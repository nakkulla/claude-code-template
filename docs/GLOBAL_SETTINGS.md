# 글로벌 설정 가이드

글로벌 설정은 모든 프로젝트에 적용되는 사용자 레벨 Claude Code 설정입니다.

---

## 설정 위치

모든 글로벌 설정은 `~/.claude/` 디렉토리에 저장됩니다.

```
~/.claude/
├── CLAUDE.md           # 기본 지침
├── settings.json       # Claude Code 설정
├── .claude.json        # MCP 서버 정의
├── auto-commit-push.sh # 자동 커밋 Hook
└── ntfy-hook.sh        # 알림 Hook
```

---

## CLAUDE.md

모든 프로젝트에 적용되는 기본 지침입니다.

### 포함 내용
- 문서화 규칙 (plan/result 파일 형식)
- 언어 설정 (한국어/영어)
- 코드 스타일 가이드
- Git 규칙

### 예시

```markdown
# Claude Code 글로벌 지침

## 1. 문서화 규칙
- 계획: `docs/plan-{YYYYMMDD-HHMM}.md`
- 결과: `docs/result-{YYYYMMDD-HHMM}.md`

## 2. 언어
- 문서는 한국어로 작성

## 3. 코드 스타일
- 간결하고 읽기 쉬운 코드 작성
- 불필요한 주석 피하기
```

---

## settings.json

Claude Code의 동작을 제어하는 설정 파일입니다.

### 전체 구조

```json
{
  "permissions": { ... },
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": [ ... ],
  "hooks": { ... },
  "statusLine": { ... },
  "alwaysThinkingEnabled": false
}
```

### permissions

권한 설정:

```json
{
  "permissions": {
    "allow": ["*"],
    "defaultMode": "bypassPermissions",
    "askBeforeRunning": false
  }
}
```

| 옵션 | 설명 |
|------|------|
| `allow` | 허용할 도구/명령어 패턴 |
| `defaultMode` | 기본 권한 모드 |
| `askBeforeRunning` | 실행 전 확인 여부 |

### hooks

이벤트별 Hook 설정:

```json
{
  "hooks": {
    "Notification": [ ... ],
    "Stop": [ ... ]
  }
}
```

자세한 내용은 [HOOKS.md](HOOKS.md) 참조.

### statusLine

상태바 설정:

```json
{
  "statusLine": {
    "type": "command",
    "command": "npx -y ccusage@latest statusline",
    "padding": 0
  }
}
```

토큰 사용량을 실시간으로 표시합니다.

### MCP 서버 활성화

```json
{
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": [
    "context7",
    "sequential-thinking"
  ]
}
```

---

## .claude.json

MCP 서버를 정의하는 파일입니다.

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "perplexity": {
      "command": "npx",
      "args": ["-y", "@perplexity-ai/mcp-server"],
      "env": {
        "PERPLEXITY_API_KEY": "${PERPLEXITY_API_KEY}"
      }
    }
  }
}
```

자세한 내용은 [MCP_SERVERS.md](MCP_SERVERS.md) 참조.

---

## Hook 스크립트

### auto-commit-push.sh

작업 완료 시 자동으로 Git 커밋 및 푸시:

**기능:**
- 대용량 파일(>100MB) 자동 감지 및 .gitignore 추가
- 변경사항 자동 스테이징 및 커밋
- 커밋 메시지 자동 생성
- 실패 시 ntfy 알림

**설정:**
```bash
NTFY_TOPIC="your_topic"  # ntfy 토픽
MAX_FILE_SIZE=100        # MB
```

### ntfy-hook.sh

이벤트 발생 시 모바일 알림:

**지원 이벤트:**
- `Notification`: 입력 대기 알림
- `Stop`: 작업 완료 알림

**설정:**
```bash
NTFY_TOPIC="your_topic"
NTFY_SERVER="https://ntfy.sh"
```

---

## 설치 방법

### 1. 수동 설치

```bash
# 파일 복사
cp global/CLAUDE.md ~/.claude/
cp global/settings.json ~/.claude/
cp global/.claude.json ~/.claude/
cp global/scripts/*.sh ~/.claude/

# 실행 권한 부여
chmod +x ~/.claude/*.sh
```

### 2. 설치 스크립트

```bash
./scripts/install.sh
```

---

## 커스터마이징

### 언어 변경

`CLAUDE.md`에서 언어 설정:

```markdown
## 언어
- 문서는 영어로 작성합니다.
```

### Hook 비활성화

`settings.json`에서 Hook 제거:

```json
{
  "hooks": {
    "Notification": [],
    "Stop": []
  }
}
```

### ntfy 설정

환경 변수 또는 스크립트 직접 수정:

```bash
# 환경 변수
export NTFY_TOPIC="my_topic"

# 또는 스크립트 수정
NTFY_TOPIC="my_topic"
```

---

## 보안

### API 키 관리

환경 변수 사용:

```bash
# ~/.bashrc 또는 ~/.zshrc
export PERPLEXITY_API_KEY="your_key"
export GITHUB_TOKEN="your_token"
```

### 파일 권한

```bash
chmod 600 ~/.claude/settings.json
chmod 600 ~/.claude/.claude.json
chmod 700 ~/.claude/
```

### .gitignore

글로벌 `.claude/` 폴더는 Git에 포함하지 않음 (개인 설정)
