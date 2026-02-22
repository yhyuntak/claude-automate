---
status: done
date: 2026-02-23
slug: wrap-skill
test-command: null
---

# /wrap 스킬 설계 + 구현

## 요구사항

브레인스토밍 결정사항:
- /wrap = "끝내는 것" (태스크 완료), /save-context = "쉬는 것" (세션 중단)
- 패턴 체크 / 문서 싱크는 /wrap에서 제거 → 별도 백로그
- implement는 커밋하지 않음 → /wrap이 최종 커밋 포인트

## AC

- [x] `skills/wrap/SKILL.md` 생성 — 기존 스킬 패턴(frontmatter, 역할, 실행, 제약, 검증, 주의사항) 준수
- [x] plan 파일 상태를 `done`으로 업데이트하는 Step 포함
- [x] backlog `doing/` → `done/` 이동 + README.md 업데이트 Step 포함
- [x] 종료용 컨텍스트 저장 Step 포함 (refs/completion-context.md 템플릿)
- [x] 모든 변경사항 커밋 Step이 마지막에 위치
- [x] 기존 `commands/wrap.md` 삭제

## 구현 순서

### 1. `skills/wrap/SKILL.md` 작성

```yaml
---
name: wrap
description: |
  세션 종료 시 태스크 마무리.
  plan 완료 + 백로그 정리 + 컨텍스트 저장 + 커밋.
  "wrap", "마무리", "끝" 키워드로 활성화.
allowed-tools:
  - Read
  - Glob
  - Bash
  - Edit
  - Write
  - Task
  - AskUserQuestion
---
```

**실행 4 Step:**

**Step 1 — Plan 종료**
- `.claude/plans/*.md`에서 `status: in_progress` 파일 찾기 (Glob)
- frontmatter의 status를 `done`으로 변경 (Edit)
- plan 파일 없거나 in_progress 없으면 → 스킵

**Step 2 — Backlog 이동**
- `docs/backlogs/doing/` 파일을 `docs/backlogs/done/`으로 이동 (Bash: mv)
- `docs/backlogs/README.md` 업데이트:
  - 현황: Doing -1, Done +1
  - 링크 경로: `doing/` → `done/`
  - 상태: `🔄 Doing` → `✅ Done`
- doing/ 비어있으면 → 스킵

**Step 3 — 종료 컨텍스트 저장**
- MUST: refs/completion-context.md 읽고 템플릿 확인
- `.claude/context/{YYYY-MM}/{YYYY-MM-DD}-{slug}.md`에 저장
- save-context와 다른 점: "완료" 상태, 다음 행동 = "새 태스크 선택"

**Step 4 — 커밋**
- `git add` (코드 + plan + backlog + context 전부)
- 커밋 메시지: `feat: {slug} 구현 완료` 또는 변경 내용 기반
- AskUserQuestion으로 커밋 메시지 확인

### 2. `skills/wrap/refs/completion-context.md` 작성

종료 전용 컨텍스트 템플릿:

```markdown
# Session: {task-name} (YYYY-MM-DD)

## 상태: 완료
## Plan: .claude/plans/{date}-{slug}.md
## 다음 행동: /start-work로 새 태스크 선택

## 완료 내용
- {무엇을 만들었는가}

## 주요 결정
- {설계/구현에서 내린 결정 + 근거}

## 남은 작업
- {이 태스크와 관련해 추가로 할 수 있는 것 — 없으면 "없음"}
```

### 3. `commands/wrap.md` 삭제

- 기존 V3 command 파일 삭제
- 스킬이 대체하므로 command는 불필요

### 4. 백로그 추가 (패턴체크 / 문서싱크 분리)

- /wrap에서 빠진 패턴 체크 / 문서 싱크를 별도 백로그로 등록
- 향후 적절한 타이밍(implement hook, 커밋 전 등)에서 처리할 수 있도록

## 의존성

- save-context SKILL.md — 컨텍스트 저장 패턴 참조
- start-work refs/backlog-selection.md — 백로그 이동 패턴 참조 (역방향)
