# /start-work에 brain 로드 추가

> 세션 시작 시 프로젝트 뇌를 컨텍스트에 주입

---

## User Story

사용자가 /start-work를 실행하면, brain.md가 자동으로 로드되어 Claude가 프로젝트 맥락을 이미 파악한 상태로 작업을 시작한다.

## Acceptance Criteria

- [ ] /start-work 플로우에 brain.md 로드 단계 추가
- [ ] brain.md 존재 시 내용 표시
- [ ] brain.md 없을 시 초기화 안내 또는 자동 생성
- [ ] 로드된 brain 내용이 세션 컨텍스트에 반영

## 비기능 요구사항

- 로드 시간: brain.md 읽기는 즉시 완료
- 실패 처리: 파일 없어도 세션은 정상 시작

## Dependencies

- phase1-001-brain-structure 완료 필요

---

## 수정 대상

- commands/start-work.md

---

**Last Updated**: 2026-02-01
