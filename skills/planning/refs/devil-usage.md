# Devil 호출 기준 (planning)

## 역할

Step 7에서 AC 전체를 검증한다.

## 검증 항목

- 모호한 AC 지적 ("잘 동작한다" → 구체화 필요)
- 테스트 불가능한 AC 표시
- 빠진 리스크/엣지케이스 지적
- AC 간 모순/중복 확인

## 호출 방법

```
Task(
  subagent_type="claude-automate:devil",
  prompt="AC 목록 검증: [AC 목록]. 모호한 AC, 테스트 불가능한 AC, 빠진 리스크를 지적해줘."
)
```

## 주의

- Step 7에서 한 번 호출 (습관적 반복 금지)
- Angel (Step 6) 이후에 호출 (확장 후 검증 순서)
