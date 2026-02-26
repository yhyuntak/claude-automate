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

# /wrap

> 세션 종료 시 태스크를 마무리하는 4단계 실행기

$ARGUMENTS

---

## 역할

현재 세션에서 완료된 작업을 정리하고 저장한다.
plan 종료 → 백로그 이동 → 컨텍스트 저장 → 커밋 순서로 실행한다.

---

## 실행

### Step 1 — Plan 확인

`.claude/plans/*.md` Glob으로 최근 plan 파일 확인.
implement에서 이미 `status: done`으로 변경되므로, 여기서는 확인만 한다.

스킵 조건: plan 파일이 없을 때.

### Step 2 — Backlog 이동

`docs/backlogs/doing/` 파일을 `docs/backlogs/done/`으로 이동 (Bash: mv).
`docs/backlogs/README.md` 업데이트:
- 현황: Doing -1, Done +1
- 링크 경로: `doing/` → `done/`
- 상태: `🔄 Doing` → `✅ Done`

스킵 조건: `docs/backlogs/doing/` 디렉토리가 비어있을 때.

### Step 3 — 종료 컨텍스트 저장

MUST: refs/completion-context.md를 읽고 템플릿을 확인하라.

`.claude/context/{YYYY-MM}/{YYYY-MM-DD}-{slug}.md`에 저장.
slug는 완료된 태스크 이름 기반으로 생성.

### Step 4 — 커밋

변경된 파일 전체 stage (코드 + plan + backlog + context).
변경 내용 기반으로 커밋 메시지 초안 작성.
AskUserQuestion으로 커밋 메시지 확인 후 커밋 실행.

---

## 제약

- 코드 검증 (패턴체크, 문서싱크)은 하지 않는다
- plan에 없는 작업은 하지 않는다
- 각 Step에서 대상 파일이 없으면 해당 Step만 스킵

---

## 검증

MUST: 아래 체크리스트를 모두 확인하라.

- [ ] plan 파일 status가 `done`인가? (또는 스킵 사유 명시)
- [ ] doing/ 파일이 done/으로 이동되었는가? (또는 스킵 사유 명시)
- [ ] 종료 컨텍스트 파일이 생성되었는가?
- [ ] 사용자가 커밋 메시지를 확인했는가?

실패 시: 해당 Step으로 돌아가 수정 → 재검증.

---

## 주의사항

1. **plan/backlog 없으면 스킵** — 에러가 아님, 정상 흐름
2. **커밋은 반드시 사용자 확인 후** — AskUserQuestion 생략 금지
3. **종료 컨텍스트는 save-context와 다른 템플릿 사용** — refs/completion-context.md 참조
