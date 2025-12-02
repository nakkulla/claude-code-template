# 글로벌 설정 (Global Settings)

이 폴더는 사용자 레벨의 Claude Code 설정을 담고 있습니다.
`~/.claude/` 디렉토리에 설치하여 모든 프로젝트에 적용됩니다.

---

## 파일 구조

```
global/
├── CLAUDE.md           # 글로벌 지침 (모든 프로젝트에 적용)
├── settings.json       # Claude Code 설정 (권한, Hooks, MCP 등)
├── .claude.json        # MCP 서버 정의
└── scripts/
    ├── auto-commit-push.sh  # 작업 완료 시 자동 Git 커밋/푸시
    └── ntfy-hook.sh         # 이벤트 발생 시 모바일 알림
```

---

## 파일별 역할

### CLAUDE.md
- **역할**: 모든 프로젝트에 적용되는 기본 지침
- **내용**: 문서화 규칙, 언어 설정, 코드 스타일, Git 규칙
- **위치**: `~/.claude/CLAUDE.md`

### settings.json
- **역할**: Claude Code 동작 설정
- **내용**:
  - 권한 설정 (permissions)
  - MCP 서버 활성화 (enabledMcpjsonServers)
  - Hook 설정 (Notification, Stop 이벤트)
  - 상태바 설정 (statusLine)
- **위치**: `~/.claude/settings.json`

### .claude.json
- **역할**: MCP (Model Context Protocol) 서버 정의
- **포함 서버**:
  - `context7`: 라이브러리 문서 검색
  - `sequential-thinking`: 순차적 사고 지원
  - `perplexity`: 웹 검색 (API 키 필요)
  - `github`: GitHub API 연동 (토큰 필요)
- **위치**: `~/.claude/.claude.json`

### scripts/auto-commit-push.sh
- **역할**: Claude Code 작업 완료 시 자동으로 Git 커밋 및 푸시
- **기능**:
  - 대용량 파일(>100MB) 자동 감지 및 .gitignore 추가
  - 변경사항 자동 스테이징 및 커밋
  - 커밋 메시지 자동 생성
  - 실패 시 ntfy 알림
- **위치**: `~/.claude/auto-commit-push.sh`

### scripts/ntfy-hook.sh
- **역할**: Claude Code 이벤트 발생 시 모바일 알림 발송
- **지원 이벤트**:
  - `Notification`: 사용자 입력 대기 시 알림
  - `Stop`: 작업 완료 시 알림
- **위치**: `~/.claude/ntfy-hook.sh`

---

## 설치 방법

### 1. 수동 설치

```bash
# 파일 복사
cp CLAUDE.md ~/.claude/
cp settings.json ~/.claude/
cp .claude.json ~/.claude/
cp scripts/*.sh ~/.claude/

# 스크립트 실행 권한 부여
chmod +x ~/.claude/*.sh
```

### 2. 설치 스크립트 사용

```bash
# 저장소 루트에서 실행
./scripts/install.sh
```

---

## 설정 커스터마이징

### ntfy 알림 설정
`auto-commit-push.sh`와 `ntfy-hook.sh`에서 토픽을 설정하세요:

```bash
# 방법 1: 환경변수 설정
export NTFY_TOPIC="your_topic_name"
export NTFY_SERVER="https://ntfy.sh"  # 또는 셀프호스팅 서버

# 방법 2: 스크립트 직접 수정
NTFY_TOPIC="your_topic_name"
```

### MCP 서버 API 키 설정
`.claude.json`에서 환경변수를 사용하거나 직접 키를 입력하세요:

```bash
# Perplexity API 키
export PERPLEXITY_API_KEY="your_api_key"

# GitHub 토큰
export GITHUB_TOKEN="ghp_your_token"
```

### Hooks 비활성화
`settings.json`에서 원하지 않는 Hook을 제거하세요:

```json
{
  "hooks": {
    "Notification": [],  // 알림 Hook 비활성화
    "Stop": []           // 자동 커밋 및 완료 알림 비활성화
  }
}
```
