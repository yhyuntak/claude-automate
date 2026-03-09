---
name: multi-review
description: |
  3개 LLM(Claude, Gemini, Codex)에게 동시에 리뷰를 요청하고 결과를 비교하는 스킬.
  "multi review", "멀티 리뷰", "3모델 비교", "여러 모델한테 물어봐" 같은 요청 시 발동.
argument-hint: "[리뷰 대상 설명]"
---

# Multi-Review

> 3개 LLM에게 동시 리뷰를 요청하고, 각 모델의 관점을 비교 종합한다.

## Step 1: 리뷰 대상 확인

사용자의 요청에서 리뷰 대상을 파악한다.

- 인자가 있으면 → 그대로 사용
- 인자가 없으면 → AskUserQuestion으로 리뷰 대상 확인

```json
{
  "question": "어떤 코드/설계를 리뷰할까요?",
  "header": "리뷰 대상",
  "multiSelect": false,
  "options": [
    { "label": "현재 작업 중인 코드", "description": "최근 변경된 파일들을 대상으로 리뷰" },
    { "label": "특정 파일/폴더", "description": "파일 경로를 직접 지정" },
    { "label": "설계/아키텍처", "description": "전체 구조나 설계 방향 리뷰" }
  ]
}
```

## Step 2: 3모델 동시 호출

3개 Task()를 **병렬로** dispatch한다.

### Claude (explore-high)

```
Task(
  subagent_type="claude-automate:explore-high",
  prompt="{프로젝트 경로}의 {리뷰 대상}을 분석해줘. 구조적 관점에서 문제점과 개선 방향을 제안해줘. 우선순위 매트릭스도 포함해줘."
)
```

### Gemini (gemini-advisor)

```
Task(
  subagent_type="claude-automate:gemini-advisor",
  prompt="{리뷰 대상}을 분석해줘. UI/UX 관점에서 문제점과 개선 방향을 제안해줘."
)
```

### Codex (codex-advisor)

```
Task(
  subagent_type="claude-automate:codex-advisor",
  prompt="{리뷰 대상}을 분석해줘. 코드 품질, 버그, 보안 관점에서 문제점과 개선 방향을 제안해줘."
)
```

MUST: 3개를 **동시에** 호출한다. 순차 호출 금지.

## Step 3: 실패 처리

각 Task() 결과를 확인한다.

| 상황 | 처리 |
|------|------|
| 3개 모두 성공 | Step 4로 |
| 1~2개 실패 | 성공한 모델 결과만 사용 + "⚠️ {모델명} 응답 실패" 표시 |
| 3개 모두 실패 | 에러 메시지 출력 후 종료 |

## Step 4: 결과 비교 종합

3모델 응답을 다음 포맷으로 종합한다:

```markdown
## Multi-Review 결과

### 모델별 관점

| | Claude | Gemini | Codex |
|---|---|---|---|
| **관점** | 구조/아키텍처 | UI/디자인 | 코드/버그 |
| **핵심 발견** | {요약} | {요약} | {요약} |
| **강점** | {이 모델만의 관점} | {이 모델만의 관점} | {이 모델만의 관점} |

### 공통 발견 (2모델 이상 동의)
- {공통 이슈 1}
- {공통 이슈 2}

### 고유 발견 (1모델만 발견)
- **Claude**: {고유 발견}
- **Gemini**: {고유 발견}
- **Codex**: {고유 발견}

### 종합 우선순위
| 순위 | 이슈 | 발견 모델 | 난이도 | 임팩트 |
|------|------|----------|--------|--------|
| 1 | ... | Claude+Codex | 낮음 | 높음 |
| 2 | ... | Gemini | 중간 | 중간 |
```

## 검증

- [ ] 3개 Task()가 병렬로 dispatch되었는가?
- [ ] 실패한 모델이 있으면 표시되었는가?
- [ ] 비교 테이블이 출력되었는가?
- [ ] 공통/고유 발견이 분류되었는가?

실패 시: 해당 Step으로 돌아가 재처리.
