# Session: 하네스 2.0 스킬 설계 + 구현 (2026-02-23)

## 상태: 자유 대화
## Plan: 없음 (설계 + 구현 세션)
## 다음 행동: /wrap 스킬 설계 + 구현 (마지막 남은 스킬)

## 배경
- 이전 세션(2026-02-22-harness-poc.md)에서 하네스 2.0 통합 설계를 완성
- 이번 세션에서 개별 스킬 설계 논의 + 백로그 등록 + 구현을 진행

## 결정사항

### 전체 하네스 2.0
- 7개 스킬 통합 플로우 확정 → phase4-019 백로그로 등록
- 전체 플로우 아스키아트 확정

### brainstorm 재설계 (phase4-020, 구현 완료)
- Phase 1~4.5 순서 강제 → **자유 대화** (Phase 없음, 에이전틱)
- 도구(Angel/Devil/코드탐색/Ask)를 상황에 맞게 자유롭게 사용
- Angel 호출 기준: 접근법 하나뿐일 때, 대화 맴돌 때
- Devil 호출 기준: 방향 잡혔을 때 구멍 확인, 범위 커질 때
- AskUserQuestion: 무조건 사용, multiSelect: true 기본
- 아이디어 캡처: 대화 중 백로그 등록 가능 (Scope Out → 백로그 후보)
- AC 추출: 정리 요청 시 요구사항 → AC 변환 + 테스트 가능 분류
- refs/ 분리: angel-devil.md, ac-extraction.md, output-format.md

### planning 재설계 (phase4-021, 구현 완료)
- 9 Phase + EnterPlanMode/ExitPlanMode → **자유 대화** (Phase 없음)
- plan 파일 직접 생성: `.claude/plans/{YYYY-MM-DD}-{slug}.md`
- plan status: draft → in_progress → done (abandoned 없음, 삭제)
- plan frontmatter에 test-command 필드 추가 (Stop Hook용)
- Write는 plan 파일만 허용
- refs/ 분리: plan-file.md, devil-usage.md

### start-work 재설계 (phase4-018, 구현 완료)
- Plan 파일 스캔 기능 추가 (날짜+status로 판단)
- 백로그 todo→doing 자동 이동 + README 갱신
- 다음 액션: 4가지 → 2가지 (brainstorm / implement)
- refs/ 분리: context-loading.md, plan-scanning.md, backlog-selection.md

### implement 스킬 (phase4-022, 구현 완료)
- plan대로 묵묵히 실행, 사용자에게 묻지 않음
- 테스트 가능 AC → TDD, 테스트 불가 AC → 일반 구현
- AC 간 의존성은 알아서 판단

### Stop Hook (phase4-023, 구현 완료)
- 임계값: 70% (75→70으로 최종 변경)
- plan in_progress 확인 → test-command 실행 → 실패 시 exit 2
- 컨텍스트 ≥70% → exit 2 → /save-context 실행 지시
- 무한루프 방지: stop_hook_active 플래그

### save-context 스킬 (phase4-024, 구현 완료)
- Claude가 상황 추천 + 사용자 확인 (implement/planning/brainstorm/자유 대화)
- 4가지 케이스별 템플릿 (refs/context-templates.md)
- AC는 plan 파일이 SSOT — 컨텍스트에는 plan 경로만
- 공통 헤더: 상태, plan 경로, 다음 행동 (next_action)
- Angel/Devil 피드백 반영: next_action, rejected_options, 원래 문제, 배경 등 추가

### 스킬 룰 준수
- 모든 스킬에 Progressive Disclosure 적용 (refs/ 분리)
- MUST 키워드 사용
- 검증 루프 내장
- Body 500줄 이내

## TODO
- [ ] /wrap 스킬 설계 + 구현 (마지막 남은 스킬)
- [ ] 백로그 정리: phase4-006, 007, 008 닫기 (통합 설계로 흡수)
- [ ] POC 파일 정리 (session-stop-poc.sh, test-hook 등)
