#!/bin/bash

# Discord 웹훅 notification hook for Claude Code
# This script sends notifications based on different Claude Code events

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/discord-config.sh"

# Read JSON input from stdin
JSON_INPUT=$(cat)

# Extract event type and relevant data
EVENT_TYPE=$(echo "$JSON_INPUT" | grep -o '"hook_event_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*:\s*"\([^"]*\)".*/\1/')
if [[ -z "$EVENT_TYPE" ]]; then
    EVENT_TYPE="unknown"
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
WORKING_DIR=$(echo "$JSON_INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*:\s*"\([^"]*\)".*/\1/')
if [[ -z "$WORKING_DIR" ]]; then
    WORKING_DIR="Unknown"
fi

# Function to send Discord notification
send_discord() {
    local title="$1"
    local message="$2"

    # allowed_mentions로 실제 ping이 작동하도록 설정
    local ALLOWED_MENTIONS="\"allowed_mentions\":{\"users\":[\"$DISCORD_USER_ID\"]}"

    # 멘션을 텍스트 안에 포함시켜서 알림에 모든 내용이 보이도록 함
    local FULL_MESSAGE="$DISCORD_USER_MENTION **$title**\n$message"
    JSON_DATA="{\"content\":\"$FULL_MESSAGE\",$ALLOWED_MENTIONS}"

    curl -s --connect-timeout 5 --max-time 10 \
        -X POST "$DISCORD_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "$JSON_DATA" > /dev/null 2>&1

    # Log the notification
    echo "[$TIMESTAMP] $EVENT_TYPE notification sent: $title" >> ~/.claude/discord-hook.log
}

# Process based on event type
case "$EVENT_TYPE" in
    "SessionStart")
        # 세션 시작 알림
        PROJECT_NAME=$(basename "$WORKING_DIR")
        send_discord \
            "🚀 Claude Code - 세션 시작" \
            "프로젝트: $PROJECT_NAME\n📂 위치: $WORKING_DIR"

        # Claude에게 추가 컨텍스트 전달
        cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "프로젝트 세션이 시작되었습니다. 작업 중인 디렉토리: ${WORKING_DIR}"
  }
}
EOF
        ;;

    "Notification")
        # Extract message for waiting status
        MESSAGE=$(echo "$JSON_INPUT" | grep -o '"message"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*:\s*"\([^"]*\)".*/\1/')
        if [[ -z "$MESSAGE" ]]; then
            MESSAGE="Claude가 입력을 기다리고 있습니다"
        fi

        # Skip the default "Claude is waiting for your input" message
        if [[ "$MESSAGE" == "Claude is waiting for your input" ]]; then
            echo "[$TIMESTAMP] Skipped default waiting message" >> ~/.claude/discord-hook.log
        else
            send_discord \
                "⏳ Claude Code - 입력 대기 중" \
                "💬 $MESSAGE"
        fi
        ;;

    "Stop")
        MESSAGE="작업이 완료되었습니다"

        if [ "$WORKING_DIR" != "Unknown" ]; then
            PROJECT_NAME=$(basename "$WORKING_DIR")
            MESSAGE="📁 프로젝트: $PROJECT_NAME\n✅ $MESSAGE"
        fi

        send_discord \
            "✅ Claude Code - 작업 완료" \
            "$MESSAGE"
        ;;

    "SubagentStop")
        # Ignore subagent completions
        echo "[$TIMESTAMP] SubagentStop event ignored" >> ~/.claude/discord-hook.log
        exit 0
        ;;

    *)
        echo "[$TIMESTAMP] Unhandled event type: $EVENT_TYPE" >> ~/.claude/discord-hook.log
        exit 0
        ;;
esac

exit 0
