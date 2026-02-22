# Backlog Selection Rules

백로그 선택, todo→doing 이동, README.md 갱신 규칙.

## 경로

```
docs/backlogs/doing/   # 진행 중
docs/backlogs/todo/    # 대기 중
docs/backlogs/README.md
```

## 스캔 방법

```bash
ls docs/backlogs/doing/*.md 2>/dev/null
ls docs/backlogs/todo/*.md 2>/dev/null
```

## 파일명 파싱

파일명: `phase{N}-{ID}-{slug}.md`

설명(description): 파일 첫 `> ` 인용구에서 추출.

```bash
head -5 docs/backlogs/todo/phase1-001-xxx.md | grep "^>" | head -1 | sed 's/^> //'
```

## AskUserQuestion 형식

doing 항목과 todo 항목을 하나의 질문으로 통합 표시한다.

```json
{
  "question": "어떤 작업을 진행할까요?",
  "header": "작업 선택",
  "multiSelect": false,
  "options": [
    {
      "label": "🔄 phase1-003-feature-z",
      "description": "진행 중 — Feature Z 구현"
    },
    {
      "label": "📋 phase1-001-feature-x",
      "description": "대기 중 — Feature X 구현"
    },
    {
      "label": "📋 phase1-002-feature-y",
      "description": "대기 중 — Feature Y 구현"
    },
    {
      "label": "새로운 작업",
      "description": "백로그 없이 자유 작업"
    }
  ]
}
```

doing 항목을 todo 항목보다 먼저 표시한다.
"새로운 작업" 옵션은 항상 마지막에 표시한다.

백로그가 없으면 AskUserQuestion을 생략하고 "새로운 작업"으로 자동 진행한다.

## todo → doing 이동

todo 항목을 선택한 경우에만 실행한다. doing 항목 선택 시 이동 없음.

```bash
mv docs/backlogs/todo/{filename}.md docs/backlogs/doing/{filename}.md
```

## README.md 갱신

이동 후 `docs/backlogs/README.md`를 업데이트한다.

변경 사항:
1. 현황 개수 갱신 (Todo: -1, Doing: +1)
2. 해당 Task 링크 경로 변경: `todo/` → `doing/`
3. 상태 표시 변경: `Todo` → `🔄 Doing`

예시 (변경 전):
```markdown
| 1 | 001 | [feature-x](todo/phase1-001-feature-x.md) | Todo |
```

예시 (변경 후):
```markdown
| 1 | 001 | [feature-x](doing/phase1-001-feature-x.md) | 🔄 Doing |
```

README.md가 없거나 파싱이 어려우면 개수 갱신만 시도하고 링크 갱신은 스킵한다.

## 작업 표시

선택 완료 후:

```markdown
## 작업 시작

**작업**: phase1-001-feature-x
**상태**: 🔄 진행 중

{백로그 파일의 User Story + Acceptance Criteria 요약}
```
