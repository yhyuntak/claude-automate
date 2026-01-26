# Agent Abstraction Tier List: 복잡도에 따른 선택 가이드

> **Credit**: 이 문서는 [@menhguin](https://github.com/menhguin)의 Agent Abstraction Tier List 개념을 기반으로 작성되었습니다.

## 개요

**Agent Abstraction Tier List**는 멀티 에이전트 시스템을 구축할 때 **복잡도 수준에 맞는 기법을 선택**하도록 도와줍니다.

### 핵심 개념

Agent 시스템에는 다양한 구현 방식이 있습니다:

- **간단한 것부터 복잡한 것까지** 스펙트럼이 존재
- **초보자는 기초부터 시작**하고, **필요할 때만 고도의 기법 사용**
- **모든 프로젝트가 복잡한 시스템이 필요한 건 아님**

이 가이드는 당신의 **프로젝트 복잡도**에 맞는 적절한 추상화 수준을 선택하는 방법을 제시합니다.

---

## 🎯 Tier List Overview (전체 구조)

### Quick Reference Table

| Tier | 기법 (한국어) | Technique (English) | 난이도 | 시작점 | 추천 대상 |
|------|------------|-----------------|--------|--------|----------|
| **1️⃣ Tier 1** | 직접 보상 | Direct Buffs | 쉬움 ⭐ | ✅ 여기서 시작 | 모든 초보자 |
| | • 서브에이전트 | • Subagents | | | |
| | • 메타프롬팅 | • Metaprompting | | | |
| | • 초기 사용자 조사 | • User Questioning | | | |
| **2️⃣ Tier 2** | 고급 기법 | Advanced Techniques | 어려움 ⭐⭐⭐ | ⚠️ 필요할 때만 | 마스터 후 |
| | • 장시간 에이전트 | • Long-running Agents | | | |
| | • 병렬 멀티 에이전트 | • Parallel Multi-Agent | | | |
| | • 역할 기반 멀티 에이전트 | • Role-Based Multi-Agent | | | |
| | • 컴퓨터 사용 에이전트 | • Computer Use Agents | | | |

---

## Tier 1: Direct Buffs (초보자 친화형)

### 개념

**Tier 1**은 기본적인 Agent 시스템을 구축하는 가장 간단하고 효과적인 방법들을 제시합니다.

이 단계에서는:
- 복잡한 아키텍처 없이 빠르게 시작 가능
- 대부분의 프로젝트에서 충분한 성능
- 이해하고 유지보수하기 쉬움

### Tier 1-1: Subagents (서브에이전트)

#### 개념

여러 개의 **특화된 에이전트**를 생성하고, 각 에이전트가 특정 영역에 집중하도록 설계합니다.

```
메인 에이전트
├── 검색 에이전트 (Search Agent)
├── 분석 에이전트 (Analyzer Agent)
├── 문서 작성 에이전트 (Document Writer)
└── 코드 리뷰 에이전트 (Code Reviewer)
```

#### 장점

✅ **간단하고 명확**: 각 에이전트의 책임이 명확
✅ **적절한 모델 선택**: 각 작업에 최적의 모델 할당 가능
✅ **비용 절감**: Haiku로 간단한 작업 처리 (30-70% 절감)
✅ **유지보수 용이**: 한 에이전트의 변경이 다른 에이전트에 영향 최소화
✅ **병렬 실행**: 독립적인 작업을 동시에 처리 가능

#### 실제 예제

```yaml
# agents/config.yaml
agents:
  - name: file-explorer
    model: haiku  # 빠른 검색 → 저렴한 모델
    role: Find and list files
    capabilities:
      - file_search
      - pattern_matching

  - name: code-analyzer
    model: sonnet  # 표준 분석 → 균형잡힌 모델
    role: Analyze code structure and patterns
    capabilities:
      - code_analysis
      - architecture_review

  - name: strategist
    model: opus  # 복잡한 설계 → 최고 성능 모델
    role: Design architecture and strategy
    capabilities:
      - system_design
      - decision_making
```

#### 언제 사용할까?

- ✅ 프로젝트 시작 단계
- ✅ 팀 규모: 1-5명
- ✅ 작업의 종류가 명확히 구분되는 경우
- ✅ 비용 최적화가 중요할 때
- ✅ 각 작업별 최적의 모델을 원할 때

#### 일반적인 에이전트 구성

```javascript
// 실제 구현 예제
const agents = {
  explore: {        // 검색 전문가
    model: "haiku",
    role: "Fast file and pattern searching"
  },
  analyzer: {       // 분석 전문가
    model: "sonnet",
    role: "Code and architecture analysis"
  },
  oracle: {         // 전략가
    model: "opus",
    role: "Complex reasoning and design"
  }
};

// 작업 위임
async function delegateTask(task) {
  if (task.type === 'search') {
    return await invokeAgent(agents.explore, task);
  } else if (task.type === 'analysis') {
    return await invokeAgent(agents.analyzer, task);
  } else if (task.type === 'strategy') {
    return await invokeAgent(agents.oracle, task);
  }
}
```

---

### Tier 1-2: Metaprompting (메타프롬팅)

#### 개념

**Metaprompting**은 에이전트에게 **자신의 사고 과정과 의사결정 방식을 명시적으로 정의**하도록 하는 기법입니다.

```
일반 프롬프트:
"코드를 분석해줘"

메타프롬프트:
"다음 단계를 따라 코드를 분석해줘:
1. 구조 파악
2. 보안 취약점 확인
3. 성능 문제 식별
4. 개선 방안 제시"
```

#### 장점

✅ **일관된 결과**: 같은 형식의 출력을 기대할 수 있음
✅ **더 깊은 분석**: 체계적인 접근으로 놓치는 부분 감소
✅ **추적 가능**: 에이전트의 사고 과정을 명확히 볼 수 있음
✅ **신뢰성**: 결과에 대한 신뢰도 증가
✅ **추가 비용 없음**: 같은 모델로 더 좋은 결과

#### 실제 예제

```markdown
## System Prompt (메타프롬프트)

당신은 고급 코드 리뷰 전문가입니다.
다음의 구조화된 방식으로 코드를 분석합니다:

### 분석 단계
1. **구조 분석** (Structure Analysis)
   - 파일 구조와 모듈화 평가
   - 의존성 관계 확인

2. **기능 검토** (Functionality Review)
   - 코드의 의도와 실제 동작 비교
   - 엣지 케이스 확인

3. **성능 평가** (Performance Assessment)
   - 시간 복잡도 분석
   - 메모리 사용량 평가

4. **보안 검토** (Security Review)
   - 잠재적 취약점 식별
   - OWASP Top 10 확인

5. **개선 제안** (Recommendations)
   - 구체적이고 실행 가능한 개선안
   - 우선순위 표시

### 출력 형식
결과는 다음의 Markdown 구조로 제공합니다:

## Review Summary
[한 문장 요약]

## Scores
| 항목 | 점수 | 코멘트 |
|------|------|--------|
| Structure | X/10 | ... |
| Performance | X/10 | ... |
| Security | X/10 | ... |

## Detailed Findings
### Critical Issues
- ...

### Warnings
- ...

## Recommendations
1. [구체적 개선안]
```

#### 예제: 메타프롬프트의 효과 비교

```javascript
// ❌ 기본 프롬프트 (결과 편차 큼)
"리뷰해줘"

출력 예시:
- 불규칙한 형식
- 깊이 부족
- 일관성 없는 분석
시간: 3초

// ✅ 메타프롬프트 (결과 일관성 높음)
"다음 체크리스트에 따라 리뷰해줘:
  1. 구조
  2. 성능
  3. 보안
  4. 테스트
각 항목마다 10점 척도와 구체적 개선안을 제시"

출력 예시:
- 정형화된 형식
- 깊이 있는 분석
- 항상 일관된 구조
시간: 4초 (+33% 시간, 훨씬 나은 품질)
```

#### 언제 사용할까?

- ✅ 일관된 형식의 결과가 필요할 때
- ✅ 다양한 에이전트 간 포맷 통일
- ✅ 자동화 파이프라인 구축
- ✅ 결과 검증 자동화
- ✅ 에이전트의 사고 과정 추적 필요

#### 메타프롬프트 템플릿

```yaml
# metaprompting-templates.yaml

code_review_template:
  analysis_steps:
    - name: "Structure Analysis"
      description: "파일과 모듈 구조 평가"
      output_format: "Markdown list"

    - name: "Performance Check"
      description: "시간/공간 복잡도 분석"
      output_format: "Big-O notation with examples"

    - name: "Security Audit"
      description: "보안 취약점 식별"
      output_format: "CVSS score + recommendation"

  output_structure:
    - summary: "한 문장 요약"
    - scores: "표로 된 점수"
    - details: "상세 분석"
    - recommendations: "구체적 개선안"

architecture_review_template:
  analysis_steps:
    - "컴포넌트 식별"
    - "데이터 흐름 추적"
    - "의존성 관계 분석"
    - "확장성 평가"
    - "리스크 식별"

  decision_tree:
    - "설계 패턴 식별"
    - "패턴의 적절성 평가"
    - "대체 패턴 제안"
```

---

### Tier 1-3: User Questioning (초기 사용자 조사)

#### 개념

**프로젝트 시작 전**에 사용자(또는 개발자)에게 **상세한 질문을 통해 충분한 정보 수집**하고, 이를 기반으로 더 정확한 에이전트 지시사항 작성합니다.

```
상황 1: 애매한 요구사항
사용자: "로그인 기능을 추가해줘"

에이전트 질문 (metis/prometheus):
1. 어떤 인증 방식? (JWT, OAuth, 세션?)
2. 어떤 사용자 정보 저장? (메일, 전화번호, SNS ID?)
3. 보안 요구사항? (2FA, 비밀번호 정책?)
4. 성능 요구사항? (동시 사용자 수?)

결과: 정확한 설계 → 올바른 구현
```

#### 장점

✅ **불확실성 제거**: 프로젝트 시작 전에 명확한 요구사항 확립
✅ **재작업 감소**: 변경사항 최소화로 시간 절감
✅ **올바른 기술 선택**: 정보 기반 의사결정
✅ **더 정확한 추정**: 현실적인 일정 계획
✅ **팀 정렬**: 모든 팀원이 같은 목표 공유

#### 실제 예제

```markdown
## Pre-Project Interview Protocol (프로젝트 전 인터뷰)

### Phase 1: Requirements Clarification (요구사항 명확화)

**Question 1: Core Functionality**
- "이 기능의 주요 목적은 무엇인가요?"
- "사용자가 주로 어떤 작업을 할 건가요?"
- "성공 지표는 무엇인가요?"

**Question 2: User Profile**
- "주 사용자는 누구인가요?"
- "기술 수준이 어느 정도인가요?"
- "예상 사용자 수는?"

**Question 3: Non-Functional Requirements**
- "성능 요구사항 (응답 시간, 처리량)?"
- "확장성은 얼마나 중요한가요?"
- "높은 가용성이 필요한가요?"

### Phase 2: Technical Constraints (기술 제약사항)

**Question 4: Existing Systems**
- "기존 시스템과의 통합 필요한가요?"
- "사용 중인 기술 스택은?"
- "마이그레이션 필요한가요?"

**Question 5: Data & Security**
- "어떤 데이터를 다루나요?"
- "데이터 민감도 수준은?"
- "규제 요구사항 (GDPR, HIPAA 등)?"

### Phase 3: Timeline & Resources (일정과 리소스)

**Question 6: Schedule & Budget**
- "목표 출시일은?"
- "사용 가능한 예산은?"
- "인원은?"

### Example Output

프로젝트: "실시간 알림 시스템"

인터뷰 결과:
```yaml
requirements:
  core: "사용자에게 즉시 알림 전달"
  users: "1000-5000 동시 사용자"
  success_metric: "1초 이내 전달률 95%"

constraints:
  existing_db: "PostgreSQL"
  notification_channels: ["Email", "SMS", "In-app"]
  latency: "< 100ms"

timeline:
  deadline: "3개월"
  phases:
    - "DB 설계 (2주)"
    - "API 구현 (4주)"
    - "프론트엔드 (3주)"
    - "테스트 및 최적화 (2주)"

결과:
- WebSocket 기반 실시간 시스템 선택
- Redis를 message queue로 사용
- 마이크로서비스 아키텍처
```
```

#### 언제 사용할까?

- ✅ 새 프로젝트 시작
- ✅ 요구사항이 불명확할 때
- ✅ 큰 의사결정이 필요할 때
- ✅ 팀이 요구사항 이해가 다를 때

#### Prometheus를 이용한 자동 인터뷰

```javascript
// claude-automate에서 /prometheus 또는 /plan 명령 사용
// 자동으로 사용자 조사를 진행하고 계획 수립

// 1. 요구사항 수집
await invokeSkill('oh-my-claude-sisyphus:prometheus', {
  prompt: `사용자의 다음 요청에 대해 상세히 질문해줘:
  "${userRequest}"`
});

// 2. 계획 수립
// Prometheus가 사용자 질문과 답변을 바탕으로 전략적 계획 생성

// 3. 계획 검증
await invokeSkill('oh-my-claude-sisyphus:review', {
  plan: generatedPlan
});
```

---

## Tier 2: Advanced Techniques (고급 기법)

### ⚠️ 주의사항

Tier 2 기법들은:
- **높은 학습 곡선**: 숙련도 필요
- **복잡한 디버깅**: 문제 추적이 어려울 수 있음
- **유지보수 비용 증가**: 더 복잡한 아키텍처
- **대부분의 프로젝트에서 불필요**: Tier 1로 충분한 경우 많음

**따라서:**
- ⚠️ Tier 1을 먼저 완전히 마스터하세요
- ⚠️ Tier 2가 진짜 필요할 때만 도입하세요
- ⚠️ 명확한 비즈니스 이유가 있어야 합니다

### Tier 2-1: Long-Running Agents (장시간 실행 에이전트)

#### 개념

하나의 에이전트가 **시간이 오래 걸리는 작업을 자체적으로 처리**하고, **상태를 유지**하면서 **필요시 도움을 요청**합니다.

```
예제: 대규모 리팩토링 작업

일반적 방식 (Tier 1):
메인 → 파일1 분석 에이전트 → 메인
메인 → 파일2 분석 에이전트 → 메인
메인 → 파일3 분석 에이전트 → 메인
...

장시간 에이전트 방식 (Tier 2):
메인 → [리팩토링 에이전트 (계속 실행)]
         ├─ 파일1 분석
         ├─ 파일2 분석
         ├─ 파일3 분석
         └─ 패턴 통합 + 최적화
```

#### 장점

✅ **컨텍스트 유지**: 전체 작업을 통해 일관성 유지
✅ **글로벌 최적화**: 개별 결과가 아닌 전체 최적화 가능
✅ **패턴 인식**: 여러 파일에 걸친 패턴 발견
✅ **자동 조정**: 진행 상황에 따라 전략 조정

#### 단점

❌ **더 비쌈**: 오래 실행되므로 토큰 사용 많음
❌ **추적 어려움**: 진행 상황 모니터링 필요
❌ **복잡함**: 상태 관리가 복잡
❌ **에러 처리**: 중간에 실패하면 처음부터 다시 시작 가능성

#### 언제 사용할까?

- ⚠️ 매우 큰 규모 작업 (1000+ 파일)
- ⚠️ 전체 최적화가 중요한 경우
- ⚠️ 파일 간 높은 상관관계 있는 경우
- ⚠️ Tier 1 (병렬 처리)로 충분하지 않은 경우

---

### Tier 2-2: Parallel Multi-Agent (병렬 멀티 에이전트)

#### 개념

여러 에이전트가 **동시에 독립적인 작업을 처리**하고, **마지막에 결과를 통합**합니다.

```
예제: 대규모 코드 리뷰

병렬 실행:
메인 →┬→ 에이전트1: 파일 A, B, C (보안 리뷰)
      ├→ 에이전트2: 파일 A, B, C (성능 리뷰)
      ├→ 에이전트3: 파일 A, B, C (코드 품질)
      └→ 에이전트4: 파일 A, B, C (아키텍처)

메인: 모든 결과 수집 → 통합 → 최종 리포트
```

#### 장점

✅ **빠른 처리**: 여러 작업 동시 진행 (최대 5개 병렬)
✅ **다각도 분석**: 여러 관점의 리뷰
✅ **토큰 절감**: 각 에이전트의 컨텍스트 작음
✅ **확장 가능**: 작업 크기에 따라 에이전트 수 조정 가능

#### 단점

❌ **API 호출 많음**: 더 많은 API 요청
❌ **오케스트레이션 복잡**: 에이전트 조정이 복잡
❌ **결과 통합 어려움**: 중복/충돌 가능성
❌ **비용 예측 어려움**: 토큰 사용량 계산 복잡

#### 실제 예제

```javascript
// parallel-agent-executor.js

async function parallelReview(files) {
  // Tier 1: 빠른 검색
  const fileMetadata = await invokeAgent(explorer, {
    task: `파일 정보 수집: ${files}`
  });

  // Tier 2: 병렬 멀티 에이전트
  const reviews = await Promise.all([
    invokeAgent(securityAgent, {
      task: `${files}의 보안 이슈 검토`
    }),

    invokeAgent(performanceAgent, {
      task: `${files}의 성능 문제 검토`
    }),

    invokeAgent(qualityAgent, {
      task: `${files}의 코드 품질 검토`
    }),

    invokeAgent(architectureAgent, {
      task: `${files}의 아키텍처 검토`
    })
  ]);

  // 결과 통합
  return await integrationAgent.synthesize(reviews);
}
```

#### 언제 사용할까?

- ⚠️ 매우 큰 작업 (독립적인 부분 분해 가능)
- ⚠️ 시간이 매우 중요한 경우
- ⚠️ 여러 관점의 분석이 필요한 경우
- ⚠️ 에이전트 오케스트레이션 능력 있을 때

#### claude-automate에서의 사용

```bash
# parallelization 섹션 참고
# docs/longform-guide/04-parallelization/README.md

# 기본 병렬 처리
Task task1 = asyncInvoke(agent1, input1)
Task task2 = asyncInvoke(agent2, input2)
Task task3 = asyncInvoke(agent3, input3)

await waitAll([task1, task2, task3])
```

---

### Tier 2-3: Role-Based Multi-Agent (역할 기반 멀티 에이전트)

#### 개념

각 에이전트가 **명확한 역할과 책임**을 가지고, 에이전트들 간 **동적인 커뮤니케이션**이 이루어집니다.

```
예제: 아키텍처 설계 미팅

시나리오:
메인 → [아키텍처 설계 미팅 진행]
  ├─ Presenter: "현재 상황을 팀에 설명"
  ├─ Architect: "3가지 설계안 제시"
  ├─ DevOps: "배포 관점에서 평가"
  ├─ Security: "보안 측면 평가"
  └─ Presenter: "최종 설계안 정리"
```

#### 특징

- **에이전트 간 대화**: 토론을 통한 더 나은 결정
- **역할 명확화**: 각 에이전트의 책임 분명
- **반복적 개선**: 여러 라운드의 토론
- **투명성**: 의사결정 과정이 명확함

#### 장점

✅ **높은 품질**: 다양한 관점의 검토
✅ **의사결정 추적**: 왜 이런 결정을 내렸는지 명확
✅ **전문 지식 활용**: 각 역할의 전문성 최대화
✅ **협력**: 에이전트 간 협력으로 시너지

#### 단점

❌ **매우 복잡**: 구현이 매우 복잡함
❌ **통제 어려움**: 토론이 발산될 수 있음
❌ **비용 높음**: 여러 라운드의 상호작용
❌ **시간 오래 걸림**: 토론 시간 필요

#### 언제 사용할까?

- ⚠️ 복잡한 전략적 결정 필요
- ⚠️ 여러 이해관계자 의견 수렴 필요
- ⚠️ 높은 품질이 매우 중요한 경우
- ⚠️ 의사결정 근거 기록 필요

#### 예제: 아키텍처 선택 토론

```yaml
# role-based-discussion.yaml

meeting_scenario: "API Gateway 선택 회의"

roles:
  presenter:
    name: "발표자"
    role: "회의 진행, 결과 정리"

  architect:
    name: "아키텍처 전문가"
    role: "기술적 설계 검토"
    concerns:
      - "확장성"
      - "유지보수성"
      - "성능"

  devops:
    name: "DevOps 엔지니어"
    role: "배포 및 운영 관점 검토"
    concerns:
      - "배포 복잡도"
      - "모니터링"
      - "비용"

  security:
    name: "보안 담당자"
    role: "보안 측면 검토"
    concerns:
      - "인증/인가"
      - "데이터 보호"
      - "감시"

options:
  - name: "Kong"
    pros: ["완벽한 기능", "확장 가능"]
    cons: ["높은 학습곡선", "운영 복잡"]

  - name: "NGINX"
    pros: ["가볍고 빠름", "안정적"]
    cons: ["기능 제한", "복잡한 설정"]

  - name: "AWS API Gateway"
    pros: ["관리형", "자동 확장"]
    cons: ["벤더 종속", "비용"]

discussion_flow:
  1. "Presenter가 옵션 소개"
  2. "Architect이 기술적 평가"
  3. "DevOps가 운영 관점 평가"
  4. "Security가 보안 평가"
  5. "토론 및 질문"
  6. "투표 또는 합의"
  7. "Presenter가 최종 결정 정리"
```

---

### Tier 2-4: Computer Use Agents (컴퓨터 사용 에이전트)

#### 개념

에이전트가 **실제 컴퓨터를 제어**하여 (마우스, 키보드) **자동으로 작업을 수행**합니다.

```
예제: 웹 애플리케이션 테스팅

컴퓨터 사용 에이전트:
1. 브라우저 열기
2. URL 입력
3. 로그인 폼 작성
4. 제출 버튼 클릭
5. 결과 확인
6. 스크린샷 캡처
7. 버그 보고
```

#### 장점

✅ **완전 자동화**: 사람의 개입 없음
✅ **실제 환경 테스팅**: 실제 UI 동작 확인
✅ **GUI 작업 자동화**: 자동화하기 어려운 작업도 가능
✅ **24/7 작동**: 지속적인 모니터링/테스팅

#### 단점

❌ **가장 복잡**: 구현이 매우 어려움
❌ **느림**: 사람보다 훨씬 느릴 수 있음
❌ **안정성 낮음**: UI 변화에 취약
❌ **고비용**: 많은 리소스 필요

#### 언제 사용할까?

- ⚠️ GUI 자동화가 필수적인 경우
- ⚠️ 반복적이고 예측 가능한 작업
- ⚠️ 테스팅 자동화
- ⚠️ 대규모 데이터 입력
- ⚠️ 다른 방법이 없을 때

#### 현재 상태

Claude의 Computer Use 기능은:
- 아직 **베타 단계**
- 매우 **제한적**
- **높은 비용**
- **Tier 2 이상의 고급 기법**

따라서 대부분의 경우 **이 기능이 필요하지 않습니다.**

---

## 🎯 어떤 Tier를 선택할까?

### Decision Tree (의사결정 트리)

```
프로젝트 시작
│
├─ 프로젝트 규모는?
│  ├─ 작음 (< 10 파일)
│  │  └─ Tier 1 충분 → Subagents + Metaprompting
│  │
│  ├─ 중간 (10-100 파일)
│  │  ├─ 병렬화 가능한가?
│  │  │  ├─ Yes → Tier 1 (Parallel Subagents)
│  │  │  └─ No → Tier 1 (Sequential)
│  │  └─ User Questioning으로 명확화
│  │
│  └─ 크다 (> 100 파일)
│     ├─ 작업이 독립적인가?
│     │  ├─ Yes → Tier 1 (Parallel Subagents)
│     │  └─ No → Tier 2 (Long-running 또는 Role-based) ⚠️
│     └─ 먼저 Tier 1 시도해보세요!
│
├─ 결과 품질이 충분한가?
│  ├─ Yes → Tier 1 유지
│  └─ No → Metaprompting 개선 또는 모델 업그레이드
│
├─ 의사결정 추적이 필요한가?
│  ├─ Yes → Role-Based Multi-Agent (Tier 2) ⚠️
│  └─ No → Tier 1 계속
│
└─ 시간이 매우 중요한가?
   ├─ Yes → Parallel Multi-Agent (Tier 2) ⚠️
   └─ No → Tier 1 (효율성 더 좋음)
```

### 프로젝트별 추천 구성

#### Scenario 1: 작은 팀의 일반 프로젝트 (가장 일반적)

```yaml
구성:
  - Subagents (Tier 1-1) ✅
  - Metaprompting (Tier 1-2) ✅
  - User Questioning (Tier 1-3) ✅

이유:
  - 충분한 성능
  - 낮은 복잡도
  - 유지보수 용이
  - 비용 효율적

예시:
  - 웹 개발: 프론트엔드, 백엔드, 테스트 에이전트
  - 데이터 파이프라인: 수집, 처리, 분석 에이전트
  - 문서 생성: 검색, 작성, 검수 에이전트
```

#### Scenario 2: 대규모 엔터프라이즈 프로젝트

```yaml
구성:
  - Tier 1 (기초): Subagents + Metaprompting + User Questioning
  - + Tier 2 추가: 병렬 멀티 에이전트 (시간 중요)

언제 Tier 2 추가할까?
  1. Tier 1로 충분한지 확인 (대부분의 경우 충분)
  2. 명확한 성능 병목 확인
  3. ROI 분석 (Tier 2 추가 비용 < 절감 시간)
  4. 그제서야 Tier 2 도입

반대로:
  ❌ "엔터프라이즈니까 복잡해야 한다" (X)
  ✅ "필요할 때만, 증거 기반으로" (O)
```

#### Scenario 3: 실시간 결정이 중요한 전략 프로젝트

```yaml
구성:
  - Tier 1: Subagents + User Questioning + Metaprompting
  - 전략: /prometheus 사용 (자동 인터뷰 + 계획)
  - 검증: /review로 계획 검토

  선택적으로 (필요시만):
  - Role-Based Multi-Agent (Tier 2)
    (예: 아키텍처 선택 토론)

핵심:
  - 먼저 Tier 1으로 시작
  - 필요함을 증명한 후에만 Tier 2
```

---

## 📊 Tier 비교 표

### 전체 비교

| 항목 | Tier 1-1 Subagents | Tier 1-2 Metaprompting | Tier 1-3 User Q | Tier 2-1 Long | Tier 2-2 Parallel | Tier 2-3 Role-Based | Tier 2-4 Computer |
|------|-------------------|----------------------|-----------------|----------------|------------------|-------------------|------------------|
| **난이도** | ⭐ | ⭐ | ⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **구현 시간** | 30분 | 1시간 | 2시간 | 1-2일 | 1-2일 | 3-5일 | 1주+ |
| **유지보수** | 쉬움 | 중간 | 중간 | 어려움 | 어려움 | 매우 어려움 | 매우 어려움 |
| **문제 추적** | 쉬움 | 쉬움 | 중간 | 어려움 | 어려움 | 매우 어려움 | 매우 어려움 |
| **비용** | 낮음 | 낮음 | 낮음 | 높음 | 높음 | 매우 높음 | 매우 높음 |
| **속도** | 빠름 | 빠름 | 중간 | 느림 | 매우 빠름 | 느림 | 매우 느림 |
| **품질** | 높음 | 높음 | 높음 | 높음 | 높음 | 매우 높음 | 중간-높음 |
| **프로젝트 필요도** | 90% | 70% | 100% (시작시) | 5% | 20% | 2% | 1% |

### 실제 프로젝트에서의 사용 빈도

```
Tier 1-1 Subagents: ████████████████████ 95% (거의 모든 프로젝트)
Tier 1-2 Metaprompting: ██████████████ 70% (대부분 권장)
Tier 1-3 User Q: ██████████████████ 90% (초기 단계 필수)

Tier 2-1 Long-running: ██ 5% (매우 드문 경우)
Tier 2-2 Parallel: ████ 20% (큰 프로젝트에서 유용)
Tier 2-3 Role-Based: ░░ 2% (극히 드문 경우)
Tier 2-4 Computer Use: ░ 1% (매우 드문 경우)
```

---

## 🚀 실전 가이드: Tier 선택 및 적용

### Step 1: Tier 1로 시작하세요

```javascript
// 프로젝트 초기 구성
const agents = {
  // Subagents (Tier 1-1)
  explorer: { model: "haiku", role: "빠른 검색" },
  analyzer: { model: "sonnet", role: "분석" },
  strategist: { model: "opus", role: "설계" }
};

// Metaprompting (Tier 1-2)
const systemPrompt = `
분석 단계:
1. 구조 파악
2. 문제 식별
3. 개선안 제시
`;

// User Questioning (Tier 1-3)
// /prometheus 또는 /plan 사용으로 자동 구현
```

### Step 2: 성능을 측정하세요

```javascript
// 메트릭 수집
const metrics = {
  time: measureExecutionTime(),
  cost: calculateTokenCost(),
  quality: evaluateOutputQuality(),
  accuracy: compareWithExpected()
};

console.log(`
성능 리포트:
- 시간: ${metrics.time}ms
- 비용: $${metrics.cost}
- 품질: ${metrics.quality}/10
- 정확도: ${metrics.accuracy}%
`);
```

### Step 3: 병목을 식별하세요

```javascript
// 성능이 부족한가?
if (metrics.time > 30000) {  // 30초 초과
  // 원인 분석
  if (canParallelize()) {
    console.log("→ Tier 2-2 (병렬) 고려");
  } else {
    console.log("→ 모델 업그레이드 고려");
  }
}

// 품질이 부족한가?
if (metrics.quality < 7) {
  console.log("→ Metaprompting 개선");
  console.log("→ 또는 모델 업그레이드");
}
```

### Step 4: Tier 2가 정말 필요한가 재검토하세요

```javascript
// 대부분의 경우 답은 "아니오"입니다

// ❌ 틀린 생각
"엔터프라이즈 프로젝트니까 복잡해야 한다"
"병렬이 더 빠를 거야"
"고급 기법을 써야 전문적이다"

// ✅ 올바른 생각
"Tier 1로 충분한가?"
"ROI가 있는가?"
"증거가 있는가?"

// 우선순위
1. Tier 1 완벽히 마스터
2. 명확한 필요성 증명
3. 그제서야 Tier 2 고려
```

---

## 💡 Best Practices (최적 사례)

### Rule 1: 항상 Tier 1부터 시작하세요

```javascript
// ✅ 올바른 접근
프로젝트 시작 → Tier 1 (Subagents + Metaprompting)
               ↓ (성능 측정)
               충분한가?
               ├─ Yes → Tier 1 유지 (90% 경우)
               └─ No → 최적화 또는 Tier 2

// ❌틀린 접근
프로젝트 시작 → "복잡할 것 같은데?" → Tier 2 도입
               → 디버깅 지옥
               → 유지보수 악몽
```

### Rule 2: 측정 없는 최적화는 하지 마세요

```javascript
// ❌ 나쁜 예
"병렬이 더 빠를 거야" → Tier 2-2 도입
// 결과: 더 복잡해지고 거의 빨라지지 않음

// ✅ 좋은 예
시간 측정 → "30초 → 10초로 줄여야 한다"
        → "병렬로 3배 빠르게 할 수 있나?"
        → Yes → Tier 2-2 도입
        → No → 다른 최적화 방법
```

### Rule 3: 복잡도는 단계적으로 증가시키세요

```
Week 1: Subagents 단독
Week 2: + Metaprompting 추가
Week 3: 성능 측정 및 평가
Week 4-5: 필요하면만 Tier 2 고려

불가능한 것:
Week 1부터 Role-Based Multi-Agent 시도
→ 너무 복잡
→ 실패할 가능성 높음
```

### Rule 4: 팀의 숙련도를 고려하세요

```yaml
팀 구성:
  - 초보자만: Tier 1만 사용
  - 중급 개발자: Tier 1 + 선택적 Tier 2
  - 전문가 팀: 필요시 모든 Tier 사용 가능

권장사항:
  - 처음 2-3개월: Tier 1 마스터
  - 이후 3-6개월: Tier 2 기초 학습
  - 6개월 이후: 필요시 Tier 2 도입
```

---

## ❓ FAQ (자주 묻는 질문)

### Q1: 언제 Tier 2를 사용해야 하나요?

**A:** 대부분의 경우 **절대 필요하지 않습니다**.

다음을 모두 만족할 때만:
1. Tier 1로 1-3개월 경험
2. 명확한 성능 병목 확인 (측정 데이터)
3. ROI 계산 완료 (이득 > 비용)
4. 팀의 기술 수준이 충분한 경우
5. Tier 2가 문제를 해결할 거 확신

대부분은 1-3번에서 탈락합니다.

---

### Q2: Tier 2-2 (병렬)가 항상 더 빠르지 않나요?

**A:** 아니요. 오버헤드가 있습니다.

```
병렬의 오버헤드:
- API 호출 비용
- 결과 통합 비용
- 디버깅 비용

작은 작업:
순차 (1s) vs 병렬 (3s + 통합)
→ 순차가 더 빠름

큰 작업 (4개 이상 독립적):
순차 (10s + 10s + 10s + 10s = 40s)
vs
병렬 (10s, 10s, 10s, 10s 동시 = 10s)
→ 병렬이 4배 빠름

따라서:
- 작은 작업: 순차 (Tier 1)
- 큰 작업: 병렬 (Tier 2)
```

---

### Q3: Metaprompting을 항상 해야 하나요?

**A:** 네, 거의 항상 도움됩니다.

```javascript
// Metaprompting 없음
"코드 분석해줘"
→ 불규칙한 결과
→ 어떤 때는 깊고 어떤 때는 얕음
→ 자동화 어려움

// Metaprompting 있음
"이 체크리스트에 따라 분석:
1. 구조
2. 성능
3. 보안
각 항목에 10점 척도 + 개선안"
→ 일관된 결과
→ 항상 깊이 있음
→ 자동화 가능
```

비용: +0-10% token (무시할 수준)
이득: +50-100% 품질

**따라서 항상 하세요.**

---

### Q4: 언제 Haiku 대신 Sonnet을 써야 하나요?

**A:** 불명확하면 **Sonnet이 기본값**입니다.

```
Haiku 선택:
- 빠른 검색 (파일 찾기, 패턴 매칭)
- 간단한 추출
- 비용이 절대적으로 중요

Sonnet 선택:
- 코드 분석
- 문서 작성
- 종합적인 검토
- "뭘 써야 할지 모르겠는데?"

Opus 선택:
- 아키텍처 설계
- 복잡한 문제 해결
- 전략적 결정
- 매우 높은 정확도 필수
```

데이터: 대부분의 프로젝트는 Haiku(20%), Sonnet(70%), Opus(10%)

---

### Q5: "아무래도 복잡할 것 같으니" Tier 2부터 시작하면?

**A:** 절대로 하지 마세요.

```
실제 경험:
초보 팀이 Tier 2부터 시작
→ 구현 3배 시간 소요
→ 버그 5배 많음
→ 유지보수 불가능
→ 결국 Tier 1로 회귀

올바른 경로:
Tier 1 (1-3개월) → 숙련
              → 성능 병목 발견
              → Tier 2 도입 (가능성 30%)
              → 대부분 Tier 1이 충분함을 깨달음
```

---

## 📚 다음 단계

Tier 선택에 대해 이해했다면:

1. **[Agent Design Patterns](./01-agent-design-patterns.md)** - 에이전트 설계 패턴
2. **[Delegation Strategies](./02-delegation-strategies.md)** - 위임 전략
3. **[Error Handling & Recovery](./03-error-handling.md)** - 에러 처리
4. **[Parallelization Guide](../04-parallelization/README.md)** - 병렬화 심화
5. **[Token Optimization](../02-token-optimization/01-subagent-architecture.md)** - 토큰 최적화

---

## 🔗 참고 자료

### claude-automate 내 관련 문서

- [Subagent Architecture](../02-token-optimization/01-subagent-architecture.md)
- [Parallelization](../04-parallelization/README.md)
- [Groundwork & Planning](../05-groundwork/README.md)

### 외부 자료

- [Anthropic Claude API Docs](https://docs.anthropic.com/claude/reference)
- [Agent Architecture Best Practices](https://docs.anthropic.com/en/docs/build-a-system)

---

## 💬 Credit & Attribution

이 문서는 다음을 기반으로 작성되었습니다:

> **Agent Abstraction Tier List** - [@menhguin](https://github.com/menhguin)
>
> 멀티 에이전트 시스템의 복잡도 선택에 대한 실용적이고 균형 잡힌 관점 제시

감사합니다! 🙏

---

<div align="center">

### 🎯 핵심 메시지

**Tier 1이 90%의 경우에 충분합니다.**

Tier 2는 증거 기반으로만, 필요할 때만 추가하세요.

**복잡함은 악이 아니라, 불필요한 복잡함이 악입니다.**

</div>
