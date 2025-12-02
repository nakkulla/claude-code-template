#!/bin/bash

# =============================================================================
# ntfy notification hook for Claude Code
# =============================================================================
# 기능: Claude Code 이벤트(Notification, Stop 등)에 대한 모바일 알림 발송
#
# 지원 이벤트:
# - Notification: 사용자 입력 대기 시 알림
# - Stop: 작업 완료 시 알림
# - SubagentStop: 무시 (스팸 방지)
#
# 설치: ~/.claude/ntfy-hook.sh 에 복사하고 chmod +x 실행
# =============================================================================

# ===== 설정 (필요에 따라 수정) =====
NTFY_TOPIC="${NTFY_TOPIC:-your_topic_here}"  # ntfy 토픽 (환경변수 또는 직접 설정)
NTFY_SERVER="${NTFY_SERVER:-https://ntfy.sh}"  # ntfy 서버 URL (셀프호스팅 시 변경)
LOG_FILE="$HOME/.claude/ntfy-hook.log"

# Read JSON input from stdin
JSON_INPUT=$(cat)

# Extract event type and relevant data without jq (using grep/sed, handling spaces)
EVENT_TYPE=$(echo "$JSON_INPUT" | grep -o '"hook_event_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"hook_event_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
if [[ -z "$EVENT_TYPE" ]]; then
    EVENT_TYPE="unknown"
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
WORKING_DIR=$(echo "$JSON_INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
if [[ -z "$WORKING_DIR" ]]; then
    WORKING_DIR="Unknown"
fi

# Function to send notification
send_notification() {
    local title="$1"
    local message="$2"
    local priority="$3"
    local tags="$4"

    # ntfy 토픽이 설정되지 않은 경우 건너뛰기
    if [[ "$NTFY_TOPIC" == "your_topic_here" ]]; then
        echo "[$TIMESTAMP] ntfy topic not configured, skipping notification" >> "$LOG_FILE"
        return 0
    fi

    curl -s \
        -H "Title: $title" \
        -H "Priority: $priority" \
        -H "Tags: $tags" \
        -d "$message" \
        "$NTFY_SERVER/$NTFY_TOPIC"

    # Log the notification
    echo "[$TIMESTAMP] $EVENT_TYPE notification sent: $title" >> "$LOG_FILE"
}

# Process based on event type
case "$EVENT_TYPE" in
    "Notification")
        # Extract message for waiting status (without jq)
        MESSAGE=$(echo "$JSON_INPUT" | grep -o '"message"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"message"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        if [[ -z "$MESSAGE" ]]; then
            MESSAGE="Claude가 입력을 기다리고 있습니다"
        fi

        # Skip the default "Claude is waiting for your input" message to prevent spam
        if [[ "$MESSAGE" == "Claude is waiting for your input" ]]; then
            echo "[$TIMESTAMP] Skipped default waiting message" >> "$LOG_FILE"
        # Check if it's actually waiting for important input or permission
        elif echo "$MESSAGE" | grep -qiE "waiting|input|permission|approve|allow"; then
            send_notification \
                "Claude Code - 입력 대기 중" \
                "$MESSAGE" \
                "high" \
                "hourglass_flowing_sand,keyboard"
        fi
        ;;

    "Stop")
        # Simple completion message
        MESSAGE="Claude Code 작업이 완료되었습니다"

        # Add working directory if available
        if [ "$WORKING_DIR" != "Unknown" ]; then
            MESSAGE="$MESSAGE\n위치: $WORKING_DIR"
        fi

        send_notification \
            "Claude Code - 작업 완료" \
            "$MESSAGE" \
            "default" \
            "white_check_mark,robot"
        ;;

    "SubagentStop")
        # Ignore subagent completions to reduce notification spam
        echo "[$TIMESTAMP] SubagentStop event ignored" >> "$LOG_FILE"
        exit 0
        ;;

    *)
        # Log other events but don't send notifications
        echo "[$TIMESTAMP] Unhandled event type: $EVENT_TYPE" >> "$LOG_FILE"
        exit 0
        ;;
esac

# Exit successfully
exit 0
