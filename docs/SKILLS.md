# Skills (스킬) 가이드

스킬은 특정 도메인의 전문 지식과 표준 절차를 패키징한 것입니다.

---

## 스킬이란?

스킬은 Claude Code에 도메인 특화 지식을 주입합니다:

- **코드 템플릿**: 자주 사용하는 코드 패턴
- **표준 절차**: 분석/작업의 단계별 가이드
- **체크리스트**: 품질 보증을 위한 확인 항목
- **자동 활성화**: 트리거 키워드 감지 시 로드

---

## 파일 위치

```
.claude/skills/
├── README.md
└── skill-name/
    └── SKILL.md
```

스킬은 반드시 **폴더** 안에 `SKILL.md` 파일로 정의합니다.

---

## 파일 형식

### Frontmatter (YAML)

```yaml
---
name: skill-name
description: 스킬 설명. 키워드1, 키워드2 시 활성화
allowed-tools: Read, Bash, Write, Glob
---
```

| 필드 | 필수 | 설명 |
|------|------|------|
| `name` | ✅ | 스킬 고유 이름 |
| `description` | ✅ | 역할 설명 및 트리거 키워드 |
| `allowed-tools` | ❌ | 사용 가능한 도구 목록 |

### 본문 (Markdown)

```markdown
# 스킬 제목

## 표준 분석 절차

### 1. 단계 1
```python
# 코드 예시
```

### 2. 단계 2
...

## 출력 형식
- 결과 형식

## 체크리스트
- [ ] 항목 1
- [ ] 항목 2

## 주의사항
- 주의 1
```

---

## 사용 방법

### 자동 활성화

description에 포함된 트리거 키워드가 감지되면 스킬이 자동으로 로드됩니다:

```yaml
description: 생존분석, KM, Cox, 로그랭크 시 활성화
```

→ "생존분석 해줘" 입력 시 스킬 자동 활성화

### 명시적 호출

```
"survival-analysis 스킬 사용해서 분석해줘"
```

---

## 예시: 생존 분석 스킬

```markdown
---
name: survival-analysis
description: 생존분석, KM 곡선, Cox regression, 로그랭크 검정 시 활성화
allowed-tools: Read, Bash, Write, Glob
---

# 생존 분석 스킬

## 표준 분석 절차

### 1. 데이터 준비
```python
import pandas as pd
from lifelines import KaplanMeierFitter, CoxPHFitter

df = pd.read_csv('data.tsv', sep='\t')

# 필수 컬럼: time, event, group
```

### 2. Kaplan-Meier 분석
```python
kmf = KaplanMeierFitter()
kmf.fit(df['time'], df['event'])
kmf.plot_survival_function()
```

### 3. Log-rank 검정
```python
from lifelines.statistics import logrank_test

results = logrank_test(
    group1['time'], group2['time'],
    group1['event'], group2['event']
)
print(f"p-value: {results.p_value:.4f}")
```

### 4. Cox Proportional Hazards
```python
cph = CoxPHFitter()
cph.fit(df, duration_col='time', event_col='event')
cph.print_summary()
```

## 출력 형식

### 결과 테이블
```
variable	hr	ci_lower	ci_upper	pvalue
age	1.023	1.001	1.045	0.039
```

## 체크리스트

- [ ] Proportional hazards 가정 검토
- [ ] 중도절단 비율 보고
- [ ] Median survival 계산
- [ ] 신뢰구간 포함
- [ ] Risk table 포함 (KM 곡선)

## 주의사항

1. Cox 모델의 비례위험 가정 확인
2. 변수당 최소 10개 이벤트 권장
3. 다중 검정 시 보정 고려
```

---

## 스킬 vs 에이전트

| 구분 | 스킬 | 에이전트 |
|------|------|---------|
| 목적 | 도메인 지식 제공 | 역할 수행 |
| 형식 | 코드 템플릿, 절차 | 페르소나, 지침 |
| 활성화 | 키워드 감지 시 로드 | 명시적 호출 또는 자동 |
| 위치 | `skills/폴더/SKILL.md` | `agents/*.md` |

---

## 베스트 프랙티스

### 1. 완전한 코드 예시
```python
# 복사-붙여넣기 가능한 완전한 코드
import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv('data.csv')
# ... 전체 분석 코드
```

### 2. 단계별 구조
```markdown
## 표준 분석 절차

### 1. 데이터 로드
### 2. 전처리
### 3. 분석 실행
### 4. 시각화
### 5. 결과 저장
```

### 3. 실용적인 체크리스트
```markdown
## 체크리스트
- [ ] 데이터 품질 확인
- [ ] 가정 검토
- [ ] 결과 검증
- [ ] 문서화 완료
```

### 4. 출력 형식 표준화
```markdown
## 출력 형식

### TSV 파일
```
column1	column2	column3
value1	value2	value3
```

### 피규어 저장
```python
plt.savefig('figures/result.png', dpi=300)
```
```

---

## 스킬 조합

여러 스킬을 조합하여 복잡한 분석 수행:

```
"survival-analysis 스킬과 forest-plot 스킬을 사용해서
메타분석을 수행해줘"
```

---

## 트러블슈팅

### 스킬이 활성화되지 않음
- 폴더 구조 확인: `skills/skill-name/SKILL.md`
- frontmatter 형식 확인
- description에 트리거 키워드 포함 확인

### 코드 실행 오류
- 코드 블록의 언어 지정 확인 (```python)
- 필요한 패키지 import 확인
- 데이터 경로/형식 확인
