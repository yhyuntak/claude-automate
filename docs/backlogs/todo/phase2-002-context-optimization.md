# /wrap, /start-work 컨텍스트 최적화

> 에이전트 활용으로 메인 컨텍스트 오염 방지

---

## User Story

/wrap, /start-work 실행 시 세부 작업은 에이전트에게 위임하여, 메인 컨텍스트가 오염되지 않고 핵심 대화만 유지된다.

## Acceptance Criteria

- [ ] /wrap: 분석/업데이트 작업을 에이전트에게 위임
- [ ] /start-work: brain 로드/초기화를 에이전트에게 위임
- [ ] 메인은 결과만 받아서 표시
- [ ] 컨텍스트 사용량 측정 (Before/After 비교)

## 비기능 요구사항

- 토큰 효율: 메인 컨텍스트 사용량 50% 이상 감소 목표
- 응답 속도: 에이전트 호출로 인한 지연 최소화

## Dependencies

- phase2-001-core-operations 완료 필요 (Read/Analyze/Write 패턴 정립 후)

---

## 배경

현재 /wrap, /start-work는 메인에서 직접 파일 읽기/분석을 수행.
이로 인해 메인 컨텍스트가 오염되어 핵심 대화 흐름이 방해받음.

핵심 동작(Read/Analyze/Write)이 정립되면,
이를 에이전트로 위임하여 메인은 결과만 받는 구조로 개선.

---

## 구조 변경

```
[Before]
/wrap 실행 → 메인이 직접 diff 읽기, 분석, 업데이트

[After]
/wrap 실행 → 에이전트 호출 → 결과만 받아서 표시
             └─ 세부 작업은 에이전트 컨텍스트에서
```

---

**Last Updated**: 2026-02-01
