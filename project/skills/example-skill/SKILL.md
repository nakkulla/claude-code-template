---
name: example-skill
description: 예시 스킬. "예시", "템플릿", "기본" 키워드 시 활성화
allowed-tools: Read, Bash, Write, Glob
---

# 예시 스킬

이 스킬은 스킬 작성의 기본 템플릿입니다.

---

## 표준 분석 절차

### 1. 데이터 준비
```python
import pandas as pd
import numpy as np

# 데이터 로드
df = pd.read_csv('data.csv')

# 기본 정보 확인
print(df.info())
print(df.describe())
```

### 2. 데이터 탐색
```python
# 결측값 확인
print(df.isnull().sum())

# 데이터 타입 확인
print(df.dtypes)
```

### 3. 분석 수행
```python
# 기본 통계
mean_val = df['column'].mean()
std_val = df['column'].std()

print(f"평균: {mean_val:.3f}")
print(f"표준편차: {std_val:.3f}")
```

### 4. 시각화
```python
import matplotlib.pyplot as plt

fig, ax = plt.subplots(figsize=(8, 6))
df['column'].hist(ax=ax, bins=30)
ax.set_xlabel('Value')
ax.set_ylabel('Frequency')
ax.set_title('Distribution')
plt.savefig('figures/distribution.png', dpi=300, bbox_inches='tight')
```

---

## 출력 형식

### 결과 테이블 (TSV)
```
metric	value
mean	10.5
std	2.3
median	10.2
```

### 피규어 저장
```python
fig.savefig(
    'figures/taskXX_chart_description.png',
    dpi=300,
    bbox_inches='tight'
)
```

---

## 체크리스트

- [ ] 데이터 품질 확인 (결측값, 이상치)
- [ ] 적절한 통계 방법 선택
- [ ] 결과에 신뢰구간 포함
- [ ] 시각화 가독성 확인
- [ ] 결과 해석 문서화

---

## 주의사항

1. **데이터 확인**: 분석 전 항상 데이터 품질 검토
2. **가정 검토**: 통계 방법의 가정 확인
3. **재현성**: 랜덤 시드 설정
4. **문서화**: 분석 과정 및 결과 기록
