# Claude Code 설정 템플릿

Claude Code의 설정(Hooks, Agents, Skills, Commands, MCP 등)을 재사용 가능한 템플릿으로 제공합니다.

---

## 개요

이 저장소는 Claude Code를 효과적으로 사용하기 위한 설정 템플릿을 제공합니다:

- **글로벌 설정**: 모든 프로젝트에 적용되는 사용자 레벨 설정
- **프로젝트 설정**: 개별 프로젝트에 적용되는 프로젝트 레벨 설정
- **상세 가이드**: 각 구성 요소에 대한 설명 문서

---

## 빠른 시작

### 1. 글로벌 설정 설치

```bash
# 저장소 클론
git clone https://github.com/YOUR_USERNAME/claude-code-template.git
cd claude-code-template

# 설치 스크립트 실행
./scripts/install.sh
```

### 2. 프로젝트 설정 초기화

```bash
# 새 프로젝트에 설정 적용
./scripts/init-project.sh /path/to/your/project
```

---

## 저장소 구조

```
claude-code-template/
├── README.md                    # 이 문서
├── docs/                        # 상세 가이드
│   ├── STRUCTURE.md            # 전체 구조 설명
│   ├── GLOBAL_SETTINGS.md      # 글로벌 설정 가이드
│   ├── PROJECT_SETTINGS.md     # 프로젝트 설정 가이드
│   ├── HOOKS.md                # Hooks 가이드
│   ├── AGENTS.md               # Agents 가이드
│   ├── SKILLS.md               # Skills 가이드
│   ├── COMMANDS.md             # Commands 가이드
│   └── MCP_SERVERS.md          # MCP 서버 가이드
├── global/                      # 글로벌 설정 템플릿
│   ├── CLAUDE.md
│   ├── settings.json
│   ├── .claude.json
│   └── scripts/
├── project/                     # 프로젝트 설정 템플릿
│   ├── CLAUDE.md
│   ├── settings.json
│   ├── .mcp.json
│   ├── agents/
│   ├── commands/
│   ├── skills/
│   └── scripts/
└── scripts/                     # 설치 스크립트
    ├── install.sh
    └── init-project.sh
```

---

## 주요 기능

### Hooks (훅)
Claude Code 이벤트에 자동으로 실행되는 스크립트:
- **SessionStart**: 세션 시작 시 초기화
- **Stop**: 작업 완료 시 자동 커밋, 알림
- **Notification**: 사용자 입력 대기 시 알림

### Agents (서브에이전트)
특정 역할에 특화된 AI 페르소나:
- 데이터 분석 전문가
- 피규어 생성 전문가
- 코드 리뷰 전문가

### Skills (스킬)
도메인 특화 지식과 표준 절차:
- 코드 템플릿 제공
- 체크리스트 및 베스트 프랙티스
- 트리거 키워드로 자동 활성화

### Commands (슬래시 명령어)
자주 사용하는 작업을 단축키로 실행:
- `/commit-push`: Git 커밋 및 푸시
- `/run-task`: 작업 실행
- `/check-results`: 결과 확인

### MCP 서버
Model Context Protocol 서버 연동:
- **context7**: 라이브러리 문서 검색
- **sequential-thinking**: 순차적 사고 지원
- **perplexity**: 웹 검색

---

## 설정 커스터마이징

### ntfy 알림 설정

[ntfy](https://ntfy.sh)를 통해 모바일 알림을 받을 수 있습니다:

```bash
# 환경변수로 설정
export NTFY_TOPIC="your_topic_name"

# 또는 스크립트 직접 수정
# global/scripts/ntfy-hook.sh
# project/scripts/ntfy-hook.sh
```

### MCP 서버 API 키

```bash
# Perplexity API 키
export PERPLEXITY_API_KEY="your_api_key"

# GitHub 토큰
export GITHUB_TOKEN="ghp_your_token"
```

---

## 문서

자세한 사용법은 [docs/](docs/) 폴더를 참조하세요:

- [전체 구조](docs/STRUCTURE.md)
- [글로벌 설정](docs/GLOBAL_SETTINGS.md)
- [프로젝트 설정](docs/PROJECT_SETTINGS.md)
- [Hooks](docs/HOOKS.md)
- [Agents](docs/AGENTS.md)
- [Skills](docs/SKILLS.md)
- [Commands](docs/COMMANDS.md)
- [MCP 서버](docs/MCP_SERVERS.md)

---

## 라이선스

MIT License
