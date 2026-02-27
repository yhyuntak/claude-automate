---
name: docs
description: |
  프로젝트 문서 CRUD + 인덱스 관리.
  문서 생성/수정/삭제 + docs/README.md 인덱스 자동 업데이트.
  "docs", "문서", "document" 키워드로 활성화.
argument-hint: "[제목 또는 설명]"
allowed-tools:
  - Read
  - Glob
  - Bash
  - Edit
  - Write
  - Task
  - AskUserQuestion
---

# /docs

$ARGUMENTS

---

## 진행 안내 규칙

각 단계 진입 시 사용자에게 현재 상황을 안내한다.

- 진입: "{Direct/Interview} 모드로 문서 작업을 시작합니다."
- 각 단계: "[N/5] {단계명} 실행합니다."
- 완료: "문서 작업이 완료되었습니다."

## Step 1: 모드 감지

인자와 대화 히스토리를 분석하여 모드를 결정한다.

| 조건 | 모드 |
|------|------|
| 구체적 내용 있음 (제목, 파일 경로, 문서화할 대화 히스토리) | **Direct** → Step 2 |
| `/docs`만 단독 호출, 맥락 없음 | **Interview** → AskUserQuestion |
| 판단 불가 | AskUserQuestion으로 확인 |

Interview 모드 진입 시 무엇을 문서화할지 질문한다:

```json
{
  "question": "어떤 문서 작업을 하시겠어요?",
  "header": "문서 작업 내용",
  "multiSelect": false,
  "options": [
    { "label": "새 문서 작성", "description": "새로운 문서를 작성합니다" },
    { "label": "기존 문서 수정", "description": "기존 문서를 수정합니다" },
    { "label": "문서 삭제", "description": "문서를 삭제합니다" },
    { "label": "인덱스 재생성", "description": "docs/README.md 인덱스를 현재 상태로 재생성합니다" }
  ]
}
```

모드 결정 후 사용자에게 안내한다:
- Direct: "**Direct 모드**로 문서 작업을 시작합니다. 제공된 내용을 기반으로 진행합니다."
- Interview: "**Interview 모드**로 문서 작업을 시작합니다. 질문을 통해 내용을 구체화합니다."

## Step 2: 작업 유형 선택

Direct 모드에서 작업 유형이 이미 명확하면 이 단계를 스킵한다.

작업 유형이 불명확한 경우 AskUserQuestion으로 확인한다:

```json
{
  "question": "어떤 작업을 할까요?",
  "header": "작업 유형 선택",
  "multiSelect": false,
  "options": [
    { "label": "새 문서 작성", "description": "새로운 문서를 docs/ 에 추가합니다" },
    { "label": "기존 문서 수정", "description": "이미 있는 문서를 수정합니다" },
    { "label": "문서 삭제", "description": "문서를 삭제하고 인덱스에서 제거합니다" },
    { "label": "인덱스 재생성", "description": "docs/README.md를 현재 파일 구조 기준으로 재생성합니다" }
  ]
}
```

## Step 3: docs/ 탐색 + 위치 결정

explore 에이전트로 docs/ 구조를 파악한다.

```
Task(
  subagent_type="claude-automate:explore",
  prompt="docs/ 폴더 전체 구조와 README.md 인덱스 현황 파악"
)
```

작업 유형별 처리:

| 유형 | 처리 |
|------|------|
| 새 문서 작성 | 기존 구조 기반으로 적절한 위치 2~3개 AskUserQuestion으로 추천 |
| 기존 문서 수정 | 대상 파일 경로 확인 |
| 문서 삭제 | 대상 파일 경로 확인 |
| 인덱스 재생성 | 현재 docs/ 파일 목록 수집 |

새 문서 작성 시 위치 추천 예시:

```json
{
  "question": "문서를 어디에 저장할까요?",
  "header": "저장 위치 선택",
  "multiSelect": false,
  "options": [
    { "label": "docs/references/", "description": "참고 자료 및 외부 문서" },
    { "label": "docs/backlogs/", "description": "백로그 작업 문서" },
    { "label": "docs/ (루트)", "description": "최상위 문서" }
  ]
}
```

## Step 4: 실행

작업 유형에 맞게 writer 에이전트에게 위임한다. 모든 파일 수정은 writer가 처리한다.

**새 문서 작성:**

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
{제목} 문서 생성

## Target
{결정된 경로}/{파일명}.md (신규 생성)

## Requirements
- 제목: {제목}
- 내용: {대화 히스토리 또는 사용자 제공 내용}
- 기존 docs/ 문서 스타일 준수

## Verification
파일 존재 여부 확인
"""
)
```

**기존 문서 수정:**

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
{파일명} 문서 수정

## Target
{대상 파일 경로}

## Requirements
- 수정 내용: {수정할 내용}
- 기존 문서 구조 유지

## Verification
파일 변경 내용 확인
"""
)
```

**문서 삭제:**

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
{파일명} 삭제

## Target
{대상 파일 경로}

## Requirements
- Bash로 파일 삭제: rm {파일 경로}

## Verification
파일 미존재 확인
"""
)
```

**인덱스 재생성:**

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
docs/README.md 인덱스 재생성

## Target
docs/README.md

## Requirements
- docs/ 하위 모든 .md 파일을 Glob으로 수집
- 현재 파일 목록 기준으로 인덱스 테이블 재작성
- 기존 README.md 구조 유지

## Verification
README.md 존재 + 내용 확인
"""
)
```

## Step 5: 인덱스 업데이트

Step 4가 인덱스 재생성이었으면 이 단계를 스킵한다.

문서 생성/수정/삭제 시 docs/README.md 인덱스를 업데이트한다. 변경이 없으면 스킵한다.

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
docs/README.md 인덱스 업데이트

## Target
docs/README.md

## Requirements
- 변경 유형: {생성/수정/삭제}
- 대상 파일: {파일 경로}
- 생성: 인덱스 테이블에 새 항목 추가
- 수정: 해당 항목 설명 업데이트
- 삭제: 해당 항목 제거

## Verification
README.md에 변경 반영 확인
"""
)
```

---

## 제약

- docs/ 외 파일은 수정하지 않는다
- 모든 파일 수정은 writer에 위임한다
- 코드 파일은 다루지 않는다 (문서만)
- `.claude/state/mode`에 기록하지 않는다 (planning/implement 루프와 독립)

---

## 검증

MUST: 아래 체크리스트를 모두 확인하라.

- [ ] 문서 파일이 정상 생성/수정/삭제되었는가?
- [ ] docs/README.md 인덱스가 최신 상태인가?
- [ ] 진행 안내가 각 단계마다 출력되었는가?

실패 시: 해당 Step으로 돌아가 수정 → 재검증.

---

## 주의사항

1. **Direct 모드에서는 대화 히스토리 적극 활용** — 문서화할 내용을 히스토리에서 추출
2. **Interview 모드에서는 질문 한 번에 하나씩** — AskUserQuestion으로 순차 진행
3. **위치 추천 시 기존 docs/ 구조 존중** — 임의로 새 폴더 생성하지 않음
4. **인덱스 업데이트는 항상 마지막에** — 파일 작업 완료 후 인덱스 갱신
