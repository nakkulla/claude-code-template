#!/bin/bash

# Auto-commit hook - 작업 완료 시 자동 커밋 및 푸시
# Stop 이벤트에서 호출됨
# 로컬 환경에서만 작동 (웹 환경에서는 스킵)

# 웹 환경에서는 스킵
if [ "$CLAUDE_CODE_REMOTE" = "true" ]; then
    echo "Skipping auto-commit (remote/web environment)"
    exit 0
fi

# JSON input 읽기
JSON_INPUT=$(cat)

# 환경 변수
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Git 레포지토리 확인 - 없으면 스킵
if ! git -C "$PROJECT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not a git repository - skipping auto-commit"
    exit 0
fi
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
BRANCH=$(git -C "$PROJECT_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)

# 로그 파일
LOG_FILE="$PROJECT_DIR/.claude/auto-commit.log"

# Discord 설정 로드
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/discord-config.sh"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Discord 알림 함수
send_discord() {
    local title="$1"
    local message="$2"
    local FULL_MESSAGE="$DISCORD_USER_MENTION **$title**\n$message"

    curl -s --connect-timeout 5 --max-time 10 \
        -X POST "$DISCORD_WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{\"content\":\"$FULL_MESSAGE\",\"allowed_mentions\":{\"users\":[\"$DISCORD_USER_ID\"]}}" > /dev/null 2>&1
}

# main/master 브랜치 확인 (선택적 - 현재는 모든 브랜치에 푸시)
# if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
#     log "main/master 브랜치 - 자동 푸시 스킵"
#     exit 0
# fi

cd "$PROJECT_DIR" || exit 1

# 변경사항 확인
CHANGES=$(git status --porcelain 2>/dev/null)

if [ -z "$CHANGES" ]; then
    log "변경사항 없음 - 커밋 스킵"
    exit 0
fi

# 변경된 파일 분석
ADDED=$(echo "$CHANGES" | grep -c "^A\|^??" || echo "0")
MODIFIED=$(echo "$CHANGES" | grep -c "^M\|^ M" || echo "0")
DELETED=$(echo "$CHANGES" | grep -c "^D\|^ D" || echo "0")

# 주요 변경 파일 (최대 3개)
MAIN_FILES=$(echo "$CHANGES" | head -3 | awk '{print $2}' | xargs -I{} basename {} 2>/dev/null | tr '\n' ', ' | sed 's/,$//')

# 커밋 메시지 생성
generate_commit_message() {
    local msg=""

    # 변경 유형 파악
    if [ "$ADDED" -gt 0 ] && [ "$MODIFIED" -eq 0 ] && [ "$DELETED" -eq 0 ]; then
        msg="Add"
    elif [ "$MODIFIED" -gt 0 ] && [ "$ADDED" -eq 0 ] && [ "$DELETED" -eq 0 ]; then
        msg="Update"
    elif [ "$DELETED" -gt 0 ] && [ "$ADDED" -eq 0 ] && [ "$MODIFIED" -eq 0 ]; then
        msg="Remove"
    else
        msg="Update"
    fi

    # 파일 정보 추가
    if [ -n "$MAIN_FILES" ]; then
        msg="$msg: $MAIN_FILES"
    fi

    # 통계 추가
    local stats=""
    [ "$ADDED" -gt 0 ] && stats="+$ADDED"
    [ "$MODIFIED" -gt 0 ] && stats="$stats${stats:+, }~$MODIFIED"
    [ "$DELETED" -gt 0 ] && stats="$stats${stats:+, }-$DELETED"

    if [ -n "$stats" ]; then
        msg="$msg ($stats files)"
    fi

    echo "$msg"
}

COMMIT_MSG=$(generate_commit_message)
FULL_MSG="[$TIMESTAMP] $COMMIT_MSG

🤖 Auto-committed by Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"

# 모든 변경사항 스테이징
git add -A

# 커밋
if git commit -m "$FULL_MSG" 2>/dev/null; then
    log "커밋 성공: $COMMIT_MSG"

    # 푸시 (현재 브랜치)
    if [ -n "$BRANCH" ]; then
        # 원격 브랜치 확인
        REMOTE=$(git remote 2>/dev/null | head -1)
        if [ -n "$REMOTE" ]; then
            if timeout 90 git push "$REMOTE" "$BRANCH" 2>/dev/null; then
                log "푸시 성공: $REMOTE/$BRANCH"
                send_discord \
                    "📤 Auto-commit 완료" \
                    "📌 브랜치: $BRANCH\n📝 $COMMIT_MSG"
            else
                log "푸시 실패: $REMOTE/$BRANCH"
                send_discord \
                    "❌ Auto-commit 푸시 실패" \
                    "📌 브랜치: $BRANCH\n⚠️ 수동 확인 필요"
            fi
        else
            log "원격 저장소 없음 - 푸시 스킵"
        fi
    fi
else
    log "커밋 실패 또는 변경사항 없음"
fi

exit 0
