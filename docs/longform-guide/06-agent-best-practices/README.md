# Agent Best Practices (Agent 최적 실전 가이드)

## 개요 (Overview)

**Agent Best Practices**는 Claude와 같은 LLM 기반 시스템에서 **멀티 에이전트 아키텍처**를 효과적으로 설계하고 구현하는 방법을 다룹니다. 단순한 에이전트 사용을 넘어, **강력하고 신뢰할 수 있는 분산 AI 시스템**을 구축하는 핵심 원칙을 배웁니다.

### 왜 중요한가?

한 개의 Claude 인스턴스(또는 에이전트)로 모든 작업을 처리하려고 하면 여러 문제가 발생합니다:

- **컨텍스트 폭주 (Context Explosion)**: 모든 정보를 한 번에 처리하려다 보니 token 낭비
- **역할 혼재 (Role Confusion)**: 검색도 하고, 계획도 하고, 실행도 하다 보니 각 작업의 품질 저하
- **재사용 불가 (Non-Reusable)**: 특정 작업에 특화된 에이전트를 만들 수 없음
- **의사결정 부하**: 한 에이전트가 모든 선택을 해야 해서 오류 증가
- **확장 불가 (Not Scalable)**: 작업이 증가하면 품질이 급격히 떨어짐

Agent Best Practices는 이러한 문제들을 **구조적으로 해결**합니다:

1. **Sub-Agent Context Problem 해결** - 에이전트에 필요한 정보만 전달
2. **Iterative Retrieval Pattern** - 정보를 효율적으로 수집하는 방법
3. **Orchestrator 패턴** - 여러 에이전트를 조율하는 마스터 에이전트
4. **Agent Abstraction Tierlist** - 에이전트별 역할과 능력 명확화

---

## 4개 핵심 섹션

이 가이드에서는 Agent 설계와 구현의 주요 개념과 실전 패턴을 다룹니다:

### 1. [The Sub-Agent Context Problem](./01-sub-agent-context-problem.md)

**Sub-Agent Context Problem**은 멀티 에이전트 시스템의 가장 근본적인 문제입니다. 어떤 정보를 어느 에이전트에 전달할지 결정하는 것의 중요성을 다룹니다.

**주요 내용:**
- Sub-Agent의 정의와 역할 분담
- Context Bloat 문제 이해하기
- Over-Context vs Under-Context의 트레이드오프
- 정보 필터링 전략
- Sub-Agent 설계의 일반적 실수
- Context Budget 개념

**핵심 개념**: 에이전트에 필요하지 않은 정보를 보내는 것은 성능 저하와 오류의 주요 원인입니다

---

### 2. [Iterative Retrieval Pattern](./02-iterative-retrieval-pattern.md)

정보를 **한 번에 모두 수집**하려고 하지 말고, **필요에 따라 반복적으로 검색**하는 패턴입니다. 이는 token 효율성과 정확성을 동시에 높입니다.

**주요 내용:**
- Iterative Retrieval의 원리와 이점
- Search → Analyze → Refine 사이클
- 검색 쿼리 개선 전략
- Breadth-First vs Depth-First 검색
- 정보 누적 방식 (Information Accumulation)
- 중단 조건 (Stopping Criteria) 정의
- 실전 예제: 코드 분석, 문서 작성, 버그 수정

**핵심 개념**: 작은 검색으로 시작해서 필요시 확장하는 방식이 전체 효율을 최대화합니다

---

### 3. [Orchestrator with Sequential Phases](./03-orchestrator-sequential-phases.md)

**Orchestrator Pattern**은 여러 Sub-Agent를 조율하는 마스터 에이전트입니다. **Sequential Phases**(순차적 단계)로 복잡한 작업을 체계적으로 분해합니다.

**주요 내용:**
- Orchestrator의 역할과 책임
- Sequential Phase 설계 방법
- Phase 간 의존성 관리
- Context 전달 및 상태 유지
- Phase별 Sub-Agent 할당
- Error Handling & Recovery
- Phase 간 동기화 (Synchronization)
- 실전 예제: 멀티 에이전트 파이프라인 구축

**핵심 개념**: 복잡한 작업을 여러 Phase로 나누고, 각 Phase마다 전문가 에이전트를 배치하면 품질과 효율이 극대화됩니다

---

### 4. [Agent Abstraction Tierlist](./04-agent-abstraction-tierlist.md)

에이전트를 **능력과 역할**에 따라 분류하는 Tierlist입니다. 이를 통해 올바른 에이전트를 올바른 작업에 할당합니다.

**주요 내용:**
- Agent Tier 개념 (Tier 1, 2, 3, ...)
- Tier별 능력과 특성
- Tier별 비용과 성능 트레이드오프
- 에이전트 선택 기준 (Decision Matrix)
- Specialized Agent (특화된 에이전트) 설계
- Multi-Tier Architecture 패턴
- Tier 간 협력 방식
- 실전 사례: 뱅킹 시스템, 콘텐츠 생성, 코드 리뷰

**핵심 개념**: 일부 작업은 간단한 에이전트(Haiku)로, 복잡한 작업은 강력한 에이전트(Opus)로 처리하면 비용과 품질을 최적화할 수 있습니다

---

## 학습 경로

처음 Agent Best Practices를 배우는 경우:

1. **[The Sub-Agent Context Problem](./01-sub-agent-context-problem.md)** 부터 시작하여 멀티 에이전트 시스템의 근본 문제를 이해합니다
2. **[Iterative Retrieval Pattern](./02-iterative-retrieval-pattern.md)** 에서 정보 수집의 효율적인 방법을 배웁니다
3. **[Orchestrator with Sequential Phases](./03-orchestrator-sequential-phases.md)** 로 에이전트들을 조율하는 방법을 학습합니다
4. **[Agent Abstraction Tierlist](./04-agent-abstraction-tierlist.md)** 으로 에이전트 설계와 선택의 기준을 마스터합니다

---

## 주요 개념 요약

| 개념 | 설명 | 효과 |
|------|------|------|
| **Sub-Agent Context Problem** | 에이전트에 불필요한 정보를 보내는 문제 | token 낭비 50-70% 해결 |
| **Context Budget** | 각 에이전트에 할당하는 최대 정보량 | 예측 가능한 비용 관리 |
| **Iterative Retrieval** | 필요에 따라 반복적으로 정보 수집 | token 효율 30-50% 개선 |
| **Orchestrator Pattern** | 여러 에이전트를 조율하는 마스터 | 복잡한 작업을 체계적으로 처리 |
| **Sequential Phase** | 복잡한 작업을 순차적 단계로 분해 | 단계별 최적 전략 적용 가능 |
| **Agent Tierlist** | 능력과 역할에 따른 에이전트 분류 | 올바른 에이전트 선택 가능 |
| **Specialization** | 특정 작업에 특화된 에이전트 | 각 에이전트의 품질 50% 향상 |
| **Sub-Agent** | 특정 작업을 수행하는 전문 에이전트 | token 절약 + 품질 향상 |

---

## 실전 시나리오별 가이드

### 시나리오 1: 문서 작성 자동화

**상황**: 장편 기술 문서 작성이 필요

**문제**: 한 명의 에이전트가 검색, 분석, 작성을 모두 처리하면 token 낭비

**해결책**:
```
Orchestrator (마스터 에이전트)
├─ Phase 1: 검색 에이전트 (Retriever)
│  └─ 필요한 정보 수집 (반복적)
├─ Phase 2: 분석 에이전트 (Analyzer)
│  └─ 정보 분석 및 구조화
└─ Phase 3: 작성 에이전트 (Writer)
   └─ 문서 작성 및 포매팅
```

**효과**: token 40% 절약, 문서 품질 50% 향상

---

### 시나리오 2: 코드 리뷰 자동화

**상황**: 큰 프로젝트의 모든 코드를 검토해야 함

**문제**: 코드가 너무 많으면 한 에이전트가 모든 context를 처리할 수 없음

**해결책**:
```
Tier 1: Orchestrator (전체 조율)
├─ Tier 2: File Analyzer (파일 분석)
│  ├─ 파일별 리뷰 에이전트 (병렬)
│  └─ 부분별 검토 (함수, 클래스)
└─ Tier 3: Specific Reviewers (특화)
   ├─ Security Reviewer
   ├─ Performance Reviewer
   └─ Style Reviewer
```

**효과**: 100개 파일을 안전하게 검토, token 60% 절약

---

### 시나리오 3: 버그 수정 파이프라인

**상황**: 복잡한 버그를 분석하고 수정해야 함

**문제**: 버그 원인을 파악하기 위해 엄청난 양의 context가 필요

**해결책**:
```
Sequential Phase Orchestrator
├─ Phase 1: 버그 수집 (Bug Gatherer)
│  └─ 오류 메시지, 스택 트레이스 수집
├─ Phase 2: 반복적 검색 (Iterative Searcher)
│  └─ 필요한 코드 부분 찾기 (검색 → 분석 → 재검색)
├─ Phase 3: 원인 분석 (Root Cause Analyzer)
│  └─ 실제 원인 파악
└─ Phase 4: 수정 구현 (Fixer)
   └─ 해결책 구현 및 테스트
```

**효과**: 복잡한 버그를 체계적으로 해결, 성공률 80% 이상

---

## 빠른 적용 가이드

### 🎯 1단계: 현재 상황 분석

```
질문 1: 한 번에 처리해야 하는 정보량이 얼마인가?
├─ 10KB 미만 → 단일 에이전트 가능
├─ 10-100KB → Sub-Agent + Orchestrator 필요
└─ 100KB 이상 → Multi-Tier + Iterative Retrieval 필요

질문 2: 작업이 명확한 단계로 나뉘는가?
├─ YES → Sequential Phase Pattern 적용
└─ NO → Iterative Retrieval로 시작

질문 3: 작업의 복잡도는?
├─ 낮음 → Tier 1 에이전트 (Haiku)
├─ 중간 → Tier 2 에이전트 (Sonnet)
└─ 높음 → Tier 3 에이전트 (Opus)
```

### 🎯 2단계: 에이전트 구조 설계

```
1. Orchestrator 정의
   └─ 책임: 전체 흐름 조율
   └─ Model: Sonnet 또는 Opus

2. Sub-Agent 정의
   ├─ 각 Sub-Agent의 역할 명확화
   ├─ 각 Sub-Agent가 필요한 정보 정의
   └─ 각 Sub-Agent의 출력 형식 정의

3. Phase 정의
   ├─ Phase 순서 결정
   ├─ Phase 간 데이터 흐름 정의
   └─ 각 Phase별 Sub-Agent 할당
```

### 🎯 3단계: Sub-Agent Context 최적화

```
각 Sub-Agent마다:
1. ✅ 필요한 정보만 전달
   └─ "이 작업을 위해 꼭 필요한 정보는?"

2. ✅ Context Budget 설정
   └─ "이 에이전트에 최대 몇 token을 할당할 것인가?"

3. ✅ 불필요한 정보 제거
   └─ "이 정보가 없어도 작업을 완료할 수 있는가?"
```

### 🎯 4단계: Iterative Retrieval 구현

```
만약 정보 수집이 필요하다면:

1. 초기 쿼리로 시작
   └─ 범용적인 검색어로 기본 정보 수집

2. 결과 분석
   └─ "부족한 정보가 있는가?"

3. 정제된 쿼리로 재검색
   └─ "더 구체적인 정보가 필요한가?"

4. 축적된 정보로 진행
   └─ "충분히 알았는가? 계속해도 되나?"
```

---

## 주요 용어

| 용어 | 한글 | 영문 | 설명 |
|------|------|------|------|
| **Agent** | 에이전트 | Agent | AI 시스템에서 특정 작업을 수행하는 실행 단위 |
| **Sub-Agent** | 하위 에이전트 | Sub-Agent | 특정 작업에 특화된 에이전트 |
| **Orchestrator** | 조율자, 오케스트레이터 | Orchestrator | 여러 에이전트를 조율하는 마스터 에이전트 |
| **Context** | 컨텍스트 | Context | 에이전트에 전달하는 배경 정보 |
| **Context Problem** | 컨텍스트 문제 | Context Problem | 불필요한 정보 전달로 인한 성능 저하 |
| **Context Budget** | 컨텍스트 예산 | Context Budget | 각 에이전트에 할당하는 최대 정보량 |
| **Iterative Retrieval** | 반복적 검색 | Iterative Retrieval | 필요에 따라 여러 번 정보를 검색하는 방식 |
| **Sequential Phase** | 순차 단계 | Sequential Phase | 복잡한 작업을 순차적으로 처리하는 단계 |
| **Tierlist** | 계층 목록 | Tierlist | 능력에 따라 에이전트를 분류한 목록 |
| **Specialization** | 특화 | Specialization | 특정 작업에 최적화된 에이전트 |

---

## 관련 문서

### 같은 레벨의 다른 섹션

- [Context & Memory Management](../01-context-memory/README.md) - Context 효율성
- [Token Optimization](../02-token-optimization/README.md) - 토큰 최적화 및 Sub-Agent 아키텍처
- [Verification Loops & Evals](../03-verification-evals/README.md) - 에이전트 출력 검증
- [Parallelization](../04-parallelization/README.md) - 에이전트 병렬 실행
- [Groundwork](../05-groundwork/README.md) - 프로젝트 설계

### 예제

- [`examples/agent-configs/`](../examples/agent-configs/) - Agent 설정 예제
- [`examples/`](../examples/) - 전체 예제 모음

### 메인 가이드

- [Longform Guide Overview](../README.md) - 전체 가이드 소개
- [main README](../../README.md) - Claude Automate 프로젝트 개요

---

## 실전 체크리스트

Agent Best Practices를 적용하기 전에 확인하세요:

- [ ] **작업 분해**: 현재 작업을 여러 단계로 나눌 수 있는가?
- [ ] **에이전트 역할**: 각 에이전트의 역할이 명확한가?
- [ ] **Context 최적화**: 각 에이전트에 필요한 정보만 전달하는가?
- [ ] **Orchestrator 설계**: 마스터 에이전트의 책임이 명확한가?
- [ ] **Phase 설계**: Phase 간의 의존성이 명확한가?
- [ ] **Retrieval 전략**: 정보 수집이 반복적인 방식인가?
- [ ] **Tier 결정**: 각 에이전트의 Tier가 적절한가?
- [ ] **Error Handling**: 실패 시나리오에 대한 대비가 있는가?
- [ ] **테스트**: 작은 규모에서 먼저 검증했는가?

---

## 30일 마스터 로드맵

### Week 1: 개념 학습

- [The Sub-Agent Context Problem](./01-sub-agent-context-problem.md) 읽기
- 현재 프로젝트에서 Context 문제 식별
- Context Budget 개념 이해하기

### Week 2: Iterative Retrieval 적용

- [Iterative Retrieval Pattern](./02-iterative-retrieval-pattern.md) 읽기
- 정보 수집이 필요한 작업 찾기
- Breadth-First 검색으로 시작해보기

### Week 3: Orchestrator 패턴 구현

- [Orchestrator with Sequential Phases](./03-orchestrator-sequential-phases.md) 읽기
- 3-5개의 Sequential Phase로 작업 분해하기
- Sub-Agent 간 데이터 흐름 정의하기

### Week 4: Agent 선택과 최적화

- [Agent Abstraction Tierlist](./04-agent-abstraction-tierlist.md) 읽기
- 각 Sub-Agent의 Tier 결정하기
- 전체 시스템 성능 측정 및 최적화하기

**예상 효과**:
- Context 효율성 40-60% 향상
- Token 비용 30-50% 절감
- 에이전트 응답 시간 20-40% 단축
- 에이전트 출력 품질 50-70% 향상

---

## 다음 단계

Agent Best Practices를 완료했다면:

1. **[Parallelization](../04-parallelization/README.md)** - 여러 에이전트를 동시에 실행하는 방법
2. **[Verification Loops & Evals](../03-verification-evals/README.md)** - 에이전트 출력의 품질 검증
3. **[Token Optimization](../02-token-optimization/README.md)** - 에이전트 기반 시스템의 비용 최적화

---

**작성자**: claude-automate 문서팀
**마지막 수정**: 2026년 1월
**상태**: 작성 완료
**원본 출처**: Claude Code Agent Architecture Best Practices
