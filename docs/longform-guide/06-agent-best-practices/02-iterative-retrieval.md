# Iterative Retrieval Pattern

> **How to retrieve incomplete information from sub-agents and use follow-up queries to get complete, accurate answers**

## 개요 (Overview)

Iterative Retrieval Pattern은 **Sub-agent 시스템에서 정보를 효과적으로 수집**하기 위한 핵심 패턴입니다.

### 문제 상황 (Problem)

Sub-agent에 질문을 보낼 때 발생하는 일반적인 문제들:

```
Sub-agent에 요청 →  답변 반환
                    ├─ 충분한가? → 사용
                    ├─ 불완전한가? → 재요청? (몇 번?)
                    ├─ 모호한가? → 어떻게 명확히 하나?
                    └─ 옆길로 빠졌나? → 다시 집중시키기?
```

**핵심 문제들:**

1. **불완전한 답변** - Sub-agent가 모든 필요한 정보를 주지 않음
2. **평가 부재** - 답변이 충분한지 확인하지 않음
3. **무한 루프** - Follow-up 질문을 몇 번이나 해야 하는지 불명확
4. **문맥 손실** - 원래 목표(Objective)를 잃어버리고 세부사항에만 빠짐

### 해결책 (Solution)

**Iterative Retrieval Pattern**은 다음을 보장합니다:

```
최초 요청 (Objective + Query)
    ↓
Sub-agent 답변 평가
    ↓
┌─ 충분한가? → 반환 (완료)
│
└─ 불충분한가? → Follow-up (최대 3회)
    ├─ 평가 → 충분?
    └─ 반복...
```

---

## 핵심 개념 (Core Concepts)

### 1. Query vs Objective (질문 vs 목표)

**구분이 중요합니다:**

#### Query (질문)
```
"Find all JavaScript files in src/"
```
- 즉시적, 구체적
- 한 번에 답변 가능할 수도, 안 될 수도

#### Objective (목표)
```
"Understand the complete module structure of this project
to identify where authentication is implemented and
create comprehensive documentation"
```
- 큰 그림
- Query들의 집합
- Sub-agent가 알아야 할 **왜** (Why)

### 2. Evaluation Criteria (평가 기준)

Sub-agent의 답변이 충분한지 판단하는 기준:

```
Sufficient Answer =
  ✓ Objective 달성에 필요한 모든 정보 포함
  ✓ 모호한 부분 없음
  ✓ 관련 없는 내용 최소화
  ✓ 구조화된 형식으로 제시됨
  ✓ 추가 질문이 필요하지 않음
```

### 3. Follow-up Question Strategy (추가 질문 전략)

최대 3회의 Follow-up 규칙:

```
Iteration 1: 기본 정보 요청
Iteration 2: 누락된 부분 명확화
Iteration 3: 최종 검증 및 정리

→ 초과하면 중단 + 부분 답변으로 진행
```

---

## 흐름 다이어그램 (Flow Diagram)

### Plaintext Flowchart

```
┌──────────────────────────────────────────────────────────────┐
│              ITERATIVE RETRIEVAL PATTERN FLOW                 │
└──────────────────────────────────────────────────────────────┘

1. ORCHESTRATOR INITIALIZATION
   ┌─────────────────────────┐
   │  User Request           │
   │  ├─ Objective: ...      │
   │  ├─ Context: ...        │
   │  └─ Requirements: ...   │
   └────────────┬────────────┘
                │
                ▼
   ┌─────────────────────────────────────────────┐
   │  Decompose into Sub-tasks                   │
   │  ├─ Identify information needs              │
   │  ├─ Determine sub-agent capabilities        │
   │  └─ Prepare objective + query pairs         │
   └────────────┬────────────────────────────────┘


2. INITIAL QUERY
                │
                ▼
   ┌─────────────────────────────────────────────┐
   │  Prepare Query Package                      │
   │  ├─ Query: Specific, actionable             │
   │  ├─ Objective: Complete context             │
   │  ├─ Examples: Success patterns (if needed)  │
   │  └─ Format: Expected output format          │
   └────────────┬────────────────────────────────┘
                │
                ▼
   ┌──────────────────────────────────────────────┐
   │  Send to Sub-agent                           │
   │  ┌──────────────────────────────────────────┤
   │  │ "Given objective [X], please answer [Y]" │
   │  │                                          │
   │  │ Objective: ...                           │
   │  │ Query: ...                               │
   │  │ Format: ...                              │
   │  └──────────────────────────────────────────┘
   └────────────┬────────────────────────────────┘


3. SUB-AGENT PROCESSING & RESPONSE
                │
                ▼
   ┌──────────────────────────────────────────────┐
   │  Sub-agent                                   │
   │  ├─ Receives objective + query               │
   │  ├─ Searches/analyzes/processes              │
   │  └─ Generates response                       │
   └────────────┬────────────────────────────────┘
                │
                ▼
   ┌──────────────────────────────────────────────┐
   │  Return Summary                              │
   │  ├─ Key findings                             │
   │  ├─ Relevant details                         │
   │  ├─ Confidence level                         │
   │  └─ Any limitations                          │
   └────────────┬────────────────────────────────┘


4. EVALUATION & DECISION
                │
                ▼
   ┌──────────────────────────────────────────────┐
   │  Evaluate Response Quality                   │
   │  ├─ Does it answer the query?                │
   │  ├─ Is it complete?                          │
   │  ├─ Are there gaps?                          │
   │  ├─ Is it relevant to objective?             │
   │  └─ Any contradictions?                      │
   └────────────┬────────────────────────────────┘
                │
         ┌──────┴──────┐
         │             │
    YES  │             │  NO / PARTIAL
         ▼             ▼
    ┌────────┐    ┌──────────────────┐
    │ ACCEPT │    │ MORE ITERATIONS? │
    └────────┘    └────────┬─────────┘
         │                 │
         │            YES / NO
         │           /       \
         │          /         \
         ▼    ┌─────┐       ┌──────┐
      RETURN  │ YES │       │ NO   │
         │    └────┬┘       └──┬───┘
         │         │           │
         │         ▼           ▼
         │    ITERATION    PARTIAL
         │    COUNTER      ACCEPT
         │    < 3?         + FLAG
         │    │
         └────┤
              │
              ▼
   ┌──────────────────────────────────────────────┐
   │  Prepare Follow-up Query (Iteration 2/3)     │
   │  ├─ What was missing?                        │
   │  ├─ Ask specific clarifying questions        │
   │  ├─ Remind objective                         │
   │  └─ Reference previous answer                │
   └────────┬────────────────────────────────────┘
            │
            └─────────────────────┐
                                  │
                    (REPEAT FROM STEP 3)
                                  ▼
                        [SUB-AGENT PROCESSES]
                                  │
                                  ▼
                        [EVALUATION AGAIN]


5. FINALIZATION
   ┌──────────────────────────────────────────────┐
   │  Integrate All Iterations                    │
   │  ├─ Combine initial + follow-up responses    │
   │  ├─ Remove redundancy                        │
   │  ├─ Create unified summary                   │
   │  └─ Mark any remaining gaps                  │
   └────────────┬────────────────────────────────┘
                │
                ▼
   ┌──────────────────────────────────────────────┐
   │  Return to Orchestrator                      │
   │  ├─ Complete information                     │
   │  ├─ Iteration count                          │
   │  ├─ Confidence level                         │
   │  └─ Any caveats or limitations               │
   └──────────────────────────────────────────────┘


KEY PRINCIPLES
├─ Always send OBJECTIVE alongside QUERY
├─ Evaluate after each response
├─ Follow-up max 3 times
├─ Track iteration history
├─ Preserve context across iterations
├─ Be specific in follow-up questions
└─ Know when to accept partial answers
```

---

## 구현 전략 (Implementation Strategy)

### Strategy 1: Always Evaluate Sub-agent Return Values

**문제:** Sub-agent 응답을 그냥 받아서 사용하기

**해결책:** 모든 응답을 명시적으로 평가하기

#### Pattern

```javascript
async function retrieveWithEvaluation(objective, query) {
  let currentResponse = null;
  let iterationCount = 0;
  const maxIterations = 3;

  while (iterationCount < maxIterations) {
    // 1. Send query with objective context
    currentResponse = await subagent.query({
      objective: objective,
      query: iterationCount === 0 ? query : followUpQuery,
      previousResponse: currentResponse  // Include prior response
    });

    // 2. Evaluate response quality
    const evaluation = evaluateResponse(
      currentResponse,
      objective,
      query
    );

    // 3. Decide: Accept or Follow-up?
    if (evaluation.isSufficient) {
      return {
        response: currentResponse,
        iterations: iterationCount + 1,
        status: "complete"
      };
    }

    // 4. Prepare follow-up if needed
    if (iterationCount < maxIterations - 1) {
      followUpQuery = generateFollowUpQuery(
        evaluation.gaps,
        objective,
        currentResponse
      );
      iterationCount++;
    } else {
      // Max iterations reached
      return {
        response: currentResponse,
        iterations: iterationCount + 1,
        status: "partial - max iterations reached",
        gaps: evaluation.gaps
      };
    }
  }
}
```

#### Evaluation Function

```javascript
function evaluateResponse(response, objective, query) {
  const evaluation = {
    isSufficient: true,
    gaps: [],
    issues: [],
    confidence: 1.0
  };

  // Check 1: Does response answer the query?
  if (!responseAnswersQuery(response, query)) {
    evaluation.isSufficient = false;
    evaluation.gaps.push("Does not directly answer the query");
    evaluation.confidence -= 0.3;
  }

  // Check 2: Is it complete?
  if (hasSignsOfIncompleteness(response)) {
    evaluation.isSufficient = false;
    evaluation.gaps.push("Response appears incomplete");
    evaluation.confidence -= 0.2;
  }

  // Check 3: Is it relevant to objective?
  if (!isRelevantToObjective(response, objective)) {
    evaluation.isSufficient = false;
    evaluation.issues.push("Off-topic or irrelevant");
    evaluation.confidence -= 0.4;
  }

  // Check 4: Are there contradictions?
  if (hasContradictions(response)) {
    evaluation.issues.push("Internal contradictions detected");
    evaluation.confidence -= 0.25;
  }

  // Check 5: Structure and clarity
  if (!isWellStructured(response)) {
    evaluation.issues.push("Poor structure or clarity");
    evaluation.confidence -= 0.15;
  }

  return evaluation;
}
```

---

### Strategy 2: Always Pass Objective Context

**문제:** Query만 보내고 "왜"를 알려주지 않기

```javascript
// ❌ 나쁜 예
await subagent.query({
  query: "Find all authentication files"
});

// ✓ 좋은 예
await subagent.query({
  objective: `Complete understanding of authentication system
             to design new OAuth2 integration`,
  query: "Find all authentication-related files and modules",
  context: {
    why: "Building OAuth2 provider support",
    scope: "Web backend only, exclude mobile",
    deadline: "2 weeks"
  }
});
```

**왜 중요한가?**

1. **Sub-agent가 더 정확하게 답변** - 전체 문맥을 알 수 있음
2. **더 적은 Follow-up 필요** - 의도를 이해하고 관련 정보를 미리 포함
3. **더 나은 판단** - 중요한 것과 부수적인 것 구분 가능

---

### Strategy 3: Follow-up Questions (최대 3회)

**패턴:** 구조화된 Follow-up 질문

```javascript
function generateFollowUpQuery(gaps, objective, previousResponse) {
  let followUpQuery = `Based on your previous response, I need clarification:

Objective (reminder): ${objective}

Previous response identified these gaps:
${gaps.map((g, i) => `${i + 1}. ${g}`).join('\n')}

Please specifically address:`;

  // Add specific follow-up questions
  if (gaps.includes("Incomplete list")) {
    followUpQuery += `
1. Are there ANY other files/modules we might have missed?
   (Search broader if needed)`;
  }

  if (gaps.includes("Missing implementation details")) {
    followUpQuery += `
2. For each item found, what is the key implementation approach?
   (Brief but specific)`;
  }

  if (gaps.includes("Unclear dependencies")) {
    followUpQuery += `
3. What are the external dependencies for these components?`;
  }

  return followUpQuery;
}
```

**Follow-up 사례:**

#### Iteration 1 (Initial)
```
Query: "Find all API endpoints in this codebase"
Response: [10 endpoints found]
Evaluation: Incomplete - missing some nested routes
```

#### Iteration 2 (Follow-up 1)
```
Query: "You found 10 main endpoints.
Are there any nested or dynamically-generated endpoints
we might have missed? Check middleware, routers, and
dynamic route registration."

Response: [+ 5 more endpoints found]
Evaluation: Better but still missing status
```

#### Iteration 3 (Follow-up 2)
```
Query: "For each endpoint, what HTTP methods are supported?
(GET, POST, PUT, DELETE, etc.)"

Response: [Complete list with all methods]
Evaluation: SUFFICIENT ✓
```

---

### Strategy 4: Objective Context Preservation

**문제:** Iteration이 진행되면서 원래 목표를 잃음

```javascript
// ❌ 나쁜 - 목표 손실
Iteration 1: Query about "files"
Iteration 2: Query about "functions"  ← 왜 이걸 찾는지 잊음
Iteration 3: Query about "dependencies" ← 더 이상 연결 안 됨

// ✓ 좋은 - 목표 유지
Iteration 1:
  Objective: "Design new auth system"
  Query: "Find existing auth files"

Iteration 2:
  Objective: "Design new auth system"  ← 동일하게 유지
  Query: "What patterns do they use?"
  Previous Response: [iteration 1 results]

Iteration 3:
  Objective: "Design new auth system"  ← 여전히 명확
  Query: "What are the gaps in current system?"
  Previous Responses: [iteration 1 + 2 results]
```

**구현:**

```javascript
class IterativeRetrieval {
  constructor(objective) {
    this.objective = objective;
    this.iterations = [];
    this.iterationCount = 0;
  }

  async retrieveWithFollowups(initialQuery) {
    let lastResponse = null;

    while (this.iterationCount < 3) {
      const query = this.iterationCount === 0
        ? initialQuery
        : this.generateFollowUp(lastResponse);

      // Always include objective
      const result = await subagent.query({
        objective: this.objective,  // ← KEY: Always send
        query: query,
        iteration: this.iterationCount + 1,
        previousResponses: this.iterations.map(r => r.response)
      });

      this.iterations.push({
        iteration: this.iterationCount + 1,
        query: query,
        response: result,
        evaluation: this.evaluate(result)
      });

      lastResponse = result;

      // Check if we're done
      if (this.iterations[this.iterationCount].evaluation.isSufficient) {
        break;
      }

      this.iterationCount++;
    }

    return this.getFinalResult();
  }

  evaluate(response) {
    // Use Strategy 1 evaluation logic
    return evaluateResponse(response, this.objective, this.lastQuery);
  }

  getFinalResult() {
    const allResponses = this.iterations.map(i => i.response);
    return {
      objective: this.objective,
      responses: allResponses,
      iterations: this.iterationCount + 1,
      isFinal: this.iterations[this.iterationCount]?.evaluation.isSufficient,
      summary: this.synthesizeResponses(allResponses)
    };
  }

  synthesizeResponses(responses) {
    // Combine all responses into single unified answer
    return mergeResponses(responses, this.objective);
  }
}
```

---

## 실전 예제 (Real-World Examples)

### Example 1: API Documentation Generation

```
OBJECTIVE:
"Create comprehensive API documentation for this service
including all endpoints, parameters, and response examples"

INITIAL QUERY:
"Find all API endpoints in the codebase.
For each, identify the HTTP method and URL path."

SUB-AGENT RESPONSE:
[Returns 25 endpoints with basic info]

EVALUATION:
✓ Found endpoints
✗ Missing request/response details
✗ Missing error codes
✗ Missing authentication requirements

ITERATION 2 QUERY:
"For each of the 25 endpoints found, what are:
1. Required query parameters?
2. Request body structure?
3. Response structure?
4. Authentication requirements?"

SUB-AGENT RESPONSE:
[Adds detailed parameter and response info]

EVALUATION:
✓ More complete
✗ Still missing error response examples
✗ Missing deprecated endpoints notice

ITERATION 3 QUERY:
"What are the possible error responses and
status codes for each endpoint?
Are there any deprecated endpoints?"

SUB-AGENT RESPONSE:
[Completes with error codes and deprecation notices]

EVALUATION:
✓ SUFFICIENT - All key information present

RESULT: Complete API documentation
Iterations needed: 3
```

---

### Example 2: Architecture Understanding

```
OBJECTIVE:
"Understand the complete system architecture to identify
security vulnerabilities and design improvements"

INITIAL QUERY:
"Map out all major components and their relationships"

RESPONSE:
[High-level component diagram: Frontend, Backend, DB, Cache]

EVALUATION:
✓ Overview obtained
✗ Data flow between components unclear
✗ External services missing
✗ Security boundaries not defined

ITERATION 2 QUERY:
"For each component, describe:
1. What data does it receive?
2. What does it return?
3. What external services does it use?
4. How is data validated?"

RESPONSE:
[Detailed data flow and external service list]

EVALUATION:
✓ Better understanding
✗ Authentication flow not clear
✗ Authorization patterns undefined
✗ Error handling strategy missing

ITERATION 3 QUERY:
"How are users authenticated? How is access controlled?
What happens when errors occur in each component?"

RESPONSE:
[Authentication, authorization, and error handling detail]

EVALUATION:
✓ SUFFICIENT - Complete architecture picture

RESULT: Full security audit possible
Iterations needed: 3
Status: Ready for improvement recommendations
```

---

### Example 3: Bug Investigation

```
OBJECTIVE:
"Identify root cause of user authentication failures
in production to create fix and prevent recurrence"

INITIAL QUERY:
"What are all the code paths in the authentication flow?
List each file and function involved."

RESPONSE:
[5 main files, 15 functions identified]

EVALUATION:
✓ Flow identified
✗ Actual error not clear
✗ Failure conditions not documented
✗ Recent changes not noted

ITERATION 2 QUERY:
"In the auth flow you identified:
1. Where could failures occur?
2. What error messages would be shown?
3. What were the recent code changes in these files?
4. What edge cases might not be handled?"

RESPONSE:
[Error points identified, recent changes found]

EVALUATION:
✓ Getting closer to root cause
✗ Specific failure scenario from logs not matched
✗ Database state issues not considered
✗ Concurrency issues not addressed

ITERATION 3 QUERY:
"Users are seeing 'Invalid token' error after
password reset. Looking at the auth files:
1. How is the token invalidated on password reset?
2. Could a race condition occur?
3. What happens with cached tokens?
4. How does session invalidation work?"

RESPONSE:
[Identifies race condition in token invalidation]

EVALUATION:
✓ SUFFICIENT - Root cause found!

RESULT: Race condition in token refresh
Fix: Add locking to token invalidation
Prevention: Add concurrent request handling test
```

---

## 안티패턴 (Anti-patterns to Avoid)

### Anti-pattern 1: ❌ Never Evaluating

```javascript
// 나쁜 예
const result = await subagent.query(query);
return result;  // 그냥 받아서 사용 - 위험!

// 좋은 예
const result = await subagent.query(query);
const quality = evaluateResponse(result, objective);
if (quality.isSufficient) {
  return result;
} else {
  // Follow-up or flag issue
}
```

### Anti-pattern 2: ❌ Query-Only Without Objective

```javascript
// 나쁜 예
await subagent.query({
  query: "Find authentication files"
});

// 좋은 예
await subagent.query({
  objective: "Design new 2FA system",
  query: "Find authentication files",
  context: "Need to understand current auth architecture"
});
```

### Anti-pattern 3: ❌ Infinite Follow-ups

```javascript
// 나쁜 예 - 제한 없음
while (true) {
  const response = await subagent.query(...);
  if (!isSufficient(response)) {
    // 다시... 그리고 또... 무한 루프 위험!
  }
}

// 좋은 예 - 3회 제한
const maxIterations = 3;
for (let i = 0; i < maxIterations; i++) {
  const response = await subagent.query(...);
  if (isSufficient(response)) break;
}
// i == maxIterations면 부분 답변 받아들이기
```

### Anti-pattern 4: ❌ Losing Context in Iterations

```javascript
// 나쁜 예 - 매번 다른 쿼리
Iteration 1: "Find files"
Iteration 2: "Tell me about functions"
Iteration 3: "What about tests?"
// Iteration 2,3은 원래 목표와 연결 안 됨

// 좋은 예 - 한 맥락으로 건설
Iteration 1:
  "Find auth files"
Iteration 2:
  "Of those files, show me the main functions"
Iteration 3:
  "Of those functions, what are edge cases?"
```

---

## 체크리스트 (Implementation Checklist)

Sub-agent 상호작용을 할 때마다 확인하세요:

- [ ] **Objective 정의됨**: 명확한 최종 목표가 있는가?
- [ ] **Query 구체적**: 의도한 정보를 구체적으로 요청하는가?
- [ ] **Objective 전달**: Sub-agent에 objective를 명시적으로 보냈는가?
- [ ] **Response 평가 함수**: 응답 품질을 평가할 방법이 있는가?
- [ ] **Gap 식별**: 부족한 정보가 무엇인지 명확히 파악했는가?
- [ ] **Follow-up 구체적**: Follow-up 질문이 gap을 명확히 해결하는가?
- [ ] **Iteration 제한**: 최대 3회로 제한했는가?
- [ ] **Context 유지**: 모든 iteration에서 원래 objective를 기억하는가?
- [ ] **최종 결과**: 모든 response를 통합하여 최종 답변을 구성했는가?

---

## 성능 지표 (Metrics)

### Success Metrics

```javascript
const metrics = {
  // 얼마나 효율적인가?
  iterationsRequired: 1,  // 평균 1-2회가 좋음

  // 얼마나 완전한가?
  completenessScore: 0.95,  // 0-1, 0.9 이상 좋음

  // 얼마나 정확한가?
  accuracyScore: 0.98,  // 정확도 점수

  // 얼마나 빠른가?
  timePerIteration: 2.3,  // 초 단위

  // 얼마나 비용 효율적인가?
  tokensPerQuery: 4200,  // 평균 토큰 수
  costPerCompletion: 0.15  // 달러
};
```

### Benchmarking

```javascript
async function benchmarkIterativeRetrieval() {
  const testCases = [
    { name: "Simple search", difficulty: "easy" },
    { name: "Pattern matching", difficulty: "medium" },
    { name: "Architecture analysis", difficulty: "hard" }
  ];

  const results = [];

  for (const testCase of testCases) {
    const start = Date.now();
    const result = await retrieval.execute(testCase);
    const duration = Date.now() - start;

    results.push({
      case: testCase.name,
      iterations: result.iterations,
      completeness: result.evaluation.completenessScore,
      duration: duration,
      tokensUsed: result.tokensUsed,
      success: result.isFinal
    });
  }

  return results;
}
```

---

## 도우미 함수 모음 (Helper Functions)

### Response Quality Evaluator

```javascript
function evaluateResponseQuality(response, objective, originalQuery) {
  const checks = {
    answersQuery: responseAddresses(response, originalQuery),
    meetsObjective: contributeToObjective(response, objective),
    isComplete: !hasSignsOfIncompleteness(response),
    isClear: isWellStructured(response),
    isRelevant: isOnTopic(response, originalQuery),
    noContradictions: !hasInternalContradictions(response)
  };

  const passedChecks = Object.values(checks).filter(Boolean).length;
  const total = Object.keys(checks).length;

  return {
    ...checks,
    score: passedChecks / total,
    isSufficient: passedChecks >= (total - 1)  // Allow 1 minor miss
  };
}
```

### Gap Identifier

```javascript
function identifyGaps(response, objective, originalQuery) {
  const gaps = [];

  if (!responseAnswersDirectly(response, originalQuery)) {
    gaps.push("Does not directly answer the original query");
  }

  if (response.length < minimumExpectedLength(originalQuery)) {
    gaps.push("Response is suspiciously brief");
  }

  if (!mentionsRelated(response, objective)) {
    gaps.push("Missing context related to objective");
  }

  if (hasUncertaintyLanguage(response)) {
    gaps.push("Contains uncertain/hedging language - ask for specifics");
  }

  return gaps;
}
```

### Follow-up Generator

```javascript
function generateSmartFollowUp(gaps, objective, previousResponse) {
  if (gaps.length === 0) return null;

  let followUp = `Based on the previous response, I need to clarify:

Context reminder: ${objective}

Specific gaps to address:
`;

  gaps.forEach((gap, i) => {
    followUp += `${i + 1}. ${gap}\n`;
  });

  followUp += `\nPlease provide:`;

  // Add actionable follow-up questions
  if (gaps.includes("incomplete")) {
    followUp += `
- A complete, exhaustive list (don't leave anything out)`;
  }

  if (gaps.includes("unclear")) {
    followUp += `
- Specific examples for each item`;
  }

  if (gaps.includes("missing context")) {
    followUp += `
- Connection to the overall objective: ${objective}`;
  }

  return followUp;
}
```

---

## 학습 자료 (Next Steps)

1. **[Sub-agent Architecture](./01-subagent-orchestration.md)**
   - Sub-agent 기본 설계

2. **[Context Management](../01-context-memory/README.md)**
   - Context 효율적으로 관리하기

3. **[Verification & Evaluation](../03-verification-evals/README.md)**
   - 응답 품질 평가 방법론

4. **[Parallel Agent Patterns](../04-parallelization/README.md)**
   - 여러 Sub-agent와 병렬 작업

---

## 요약 (Summary)

### Iterative Retrieval Pattern의 핵심

```
1. OBJECTIVE + QUERY 분리
   ├─ Objective: 최종 목표
   └─ Query: 구체적 질문

2. SUB-AGENT에 둘 다 전달
   ├─ 더 정확한 답변 가능
   └─ 더 적은 Follow-up 필요

3. 응답 평가 (명시적)
   ├─ 충분한가?
   └─ 부족한 부분이 무엇인가?

4. 최대 3회 Follow-up
   ├─ 반복은 도움이 되지만 무한이 아니어야 함
   └─ 3회 후 부분 답변도 받아들이기

5. 모든 응답 통합
   ├─ Iteration 1, 2, 3 결과 합치기
   └─ 최종 완전한 답변 생성
```

### 체크리스트

```
✓ Objective를 항상 정의한다
✓ Sub-agent에 Objective를 전달한다
✓ 응답을 명시적으로 평가한다
✓ Follow-up은 최대 3회로 제한한다
✓ 모든 iteration에서 맥락을 유지한다
✓ 최종 결과를 통합하여 반환한다
```

---

<div align="center">

### Complete Information Through Structured Iteration

**명확한 목표와 체계적인 평가로 완전한 정보를 얻으세요.**

</div>
