---
name: brainstorm
description: 아이디어를 구체적인 요구사항으로 발전. "brainstorm", "브레인스토밍", "아이디어", "뭘 만들지" 키워드로 자동 활성화
argument-hint: "[idea or topic]"
---

# /brainstorm

> 아이디어를 구체적인 요구사항으로 발전

$ARGUMENTS

---

## 목적

**brainstorm vs planning 구분:**

| 단계 | 목적 | Brain 필요 |
|------|------|-----------|
| brainstorm | **뭘** 만들지 구체화 | ❌ |
| planning | **어떻게** 만들지 계획 | ✅ |

---

## 제약

- **Read-only**: 파일 수정 불가
- 대화로만 아이디어 구체화
- 코드 작성 금지

---

## 역할

1. 모호한 아이디어 → 구체적 요구사항
2. 범위 정의
3. 제약 조건 파악
4. 대안 탐색

---

## 실행 프로토콜

### Phase 1: 아이디어 청취

사용자의 초기 아이디어 파악:

```
- 무엇을 하고 싶은가?
- 왜 필요한가?
- 누가 사용하는가?
```

### Phase 2: 코드베이스 탐색 (Read-only)

기존 코드 구조 파악:

```
- 관련 기능이 이미 있는가?
- 어디에 위치할 수 있는가?
- 기존 패턴과 어떻게 맞는가?
```

### Phase 3: 명확화 질문

AskUserQuestion으로 구체화:

```
- 범위 관련 질문
- 우선순위 관련 질문
- 제약 조건 관련 질문
```

### Phase 3.5: 생각 확장 (선택적)

사용자가 막히거나 더 많은 아이디어가 필요할 때:

```json
{
  "questions": [{
    "question": "더 많은 아이디어와 시각이 필요하신가요?",
    "header": "Angel 에이전트를 호출하여 다양한 관점을 확인할 수 있습니다",
    "multiSelect": false,
    "options": [
      {
        "label": "예, angel 에이전트 호출",
        "description": "Opus가 다양한 시각으로 생각을 확장해줍니다"
      },
      {
        "label": "아니오, 계속 진행",
        "description": "현재 논의로 충분합니다"
      }
    ]
  }]
}
```

**angel 호출 시**:
```
Task(
  subagent_type="claude-automate:angel",
  prompt="""
## Context
{현재까지 논의한 내용}

## Question
{사용자가 고민하는 부분}

## Goal
다양한 시각으로 생각을 확장하고 새로운 아이디어 제시
"""
)
```

### Phase 4: 구체화된 요구사항 제시

정리된 형식으로 출력:

```markdown
## 요구사항 정리

### Context (배경)
- {현재 상황/문제}
- {이게 없으면 어떤 문제가 발생하는가}

### What (무엇을)
- {핵심 기능}
- {사용자 시나리오}

### Why (왜)
- {비즈니스 목표}
- {사용자 가치}

### Success Criteria (성공 기준)
- [ ] {완료 판단 기준 1}
- [ ] {완료 판단 기준 2}

### Scope (범위)
- ✅ In: {이번에 할 것}
- ❌ Out: {안 할 것}

### Constraints (제약)
- {기술/시간/리소스 제약}

### Open Questions (미결정)
- {구현 중 결정할 것}

### 다음 단계
→ /planning으로 구현 계획 수립 권장
```

---

## 출력 형식

```markdown
# Brainstorm: {Topic}

## 논의 요약
{대화에서 파악한 내용}

## 요구사항 정리

### Context (배경)
- {현재 상황/문제}
- {이게 없으면 어떤 문제가 발생하는가}

### What (무엇을)
- {핵심 기능}
- {사용자 시나리오}

### Why (왜)
- {비즈니스 목표}
- {사용자 가치}

### Success Criteria (성공 기준)
- [ ] {완료 판단 기준 1}
- [ ] {완료 판단 기준 2}

### Scope (범위)
- ✅ In: {이번에 할 것}
- ❌ Out: {안 할 것}

### Constraints (제약)
- {기술/시간/리소스 제약}

### Open Questions (미결정)
- {구현 중 결정할 것}

## 다음 단계
→ `/planning {feature}` 실행하여 구현 계획 수립
```

---

## 주의사항

1. **Read-only 엄수**: 파일 수정 절대 금지
2. **Brain 참조 안 함**: brainstorm 단계에서는 brain 불필요
3. **대화 중심**: 질문과 답변으로 구체화
4. **다음 단계 안내**: planning으로 연결

---

**Last Updated**: 2026-02-05
