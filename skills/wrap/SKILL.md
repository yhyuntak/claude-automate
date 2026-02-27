---
name: wrap
description: |
  세션 종료 시 태스크 마무리.
  plan 확인 + 백로그 정리 + 문서 싱크 체크 + 커밋.
  "wrap", "마무리", "끝" 키워드로 활성화.
argument-hint: "[커밋 메시지]"
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

$ARGUMENTS

---

## 진행 안내 규칙

각 단계 진입 시 사용자에게 현재 상황을 안내한다.

- 진입: "마무리를 시작합니다."
- 각 단계: "[N/4] {단계명} 실행합니다."
- 결과: 각 단계 완료 후 요약 한 줄
- 완료: "마무리 완료"

## Step 1: Plan 확인

`.claude/plans/` 에서 `status: in_progress`인 plan 파일을 Glob으로 탐색한다.

있으면:
- 모든 AC가 체크(`- [x]`)되었는지 확인
- 미완료 AC가 있으면 경고 출력 + AskUserQuestion ("미완료 AC가 있습니다. 그래도 진행할까요?")
- 진행 확인 후 writer에 위임하여 plan 파일의 status를 `done`으로 변경

없으면: 스킵

MUST: `.claude/state/mode`에 `idle`을 기록하라. (`echo idle > .claude/state/mode`)

## Step 2: 백로그 정리

`docs/backlogs/doing/` 에서 현재 작업과 관련된 백로그 파일을 확인한다.

- doing/에 여러 개 있을 수 있으므로, 현재 plan slug나 대화 히스토리와 매칭되는 것을 찾음
- 관련 백로그의 AC가 모두 완료되었으면 → Bash로 `done/`으로 이동
- `docs/backlogs/README.md` 업데이트 (writer 위임):
  - 현황: Doing -1, Done +1
  - 링크 경로: `doing/` → `done/`
  - 상태: `🔄 Doing` → `✅ Done`

관련 백로그 없으면: 스킵

## Step 3: 문서 싱크 체크

doc-sync-checker 에이전트로 변경 파일과 인덱스의 일치 여부를 확인한다.

```
Task(
  subagent_type="claude-automate:doc-sync-checker",
  prompt="git diff로 변경된 파일 목록 확인. docs/README.md 인덱스와 비교하여 누락/불일치 항목 보고."
)
```

결과에 싱크 문제 있으면:
- AskUserQuestion ("인덱스 업데이트할까요?")
- 확인 시 writer에 위임하여 업데이트

싱크 문제 없으면: 스킵

doc-sync-checker 실패 시: "문서 싱크 체크 실패 (경고)" 출력하고 Step 4로 진행 (실패 내성)

## Step 4: 커밋

변경 내용 기반으로 커밋 메시지 초안을 작성한다.

- $ARGUMENTS가 있으면 기본 메시지로 제안
- 없으면 `git diff --stat` 기반으로 메시지 생성

AskUserQuestion으로 커밋 메시지 확인:

```json
{
  "question": "커밋 메시지를 확인해주세요.",
  "header": "커밋",
  "multiSelect": false,
  "options": [
    { "label": "이대로 커밋", "description": "제안된 메시지로 커밋 실행" },
    { "label": "메시지 수정", "description": "메시지를 직접 입력" },
    { "label": "커밋 안 함", "description": "커밋 없이 종료" }
  ]
}
```

- "이대로 커밋" → `git add -A && git commit -m "{메시지}"` 실행
- "메시지 수정" → AskUserQuestion으로 메시지 입력 받아 커밋
- "커밋 안 함" → 스킵하고 graceful하게 종료

---

## 제약

- plan에 없는 작업은 하지 않는다
- 모든 파일 수정은 writer에 위임 (git 명령 제외)
- 커밋은 반드시 사용자 확인 후

---

## 검증

MUST: 아래 체크리스트를 모두 확인하라.

- [ ] plan 파일 status가 `done`인가? (또는 plan 없으면 스킵)
- [ ] doing/ 파일이 done/으로 이동되었는가? (또는 관련 백로그 없으면 스킵)
- [ ] docs/README.md 인덱스가 최신인가?
- [ ] 사용자가 커밋을 확인했는가?
- [ ] 진행 안내가 각 단계마다 출력되었는가?

실패 시: 해당 Step으로 돌아가 수정 → 재검증.

---

## 주의사항

1. **각 Step은 대상이 없으면 스킵** — 에러가 아님, 정상 흐름
2. **doc-sync-checker 실패는 wrap을 중단시키지 않음** — 경고 출력 후 계속
3. **커밋 거부 시 graceful하게 종료** — AskUserQuestion 생략 금지
