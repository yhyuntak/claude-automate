---
name: planning
description: |
  구현 계획을 수립한다. 모드 자동 감지, 코드베이스 탐색, AC 추출, 검증을 포함.
  "planning", "계획", "플래닝", "어떻게 만들지" 키워드로 활성화.
argument-hint: "[feature or topic]"
allowed-tools:
  - Read
  - Glob
  - Grep
  - LSP
  - Task
  - AskUserQuestion
---

# /planning

$ARGUMENTS

---

## 진행 안내 규칙

각 단계 진입 시 사용자에게 현재 상황을 안내한다.

- 진입: "{Direct/Interview} 모드로 진입합니다."
- 각 단계: "[N/9] {단계명} 실행합니다."
- 결과: 각 단계 완료 후 요약 한 줄

## Step 1: 모드 감지

MUST: `.claude/state/mode`에 `planning`을 기록하라. (`echo planning > .claude/state/mode`)

MUST: refs/mode-detection.md를 읽고 판별 기준을 확인하라.

인자와 대화 히스토리를 분석하여 모드를 결정한다.

| 조건 | 모드 |
|------|------|
| 구체적 요구사항 있음 (파일명, 기능명, 명확한 동작) | **Direct** → Step 3 |
| 모호한 요청 (개선, 리팩터링, 뭔가 하고 싶다) | **Interview** → Step 2 |
| 판단 불가 | AskUserQuestion으로 확인 |

모드 결정 후 사용자에게 안내한다:
- Direct: "**Direct 모드**로 진입합니다. 구체적 요구사항을 기반으로 계획을 수립합니다."
- Interview: "**Interview 모드**로 진입합니다. 아이디어를 구체화하기 위해 질문합니다."

## Step 2: Interview (모호할 때만)

사용자의 아이디어를 구체화한다.

규칙:
- 질문은 **한 번에 하나씩** (AskUserQuestion 사용)
- 코드베이스에서 확인 가능한 것은 **묻지 말고 explore로 먼저 파악**
- 각 질문은 이전 답변을 기반으로 발전
- 충분히 구체화되면 → Step 3으로 진행

질문 분류:
| 유형 | 처리 |
|------|------|
| 코드베이스 사실 ("어떤 패턴 쓰고 있어?") | explore 에이전트로 확인 → 묻지 않음 |
| 사용자 선호 ("어떤 방식이 좋아?") | AskUserQuestion |
| 스코프 결정 ("이것도 포함할까?") | AskUserQuestion |
| 기술 제약 ("성능 요구사항?") | AskUserQuestion |

## Step 3: Brain 읽기

`.claude/brain.md` 인덱스를 읽는다.

- brain.md 존재 → 관련 파일 확인 (code-map, patterns, decisions)
- brain.md 없음 → 스킵, Step 4에서 전체 탐색

이미 brain에 있는 정보는 Step 4에서 탐색 생략.

## Step 4: 코드베이스 탐색

explore 에이전트로 구현에 필요한 코드 구조를 파악한다.

```
Task(
  subagent_type="claude-automate:explore",
  prompt="[구현 대상] 관련 코드 구조, 패턴, 의존성 파악"
)
```

탐색 대상:
- 수정/확장할 기존 코드
- 관련 패턴 및 컨벤션
- 의존성 및 영향 범위

탐색 결과 중 brain에 기록할 것이 있으면 메모 (Step 9에서 plan에 포함).

## Step 5: AC 초안 추출

두 소스에서 AC를 추출한다:

| 소스 | AC 유형 | 예시 |
|------|---------|------|
| 대화/Interview | 사용자 관점 | "로그아웃하면 세션 끊김" |
| Step 4 탐색 결과 | 기술 관점 | "refresh token도 무효화 필요" |

AC/TC 작성 기준:
- AC = 작업 항목 (뭘 할지)
- TC = 검증 기준 (어떻게 확인할지, AC 하위 항목)
- TC는 "통과/실패" 판정 가능한 문장
- 하나의 TC = 하나의 검증 포인트
- 테스트 불가한 AC는 "(TC 없음)" 표기
- 모호한 표현 금지 ("잘 동작한다" → "200 응답 반환")

## Step 6: Angel 확장

Angel 에이전트로 AC를 확장한다.

```
Task(
  subagent_type="claude-automate:angel",
  prompt="현재 AC/TC 목록: [AC/TC 목록]. AC 레벨에서 빠진 작업 항목, TC 레벨에서 빠진 엣지케이스/검증 조건이 있는지 확인해줘."
)
```

Angel이 제안한 추가 AC를 초안에 병합한다.

## Step 7: Devil 검증

MUST: refs/devil-usage.md를 읽고 호출 기준을 확인하라.

Devil 에이전트로 AC 전체를 검증한다.

```
Task(
  subagent_type="claude-automate:devil",
  prompt="AC/TC 목록 검증: [AC/TC 목록]. 모호한 AC, 테스트 불가능한 TC, 빠진 리스크, AC-TC 불일치를 지적해줘."
)
```

Devil 피드백 기반으로 AC를 수정한다:
- 모호한 AC → 구체화
- 테스트 불가 AC → (테스트 불가) 표시
- 빠진 리스크 → AC 추가

## Step 8: 사용자 확인

AskUserQuestion으로 최종 AC 목록을 제시한다.

```json
{
  "question": "AC 목록을 확인해주세요. 추가/수정/삭제할 것이 있나요?",
  "header": "AC 확인",
  "multiSelect": true,
  "options": [
    { "label": "이대로 진행", "description": "AC 목록 확정, plan 파일 생성" },
    { "label": "AC 수정 필요", "description": "AC를 수정/추가/삭제하고 싶다" },
    { "label": "처음부터 다시", "description": "방향을 바꾸고 싶다" }
  ]
}
```

- "이대로 진행" → Step 9
- "AC 수정 필요" → 수정 후 Step 8 반복
- "처음부터 다시" → Step 1로

## Step 9: plan 파일 생성

MUST: refs/plan-file.md를 읽고 파일 구조를 확인하라.

writer 에이전트에게 plan 파일 작성을 위임한다.

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
plan 파일 생성

## Target
.claude/plans/{YYYY-MM-DD}-{slug}.md

## Content
{아래 내용을 모두 포함하여 plan 파일을 Write하라}

- 요구사항 (Context/What/Why/Scope)
- Brain 업데이트 (Step 4에서 발견한 기록할 것들)
- AC 목록 (Step 8에서 확정된 것)
- 구현 순서 (Brain 업데이트 → AC 순서)
- 테스트 계획

## Format
refs/plan-file.md 구조를 따를 것
"""
)
```

생성 후 MUST: AskUserQuestion으로 다음 행동을 확인하라.

```json
{
  "question": "plan 파일이 생성되었습니다. 다음에 무엇을 할까요?",
  "header": "다음 행동",
  "multiSelect": true,
  "options": [
    { "label": "/implement 실행 (Recommended)", "description": "plan 기반으로 바로 구현 시작" },
    { "label": "plan 수정", "description": "plan 파일을 다시 검토/수정" },
    { "label": "나중에", "description": "지금은 구현하지 않음" }
  ]
}
```

---

## 제약

- plan 파일 외 파일 수정 금지
- 코드 작성 금지 (구현은 /implement에서)
- brain 파일 수정 금지 (plan에 기록만, implement에서 실행)

---

## 검증

MUST: 아래 체크리스트를 모두 확인하라.

- [ ] 모드 감지가 정확한가? (Direct/Interview)
- [ ] brain을 읽었는가? (없으면 "없음" 명시)
- [ ] explore로 코드베이스를 탐색했는가?
- [ ] Angel 확장을 실행했는가?
- [ ] Devil 검증을 실행했는가?
- [ ] 사용자 확인을 받았는가?
- [ ] plan 파일에 필수 섹션이 모두 있는가?

실패 시: 해당 Step으로 돌아가 수정 → 재검증.

---

## 주의사항

1. **"자유롭게" 금지** — 반드시 Step 순서대로
2. **explore 먼저, 질문 나중** — 코드에서 알 수 있는 건 묻지 마라
3. **구현은 하지 않는다** — 계획만
4. **brain은 plan에 기록만** — 직접 수정하지 않는다
