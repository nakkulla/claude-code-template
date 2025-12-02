# 프로젝트 설정 가이드

프로젝트 설정은 개별 프로젝트에만 적용되는 Claude Code 설정입니다.

---

## 설정 위치

프로젝트 설정은 프로젝트 루트의 `.claude/` 디렉토리에 저장됩니다.

```
project/.claude/
├── CLAUDE.md           # 프로젝트 지침
├── settings.json       # 프로젝트 설정
├── .mcp.json           # 프로젝트 MCP 서버
├── agents/             # 서브에이전트
├── commands/           # 슬래시 명령어
├── skills/             # 스킬
└── scripts/            # Hook 스크립트
```

---

## CLAUDE.md

프로젝트 특화 지침을 정의합니다.

### 포함 내용
- 프로젝트 개요 (목적, 기술 스택)
- 폴더 구조 설명
- 네이밍 컨벤션
- 사용 가능한 기능 목록 (Commands, Agents, Skills)

### 예시

```markdown
# [프로젝트명] Claude Code 지침

## 프로젝트 개요
- **목적**: 데이터 분석 프로젝트
- **기술**: Python, pandas, matplotlib

## 폴더 구조
```
project/
├── scripts/    # 분석 스크립트
├── data/       # 입력 데이터
├── results/    # 결과 파일
└── figures/    # 시각화
```

## 네이밍 컨벤션
- 스크립트: `{XX}_{name}.py`
- 결과: `task{XX}_{type}.tsv`
- 피규어: `task{XX}_{type}.png`

## Slash Commands
- `/run-task [N]`: 작업 실행
- `/commit-push`: Git 커밋/푸시
```

---

## settings.json

프로젝트별 Claude Code 설정입니다.

### 주요 차이점 (글로벌 vs 프로젝트)

| 항목 | 글로벌 | 프로젝트 |
|------|--------|---------|
| Hook 경로 | `~/.claude/` | `$CLAUDE_PROJECT_DIR/.claude/` |
| 범위 | 모든 프로젝트 | 해당 프로젝트만 |
| 우선순위 | 낮음 | 높음 |

### 예시

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/scripts/init.sh",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

**주의**: 프로젝트 스크립트 경로는 `$CLAUDE_PROJECT_DIR` 변수를 사용합니다.

---

## .mcp.json

프로젝트에서 사용할 MCP 서버를 정의합니다.

글로벌 설정과 동일한 형식이지만, 프로젝트 특화 서버를 추가할 수 있습니다.

```json
{
  "$schema": "https://modelcontextprotocol.io/schemas/mcp.json",
  "mcpServers": {
    "context7": { ... },
    "project-specific-server": { ... }
  }
}
```

---

## agents/ (서브에이전트)

프로젝트 특화 역할의 AI 페르소나를 정의합니다.

```
agents/
├── data-analyst.md     # 데이터 분석 전문가
└── figure-creator.md   # 피규어 생성 전문가
```

자세한 내용은 [AGENTS.md](AGENTS.md) 참조.

---

## commands/ (슬래시 명령어)

자주 사용하는 워크플로우를 명령어로 정의합니다.

```
commands/
├── run-task.md         # 작업 실행
├── commit-push.md      # Git 커밋/푸시
└── check-results.md    # 결과 확인
```

자세한 내용은 [COMMANDS.md](COMMANDS.md) 참조.

---

## skills/ (스킬)

도메인 특화 지식과 코드 템플릿을 패키징합니다.

```
skills/
└── example-skill/
    └── SKILL.md
```

자세한 내용은 [SKILLS.md](SKILLS.md) 참조.

---

## scripts/ (Hook 스크립트)

프로젝트 레벨 Hook 스크립트입니다.

```
scripts/
├── session-start-hook.sh  # 세션 시작 시 초기화
└── ntfy-hook.sh           # 알림 전송
```

자세한 내용은 [HOOKS.md](HOOKS.md) 참조.

---

## 설치 방법

### 1. 수동 설치

```bash
# 프로젝트 루트로 이동
cd /path/to/project

# .claude 디렉토리 생성
mkdir -p .claude/{agents,commands,skills,scripts}

# 템플릿 복사
cp -r /path/to/template/project/* .claude/

# 스크립트 실행 권한
chmod +x .claude/scripts/*.sh
```

### 2. 초기화 스크립트

```bash
./scripts/init-project.sh /path/to/project
```

---

## 커스터마이징 체크리스트

### 1. CLAUDE.md
- [ ] 프로젝트명 입력
- [ ] 목적 및 기술 스택 정의
- [ ] 폴더 구조 설명
- [ ] 네이밍 컨벤션 정의
- [ ] 사용 가능한 Commands/Agents/Skills 목록

### 2. Agents
- [ ] 프로젝트에 필요한 역할 정의
- [ ] 전문 분야 및 절차 기술
- [ ] 출력 형식 표준화

### 3. Commands
- [ ] 자주 사용하는 워크플로우 식별
- [ ] 명령어로 자동화
- [ ] 인자 지원 추가

### 4. Skills
- [ ] 도메인 특화 지식 패키징
- [ ] 코드 템플릿 작성
- [ ] 체크리스트 추가

### 5. Hooks
- [ ] 세션 초기화 작업 정의
- [ ] 알림 설정 (ntfy 토픽)

---

## Git 설정

### .gitignore 권장 항목

```gitignore
# Claude Code 자동 생성 파일
.claude/claude_setting/
.claude/session-env/
.claude/debug/
.claude/*.log

# 개인 설정 (선택)
.claude/settings.local.json
```

### 버전 관리 포함 권장

```
.claude/CLAUDE.md          # 프로젝트 지침
.claude/settings.json      # 공유 설정
.claude/.mcp.json          # MCP 서버 (키 제외)
.claude/agents/            # 에이전트 정의
.claude/commands/          # 명령어 정의
.claude/skills/            # 스킬 정의
.claude/scripts/           # Hook 스크립트
```

---

## 글로벌 vs 프로젝트 설정

| 항목 | 글로벌에 적합 | 프로젝트에 적합 |
|------|--------------|----------------|
| 언어 설정 | ✅ | |
| 문서화 규칙 | ✅ | ✅ (프로젝트 특화) |
| 자동 커밋 Hook | ✅ | |
| ntfy 알림 | ✅ | ✅ (프로젝트별 토픽) |
| MCP 서버 (공통) | ✅ | |
| MCP 서버 (특화) | | ✅ |
| 에이전트 | | ✅ |
| 명령어 | | ✅ |
| 스킬 | | ✅ |
