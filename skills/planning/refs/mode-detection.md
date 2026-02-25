# 모드 감지 기준

## Direct 모드 (구체적)

다음 중 하나라도 해당하면 Direct:

- 특정 파일명이 언급됨 ("UserService.ts를 수정해")
- 구체적 기능명이 있음 ("로그아웃 기능 추가")
- 명확한 동작이 정의됨 ("버튼 클릭 시 세션 종료")
- 이전 대화에서 이미 충분히 구체화됨

## Interview 모드 (모호)

다음 중 하나라도 해당하면 Interview:

- 모호한 동사 사용 ("개선", "리팩터링", "최적화")
- 3개 이상 영역에 걸침 ("전반적으로 고치고 싶어")
- 구체적 파일/기능 언급 없음
- "뭔가 하고 싶은데" 류의 표현

## 인자 없음

대화 히스토리를 분석:
- 이전 대화에서 구체적 아이디어가 나옴 → Direct
- 이전 대화가 모호하거나 없음 → Interview
- 판단 불가 → AskUserQuestion

```json
{
  "question": "어떤 작업을 계획할까요?",
  "header": "Planning",
  "multiSelect": false,
  "options": [
    { "label": "이전 대화 이어가기", "description": "방금 논의한 내용을 plan으로" },
    { "label": "새로운 작업", "description": "새로운 기능/개선 계획" }
  ]
}
```
