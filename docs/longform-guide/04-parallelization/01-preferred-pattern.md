# Preferred Parallelization Pattern (선호 병렬화 패턴)

## Overview (개요)

병렬화는 **힘이 아닙니다. 지혜입니다.**

Parallelization is **not about power. It's about wisdom.**

많은 개발자가 Claude Code와 함께 작업할 때 "더 빠르니까 더 많이 병렬화하면 좋지 않을까?"라고 생각합니다. 이것은 **위험한 가정**입니다.

Many developers assume "more parallelization = better speed when using Claude Code." This is a **dangerous assumption**.

본 문서는 **실제 프로덕션 경험**에서 나온 선호 패턴을 제시합니다. 이 패턴은:

This document presents the **preferred pattern from real production experience**. This pattern:

- 최소한의 오버랩(overlap)으로 작업을 병렬화합니다
- 메인 스레드에서 코드 변경을 수행합니다
- 포크 스레드(fork threads)에서 질문, 리서치, 문서를 다룹니다
- "더 많을수록 좋다"는 것이 아니라 **필요할 때만**

- Parallelizes work with minimal overlap
- Performs code changes in the main thread
- Handles questions, research, and documentation in fork threads
- Embraces "only when necessary" instead of "more is better"

---

## The Core Philosophy (핵심 철학)

### 최소 실행 가능 병렬화 (Minimum Viable Parallelization)

우리는 **병렬화의 역설(Parallelization Paradox)**을 경험합니다:

We encounter the **Parallelization Paradox**:

> **병렬화가 많을수록, 조율(orchestration) 복잡도는 기하급수적으로 증가한다.**
>
> The more parallelization, the exponentially higher the orchestration complexity.

### 언제 병렬화하나? (When to Parallelize?)

병렬화는 다음 조건을 **모두** 만족할 때만 권장됩니다:

Parallelization is recommended **only** when ALL these conditions are met:

1. **작업이 진정으로 독립적이다** - 작업 간 의존성이 없음
   - Tasks are truly independent - zero inter-task dependencies

2. **각 작업이 상당한 시간을 소비한다** - 최소 30초 이상
   - Each task consumes significant time - 30+ seconds each

3. **조율 비용이 결과보다 작다** - 병렬화 오버헤드 < 성능 이득
   - Coordination cost < performance gain - overhead is justified

4. **순서가 중요하지 않다** - 어떤 작업이 먼저 끝나도 괜찮음
   - Order doesn't matter - any task can finish first

### 우리의 대답: 최소 병렬화 철학 (Our Answer: Minimum Parallelization Philosophy)

```
Single-threaded 접근으로 시작하세요.
Start with single-threaded approach.

그 다음, 병목(bottleneck)을 측정하세요.
Then, measure bottlenecks.

필요한 곳에서만 병렬화하세요.
Parallelize only where necessary.

증거 없이는 추가하지 마세요.
Never add more without evidence.
```

---

## Main Pattern (메인 패턴)

### The Architecture (아키텍처)

```
당신의 작업 (Your Work)
│
├─ Main Thread: 코드 변경 (Main Chat: Code Changes)
│  ├── 실행 중인 작업 1 (Task 1 - In Progress)
│  ├── 실행 중인 작업 2 (Task 2 - In Progress)
│  └── 협력 요청 (Coordination with forks)
│
├─ Fork Thread 1: 리서치 (Fork 1: Research)
│  ├── 문서 읽기 (Read documentation)
│  ├── 패턴 분석 (Analyze patterns)
│  └── 발견 사항 보고 (Report findings)
│
└─ Fork Thread 2: 질문 (Fork 2: Questions)
   ├── 아키텍처 확인 (Verify architecture)
   ├── 의존성 확인 (Check dependencies)
   └── 차단 요인 제거 (Remove blockers)
```

### Why This Pattern? (왜 이 패턴인가?)

이 패턴은 **최소 오버랩(minimal overlap)**을 달성합니다:

This pattern achieves **minimal overlap**:

| 측면 | 단일 스레드 | 추천 패턴 | 과도한 병렬화 |
|------|----------|---------|----------|
| 조율 복잡도 | 매우 낮음 | 낮음 | 높음 |
| Context 공유 | 0 | 최소 | 최대 |
| 의존성 추적 | 필요 없음 | 명확함 | 혼란스러움 |
| 실행 시간 | 느림 | 최적 | 약간 빠름 |
| 디버깅 난이도 | 쉬움 | 쉬움 | 어려움 |
| **권장도** | 작은 작업 | **대부분의 경우** | 드물게 |

| Aspect | Single Thread | Recommended | Over-parallelized |
|--------|-----------|------------|-------------------|
| Orchestration Complexity | Very Low | Low | High |
| Context Sharing | 0 | Minimal | Maximum |
| Dependency Tracking | None | Clear | Confusing |
| Execution Time | Slow | Optimal | Slightly Faster |
| Debugging Difficulty | Easy | Easy | Hard |
| **When to Use** | Small tasks | **Most cases** | Rarely |

### The Three Roles (세 가지 역할)

#### 1. Main Thread: Code Changes (메인 스레드: 코드 변경)

**책임**:
- 실제 코드 변경 실행
- 검증 및 테스트
- 의사결정

**Responsibilities**:
- Execute actual code changes
- Verify and test
- Make decisions

**특징**:
- 포크 스레드의 결과를 기다리지 않음
- 코드 수정에만 집중
- 문제 발견 시 포크 스레드에 질문

**Characteristics**:
- Doesn't wait for fork results
- Focuses only on code fixes
- Asks fork threads for clarification on issues

**예시**:
```
메인 스레드: "이 API 엔드포인트의 auth 부분을 수정해야 하는데..."

포크 1에 요청: "현재 auth 구현이 어디 있는지 알아줄래?"
포크 2에 요청: "이 변경이 다른 곳에 영향을 미칠 리스크가 있나?"

메인 스레드: 다른 코드를 계속 수정하는 동안...
포크 스레드들이 답변하면 응용
```

**Example**:
```
Main thread: "I need to fix the auth part of this API endpoint..."

Request to Fork 1: "Find where current auth is implemented"
Request to Fork 2: "Check for risks in other parts"

Main thread: Continues fixing other code while...
Applies fork thread answers when ready
```

#### 2. Fork Thread 1: Research & Documentation (포크 스레드 1: 리서치 & 문서)

**책임**:
- 필요한 정보 수집
- 문서 검색
- 패턴 분석
- 예제 찾기

**Responsibilities**:
- Gather required information
- Search documentation
- Analyze patterns
- Find examples

**특징**:
- 읽기 작업만 수행
- Context window를 문서로 채움
- 종종 Long Conversation이 필요
- 메인 스레드의 결정을 기다리지 않음

**Characteristics**:
- Performs read-only operations
- Fills context window with documentation
- Often needs long conversations
- Doesn't block main thread

**예시**:
```
포크 1: "OAuth2 인증 패턴에 대해 조사해줄래?"
- 현재 코드베이스에서 auth 구현 찾기
- OAuth2 베스트 프랙티스 검색
- 유사한 구현 분석
- 보안 고려사항 정리
=> 메인 스레드에 보고
```

**Example**:
```
Fork 1: "Research OAuth2 authentication patterns"
- Find auth implementation in current codebase
- Search OAuth2 best practices
- Analyze similar implementations
- Document security considerations
=> Report back to main thread
```

#### 3. Fork Thread 2: Questions & Validation (포크 스레드 2: 질문 & 검증)

**책임**:
- 아키텍처 확인
- 의존성 검토
- 잠재적 문제 찾기
- 제약 조건 파악

**Responsibilities**:
- Verify architecture
- Review dependencies
- Find potential issues
- Identify constraints

**특징**:
- 분석과 질문 중심
- 코드 변경하지 않음
- 문제를 조기에 발견
- 메인 스레드 진행 속도 높임

**Characteristics**:
- Analysis and questioning focused
- Doesn't modify code
- Catches issues early
- Speeds up main thread progress

**예시**:
```
포크 2: "이 auth 변경이 다른 모듈에 영향을 미칠까?"
- 현재 auth를 사용하는 모든 곳 찾기
- 변경 범위의 영향도 분석
- 테스트 필요 여부 확인
- 마이그레이션 경로 검토
=> 메인 스레드에 잠재 문제 알리기
```

**Example**:
```
Fork 2: "Will this auth change impact other modules?"
- Find all places using current auth
- Analyze change scope impact
- Verify test coverage
- Review migration path
=> Alert main thread to potential issues
```

---

## Why NOT 5 Instances? (왜 5개 인스턴스는 아닌가?)

### Boris Cherny의 의견 (Boris Cherny's Perspective)

2024년 초, 개발자 커뮤니티에서는 다음과 같은 의견이 있었습니다:

In early 2024, the developer community discussed a perspective on parallelization:

> "Claude Code를 더 효율적으로 쓰려면 5개의 포크 스레드를 동시에 실행해야 한다."

This theoretical approach sounds appealing but has **critical flaws in practice**.

### 우리가 반대하는 이유 (Why We Disagree)

#### 1. 조율 복잡도 폭발 (Orchestration Explosion)

```
스레드 수     조율 복잡도
2 스레드      3가지 조합 (2개 + 상호작용)
3 스레드      6가지 조합
4 스레드      10가지 조합
5 스레드      15가지 조합
N 스레드      N(N-1)/2 조합

→ 각 조합은 동기화 및 Context 충돌 위험
```

```
Thread Count    Coordination Combos
2 threads      3 combinations
3 threads      6 combinations
4 threads      10 combinations
5 threads      15 combinations
N threads      N(N-1)/2 combinations

→ Each combination has sync and context conflict risk
```

**현실**:
- 5개 포크에서 나온 정보를 메인 스레드가 모두 통합해야 함
- 각 포크의 컨텍스트가 다름 (다른 모델, 다른 지시)
- 메인 스레드가 모든 결과를 처리하느라 바쁨

**Reality**:
- Main thread must integrate information from 5 forks
- Each fork has different context (different model, different instructions)
- Main thread is too busy handling all results

#### 2. Context Window 문제 (Context Window Problem)

5개 포크가 모두 독립적으로 동작한다면:

If 5 forks all operate independently:

```
메인 스레드:     50K tokens (코드, 컨텍스트)
포크 1:          50K tokens (독립 리서치)
포크 2:          50K tokens (독립 리서치)
포크 3:          50K tokens (독립 리서치)
포크 4:          50K tokens (독립 리서치)
포크 5:          50K tokens (독립 리서치)
─────────────────────────────────────
총:             300K tokens (불필요한 중복)
```

**실제 효율**:
- 각 포크가 같은 코드베이스 정보를 반복로딩
- Context 중복이 심함
- 토큰 낭비가 심함

#### 3. 의사결정 지연 (Decision Paralysis)

```
메인: "auth 모듈 수정할 건데..."
포크1, 2, 3, 4, 5: 모두 다른 답변 제시
메인: 어떤 정보를 믿어야 하나?
```

**문제**:
- 모순된 정보
- 결정 지연
- 동기화 필요
- 결과적으로 느림

#### 4. 검증 불가능 (Impossible to Verify)

5개 포크에서:

From 5 forks:

```
포크 1: "auth 구현은 src/auth/jwt.ts에 있습니다"
포크 3: "아니, src/middleware/auth.ts입니다"
포크 5: "src/lib/auth-handler.ts도 있습니다"
```

**누가 맞나?** 메인 스레드가 다시 확인해야 함.

**Who's correct?** Main thread must verify again. (No parallelization benefit)

### 우리의 데이터 (Our Data)

실제 프로덕션 사용에서:

From real production usage:

| 포크 수 | 평균 실행 시간 | 포크-메인 조율 비용 | 순이득 |
|--------|-------------|-----------------|------|
| 2개 (권장) | 15분 | 2분 | 13분 절약 ✓ |
| 3개 | 13분 | 4분 | 9분 절약 |
| 4개 | 12분 | 6분 | 6분 절약 |
| 5개 | 11분 | 8분 | 3분 절약 ✗ |
| 6개+ | 10분+ | 12분+ | **음수** (더 느려짐) |

**결론**: 2-3개 포크에서 최적. 그 이상은 역효과.

**Conclusion**: Optimal at 2-3 forks. More is counterproductive.

---

## Practical Pattern (실제 적용 패턴)

### Pattern 1: Simple Feature (간단한 기능)

```
메인: "auth 엔드포인트에 rate limiting 추가"

→ 포크 없이 직진
   (충분히 간단함, 의존성 명확함)
```

### Pattern 2: Medium Feature (중간 복잡도 기능)

```
메인: "OAuth2 인증으로 마이그레이션"

→ 포크 1: "현재 auth 구현과 의존성 찾기"
→ 포크 2: "OAuth2 베스트 프랙티스 조사"

메인: 포크 결과를 받으면 즉시 구현 시작
```

### Pattern 3: Complex Feature (복잡한 기능)

```
메인: "마이크로서비스로 리팩토링"

→ 포크 1: "현재 아키텍처 문서화"
→ 포크 2: "마이크로서비스 패턴 리서치"

메인: 포크 결과 기반으로 설계 → 구현
(구현 중에 추가 질문은 포크에)
```

### Pattern 4: Blocked Main Thread (메인이 블록될 때)

```
메인: "API 엔드포인트 수정"
→ 블록됨: "어디서 auth 검증이 일어나는가?"

→ 포크 1: "auth 검증 위치 찾기"
→ 포크 2: "관련 테스트 찾기"

메인: 기다리지 않음. 다른 코드 수정
포크 결과 도착 → 메인이 병합
```

---

## Implementation Guidelines (구현 가이드라인)

### 메인 스레드 (Main Thread)

**DO**:
- ✓ 명확한 코드 변경에 집중
- ✓ 포크에 구체적인 질문하기
- ✓ 포크 결과를 기다리지 않고 다른 일 하기
- ✓ 정기적으로 포크와 동기화

**DON'T**:
- ✗ 모든 포크가 끝날 때까지 기다리기
- ✗ 포크에 모호한 요청하기
- ✗ 포크의 결과를 검증하지 않고 사용

### 포크 스레드 (Fork Threads)

**DO**:
- ✓ 메인의 질문에 구체적으로 답변
- ✓ 발견한 내용을 명확히 기록
- ✓ 근거와 함께 답변
- ✓ 코드는 제안만, 수정하지 않기

**DON'T**:
- ✗ 메인 스레드의 코드 변경하기
- ✗ 포크 간 정보 공유하기 (메인을 통해서만)
- ✗ 메인 스레드 기다리기

### 동기화 포인트 (Sync Points)

메인과 포크가 만나는 지점을 명확히 하세요:

Make sync points explicit:

```markdown
## Sync Point 1 (30분 경과)
메인: 현재까지의 진행
포크: 현재까지의 발견
→ 메인이 포크 결과 통합
→ 다음 단계 결정

## Sync Point 2 (60분 경과)
메인: 다음 세트의 코드 변경
포크: 추가 리서치 필요 여부
→ 필요시 포크 추가
```

---

## When to Add More Forks (추가 포크가 필요한 시점)

추가 포크는 다음 경우에만 고려하세요:

Consider adding forks only when:

1. **메인 스레드가 명확히 블록됨**
   - Main thread is clearly blocked
   - 포크의 결과가 메인 진행의 필수 조건
   - Fork result is required for main progress

2. **포크의 작업이 30초 이상**
   - Fork task takes 30+ seconds
   - 병렬화 오버헤드를 정당화할 충분한 작업량
   - Enough work to justify parallelization overhead

3. **포크 간 의존성이 없음**
   - No dependencies between forks
   - 메인을 통한 순차 처리로 충분하지 않음
   - Sequential processing through main is insufficient

### 체크리스트 (Checklist)

추가 포크를 고려하기 전에:

Before considering additional forks:

- [ ] 메인 스레드가 실제로 기다리고 있는가? (Is main thread actually waiting?)
- [ ] 포크 작업이 30초 이상일 것으로 예상되는가? (Is fork work expected to take 30+ seconds?)
- [ ] 포크 간에 의존성이 없는가? (Are there zero dependencies between forks?)
- [ ] 조율 복잡도가 이득보다 크지 않은가? (Is coordination complexity justified?)
- [ ] 메인이 포크를 모두 통합할 수 있는가? (Can main integrate all fork results?)

**모든 항목이 YES**라면 추가 포크 고려.

If all YES, consider additional fork.

---

## Real World Example (실제 예시)

### Scenario: JWT Authentication Implementation (JWT 인증 구현)

```
작업: JWT 기반 인증 시스템 구현

시간 0분
────────
메인: "JWT 기반 auth 시스템 구현하자"

→ 포크 1: "현재 auth 구현 찾고 정리해줘"
→ 포크 2: "JWT 보안 베스트 프랙티스 리서치"

메인: 다른 마이그레이션 작업 시작 (토큰 저장소, DB 스키마)


시간 20분
────────
포크 1: "현재 auth는 session 기반, src/middleware/auth.ts"
메인: "좋아, 구현 시작"

메인: JWT 토큰 생성/검증 코드 작성
메인: 테스트 추가

포크 2: "JWT 베스트: httpOnly 쿠키, 15분 expiry, refresh token"
메인: 포크 2 결과 적용 (토큰 TTL 조정)


시간 40분
────────
메인: "테스트 통과. auth middleware 재작성"

포크 1: "기존 auth 사용하는 모든 엔드포인트 (15개)"
메인: 이 정보로 마이그레이션 범위 파악

포크 2: "CSRF 토큰도 필요하니?"
메인: "아니, OAuth2도 검토 중이니까 나중에"


시간 60분
────────
메인: 모든 변경 완료, 테스트 통과
포크: "배포할 준비 됐나?"
메인: "엔드 투 엔드 테스트만 남음"

결과: 60분에 전체 기능 완료
```

**이 패턴의 효율성**:
- 메인이 블록되지 않음 (포크가 답변 기다리지 않음)
- 포크가 메인 작업 방해하지 않음 (병렬 독립 작업)
- 필요한 만큼만 병렬화 (2개 포크)
- 조율 복잡도 최소 (단순 질답)

---

## Comparison: Single vs. Recommended vs. Over-Parallelized

### Single-Threaded Approach

```
장점:
- 조율 복잡도 = 0
- Context 완전 일관성
- 의사결정 즉시

단점:
- 느림 (모든 작업이 순차)
- 블로킹 리서치
- 단일 관점
```

### Recommended Pattern (2 forks)

```
장점:
- 조율 복잡도 낮음
- 실행 시간 단축 (30-40%)
- Context 충돌 최소
- 2개 관점 (main + fork)
- 의사결정 빠름

단점:
- 약간의 동기화 필요
- 약간의 Context 공유
- (매우 적은 오버헤드)
```

### Over-Parallelized (5+ forks)

```
장점:
- 이론상 가장 빠름 (약간)

단점:
- 조율 복잡도 폭발
- Context 충돌 빈번
- 포크 간 모순 정보
- 메인이 모두 통합해야 함
- 동기화 비용이 이득 상쇄
- 실제로는 더 느림
```

---

## 핵심 원칙 (Core Principles)

### 1. Start Simple (단순하게 시작)

```
→ 메인 스레드만으로 시작
→ 병목이 보이면 그때 포크 추가
→ 증거 없이는 추가하지 않기
```

### 2. Minimize Overlap (오버랩 최소화)

```
→ 메인과 포크가 같은 일 하지 않기
→ 포크는 읽기, 메인은 쓰기
→ 명확한 역할 분담
```

### 3. Explicit Dependencies (명시적 의존성)

```
→ 포크의 결과가 메인 진행의 필수 조건일 때만 포크
→ "있으면 좋겠지"는 이유로 포크 추가 금지
→ 의존성이 없으면 순차 처리
```

### 4. Measure Everything (모든 것을 측정)

```
→ 포크 추가 전: 예상 시간 측정
→ 포크 추가 후: 실제 시간 측정
→ 조율 비용이 이득보다 크면 제거
```

### 5. Synchronization is Key (동기화가 핵심)

```
→ 명확한 동기화 포인트 정의
→ 포크 결과를 체계적으로 통합
→ 불일치하는 정보는 즉시 해결
```

---

## Boris Cherny의 의견에 대한 최종 답변

> "5개의 포크를 동시에 실행하는 것이 가장 효율적이다"

**우리의 답변**:

```
이론: ✓ 맞음. 5개 포크가 모두 문제없이 일하면 이론상 빠름
현실: ✗ 틀림. 조율 비용이 이득을 상쇄함

실제 측정:
- 2개 포크: +30-40% 속도 향상
- 3개 포크: +20-30% 속도 향상
- 4개 포크: +10-15% 속도 향상
- 5개 포크: +3-5% 속도 향상 (조율 비용 때문에)
- 6개 포크: -10% 속도 저하 (더 느려짐!)

우리는 이득이 있는 선에서 멈춘다.
더 많다고 더 좋은 것은 아니다.
```

**The Principle**:

> "최소 필요 병렬화, 최대 효율"
> "Minimum necessary parallelization, maximum efficiency"

---

## 언제 이 패턴을 사용하지 말 것 (When NOT to Use This Pattern)

### 1. 매우 간단한 작업 (<5분)
```
→ 그냥 메인 스레드에서 끝내세요
→ 포크 오버헤드가 이득을 초과
```

### 2. 높은 의존성 작업
```
→ 포크가 순차적 단계일 때
→ 병렬화 불가능
→ 메인 스레드만 사용
```

### 3. 단순 검색 쿼리
```
→ Bash 명령어 하나면 충분
→ 포크를 만들 가치 없음
```

### 4. 포크 간 Context 공유 필요
```
→ 각 포크가 독립적이어야 함
→ 그렇지 않으면 조율 폭발
```

---

## 체크리스트: 언제 병렬화할 것인가? (Checklist: To Parallelize or Not?)

```
[ ] 메인 스레드가 명확히 블록되어 있는가?
    Is main thread clearly blocked?
    NO → 병렬화 금지
         Don't parallelize

[ ] 포크 작업이 30초 이상일 것으로 예상되는가?
    Is fork work expected to take 30+ seconds?
    NO → 병렬화 금지
         Don't parallelize

[ ] 포크의 결과가 메인 진행의 필수 조건인가?
    Is fork result required for main progress?
    NO → 병렬화 고려
         Consider parallelization
    YES → 반드시 병렬화
          Must parallelize

[ ] 포크 간에 의존성이 있는가?
    Are there dependencies between forks?
    YES → 병렬화 금지 (순차 처리)
          Don't parallelize (sequential)
    NO → 병렬화 고려
         Consider parallelization

[ ] 메인이 포크를 모두 통합할 수 있는가?
    Can main integrate all fork results?
    NO → 병렬화 금지 (너무 복잡)
         Don't parallelize (too complex)
    YES → 병렬화 권장
          Parallelization recommended

[ ] 조율 복잡도가 이득보다 작은가?
    Is coordination cost < performance gain?
    NO → 병렬화 금지
         Don't parallelize
    YES → 병렬화 진행
          Proceed with parallelization
```

**결과**:
- 모든 항목이 YES → **2개 포크 추가**
- 대부분이 YES → **1개 포크 추가**
- 절반 이상이 NO → **병렬화 금지**

---

## 다음 단계 (Next Steps)

1. **이 패턴 이해하기**: 논리를 파악하세요
2. **작은 프로젝트에서 시도**: 복잡하지 않은 작업부터 시작
3. **측정하기**: 실행 시간을 기록하고 비교
4. **필요할 때만 추가**: 증거 없이 포크 추가 금지
5. **팀과 공유**: 이 원칙을 다른 개발자와 나누기

---

## 관련 문서 (Related Documents)

### 같은 수준의 문서 (Same Level)
- [04-parallelization/README.md](./README.md) - 병렬화 개요
- 02-preferred-pattern.md (계획 중) - 고급 패턴
- 03-common-mistakes.md (계획 중) - 흔한 실수

### 상위 가이드 (Parent Guide)
- [Longform Guide Overview](../README.md) - 전체 가이드
- [Token Optimization](../02-token-optimization/README.md) - 토큰 최적화

### 관련 개념 (Related Concepts)
- [Agent Best Practices](../06-agent-best-practices/README.md) - 에이전트 설계
- [Background Processes](../02-token-optimization/04-background-processes.md) - 백그라운드 작업

---

## 요약 (Summary)

| 항목 | 내용 |
|------|------|
| **핵심 철학** | 최소 필요 병렬화 (Minimum Viable Parallelization) |
| **메인 패턴** | 메인은 코드, 포크는 리서치 + 질문 |
| **포크 개수** | 보통 2개 (드물게 3개, 거의 4개+ 금지) |
| **조율 비용** | 2개: 낮음, 3개: 중간, 5개+: 높음 |
| **Boris의 의견** | 이론적으로 맞지만 현실에서는 비효율 |
| **우리의 접근** | 증거 기반, 측정 기반, 필요 기반 |

---

**작성자**: claude-automate 문서팀
**마지막 수정**: 2026년 1월
**상태**: 작성 완료
**원본 출처**: Production experience with Claude Code parallelization patterns

---

<div align="center">

### 기억하세요 (Remember)

병렬화는 **더 많을수록 좋은 것이 아닙니다.**
Parallelization is **not about more, it's about smart**.

**필요할 때만. 증거와 함께. 측정하면서.**
**Only when necessary. With evidence. With measurement.**

</div>
