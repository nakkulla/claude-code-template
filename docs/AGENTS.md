# Agents (서브에이전트) 가이드

서브에이전트는 특정 역할에 특화된 AI 페르소나입니다.

---

## 서브에이전트란?

서브에이전트는 Claude Code 내에서 특정 도메인이나 작업에 특화된 역할을 수행합니다:

- **전문 지식**: 특정 분야의 깊은 지식 제공
- **일관된 출력**: 표준화된 형식의 결과물
- **자동 활성화**: 트리거 키워드 감지 시 자동 호출

---

## 파일 위치

```
.claude/agents/
├── data-analyst.md
├── figure-creator.md
└── code-reviewer.md
```

---

## 파일 형식

### Frontmatter (YAML)

```yaml
---
name: agent-name
description: 에이전트 설명. 트리거 키워드1, 키워드2 시 활성화
tools: Read, Bash, Write, Glob
model: sonnet
---
```

| 필드 | 필수 | 설명 |
|------|------|------|
| `name` | ✅ | 에이전트 고유 이름 |
| `description` | ✅ | 역할 설명 및 트리거 키워드 |
| `tools` | ❌ | 사용 가능한 도구 목록 |
| `model` | ❌ | 사용할 모델 (sonnet, opus, haiku) |

### 본문 (Markdown)

```markdown
# 에이전트 제목

역할 소개...

## 전문 분야
- 분야 1
- 분야 2

## 표준 절차
1. 단계 1
2. 단계 2

## 출력 형식
- 결과 파일: ...
- 피규어: ...

## 주의사항
- 주의 1
- 주의 2
```

---

## 사용 방법

### 1. 직접 호출

```
"data-analyst 에이전트로 이 데이터를 분석해줘"
"figure-creator 에이전트 사용해서 그래프 만들어줘"
```

### 2. 트리거 키워드

description에 포함된 키워드가 감지되면 자동 활성화:

```yaml
description: 데이터 분석, 통계 분석, 차트 요청 시 활성화
```

→ "데이터 분석해줘" 입력 시 자동 활성화

---

## 예시: 데이터 분석 에이전트

```markdown
---
name: data-analyst
description: 데이터 분석, 통계 분석, 시각화 전문가. 데이터 분석, 통계, 차트 요청 시 활성화
tools: Read, Bash, Write, Glob
model: sonnet
---

# 데이터 분석 전문가

당신은 데이터 분석 전문가입니다.

## 전문 분야

### 1. 데이터 처리
- 데이터 로딩 및 전처리
- 결측값 처리
- 데이터 변환

### 2. 통계 분석
- 기술 통계
- 가설 검정
- 회귀 분석

## 분석 표준

### Python 환경
```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
```

### 출력 형식
- 결과: `results/*.tsv`
- 피규어: `figures/*.png` (300 DPI)

## 작업 절차
1. 데이터 확인
2. 전처리
3. 분석 실행
4. 시각화
5. 문서화
```

---

## 사용 가능한 도구

| 도구 | 설명 |
|------|------|
| `Read` | 파일 읽기 |
| `Write` | 파일 쓰기 |
| `Edit` | 파일 편집 |
| `Bash` | 쉘 명령어 실행 |
| `Glob` | 파일 패턴 검색 |
| `Grep` | 텍스트 검색 |
| `WebFetch` | 웹 페이지 가져오기 |
| `WebSearch` | 웹 검색 |

---

## 모델 선택

| 모델 | 특징 | 권장 용도 |
|------|------|----------|
| `haiku` | 빠름, 저비용 | 간단한 작업, 빠른 응답 |
| `sonnet` | 균형 | 일반적인 분석, 코드 작성 |
| `opus` | 고성능 | 복잡한 추론, 긴 컨텍스트 |

---

## 베스트 프랙티스

### 1. 명확한 역할 정의
```markdown
## 당신은 [역할]입니다.
- 전문 분야 1
- 전문 분야 2
- 전문 분야 3
```

### 2. 표준 절차 제공
```markdown
## 작업 절차
1. 입력 확인
2. 처리/분석
3. 출력 생성
4. 검증
```

### 3. 출력 형식 표준화
```markdown
## 출력 형식
- 결과 파일: `results/task{XX}_{type}.tsv`
- 피규어: `figures/task{XX}_{type}.png`
- 문서: `docs/result-{YYYYMMDD}.md`
```

### 4. 코드 템플릿 제공
```markdown
## Python 환경
```python
import pandas as pd
# 표준 import 목록
```

## 기본 코드 구조
```python
def analyze(data):
    # 분석 로직
    pass
```
```

---

## 트러블슈팅

### 에이전트가 활성화되지 않음
- frontmatter 형식 확인 (YAML)
- `name` 필드 존재 확인
- description에 트리거 키워드 포함 확인

### 도구 사용 불가
- `tools` 필드에 필요한 도구 추가
- 도구 이름 철자 확인

### 모델 관련 오류
- `model` 필드 값 확인 (sonnet/opus/haiku)
