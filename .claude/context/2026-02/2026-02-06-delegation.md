# Session: 2026-02-06 14:00

## Context
Agent delegation 규칙에 절대 원칙(hard rules)을 추가하여 에이전트 위임 시 발생할 수 있는 컨텍스트 오염을 근본적으로 방지하는 작업.

## Work Summary
- 글로벌 에이전트 위임 규칙에 "⛔ 절대 원칙" 섹션 추가
  - 파일 읽기 규칙: 처음 보는 파일은 explore-* 에이전트 필수 사용
  - 파일 쓰기 규칙: 10줄 이상 수정은 writer-* 에이전트 필수 사용
  - 명령 실행 규칙: 빌드/테스트/배포는 Bash 에이전트 필수 사용
- 글로벌 규칙(~/.claude/rules/agent-delegation.md) 동기화
- 프로젝트 규칙(rules/agent-delegation.md) 동기화
- 버전 업데이트: v0.16.0 → v0.17.0

## Problems & Solutions
- 절대 원칙의 명확성: 여러 줄의 개행으로 시각적 강조 추가하여 규칙의 중요도를 명확하게 표현

## Decisions
- "절대 원칙" 섹션을 규칙 문서 상단에 배치: 우선순위를 명확하게 하고 사용자가 먼저 확인하도록 유도
- 예외 상황 대신 "반드시 지켜야 할 원칙" 포지셍: 선택 사항이 아닌 필수 규칙으로 정의

## Incomplete/TODO
- [ ] 다른 규칙 문서(workflow.md, interaction.md)에도 "절대 원칙" 섹션 추가 검토 필요
- [ ] 기존 에이전트 호출 패턴이 절대 원칙을 따르는지 감사 실시

## Next Session Suggestions
- 기존 commands와 agents의 호출 패턴을 검토하여 절대 원칙 준수 여부 확인
- 이번 세션에서 추가한 절대 원칙이 실제 작업 워크플로우에서 제대로 적용되는지 모니터링
- 절대 원칙 위반 케이스 발생 시 자동으로 감지할 수 있는 검증 로직 추가 검토

---

**Last Updated**: 2026-02-06 14:00
