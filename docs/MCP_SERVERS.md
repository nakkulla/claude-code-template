# MCP 서버 가이드

MCP (Model Context Protocol) 서버는 Claude Code의 기능을 확장하는 외부 서비스입니다.

---

## MCP 서버란?

MCP 서버는 Claude Code에 추가 기능을 제공합니다:

- **context7**: 라이브러리 문서 검색
- **sequential-thinking**: 복잡한 문제의 순차적 사고 지원
- **perplexity**: 실시간 웹 검색
- **github**: GitHub API 연동

---

## 설정 파일 위치

### 글로벌 설정
`~/.claude/.claude.json` - 모든 프로젝트에서 사용

### 프로젝트 설정
`.claude/.mcp.json` - 해당 프로젝트에서만 사용

---

## 설정 파일 형식

```json
{
  "$schema": "https://modelcontextprotocol.io/schemas/mcp.json",
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "package-name"],
      "env": {
        "API_KEY": "your_api_key"
      }
    }
  }
}
```

### 필드 설명

| 필드 | 설명 |
|------|------|
| `command` | 실행 명령어 (보통 `npx`) |
| `args` | 명령어 인자 |
| `env` | 환경 변수 (API 키 등) |

---

## 주요 MCP 서버

### 1. context7

라이브러리 문서를 검색하고 최신 API 정보를 제공합니다.

```json
{
  "context7": {
    "command": "npx",
    "args": ["-y", "@upstash/context7-mcp"]
  }
}
```

**사용 예시:**
```
"React hooks에 대한 최신 문서를 찾아줘"
"pandas DataFrame 메서드 문서를 검색해줘"
```

### 2. sequential-thinking

복잡한 문제를 단계별로 분석합니다.

```json
{
  "sequential-thinking": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
  }
}
```

**사용 예시:**
```
"이 알고리즘의 시간 복잡도를 분석해줘"
"이 버그의 원인을 단계별로 추적해줘"
```

### 3. perplexity

실시간 웹 검색을 수행합니다.

```json
{
  "perplexity": {
    "command": "npx",
    "args": ["-y", "@perplexity-ai/mcp-server"],
    "env": {
      "PERPLEXITY_API_KEY": "${PERPLEXITY_API_KEY}"
    }
  }
}
```

**API 키 설정:**
```bash
export PERPLEXITY_API_KEY="your_api_key"
```

**사용 예시:**
```
"2024년 Python 3.12의 새로운 기능을 검색해줘"
"최신 React 19 변경사항을 찾아줘"
```

### 4. github

GitHub API를 통해 저장소, 이슈, PR 등을 관리합니다.

```json
{
  "github": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-github"],
    "env": {
      "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
    }
  }
}
```

**토큰 설정:**
```bash
export GITHUB_TOKEN="ghp_your_token"
```

**사용 예시:**
```
"이 저장소의 열린 이슈 목록을 보여줘"
"PR #123의 변경사항을 확인해줘"
```

---

## settings.json에서 활성화

MCP 서버를 정의한 후, `settings.json`에서 활성화해야 합니다:

```json
{
  "enableAllProjectMcpServers": true,
  "enabledMcpjsonServers": [
    "context7",
    "sequential-thinking",
    "perplexity"
  ]
}
```

| 옵션 | 설명 |
|------|------|
| `enableAllProjectMcpServers` | 프로젝트 MCP 서버 자동 활성화 |
| `enabledMcpjsonServers` | 활성화할 서버 목록 |

---

## 환경 변수 사용

API 키를 설정 파일에 직접 넣지 않고 환경 변수로 관리:

### .claude.json / .mcp.json

```json
{
  "env": {
    "PERPLEXITY_API_KEY": "${PERPLEXITY_API_KEY}"
  }
}
```

### 쉘 설정 (~/.bashrc 또는 ~/.zshrc)

```bash
export PERPLEXITY_API_KEY="pplx-xxxxx"
export GITHUB_TOKEN="ghp_xxxxx"
```

---

## 보안 주의사항

### API 키 보호

1. **환경 변수 사용**: 설정 파일에 직접 키를 넣지 않음
2. **.gitignore 추가**:
   ```
   .claude/settings.local.json
   .env
   ```
3. **권한 제한**: `chmod 600 ~/.claude/.claude.json`

### 토큰 권한

- **GitHub 토큰**: 최소 필요 권한만 부여 (repo, read:org 등)
- **API 키**: 사용량 제한 설정

---

## MCP 서버 추가

### 1. NPM 패키지 확인

MCP 서버는 보통 NPM 패키지로 제공됩니다:
- `@upstash/context7-mcp`
- `@perplexity-ai/mcp-server`
- `@modelcontextprotocol/server-*`

### 2. 설정 파일에 추가

```json
{
  "mcpServers": {
    "new-server": {
      "command": "npx",
      "args": ["-y", "@package/server-name"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

### 3. settings.json에서 활성화

```json
{
  "enabledMcpjsonServers": [
    "existing-server",
    "new-server"
  ]
}
```

---

## 트러블슈팅

### 서버가 시작되지 않음
- `npx` 설치 확인: `npm install -g npx`
- 패키지 이름 확인
- 네트워크 연결 확인

### API 키 오류
- 환경 변수 설정 확인: `echo $PERPLEXITY_API_KEY`
- 키 형식 확인
- 키 만료 여부 확인

### 서버가 활성화되지 않음
- `enabledMcpjsonServers`에 서버 이름 추가 확인
- `enableAllProjectMcpServers: true` 설정 확인

### 느린 응답
- 네트워크 상태 확인
- 타임아웃 설정 확인
- 서버 상태 확인
