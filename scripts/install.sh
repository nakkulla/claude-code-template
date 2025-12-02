#!/bin/bash

# =============================================================================
# Claude Code 글로벌 설정 설치 스크립트
# =============================================================================
# 이 스크립트는 글로벌 Claude Code 설정을 ~/.claude/에 설치합니다.
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
GLOBAL_DIR="$TEMPLATE_DIR/global"
CLAUDE_DIR="$HOME/.claude"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Claude Code 글로벌 설정 설치${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 1. 기존 설정 확인
if [[ -d "$CLAUDE_DIR" ]]; then
    echo -e "${YELLOW}⚠️  기존 ~/.claude/ 디렉토리가 발견되었습니다.${NC}"
    echo ""
    echo "선택하세요:"
    echo "  1) 백업 후 설치 (권장)"
    echo "  2) 병합 (기존 파일 유지, 새 파일만 추가)"
    echo "  3) 취소"
    echo ""
    read -p "선택 [1/2/3]: " choice

    case $choice in
        1)
            BACKUP_DIR="$HOME/.claude_backup_$(date +%Y%m%d_%H%M%S)"
            echo -e "${BLUE}📦 백업 중: $BACKUP_DIR${NC}"
            cp -r "$CLAUDE_DIR" "$BACKUP_DIR"
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
else
    mkdir -p "$CLAUDE_DIR"
fi

echo ""

# 2. 파일 복사
echo -e "${BLUE}📂 파일 설치 중...${NC}"

copy_file() {
    local src="$1"
    local dst="$2"

    if [[ "$MERGE_MODE" == true ]] && [[ -f "$dst" ]]; then
        echo -e "  ${YELLOW}⏭️  건너뜀 (기존 파일 유지): $(basename "$dst")${NC}"
    else
        cp "$src" "$dst"
        echo -e "  ${GREEN}✓${NC} $(basename "$dst")"
    fi
}

# CLAUDE.md
copy_file "$GLOBAL_DIR/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"

# settings.json
copy_file "$GLOBAL_DIR/settings.json" "$CLAUDE_DIR/settings.json"

# .claude.json (MCP 서버 설정)
copy_file "$GLOBAL_DIR/.claude.json" "$CLAUDE_DIR/.claude.json"

# 스크립트
copy_file "$GLOBAL_DIR/scripts/auto-commit-push.sh" "$CLAUDE_DIR/auto-commit-push.sh"
copy_file "$GLOBAL_DIR/scripts/ntfy-hook.sh" "$CLAUDE_DIR/ntfy-hook.sh"

# 실행 권한 부여
chmod +x "$CLAUDE_DIR/auto-commit-push.sh"
chmod +x "$CLAUDE_DIR/ntfy-hook.sh"

echo ""

# 3. ntfy 설정
echo -e "${BLUE}🔔 ntfy 알림 설정${NC}"
echo ""
echo "ntfy를 통해 모바일 알림을 받을 수 있습니다."
echo "설정하시겠습니까? (나중에 수동으로 설정할 수도 있습니다)"
echo ""
read -p "ntfy 설정 [y/N]: " setup_ntfy

if [[ "$setup_ntfy" =~ ^[Yy]$ ]]; then
    echo ""
    read -p "ntfy 토픽 이름 (예: my_claude_alerts): " ntfy_topic

    if [[ -n "$ntfy_topic" ]]; then
        # auto-commit-push.sh 수정
        sed -i "s/NTFY_TOPIC=\"\${NTFY_TOPIC:-your_topic_here}\"/NTFY_TOPIC=\"\${NTFY_TOPIC:-$ntfy_topic}\"/" "$CLAUDE_DIR/auto-commit-push.sh"
        # ntfy-hook.sh 수정
        sed -i "s/NTFY_TOPIC=\"\${NTFY_TOPIC:-your_topic_here}\"/NTFY_TOPIC=\"\${NTFY_TOPIC:-$ntfy_topic}\"/" "$CLAUDE_DIR/ntfy-hook.sh"
        echo -e "${GREEN}✓ ntfy 토픽이 설정되었습니다: $ntfy_topic${NC}"
    fi
fi

echo ""

# 4. 완료 메시지
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✅ 설치가 완료되었습니다!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "설치된 파일 위치: ${BLUE}$CLAUDE_DIR${NC}"
echo ""
echo "설치된 파일:"
ls -la "$CLAUDE_DIR"/*.md "$CLAUDE_DIR"/*.json "$CLAUDE_DIR"/*.sh 2>/dev/null | awk '{print "  " $NF}'
echo ""
echo -e "${YELLOW}다음 단계:${NC}"
echo "  1. Claude Code 재시작"
echo "  2. (선택) ntfy 앱에서 토픽 구독"
echo "  3. (선택) 환경 변수 설정:"
echo "     export PERPLEXITY_API_KEY=\"your_key\""
echo "     export GITHUB_TOKEN=\"your_token\""
echo ""
echo "문서: $TEMPLATE_DIR/docs/"
