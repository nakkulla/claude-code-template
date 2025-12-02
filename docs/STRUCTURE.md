# Claude Code 설정 구조

Claude Code의 설정 파일 구조와 각 구성 요소의 역할을 설명합니다.

---

## 설정 레벨

Claude Code 설정은 두 가지 레벨로 구분됩니다:

### 1. 글로벌 설정 (`~/.claude/`)
- **적용 범위**: 모든 프로젝트
- **위치**: 사용자 홈 디렉토리의 `.claude/` 폴더
- **용도**: 기본 지침, 공통 Hook, 개인 설정

### 2. 프로젝트 설정 (`프로젝트/.claude/`)
- **적용 범위**: 해당 프로젝트만
- **위치**: 프로젝트 루트의 `.claude/` 폴더
- **용도**: 프로젝트 특화 지침, 에이전트, 명령어, 스킬

---

## 글로벌 설정 구조

```
~/.claude/
├── CLAUDE.md           # 글로벌 지침 (모든 프로젝트에 적용)
├── settings.json       # Claude Code 전역 설정
├── .claude.json        # MCP 서버 정의
├── auto-commit-push.sh # 자동 커밋/푸시 Hook
├── ntfy-hook.sh        # 알림 Hook
└── (자동 생성 폴더들)
    ├── plans/          # 작업 계획 저장
    ├── projects/       # 프로젝트별 캐시
    └── *.log           # 로그 파일
```

### 파일별 역할

| 파일 | 역할 |
|------|------|
| `CLAUDE.md` | 문서화 규칙, 언어 설정, 코드 스타일 등 기본 지침 |
| `settings.json` | 권한, Hook, MCP 서버, 상태바 설정 |
| `.claude.json` | MCP 서버 정의 (context7, perplexity 등) |
| `auto-commit-push.sh` | Stop 이벤트 시 자동 Git 커밋/푸시 |
| `ntfy-hook.sh` | 이벤트 발생 시 ntfy 알림 전송 |

---

## 프로젝트 설정 구조

```
project/.claude/
├── CLAUDE.md           # 프로젝트 지침
├── settings.json       # 프로젝트 설정
├── .mcp.json           # 프로젝트 MCP 서버
├── agents/             # 서브에이전트
│   ├── data-analyst.md
│   └── figure-creator.md
├── commands/           # 슬래시 명령어
│   ├── run-task.md
│   └── commit-push.md
├── skills/             # 스킬
│   └── example-skill/
│       └── SKILL.md
└── scripts/            # Hook 스크립트
    ├── session-start-hook.sh
    └── ntfy-hook.sh
```

### 파일별 역할

| 파일/폴더 | 역할 |
|-----------|------|
| `CLAUDE.md` | 프로젝트 개요, 폴더 구조, 네이밍 컨벤션, 사용 가능한 기능 목록 |
| `settings.json` | 프로젝트별 권한, Hook, MCP 서버 설정 |
| `.mcp.json` | 프로젝트에서 사용할 MCP 서버 정의 |
| `agents/` | 특정 역할에 특화된 서브에이전트 |
| `commands/` | 자주 사용하는 워크플로우 자동화 명령어 |
| `skills/` | 도메인 특화 지식과 코드 템플릿 |
| `scripts/` | Hook에서 실행되는 스크립트 |

---

## 설정 우선순위

프로젝트 설정이 글로벌 설정보다 우선합니다:

1. **프로젝트 `.claude/CLAUDE.md`** (가장 높음)
2. **글로벌 `~/.claude/CLAUDE.md`**
3. **기본 Claude Code 동작** (가장 낮음)

---

## 설정 파일 형식

### JSON 설정 파일
- `settings.json`: Claude Code 동작 설정
- `.mcp.json` / `.claude.json`: MCP 서버 정의

### Markdown 설정 파일
- `CLAUDE.md`: 지침 문서
- `agents/*.md`: 서브에이전트 정의
- `commands/*.md`: 슬래시 명령어 정의
- `skills/*/SKILL.md`: 스킬 정의

### Shell 스크립트
- `*.sh`: Hook에서 실행되는 자동화 스크립트

---

## 설정 적용 흐름

```
사용자가 Claude Code 실행
    │
    ├─→ 글로벌 설정 로드 (~/.claude/)
    │       ├─ CLAUDE.md (기본 지침)
    │       ├─ settings.json (Hook, 권한 등)
    │       └─ .claude.json (MCP 서버)
    │
    └─→ 프로젝트 설정 로드 (.claude/)
            ├─ CLAUDE.md (프로젝트 지침)
            ├─ settings.json (프로젝트 설정)
            ├─ .mcp.json (프로젝트 MCP)
            ├─ agents/ (서브에이전트)
            ├─ commands/ (슬래시 명령어)
            └─ skills/ (스킬)
```

---

## 자동 생성 폴더

Claude Code가 자동으로 생성하는 폴더들 (`.gitignore`에 추가 권장):

```
~/.claude/
├── plans/              # 작업 계획 문서
├── projects/           # 프로젝트별 세션 캐시
├── todos/              # TODO 상태
├── file-history/       # 파일 변경 이력
├── session-env/        # 세션 환경
├── debug/              # 디버그 정보
└── *.log               # 로그 파일
```
