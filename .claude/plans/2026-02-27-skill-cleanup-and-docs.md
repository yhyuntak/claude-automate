---
status: done
created: 2026-02-27
slug: skill-cleanup-and-docs
test-command:
---

# Plan: skill-cleanup-and-docs

## 요구사항

### Context (배경)
- 백로그 phase2-001-skill-cleanup-and-docs.md의 Part 2/3/4에 해당
- Part 1(save-context, start-work 스킬 삭제)은 이미 완료됨
- wrap 스킬이 현재 컨텍스트 저장을 담당하나, PreCompact hook이 이를 대체함
- docs/ 폴더에 인덱스가 없어 문서 관리/싱크 체크가 어려움
- 문서 CRUD를 도와주는 스킬이 없음

### What (무엇을)
- docs/ 인덱스 포맷 정의 + claude-automate 프로젝트에 적용
- docs 스킬 신규 생성 (docs/ CRUD + 인덱스 관리)
- wrap 스킬 재설계 (컨텍스트 저장 제거 + doc 싱크 체크 추가 + 진행 안내)

### Why (왜)
- wrap에서 문서 싱크 체크가 가능해짐 (git diff → 인덱스 비교)
- 문서 작성 시 위치 추천 + 자동 인덱스 등록으로 일관성 유지
- 불필요한 컨텍스트 저장 제거 (PreCompact hook이 대체)
- 진행 안내 규칙으로 사용자가 현재 상태를 항상 파악 가능

### Scope
- ✅ In: 인덱스 포맷, docs 스킬, wrap 재설계, 진행 안내 규칙
- ❌ Out: doc-sync-checker 에이전트 수정 (기존 그대로 사용), save-context/start-work 삭제 (이미 완료)

## Brain 업데이트

- code-map: skills/docs/ 폴더 신규 추가, skills/wrap/ 구조 변경 (refs/completion-context.md 삭제), docs/README.md 인덱스 추가
- decisions: discovery-based 인덱스 (고정 카테고리 없이 실제 파일만 나열), docs 스킬 Direct/Interview 모드 (planning 패턴 차용)

<!--
AC = 작업 항목 (진행 추적, 체크박스 = 상태)
TC = 검증 기준 (TDD 테스트 대상, AC별 하위 항목)
-->

## AC 목록

- [x] AC-1: docs/ 인덱스 포맷 정의 + 적용 (TC 없음)
  - docs/README.md에 discovery-based 인덱스 테이블 생성
  - 현재 docs/ 하위 md 파일들 + 하위 폴더 README.md 포함
  - 포맷: | 경로 | 설명 | 최종 수정 | 테이블
  - 인덱스 자체(docs/README.md)는 테이블에 포함하지 않음
- [x] AC-2: docs 스킬 생성 (TC 없음)
  - skills/docs/SKILL.md 생성
  - Direct/Interview 모드 분기 (인자/프롬프트 있으면 Direct, 없으면 Interview)
  - CRUD 4가지: 생성, 수정, 삭제, 인덱스 재생성
  - 위치 추천: explore로 docs/ 구조 파악 → AskUserQuestion으로 추천
  - 인덱스 재생성 시 doc-sync-checker로 현재 상태 확인
  - 모든 파일 수정은 writer에 위임
  - 진행 안내 규칙: 각 Step 진입 시 "[N/M] 단계명" 형태로 브리핑
  - 검증 체크리스트 포함
- [x] AC-3: wrap 스킬 재설계 (TC 없음)
  - wrap SKILL.md 재작성
  - 컨텍스트 저장 Step 제거 + refs/completion-context.md 삭제
  - doc-sync-checker 호출 Step 추가 (git diff → 인덱스 비교 → 결과 반환)
  - 싱크 문제 시 AskUserQuestion → writer로 인덱스 업데이트, 없으면 스킵
  - doc-sync-checker 실패 시 경고만 하고 커밋 진행 (실패 내성)
  - 4단계 구조: plan 확인 → 백로그 정리 → doc 싱크 체크 → 커밋
  - 진행 안내 규칙: "[N/4] 단계명" 형태
  - doing/ 에 여러 개 있을 수 있으므로 관련 doing 체크부터

## 구현 순서

1. Brain 업데이트
2. [순차] AC-1 → docs/README.md (인덱스가 AC-2, AC-3의 기반)
3. [순차] AC-2 → skills/docs/SKILL.md (docs 스킬이 wrap의 doc 싱크 기준)
4. [순차] AC-3 → skills/wrap/SKILL.md, skills/wrap/refs/completion-context.md 삭제
