# Sub-agent Context Problem: When Agents Lose Critical Information

## 핵심 개념 (Core Concept)

**Sub-agent Context Problem**은 멀티-에이전트 시스템에서 발생하는 근본적인 한계입니다. **Orchestrator(조정자)는 전체 Semantic Context(의미론적 맥락)를 이해**하지만, **Sub-agent(부에이전트)는 오직 전달받은 Literal Query(문자 그대로의 쿼리)만 받습니다.**

이 차이로 인해 종종 **핵심 정보가 누락되고, Sub-agent는 불완전한 정보로 작업을 수행**하게 됩니다.

---

## 문제의 본질: The Boss and the Errand Analogy

### @PerceptualPeak의 비유 (The Boss Analogy)

상황을 상상해보세요. 당신은 회사의 CEO(Orchestrator)이고, 부하 직원(Sub-agent)이 있습니다.

#### 시나리오 1: 완벽한 Context를 가진 CEO

CEO의 머리 속:
```
"We're struggling with user retention because:
- Customer acquisition cost is up 40%
- Our pricing model isn't competitive
- Competitor X just launched a lower-cost alternative
- We need retention numbers to stay above 85%
- Engineering bandwidth is limited (3 people)
- Budget for this quarter is $50K

I need Sarah to:
1. Analyze competitor pricing (cost analysis)
2. Model our retention curve (data analysis)
3. Design a loyalty program (strategic design)
4. Estimate implementation cost (resource planning)

All while keeping in mind: quick wins first, cheaper solutions preferred."
```

CEO의 이 모든 생각은 **Semantic Context**입니다. 직관적으로 이해되는 의미론적 맥락입니다.

---

#### 시나리오 2: CEO가 Sub-agent에게 보내는 것

CEO가 생각한 것을 전부 전달하지 않고, 하나의 작업만 지시합니다:

```
CEO: "Sarah, 고객 유지율 문제를 해결하는 방안을 분석해줄래?"
```

**Sarah(Sub-agent)가 받은 것:**
- "고객 유지율 문제" (너무 광범위함)
- 해결 방법? (무엇을 분석해야 하는가?)
- 예산? (모름)
- 기술 제약? (모름)
- 우선순위? (모름)

#### 결과

```
Sarah의 보고서:
"고객 유지율 개선을 위해서는:
1. 심층 마케팅 분석 필요
2. 전체 고객 세그먼테이션 프로젝트 시작
3. 새 CRM 시스템 도입 (비용: $100K)
4. 완전한 UX 리디자인 (시간: 6개월)
..."

CEO의 반응:
"어? 이건 너무 복잡하고 비싸다.
내가 원하던 게 이게 아니었는데..."
```

#### 문제점

1. Sarah는 예산이 $50K라는 것을 몰랐다
2. Sarah는 팀이 3명뿐이라는 것을 몰랐다
3. Sarah는 "빠른 승리"가 필요하다는 것을 몰랐다
4. Sarah는 경쟁사 가격이 핵심이라는 것을 몰랐다

**Sarah는 최고의 분석을 했지만, CEO가 원하는 것이 아닙니다.**

---

## Sub-agent Context Problem의 기술적 원인

### 1️⃣ Context vs. Query

#### Orchestrator의 Semantic Context
```
{
  "project_state": {
    "current_issue": "user retention declining",
    "root_causes": ["pricing", "competitors", "features"],
    "business_metrics": {
      "target_retention": 0.85,
      "current_retention": 0.78,
      "acq_cost": "up 40%"
    }
  },
  "constraints": {
    "budget": "$50K",
    "team_size": 3,
    "timeline": "this quarter",
    "priority": "quick wins first"
  },
  "decision_history": [
    "Tried feature X - didn't work",
    "Considered Y - too expensive",
    "Z is our backup option"
  ]
}
```

**이것은 모두 Orchestrator의 머리 속에 있습니다.**

#### Sub-agent가 받는 것
```
"고객 유지율 문제를 해결하는 방안을 분석해줄래?"
```

**이것뿐입니다.**

### 2️⃣ Summary Loss Problem (요약 손실 문제)

Orchestrator가 Context를 요약하여 Sub-agent에게 전달하려고 해도, **중요한 세부사항이 자주 손실됩니다.**

#### 예제: 검색 작업

**원래 Orchestrator의 Context:**
```
"우리는 마이그레이션을 진행 중입니다:
- 기존: MongoDB (문서 기반)
- 신규: PostgreSQL (관계형)
- 주의: 필드 이름이 변경됨
  - old_user_id → user_uuid
  - email_addr → email (더 짧음)
  - created_at는 그대로
- 이미 마이그레이션된 테이블: users, products
- 아직 미마이그레이션: orders, payments
- 중요: orders 테이블에는 legacy 데이터가 남아있음
"
```

**Orchestrator가 Sub-agent에게 보내는 것:**
```
"orders 테이블에서 사용자 정보를 찾아줄래?"
```

**Sub-agent가 찾은 것:**
```sql
SELECT * FROM orders WHERE user_id = '123'
```

**문제:** old MongoDB 필드명을 사용했거나, legacy 데이터를 고려하지 않음

### 3️⃣ Assumption Mismatch (가정의 불일치)

Sub-agent는 자신의 **기본 가정(Default Assumptions)**으로 작업합니다.

```javascript
// Sub-agent가 가정:
"일반적인 사용자 검색이겠지"
"표준 프로세스를 따르겠지"
"특이한 제약이 없을 거야"

// 실제 Orchestrator의 의도:
"마이그레이션 중이다"
"특별한 처리가 필요하다"
"레거시 호환성을 유지해야 한다"
```

---

## 실제 시나리오: Context Loss의 진정한 비용

### 시나리오 1: API 통합 작업

#### Orchestrator의 머리 속
```
"우리는 Stripe 통합을 진행 중입니다:
- 결제만 처리하는 게 아니라
- 환불 처리도 해야 한다
- 그리고 부분 환불도 지원해야 한다
- 기존 결제 시스템과의 호환성을 유지해야 한다
- 테스트 카드는 이미 정의되어 있다
- 규정상 결제 로그는 90일 보관해야 한다"
```

#### Orchestrator가 Sub-agent에게 보내는 것
```
"Sub-agent, Stripe 결제 통합을 구현해줄래?"
```

#### Sub-agent가 구현하는 것
```python
# 기본적인 결제만 처리
stripe.charge.create(
    amount=amount,
    currency="usd",
    source=token
)
```

#### 결과
```
✗ 환불 처리 로직 없음
✗ 부분 환불 지원 안 함
✗ 호환성 코드 없음
✗ 로깅 미처리
✗ 재작업 필요
```

**손실된 시간:** 3-4시간 (디버깅, 수정, 재검토)

---

### 시나리오 2: 문서 작성 작업

#### Orchestrator의 머리 속
```
"우리는 새로운 API를 출시합니다:
- 이전 API와의 마이그레이션 가이드가 필요합니다
- 고객들은 2개월 유예 기간이 있습니다
- 일부 엔드포인트는 이름만 바뀌었습니다
- 일부는 전혀 다릅니다
- 인증 방식도 변경되었습니다 (Basic Auth → Bearer Token)
- 응답 형식도 일부 변경되었습니다
- 일부 고객은 아직도 구 API 사용 중입니다"
```

#### Orchestrator가 Sub-agent에게 보내는 것
```
"새 API 문서를 작성해줄래?"
```

#### Sub-agent가 작성하는 것
```markdown
# New API Documentation

## Endpoints
- GET /api/v2/users
- GET /api/v2/products
- POST /api/v2/orders
...
```

#### 문제
```
✗ 마이그레이션 가이드 없음
✗ 구 API 필드 매핑 없음
✗ 인증 변경사항 미언급
✗ 유예 기간 정보 없음
✗ 호환성 주의사항 없음
```

**결과:** 고객들이 혼란스러워하고, 지원 요청이 증가합니다.

---

## Context Problem의 영향 (Impact)

### 1️⃣ 재작업 (Rework)

```
원래 계획
└─ Sub-agent 작업
   ├─ 불완전한 결과
   ├─ Orchestrator 검토
   ├─ "이건 아닌데..."
   └─ 재작업 요청
      └─ Sub-agent 재작업
         └─ 더 많은 시간 소요
```

**비용:** 20-40% 추가 시간 소요

### 2️⃣ 품질 저하

Sub-agent는 최고의 노력을 하지만, **불완전한 정보로는 최고의 결과를 만들 수 없습니다.**

```
완벽한 Context → 완벽한 결과
불완전한 Context → 불완전한 결과 (아무리 똑똑한 Agent라도)
```

### 3️⃣ 의사소통 오버헤드

```
Orchestrator: "Sub-agent, 이 작업을 해줄래?"
Sub-agent: "네, 완료했습니다"
Orchestrator: "어? 이건 내가 원하던 게 아닌데"
Sub-agent: "아, 그래요? 어떻게 하면 되나요?"
Orchestrator: "음... 이렇게 했으면..."
Sub-agent: "알겠습니다. 다시 하겠습니다"
```

**손실된 시간:** 30분~1시간의 명확화 루프

### 4️⃣ 일관성 부족

Sub-agent들이 각각 다른 가정으로 작업하면:

```
Sub-agent A: "기본 기능만 구현하겠습니다"
Sub-agent B: "고급 기능까지 포함하겠습니다"
Sub-agent C: "에러 처리를 포함하겠습니다"

결과: 작업들이 일관성 없게 섞임
```

---

## Context Problem의 근본 원인

### 왜 이런 일이 생길까요?

#### 1. Token 제약 (Token Constraints)

```
Orchestrator의 전체 Context: 50,000 tokens
Sub-agent에게 보낼 수 있는 것: 5,000 tokens (10%)

손실되는 정보: 45,000 tokens (90%)
```

#### 2. 시간 제약 (Time Constraints)

```
Orchestrator: "Sub-agent, 이 일을 해줄래?"
Sub-agent: "네, 하겠습니다"

(Sub-agent는 모든 Context를 물어볼 시간이 없음)
```

#### 3. 설계 가정 (Design Assumptions)

Sub-agent는 "일반적인 경우"를 가정합니다:
- "표준 동작이겠지"
- "특별한 제약이 없겠지"
- "평범한 구현이면 되겠지"

---

## Context Problem 식별하기

### 체크리스트: Context 손실 감지

당신이 다음 중 하나라도 경험했다면, **Context Problem**이 있을 가능성이 높습니다:

- [ ] Sub-agent의 결과가 기대와 다르다
- [ ] "이건 내가 원하던 게 아닌데"라고 생각한다
- [ ] 재작업이 자주 필요하다
- [ ] Sub-agent가 중요한 제약을 놓친다
- [ ] 여러 Sub-agent 간에 작업 스타일이 일관성 없다
- [ ] Sub-agent가 "왜 이렇게 해야 하는지" 이해하지 못한다
- [ ] 비슷한 작업도 매번 다르게 처리된다
- [ ] Sub-agent가 "특이한" 요구사항을 자주 놓친다

---

## Context Problem의 후유증

### 실제 영향도 측정

#### 작은 프로젝트 (1-2주)

```
Context Loss 미처리:
- Sub-agent 재작업: 2-3시간
- Orchestrator 명확화: 1-2시간
- 최종 재검토: 1시간
= 총 4-6시간 손실 (20-30% 시간 낭비)

Context 제대로 처리:
- 처음부터 정확한 결과
- 최소한의 재검토
= 기본 시간 + 10%
```

**비용:** 작은 프로젝트에도 하루 종일 손실 가능

#### 중간 프로젝트 (1-2개월)

```
Context Loss 누적:
- 매주 5-10% 재작업
- 2개월 = 8주
- 누적 손실 = 40-80 시간
= 2주 이상의 시간 낭비
```

#### 대규모 팀 (5명 이상)

```
Context Loss (잘못된 방향):
- 모든 Sub-agent가 다른 가정으로 작업
- 통합 불가능
- 전체 재작업 필요
= 수 주일의 손실
```

---

## Context Problem 케이스 스터디

### 케이스 1: 마이크로서비스 마이그레이션

#### 상황
Orchestrator는 결정했습니다:
- 단계적 마이그레이션 (모든 서비스 동시 X)
- 호환성 레이어 필수
- 필드명 변경에 대한 매핑 필요
- 롤백 계획 필수

#### Sub-agent에게 보낸 것
```
"Service A를 새 아키텍처로 마이그레이션해줄래?"
```

#### Sub-agent가 이해한 것
```
"Service A를 새 기술 스택으로 완전히 다시 작성"
```

#### 결과
```
✗ 다른 서비스와 호환되지 않음
✗ 동시 실행 불가능
✗ 롤백 불가능
✗ 필드 매핑 누락
= 전체 재작업 필요
```

**손실 시간:** 2주

---

### 케이스 2: API 응답 스키마 변경

#### Orchestrator의 의도
```
"응답 필드를 다음과 같이 변경:
- user_id → id (짧게)
- full_name을 first_name + last_name으로 분리
- 레거시 호환성: id와 user_id 모두 포함
- 점진적 폐지 일정: 3개월
"
```

#### Sub-agent가 받은 것
```
"API 응답 스키마를 업데이트해줄래?"
```

#### Sub-agent가 구현
```json
{
  "id": 123,
  "first_name": "John",
  "last_name": "Doe"
}
```

#### 문제
```
✗ 레거시 user_id 필드 없음 (호환성 깨짐)
✗ 폐지 일정 없음
✗ 마이그레이션 가이드 없음
= 기존 클라이언트가 부서짐
```

---

## 다음 단계: Context Problem 해결하기

이 문제를 **해결하는 방법**은 다른 문서에서 다룹니다:

**📖 관련 문서들:**

1. **[Context Brokering Strategy](./02-context-brokering.md)** - Context를 효과적으로 전달하는 방법
2. **[Prompt Engineering for Sub-agents](./03-prompt-engineering.md)** - Sub-agent 프롬프트 작성 가이드
3. **[Sub-agent Capability Mapping](./04-capability-mapping.md)** - Sub-agent 능력 정의 및 제약 설정
4. **[Verification Loops](../03-verification-evals/01-observability-methods.md)** - 검증 루프로 Context Loss 감지

---

## 핵심 교훈 (Key Takeaway)

### The Boss Analogy의 교훈

```
❌ 잘못된 방법:
CEO: "고객 유지 문제 해결해줄래?"
Sarah: ??? (무엇을 해야 할지 모름)

✓ 올바른 방법:
CEO: "
우리의 상황:
- 유지율 목표: 85%
- 현재: 78%
- 예산: $50K
- 팀: 3명
- 시간: 이번 분기

해야 할 것:
1. 경쟁사 가격 분석 (우선순위 1)
2. 빠른 승리 방안 찾기 (우선순위 2)
3. 장기 대책은 나중에

제약:
- 간단한 솔루션부터
- 비싼 도구/서비스 피하기
"
Sarah: "이제 명확합니다. 2일 안에 분석 결과 드리겠습니다."
```

---

## 기억해야 할 것

1. **Sub-agent는 마인드 리더가 아닙니다**
   - 당신이 생각하는 것을 자동으로 알지 못합니다
   - Context를 명시적으로 전달해야 합니다

2. **문자 그대로의 쿼리는 불완전합니다**
   - "고객 유지 문제 해결" = 너무 광범위
   - Context 없이는 대부분의 가정이 틀립니다

3. **Summary는 항상 손실됩니다**
   - 50,000 tokens → 5,000 tokens = 90% 손실
   - 중요한 세부사항이 빠집니다

4. **재작업은 예측 가능합니다**
   - Context 없으면 재작업 확률 = 50-80%
   - Context 명확하면 재작업 확률 = 5-10%

5. **Context 투자는 최고의 ROI입니다**
   - 5분의 Context 준비 = 2시간 절감
   - 40배 ROI

---

<div align="center">

### Sub-agent와의 협력은 Context 투명성에서 시작됩니다

**"당신이 알아야 할 모든 것을 전달하세요. 그러면 Sub-agent는 최고의 결과를 만듭니다."**

</div>
