# Plan 파일 규칙

## 경로

`.claude/plans/{YYYY-MM-DD}-{slug}.md`

예시: `.claude/plans/2026-02-22-user-auth.md`

---

## 상태 관리

```
draft       → planning에서 생성 (구현 시작 전)
in_progress → /implement 시작 시
done        → /wrap에서 완료 시
```

abandoned 없음 — 안 할 거면 파일 삭제.

---

## 파일 구조

```markdown
---
status: draft
created: {YYYY-MM-DD}
slug: {feature-name}
test-command: {프로젝트 테스트 커맨드 예: npm test, pytest, go test}
---

# Plan: {feature-name}

## 요구사항

### Context (배경)
- {대화에서 가져옴}

### What (무엇을)
- {핵심 기능}

### Why (왜)
- {목표/가치}

### Scope
- ✅ In: {이번에 할 것}
- ❌ Out: {안 할 것}

## Brain 업데이트

- code-map: {구조 변경 사항}
- patterns: {새 패턴 또는 변경}
- decisions: {아키텍처 결정 사항}

(implement 시 제일 먼저 실행. 해당 없으면 "없음" 명시.)

<!--
AC = 작업 항목 (진행 추적, 체크박스 = 상태)
TC = 검증 기준 (TDD 테스트 대상, AC별 하위 항목)
-->

## AC 목록

- [ ] AC-1: {작업 항목}
  - TC: {검증 조건 1}
  - TC: {검증 조건 2}
- [ ] AC-2: {작업 항목}
  - TC: {검증 조건}
- [ ] AC-3: {작업 항목} (TC 없음)

## 구현 순서

1. Brain 업데이트
2. AC-1 → {어떤 파일, 어떤 방식}
3. AC-2 → {어떤 파일, 어떤 방식}
```

---

## test-command

Stop Hook이 implement 중 자동으로 실행하는 테스트 커맨드.
- planning 단계에서 설정
- 프로젝트에 맞는 커맨드 사용 (npm test, pytest, go test 등)
- 비어있으면 테스트 스킵

---

## start-work에서의 판단

| 날짜 | status | 액션 |
|------|--------|------|
| 최근 | in_progress | "이어갈까요?" |
| 오래됨 | in_progress | "아직 할 건가요?" |
| - | draft | "시작할까요?" |
