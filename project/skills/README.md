# Skills (스킬)

이 폴더는 Claude Code 스킬을 정의합니다.

---

## 스킬이란?

스킬은 특정 도메인의 전문 지식과 표준 절차를 패키징한 것입니다.
- 트리거 키워드로 자동 활성화
- 도메인 특화 코드 템플릿 제공
- 체크리스트 및 베스트 프랙티스 포함

---

## 폴더 구조

```
skills/
├── README.md
└── skill-name/
    └── SKILL.md
```

---

## 파일 형식

```markdown
---
name: skill-name
description: 스킬 설명 및 트리거 키워드
allowed-tools: Read, Bash, Write, Glob
---

# 스킬 제목

## 표준 분석 절차

### 1. 단계 1
```python
# 코드 예시
```

### 2. 단계 2
...

## 출력 형식
- 결과 형식 정의

## 체크리스트
- [ ] 항목 1
- [ ] 항목 2
```

---

## 사용 방법

스킬은 트리거 키워드가 감지되면 자동으로 활성화됩니다.

예시: `survival-analysis` 스킬
- "생존분석 해줘" → 스킬 활성화
- "KM 곡선 그려줘" → 스킬 활성화
- "Cox regression 실행" → 스킬 활성화

---

## 포함된 예시

- `example-skill/SKILL.md`: 기본 스킬 템플릿

---

## 커스터마이징

1. 새 폴더 생성 (스킬 이름)
2. 폴더 안에 `SKILL.md` 파일 생성
3. frontmatter에 name, description, allowed-tools 정의
4. 표준 절차, 코드 템플릿, 체크리스트 기술
5. description에 트리거 키워드 포함
