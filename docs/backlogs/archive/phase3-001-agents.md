# 에이전트 고도화

> 핵심 동작 위에 특수 목적 에이전트 구현

---

## User Story

Claude가 패턴 위반을 자동 검증/수정하고, 레거시를 스캔하여, 프로젝트가 자율적으로 진화한다.

## Acceptance Criteria

- [ ] pattern-validator: 위반이 진짜인지 검증
- [ ] pattern-fixer: 위반 자동 수정 + 테스트 + 롤백
- [ ] pattern-fixer-high: 복잡한 수정 (Opus)
- [ ] legacy-scanner: 패턴 변경 시 레거시 스캔
- [ ] /wrap 플로우에 통합

## 비기능 요구사항

- 티어 구분: 복잡도에 따라 Sonnet/Opus 분리
- 조합 가능: Read/Analyze/Write 패턴 기반

## Dependencies

- phase2-001-core-operations 완료 필요

---

## 에이전트 상세

| 에이전트 | 역할 | 티어 |
|----------|------|------|
| pattern-validator | 위반 검증 | Sonnet |
| pattern-fixer | 자동 수정 | Sonnet |
| pattern-fixer-high | 복잡한 수정 | Opus |
| legacy-scanner | 레거시 스캔 | Sonnet |

---

**Last Updated**: 2026-02-01
