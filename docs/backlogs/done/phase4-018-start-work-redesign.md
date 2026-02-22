# /start-work 스킬 재설계

> 세션 진입점 — 컨텍스트 복원 + plan 이어가기 + 백로그 관리를 하나로 통합

---

## User Story

사용자가 새 세션을 시작하면, 이전 작업 상태를 자동으로 복원하고
다음에 할 일을 안내받는다.

## AS-IS 플로우 (현재)

```
┌──────────────────────────────────────────────┐
│  /start-work                                  │
│     │                                        │
│     ├─ 1. Display session summary            │
│     │      └─ .claude/context/ 확인           │
│     ├─ 2. Display backlog table              │
│     │      └─ docs/backlog/todo/ 확인         │
│     ├─ 3. [Ask] "Use worktree?"              │
│     ├─ 4. [Ask] "Which task?"                │
│     ├─ 5. (If worktree) git worktree add     │
│     ├─ 6. Completion message                 │
│     └─ 6.5 [Ask] "다음에 무엇을 할까요?"      │
│            ├─ 브레인스토밍 → /brainstorm       │
│            ├─ 계획 세우기 → /planning          │
│            ├─ 바로 구현                        │
│            └─ 질문/논의                        │
└──────────────────────────────────────────────┘
```

## TO-BE 플로우 (재설계)

```
/start-work
  → Step 1: 세션 컨텍스트 로드 (최근 1개만)
  → Step 2: Plan 파일 스캔 (날짜 + status)
     ├─ in_progress → "이어갈까요?" → /implement
     ├─ draft → "시작할까요?" → /implement
     └─ 없음 → Step 3
  → Step 3: 백로그 선택
     - doing/ + todo/ 한 번에 표시
     - 선택 시 todo→doing 이동 + README 갱신
     - 또는 새로운 작업 (백로그 없이)
  → Step 4: 워크트리 (선택)
  → Step 5: 다음 액션
     ├─ plan 이어가기 → /implement
     └─ 새 작업 → /brainstorm 또는 질문/논의
```

## 하네스 내 위치

```
새 세션 시작
     │
     ▼
/start-work  ◀── 여기
     │
     ├── plan 이어가기 ──→ /implement (TDD 루프)
     │                         │
     └── 새 작업 ──→ /brainstorm → /planning → /implement
                                                    │
                                               Stop Hook
                                               ├─ 테스트 실패 → 계속 수정
                                               ├─ 컨텍스트 ≥80% → /save-context → 새 세션
                                               └─ 통과 → exit 0

     사용자 수동: /wrap (완료 시) — 컨텍스트 저장 + 백로그 done + 커밋
```

## Acceptance Criteria

### Step 1: 세션 컨텍스트 로드
- [ ] `.claude/context/{YYYY-MM}/` 에서 가장 최근 파일 1개를 자동 로드
- [ ] 컨텍스트 파일이 없으면 스킵하고 Step 2로 진행
- [ ] 로드한 내용을 요약해서 사용자에게 표시

### Step 2: Plan 파일 스캔 (신규)
- [ ] `.claude/plans/*.md` 에서 status 필드를 읽어 분류
- [ ] 날짜 + status 조합으로 판단:
  - 최근 + in_progress → "이어갈까요?"
  - 오래된 + in_progress → "아직 할 건가요?"
  - draft → "시작할까요?"
- [ ] plan이 있으면 AskUserQuestion으로 선택지 제시
- [ ] plan이 없으면 Step 3으로 진행

### Step 3: 백로그 선택 (개선)
- [ ] `docs/backlogs/doing/` + `docs/backlogs/todo/` 통합 표시
  - doing 항목: 🔄 진행 중
  - todo 항목: 📋 대기 중
- [ ] AskUserQuestion으로 선택 (또는 "새로운 작업")
- [ ] todo 항목 선택 시 → `doing/`으로 이동 + README.md 갱신
- [ ] 백로그가 없으면 스킵

### Step 4: 워크트리 (기존 유지)
- [ ] 기존 워크트리 로직 유지

### Step 5: 다음 액션 라우팅 (변경)
- [ ] plan 이어가기 선택 시 → /implement 안내
- [ ] 새 작업 선택 시 → /brainstorm 필수 경유
- [ ] 기존 4가지 → 2가지로 단순화 (brainstorm / implement)

## 현재 대비 변경점 요약

- Plan 파일 스캔 기능 추가 (Step 2 신규)
- 백로그 todo→doing 자동 이동 로직 추가
- README.md 자동 갱신 추가
- 다음 액션: 4가지 → 2가지 (brainstorm / implement)
- brainstorm 필수 경유 (새 작업 시)
- 경로 수정: docs/backlog/ → docs/backlogs/

## 비기능 요구사항

- 각 Step에서 해당 파일/폴더가 없으면 graceful하게 스킵
- 사용자 선택은 AskUserQuestion 사용 (multiSelect 규칙 준수)

## Dependencies

- plan 파일 규칙 확정 (경로: `.claude/plans/{date}-{slug}.md`, status: draft/in_progress/done)
- 세션 컨텍스트 경로 규칙 확정 (`.claude/context/{YYYY-MM}/{YYYY-MM-DD}-{slug}.md`)

---

**Last Updated**: 2026-02-22
