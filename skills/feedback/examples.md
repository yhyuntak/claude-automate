# Feedback Examples

## 의도 감지 예시

| 사용자 발화 | 감지 의도 | 실행 |
|-------------|-----------|------|
| "이거 피드백으로 남겨둬" | write | `/write-feedback` |
| "버그 발견했어" | write (bug) | `/write-feedback` |
| "나중에 개선할 내용인데 기록해둬" | write | `/write-feedback` |
| "피드백 뭐 있어?" | check | `/check-feedback` |
| "2번 피드백 처리됐어" | done | status 변경 |
| "open된 피드백만 봐줘" | check open | `/check-feedback open` |

---

## 자연어 → 피드백 변환 예시

### Case 1: 대화 중 자연스럽게

```
사용자: wrap 기능 쓰다가 느낀건데, 결과가 좀 더 간결했으면 좋겠어.
       이거 피드백으로 남겨둬.

Claude: (feedback skill 자동 활성화)
        피드백을 저장합니다.

        타입: improvement
        내용: wrap 결과가 좀 더 간결했으면 좋겠다
        태그: wrap, ux

        저장 완료: ~/.claude/feedback/2026-01-22.jsonl
```

### Case 2: 명시적 커맨드

```
사용자: /feedback write 다크모드 추가해주세요

Claude: → /write-feedback 다크모드 추가해주세요

        타입: idea
        내용: 다크모드 추가해주세요
        태그: new-feature, ui
```

### Case 3: 피드백 확인

```
사용자: 피드백 목록 좀 볼래

Claude: (feedback skill 자동 활성화)
        → /check-feedback

        | # | 상태 | 프로젝트 | 타입 | 내용 |
        |---|------|----------|------|------|
        | 1 | 🔴 | my-app | 💡 | 다크모드 추가 |
        | 2 | 🔴 | claude-automate | ✨ | wrap 간결하게 |

        총 2개 (🔴 open: 2)
```

### Case 4: 피드백 완료 처리

```
사용자: 1번 피드백 처리됐어

Claude: (feedback skill 자동 활성화)

        Feedback #1 marked as done
        내용: 다크모드 추가
```

---

## 저장되는 JSON 예시

### idea 타입

```json
{
  "timestamp": "2026-01-22T23:30:00+09:00",
  "session_id": "abc-123",
  "project": "my-app",
  "user_feedback": "다크모드 추가해주세요",
  "type": "idea",
  "status": "open",
  "context": {
    "description": "앱에 다크모드 테마 추가",
    "related": "현재 라이트모드만 지원"
  },
  "tags": ["new-feature", "ui", "theme"]
}
```

### bug 타입

```json
{
  "timestamp": "2026-01-22T23:35:00+09:00",
  "session_id": "abc-123",
  "project": "claude-automate",
  "user_feedback": "훅이 작동 안 해",
  "type": "bug",
  "status": "open",
  "context": {
    "target": "feedback-hint.sh",
    "symptom": "피드백 키워드 감지 안 됨",
    "steps": "1. 피드백 키워드 입력 2. 힌트 미표시"
  },
  "tags": ["bug", "hook"]
}
```

### improvement 타입

```json
{
  "timestamp": "2026-01-22T23:40:00+09:00",
  "session_id": "abc-123",
  "project": "claude-automate",
  "user_feedback": "wrap 결과가 너무 길어",
  "type": "improvement",
  "status": "open",
  "context": {
    "target": "/wrap",
    "current": "상세한 분석 결과 출력",
    "desired": "간결한 요약 출력"
  },
  "tags": ["wrap", "ux", "improvement"]
}
```
