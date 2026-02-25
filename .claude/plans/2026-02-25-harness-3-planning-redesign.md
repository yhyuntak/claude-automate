---
status: in_progress
created: 2026-02-25
slug: harness-3-planning-redesign
test-command: null
---

# Plan: Harness 2.1 — /planning 재설계 + 이름 원복 + Brain 활성화

## 요구사항

### Context (배경)
- 현재 하네스(muse/oracle/smith)가 "자유롭게" 지시로 인해 제대로 동작하지 않음
- omc 분석 결과, 구체적 스텝이 있어야 Claude가 지시를 따름
- muse(brainstorm)는 일반 대화로 대체 가능, 별도 스킬 불필요
- brain 시스템이 형식만 있고 실질적으로 활용되지 않음

### What (무엇을)
- muse 삭제, oracle→planning/smith→implement 이름 원복
- /planning을 9-step 구체적 스킬로 재설계
- brain 구조 활성화 (code-map, decisions, patterns)
- plan 파일 포맷에 Brain 업데이트 섹션 추가

### Why (왜)
- "자유롭게" → "구체적 스텝"으로 전환하여 하네스가 실제로 동작하게
- brain을 planning 루프에 녹여 세션마다 프로젝트 지식이 성장하게

### Scope
- ✅ In: planning 스킬 재설계, 이름 원복, brain 구조, plan 포맷, cross-reference
- ❌ Out: implement 재설계 (TDD loop), start-work 변경, PreCompact hook, save-context 제거

### Constraints
- planning은 plan 파일만 Write/Edit (다른 파일 수정 금지)
- brain 업데이트는 implement에서 실행 (planning은 plan에 기록만)
- brain이 없는 프로젝트에서도 정상 동작해야 함

## Brain 업데이트
- brain.md 인덱스에 code-map, decisions 링크 추가
- .claude/brain/code-map.md 빈 템플릿 생성
- .claude/brain/decisions.md 빈 템플릿 생성
- (implement 시 제일 먼저 실행)

## AC 목록

- [x] AC-1: skills/muse/ 폴더 및 commands/muse.md 삭제 (✅ 테스트 가능)
- [x] AC-2: skills/oracle/ → skills/planning/ 이름 변경 + 내부 참조 수정 (✅ 테스트 가능)
- [x] AC-3: skills/smith/ → skills/implement/ 이름 변경 + 내부 참조 수정 (✅ 테스트 가능)
- [x] AC-4: /planning SKILL.md 9-step 재설계 (✅ 테스트 가능)
  - Step 1: 모드 자동 감지 (Direct/Interview/대화 히스토리)
  - Step 2: Interview (모호할 때만, 질문 하나씩, explore 먼저)
  - Step 3: Brain 읽기 (없으면 스킵)
  - Step 4: 코드베이스 탐색 (explore 에이전트)
  - Step 5: AC 초안 추출 (대화 기반 + explore 기반)
  - Step 6: Angel 확장 ("이런 케이스도?")
  - Step 7: Devil 검증 ("이건 모호함, 이건 테스트 불가")
  - Step 8: 사용자 확인 (AskUserQuestion으로 AC 목록 제시)
  - Step 9: plan 파일 생성 (사용자 확인 후 Write)
- [x] AC-5: plan 파일 포맷에 "Brain 업데이트" 섹션 추가 (refs/plan-file.md 수정) (✅ 테스트 가능)
- [x] AC-6: brain 구조 정리 — code-map.md, decisions.md 생성 + brain.md 인덱스 업데이트 (✅ 테스트 가능)
- [x] AC-7: cross-reference 전체 업데이트 — 15개 파일에서 muse/oracle/smith → planning/implement 변경 (✅ 테스트 가능)
- [x] AC-8: 버전업 (0.27.0) + CHANGELOG + 커밋 (✅ 테스트 가능)

## 구현 순서

1. **AC-6**: brain 구조 정리 (의존성 없음, 먼저)
2. **AC-1**: muse 삭제
3. **AC-2 + AC-3**: oracle→planning, smith→implement 이름 원복 (동시)
4. **AC-5**: plan 파일 포맷 수정 (refs/plan-file.md)
5. **AC-4**: /planning SKILL.md 재설계 (핵심, 가장 큰 작업)
6. **AC-7**: cross-reference 전체 업데이트
7. **AC-8**: 버전업 + 커밋

## 테스트 계획

- AC-1: `ls skills/muse/` 실패 + `ls commands/muse.md` 실패 확인
- AC-2: `ls skills/planning/SKILL.md` 존재 + 내부에 "oracle" 문자열 없음
- AC-3: `ls skills/implement/SKILL.md` 존재 + 내부에 "smith" 문자열 없음
- AC-4: skills/planning/SKILL.md에 9개 Step이 모두 존재하는지 확인
- AC-5: skills/planning/refs/plan-file.md에 "Brain 업데이트" 섹션 존재
- AC-6: .claude/brain/code-map.md + decisions.md 존재 + brain.md에 링크
- AC-7: 프로젝트 전체에서 "/muse", "/oracle", "/smith" grep 결과 0건 (CHANGELOG 제외)
- AC-8: plugin.json + marketplace.json 버전 0.27.0 확인
