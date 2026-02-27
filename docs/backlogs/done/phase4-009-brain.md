# Brain Bootstrap & Index

> brain.md 인덱스 자동 생성 + planning/implement 루프에서 brain이 실제로 축적되게 만들기

---

## User Story

CA 사용자가 어떤 프로젝트에서든 첫 /planning을 돌리면 brain.md 인덱스가 자동 생성되고, 이후 planning→implement 루프를 거듭할수록 프로젝트 지식이 축적된다.

## Acceptance Criteria

- [ ] brain.md 인덱스 구조 설계 (code-map, decisions, patterns를 가리키는 목차)
- [ ] /planning 수정: brain.md 없으면 skip이 아니라, exploration 후 brain.md 초기 생성을 plan에 포함
- [ ] /implement 수정: brain update 시 brain.md 인덱스도 함께 갱신
- [ ] 새 프로젝트에서 첫 /planning → brain.md 생성 → 이후 루프 정상 동작 확인

## Context (already implemented)

- `.claude/brain/` 폴더 구조: code-map.md, decisions.md, patterns/
- /planning Step 3: brain.md 읽기 (없으면 skip → 이걸 고쳐야 함)
- /implement Step [2/5]: plan의 brain section 실행 (인덱스 갱신 누락 → 추가 필요)

## Dependencies

- review-insights.md A1 참조

---

**Last Updated**: 2026-02-28
