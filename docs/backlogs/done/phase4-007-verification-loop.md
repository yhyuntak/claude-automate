# Verification Loop 확장

> Build→TypeCheck→Lint→Test→Security 순차검증 + 자동재시도 파이프라인 검토

---

## User Story

CA 사용자가 코드 변경 후 자동으로 다단계 검증이 실행되어, 문제 발견과 수정이 빨라진다.

## Acceptance Criteria

- [ ] ECC Verification Loop 분석 (순차 검증 + 최대 3회 자동 재시도)
- [ ] CA /wrap 검증 범위 확장 가능성 검토
- [ ] Hook 기반(매번) vs 커맨드 기반(수동) vs 중간 지점 비교
- [ ] 결정: 도입 여부 및 검증 파이프라인 설계

## Dependencies

- review-insights.md A10 참조
- phase4-005 (hook-system) 결과와 연관

---

**Last Updated**: 2026-02-20
