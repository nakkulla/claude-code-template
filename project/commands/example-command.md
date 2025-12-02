---
description: 지정된 작업을 실행합니다
argument-hint: [작업 번호 또는 이름]
allowed-tools: Bash, Read, Glob
---

# 작업 실행: $ARGUMENTS

지정된 작업($ARGUMENTS)을 실행합니다.

## 1. 사전 확인

작업 파일 존재 여부 확인:
!ls -la scripts/*$1* 2>/dev/null || echo "해당 작업 파일을 찾을 수 없습니다"

## 2. 데이터 확인

입력 데이터 확인:
!ls -la data/ 2>/dev/null | head -10

## 3. 작업 실행

스크립트 실행:
!python3 scripts/$1*.py 2>&1 || echo "실행 실패"

## 4. 결과 확인

생성된 결과 파일:
!ls -la results/ 2>/dev/null | tail -5
!ls -la figures/ 2>/dev/null | tail -5

## 5. 요약

실행 결과를 요약하고, 오류가 있으면 보고해주세요.
