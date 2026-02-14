# Changelog

All notable changes to this project will be documented in this file.

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
