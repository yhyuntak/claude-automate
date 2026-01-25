# Interaction Rule

Claude Code와 사용자 간 상호작용 규칙입니다.

## AskUserQuestion 사용 원칙

### 필수: multiSelect 기본값

```json
{
  "multiSelect": true
}
```

**모든 질문에서 `multiSelect: true`를 기본값으로 사용해야 합니다.**

### 이유

| multiSelect: false | multiSelect: true |
|-------------------|-------------------|
| 단일 선택만 가능 | 단일 선택 **또는** 복수 선택 가능 |
| 제한적 | 유연함 |
| 사용자가 여러 옵션 원할 때 재질문 필요 | 한 번에 해결 |

**multiSelect: true는 multiSelect: false의 기능을 포함합니다.**
- 사용자가 원하면 1개만 선택 가능
- 사용자가 원하면 여러 개 선택 가능
- 더 나은 UX를 제공

### 예외 상황

다음 경우에**만** `multiSelect: false` 사용:

1. **상호 배타적 선택**: 논리적으로 하나만 선택 가능한 경우
   - 예: "어떤 브랜치를 base로 할까요?" (main vs develop)
   - 예: "어떤 모델을 사용할까요?" (haiku vs sonnet vs opus)

2. **단계적 선택**: 이전 선택에 따라 다음 질문이 달라지는 경우
   - 예: "어떤 방식으로 진행할까요?" → 선택에 따라 후속 질문 변경

### 체크리스트

AskUserQuestion 사용 전 확인:

- [ ] `multiSelect: true` 설정했는가?
- [ ] 질문이 상호 배타적인가? (No → multiSelect: true 유지)
- [ ] 사용자가 여러 옵션을 선택할 가능성이 있는가? (Yes → multiSelect: true 유지)

### 좋은 예시

```json
{
  "questions": [{
    "question": "어떤 기능을 추가할까요?",
    "header": "기능 선택",
    "multiSelect": true,
    "options": [
      {
        "label": "인증 시스템",
        "description": "JWT 기반 사용자 인증"
      },
      {
        "label": "파일 업로드",
        "description": "S3 연동 파일 업로드"
      },
      {
        "label": "알림 시스템",
        "description": "이메일/SMS 알림"
      }
    ]
  }]
}
```

사용자는 필요한 만큼 선택 가능 (1개도 OK, 3개도 OK)

### 나쁜 예시

```json
{
  "multiSelect": false  // ❌ 기본값으로 사용 금지
}
```

사용자가 여러 기능을 원해도 하나만 선택 가능 → 나쁜 UX

## 적용 범위

- ✅ 모든 commands
- ✅ 모든 skills
- ✅ 모든 agents
- ✅ Claude Code 대화 중 질문

## 목적

**타이핑 최소화, UX 최대화** - 사용자가 긴 텍스트를 입력하지 않고 클릭만으로 응답 가능하게 함.
