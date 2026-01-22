# Feedback JSON Schema

## 필수 필드

| 필드 | 타입 | 설명 |
|------|------|------|
| timestamp | string | ISO 8601 형식 (예: 2026-01-22T23:30:00+09:00) |
| session_id | string | 현재 세션 ID |
| project | string | 현재 프로젝트명 |
| user_feedback | string | 피드백 원문 |
| type | enum | wrap, idea, improvement, bug, general |
| status | enum | open, done |
| tags | string[] | 자동 생성 태그 |

## 선택 필드

| 필드 | 타입 | 설명 |
|------|------|------|
| context | object | 타입별 추가 정보 |

---

## Type 판단 기준

| 키워드/맥락 | type |
|-------------|------|
| wrap 관련 제안, 별로, 필요없어 | `wrap` |
| 새로 만들어야, 있으면 좋겠다 | `idea` |
| 개선, 바꾸면, 이렇게 하면 | `improvement` |
| 에러, 안돼, 버그, 이상해 | `bug` |
| 그 외 | `general` |

---

## Context 구조 (타입별)

### wrap
```json
{
  "suggestions": [
    {"index": 1, "title": "...", "content": "..."}
  ],
  "target_indices": [2]
}
```

### idea
```json
{
  "description": "새 기능 설명",
  "related": "관련 정보"
}
```

### improvement
```json
{
  "target": "대상 커맨드/기능",
  "current": "현재 동작",
  "desired": "원하는 동작"
}
```

### bug
```json
{
  "target": "대상",
  "symptom": "증상",
  "steps": "재현 방법"
}
```

### general
```json
{
  "note": "자유 형식 메모"
}
```

---

## Tags 자동 생성

맥락에서 키워드 추출:
- 커맨드: `command`, `wrap`, `feedback`, `session`
- 에이전트: `agent`, `reader`, `analyzer`
- 기능: `new-feature`, `improvement`, `bug`, `ux`

---

## 전체 예시

```json
{
  "timestamp": "2026-01-22T23:30:00+09:00",
  "session_id": "abc-123-def",
  "project": "claude-automate",
  "user_feedback": "/check-feedback에 설명 컬럼 추가해주세요",
  "type": "improvement",
  "status": "open",
  "context": {
    "target": "/check-feedback",
    "current": "# 상태 날짜 프로젝트 타입 내용 태그",
    "desired": "# 상태 날짜 프로젝트 타입 내용 설명 태그"
  },
  "tags": ["command", "check-feedback", "ux"]
}
```
