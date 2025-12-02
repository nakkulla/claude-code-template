# [프로젝트명] Claude Code 지침

이 문서는 Claude Code 실행 시 이 프로젝트에 적용되는 지침을 담고 있습니다.

---

## 프로젝트 개요

- **프로젝트명**: [프로젝트명]
- **목적**: [프로젝트 목적]
- **주요 기술**: [사용 기술/언어]

---

## 1. 문서화 규칙

### 계획과 결과 문서화
- 작업을 계획하게 되면 반드시 문서화하며, 해당 작업 폴더 내부에 `docs` 폴더를 생성
- 문서 이름 형식:
  - 계획: `plan-{YYYYMMDD-HHMM}.md`
  - 결과: `result-{YYYYMMDD-HHMM}.md`

### 피규어 및 시각 자료
- 피규어는 PNG 형식으로 출력
- `results/` 또는 `figures/` 폴더에 저장
- 그래프/표 제목과 설명을 문서에 함께 기재

---

## 2. Slash Commands

| 명령어 | 설명 |
|--------|------|
| `/run-task [N]` | Task N 실행 |
| `/check-results [N]` | Task N 결과 확인 |
| `/commit-push [메시지]` | Git 커밋 및 푸시 |

---

## 3. Subagents (서브에이전트)

| 에이전트 | 용도 |
|----------|------|
| `data-analyst` | 데이터 분석 전문가 |
| `code-reviewer` | 코드 리뷰 전문가 |

사용법: "data-analyst 에이전트로 분석해줘"

---

## 4. Skills (스킬)

| 스킬 | 트리거 키워드 |
|------|--------------|
| `example-skill` | [관련 키워드] |

---

## 5. 네이밍 컨벤션

| 항목 | 형식 | 예시 |
|------|------|------|
| 스크립트 | `{XX}_{name}.py` | `01_preprocessing.py` |
| 결과 파일 | `task{XX}_{type}_{desc}.tsv` | `task01_analysis_result.tsv` |
| 피규어 | `task{XX}_{type}_{desc}.png` | `task01_chart_overview.png` |

---

## 6. 폴더 구조

```
project/
├── scripts/        # 분석/처리 스크립트
├── data/           # 입력 데이터
├── results/        # 결과 파일
├── figures/        # 시각화 결과
├── docs/           # 문서
└── .claude/        # Claude Code 설정
```

---

## 커스터마이징

이 파일을 프로젝트에 맞게 수정하세요:
1. 프로젝트명과 목적 입력
2. 사용하는 Slash Commands 정의
3. 필요한 Subagents 추가
4. 프로젝트 특화 네이밍 컨벤션 정의
5. 폴더 구조 설명 업데이트
