# /save-context 스킬 (신규)

> Stop Hook 전용 — 세션 컨텍스트를 상황별 템플릿으로 저장

---

## User Story

컨텍스트가 70%에 도달하면 Stop Hook이 /save-context를 트리거하고,
상황에 맞는 템플릿으로 세션 상태를 저장하여
다음 세션에서 /start-work로 이어갈 수 있게 한다.

## 하네스 내 위치

```
Stop Hook (컨텍스트 ≥70%)
  → exit 2 → /save-context ◀── 여기
  → 세션 컨텍스트 저장
  → "새 세션에서 /start-work로 이어가세요"
```

## Acceptance Criteria

### 상황 판단
- [ ] Claude가 대화 내용을 보고 상황 추천 (implement/planning/brainstorm/자유 대화)
- [ ] AskUserQuestion으로 사용자 확인 (multiSelect: true)

### 상황별 저장
- [ ] 4가지 케이스별 템플릿 적용
- [ ] 공통 헤더: 상태, plan 경로(있으면), 다음 행동
- [ ] AC는 plan 파일이 SSOT — 컨텍스트에는 plan 경로만 저장

### 저장 경로
- [ ] `.claude/context/{YYYY-MM}/{YYYY-MM-DD}-{slug}.md`

### 안내
- [ ] 저장 후 "새 세션에서 /start-work로 이어가세요" 안내

## Dependencies

- phase4-019: AI 하네스 2.0
- phase4-023: Stop Hook (트리거)

---

**Last Updated**: 2026-02-23
