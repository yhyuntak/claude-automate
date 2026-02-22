# 문서 싱크 체크 타이밍 재설계

> 코드 변경 시 관련 문서(README, CLAUDE.md 등) 동기화 검증을 적절한 시점에 실행

---

## User Story

개발자가 코드를 변경할 때, 관련 문서가 outdated 되었는지 적절한 시점에 감지하여 문서 품질을 유지한다.

## Acceptance Criteria

- [ ] 문서 싱크 체크가 실행될 최적 시점 결정 (implement 중 / 커밋 전 hook / 별도 명령)
- [ ] 기존 doc-sync-checker 에이전트 재활용 또는 재설계 결정
- [ ] 선택된 방식으로 문서 싱크 체크 통합

## 비기능 요구사항

- 메인 컨텍스트 오염 최소화
- 변경된 코드와 관련 문서만 정밀 체크

## Dependencies

- /wrap 스킬 재설계 완료 (wrap에서 분리된 기능)

---

**Last Updated**: 2026-02-23
