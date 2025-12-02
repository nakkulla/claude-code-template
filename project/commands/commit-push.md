---
description: 현재 변경사항을 커밋하고 푸시합니다. 메시지를 인자로 전달하거나 자동 생성합니다.
argument-hint: [커밋 메시지 (선택)]
allowed-tools: Bash, Read
---

# Git 커밋 및 푸시

현재 변경사항을 확인하고 커밋/푸시합니다.

## 1. 현재 상태 확인

!git status --short

## 2. 변경사항 확인

!git diff --stat

## 3. 커밋 및 푸시

변경사항이 있다면 다음 작업을 수행해주세요:

### 커밋 메시지 규칙
- 사용자가 메시지를 제공한 경우: "$ARGUMENTS" 사용
- 메시지가 없는 경우: 변경된 파일 기반으로 자동 생성
  - 새 파일: "Add: 파일명"
  - 수정: "Update: 파일명"
  - 삭제: "Remove: 파일명"
  - 혼합: "Update: 주요파일 (+N ~N -N files)"

### 커밋 메시지 형식
```
메시지 내용

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 실행 순서
1. `git add -A` - 모든 변경사항 스테이징
2. `git commit -m "메시지"` - 커밋
3. `git push origin 현재브랜치` - 푸시

## 4. 결과 확인

!git log -1 --oneline
!git status

커밋 및 푸시 결과를 알려주세요.
