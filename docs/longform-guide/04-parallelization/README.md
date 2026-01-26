# Parallelization (병렬화)

## 개요 (Overview)

**Parallelization**은 Claude와의 작업을 **동시에 여러 개 진행**하여 전체 실행 시간을 대폭 단축하는 전략입니다. 지능적인 병렬화는 Claude Automate의 성능을 극대화하는 핵심 기술입니다.

### 왜 중요한가?

많은 개발 작업들은 **서로 독립적**입니다:

- **문제**: 순차 처리로 작업하면 이전 작업이 완료될 때까지 다음 작업을 기다려야 합니다
- **기회**: 독립적인 작업들을 동시에 실행하면 전체 시간을 획기적으로 단축할 수 있습니다
- **복잡성**: 하지만 병렬화를 잘못하면 race condition, 리소스 부족, 동기화 문제가 발생합니다

Parallelization은 이러한 과제들을 해결합니다:

1. **Task 의존성 분석** - 어떤 작업이 병렬화 가능한지 판단
2. **지능적 분산** - 여러 Agent를 동시에 실행
3. **Cascade Pattern** - 단계별 의존성을 효율적으로 처리
4. **리소스 관리** - 동시성 제한 준수
5. **동기화 전략** - 병렬 작업의 결과를 안전하게 조합

---

## 4개 핵심 서브섹션

이 섹션에서는 Parallelization의 주요 개념과 실제 적용 방법을 다룹니다:

### 1. [My Preferred Pattern](./01-my-preferred-pattern.md)
실전에서 가장 효율적이고 안정적인 병렬화 패턴을 설명합니다.

- Task 의존성 표현 방법
- 병렬화 가능한 작업 식별
- Parallel agent 호출 패턴
- 결과 수집 및 검증
- 실제 사례 및 예제

### 2. [When to Scale Instances](./02-when-to-scale-instances.md)
여러 Claude Instance를 사용해야 하는 시점과 기준을 다룹니다.

- 단일 instance의 한계 이해하기
- Multiple instance 아키텍처
- Instance 간 통신 및 조정
- 상태 공유 및 동기화
- 비용 vs 성능 트레이드오프

### 3. [Git Worktrees for Parallel Instances](./03-git-worktrees.md)
Git worktree를 사용하여 병렬 작업 환경을 관리하는 방법을 설명합니다.

- Git worktree의 개념과 장점
- Worktree 생성 및 관리
- 병렬 branch 작업
- Merge 전략 및 conflict 해결
- Production 배포 안전성

### 4. [The Cascade Method](./04-cascade-method.md)
복잡한 의존성을 가진 작업을 효율적으로 처리하는 Cascade pattern을 다룹니다.

- Cascade pattern의 원리
- 단계별 작업 흐름 설계
- Phase 간 데이터 전달
- 에러 처리 및 롤백
- 실전 예제 (멀티 에이전트 파이프라인)

---

## 학습 경로

처음 Parallelization을 배우는 경우:

1. **[My Preferred Pattern](./01-my-preferred-pattern.md)** 부터 시작하여 기본 패턴을 이해합니다
2. **[When to Scale Instances](./02-when-to-scale-instances.md)** 에서 확장 기준을 배웁니다
3. **[Git Worktrees for Parallel Instances](./03-git-worktrees.md)** 로 실제 구현 방식을 학습합니다
4. **[The Cascade Method](./04-cascade-method.md)** 으로 복잡한 상황 처리를 마스터합니다

---

## 주요 개념 요약

| 개념 | 설명 | 효과 |
|------|------|------|
| **Parallel Task** | 서로 의존하지 않은 작업들을 동시 실행 | 시간 50-90% 단축 |
| **Task Dependency** | 작업 간의 선행 관계 분석 | 최적의 병렬화 전략 수립 |
| **Multiple Instance** | 여러 Claude 인스턴스 동시 실행 | 고가용성 + 처리량 증대 |
| **Git Worktree** | 안전한 병렬 개발 환경 | Conflict 최소화 |
| **Cascade Pattern** | 단계별 의존성 처리 | 복잡한 파이프라인 관리 |
| **Concurrency Limit** | 동시 실행 작업 수 제한 | API rate limit 준수 |

---

## 실전 시나리오별 가이드

### 시나리오 1: 독립적 작업 병렬화
```
상황: 3개의 독립적인 문서 작성 필요
효율성: 순차 (3시간) vs 병렬 (1시간) = 66% 단축

추천: My Preferred Pattern 사용
```

### 시나리오 2: 높은 처리량 필요
```
상황: 100개 파일을 동시에 처리해야 함
한계: 단일 instance는 rate limit에 걸림
효율성: 5개 instance로 처리량 5배 증대

추천: When to Scale Instances 적용
```

### 시나리오 3: 병렬 기능 개발
```
상황: 3개 팀이 다른 branch에서 동시 개발
충돌 위험: Merge 시 큰 conflict 발생 가능
효율성: Worktree로 안전하게 병렬 진행

추천: Git Worktrees for Parallel Instances 사용
```

### 시나리오 4: 복잡한 멀티 에이전트 파이프라인
```
상황: 계획 → 구현 → 테스트 → 문서화 → 배포
의존성: 각 단계는 이전 단계에 의존
효율성: Cascade pattern으로 각 단계 내 작업 병렬화

추천: The Cascade Method 적용
```

---

## 빠른 적용 가이드

### 🎯 1단계: Task 의존성 분석

병렬화 가능한지 판단하기:

```
독립적가?
├─ YES → 병렬화 가능 (My Preferred Pattern)
└─ NO  → 의존성 확인
         ├─ 선형 의존성? → Cascade Method
         └─ 복잡한 의존성? → 여러 instance + Cascade
```

### 🎯 2단계: 리소스 확인

```bash
# 동시 실행 가능한 작업 수
- API rate limit: 분당 요청 수
- Token 예산: 사용 가능한 총 token
- 시간 제한: 작업 완료 시간
```

### 🎯 3단계: 패턴 선택 및 구현

| 상황 | 패턴 | 복잡도 |
|------|------|--------|
| 2-5개 독립 작업 | My Preferred Pattern | 낮음 |
| 높은 처리량 | When to Scale Instances | 중간 |
| 병렬 개발 | Git Worktrees | 중간 |
| 복잡한 파이프라인 | Cascade Method | 높음 |

### 🎯 4단계: 모니터링 및 최적화

```bash
# 성능 지표 추적
- 시작 시간과 종료 시간
- 각 작업의 실행 시간
- 병렬화로 인한 시간 단축율
- 에러율 및 재시도 횟수
```

---

## 주의사항 (⚠️ Common Pitfalls)

### 1. 과도한 병렬화
```
❌ 나쁜 예: 100개 작업을 모두 동시에 실행
✅ 좋은 예: API rate limit을 고려하여 10개씩 배치 처리
```

### 2. 동기화 누락
```
❌ 나쁜 예: 병렬 작업 결과를 기다리지 않고 진행
✅ 좋은 예: 모든 병렬 작업의 완료를 명시적으로 확인
```

### 3. 상태 공유 미처리
```
❌ 나쁜 예: 여러 작업이 같은 파일을 동시에 수정
✅ 좋은 예: Lock 메커니즘 또는 작업 영역 분리
```

### 4. 에러 처리 부족
```
❌ 나쁜 예: 한 작업의 실패를 무시하고 계속 진행
✅ 좋은 예: 각 병렬 작업의 에러를 명시적으로 처리
```

---

## 성능 개선 사례

### Case 1: 문서 작성 병렬화
```
작업: 6개 문서 섹션 작성
순차 처리: 2시간 (각 섹션 20분)
병렬 처리: 1시간 (3개 agent가 동시에 2개씩)
개선율: 50% 단축 ✓

기법: My Preferred Pattern
```

### Case 2: 대규모 코드 생성
```
작업: 50개 파일 생성
순차 처리: 5시간
병렬 처리: 40분 (10개 instance, 각각 5개 파일)
개선율: 87.5% 단축 ✓

기법: When to Scale Instances + Cascade
```

### Case 3: 멀티 팀 개발
```
상황: 3개 팀이 다른 기능 동시 개발
without worktree: 3명이 순차 커밋 (conflict 다발)
with worktree: 3개 branch 동시 진행 (안전한 병렬화)
개선율: 개발 속도 3배 향상 ✓

기법: Git Worktrees for Parallel Instances
```

---

## 관련 문서

### 같은 레벨의 다른 섹션

- [Context & Memory Management](../01-context-memory/README.md) - Context 효율성
- [Token Optimization](../02-token-optimization/README.md) - 토큰 최적화
- [Verification Loops & Evals](../03-verification-evals/README.md) - 품질 검증
- [Groundwork](../05-groundwork/README.md) - 프로젝트 설계
- [Agent Best Practices](../06-agent-best-practices/README.md) - Agent 설계

### 예제

- [`examples/`](../examples/) - 전체 예제 모음
- [`examples/agent-configs/`](../examples/agent-configs/) - Agent 설정 예제

### 메인 가이드

- [Longform Guide Overview](../README.md) - 전체 가이드 소개
- [main README](../../README.md) - Claude Automate 프로젝트 개요

---

## 실전 체크리스트

Parallelization을 시작하기 전에 확인하세요:

- [ ] **Task 의존성 명확화**: 어떤 작업이 병렬화 가능한지 파악
- [ ] **리소스 계획**: API rate limit, token 예산, 시간 제한 확인
- [ ] **패턴 선택**: 상황에 맞는 병렬화 패턴 선택
- [ ] **동기화 전략**: 병렬 작업 결과 수집 방법 정의
- [ ] **에러 처리**: 실패 시나리오 대비
- [ ] **모니터링**: 성능 지표 추적 방법 준비
- [ ] **테스트**: 작은 규모에서 먼저 검증

---

## 주요 용어

| 용어 | 한글 | 설명 |
|------|------|------|
| **Parallelization** | 병렬화 | 여러 독립적 작업을 동시에 실행 |
| **Concurrent** | 동시성 | 여러 작업이 겹쳐서 실행되는 상태 |
| **Task Dependency** | 작업 의존성 | 작업 간의 선행 관계 |
| **Race Condition** | 레이스 조건 | 여러 작업이 동시에 리소스 접근할 때 발생하는 문제 |
| **Synchronization** | 동기화 | 병렬 작업들을 조정하여 올바른 순서 보장 |
| **Cascade** | 연쇄, 폭포 | 단계별 의존성을 처리하는 패턴 |
| **Worktree** | 작업 트리 | Git에서 독립적인 작업 영역 |
| **Instance** | 인스턴스 | Claude API의 독립적인 실행 단위 |

---

## 다음 단계

Parallelization을 완료했다면:

1. **[Verification Loops & Evals](../03-verification-evals/README.md)** - 병렬 작업 결과 검증
2. **[Agent Best Practices](../06-agent-best-practices/README.md)** - 효율적인 Agent 설계
3. **[Token Optimization](../02-token-optimization/README.md)** - 비용 최적화와 병렬화 조합

---

**작성자**: claude-automate 문서팀
**마지막 수정**: 2026년 1월
**상태**: 작성 중
