# When to Scale: Parallelization at Different Levels

## 핵심 개념 (Core Concept)

병렬 처리는 강력하지만, 모든 프로젝트에서 필요한 것은 아닙니다. 이 가이드는 **언제** 단일 인스턴스에서 시작하고, **언제** 스케일링으로 나아가야 하는지를 설명합니다.

**The Question**: Do you actually need multiple instances? Most projects don't—until they do.

## 3가지 실제 사례 (Three Real Scenarios)

### Scenario 1: Single Instance (가장 흔함)

```
┌─────────────────────────────┐
│   Claude Code Instance 1    │
│  Your Main Development Loop │
│                             │
│  • Feature implementation   │
│  • Bug fixes               │
│  • Documentation updates   │
└─────────────────────────────┘
```

**이 상황이라면 단일 인스턴스로 충분합니다:**

- 작업이 주로 **순차적**이고 의존성이 명확함
- 한 번에 1-2개의 병렬 작업만 필요
- 인지적 오버헤드를 낮추는 것이 우선
- 프로젝트가 초기 단계

**예시:**
```
Session 1: Feature A 구현
└─ 다음 세션: Bug fix
    └─ 다음 세션: Documentation
        └─ 다음 세션: Release
```

---

### Scenario 2: Two-Three Instances (실용적)

```
┌──────────────────┐    ┌──────────────────┐
│ Instance 1       │    │ Instance 2       │
│ Feature Branch   │    │ Hotfix Branch    │
│                  │    │                  │
│ Main Work        │    │ Urgent Issues    │
│ • Complex impl   │    │ • Bug fixes      │
│ • Architecture   │    │ • Quick patches  │
│ • Testing        │    │ • User support   │
└──────────────────┘    └──────────────────┘
     git worktree           git worktree
```

**2-3개 인스턴스가 필요한 신호:**

- **독립적인 작업 흐름**: Feature 개발과 긴급 버그 수정
- **명확한 책임 분리**: 각 인스턴스가 다른 branch에서 작동
- **팀 협업**: 여러 개발자가 동시에 작업
- **중간 크기 프로젝트**: 충분한 작업량이 있지만 압도적이지 않음

**예시:**
```
Instance 1 (feature-payment):
- 결제 시스템 구현 중
- 복잡한 아키텍처 결정 필요
- 3-4 세션 예상

Instance 2 (hotfix-critical-bug):
- 사용자 보고된 critical bug 수정
- 빠른 해결 필요
- 1-2 세션으로 완료 후 merge
```

**git worktrees 필수:**

```bash
# Instance 1: 메인 기능 작업
git worktree add ../feature-payment origin/feature-payment
cd ../feature-payment

# Instance 2: 버그 수정
git worktree add ../hotfix-critical origin/hotfix-critical
cd ../hotfix-critical
```

**장점:**
- Context switching 없음 (각 인스턴스는 독립적)
- Git 상태가 깔끔함
- 각 세션이 명확한 목표를 가짐

**주의점:**
- 2개까지는 관리 가능
- 3개부터는 인지 부하가 증가
- 무조건 필요할 때만 추가

---

### Scenario 3: Four+ Instances (드문 경우)

```
┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ Instance 1   │  │ Instance 2   │  │ Instance 3   │  │ Instance 4   │
│ Feature-A    │  │ Feature-B    │  │ Refactor     │  │ Docs         │
│              │  │              │  │              │  │              │
│ Parallel Dev │  │ Parallel Dev │  │ Infrastructure│  │ Parallel Doc │
└──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘
   worktree          worktree          worktree         worktree
```

**4개 이상이 필요한 경우는 매우 드뭅니다:**

- **대규모 팀 프로젝트**: 5명 이상의 개발자
- **매우 복잡한 아키텍처**: 독립적인 여러 서브시스템
- **적극적인 병렬화 전략**: 명확한 이유와 계획이 있음

**위험 신호:**
- 어떤 인스턴스에서 무엇을 하는지 모호해짐
- 인스턴스 간 충돌 가능성 증가
- 각 인스턴스의 진행 상황 추적이 어려움

---

## 핵심 결정 지표

### 체크리스트: 단일 인스턴스로 충분한가?

```
✓ 작업 대부분이 순차적이다
✓ 한 번에 최대 1개의 병렬 작업만 필요
✓ Context switching이 비용이 크지 않음
✓ 인지적 부하를 낮추고 싶다
✓ 프로젝트가 초기 단계다
✓ 팀이 1명이다

→ YES: 단일 인스턴스로 진행하세요
```

### 체크리스트: 2-3개 인스턴스가 필요한가?

```
✓ 최소 2개 이상의 독립적인 작업 흐름이 있다
✓ 각 작업이 다른 branch에 격리될 수 있다
✓ 팀 협업이 필요하거나 병렬 작업이 자주 발생
✓ 충분한 작업량이 있어 병렬화가 의미 있다
✓ Well-defined plan for each instance이 있다
✓ 각 인스턴스의 목표가 명확하다

→ YES: 2-3개 인스턴스 활성화
```

### 체크리스트: 4개 이상은 위험한가?

```
✗ 어떤 인스턴스가 무엇인지 설명하기 어렵다
✗ 각 인스턴스의 책임이 불명확해지고 있다
✗ 인스턴스 간 조정이 복잡하다
✗ 병렬화의 이점이 관리 비용을 초과한다
✗ 팀 크기로 정당화하기 어렵다

→ NO: 다시 생각해보세요
```

---

## Mental Overhead vs Productivity 균형

### 단일 인스턴스의 인지 부하

```
인지 비용:
┌─────────────────────────────┐
│ • Session 상태: 1개만 추적  │
│ • 컨텍스트 전환: 없음       │
│ • Git 상태: 단순함          │
│ • Chat 이름: 하나만 관리    │
│ 총합: 최소              │
└─────────────────────────────┘

생산성:
┌─────────────────────────────┐
│ • 순차 작업: 빠름          │
│ • 집중력: 높음              │
│ • 병렬화 가능: 부분적       │
│ 대기 시간: 중간              │
└─────────────────────────────┘
```

### 2-3개 인스턴스의 인지 부하

```
인지 비용:
┌─────────────────────────────┐
│ • Session 상태: 2-3개 추적  │
│ • 컨텍스트 전환: 가능       │
│ • Git 상태: worktree 관리   │
│ • Chat 이름: 명확하게 구분  │
│ 총합: 관리 가능         │
└─────────────────────────────┘

생산성:
┌─────────────────────────────┐
│ • 순차 작업: 매우 빠름      │
│ • 병렬화: 높음              │
│ • 대기 시간: 최소화         │
│ • 적극적인 개발: 가능       │
└─────────────────────────────┘
```

### 4개 이상의 인지 부하 (위험)

```
인지 비용:
┌─────────────────────────────┐
│ • Session 상태: 4개+ 추적   │
│ • 컨텍스트 전환: 빈번       │
│ • Git 상태: 복잡함          │
│ • Chat 이름: 구분 어려움    │
│ • 우선순위: 불명확함       │
│ 총합: 압도적             │
└─────────────────────────────┘

생산성:
┌─────────────────────────────┐
│ • 순차 작업: 느려짐         │
│ • 병렬화: 혼란             │
│ • Context switch overhead   │
│ • Bug 위험 증가             │
│ 결과: 전체 속도 ↓           │
└─────────────────────────────┘
```

**규칙: Cognitive overhead가 생산성 이득을 초과하면 너무 많은 것입니다.**

---

## 실제 구현: Well-Defined Plan

스케일링할 때 **각 인스턴스마다 명확한 계획**이 필수입니다.

### 나쁜 예: 무계획 병렬화

```markdown
Instance 1: 뭔가 하기
Instance 2: 다른 거 하기
Instance 3: 그것도 하기

결과:
- 각 인스턴스가 언제 끝날지 불명확
- 우선순위 충돌
- Merge 복잡성 증가
```

### 좋은 예: Well-Defined Plan

```markdown
Instance 1: Feature-Payment
├─ Goal: 결제 모듈 전체 구현
├─ Scope: src/payment/, tests/payment/
├─ Timeline: 3-4 세션 (월요일-목요일)
├─ Branch: feature/payment-v2
├─ Success Criteria: 모든 테스트 통과, PR ready
└─ Blockers: None

Instance 2: Hotfix-Critical-Bug
├─ Goal: 사용자 인증 버그 수정
├─ Scope: src/auth/
├─ Timeline: 1-2 세션 (금요일 오후)
├─ Branch: hotfix/critical-auth
├─ Success Criteria: Bug 재현 불가, 회귀 테스트 통과
└─ Blockers: None
```

---

## /rename으로 채팅 이름 지정

각 인스턴스의 채팅 이름을 **명확하게 지정**하는 것이 중요합니다.

### 채팅 이름 규칙

```
형식: [BRANCH] - Brief Description
예시:
```

**좋은 채팅 이름:**
```
feature/payment - Payment Module Implementation
hotfix/auth-bug - Critical Auth Bug Fix
refactor/api - REST to GraphQL Migration
```

**나쁜 채팅 이름:**
```
Work
Session 1
Random stuff
```

### 왜 중요한가?

1. **빠른 인지**: 어떤 인스턴스를 봐야 하는지 즉시 파악
2. **히스토리 추적**: 나중에 어떤 작업을 했는지 기억하기 쉬움
3. **팀 커뮤니케이션**: 다른 개발자가 어떤 작업 중인지 명확
4. **Session 정리**: 완료된 작업을 쉽게 찾을 수 있음

### 설정 방법

Claude Code의 설정 메뉴에서 대화 이름을 지정하세요:

```
Instance 1:
[feature/payment] - Payment Module Implementation
├─ Work period: Mon-Thu
├─ Related PR: #123
└─ Status: In Progress

Instance 2:
[hotfix/critical] - Auth Bug Fix
├─ Work period: Fri afternoon
├─ Related Issue: #456
└─ Status: Ready to Merge
```

---

## 단계별 스케일링 전략

### Phase 0: 단일 인스턴스 (초기 상태)

```
상황: 프로젝트 시작
→ 한 개의 Claude Code 인스턴스만 사용
→ 기본 작업 흐름 확립
```

**체크포인트:**
- Session state 파일 구조 잡혔는가?
- 기본 개발 흐름이 명확한가?
- 병렬화의 필요성이 명확한가?

---

### Phase 1: 병렬화 필요성 평가

```
신호:
✓ 두 개 이상의 독립적인 작업 흐름이 자주 발생
✓ Blocking 작업(테스트, 빌드)이 많아짐
✓ Context switching이 빈번
✓ 팀 협업이 필요해짐

의사결정: 2-3개 인스턴스로 스케일?
```

**준비 체크리스트:**
- [ ] Git worktrees 학습
- [ ] 각 인스턴스의 책임 정의
- [ ] /rename으로 이름 규칙 결정
- [ ] Merge 전략 수립

---

### Phase 2: 2개 인스턴스 활성화

```bash
# 기존 main 인스턴스
git worktree add ../feature-branch origin/feature-branch
cd ../feature-branch
# → Instance 1 시작: feature 개발

# 원본 디렉토리
cd ../original
# → Instance 2 시작: hotfix 개발
```

**첫 주 모니터링:**
- [ ] 각 인스턴스가 독립적으로 작동하는가?
- [ ] Context switching 비용이 수용 가능한가?
- [ ] Merge 충돌이 없는가?
- [ ] 총 생산성이 증가했는가?

---

### Phase 3: 필요시 3번째 인스턴스

```bash
# 세 번째 인스턴스가 정말 필요한가?
체크:
□ 동시에 3개 이상의 작업이 자주 진행?
□ 각각 명확한 책임과 timeline?
□ 팀 크기로 정당화?

No → 2개 유지
Yes → 3번째 추가
```

**절대 넘지 말아야 할 것:**
```
4개 이상의 인스턴스는 관리 비용이 이득을 초과합니다.
추가 작업이 필요하면 현재 인스턴스 완료 후 시작하세요.
```

---

## 실제 프로젝트 사례

### Case Study 1: 초기 개발 단계

```
프로젝트: Authentication System (신규)
팀 크기: 1명 (개발자)
기간: 2주

Instance 설정:
✓ 단일 인스턴스만 사용
  ├─ Session 1: Architecture design
  ├─ Session 2: JWT implementation
  ├─ Session 3: Middleware setup
  ├─ Session 4: Testing
  └─ Session 5: Documentation

결과:
- 총 5 세션으로 완료
- Context switching 없음
- 순차적 진행이 효율적
```

---

### Case Study 2: 팀 협업 (중간 크기)

```
프로젝트: E-commerce Platform
팀 크기: 2명 (개발자)
기간: 4주

Instance 설정:
Developer A:
┌─ Instance 1: [feature/payment] - Payment Integration
│  ├─ 세션 1-3: Stripe API integration
│  ├─ 세션 4-5: Testing & optimization
│  └─ 세션 6: Documentation & PR
│
└─ 4주 진행

Developer B:
┌─ Instance 2: [feature/inventory] - Inventory System
│  ├─ 세션 1-2: Database schema design
│  ├─ 세션 3-4: CRUD operations
│  └─ 세션 5-6: Integration testing
│
└─ 4주 진행

Parallel로 진행하되 자주 merge:
└─ 주 2회 integration merge

결과:
- 병렬화로 2주 단축
- Git worktrees로 충돌 방지
- 각 개발자 집중도 높음
- 최종 통합 시간 최소화
```

---

### Case Study 3: 긴급 + 정상 작업

```
프로젝트: SaaS Platform (운영 중)
팀 크기: 3명
상황: Feature 개발 중 critical bug 발견

Before (단일 인스턴스):
세션 1-2: Feature A 개발
→ Bug 발견! 긴급 수정 필요
→ Feature A 중단하고 bug 수정 (context switch)
→ Feature A 재개
→ 시간 낭비: ~2시간

After (2개 인스턴스):
Instance 1: [feature/new] - Main Feature Development
└─ 계속 진행

Instance 2: [hotfix/critical] - Critical Bug Fix
└─ 병렬로 처리, 완료 후 merge

→ Context switching 없음
→ 총 개발 시간: 30% 단축
→ Bug 수정: 1시간
→ Feature: 계속 진행
```

---

## 피해야 할 실수

### 실수 1: 무조건 병렬화

```markdown
❌ 나쁜 접근:
"병렬화는 좋으니까 무조건 여러 인스턴스 실행"

✓ 올바른 접근:
"이 작업이 정말 병렬화되어야 하는가?"
```

---

### 실수 2: Well-defined plan 없이 시작

```markdown
❌ 나쁜 상태:
Instance 1: 뭔가?
Instance 2: 다른 뭔가?
Instance 3: 또 다른 뭔가?

✓ 좋은 상태:
Instance 1: Feature X (Sessions 1-3, Branch: feature/x)
Instance 2: Hotfix Y (Sessions 1-2, Branch: hotfix/y)
```

---

### 실수 3: 4개 이상 인스턴스

```markdown
❌ 위험 신호:
4개 이상의 동시 인스턴스

✓ 해결:
- 우선순위 재정의
- 완료된 인스턴스 정리
- 다음 작업까지 대기
```

---

### 실수 4: 불명확한 채팅 이름

```markdown
❌ 혼란:
Instance 1: Work
Instance 2: Session
Instance 3: Dev

✓ 명확:
Instance 1: [feature/payment] - Payment Module
Instance 2: [hotfix/auth] - Critical Auth Bug
Instance 3: [refactor/api] - REST to GraphQL
```

---

## 체크리스트: 스케일링 준비

스케일링을 고려할 때 이 체크리스트를 따르세요:

```
스케일링 판단:
□ 최소 2개 이상의 명확하게 독립적인 작업이 있는가?
□ 각 작업이 다른 branch에 격리될 수 있는가?
□ 각 인스턴스의 책임이 명확한가?
□ 각 인스턴스의 예상 기간이 있는가?
□ Well-defined success criteria가 있는가?

Git 준비:
□ Git worktrees 사용법을 이해했는가?
□ Branch 전략이 명확한가?
□ Merge 전략이 수립되었는가?

명명 규칙:
□ /rename으로 채팅 이름 규칙을 정했는가?
□ 각 인스턴스의 목표를 이름에 반영했는가?
□ 팀원들이 이름만으로 이해할 수 있는가?

모니터링:
□ 각 인스턴스의 진행 상황을 추적할 계획?
□ Session state 파일을 각각 유지할 계획?
□ 병렬화의 효과를 측정할 지표?

결론:
모두 Yes → 스케일링 준비됨
일부 No → 준비 강화 후 진행
```

---

## 요약: 언제 스케일을 하는가?

| 상황 | 권장사항 | 이유 |
|------|--------|------|
| **초기 프로젝트** | 단일 인스턴스 | 명확한 작업 흐름 아직 형성 안 됨 |
| **순차적 작업 주류** | 단일 인스턴스 | 병렬화 이득 < 인지 부하 |
| **2-3개 병렬 작업** | 2-3개 인스턴스 | 최적의 균형점 |
| **명확한 책임 분리** | 2-3개 인스턴스 | 각 인스턴스가 독립적 |
| **4개 이상 필요** | 재검토 | 관리 복잡도 급증 |
| **팀 협업** | 2-3개/인 (최대 5-6개 총) | 개인별로 추천량 준수 |

---

## 다음 단계

병렬화 스케일링 결정을 했다면:

1. **[Git Worktrees Guide](./03-git-worktrees-setup.md)** - 기술적 설정
2. **[Instance Management](./04-managing-parallel-instances.md)** - 일상적 관리
3. **[Advanced Patterns](./05-advanced-parallelization.md)** - 심화 기법

---

**작성자**: claude-automate 문서팀
**마지막 수정**: 2026년 1월
**상태**: 작성 완료
**원본 출처**: Affaan Mustafa's Parallelization Strategy
