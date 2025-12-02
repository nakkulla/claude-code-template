#!/bin/bash

# =============================================================================
# Session Start Hook for Claude Code
# =============================================================================
# 기능: Claude Code 세션 시작 시 자동 실행되는 초기화 스크립트
#
# 설치: .claude/scripts/session-start-hook.sh 에 저장하고 chmod +x 실행
# =============================================================================

# Read JSON input from stdin
JSON_INPUT=$(cat)

# Extract working directory
WORKING_DIR=$(echo "$JSON_INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Log session start
echo "[$TIMESTAMP] Session started in: $WORKING_DIR" >> "$HOME/.claude/session.log"

# ===== 초기화 작업 추가 =====

# 예시 1: 환경 변수 확인
# if [[ -z "$IMPORTANT_VAR" ]]; then
#     echo "Warning: IMPORTANT_VAR is not set"
# fi

# 예시 2: 필수 디렉토리 생성
# mkdir -p "$WORKING_DIR"/{results,figures,docs}

# 예시 3: 가상환경 활성화 (필요시)
# source "$WORKING_DIR/venv/bin/activate"

# 예시 4: 의존성 확인
# if [[ -f "$WORKING_DIR/requirements.txt" ]]; then
#     pip install -r "$WORKING_DIR/requirements.txt" --quiet
# fi

# ===========================

# 성공 메시지 출력 (Claude Code에서 표시됨)
echo "프로젝트 세션이 시작되었습니다. 작업 중인 디렉토리: $WORKING_DIR"

exit 0
