# 연속 루프 아키텍처

> ECC의 "AI가 혼자 오래 돌아도 괜찮게" 모델을 CA에 부분 도입할지 검토

---

## User Story

CA가 필요한 경우 세션 경계를 넘어 연속적으로 작업할 수 있어서, 장기 작업의 효율이 올라간다.

## Acceptance Criteria

- [ ] ECC 연속 루프 6가지 지원 메커니즘 분석 (Strategic Compact, PreCompact Hook, SessionStart Hook, Stop Hook, Verification Loop, Continuous Learning)
- [ ] CA 세션 단위 모델과의 철학적 차이 정리
- [ ] 부분 도입 가능성 검토 (PreCompact 상태 저장, SessionStart 복원 등)
- [ ] 결정: 부분 도입 여부 및 범위

## Dependencies

- review-insights.md A6 참조

---

**Last Updated**: 2026-02-20
