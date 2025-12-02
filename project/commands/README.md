# Slash Commands

이 폴더는 Claude Code 슬래시 명령어를 정의합니다.

---

## 슬래시 명령어란?

슬래시 명령어는 자주 사용하는 작업을 단축키처럼 실행하는 기능입니다.
- `/명령어` 형식으로 호출
- 인자 전달 가능: `/명령어 인자값`
- 복잡한 워크플로우 자동화

---

## 파일 형식

```markdown
---
description: 명령어 설명
argument-hint: [인자 설명]
allowed-tools: Bash, Read, Glob
---

# 명령어 제목

명령어가 수행할 작업 설명...

## 실행 단계

1. 단계 1
!실행할 명령어

2. 단계 2
...
```

---

## 인자 사용

- `$ARGUMENTS`: 전체 인자 문자열
- `$1`, `$2`: 개별 인자 (공백으로 분리)

예시: `/run-task 5`
- `$ARGUMENTS` = "5"
- `$1` = "5"

---

## 사용 방법

대화에서 슬래시로 시작하는 명령 입력:
```
/run-task 1
/commit-push "기능 추가"
/check-results
```

---

## 포함된 예시

- `example-command.md`: 기본 명령어 템플릿
- `commit-push.md`: Git 커밋/푸시 자동화

---

## 커스터마이징

1. 이 폴더에 새 `.md` 파일 생성
2. 파일명이 명령어 이름이 됨 (`run-task.md` → `/run-task`)
3. frontmatter에 description, argument-hint, allowed-tools 정의
4. 실행할 단계와 명령어 기술
