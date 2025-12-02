#!/bin/bash

# =============================================================================
# Smart auto-commit and push script for Claude Code Stop hook
# =============================================================================
# 기능:
# 1. 대용량 파일(>100MB) 자동 감지 및 .gitignore 추가
# 2. 변경사항 자동 커밋
# 3. Git push 실행
# 4. 실패 시 ntfy 알림 발송
#
# 설치: ~/.claude/auto-commit-push.sh 에 복사하고 chmod +x 실행
# =============================================================================

# ===== 설정 (필요에 따라 수정) =====
NTFY_TOPIC="${NTFY_TOPIC:-your_topic_here}"  # ntfy 토픽 (환경변수 또는 직접 설정)
NTFY_SERVER="${NTFY_SERVER:-https://ntfy.sh}"  # ntfy 서버 URL
LOG_FILE="$HOME/.claude/auto-commit-push.log"
MAX_FILE_SIZE=100  # MB (이 크기 이상 파일은 .gitignore에 추가)

# Read JSON input from stdin (passed by Claude Code hook)
JSON_INPUT=$(cat)

# Extract working directory
WORKING_DIR=$(echo "$JSON_INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
if [[ -z "$WORKING_DIR" ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] No working directory found, exiting" >> "$LOG_FILE"
    exit 0
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Function to send notification
send_notification() {
    local title="$1"
    local message="$2"
    local priority="$3"
    local tags="$4"

    # ntfy 토픽이 설정되지 않은 경우 건너뛰기
    if [[ "$NTFY_TOPIC" == "your_topic_here" ]]; then
        return 0
    fi

    curl -s \
        -H "Title: $title" \
        -H "Priority: $priority" \
        -H "Tags: $tags" \
        -d "$message" \
        "$NTFY_SERVER/$NTFY_TOPIC" > /dev/null 2>&1
}

# Function to log
log() {
    echo "[$TIMESTAMP] $1" >> "$LOG_FILE"
}

# Navigate to working directory
cd "$WORKING_DIR" || {
    log "Failed to cd to $WORKING_DIR"
    exit 1
}

# Check if it's a git repository
if [[ ! -d ".git" ]]; then
    log "Not a git repository: $WORKING_DIR"
    exit 0
fi

# Check if there are any changes
if git diff --quiet && git diff --cached --quiet && [[ -z $(git ls-files --others --exclude-standard) ]]; then
    log "No changes to commit in $WORKING_DIR"
    exit 0
fi

log "Starting auto-commit in $WORKING_DIR"

# Step 1: Find and exclude large files (>100MB)
LARGE_FILES_FOUND=0
GITIGNORE_UPDATED=0

while IFS= read -r file; do
    if [[ -n "$file" ]]; then
        # Get relative path
        rel_path="${file#./}"

        # Check if already in .gitignore
        if ! grep -qxF "$rel_path" .gitignore 2>/dev/null; then
            echo "$rel_path" >> .gitignore
            log "Added to .gitignore: $rel_path ($(du -h "$file" | cut -f1))"
            GITIGNORE_UPDATED=1
        fi
        LARGE_FILES_FOUND=1
    fi
done < <(find . -type f -size +${MAX_FILE_SIZE}M ! -path "./.git/*" 2>/dev/null)

if [[ $LARGE_FILES_FOUND -eq 1 ]]; then
    log "Large files (>100MB) detected and added to .gitignore"
fi

# Step 2: Stage all changes
git add -A

# Step 3: Check if there are staged changes
if git diff --cached --quiet; then
    log "No staged changes after adding"
    exit 0
fi

# Step 4: Create commit message based on changes
ADDED=$(git diff --cached --name-only --diff-filter=A | wc -l)
MODIFIED=$(git diff --cached --name-only --diff-filter=M | wc -l)
DELETED=$(git diff --cached --name-only --diff-filter=D | wc -l)

# Get main changed files (up to 3)
MAIN_FILES=$(git diff --cached --name-only | head -3 | xargs -I {} basename {} | tr '\n' ',' | sed 's/,$//')

COMMIT_MSG="[$(date '+%Y-%m-%d %H:%M')] Auto-commit: $MAIN_FILES"
if [[ $ADDED -gt 0 || $MODIFIED -gt 0 || $DELETED -gt 0 ]]; then
    COMMIT_MSG="$COMMIT_MSG (+$ADDED ~$MODIFIED -$DELETED)"
fi

# Step 5: Commit
if ! git commit -m "$COMMIT_MSG" >> "$LOG_FILE" 2>&1; then
    log "Commit failed"
    send_notification \
        "Git Commit Failed" \
        "Commit failed in $WORKING_DIR" \
        "high" \
        "x,warning"
    exit 1
fi

log "Committed: $COMMIT_MSG"

# Step 6: Push
BRANCH=$(git rev-parse --abbrev-ref HEAD)
PUSH_OUTPUT=$(git push origin "$BRANCH" 2>&1)
PUSH_RESULT=$?

if [[ $PUSH_RESULT -ne 0 ]]; then
    log "Push failed: $PUSH_OUTPUT"

    # Check if it's a large file error
    if echo "$PUSH_OUTPUT" | grep -q "exceeds GitHub's file size limit"; then
        send_notification \
            "Git Push Failed - Large File" \
            "Push failed due to large file. Manual intervention needed.\n$WORKING_DIR" \
            "urgent" \
            "x,file"
    else
        send_notification \
            "Git Push Failed" \
            "Push failed in $WORKING_DIR\nBranch: $BRANCH\nCheck log for details" \
            "high" \
            "x,warning"
    fi
    exit 1
fi

log "Pushed to $BRANCH successfully"

exit 0
