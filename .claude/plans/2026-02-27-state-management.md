---
status: done
created: 2026-02-27
slug: state-management
test-command:
---

# Plan: state-management

## 요구사항

### Context (배경)
- compact 발생 시 "뭘 하고 있었는지" 정보가 유실됨
- plan 파일의 AC 체크박스로 진행 상태는 복구 가능하나, "어떤 스킬 실행 중이었는지"는 알 수 없음
- OMC의 PreCompact hook + state 파일 패턴을 참고하여 상태 관리 시스템 도입

### What (무엇을)
- SessionStart hook: 세션 시작 시 mode를 idle로 초기화
- PreCompact hook: compact 직전 mode 읽고 systemMessage 주입
- 스킬별 mode 업데이트: planning/implement/wrap이 시작 시 mode 기록
- 실험용 스크립트 정리

### Why (왜)
- compact 후에도 Claude가 자연스럽게 이어서 작업 가능
- implement 중 compact → plan 파일 경로 + "미완료 AC부터" 안내
- planning 중 compact → "planning 중이었음" 안내

### Scope
- ✅ In: SessionStart hook, PreCompact hook, mode 파일, 스킬 수정, 실험 스크립트 정리
- ❌ Out: 자유 대화 상태 저장 (compact 요약으로 충분), start-work 수정 (SessionStart가 처리)

## Brain 업데이트

- code-map: hooks/ 폴더에 session-start.sh, pre-compact.sh 추가. .claude/state/ 폴더 신규
- patterns: hook 스크립트 패턴 (stdin JSON 파싱, stdout JSON 출력, mkdir -p, graceful fallback)
- decisions: mode 파일 포맷은 단순 문자열 (idle/planning/implement). plan 경로는 mode에 저장하지 않고 grep으로 탐색

<!--
AC = 작업 항목 (진행 추적, 체크박스 = 상태)
TC = 검증 기준 (TDD 테스트 대상, AC별 하위 항목)
-->

## AC 목록

- [x] AC-1: SessionStart hook 생성
  - TC: 세션 시작 시 .claude/state/mode 파일이 idle로 생성됨
  - TC: .claude/state/ 디렉토리가 없는 상태에서도 정상 동작 (mkdir -p)
  - TC: 두 번 연속 실행해도 idle 유지 (멱등성)
- [x] AC-2: PreCompact hook 생성
  - TC: implement 중 compact 시 systemMessage에 in_progress plan 경로 포함
  - TC: idle 상태에서 compact 시 systemMessage 빈 문자열
  - TC: mode 파일 없을 때 에러 없이 idle 취급
  - TC: implement인데 in_progress plan 없을 때 에러 없이 종료
- [x] AC-3: 스킬에 mode 업데이트 지시 추가
  - TC: planning 시작 시 mode가 planning으로 변경
  - TC: implement 시작 시 mode가 implement으로 변경
  - TC: wrap 시 mode가 idle로 변경
  - TC: planning → implement 전환 시 mode가 올바르게 덮어써짐
- [x] AC-4: .claude/hooks/ 실험 스크립트 정리 (TC 없음)

## 구현 순서

1. Brain 업데이트
2. [병렬] AC-1 → hooks/session-start.sh, hooks/hooks.json / AC-2 → hooks/pre-compact.sh, hooks/hooks.json
3. [순차] AC-3 → skills/planning/SKILL.md, skills/implement/SKILL.md, skills/wrap/SKILL.md (AC-1,2 완료 후)
4. [병렬] AC-4 → .claude/hooks/session-stop.sh, .claude/hooks/session-stop-poc.sh
