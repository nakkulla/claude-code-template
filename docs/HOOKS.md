# Hooks 가이드

Claude Code Hook은 특정 이벤트 발생 시 자동으로 실행되는 스크립트입니다.

---

## Hook 이벤트 종류

| 이벤트 | 발생 시점 | 용도 |
|--------|----------|------|
| `SessionStart` | Claude Code 세션 시작 | 환경 초기화, 의존성 설치 |
| `Stop` | Claude Code 작업 완료 | 자동 커밋, 완료 알림 |
| `Notification` | 사용자 입력 대기 | 대기 알림 |
| `SubagentStop` | 서브에이전트 완료 | (보통 무시) |

---

## Hook 설정 방법

### settings.json에서 설정

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "스크립트 경로",
            "timeout": 5000
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "스크립트 경로",
            "timeout": 60000
          }
        ]
      }
    ]
  }
}
```

### 설정 옵션

| 옵션 | 설명 |
|------|------|
| `matcher` | 조건 문자열 (빈 문자열 = 항상 실행) |
| `type` | `"command"` (쉘 명령어 실행) |
| `command` | 실행할 스크립트 경로 |
| `timeout` | 타임아웃 (밀리초) |

---

## 스크립트 경로 변수

| 변수 | 설명 |
|------|------|
| `~` | 사용자 홈 디렉토리 |
| `$CLAUDE_PROJECT_DIR` | 현재 프로젝트 디렉토리 |

### 예시

```json
// 글로벌 스크립트
"command": "~/.claude/ntfy-hook.sh"

// 프로젝트 스크립트
"command": "\"$CLAUDE_PROJECT_DIR\"/.claude/scripts/hook.sh"
```

---

## Hook 스크립트 작성

### 기본 구조

```bash
#!/bin/bash

# Claude Code가 JSON 형식으로 컨텍스트 전달
JSON_INPUT=$(cat)

# JSON에서 정보 추출 (jq 없이)
EVENT_TYPE=$(echo "$JSON_INPUT" | grep -o '"hook_event_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')
WORKING_DIR=$(echo "$JSON_INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')

# 이벤트 처리
case "$EVENT_TYPE" in
    "SessionStart")
        # 세션 시작 처리
        ;;
    "Stop")
        # 작업 완료 처리
        ;;
    "Notification")
        # 알림 처리
        ;;
esac

exit 0
```

### JSON 입력 예시

```json
{
  "hook_event_name": "Stop",
  "cwd": "/path/to/project",
  "session_id": "abc123",
  "stop_hook_active": true
}
```

---

## 자주 사용하는 Hook 패턴

### 1. 세션 시작 시 초기화

```bash
#!/bin/bash
JSON_INPUT=$(cat)
WORKING_DIR=$(echo "$JSON_INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')

# 필수 디렉토리 생성
mkdir -p "$WORKING_DIR"/{results,figures,docs}

# 환경 확인 메시지
echo "프로젝트가 초기화되었습니다: $WORKING_DIR"
```

### 2. 작업 완료 시 자동 커밋

```bash
#!/bin/bash
JSON_INPUT=$(cat)
WORKING_DIR=$(echo "$JSON_INPUT" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')

cd "$WORKING_DIR" || exit 0

# Git 저장소가 아니면 종료
[[ ! -d ".git" ]] && exit 0

# 변경사항 없으면 종료
git diff --quiet && git diff --cached --quiet && exit 0

# 자동 커밋
git add -A
git commit -m "[Auto] $(date '+%Y-%m-%d %H:%M')"
git push origin HEAD
```

### 3. ntfy 알림 전송

```bash
#!/bin/bash
NTFY_TOPIC="your_topic"
NTFY_SERVER="https://ntfy.sh"

JSON_INPUT=$(cat)
EVENT_TYPE=$(echo "$JSON_INPUT" | grep -o '"hook_event_name"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*"\([^"]*\)"$/\1/')

case "$EVENT_TYPE" in
    "Stop")
        curl -s -d "작업이 완료되었습니다" "$NTFY_SERVER/$NTFY_TOPIC"
        ;;
    "Notification")
        curl -s -d "입력을 기다리고 있습니다" "$NTFY_SERVER/$NTFY_TOPIC"
        ;;
esac
```

---

## 글로벌 vs 프로젝트 Hook

### 글로벌 Hook (`~/.claude/`)
- 모든 프로젝트에 적용
- 공통 작업 (알림, 로깅 등)
- `settings.json`에서 설정

### 프로젝트 Hook (`.claude/`)
- 해당 프로젝트에만 적용
- 프로젝트 특화 작업 (빌드, 테스트 등)
- `$CLAUDE_PROJECT_DIR` 변수 사용

---

## 디버깅

### 로그 파일 확인

```bash
# Hook 실행 로그
cat ~/.claude/hook.log

# ntfy Hook 로그
cat ~/.claude/ntfy-hook.log

# 자동 커밋 로그
cat ~/.claude/auto-commit-push.log
```

### 스크립트 직접 테스트

```bash
# JSON 입력 시뮬레이션
echo '{"hook_event_name": "Stop", "cwd": "/path/to/project"}' | ./hook.sh
```

---

## 주의사항

1. **타임아웃**: 적절한 타임아웃 설정 (기본 5-60초)
2. **에러 처리**: 스크립트 실패 시 Claude Code 작업에 영향 없도록
3. **비동기 작업**: 긴 작업은 백그라운드로 실행
4. **로깅**: 디버깅을 위한 로그 기록
5. **실행 권한**: `chmod +x` 필수
