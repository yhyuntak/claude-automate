# Hook 체계 설계

> hooks.json 기반 자동화로 /wrap 수동검증을 보완/대체할 수 있는지 검토

---

## User Story

CA 사용자가 코드 변경 시 자동으로 검증이 실행되어, /wrap 때 한꺼번에 발견하던 문제를 조기에 잡을 수 있다.

## Acceptance Criteria

- [ ] ECC의 Hook 체계 분석 (3가지 타입: command/prompt/agent, 14가지 이벤트)
- [ ] CA에 적용 가능한 Hook 시나리오 도출
- [ ] 결정: 도입 여부 및 범위 (매번/단위완료시/수동)
- [ ] 도입 시 hooks.json 설계안 작성

## Dependencies

- review-insights.md A1, A3 참조

---

**Last Updated**: 2026-02-20
