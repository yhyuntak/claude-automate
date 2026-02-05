# 핵심 동작 (Read/Analyze/Write) 개선

> 모든 에이전트의 기반이 되는 핵심 동작 패턴 정립

---

## User Story

Claude가 코드를 읽고, 분석하고, 수정하는 핵심 동작이 일관되고 효율적으로 수행되어, 그 위에 특수 목적 에이전트들이 안정적으로 동작한다.

## Acceptance Criteria

- [ ] Read 패턴 정립: brain 기반 효율적 파일 탐색
- [ ] Analyze 패턴 정립: 명확한 분석 기준, 일관된 결과 포맷
- [ ] Write 패턴 정립: 수정 → 테스트 → 검증 파이프라인
- [ ] 각 패턴의 문서화 또는 템플릿화
- [ ] Phase 1 실사용 피드백 반영

## 비기능 요구사항

- 재사용성: 특수 목적 에이전트들이 조합해서 사용 가능
- 일관성: 어떤 에이전트든 동일한 패턴 사용

## Dependencies

- phase1-002, phase1-003 완료 후 실사용 피드백 기반

---

## 배경

특수 목적 에이전트(pattern-validator, brain-updater 등)를 만들기 전에,
기반이 되는 Read/Analyze/Write 동작을 먼저 잘 정립해야 함.

---

**Last Updated**: 2026-02-01
