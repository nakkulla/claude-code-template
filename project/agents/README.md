# Agents (서브에이전트)

이 폴더는 Claude Code 서브에이전트를 정의합니다.

---

## 서브에이전트란?

서브에이전트는 특정 역할에 특화된 AI 페르소나입니다.
- 특정 도메인 전문 지식 제공
- 일관된 출력 형식 보장
- 복잡한 작업의 표준화

---

## 파일 형식

```markdown
---
name: agent-name
description: 에이전트 설명 (트리거 키워드 포함)
tools: Read, Bash, Write, Glob
model: sonnet
---

# 에이전트 제목

에이전트 역할과 전문 분야 설명...

## 전문 분야
- 분야 1
- 분야 2

## 작업 절차
1. 단계 1
2. 단계 2

## 출력 형식
- 결과 파일 형식
- 피규어 형식
```

---

## 사용 방법

대화에서 에이전트를 호출하려면:
- "data-analyst 에이전트로 분석해줘"
- "figure-creator 에이전트 사용해서 그래프 만들어줘"

또는 description의 트리거 키워드 사용:
- "데이터 분석 해줘" → data-analyst 자동 활성화
- "피규어 생성해줘" → figure-creator 자동 활성화

---

## 포함된 예시

- `example-agent.md`: 범용 데이터 분석 에이전트 템플릿

---

## 커스터마이징

1. 이 폴더에 새 `.md` 파일 생성
2. frontmatter에 name, description, tools, model 정의
3. 에이전트의 역할, 전문 분야, 작업 절차 기술
4. 프로젝트 특화 내용 추가
