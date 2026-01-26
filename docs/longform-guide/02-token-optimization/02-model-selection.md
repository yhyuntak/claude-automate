# Model Selection Quick Reference (모델 선택 빠른 참고)

## 개요

**Model Selection**은 Token Optimization에서 가장 직접적이고 효과가 큰 최적화 전략입니다. 작업의 복잡도에 맞춘 올바른 모델 선택으로 **30-70% 비용을 절감**할 수 있습니다.

### 핵심 원칙

- **Haiku**: 빠르고 저렴한 간단한 작업용
- **Sonnet**: 균형 잡힌 성능과 비용 (기본 선택)
- **Opus**: 최고 성능의 복잡한 추론 작업용

**기본 규칙: 불명확할 때는 Sonnet부터 시작하고, 결과를 평가한 후 필요시 조정하세요.**

---

## 2026 Pricing Reference (현재 가격)

### 모델별 기본 가격 (2026년 1월)

| 모델 | 입력 (Input) | 출력 (Output) | 캐시 읽기 | 상대 비용 |
|------|------------|------------|----------|----------|
| **Haiku 4.5** | $1 / MTok | $5 / MTok | $0.10 / MTok | 1x (기준) |
| **Sonnet 4.5** | $3 / MTok | $15 / MTok | $0.30 / MTok | 3x |
| **Opus 4.5** | $5 / MTok | $25 / MTok | $0.50 / MTok | 5x |

**MTok = Million tokens (백만 토큰)**

### 실제 예제: 10,000 tokens 처리 비용

```
Haiku로 1000줄 코드 검색:
  입력: 8,000 tokens × ($1/1M) = $0.008
  출력: 2,000 tokens × ($5/1M) = $0.010
  총합: $0.018

Sonnet으로 동일 작업:
  입력: 8,000 tokens × ($3/1M) = $0.024
  출력: 2,000 tokens × ($15/1M) = $0.030
  총합: $0.054 (3배 비쌈)

Opus로 동일 작업:
  입력: 8,000 tokens × ($5/1M) = $0.040
  출력: 2,000 tokens × ($25/1M) = $0.050
  총합: $0.090 (5배 비쌈)
```

### 배치 처리 할인 (Batch API)

배치 API를 사용하면 50% 할인을 받습니다:

| 모델 | Batch 입력 | Batch 출력 |
|------|-----------|-----------|
| **Haiku 4.5** | $0.50 / MTok | $2.50 / MTok |
| **Sonnet 4.5** | $1.50 / MTok | $7.50 / MTok |
| **Opus 4.5** | $2.50 / MTok | $12.50 / MTok |

---

## 작업 복잡도별 모델 선택

### 의사결정 플로우차트

```
작업 분류
│
├─ 복잡도 평가
│  ├─ LOW (복잡도 < 0.4)
│  │  ├─ 파일/패턴 검색
│  │  ├─ 간단한 텍스트 처리
│  │  ├─ 정규식 매칭
│  │  ├─ 코드 포매팅
│  │  └─ → Haiku 선택 ✓
│  │
│  ├─ MEDIUM (0.4 ≤ 복잡도 < 0.7)
│  │  ├─ 표준 코드 분석
│  │  ├─ 문서 작성
│  │  ├─ 코드 리뷰
│  │  ├─ API 통합
│  │  ├─ 중간 복잡도 버그 분석
│  │  └─ → Sonnet 선택 ✓ (기본값)
│  │
│  └─ HIGH (복잡도 ≥ 0.7)
│     ├─ 아키텍처 설계
│     ├─ 복잡한 버그 근본 원인 분석
│     ├─ 전략적 계획
│     ├─ 보안 결정
│     ├─ 다중 도메인 의사결정
│     └─ → Opus 선택 ✓
│
└─ 우선순위 조정
   ├─ 속도 중시 → 한 단계 낮춤
   ├─ 정확도 중시 → 한 단계 높임
   └─ 불명확 → Sonnet 유지
```

---

## 실전 시나리오별 모델 선택

### 1️⃣ Haiku 사용 시나리오

**언제 사용할까?**

#### 1. 파일 검색 및 매칭

```yaml
Task: "프로젝트에서 모든 test 파일 찾기"
Pattern: "**/*.test.js"
Complexity: 0.1 (매우 낮음)

선택: Haiku
이유: 간단한 패턴 매칭, 복잡한 추론 불필요
예상 토큰: 1,000-2,000
예상 비용: $0.018
```

**코드 예제:**
```javascript
// 나쁜 예: Opus 사용
await invokeAgent({
  name: "oracle",
  model: "opus",
  task: "모든 test 파일 찾기"  // 과도함
});

// 좋은 예: Haiku 사용
await invokeAgent({
  name: "explore",
  model: "haiku",
  task: "모든 test 파일 찾기"  // 적절함
});
```

#### 2. 데이터 추출 및 변환

```yaml
Task: "JavaScript 파일에서 모든 함수명 추출"
Complexity: 0.2 (낮음)

선택: Haiku
이유: 직관적인 패턴 추출
예상 토큰: 1,500-2,500
예상 비용: $0.030
```

#### 3. 간단한 문서 처리

```yaml
Task: "README.md 파일을 200줄로 요약"
Complexity: 0.15 (매우 낮음)

선택: Haiku
이유: 선택적 복사, 복잡한 분석 불필요
예상 토큰: 3,000-4,000
예상 비용: $0.050
```

#### 4. 코드 포매팅

```yaml
Task: "JavaScript 코드에 Prettier 포매팅 적용"
Complexity: 0.1 (매우 낮음)

선택: Haiku
이유: 결정론적 변환, 상황별 판단 불필요
예상 토큰: 2,000-3,000
예상 비용: $0.028
```

#### 5. Worker 에이전트

```yaml
Task: "다른 에이전트의 지시에 따라 파일 읽기"
Context: Orchestrator가 이미 의사결정 완료
Complexity: 0.2 (낮음)

선택: Haiku
이유: 명확한 지시, 창의성 불필요
예상 토큰: 2,000-4,000
예상 비용: $0.040
```

**Haiku 최적화 팁:**
- ✓ 단순하고 명확한 지시 제공
- ✓ Context window 최소화 (필수 정보만)
- ✓ 정규식이나 패턴 기반 작업에 최적
- ✗ 복잡한 추론이 필요한 작업 피하기
- ✗ 긴 설명이나 예제 최소화

---

### 2️⃣ Sonnet 사용 시나리오 (기본값)

**언제 사용할까?**

#### 1. 표준 코드 분석 및 리뷰

```yaml
Task: "Pull Request 코드 품질 검토"
Input: 500줄의 새로운 코드
Complexity: 0.5 (중간)

선택: Sonnet (기본값)
이유: Context 이해, 패턴 인식, 개선 제안 필요
예상 토큰: 6,000-10,000
예상 비용: $0.045-0.090
```

**코드 예제:**
```javascript
// Sonnet으로 코드 리뷰
await invokeAgent({
  name: "sisyphus-junior",
  model: "sonnet",  // 기본값
  task: "다음 PR을 코드 품질 관점에서 리뷰하세요",
  context: {
    code: pullRequest.changes,
    standards: projectCodingStandards
  }
});
```

#### 2. 문서 작성 및 설명

```yaml
Task: "REST API 문서 작성"
Requirements:
  - 엔드포인트 설명
  - 요청/응답 예제
  - 에러 처리 설명
Complexity: 0.55 (중간)

선택: Sonnet
이유: 구조화된 설명, 예제 작성, Context 필요
예상 토큰: 8,000-12,000
예상 비용: $0.070-0.130
```

#### 3. 버그 분석 및 진단

```yaml
Task: "메모리 누수 버그 분석"
Given:
  - 스택 트레이스
  - 관련 코드
  - 테스트 사례
Complexity: 0.6 (중간-높음)

선택: Sonnet
이유: 중간 복잡도의 추론, 일반적인 버그 패턴
예상 토큰: 10,000-15,000
예상 비용: $0.105-0.180
```

#### 4. 코드 리팩토링

```yaml
Task: "성능 최적화를 위해 함수 리팩토링"
Target: getUserData() 함수 (200줄)
Goal: 응답 시간 50% 단축
Complexity: 0.55 (중간)

선택: Sonnet
이유: 성능 의미 파악, 트레이드오프 고려
예상 토큰: 7,000-11,000
예상 비용: $0.075-0.130
```

#### 5. 통합 및 마이그레이션

```yaml
Task: "새로운 인증 라이브러리로 마이그레이션"
Changes:
  - 10개 파일 영향
  - 기존 로직 유지 필요
  - 보안 고려사항
Complexity: 0.6 (중간)

선택: Sonnet
이유: 광범위한 변경, 일관성 유지 필요
예상 토큰: 12,000-18,000
예상 비용: $0.150-0.220
```

**Sonnet 최적화 팁:**
- ✓ 대부분의 일상적인 개발 작업에 최적
- ✓ 복잡한 분석과 간단한 추론의 좋은 균형
- ✓ 예제와 설명이 필요한 작업에 적합
- ✓ 이전에 Haiku 시도했다가 부족한 경우 업그레이드
- ✗ 매우 복잡한 전략적 결정에는 부족할 수 있음

---

### 3️⃣ Opus 사용 시나리오

**언제 사용할까?**

#### 1. 아키텍처 설계 및 의사결정

```yaml
Task: "마이크로서비스 아키텍처 설계"
Considerations:
  - 확장성 (scalability)
  - 성능 (performance)
  - 운영 복잡도 (operational complexity)
  - 비용 최적화
  - 팀 역량
Complexity: 0.9 (매우 높음)

선택: Opus
이유: 다중 인수, 트레이드오프 분석, 전략적 결정
예상 토큰: 15,000-25,000
예상 비용: $0.200-0.375
```

**코드 예제:**
```javascript
// 복잡한 아키텍처 결정은 Opus
await invokeAgent({
  name: "prometheus",
  model: "opus",  // 필수
  task: "마이크로서비스 vs 모놀리식 아키텍처 분석",
  context: {
    currentLoad: systemMetrics,
    teamSize: organizationInfo,
    budget: projectBudget,
    timeline: developmentTimeline
  }
});
```

#### 2. 복잡한 버그의 근본 원인 분석

```yaml
Task: "신비로운 race condition 분석"
Symptoms:
  - 간헐적 실패
  - 재현 불가능
  - 프로덕션 환경에서만 발생
  - 여러 시스템 관련
Complexity: 0.85 (매우 높음)

선택: Opus
이유: 깊은 추론, 여러 가능성 탐색, 근본 원인 파악
예상 토큰: 12,000-20,000
예상 비용: $0.160-0.300
```

#### 3. 기술 스택 선택

```yaml
Task: "프론트엔드 프레임워크 선택 (React vs Vue vs Angular)"
Factors:
  - 성능 (Performance)
  - 개발 생산성 (Developer Productivity)
  - 커뮤니티 크기
  - 장기 유지보수성
  - 팀 경험
  - 프로젝트 요구사항
Complexity: 0.8 (높음)

선택: Opus
이유: 다중 기준 분석, 장기 영향 평가
예상 토큰: 18,000-28,000
예상 비용: $0.240-0.430
```

#### 4. 보안 감시 및 위험 분석

```yaml
Task: "새로운 의존성의 보안 위험 평가"
Input:
  - 의존성 코드 분석
  - 알려진 취약점 검토
  - 라이선스 호환성
  - 유지보수 상태
Complexity: 0.75 (높음)

선택: Opus
이유: 보안 결정의 중대성, 다중 인수 고려
예상 토큰: 10,000-18,000
예상 비용: $0.150-0.280
```

#### 5. 전략적 계획 및 로드맵

```yaml
Task: "향후 12개월 기술 로드맵 수립"
Inputs:
  - 현재 시스템 상태
  - 팀 역량
  - 비즈니스 목표
  - 기술 부채
  - 시장 동향
Complexity: 0.95 (매우 높음)

선택: Opus (필수)
이유: 전략적 중요성, 광범위한 영향, 다중 변수
예상 토큰: 20,000-35,000
예상 비용: $0.300-0.550
```

**Opus 사용 기준:**

upgrade to Opus when:
- ✓ 첫 시도 (Sonnet)이 실패했을 때
- ✓ 5개 이상 파일이 영향을 받을 때
- ✓ 건축적 결정 (Architecture decision)이 필요할 때
- ✓ 보안이 중대한 (Security-critical) 경우
- ✓ 전략적 계획이 필요할 때

Do NOT use Opus for:
- ✗ 간단한 검색/매칭
- ✗ 일상적인 코드 리뷰
- ✗ 기본적인 버그 수정
- ✗ 명확한 지시가 있는 작업

---

## 가격 대비 성능 분석

### 비용 효율성 비교

```
동일한 작업을 다양한 모델에서 실행 - 실제 비교

예: "1000줄 코드 리뷰"

Haiku 결과:
  비용: $0.040
  품질: 7/10 (표면적 문제만 감지)
  소요 시간: 2초

Sonnet 결과:
  비용: $0.090
  품질: 9/10 (심층 분석, 개선안 제시)
  소요 시간: 4초

Opus 결과:
  비용: $0.150
  품질: 9.5/10 (아키텍처 수준 지적)
  소요 시간: 6초

분석:
  Haiku vs Sonnet: 2.25배 비용 → 2점 품질 향상
  Sonnet vs Opus: 1.67배 비용 → 0.5점 품질 향상 (수익 감소)
  추천: Sonnet 선택 (최적 가치)
```

### 월간 비용 절감 시뮬레이션

```
시나리오: 일일 100개 API 호출, 현재 모두 Sonnet 사용

현재 비용 (Sonnet 100%):
  일일: 100 tasks × $0.07 average = $7
  월간: $7 × 30 = $210

최적화 후 (Haiku 40% + Sonnet 50% + Opus 10%):
  Haiku (40개): 40 × $0.025 = $1.00
  Sonnet (50개): 50 × $0.070 = $3.50
  Opus (10개): 10 × $0.150 = $1.50
  일일: $6.00
  월간: $180

월간 절감: $30 (14% 절감)
연간 절감: $360
```

### 언제 가격이 정당해지는가?

```
Sonnet ($0.090)이 Haiku ($0.040)보다 비싼 이유:

├─ 정확도 향상: +2점
├─ 설명 품질: +3점
├─ 반복 작업 불필요: 시간 절감
└─ 결과를 바로 사용 가능

ROI:
  - 추가 비용: $0.050 (125% 증가)
  - 시간 절감: 반복 작업 제거 = 1시간/주
  - 품질 향상으로 버그 감소: 예방 비용 절감
  - 결론: Haiku 실패로 재작업하는 것이 더 비쌈

결론: 불명확할 때는 Sonnet부터 시작하는 것이 더 경제적
```

---

## YAML 에이전트 설정 예제

### 1. Haiku 기반 검색 에이전트

```yaml
# agents/search-agent.yaml
name: search-agent
description: Fast file and pattern searching
model: haiku

capabilities:
  - file_search
  - pattern_matching
  - quick_lookup

performance:
  target_tokens: 2000
  max_latency: 1s
  expected_cost_per_call: $0.02

system_prompt: |
  당신은 파일 검색 전문가입니다.
  주어진 패턴에 정확히 일치하는 파일을 찾으세요.

instructions:
  - 단순하고 명확한 결과 제공
  - 파일 경로만 나열 (설명 불필요)
  - 정규식 지원
```

### 2. Sonnet 기반 표준 분석 에이전트

```yaml
# agents/analyzer-agent.yaml
name: analyzer-agent
description: Code and architecture analysis
model: sonnet  # MEDIUM 티어 기본값

capabilities:
  - code_analysis
  - pattern_detection
  - documentation_review
  - bug_detection

performance:
  target_tokens: 8000
  max_latency: 5s
  expected_cost_per_call: $0.08

fallback_model: opus
fallback_condition: "complexity > 0.7 OR retry_count > 0"

system_prompt: |
  당신은 경험 많은 소프트웨어 엔지니어입니다.
  코드를 분석하고 개선안을 제시하세요.

instructions:
  - 구조적 분석 제공
  - 구체적인 개선안 제시
  - 트레이드오프 설명
```

### 3. Opus 기반 전략 계획 에이전트

```yaml
# agents/prometheus-agent.yaml
name: prometheus-agent
description: Strategic planning and complex reasoning
model: opus  # HIGH 티어 필수

capabilities:
  - strategic_planning
  - complex_reasoning
  - architecture_design
  - risk_analysis

performance:
  target_tokens: 20000
  max_latency: 10s
  expected_cost_per_call: $0.20

min_model: opus  # 다운그레이드 불가

system_prompt: |
  당신은 기술 전략가이자 아키텍처 설계자입니다.
  장기적 관점에서 전략적 결정을 지원하세요.

instructions:
  - 다중 관점 분석
  - 트레이드오프 명확히
  - 장기 영향 평가
  - 위험 요소 식별
```

### 4. 동적 모델 선택 에이전트

```yaml
# agents/adaptive-agent.yaml
name: adaptive-agent
description: Dynamically selects model based on task complexity
strategy: intelligent_routing

model_selection:
  default: sonnet

  rules:
    - condition: "task.complexity < 0.4"
      model: haiku
      reason: "Simple task - optimize for cost"
      confidence: 0.95

    - condition: "task.complexity >= 0.4 AND task.complexity < 0.7"
      model: sonnet
      reason: "Standard task - balance cost and quality"
      confidence: 0.99

    - condition: "task.complexity >= 0.7"
      model: opus
      reason: "Complex task - prioritize accuracy"
      confidence: 0.98

    - condition: "task.prior_failures > 0 AND task.model == 'haiku'"
      model: sonnet
      reason: "Haiku failed previously - upgrade"
      confidence: 0.90

complexity_calculator: |
  (
    input_length * 0.2 +
    required_reasoning * 0.5 +
    decision_points * 0.3
  ) / 100

monitoring:
  track_quality: true
  track_cost: true
  auto_adjust: true
  adjustment_interval: 7d
```

---

## 의사결정 플로우차트 (상세)

```
작업 받음
│
├─ 단계 1: 복잡도 빠른 평가
│  ├─ 명확함? (검색, 매칭, 포매팅) → Haiku ✓
│  ├─ 중간 정도? (분석, 리뷰, 문서) → Sonnet ✓
│  └─ 복잡함? (설계, 전략, 아키텍처) → Opus ✓
│
├─ 단계 2: 우선순위 확인
│  ├─ 비용 중시?
│  │  └─ 한 단계 낮춤 (Opus→Sonnet, Sonnet→Haiku)
│  ├─ 품질 중시?
│  │  └─ 한 단계 높임 (Haiku→Sonnet, Sonnet→Opus)
│  └─ 불명확?
│     └─ Sonnet 유지 (기본값)
│
├─ 단계 3: 이전 경험 확인
│  ├─ 같은 작업 전에 했나?
│  │  ├─ 성공했나? → 같은 모델 사용
│  │  └─ 실패했나? → 한 단계 높임
│  └─ 처음인가? → 기본값 사용
│
└─ 실행 & 평가
   ├─ 결과 품질 평가
   ├─ 소요 시간 확인
   ├─ 실제 비용 기록
   └─ 다음을 위해 데이터 저장
```

---

## 실전 예제

### 예제 1: 새로운 기능 추가 (Realtime Notifications)

```
요청: "실시간 알림 기능 추가"

분석 계획 수립:
├─ 단계 1: 기존 코드 검색 (Haiku)
│  Task: "알림 관련 기존 코드 모두 찾기"
│  Complexity: 0.2
│  Model: Haiku
│  Cost: $0.02
│  Time: 2초
│
├─ 단계 2: 아키텍처 이해 (Sonnet)
│  Task: "알림 시스템의 현재 아키텍처 분석"
│  Complexity: 0.5
│  Model: Sonnet
│  Cost: $0.08
│  Time: 4초
│
├─ 단계 3: 설계 패턴 결정 (Opus)
│  Task: "실시간 알림을 위한 최적 아키텍처 제안"
│  Considerations: Scalability, Latency, Cost
│  Complexity: 0.85
│  Model: Opus
│  Cost: $0.20
│  Time: 6초
│
└─ 단계 4: 구현 코드 작성 (Sonnet)
   Task: "WebSocket 기반 알림 시스템 구현"
   Complexity: 0.6
   Model: Sonnet
   Cost: $0.10
   Time: 5초

총 비용: $0.40
총 시간: 17초

최적화 결과:
- 모두 Opus 사용: $0.80 (비용 2배)
- 현재 혼합: $0.40 (최적)
```

### 예제 2: 버그 수정 (CSRF Token Error)

```
요청: "로그인 페이지에서 CSRF 토큰 오류 발생"

분석 프로세스:
├─ 단계 1: 에러 로그 확인 (Haiku)
│  Cost: $0.01
│
├─ 단계 2: 관련 코드 찾기 (Haiku)
│  Cost: $0.02
│
├─ 단계 3: 패턴 분석 (Sonnet)
│  Task: "CSRF 토큰 검증 로직 분석"
│  Cost: $0.05
│
├─ 단계 4: 근본 원인 분석 (Opus)
│  Task: "왜 CSRF 토큰이 유효하지 않은가?"
│  Cost: $0.15
│
└─ 단계 5: 수정 코드 작성 (Sonnet)
   Cost: $0.06

총 비용: $0.29
절감: Haiku로 기초 수집하면 30% 비용 절감

비교:
- 모두 Opus: $0.50
- 최적화: $0.29 (42% 절감)
```

### 예제 3: 코드 리뷰 (1000줄)

```
요청: "Pull Request 1000줄 코드 리뷰"

기본 접근 (모두 Opus):
  Cost: $0.90
  Time: 15초
  Quality: 9.5/10

최적화 접근:
├─ 구조 확인 (Haiku) → $0.02, 1초
├─ 패턴 검토 (Sonnet) → $0.08, 3초
├─ 보안 분석 (Opus) → $0.20, 5초
└─ 최종 종합 (Sonnet) → $0.07, 2초

최적화 비용: $0.37 (59% 절감)
최적화 시간: 11초 (26% 단축)
최적화 품질: 9/10 (거의 동일)

ROI: $0.53 절감으로 동일한 품질 달성
```

---

## 모델 선택 체크리스트

### 작업 분류 단계

- [ ] 작업의 주요 목표가 무엇인가?
- [ ] 얼마나 복잡한가? (단순/중간/복잡)
- [ ] 창의성이 필요한가?
- [ ] 정확도가 중요한가?
- [ ] 속도가 중요한가?
- [ ] 비용이 중요한가?

### 모델 선택 단계

- [ ] 기본값 (Sonnet) 고려
- [ ] 비용 제약이 있으면 Haiku 고려
- [ ] 품질 중시면 Opus 고려
- [ ] 불명확하면 Sonnet으로 시작

### 실행 후 평가

- [ ] 결과 품질 평가
- [ ] 토큰 사용량 기록
- [ ] 비용 확인
- [ ] 소요 시간 측정
- [ ] 데이터 저장 및 추후 참고

---

## 일반적인 실수

### ❌ 실수 1: 모든 작업에 Opus 사용

```javascript
// 나쁜 예
async function findTestFiles() {
  return await invokeAgent({
    name: "oracle",
    model: "opus",  // 과도함!
    task: "모든 test 파일 찾기"
  });
}

// 좋은 예
async function findTestFiles() {
  return await invokeAgent({
    name: "explore",
    model: "haiku",  // 적절함
    task: "모든 test 파일 찾기"
  });
}
```

비용 영향: 5배 비용 증가

### ❌ 실수 2: 벤치마킹 없이 모델 선택

```javascript
// 나쁜 예
const model = "sonnet";  // 왜? 모름

// 좋은 예
const model = await selectModelByBenchmark({
  task: "code-review",
  targetQuality: 0.9,
  costLimit: 0.10
});
```

비용 영향: 최적이 아닌 모델 선택으로 불필요한 비용

### ❌ 실수 3: 품질 무시

```javascript
// 나쁜 예: 가장 저렴한 모델만 사용
const model = "haiku";  // 항상

// 좋은 예: 품질과 비용 균형
const quality = evaluateOutput(result);
if (quality < requiredQuality) {
  // Sonnet이나 Opus로 재시도
}
```

비용 영향: Haiku 재작업 > Sonnet 한 번

### ❌ 실수 4: 토큰 사용량 미추적

```javascript
// 나쁜 예: 무시
console.log(response);  // 정보 확인 안 함

// 좋은 예: 추적
tracker.record({
  model: response.model,
  input_tokens: response.usage.input_tokens,
  output_tokens: response.usage.output_tokens,
  cost: calculateCost(response)
});
```

비용 영향: 비효율 감지 불가능

---

## 모니터링 및 최적화

### 토큰 사용량 추적

```javascript
class ModelOptimizer {
  constructor() {
    this.taskMetrics = new Map();
  }

  recordTask(taskName, model, inputTokens, outputTokens, quality) {
    const cost = this.calculateCost(model, inputTokens, outputTokens);

    if (!this.taskMetrics.has(taskName)) {
      this.taskMetrics.set(taskName, []);
    }

    this.taskMetrics.get(taskName).push({
      model,
      cost,
      quality,
      efficiency: quality / cost,
      timestamp: new Date()
    });
  }

  getOptimalModel(taskName) {
    const results = this.taskMetrics.get(taskName) || [];

    // 비용 대비 품질로 정렬
    return results
      .sort((a, b) => b.efficiency - a.efficiency)
      .reverse()[0]?.model || "sonnet";
  }

  generateReport() {
    const report = {};

    for (const [taskName, metrics] of this.taskMetrics.entries()) {
      const avgCost = metrics.reduce((sum, m) => sum + m.cost, 0) / metrics.length;
      const avgQuality = metrics.reduce((sum, m) => sum + m.quality, 0) / metrics.length;
      const bestModel = this.getOptimalModel(taskName);

      report[taskName] = {
        avgCost,
        avgQuality,
        bestModel,
        savings: this.estimateSavings(taskName)
      };
    }

    return report;
  }
}
```

### 월간 최적화 리포트 템플릿

```markdown
# Model Selection Optimization Report

## Summary
- 총 작업 수: 150
- 총 비용: $1,240
- 작업당 평균 비용: $8.27
- 모델 분포: Haiku 25%, Sonnet 65%, Opus 10%

## 모델별 분석

### Haiku 사용
- 작업 수: 38 (25%)
- 총 비용: $76
- 작업당: $2.00
- 품질 점수: 8.2/10

### Sonnet 사용 (기본값)
- 작업 수: 98 (65%)
- 총 비용: $784
- 작업당: $8.00
- 품질 점수: 9.1/10

### Opus 사용
- 작업 수: 14 (10%)
- 총 비용: $380
- 작업당: $27.14
- 품질 점수: 9.6/10

## 최적화 기회

1. Sonnet → Haiku 전환 가능: 8개 작업
   - 절감: $60/월

2. Opus 사용 정당성 확인: 모두 적절함
   - 유지

## 권장사항

- Haiku 사용 30%로 증가 (현재 25%)
- Sonnet 60%로 감소 (현재 65%)
- Opus 유지 (현재 10%)
- 예상 월간 절감: 12-15%
```

---

## 다음 단계

모델 선택 전략을 완성했다면:

1. **[Subagent Architecture](./01-subagent-architecture.md)** - 에이전트 구성 심화
2. **[Tool Optimizations](./03-tool-optimizations.md)** - 도구별 토큰 절약
3. **[Background Processes](./04-background-processes.md)** - 병렬 처리 최적화

---

## 빠른 참고: 언제 어떤 모델?

| 작업 | 모델 | 비용 | 이유 |
|------|------|------|------|
| 파일 검색 | Haiku | $0.02 | 단순 패턴 매칭 |
| 텍스트 정리 | Haiku | $0.03 | 결정론적 변환 |
| 코드 리뷰 | Sonnet | $0.08 | 균형잡힌 분석 |
| 문서 작성 | Sonnet | $0.10 | 구조화된 설명 |
| 버그 디버깅 | Sonnet | $0.12 | 중간 복잡도 |
| 아키텍처 설계 | Opus | $0.20 | 복잡한 추론 |
| 전략 계획 | Opus | $0.25 | 다중 인수 |
| 불명확한 작업 | Sonnet | $0.08 | 기본값 |

---

## 참고 자료

- [Anthropic Pricing (2026년 1월)](https://platform.claude.com/docs/en/about-claude/pricing)
- [Claude Models Comparison](https://docs.anthropic.com/claude/reference/models-overview)
- [Token Counting Guide](https://docs.anthropic.com/claude/reference/token-counting-api)

---

<div align="center">

### Intelligent Model Selection = 30-70% Cost Savings

**올바른 모델 선택으로 비용을 절감하고 더 빠른 결과를 얻으세요.**

</div>

---

**문서 작성**: Claude Automate 기술 문서팀
**최종 수정**: 2026년 1월
**상태**: 작성 완료
**원본 출처**: Affaan Mustafa's Claude Code Strategy
