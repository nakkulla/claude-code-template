#!/bin/bash

# =============================================================================
# ntfy notification hook for Claude Code (Project-level)
# =============================================================================
# 기능: 프로젝트 레벨에서 Claude Code 이벤트 알림 발송
#
# 설치: .claude/scripts/ntfy-hook.sh 에 저장하고 chmod +x 실행
# =============================================================================

# ===== 설정 (필요에 따라 수정) =====
NTFY_TOPIC="${NTFY_TOPIC:-your_topic_here}"
NTFY_SERVER="${NTFY_SERVER:-https://ntfy.sh}"
LOG_FILE="$HOME/.claude/ntfy-hook.log"

# Read JSON input from stdin
JSON_INPUT=$(cat)

# Extract event type
EVENT_TYPE=$(echo "$JSON_INPUT" | grep -o '"hook_event_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"hook_event_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
if [[ -z "$EVENT_TYPE" ]]; then
    EVENT_TYPE="unknown"
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
WORKING_DIR=$(echo "$JSON_INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
PROJECT_NAME=$(basename "$WORKING_DIR" 2>/dev/null || echo "Unknown")

# Function to send notification
send_notification() {
    local title="$1"
    local message="$2"
    local priority="$3"
    local tags="$4"

    # ntfy 토픽이 설정되지 않은 경우 건너뛰기
    if [[ "$NTFY_TOPIC" == "your_topic_here" ]]; then
        echo "[$TIMESTAMP] ntfy topic not configured, skipping" >> "$LOG_FILE"
        return 0
    fi

    curl -s \
        -H "Title: $title" \
        -H "Priority: $priority" \
        -H "Tags: $tags" \
        -d "$message" \
        "$NTFY_SERVER/$NTFY_TOPIC"

    echo "[$TIMESTAMP] [$PROJECT_NAME] $EVENT_TYPE: $title" >> "$LOG_FILE"
}

# Process based on event type
case "$EVENT_TYPE" in
    "Notification")
        MESSAGE=$(echo "$JSON_INPUT" | grep -o '"message"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"message"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

        # Skip default waiting message
        if [[ "$MESSAGE" == "Claude is waiting for your input" ]]; then
            echo "[$TIMESTAMP] Skipped default waiting message" >> "$LOG_FILE"
        elif echo "$MESSAGE" | grep -qiE "waiting|input|permission|approve"; then
            send_notification \
                "[$PROJECT_NAME] 입력 대기" \
                "$MESSAGE" \
                "high" \
                "hourglass_flowing_sand"
        fi
        ;;

    "Stop")
        send_notification \
            "[$PROJECT_NAME] 작업 완료" \
            "Claude Code 작업이 완료되었습니다" \
            "default" \
            "white_check_mark"
        ;;

    "SubagentStop")
        # Ignore to reduce spam
        echo "[$TIMESTAMP] SubagentStop ignored" >> "$LOG_FILE"
        ;;

    *)
        echo "[$TIMESTAMP] Unhandled event: $EVENT_TYPE" >> "$LOG_FILE"
        ;;
esac

exit 0
