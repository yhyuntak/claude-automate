---
name: feedback
description: 사용자가 피드백, 개선점, 버그, 아이디어를 남기고 싶어할 때 사용. "피드백 남기고 싶어", "이거 기록해둬", "나중에 개선할 내용", "버그 발견" 등의 의도 감지 시 자동 활성화
argument-hint: "[write|check|done] [args]"
---

# Feedback System

$ARGUMENTS

사용자의 피드백 의도를 감지하면 이 skill이 활성화됩니다.

---

## 의도 판단

| 사용자 의도 | 실행할 커맨드 |
|-------------|---------------|
| 피드백 저장 ("남겨둬", "기록해", "피드백 추가") | `/write-feedback` |
| 피드백 확인 ("뭐 있어?", "목록", "체크") | `/check-feedback` |
| 피드백 완료 ("done", "완료", "처리됨") | 직접 status 변경 |

---

## 피드백 저장 흐름

1. 대화 맥락에서 피드백 내용 파악
2. schema.md 참고하여 JSON 구성
3. `/write-feedback` 실행 또는 직접 저장

**저장 경로**: `~/.claude/feedback/{YYYY-MM-DD}.jsonl`

---

## 피드백 확인 흐름

`/check-feedback` 실행하여 목록 표시

옵션:
- `open` / `done` - 상태별 필터
- `today` - 오늘만
- `bug` / `idea` / `improvement` - 타입별

---

## 피드백 완료 처리 (done)

`/feedback done 3` 또는 "3번 피드백 처리됐어"

1. `~/.claude/feedback/` 폴더의 모든 .jsonl 파일 읽기
2. 전체 피드백에 순번 부여 (최신순)
3. 해당 번호 피드백의 `"status": "open"` → `"status": "done"` 변경
4. 파일 다시 저장

---

## 명시적 호출

라우터 방식:
- `/feedback write <내용>`
- `/feedback check [옵션]`
- `/feedback done <번호>`

직접 호출:
- `/write-feedback <내용>`
- `/check-feedback [옵션]`

---

## 참고 파일

- 스키마: schema.md
- 예시: examples.md
