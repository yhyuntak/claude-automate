# Plan Scanning Rules

Plan 파일을 스캔하여 status를 판단하는 규칙.

## 경로

```
.claude/plans/{date}-{slug}.md
```

예시: `.claude/plans/2026-02-22-implement-hook.md`

## 스캔 방법

```bash
ls -t .claude/plans/*.md 2>/dev/null
```

파일이 없으면 Plan 없음으로 처리하고 Step 3으로 진행한다.

## Status 판단

각 Plan 파일의 frontmatter에서 `status` 필드를 읽는다.

```yaml
---
status: in_progress   # draft | in_progress | done
date: 2026-02-22
---
```

판단 우선순위:

| status | 날짜 기준 | 처리 |
|--------|----------|------|
| `in_progress` | 7일 이내 | "이 Plan을 이어갈까요?" |
| `in_progress` | 7일 초과 | "아직 진행할 건가요?" |
| `draft` | - | "이 Plan을 시작할까요?" |
| `done` | - | 스킵 (표시 안 함) |

최신 파일 순으로 처리한다. 여러 in_progress가 있으면 가장 최근 것만 표시한다.

## AskUserQuestion 형식

in_progress (최근):
```json
{
  "question": "진행 중인 Plan이 있습니다. 이어갈까요?",
  "header": "Plan: {slug}",
  "multiSelect": false,
  "options": [
    { "label": "이어가기", "description": "이 Plan에서 작업 계속" },
    { "label": "건너뛰기", "description": "새 작업 선택 (Step 3)으로 이동" }
  ]
}
```

in_progress (오래됨):
```json
{
  "question": "오래된 Plan이 있습니다. 계속 진행하나요?",
  "header": "Plan: {slug} ({N}일 전)",
  "multiSelect": false,
  "options": [
    { "label": "계속 진행", "description": "이 Plan 이어가기" },
    { "label": "폐기", "description": "이 Plan 무시하고 새 작업 선택" }
  ]
}
```

draft:
```json
{
  "question": "Draft Plan이 있습니다. 시작할까요?",
  "header": "Plan: {slug}",
  "multiSelect": false,
  "options": [
    { "label": "시작", "description": "이 Plan으로 작업 시작" },
    { "label": "건너뛰기", "description": "새 작업 선택 (Step 3)으로 이동" }
  ]
}
```

## 이어가기 선택 시

Plan 파일 내용을 표시하고 Step 5(다음 액션)로 이동한다.
Step 3 백로그 선택을 건너뛴다.
