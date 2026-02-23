---
name: start-work
description: |
  세션 시작 시 작업 환경을 설정한다.
  컨텍스트 복원, plan 이어가기, 백로그 관리를 하나로 통합한다.
  "start-work", "작업 시작", "시작하자" 키워드로 활성화.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Task
  - AskUserQuestion
  - Bash
---

## Step 1: 세션 컨텍스트 로드

MUST: `refs/context-loading.md`를 읽고 컨텍스트 로드 규칙을 확인하라.

가장 최근 컨텍스트 파일 1개를 읽어 요약을 표시한다.
파일이 없으면 "이전 세션 없음"을 명시하고 Step 2로 진행한다.

### 중단된 세션 감지 시

컨텍스트에서 "다음 행동"이 발견되면 중단된 세션이다.
AskUserQuestion으로 이어가기 여부를 확인한다:

```json
{
  "question": "이전 세션이 중단된 상태입니다. 이어갈까요?\n\n다음 행동: {다음 행동 내용}",
  "header": "세션 이어가기",
  "multiSelect": false,
  "options": [
    { "label": "이어가기 (Recommended)", "description": "이전 세션의 다음 행동부터 재개" },
    { "label": "새로 시작", "description": "이전 세션 무시하고 새 작업 선택" }
  ]
}
```

- "이어가기" 선택 시:
  - 상태가 `implement`이고 Plan 경로 있으면 → `/implement` 안내
  - 상태가 `planning`이면 → `/planning` 안내
  - 상태가 `brainstorm`이면 → `/brainstorm` 안내
  - 상태가 `자유 대화`이면 → "다음 행동" 기반으로 자유 논의 진행
  - **Step 2~4를 건너뛴다.**
- "새로 시작" 선택 시 → Step 2로 계속 진행

## Step 2: Plan 파일 스캔

MUST: `refs/plan-scanning.md`를 읽고 Plan 스캔 규칙을 확인하라.

`.claude/plans/*.md` 에서 status 필드를 읽어 분류한다.

- in_progress → AskUserQuestion: "이 Plan을 이어갈까요?"
- draft → AskUserQuestion: "이 Plan을 시작할까요?"
- Plan 없음 → Step 3으로 진행

Plan이 있고 사용자가 이어가기를 선택하면 Step 5(다음 액션)로 바로 이동한다.

## Step 3: 백로그 선택

MUST: `refs/backlog-selection.md`를 읽고 백로그 선택 규칙을 확인하라.

`docs/backlogs/doing/` + `docs/backlogs/todo/` 항목을 통합해 AskUserQuestion으로 표시한다.

- doing 항목: 우선 표시 (진행 중)
- todo 항목: 다음 표시 (대기 중)
- 추가 옵션: "새로운 작업 (백로그 없이)"

todo 항목 선택 시 → `doing/`으로 이동 + `README.md` 갱신 수행.
백로그가 없으면 "새로운 작업"으로 자동 진행한다.

## Step 4: 워크트리 (선택)

AskUserQuestion으로 워크트리 사용 여부를 확인한다.

```json
{
  "question": "이 작업에 worktree를 사용할까요?",
  "header": "Worktree",
  "multiSelect": false,
  "options": [
    { "label": "Yes", "description": "별도 브랜치에서 격리 작업" },
    { "label": "No", "description": "현재 폴더에서 작업" }
  ]
}
```

Yes 선택 시 워크트리 생성 규칙:
- 브랜치명: 파일 slug 추출 (예: `phase1-001-feature-x` → `feature-x`)
- 경로: `../{project-name}-{branch}`
- 기존 워크트리 있으면 경고 표시
- .env 파일 있으면 워크트리에 복사

```bash
git worktree add ../{project}-{branch} -b {branch}
```

## Step 5: 다음 액션

AskUserQuestion으로 다음 행동을 결정한다.

```json
{
  "question": "다음에 무엇을 할까요?",
  "header": "Next Action",
  "multiSelect": false,
  "options": [
    { "label": "Plan 이어가기", "description": "/implement 로 진행" },
    { "label": "브레인스토밍", "description": "뭘 만들지 구체화 (/brainstorm)" },
    { "label": "질문/논의", "description": "작업에 대해 더 논의" }
  ]
}
```

선택에 따라 안내:
- "Plan 이어가기" → `/implement` 스킬 안내
- "브레인스토밍" → `/brainstorm` 스킬 안내
- "질문/논의" → 자유 논의 진행

## 검증

MUST: 아래 체크리스트를 모두 확인하라.

- [ ] 세션 컨텍스트를 표시했는가? (없으면 "없음" 명시)
- [ ] 중단된 세션이면 이어가기 옵션을 제시했는가?
- [ ] Plan 스캔 결과를 표시했는가? (없으면 "없음" 명시)
- [ ] 사용자 선택을 받았는가? (백로그 또는 새로운 작업)
- [ ] 다음 액션을 AskUserQuestion으로 안내했는가?

실패 시: 해당 Step으로 돌아가 수정 → 재검증.
