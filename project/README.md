# 프로젝트 설정 (Project Settings)

이 폴더는 프로젝트 레벨의 Claude Code 설정을 담고 있습니다.
각 프로젝트의 `.claude/` 디렉토리에 설치하여 프로젝트별 맞춤 설정을 적용합니다.

---

## 파일 구조

```
project/
├── CLAUDE.md           # 프로젝트 지침
├── settings.json       # 프로젝트 Claude Code 설정
├── .mcp.json           # 프로젝트 MCP 서버 설정
├── agents/             # 서브에이전트 정의
│   ├── README.md
│   └── example-agent.md
├── commands/           # 슬래시 명령어 정의
│   ├── README.md
│   ├── example-command.md
│   └── commit-push.md
├── skills/             # 스킬 정의
│   ├── README.md
│   └── example-skill/
│       └── SKILL.md
├── scripts/            # Hook 스크립트
│   ├── session-start-hook.sh
│   └── ntfy-hook.sh
└── README.md
```

---

## 구성 요소별 역할

### CLAUDE.md
- **역할**: 프로젝트 특화 지침
- **내용**: 폴더 구조, 네이밍 컨벤션, 사용 가능한 명령어/에이전트/스킬 목록
- **위치**: `.claude/CLAUDE.md`

### settings.json
- **역할**: 프로젝트별 Claude Code 설정
- **내용**:
  - 권한 설정
  - Hook 설정 (SessionStart, Stop, Notification)
  - MCP 서버 활성화
- **위치**: `.claude/settings.json`

### .mcp.json
- **역할**: 프로젝트에서 사용할 MCP 서버 정의
- **포함 서버**: context7, sequential-thinking, perplexity
- **위치**: `.claude/.mcp.json`

### agents/
- **역할**: 특정 역할에 특화된 서브에이전트 정의
- **사용**: "data-analyst 에이전트로 분석해줘"
- **위치**: `.claude/agents/`

### commands/
- **역할**: 자주 사용하는 작업을 슬래시 명령어로 정의
- **사용**: `/commit-push "메시지"`
- **위치**: `.claude/commands/`

### skills/
- **역할**: 도메인 특화 지식과 표준 절차 패키징
- **사용**: 트리거 키워드로 자동 활성화
- **위치**: `.claude/skills/`

### scripts/
- **역할**: Hook에서 실행되는 자동화 스크립트
- **포함 스크립트**:
  - `session-start-hook.sh`: 세션 시작 시 초기화
  - `ntfy-hook.sh`: 이벤트 발생 시 알림
- **위치**: `.claude/scripts/`

---

## 설치 방법

### 1. 수동 설치

```bash
# 프로젝트 루트로 이동
cd /path/to/your/project

# .claude 디렉토리 생성
mkdir -p .claude/{agents,commands,skills,scripts}

# 파일 복사
cp -r /path/to/template/project/* .claude/

# 스크립트 실행 권한 부여
chmod +x .claude/scripts/*.sh
```

### 2. 설치 스크립트 사용

```bash
# 저장소 루트에서 실행
./scripts/init-project.sh /path/to/your/project
```

---

## 커스터마이징

### 1. CLAUDE.md 수정
- 프로젝트명, 목적, 기술 스택 입력
- 사용할 Slash Commands 목록 업데이트
- 네이밍 컨벤션 정의
- 폴더 구조 설명

### 2. 에이전트 추가
- `agents/` 폴더에 새 `.md` 파일 생성
- 프로젝트 도메인에 맞는 전문가 정의

### 3. 명령어 추가
- `commands/` 폴더에 새 `.md` 파일 생성
- 자주 사용하는 워크플로우 자동화

### 4. 스킬 추가
- `skills/` 폴더에 새 서브폴더 생성
- `SKILL.md` 파일에 도메인 지식 패키징

### 5. ntfy 설정
`scripts/ntfy-hook.sh`에서 토픽 설정:
```bash
NTFY_TOPIC="your_project_topic"
```

또는 환경변수 사용:
```bash
export NTFY_TOPIC="your_project_topic"
```
