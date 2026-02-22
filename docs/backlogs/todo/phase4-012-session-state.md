# Session-Scoped State

> 같은 파일+규칙 조합 세션 내 1회만 경고하여 중복 경고 방지

---

## User Story

CA 검증 에이전트가 같은 파일의 같은 이슈를 세션 내에서 반복 보고하지 않아, 경고 피로가 줄어든다.

## Acceptance Criteria

- [ ] ECC Session-Scoped State 방식 분석 (JSON 파일, 키: 파일경로-규칙이름)
- [ ] CA에서 반복 경고가 발생하는 실제 사례 확인
- [ ] 결정: 도입 여부 및 구현 방식 (구현 간단, 효과 큼이라는 평가 검증)

## Dependencies

- review-insights.md A18 참조

---

**Last Updated**: 2026-02-20
