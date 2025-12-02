# Slash Commands (슬래시 명령어) 가이드

슬래시 명령어는 자주 사용하는 워크플로우를 단축키처럼 실행하는 기능입니다.

---

## 슬래시 명령어란?

슬래시 명령어는 복잡한 작업을 간단한 명령으로 실행합니다:

- **자동화**: 반복 작업 자동 실행
- **표준화**: 일관된 워크플로우 보장
- **인자 지원**: 동적 값 전달 가능

---

## 파일 위치

```
.claude/commands/
├── run-task.md
├── commit-push.md
└── check-results.md
```

**파일명이 명령어 이름이 됩니다**: `commit-push.md` → `/commit-push`

---

## 파일 형식

### Frontmatter (YAML)

```yaml
---
description: 명령어 설명
argument-hint: [인자 설명]
allowed-tools: Bash, Read, Glob
---
```

| 필드 | 필수 | 설명 |
|------|------|------|
| `description` | ✅ | 명령어 기능 설명 |
| `argument-hint` | ❌ | 인자 사용법 힌트 |
| `allowed-tools` | ❌ | 사용 가능한 도구 목록 |

### 본문 (Markdown)

```markdown
# 명령어 제목

명령어 설명...

## 1. 단계 1
!실행할 쉘 명령어

## 2. 단계 2
추가 지시사항...
```

---

## 인자 사용

### 인자 변수

| 변수 | 설명 |
|------|------|
| `$ARGUMENTS` | 전체 인자 문자열 |
| `$1` | 첫 번째 인자 |
| `$2` | 두 번째 인자 |
| `$@` | 모든 인자 (배열) |

### 예시

```
/run-task 5 debug
```
- `$ARGUMENTS` = "5 debug"
- `$1` = "5"
- `$2` = "debug"

---

## 쉘 명령어 실행

본문에서 `!`로 시작하는 줄은 쉘 명령어로 실행됩니다:

```markdown
## 파일 확인
!ls -la scripts/

## Git 상태
!git status --short
```

---

## 예시: Git 커밋/푸시 명령어

```markdown
---
description: 현재 변경사항을 커밋하고 푸시합니다
argument-hint: [커밋 메시지 (선택)]
allowed-tools: Bash, Read
---

# Git 커밋 및 푸시

## 1. 현재 상태 확인
!git status --short

## 2. 변경사항 확인
!git diff --stat

## 3. 커밋 및 푸시

### 커밋 메시지 규칙
- 사용자가 메시지를 제공한 경우: "$ARGUMENTS" 사용
- 메시지가 없는 경우: 변경된 파일 기반으로 자동 생성

### 실행 순서
1. `git add -A`
2. `git commit -m "메시지"`
3. `git push origin HEAD`

## 4. 결과 확인
!git log -1 --oneline
```

---

## 예시: 작업 실행 명령어

```markdown
---
description: 지정된 작업을 실행합니다
argument-hint: [작업 번호]
allowed-tools: Bash, Read, Glob
---

# 작업 $1 실행

## 1. 스크립트 확인
!ls -la scripts/*$1*.py 2>/dev/null

## 2. 실행
!python3 scripts/$1*.py

## 3. 결과 확인
!ls -la results/ | tail -5
!ls -la figures/ | tail -5
```

---

## 사용 방법

### 기본 사용

```
/commit-push
/run-task 1
/check-results
```

### 인자와 함께

```
/commit-push "새 기능 추가"
/run-task 5
```

### 여러 인자

```
/analyze data.csv output
```

---

## 베스트 프랙티스

### 1. 명확한 단계 구분

```markdown
## 1. 사전 확인
## 2. 실행
## 3. 결과 확인
## 4. 요약
```

### 2. 에러 처리

```markdown
## 스크립트 실행
!python3 script.py 2>&1 || echo "실행 실패"
```

### 3. 조건부 실행

```markdown
## 파일 존재 시에만 실행
![ -f data.csv ] && python3 analyze.py
```

### 4. 결과 표시

```markdown
## 생성된 파일 확인
!ls -la results/ 2>/dev/null || echo "결과 없음"
```

---

## 자주 사용하는 명령어 패턴

### 빌드/테스트

```markdown
---
description: 프로젝트 빌드 및 테스트
---

# 빌드 및 테스트

## 1. 빌드
!npm run build

## 2. 테스트
!npm test

## 3. 결과
빌드 및 테스트 결과를 요약해주세요.
```

### 환경 초기화

```markdown
---
description: 프로젝트 환경 초기화
---

# 환경 초기화

## 1. 의존성 설치
!pip install -r requirements.txt

## 2. 디렉토리 생성
!mkdir -p {data,results,figures,docs}

## 3. 확인
!ls -la
```

### 결과 정리

```markdown
---
description: 결과 파일 정리 및 백업
---

# 결과 정리

## 1. 백업
!cp -r results/ results_backup_$(date +%Y%m%d)/

## 2. 정리
!rm -f results/*.tmp

## 3. 확인
!ls -la results/
```

---

## 트러블슈팅

### 명령어가 인식되지 않음
- 파일 위치 확인: `.claude/commands/`
- 파일 확장자 확인: `.md`
- frontmatter 형식 확인

### 인자가 전달되지 않음
- `$ARGUMENTS` 또는 `$1` 사용 확인
- 따옴표 처리 확인

### 쉘 명령어 실행 안됨
- `!` 접두사 확인
- `allowed-tools`에 `Bash` 포함 확인
