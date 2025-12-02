#!/bin/bash

# =============================================================================
# Claude Code 프로젝트 설정 초기화 스크립트
# =============================================================================
# 이 스크립트는 프로젝트에 Claude Code 설정을 초기화합니다.
#
# 사용법: ./init-project.sh /path/to/project
# =============================================================================

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 스크립트 위치
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_TEMPLATE="$TEMPLATE_DIR/project"

# 대상 프로젝트 디렉토리
TARGET_DIR="${1:-.}"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
CLAUDE_DIR="$TARGET_DIR/.claude"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Claude Code 프로젝트 설정 초기화${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "대상 프로젝트: ${BLUE}$TARGET_DIR${NC}"
echo ""

# 1. 기존 설정 확인
if [[ -d "$CLAUDE_DIR" ]]; then
    echo -e "${YELLOW}⚠️  기존 .claude/ 디렉토리가 발견되었습니다.${NC}"
    echo ""
    echo "선택하세요:"
    echo "  1) 백업 후 초기화"
    echo "  2) 병합 (기존 파일 유지, 새 파일만 추가)"
    echo "  3) 취소"
    echo ""
    read -p "선택 [1/2/3]: " choice

    case $choice in
        1)
            BACKUP_DIR="$TARGET_DIR/.claude_backup_$(date +%Y%m%d_%H%M%S)"
            echo -e "${BLUE}📦 백업 중: $BACKUP_DIR${NC}"
            mv "$CLAUDE_DIR" "$BACKUP_DIR"
            echo -e "${GREEN}✓ 백업 완료${NC}"
            ;;
        2)
            echo -e "${BLUE}🔀 병합 모드로 설치합니다.${NC}"
            MERGE_MODE=true
            ;;
        3)
            echo -e "${YELLOW}설치가 취소되었습니다.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}잘못된 선택입니다.${NC}"
            exit 1
            ;;
    esac
fi

echo ""

# 2. 디렉토리 생성
echo -e "${BLUE}📂 디렉토리 구조 생성 중...${NC}"
mkdir -p "$CLAUDE_DIR"/{agents,commands,skills/example-skill,scripts}
echo -e "${GREEN}✓ 디렉토리 생성 완료${NC}"
echo ""

# 3. 파일 복사 함수
copy_file() {
    local src="$1"
    local dst="$2"

    if [[ "$MERGE_MODE" == true ]] && [[ -f "$dst" ]]; then
        echo -e "  ${YELLOW}⏭️  건너뜀: $(basename "$dst")${NC}"
    else
        cp "$src" "$dst"
        echo -e "  ${GREEN}✓${NC} $(basename "$dst")"
    fi
}

# 4. 파일 복사
echo -e "${BLUE}📄 파일 복사 중...${NC}"

# 기본 설정 파일
copy_file "$PROJECT_TEMPLATE/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
copy_file "$PROJECT_TEMPLATE/settings.json" "$CLAUDE_DIR/settings.json"
copy_file "$PROJECT_TEMPLATE/.mcp.json" "$CLAUDE_DIR/.mcp.json"

# Agents
copy_file "$PROJECT_TEMPLATE/agents/README.md" "$CLAUDE_DIR/agents/README.md"
copy_file "$PROJECT_TEMPLATE/agents/example-agent.md" "$CLAUDE_DIR/agents/example-agent.md"

# Commands
copy_file "$PROJECT_TEMPLATE/commands/README.md" "$CLAUDE_DIR/commands/README.md"
copy_file "$PROJECT_TEMPLATE/commands/example-command.md" "$CLAUDE_DIR/commands/example-command.md"
copy_file "$PROJECT_TEMPLATE/commands/commit-push.md" "$CLAUDE_DIR/commands/commit-push.md"

# Skills
copy_file "$PROJECT_TEMPLATE/skills/README.md" "$CLAUDE_DIR/skills/README.md"
copy_file "$PROJECT_TEMPLATE/skills/example-skill/SKILL.md" "$CLAUDE_DIR/skills/example-skill/SKILL.md"

# Scripts
copy_file "$PROJECT_TEMPLATE/scripts/session-start-hook.sh" "$CLAUDE_DIR/scripts/session-start-hook.sh"
copy_file "$PROJECT_TEMPLATE/scripts/ntfy-hook.sh" "$CLAUDE_DIR/scripts/ntfy-hook.sh"

# README
copy_file "$PROJECT_TEMPLATE/README.md" "$CLAUDE_DIR/README.md"

# 실행 권한
chmod +x "$CLAUDE_DIR/scripts/"*.sh

echo ""

# 5. 프로젝트 정보 입력 (선택)
echo -e "${BLUE}📝 프로젝트 정보 설정 (선택)${NC}"
echo ""
read -p "프로젝트명 (Enter로 건너뛰기): " project_name

if [[ -n "$project_name" ]]; then
    sed -i "s/\[프로젝트명\]/$project_name/g" "$CLAUDE_DIR/CLAUDE.md"
    echo -e "${GREEN}✓ 프로젝트명이 설정되었습니다: $project_name${NC}"
fi

echo ""

# 6. ntfy 설정 (선택)
echo -e "${BLUE}🔔 ntfy 알림 설정 (선택)${NC}"
echo ""
read -p "ntfy 토픽 (Enter로 건너뛰기): " ntfy_topic

if [[ -n "$ntfy_topic" ]]; then
    sed -i "s/NTFY_TOPIC=\"\${NTFY_TOPIC:-your_topic_here}\"/NTFY_TOPIC=\"\${NTFY_TOPIC:-$ntfy_topic}\"/" "$CLAUDE_DIR/scripts/ntfy-hook.sh"
    echo -e "${GREEN}✓ ntfy 토픽이 설정되었습니다: $ntfy_topic${NC}"
fi

echo ""

# 7. .gitignore 업데이트 (선택)
echo -e "${BLUE}📋 .gitignore 업데이트${NC}"
echo ""

GITIGNORE_ENTRIES="
# Claude Code 자동 생성 파일
.claude/claude_setting/
.claude/session-env/
.claude/debug/
.claude/*.log
"

if [[ -f "$TARGET_DIR/.gitignore" ]]; then
    if ! grep -q "Claude Code" "$TARGET_DIR/.gitignore"; then
        read -p ".gitignore에 Claude Code 항목을 추가하시겠습니까? [Y/n]: " add_gitignore
        if [[ ! "$add_gitignore" =~ ^[Nn]$ ]]; then
            echo "$GITIGNORE_ENTRIES" >> "$TARGET_DIR/.gitignore"
            echo -e "${GREEN}✓ .gitignore가 업데이트되었습니다.${NC}"
        fi
    else
        echo -e "${YELLOW}⏭️  .gitignore에 이미 Claude Code 항목이 있습니다.${NC}"
    fi
else
    read -p ".gitignore 파일을 생성하시겠습니까? [Y/n]: " create_gitignore
    if [[ ! "$create_gitignore" =~ ^[Nn]$ ]]; then
        echo "$GITIGNORE_ENTRIES" > "$TARGET_DIR/.gitignore"
        echo -e "${GREEN}✓ .gitignore가 생성되었습니다.${NC}"
    fi
fi

echo ""

# 8. 완료 메시지
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ 프로젝트 설정이 완료되었습니다!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "설정 위치: ${BLUE}$CLAUDE_DIR${NC}"
echo ""
echo "생성된 구조:"
find "$CLAUDE_DIR" -type f | sort | while read file; do
    echo "  ${file#$CLAUDE_DIR/}"
done
echo ""
echo -e "${YELLOW}다음 단계:${NC}"
echo "  1. .claude/CLAUDE.md 수정: 프로젝트 정보 입력"
echo "  2. .claude/agents/ 수정: 프로젝트 특화 에이전트 추가"
echo "  3. .claude/commands/ 수정: 자주 사용하는 명령어 추가"
echo "  4. .claude/skills/ 수정: 도메인 특화 스킬 추가"
echo ""
echo "문서: $TEMPLATE_DIR/docs/"
