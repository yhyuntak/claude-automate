# Subagent Architecture & Token Optimization

## 개요

**Subagent Architecture**는 Claude Automate의 핵심 설계 원칙으로, 각 작업의 복잡도에 맞춰 최적의 모델을 선택하여 비용을 줄이고 성능을 극대화합니다.

### 핵심 개념: Model Tier Strategy (모델 티어 전략)

Claude 3 모델 계열은 세 가지 티어로 나뉩니다:

- **Haiku** - 빠르고 저렴한 간단한 작업용
- **Sonnet** - 균형 잡힌 성능과 비용 (기본 선택)
- **Opus** - 최고 성능의 복잡한 추론 작업용

**핵심 원칙**: 모든 작업에 Opus를 사용할 필요가 없습니다. 작업의 복잡도에 맞춘 모델 선택으로 **30-70% 비용 절감**이 가능합니다.

---

## 왜 이것이 중요한가?

### 문제: 모든 작업에 Opus 사용

```
모든 작업 = Opus 사용
  ├─ 간단한 검색 → Opus (과도함)
  ├─ 빠른 파일 읽기 → Opus (과도함)
  ├─ 정규식 매칭 → Opus (과도함)
  └─ 복잡한 아키텍처 분석 → Opus (적절함)

결과: 불필요한 비용 증가 + 느린 응답 시간
```

### 해결책: Intelligent Model Selection

```
복잡도 기반 모델 선택
  ├─ 간단한 검색 → Haiku ✓ (빠름, 저렴)
  ├─ 빠른 파일 읽기 → Haiku ✓ (빠름, 저렴)
  ├─ 정규식 매칭 → Haiku ✓ (빠름, 저렴)
  ├─ 표준 작업 → Sonnet ✓ (균형잡힌 선택)
  └─ 복잡한 아키텍처 분석 → Opus ✓ (정확함)

결과: 30-70% 비용 절감 + 빠른 응답
```

---

## Pricing Comparison (가격 비교)

### Anthropic Claude 3 Models (2024-2025)

**Input Token 가격 (1M tokens 기준)**

| 모델 | 입력 (Input) | 출력 (Output) | 비용 비율 |
|------|------------|------------|----------|
| **Haiku** | $0.80 | $4.00 | 1x (기준) |
| **Sonnet** | $3.00 | $15.00 | 3.75x |
| **Opus** | $15.00 | $75.00 | 18.75x |

**실제 예제: 1,000 tokens 처리 비용**

| 모델 | 입력 비용 | 출력 비용 | 총 비용 | 상대 비용 |
|------|---------|---------|--------|----------|
| Haiku | $0.0008 | $0.004 | $0.0048 | 1x |
| Sonnet | $0.003 | $0.015 | $0.018 | 3.75x |
| Opus | $0.015 | $0.075 | $0.090 | 18.75x |

**가격 정보 출처**:
- [Anthropic Pricing Page](https://www.anthropic.com/pricing/claude)
- [API Documentation](https://docs.anthropic.com/claude/reference/pricing)

---

## Model Selection Decision Tree (의사결정 트리)

```
작업 분류
│
├─ 복잡도 평가
│  ├─ LOW (간단함)
│  │  ├─ 파일 검색
│  │  ├─ 정규식 매칭
│  │  ├─ 텍스트 기본 처리
│  │  └─ → Haiku 선택 ✓
│  │
│  ├─ MEDIUM (중간)
│  │  ├─ 표준 코드 분석
│  │  ├─ 문서 작성
│  │  ├─ API 통합
│  │  └─ → Sonnet 선택 ✓ (기본값)
│  │
│  └─ HIGH (복잡함)
│     ├─ 아키텍처 설계
│     ├─ 버그 디버깅
│     ├─ 전략적 계획
│     ├─ 복잡한 추론
│     └─ → Opus 선택 ✓
│
└─ 속도 vs 정확도
   ├─ 속도 중요 → 한 단계 낮춤 (Haiku/Sonnet)
   ├─ 정확도 중요 → 한 단계 높임 (Sonnet/Opus)
   └─ 불명확 → 기본값 Sonnet 사용
```

---

## Agent Tier Mapping (에이전트 티어 매핑)

### Available Subagents with Model Tiers

| 에이전트 | 기본 모델 | LOW 티어 | MEDIUM 티어 | HIGH 티어 | 용도 |
|---------|---------|---------|-----------|----------|------|
| **explore** | Haiku | Haiku | Haiku-medium | - | 빠른 검색 |
| **librarian** | Sonnet | Haiku | Sonnet | - | 문서 조사 |
| **oracle** | Opus | oracle-low | oracle-medium | Opus | 복잡한 분석 |
| **sisyphus-junior** | Sonnet | junior-low | Sonnet | junior-high | 작업 실행 |
| **frontend-engineer** | Sonnet | engineer-low | Sonnet | engineer-high | UI/UX 작업 |
| **document-writer** | Haiku | Haiku | - | - | 문서 작성 |
| **qa-tester** | Sonnet | - | Sonnet | - | CLI 테스팅 |
| **prometheus** | Opus | - | - | Opus | 전략 계획 |
| **momus** | Opus | - | - | Opus | 계획 검토 |
| **metis** | Opus | - | - | Opus | 사전 계획 |

### Tier Selection Heuristic (선택 휴리스틱)

**LOW 티어 선택 기준:**
- 빠른 응답 필요
- 간단한 검색/매칭
- 기본 정보 수집
- 예산 제약 심함

**MEDIUM 티어 선택 기준 (기본값)**
- 표준 업무
- 코드 분석 및 작성
- 문서 작성
- 중간 복잡도의 추론

**HIGH 티어 선택 기준**
- 복잡한 아키텍처 분석
- 전략적 의사결정
- 버그 근본 원인 분석
- 고도의 추론 필요

---

## Token Usage Benchmarking (토큰 사용량 벤치마킹)

### Benchmarking Approach using Git Worktree

Git worktree를 사용하여 동일한 작업을 다양한 모델에서 테스트합니다.

#### Step 1: Setup Benchmark Environment

```bash
# 메인 프로젝트 디렉토리에서
cd /your/project

# 각 모델별 worktree 생성
git worktree add ../haiku-bench
git worktree add ../sonnet-bench
git worktree add ../opus-bench
```

#### Step 2: Run Same Task Across Models

```bash
# 동일한 작업을 다양한 모델에서 실행
# 예: 코드 리뷰 작업

# Haiku로 실행
cd ../haiku-bench
agent_model=haiku npm run code-review src/app.js

# Sonnet으로 실행
cd ../sonnet-bench
agent_model=sonnet npm run code-review src/app.js

# Opus로 실행
cd ../opus-bench
agent_model=opus npm run code-review src/app.js
```

#### Step 3: Collect Metrics

각 실행 후 다음 메트릭을 수집합니다:

```yaml
# benchmark-results.yaml
Task: code-review
Input: src/app.js (234 lines)

Haiku:
  input_tokens: 4,234
  output_tokens: 892
  total_cost: $0.039
  execution_time: 2.3s
  quality_score: 8/10

Sonnet:
  input_tokens: 4,234
  output_tokens: 1,234
  total_cost: $0.103
  execution_time: 3.1s
  quality_score: 9/10

Opus:
  input_tokens: 4,234
  output_tokens: 1,567
  total_cost: $0.218
  execution_time: 4.2s
  quality_score: 9.5/10

Efficiency Analysis:
  Haiku vs Sonnet: 37.9% 비용 절감 (quality: 1점 손실)
  Sonnet vs Opus: 52.8% 비용 절감 (quality: 0.5점 손실)
  Recommendation: Sonnet 추천 (최적 균형)
```

#### Step 4: Decision Framework

```
비용 vs 품질 분석
├─ 차이가 미미 (<1 quality point) → 저렴한 모델 사용
├─ 차이가 중간 (1-2 quality points) → 비즈니스 요구사항 고려
└─ 차이가 큼 (>2 quality points) → 비싼 모델 사용
```

---

## YAML Configuration Example (설정 예제)

### Agent Definitions with Model Specification

#### Example 1: Simple Search Agent

```yaml
# agents/search-agent.yaml
name: search-agent
description: Fast file and pattern searching
model: haiku  # LOW 티어 - 속도 우선

capabilities:
  - file_search
  - pattern_matching
  - quick_lookup

performance:
  target_tokens: 2000
  max_latency: 1s
```

#### Example 2: Standard Analysis Agent

```yaml
# agents/analyzer-agent.yaml
name: analyzer-agent
description: Code and architecture analysis
model: sonnet  # MEDIUM 티어 - 기본값

capabilities:
  - code_analysis
  - pattern_detection
  - documentation_review

performance:
  target_tokens: 8000
  max_latency: 5s

# 필요시 모델 업그레이드
fallback_model: opus
fallback_condition: "complexity > 0.7"
```

#### Example 3: Strategic Planning Agent

```yaml
# agents/prometheus-agent.yaml
name: prometheus-agent
description: Strategic planning and complex reasoning
model: opus  # HIGH 티어 - 정확도 우선

capabilities:
  - strategic_planning
  - complex_reasoning
  - architecture_design
  - risk_analysis

performance:
  target_tokens: 20000
  max_latency: 10s

# Opus 전용 - 다운그레이드 불가
min_model: opus
```

#### Example 4: Dynamic Model Selection

```yaml
# agents/adaptive-agent.yaml
name: adaptive-agent
description: Dynamically selects model based on task complexity
model_selection:
  default: sonnet

  rules:
    - condition: "task.complexity < 0.4"
      model: haiku
      confidence: 0.95

    - condition: "task.complexity >= 0.4 and task.complexity < 0.7"
      model: sonnet
      confidence: 0.99

    - condition: "task.complexity >= 0.7"
      model: opus
      confidence: 0.98

  # 복잡도 계산 함수
  complexity_calculator: |
    (
      input_length * 0.2 +
      required_reasoning * 0.5 +
      decision_points * 0.3
    ) / 100

capabilities:
  - adaptive_processing
  - quality_assurance
  - cost_optimization
```

---

## Primary Strategy: When to Use Each Model

### Haiku - Cost-Optimized Tier

**사용 시점:**

1. **검색 및 매칭 작업**
   ```yaml
   Task: Find all files matching pattern "*.test.js"
   Reason: Simple regex matching, no complex reasoning
   Model: Haiku
   Expected tokens: 1,000-2,000
   Expected cost: < $0.01
   ```

2. **기본 정보 추출**
   ```yaml
   Task: Extract function names from JavaScript file
   Reason: Straightforward pattern extraction
   Model: Haiku
   Expected tokens: 1,500-2,500
   Expected cost: < $0.02
   ```

3. **문서 읽기 및 이해**
   ```yaml
   Task: Summarize README.md in 200 words
   Reason: Simple comprehension, no analysis needed
   Model: Haiku
   Expected tokens: 3,000-4,000
   Expected cost: < $0.03
   ```

4. **코드 포맷팅**
   ```yaml
   Task: Apply prettier formatting to code
   Reason: Deterministic transformation
   Model: Haiku
   Expected tokens: 2,000-3,000
   Expected cost: < $0.02
   ```

**성능 특성:**
- 응답 시간: 매우 빠름 (1-3초)
- 정확도: 간단한 작업에서 95%+
- 비용: 가장 저렴

**주의사항:**
- 복잡한 추론이 필요한 작업은 부적합
- 긴 context window 필요시 다른 모델 고려

---

### Sonnet - Balanced Tier (기본 선택)

**사용 시점:**

1. **표준 코드 분석**
   ```yaml
   Task: Review pull request for code quality
   Reason: Requires understanding context, patterns
   Model: Sonnet
   Expected tokens: 6,000-10,000
   Expected cost: $0.04-0.08
   ```

2. **문서 작성**
   ```yaml
   Task: Write API documentation
   Reason: Needs clear structure, examples, context
   Model: Sonnet
   Expected tokens: 8,000-12,000
   Expected cost: $0.05-0.10
   ```

3. **중간 복잡도의 버그 분석**
   ```yaml
   Task: Debug memory leak in application
   Reason: Requires some reasoning, but not extreme
   Model: Sonnet
   Expected tokens: 10,000-15,000
   Expected cost: $0.08-0.13
   ```

4. **코드 리팩토링**
   ```yaml
   Task: Refactor function for better performance
   Reason: Needs understanding of implications
   Model: Sonnet
   Expected tokens: 7,000-11,000
   Expected cost: $0.05-0.09
   ```

**성능 특성:**
- 응답 시간: 중간 (3-5초)
- 정확도: 대부분의 작업에서 90-95%
- 비용: 적절한 가격대

**언제 업그레이드할까?**
- 결과 품질이 충분하지 않을 때
- 신뢰할 수 있는 최종 결과 필요할 때

**언제 다운그레이드할까?**
- 비용 절감 필요
- 빠른 응답 필요
- 간단한 작업

---

### Opus - High-Performance Tier

**사용 시점:**

1. **전략적 계획 및 설계**
   ```yaml
   Task: Design microservices architecture
   Reason: Complex system design, multiple trade-offs
   Model: Opus
   Expected tokens: 15,000-25,000
   Expected cost: $0.15-0.25
   ```

2. **복잡한 버그 근본 원인 분석**
   ```yaml
   Task: Analyze mysterious race condition
   Reason: Deep reasoning, multiple possibilities
   Model: Opus
   Expected tokens: 12,000-20,000
   Expected cost: $0.12-0.20
   ```

3. **다중 도메인 의사결정**
   ```yaml
   Task: Choose between framework options (React/Vue/Angular)
   Reason: Requires deep analysis of many factors
   Model: Opus
   Expected tokens: 18,000-28,000
   Expected cost: $0.18-0.28
   ```

4. **마지막 검증 및 검토**
   ```yaml
   Task: Final review of critical system design
   Reason: Need highest confidence before implementation
   Model: Opus
   Expected tokens: 10,000-18,000
   Expected cost: $0.10-0.18
   ```

**성능 특성:**
- 응답 시간: 더딤 (5-10초)
- 정확도: 거의 모든 작업에서 95%+
- 비용: 가장 비쌈

**비용 정당화:**
- 중대한 결정이 필요할 때만 사용
- 잘못된 결정의 비용이 클 때
- 전문성과 신뢰성이 필수적일 때

---

## Real-World Decision Examples

### Example 1: Adding New Feature

```
요청: "실시간 알림 기능 추가"

1단계: 분석 (분할하기)
  ├─ 기존 코드 검색 → Haiku (빠른 검색)
  ├─ 아키텍처 이해 → Sonnet (표준 분석)
  ├─ 설계 패턴 결정 → Opus (전략적)
  └─ 구현 코드 작성 → Sonnet (표준 개발)

전체 비용: Haiku($0.01) + Sonnet($0.08) + Opus($0.20) + Sonnet($0.10) = $0.39
최적화: 전략부분만 Opus, 나머지는 저렴한 모델 사용
```

### Example 2: Bug Fix

```
요청: "로그인 페이지에서 CSRF 토큰 오류 발생"

1단계: 문제 파악
  ├─ 에러 로그 확인 → Haiku ($0.01)
  ├─ 관련 코드 찾기 → Haiku ($0.02)
  ├─ 패턴 분석 → Sonnet ($0.05)
  ├─ 근본 원인 분석 → Opus ($0.15)
  └─ 수정 코드 작성 → Sonnet ($0.06)

전체 비용: $0.29
비용 절감: Haiku로 기초 수집 → 30% 비용 절감
```

### Example 3: Code Review

```
요청: "1000줄 코드 리뷰"

기본 접근 (모두 Opus):
  Cost: $0.90, Time: 15초

최적화된 접근:
  ├─ 구조 확인 → Haiku ($0.02, 1초)
  ├─ 패턴 검토 → Sonnet ($0.08, 3초)
  ├─ 보안 분석 → Opus ($0.20, 5초)
  └─ 최종 종합 → Sonnet ($0.07, 2초)

최적화된 비용: $0.37 (59% 절감)
최적화된 시간: 11초 (26% 단축)
```

---

## Implementation Best Practices

### 1. Start with Sonnet

```javascript
// 기본 전략: 불명확하면 Sonnet부터 시작
const agent = await invokeAgent({
  name: "analyzer",
  model: "sonnet",  // 기본값
  task: unknownTask
});

// 결과 평가 후 필요시 조정
if (quality < 0.8) {
  // Opus로 재시도
}
if (responseTime > 5s && quality > 0.9) {
  // Haiku로 다시 시도 가능
}
```

### 2. Create Task Complexity Profiles

```yaml
# task-profiles.yaml
task_profiles:
  simple_search:
    complexity: 0.2
    recommended_model: haiku
    max_cost: $0.01

  code_review:
    complexity: 0.6
    recommended_model: sonnet
    fallback_model: opus
    max_cost: $0.10

  architecture_design:
    complexity: 0.9
    recommended_model: opus
    min_cost: $0.15

  strategic_planning:
    complexity: 0.95
    recommended_model: opus
    min_cost: $0.20
```

### 3. Monitor and Adjust

```javascript
// token-usage-tracker.js
class TokenTracker {
  constructor() {
    this.sessions = new Map();
  }

  track(taskName, model, inputTokens, outputTokens) {
    const cost = this.calculateCost(model, inputTokens, outputTokens);

    if (!this.sessions.has(taskName)) {
      this.sessions.set(taskName, []);
    }

    this.sessions.get(taskName).push({
      model,
      cost,
      quality: this.getQualityScore(taskName, model),
      timestamp: new Date()
    });
  }

  getOptimalModel(taskName) {
    const results = this.sessions.get(taskName) || [];

    // Cost-effectiveness 점수로 정렬
    return results
      .sort((a, b) => (a.quality / a.cost) - (b.quality / b.cost))
      .reverse()[0]?.model || "sonnet";
  }
}
```

### 4. Build Smart Delegation

```javascript
// smart-delegator.js
async function delegateTask(task) {
  // 복잡도 자동 평가
  const complexity = evaluateComplexity(task);

  let model;
  if (complexity < 0.4) {
    model = "haiku";
  } else if (complexity < 0.7) {
    model = "sonnet";
  } else {
    model = "opus";
  }

  return await invokeSubagent({
    agent: task.preferredAgent,
    model,
    prompt: task.description
  });
}

function evaluateComplexity(task) {
  let score = 0;

  // 요인별 평가
  score += (task.description.length / 1000) * 0.1;  // 길이
  score += task.reasoningRequired ? 0.3 : 0;        // 추론
  score += task.domainSpecific ? 0.2 : 0;           // 도메인 특수성
  score += task.criticalDecision ? 0.4 : 0;         // 중대성

  return Math.min(1, score);
}
```

---

## Cost Analysis Template

프로젝트별로 다음 템플릿을 사용하여 실제 비용을 추적하세요:

```markdown
# Token Optimization Report

## Summary
- Total Tasks: 45
- Total Cost: $2,340
- Average Cost per Task: $52
- Model Distribution: Haiku 30%, Sonnet 60%, Opus 10%

## Model Breakdown

### Haiku Usage
- Tasks: 14 (31%)
- Total Cost: $18
- Avg per Task: $1.29
- Quality Score: 8.2/10

### Sonnet Usage
- Tasks: 27 (60%)
- Total Cost: $1,620
- Avg per Task: $60
- Quality Score: 9.1/10

### Opus Usage
- Tasks: 4 (9%)
- Total Cost: $702
- Avg per Task: $175.50
- Quality Score: 9.6/10

## Optimization Opportunities

1. **Haiku Tasks**: 모두 예상대로 수행
   - 추가 5개 작업을 Haiku로 전환 가능
   - 잠재적 절감: $300

2. **Sonnet -> Haiku**: 품질 손실 < 0.5점인 작업 8개
   - 잠재적 절감: $240

3. **Opus 최적화**: 4개 작업 모두 정당함
   - 현재 상태 유지

## Recommendations

- Haiku 사용 비율 35%로 증가 (현재 31%)
- Sonnet 비율 55%로 감소 (현재 60%)
- Opus 유지 (현재 10%)
- **예상 월간 절감**: 15-20%
```

---

## Common Mistakes to Avoid

### 1. ❌ Using Opus for Everything

```javascript
// 나쁜 예
async function searchFiles(pattern) {
  return await invokeSubagent({
    agent: "oracle",
    model: "opus",  // 과도한 선택
    task: `Find files matching ${pattern}`
  });
}

// 좋은 예
async function searchFiles(pattern) {
  return await invokeSubagent({
    agent: "explore",
    model: "haiku",  // 적절한 선택
    task: `Find files matching ${pattern}`
  });
}
```

### 2. ❌ Never Benchmarking

```javascript
// 나쁜 예: 추측에 의존
const model = "sonnet";  // 왜? 모름

// 좋은 예: 데이터 기반 결정
const model = await selectModelByBenchmark({
  task: "code-review",
  targetQuality: 0.9,
  costLimit: 0.10
});
```

### 3. ❌ Ignoring Response Quality

```javascript
// 나쁜 예: 가장 저렴한 모델만 사용
const model = "haiku";  // 항상

// 좋은 예: 품질과 비용 균형
const quality = evaluateOutput(result);
if (quality < requiredQuality) {
  // Sonnet이나 Opus로 재시도
}
```

### 4. ❌ Not Monitoring Tokens

```javascript
// 나쁜 예: 무시
console.log(response);  // token 정보 사용 안 함

// 좋은 예: 추적
tracker.record({
  model: response.model,
  input_tokens: response.usage.input_tokens,
  output_tokens: response.usage.output_tokens,
  cost: calculateCost(response)
});
```

---

## Advanced: Dynamic Model Switching

실시간으로 모델을 전환하는 고급 기법:

```javascript
// adaptive-agent-manager.js
class AdaptiveAgentManager {
  async executeWithFallback(task, primaryModel = "sonnet") {
    try {
      // 기본 모델로 시도
      const result = await this.executeTask(task, primaryModel);

      // 품질 평가
      const quality = await this.evaluateQuality(result);

      if (quality > 0.85) {
        return result;  // 충분함
      }

      // 품질 부족 → 업그레이드
      console.log(`Quality ${quality} insufficient, upgrading to opus`);
      return await this.executeTask(task, "opus");

    } catch (error) {
      // 오류 발생 → 더 강력한 모델로 재시도
      console.log(`${primaryModel} failed, retrying with opus`);
      return await this.executeTask(task, "opus");
    }
  }

  async executeTask(task, model) {
    return await invokeSubagent({
      agent: task.agent,
      model,
      prompt: task.description,
      timeout: this.getTimeout(model)
    });
  }

  getTimeout(model) {
    return {
      haiku: 3000,
      sonnet: 5000,
      opus: 10000
    }[model];
  }
}
```

---

## Summary: Quick Reference

### When in Doubt
1. **기본값으로 Sonnet 선택**
2. **결과 품질 평가**
3. **필요시 조정** (Haiku or Opus)

### Cost Optimization Rules
1. 모든 작업에 Opus 사용하지 말기
2. 정기적으로 벤치마킹하기
3. 토큰 사용량 추적하기
4. 복잡도에 따라 모델 선택하기

### Model Selection Quick Reference

| 상황 | 선택 | 이유 |
|------|------|------|
| 빠른 검색/매칭 | Haiku | 빠름, 저렴 |
| 표준 개발 작업 | Sonnet | 최적 균형 |
| 복잡한 분석/설계 | Opus | 정확도 |
| 불명확함 | Sonnet | 기본값 |
| 비용 중시 | Haiku | 절감 |
| 품질 중시 | Opus | 신뢰성 |

---

## 다음 단계

이 문서의 이해를 바탕으로:

1. **[Token Economy Fundamentals](./02-token-economy-fundamentals.md)** - Token 개념 이해하기
2. **[Batch Processing Strategy](./03-batch-processing.md)** - 효율적인 배치 처리
3. **[Cost Monitoring & Analytics](./04-cost-monitoring.md)** - 지속적인 모니터링
4. **[Parallel Agent Optimization](../04-parallelization/README.md)** - 병렬 에이전트 최적화

---

## References & Resources

- [Anthropic Claude API Documentation](https://docs.anthropic.com/claude/reference)
- [Claude Models Comparison](https://docs.anthropic.com/claude/reference/models-overview)
- [Pricing Information](https://www.anthropic.com/pricing/claude)
- [Token Counting Guide](https://docs.anthropic.com/claude/reference/token-counting-api)

---

<div align="center">

### Intelligent Model Selection = Better Performance + Lower Costs

**올바른 모델 선택으로 30-70% 비용을 절감하고 더 빠른 응답을 얻으세요.**

</div>
