---
description: 피드백 저장 (일반화)
---

[FEEDBACK MODE]

$ARGUMENTS

---

## Mission

사용자의 피드백을 대화 맥락에서 파악하여 구조화된 형태로 저장합니다.

---

## Step 1: 대화 맥락 파악

전체 대화 흐름에서:
- 유저가 뭘 말하려는 건지
- 어떤 기능/커맨드/에이전트에 대한 건지
- 직전 대화 관련? 전체 맥락?

---

## Step 2: 피드백 타입 판단

| 키워드/맥락 | type |
|------------|------|
| 제안, 별로, 필요없어 (wrap 관련) | `wrap` |
| 새로 만들어야, 있으면 좋겠다 | `idea` |
| 개선, 바꾸면, 이렇게 하면 | `improvement` |
| 에러, 안돼, 버그, 이상해 | `bug` |
| 그 외 | `general` |

---

## Step 3: context 구성

type에 맞게 유연하게 구성:

### wrap
```json
{
  "suggestions": [
    {"index": 1, "title": "...", "content": "..."},
    {"index": 2, "title": "...", "content": "..."}
  ],
  "target_indices": [2]
}
```

### idea
```json
{
  "description": "새 커맨드 /analyze 만들면 좋겠다",
  "related": "현재 분석 기능이 부족함"
}
```

### improvement
```json
{
  "target": "/wrap-v2",
  "current": "현재 동작 방식",
  "desired": "원하는 동작 방식"
}
```

### bug
```json
{
  "target": "wrap-reader",
  "symptom": "에러 메시지 또는 증상",
  "steps": "재현 방법 (있으면)"
}
```

### general
```json
{
  "note": "자유 형식 메모"
}
```

---

## Step 4: JSON 구성 및 저장

### 최종 포맷
```json
{
  "timestamp": "{현재시간 ISO}",
  "session_id": "{세션ID}",
  "project": "{현재 프로젝트명}",
  "user_feedback": "$ARGUMENTS",
  "type": "wrap|idea|improvement|bug|general",
  "context": {...},
  "tags": ["tag1", "tag2"]
}
```

### 저장 위치
`~/.claude/feedback/{YYYY-MM-DD}.jsonl`

### 저장 방법
```bash
# 1. 디렉토리 생성 (없으면)
mkdir -p ~/.claude/feedback

# 2. JSONL 파일에 append (한 줄로)
echo '{...json...}' >> ~/.claude/feedback/2026-01-20.jsonl
```

---

## Step 5: 확인 메시지

```
Feedback saved

타입: {type}
내용: {user_feedback 요약}
태그: {tags}
파일: ~/.claude/feedback/{date}.jsonl
```

---

## 예시

### 예시 1: wrap 제안 피드백
```
/feedback 2번 제안 README 업데이트 별로야
```
-> type: `wrap`, target_indices: `[2]`

### 예시 2: 새 기능 아이디어
```
/feedback 코드 분석하는 커맨드 새로 만들면 좋겠다
```
-> type: `idea`, tags: `["command", "new-feature"]`

### 예시 3: 개선 제안
```
/feedback wrap-v2가 좀 더 빠르게 동작하면 좋겠어
```
-> type: `improvement`, target: `wrap-v2`

### 예시 4: 버그 리포트
```
/feedback wrap-reader가 에러나
```
-> type: `bug`, target: `wrap-reader`

### 예시 5: 일반 메모
```
/feedback 나중에 세션 패턴 분석 기능 추가하기
```
-> type: `general`, tags: `["todo", "session-pattern"]`

---

## Tags 자동 생성

맥락에서 관련 키워드 추출:
- 커맨드 관련: `command`, `wrap`, `feedback` 등
- 에이전트 관련: `agent`, `reader`, `analyzer` 등
- 기능 관련: `new-feature`, `improvement`, `bug` 등
