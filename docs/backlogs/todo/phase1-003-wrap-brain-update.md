# /wrap에 brain 업데이트 추가

> 세션 종료 시 프로젝트 뇌를 증분 업데이트

---

## User Story

사용자가 /wrap을 실행하면, 이번 세션의 작업 내용이 brain.md에 자동으로 반영되어 다음 세션에서 활용 가능하다.

## Acceptance Criteria

- [ ] /wrap 플로우에 brain 업데이트 단계 추가
- [ ] Architecture 변경 시 해당 섹션 갱신
- [ ] 새 패턴 도입 시 Patterns 섹션 갱신
- [ ] 레거시 발견/해결 시 Legacy 섹션 갱신
- [ ] 주요 결정 시 History 섹션 추가
- [ ] 증분 업데이트 (전체 재작성 X)

## 비기능 요구사항

- 자동화: 사용자 개입 없이 업데이트
- 안정성: 업데이트 실패해도 세션 저장은 진행

## Dependencies

- phase1-001-brain-structure 완료 필요

---

## 수정 대상

- commands/wrap.md
- (선택) agents/brain-updater.md 신규 생성

---

**Last Updated**: 2026-02-01
