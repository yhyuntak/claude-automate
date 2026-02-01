# Plan Skill 테스트

> Plan skill과 planning agents 동작 검증

---

## User Story

개발자가 `/plan` 명령 또는 자동 감지 키워드로 계획 워크플로우를 시작하면, 5단계 플로우가 정상 동작한다.

## Acceptance Criteria

- [ ] `/plan` 명령으로 스킬 활성화 확인
- [ ] 키워드 자동 감지 테스트 ("설계", "계획", "어떻게 할까")
- [ ] 시나리오 분류 동작 확인 (new/bug/refactor/perf/migrate/other)
- [ ] AskUserQuestion 단일 질문 원칙 준수 확인
- [ ] Agent 호출 테스트 (explore, debugger, architect, profiler)
- [ ] Tier 선택 동작 확인 (-low, default, -high)
- [ ] 플랜 파일 생성 확인 (.claude/plans/{date}-{slug}.md)

## Dependencies

- 없음 (독립적으로 시작 가능)
- 참고: phase0-001 (아키텍처 우선 계획) 완료됨

---

## 테스트 시나리오

### 1. 기본 플로우 테스트
```
"JWT 인증 시스템 만들자"
→ 키워드 감지 ("만들자")
→ Scenario: New Feature
→ 체크리스트 생성
→ 질문 시작
→ 플랜 저장
```

### 2. 에이전트 호출 테스트
```
"/plan refactor"
→ Explore agent 호출 (구조 파악)
→ Architect agent 호출 (영향도 분석)
→ 결과 통합
```

### 3. Tier 선택 테스트
```
단순: "이 함수 어디 있어?" → explore-low
복잡: "전체 아키텍처 분석해줘" → explore-high
```

---

**Last Updated**: 2026-02-01
