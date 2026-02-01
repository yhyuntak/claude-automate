# 아키텍처 우선 계획 단계

> 코드 작성 전 아키텍처와 설계를 먼저 확정하는 워크플로우

---

## User Story

개발자가 새로운 기능을 구현할 때, 코드부터 작성하는 대신 아키텍처와 설계를 먼저 논의하고 확정한 후 구현으로 넘어간다.

## Acceptance Criteria

- [x] 계획 단계 강제 모드 (`/plan` 명령) → `skills/plan/SKILL.md`
- [x] 아키텍처 템플릿 (어떤 내용을 정해야 하는지) → `skills/plan/schema.md`
- [x] 계획 승인 워크플로우 (사람이 OK 해야 진행) → SKILL.md Step 4-5
- [x] 계획 변경 추적 (왜 바뀌었는지 기록) → schema.md Change History

## 비기능 요구사항

- 유연성: 작은 변경은 계획 스킵 가능
- 강제성: 큰 변경은 계획 필수
- 추적성: 결정의 이유 기록

## Dependencies

- 없음 (독립적으로 시작 가능)

---

## 구현 노트 (작업 중 추가)

### Peter Steinberger 접근법

> "계획에 80%의 시간을 투자하고, 실행에 20%"

- Opus로 아키텍처 논의
- 결정 사항 문서화
- 실행은 Sonnet/Haiku에게 위임

### 계획 템플릿 (초안)

```markdown
# Feature Plan: {feature-name}

## 문제 정의
{무엇을 해결하려는가}

## 제약 조건
- {constraint 1}
- {constraint 2}

## 설계 옵션
### 옵션 A: {name}
- 장점: ...
- 단점: ...

### 옵션 B: {name}
- 장점: ...
- 단점: ...

## 선택한 설계
{옵션 X를 선택한 이유}

## 구현 단계
1. [ ] {step 1}
2. [ ] {step 2}

## 승인
- [ ] 아키텍처 승인
- [ ] 구현 시작 가능
```

### 기술 결정

1. **Skill vs Rule**: Plan은 Skill로 구현 (키워드 감지 시 자동 활성화)
2. **Agent 구조**: Tier 분리 (Haiku/Sonnet/Opus)
3. **플랜 저장 위치**: `.claude/plans/{date}-{slug}.md`
4. **에이전트 종류**: Explore, Debugger, Architect, Profiler (각 Tier별)

### 구현된 파일들

**Skills:**
- `skills/plan/SKILL.md` - 메인 스킬 정의
- `skills/plan/schema.md` - 플랜 템플릿, 체크리스트 예시
- `skills/plan/references/scenarios.md` - 시나리오별 플로우
- `skills/plan/references/agents.md` - 에이전트 호출 가이드

**Agents:**
- `agents/explore.md`, `explore-low.md`, `explore-high.md`
- `agents/debugger.md`, `debugger-low.md`
- `agents/architect.md`, `architect-low.md`
- `agents/profiler.md`, `profiler-low.md`

### 이슈/해결

1. **기타 시나리오 필요**: 5개 시나리오에 맞지 않는 경우 → Scenario 6: Other 추가
2. **변경 추적 누락**: Acceptance Criteria에 있었지만 초안에 없음 → Change History 섹션 추가

---

**Last Updated**: 2026-02-01
