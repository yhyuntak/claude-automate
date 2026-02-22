# /planning 스킬 재설계

> brainstorm 결과를 plan 파일로 구체화 — Phase 없이 자유 대화 + plan 파일 생성

---

## User Story

brainstorm에서 요구사항과 AC가 정리되면,
자유로운 대화를 통해 구현 방법을 탐색하고
plan 파일을 생성하여 /implement로 넘긴다.

## AS-IS (현재 — 9 Phase 시스템)

```
EnterPlanMode
  → Phase 0: 요구사항 게이트 (필수)
  → Phase 1: 타입 분류 A/B/C (필수)
  → Phase 2: 코드베이스 탐색 (조건부)
  → Phase 3: Brain 참조 (조건부)
  → Phase 3.5: 시각화 (조건부)
  → Phase 4: Plan 작성 (필수)
  → Phase 5: Devil 검증 (필수)
ExitPlanMode
```

문제: Phase 순서 강제. 실제로는 탐색/작성을 왔다갔다함. EnterPlanMode/ExitPlanMode 의존.

## TO-BE (재설계)

```
/planning
  ┌─────────────────────────────────┐
  │  자유 대화                       │
  │                                 │
  │  입력: brainstorm 출력           │
  │       (요구사항 + AC)            │
  │                                 │
  │  사용 가능한 도구:                │
  │  - 코드 탐색 (read-only)        │
  │  - Devil (구현 방식 검증)        │
  │  - AskUserQuestion (선택/확인)   │
  │  - Write (plan 파일만)           │
  │                                 │
  │  제약:                           │
  │  - plan 파일 외 수정 금지         │
  │  - 코드 작성 금지                │
  │                                 │
  │  출력:                           │
  │  - plan 파일 생성                │
  │  → /implement 핸드오프           │
  └─────────────────────────────────┘
```

Phase 없음. EnterPlanMode/ExitPlanMode 제거. 자유롭게 탐색하고 plan 파일 생성.

## 하네스 내 위치

```
/start-work
     │
     └── 새 작업 ──→ /brainstorm → /planning ◀── 여기
                                      │
                                      ▼
                                 /implement
```

## Acceptance Criteria

### 스킬 구조
- [ ] Phase 없이 자유 대화 구조
- [ ] EnterPlanMode/ExitPlanMode 제거
- [ ] frontmatter에 allowed-tools 명시 (Read, Glob, Grep, LSP, Task, Write, AskUserQuestion)
- [ ] plan 파일 외 수정 금지

### 도구 사용 규칙
- [ ] Devil 에이전트: 구현 방식 리스크 확인, plan 작성 직전 최종 검증, 사용자 요청 시
- [ ] Devil 습관적 매번 호출 금지
- [ ] AskUserQuestion: 물어볼 게 있으면 무조건 사용, multiSelect: true 기본
- [ ] Write: plan 파일(.claude/plans/{date}-{slug}.md)만 허용

### Plan 파일
- [ ] 경로: `.claude/plans/{YYYY-MM-DD}-{slug}.md`
- [ ] frontmatter: status (draft/in_progress/done), created, slug
- [ ] 내용: 요구사항 (brainstorm에서) + AC 목록 + 구현 순서 + 테스트 계획
- [ ] 사용자 컨펌 후 Write

### Plan 상태 관리
- [ ] draft: planning에서 생성 (구현 시작 전)
- [ ] in_progress: /implement 시작 시
- [ ] done: /wrap에서 완료 시
- [ ] abandoned 없음 — 안 할 거면 파일 삭제

### 행동 규칙
- [ ] 단계를 강제하지 않는다
- [ ] brainstorm 결과(AC)를 임의로 바꾸지 않는다
- [ ] 구현하지 않는다 — 계획만
- [ ] 사용자 확인 후에만 파일 생성
- [ ] 정리를 재촉하지 않는다

### 핸드오프
- [ ] plan 파일 생성 + 사용자 확인 후 → /implement 안내

### refs/ 분리 (Progressive Disclosure)
- [ ] SKILL.md body는 목차 수준으로 유지
- [ ] refs/plan-file.md — plan 파일 구조 + 상태 관리 + 경로 규칙
- [ ] refs/devil-usage.md — Devil 호출 기준
- [ ] SKILL.md에서 MUST: refs/xxx.md를 읽어라 형태로 참조

### 검증 루프
- [ ] plan 파일에 필수 섹션 체크 (요구사항/AC/구현 순서/테스트 계획)
- [ ] AC가 brainstorm 결과와 일치하는지 확인
- [ ] 사용자 확인 받았는지 확인
- [ ] 실패 시 해당 부분으로 돌아가 수정 → 재검증

## 현재 대비 변경점 요약

- 9 Phase 순서 강제 → 자유 대화 (Phase 없음)
- EnterPlanMode/ExitPlanMode → 제거
- plan 파일 경로: 없음 → `.claude/plans/{date}-{slug}.md`
- plan 상태 관리: 없음 → draft/in_progress/done
- 사용자 확인: ExitPlanMode → AskUserQuestion
- Devil 호출 기준 구체화

## 비기능 요구사항

- 사용자 페이스에 맞춘 대화 (재촉 금지)
- plan 파일 외 파일 수정 금지

## Dependencies

- phase4-019: AI 하네스 2.0 (전체 플로우 정의)
- phase4-020: /brainstorm 스킬 재설계 (입력 형식 정의)

---

**Last Updated**: 2026-02-22
