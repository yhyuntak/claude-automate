# AI 하네스 2.0

> 7개 스킬 기반 통합 하네스 — 세션 연속성 + TDD 자동화 + 컨텍스트 보호

---

## User Story

개발자가 세션을 시작하면, 이전 작업을 자동 복원하고
brainstorm → planning → implement → 검증까지 하나의 루프로 작업한다.

## 전체 플로우

```
새 세션 시작
     │
     ▼
┌─────────────────────────────────────────────────────────────┐
│  /start-work                                                 │
│     1. 세션 컨텍스트 로드 (최근 1개)                            │
│     2. Plan 파일 스캔 (날짜 + status)                          │
│     3. 백로그 선택 (todo→doing 이동)                           │
│     4. 워크트리 (선택)                                        │
│     5. 다음 액션 라우팅                                        │
└─────────────┬───────────────────────┬───────────────────────┘
              │                       │
     plan 이어가기                  새 작업
              │                       │
              │                       ▼
              │              ┌─────────────────┐
              │              │  /brainstorm      │
              │              │  아이디어          │
              │              │  → 요구사항        │
              │              │  → AC 추출        │
              │              │  → 테스트 가능 분류  │
              │              └────────┬──────────┘
              │                       │
              │                       ▼
              │              ┌─────────────────┐
              │              │  /planning        │
              │              │  AC 정리          │
              │              │  구현 순서         │
              │              │  테스트 계획       │
              │              │  → plan 파일 생성  │
              │              └────────┬──────────┘
              │                       │
              ▼                       ▼
        ┌─────────────────────────────────┐
        │  /implement                      │
        │  plan 로드 → TDD 루프            │
        │  ┌─────────────────────┐        │
        │  │ AC별 반복:           │        │
        │  │  1. 테스트 작성      │        │
        │  │  2. 구현             │        │
        │  │  3. 테스트 통과?     │        │
        │  │     ├─ No → 2로     │        │
        │  │     └─ Yes → 다음 AC │        │
        │  └─────────────────────┘        │
        └────────────────┬────────────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │  Stop Hook (자동)    │
              │                     │
              │  ① 테스트 통과?      │
              │     No → exit 2     │
              │     → 계속 수정      │
              │                     │
              │  ② 컨텍스트 ≥80%?   │
              │     Yes → exit 2    │
              │     → /save-context │
              │     → 새 세션 안내   │
              │                     │
              │  ③ 통과 → exit 0    │
              └──────────┬──────────┘
                         │
              ┌──────────┴──────────┐
              │                     │
              ▼                     ▼
    ┌──────────────┐     ┌──────────────────┐
    │ /save-context │     │ /wrap (수동)      │
    │ 세션 저장만   │     │ 컨텍스트 저장     │
    │ → 새 세션     │     │ 백로그 done       │
    │   시작 안내   │     │ plan done         │
    └──────────────┘     │ 커밋              │
                         └──────────────────┘
```

## 7개 스킬

| 순서 | 스킬 | 역할 | 트리거 |
|------|------|------|--------|
| 1 | /start-work | 진입점 — plan/세션 컨텍스트 로드, 백로그 doing 이동 | 사용자 수동 |
| 2 | /brainstorm | 아이디어 → 요구사항 → AC 추출 → 테스트 가능 분류 | start-work에서 연결 |
| 3 | /planning | plan 파일 생성 (AC, 구현 순서, 테스트 계획) | brainstorm 후 |
| 4 | /implement | plan 기반 TDD 루프 (AC별: 테스트→구현→통과) | planning 후 또는 이어가기 |
| 5 | Stop Hook | 테스트 검증(exit 2) + 컨텍스트 감시(≥80% → exit 2) | 자동 (Claude 멈출 때) |
| 6 | /save-context | 세션 컨텍스트 저장만 (Hook 전용, 가벼움) | Stop Hook이 트리거 |
| 7 | /wrap | 전체 마무리 — 컨텍스트 저장 + 백로그 done + plan done + 커밋 | 사용자 수동 |

## 핵심 결정사항

1. **brainstorm 필수 경유** — 새 작업 시 planning 직행 금지
2. **내장 plan mode 안 씀** — `.claude/plans/{date}-{slug}.md`에 직접 생성
3. **plan 상태**: draft / in_progress / done (3가지만, abandoned 없음)
4. **/wrap vs /save-context 분리** — wrap은 수동(전체 마무리), save-context는 Hook 전용(저장만)
5. **Stop Hook은 /compact 실행 불가** — 대신 /save-context 후 새 세션 안내

## 데이터 흐름

```
.claude/plans/*.md              ← planning 생성(draft) / implement 갱신(in_progress) / wrap 완료(done)
.claude/context/{YYYY-MM}/*.md  ← save-context, wrap 저장 / start-work 로드
docs/backlogs/                  ← start-work(todo→doing) / wrap(doing→done)
/tmp/claude-context-pct-{sid}   ← statusline 기록 / Stop Hook 읽기
```

## 백로그 흡수 관계

- phase4-006 (AI+TDD) → brainstorm Phase 5 + planning + implement로 흡수
- phase4-007 (Verification Loop) → implement의 TDD 반복 루프로 흡수
- phase4-008 (Orchestrator) → /implement 스킬 자체가 orchestrator 역할

## 개별 스킬 백로그

각 스킬의 상세 설계는 별도 백로그로 관리:

- phase4-018: [/start-work 스킬 재설계](todo/phase4-018-start-work-redesign.md)
- phase4-0XX: /brainstorm 스킬 재설계 (예정)
- phase4-0XX: /planning 스킬 재설계 (예정)
- phase4-0XX: /implement 스킬 (신규, 예정)
- phase4-0XX: Stop Hook 운영 설계 (예정)
- phase4-0XX: /save-context 스킬 (신규, 예정)
- phase4-0XX: /wrap 스킬 개선 (예정)

## Acceptance Criteria

- [ ] 7개 스킬 각각의 상세 설계 백로그 등록 완료
- [ ] 7개 스킬 구현 완료
- [ ] 전체 플로우 E2E 테스트 통과
- [ ] phase4-006, 007, 008 백로그 닫기

## Dependencies

- phase4-005 (Hook System) 완료 — Stop Hook POC 검증됨

---

**Last Updated**: 2026-02-22
