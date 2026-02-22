# 패턴 체크 타이밍 재설계

> 프로젝트 규칙 준수 검증을 적절한 시점에 실행하도록 재설계

---

## User Story

개발자가 코드를 작성할 때, 프로젝트 규칙(rules/*.md) 위반을 적절한 시점에 감지하여 수정 비용을 최소화한다.

## Acceptance Criteria

- [ ] 패턴 체크가 실행될 최적 시점 결정 (implement 중 / 커밋 전 hook / 별도 명령)
- [ ] 기존 pattern-checker 에이전트 재활용 또는 재설계 결정
- [ ] 선택된 방식으로 패턴 체크 통합

## 비기능 요구사항

- 메인 컨텍스트 오염 최소화
- false positive 최소화

## Dependencies

- /wrap 스킬 재설계 완료 (wrap에서 분리된 기능)

---

**Last Updated**: 2026-02-23
