# Changelog

All notable changes to this project will be documented in this file.

## [0.25.2] - 2026-02-24

### Improved
- brainstorm → planning 전환 시 MUST: AskUserQuestion 확인 강제
- planning → implement 전환 시 MUST: AskUserQuestion 확인 강제

## [0.25.1] - 2026-02-24

### Improved
- start-work: 중단된 세션 감지 → "이어가기" 옵션 우선 제시
  - 컨텍스트 파일 헤더 파싱 (상태, Plan, 다음 행동)
  - "다음 행동" 존재 시 중단된 세션으로 판단, 이어가기 라우팅
- implement: 완료 후 /wrap 유도 AskUserQuestion 추가
  - 모든 AC 완료 시 plan status → done + 다음 행동 안내

## [0.25.0] - 2026-02-23

### Changed
- Angel/Devil을 개발 특화 → 범용 사고 도구로 전환
  - Devil: 비판적 사고 도구 (어떤 아이디어/계획/결정이든 검증)
  - Angel: 확장적 사고 도구 (어떤 주제든 새로운 관점 탐색)
  - 개발은 적용 사례 중 하나로 유지, 비개발 예시 추가
  - 질문 옵션/출력 형식/호출 기준 범용화

## [0.24.1] - 2026-02-23

### Fixed
- Stop Hook BSD sed 호환성 수정 (macOS에서 에러 발생 문제)
- Stop Hook `test-command: null` 처리 추가
- Stop Hook을 플러그인 hooks 시스템으로 이관 (프로젝트 레벨 → 플러그인 배포)
- hooks/session-stop.sh를 Harness 2.0 버전으로 교체

## [0.24.0] - 2026-02-23

### Changed
- Harness 2.0: 7개 스킬 기반 통합 워크플로우 재설계
  - start-work, brainstorm, planning, implement, save-context, wrap 스킬 재설계
  - Stop Hook 추가 (컨텍스트 70% 도달 시 자동 트리거)
- Commands → Skills 전환 (wrap, start-work 등)
- Plan 파일 시스템 도입 (.claude/plans/)
- 종료 컨텍스트 템플릿 분리 (wrap vs save-context)

### Added
- skills/wrap/ — 태스크 완료 시 상태 정리 + 커밋
- skills/implement/ — plan 기반 AC별 구현 실행기
- skills/save-context/ — 세션 중단 시 컨텍스트 저장
- phase4-025 백로그: 패턴 체크 타이밍 재설계
- phase4-026 백로그: 문서 싱크 체크 타이밍 재설계

### Removed
- commands/wrap.md (V3) — skills/wrap/SKILL.md로 대체
- /wrap에서 패턴 체크 / 문서 싱크 분리 (별도 백로그로 이동)

## [0.23.1] - 2026-02-14

### Fixed
- /verify-web-ui 커맨드가 스킬을 거치지 않고 직접 orchestrator 에이전트 호출하도록 수정

## [0.23.0] - 2026-02-14

### Changed
- verify-web-ui 오케스트레이터를 별도 에이전트로 분리하여 MCP 물리적 차단
- SKILL.md를 즉시 위임 구조로 단순화
- mcp-test 임시 에이전트 삭제

## [0.22.0] - 2026-02-14

### Changed
- Planning: EnterPlanMode을 스킬 시작 시 즉시 호출하도록 순서 변경
- Verify-web-ui: 브라우저 직접 조작 금지 절대 규칙 + 2단계 위임 지시 강화

## [0.21.0] - 2026-02-09

### Added
- /wrap에 백로그 cleanup (doing → done) 기능 추가
- PARA concept extraction rule 추가

## [0.20.0] - 2026-02-08

### Added
- verify-web-ui 시스템 플러그인 추가

## [0.19.4] - 2026-02-06

### Fixed
- Commands에서 skill path 참조 제거

## [0.19.3] - 2026-02-06

### Changed
- Skill-trigger commands 단순화

## [0.19.2] - 2026-02-06

### Fixed
- Commands에서 anchor 참조 모두 제거

## [0.19.1] - 2026-02-06

### Fixed
- install-rule 스킬의 force overwrite 기능 추가

## [0.19.0] - 2026-02-06

### Changed
- Anchor 시스템 제거 및 archived backlogs 추가

## [0.18.0] - 2026-02-06

### Changed
- Brainstorm/planning 책임 분리 및 devil validation 리팩토링

## [0.17.0] - 2026-02-06

### Added
- Agent-delegation rules에 절대 원칙 추가

## [0.16.0] - 2026-02-06

### Changed
- Planning 스킬에 phase ordering 및 type classification 개선

## [0.15.0] - 2026-02-05

### Added
- Planning workflow를 위한 devil/angel agents 추가

## [0.14.0] - 2026-02-04

### Added
- Agent-delegation에 병렬 실행 규칙 추가

## [0.13.1] - 2026-02-03

### Added
- install-rule 및 create command에 agent-delegation rule 추가

## [0.13.0] - 2026-02-03

### Added
- 복잡한 코드 작성을 위한 writer-high agent 추가

## [0.12.2] - 2026-02-03

### Fixed
- 백로그가 없을 때 task selection 스킵

## [0.12.1] - 2026-02-03

### Added
- /start-work next action에 brainstorm 옵션 추가

## [0.12.0] - 2026-02-03

### Added
- Brain 시스템 및 brainstorm/planning skills 추가

## [0.11.0] - 2026-02-03

### Added
- /start-work 완료 시 AskUserQuestion 강제 적용

## [0.10.0] - 2026-02-02

### Added
- Writer agent 및 agent delegation rules 추가

## [0.9.1] - 2026-02-02

### Changed
- save-para에 Progressive Disclosure 적용

## [0.9.0] - 2026-02-02

### Added
- Tmux status bar integration으로 anchor 표시 기능

## [0.8.0] - 2026-02-02

### Added
- 프로젝트 brain 시스템을 위한 brain.md 템플릿

## [0.7.0] - 2026-02-01

### Added
- Plan 스킬 호출을 위한 /plan command

## [0.6.0] - 2026-02-01

### Added
- save-para 스킬 및 backlogs 재구성

## [0.5.7] - 2026-02-01

### Removed
- anchor-update.sh (Stop hook 제거)

## [0.5.6] - 2026-02-01

### Fixed
- Stop hook hookSpecificOutput 수정

## [0.5.5] - 2026-02-01

### Fixed
- Anchor 업데이트 경로 수정

## [0.5.4] - 2026-02-01

### Fixed
- install-rule command에 anchor 추가

## [0.5.3] - 2026-02-01

### Added
- 세션 컨텍스트를 위한 anchor 시스템

## [0.5.2] - 2026-01-31

### Added
- explain-plugins 스킬 추가

## [0.5.1] - 2026-01-29

### Fixed
- start-work 컨텍스트 로딩 수정

## [0.5.0] - 2026-01-26

### Changed
- Command stubs 제거, 스킬만 사용하도록 변경

## [0.4.8] - 2026-01-26

### Fixed
- Autocomplete를 위한 command stubs 복원

## [0.4.7] - 2026-01-26

### Changed
- Skills-only 테스트를 위해 command stubs 제거 시도

## [0.4.6] - 2026-01-26

### Added
- 모든 스킬에 command stubs 추가

## [0.4.5] - 2026-01-26

### Added
- install-rule 스킬을 위한 command stub 테스트

## [0.4.4] - 2026-01-25

### Fixed
- plugin.json에 skills 필드 추가

## [0.4.3] - 2026-01-25

### Fixed
- install-rule을 bash 코드 대신 instructions로 재작성

## [0.4.2] - 2026-01-25

### Fixed
- install-rule에서 Write tool로 규칙 설치하도록 수정

## [0.4.1] - 2026-01-25

### Fixed
- install-rule 스킬에 user-invocable flag 추가

## [0.4.0] - 2026-01-25

### Changed
- install-rule을 embedded rules와 함께 스킬로 변환

## [0.3.0] - 2026-01-24

### Added
- project-init 스킬 및 global rules 시스템
- 한국어 키워드 지원
- /install-rule command

## [0.2.0] - 2026-01-23

### Added
- interaction-rules 스킬
- 모든 문서를 영어로 번역

## [0.1.9] - 2026-01-23

### Added
- explain-skills에 agentskills 스펙 참조 문서 추가

## [0.1.8] - 2026-01-23

### Added
- /start-work 통합 워크플로우 커맨드

## [0.1.7] - 2026-01-22

### Added
- backlog 스킬

## [0.1.6] - 2026-01-22

### Added
- Skills 시스템 도입
- 피드백 기능 개선

## [0.1.4] - 2026-01-22

### Changed
- 피드백 시스템 및 코드 품질 개선

## [0.1.3] - 2026-01-20

### Changed
- /wrap-v2 - 간소화된 3-에이전트 구조

## [0.1.1] - 2026-01-20

### Fixed
- wrap.md에 에이전트 위임 강제 지시 추가

## [0.1.0] - 2026-01-20

### Added
- 세션 컨텍스트 시스템
