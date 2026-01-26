# Verification Loops & Evals

## 개요 (Overview)

**Verification Loops & Evals**은 Claude와의 상호작용에서 생성된 결과물의 품질을 지속적으로 보증하는 체계입니다. 자동화 시스템이 신뢰할 수 있는 결과를 생성하는지 검증하고, 실패 패턴을 분석하며, 성능을 계속 개선하는 방법을 다룹니다.

### 왜 중요한가?

자동화 시스템을 구축할 때 가장 중요한 질문은 **"정말 작동하는가?"**입니다.

Claude가 작업을 완료했다고 해서 정말 올바르게 완료했는지 확신할 수 없습니다:

- **Hallucination Risk**: 모델이 존재하지 않는 정보를 생성할 수 있습니다
- **Edge Cases**: 일반적인 경우는 작동하지만, 특수한 경우에 실패할 수 있습니다
- **Quality Degradation**: 시간이 지나면서 품질이 저하될 수 있습니다
- **Unknowable Failures**: 실패를 감지하지 못하고 계속 진행할 수 있습니다

Verification Loops & Evals는 이러한 문제를 체계적으로 해결하여:

1. **신뢰성 보증** - 결과물의 품질을 객관적으로 측정
2. **조기 실패 감지** - 문제를 최대한 빨리 발견하고 해결
3. **성능 추적** - 시간에 따른 품질 변화를 모니터링
4. **지속적 개선** - Feedback을 바탕으로 시스템 개선

---

## 5개 핵심 섹션

이 가이드에서는 검증 체계의 주요 개념과 구현 방식을 다룹니다:

### 1. [Observability Methods](./01-observability-methods.md)
시스템의 동작 상태를 관찰하고 이해하는 방법을 설명합니다.

**주요 내용:**
- Logging 전략 및 구조화된 로그 (Structured Logging)
- Tracing: 작업 흐름 추적 (Execution Trace)
- Monitoring: 실시간 상태 감시 (Real-time Monitoring)
- Error Tracking: 예외와 오류 기록 (Exception Tracking)
- Observability 도구 및 대시보드

---

### 2. [Benchmarking Workflow](./02-benchmarking-workflow.md)
시스템의 성능을 체계적으로 측정하고 비교하는 프로세스를 다룹니다.

**주요 내용:**
- Benchmark 설계: 공정한 비교 기준 수립
- Baseline 설정: 성능 기준점 정의
- A/B Testing: 변경 전후 비교
- Performance Profiling: 병목 구간 분석
- Regression Detection: 성능 저하 감지
- Benchmark Suite 관리

---

### 3. [Eval Pattern Types](./03-eval-pattern-types.md)
검증 로직의 다양한 패턴과 각각의 사용 시기를 설명합니다.

**주요 내용:**
- **Unit Evals**: 개별 기능 검증 (함수/메서드 수준)
- **Integration Evals**: 통합 검증 (여러 컴포넌트 간 상호작용)
- **End-to-End Evals**: 전체 흐름 검증 (사용자 시나리오 기반)
- **Property-Based Evals**: 속성 기반 검증 (불변값 검증)
- **Semantic Evals**: 의미 기반 검증 (LLM 출력 검증)
- **Human-in-the-Loop Evals**: 사람의 판단을 포함한 검증

---

### 4. [Grader Types](./04-grader-types.md)
평가(Grading) 로직의 다양한 유형과 구현 방식을 다룹니다.

**주요 내용:**
- **Deterministic Graders**: 명확한 규칙 기반 평가 (정해진 규칙)
- **LLM-as-a-Judge**: LLM을 평가자로 활용 (모델 활용)
- **Similarity-Based Graders**: 유사도 기반 평가 (텍스트 비교)
- **Custom Graders**: 도메인 특화 평가자 (맞춤형 로직)
- **Composite Graders**: 여러 평가자 조합 (다중 평가)
- **Grader Implementation Patterns**: 실제 구현 예제

---

### 5. [Key Metrics](./05-key-metrics.md)
검증 시스템에서 추적해야 할 핵심 지표와 해석 방법을 설명합니다.

**주요 내용:**
- **Pass Rate / Success Rate**: 성공 비율
- **Latency / Response Time**: 응답 시간
- **Quality Scores**: 품질 점수
- **Error Rate**: 오류 발생률
- **Coverage**: 테스트 범위
- **Consistency**: 결과 일관성
- **Cost per Verification**: 검증 비용
- **Metric 수집 및 시각화**: 데이터 분석

---

## 학습 경로

처음 Verification Loops & Evals를 학습하는 분이라면:

1. **[Observability Methods](./01-observability-methods.md)** 부터 시작하여 시스템 상태를 관찰하는 기본을 배웁니다
2. **[Benchmarking Workflow](./02-benchmarking-workflow.md)** 에서 성능 측정의 중요성을 이해합니다
3. **[Eval Pattern Types](./03-eval-pattern-types.md)** 로 검증 전략의 다양성을 살펴봅니다
4. **[Grader Types](./04-grader-types.md)** 에서 평가 로직을 구현하는 방법을 배웁니다
5. **[Key Metrics](./05-key-metrics.md)** 으로 성능을 추적하는 방법을 마무리합니다

---

## 핵심 개념 요약

| 개념 | 한글 | 설명 |
|------|------|------|
| **Verification Loop** | 검증 루프 | 실행 → 평가 → 개선의 반복 주기 |
| **Eval** | 평가 | 결과가 요구사항을 만족하는지 검증 |
| **Grader** | 평가자 | 평가를 수행하는 로직이나 함수 |
| **Benchmark** | 벤치마크 | 성능을 비교하기 위한 표준 기준점 |
| **Metric** | 지표 | 성능이나 품질을 나타내는 정량적 값 |
| **Observability** | 관찰성 | 시스템의 내부 동작을 외부에서 파악할 수 있는 정도 |
| **Coverage** | 커버리지 | 테스트나 검증이 시스템의 어느 정도를 포함하는가 |
| **Regression** | 회귀 | 이전에 작동했던 기능이 다시 실패하는 현상 |

---

## 실제 적용 시나리오

### 시나리오 1: LLM 기반 텍스트 생성 검증

```
상황: 문서 자동 생성 시스템
문제: Claude가 생성한 문서의 품질을 확보하고 싶습니다.

해결 방법:
1. [Observability] → 생성된 각 문서의 메타데이터(길이, 토큰, 시간) 기록
2. [Benchmarking] → 샘플 문서 10개를 기준점으로 설정
3. [Eval Patterns] → End-to-End eval로 전체 문서 완성도 검증
4. [Graders] → LLM-as-a-Judge로 내용 품질 평가
5. [Metrics] → Pass Rate, 평균 점수, 생성 시간 추적
```

### 시나리오 2: 코드 생성 안정성 모니터링

```
상황: 코드 생성 기능의 성능 추적
문제: 모델 업데이트 후 코드 품질이 저하되었는지 확인하고 싶습니다.

해결 방법:
1. [Observability] → 생성된 코드의 컴파일/런타임 오류 기록
2. [Benchmarking] → 테스트 스위트 구성 (30개 함수 생성)
3. [Eval Patterns] → Unit Evals로 각 함수 검증
4. [Graders] → 컴파일 성공 여부, 테스트 통과 여부 확인
5. [Metrics] → Pass Rate (전: 95%, 후: 88%) → 회귀 감지!
```

### 시나리오 3: 멀티 에이전트 시스템 품질 보증

```
상황: 여러 에이전트가 협력하는 시스템
문제: 에이전트 간 통신과 최종 결과물의 품질을 보증하고 싶습니다.

해결 방법:
1. [Observability] → 각 에이전트의 로그, 입출력 추적
2. [Benchmarking] → 복잡도별 테스트 케이스 (쉬움/중간/어려움)
3. [Eval Patterns] → Integration Evals로 에이전트 간 통신 검증
4. [Graders] → Composite Grader로 여러 관점에서 평가
5. [Metrics] → 에이전트별 Pass Rate, 전체 시스템 일관성 추적
```

---

## 일반적인 실수와 주의사항

### ❌ 하면 안 되는 것

1. **평가 없는 자동화**
   - 검증 없이 자동으로 코드 배포하기
   - 결과를 확인하지 않고 다음 단계 진행하기

2. **불충분한 커버리지**
   - 행복한 경로(Happy Path)만 테스트하기
   - 엣지 케이스를 무시하기

3. **수동 평가만 의존**
   - 모든 평가를 사람이 직접 하기
   - 확장성이 제한됨

4. **너무 엄격한 평가**
   - 완벽함을 추구하느라 반복 주기가 너무 길어짐
   - "완벽한 평가"를 기다리다가 배포를 못 하는 상황

### ✅ 좋은 실천 방법

1. **계층적 검증**
   - 빠른 검증(자동)부터 시작
   - 필요한 경우만 느린 검증(사람) 실행

2. **조기 실패**
   - 문제를 빨리 발견하고 즉시 피드백 제공
   - 작은 변경은 빠르게 검증, 빠르게 배포

3. **추적 가능한 메트릭**
   - 모든 검증 결과를 기록
   - 시간에 따른 변화를 추적

4. **문제 재현 가능성**
   - 실패 케이스를 보존하고 분석
   - "왜 실패했는가"를 이해

---

## 관련 섹션

### 이 섹션과 연관된 다른 가이드들

- **[Context & Memory Management](../01-context-memory/README.md)** - 검증 결과를 세션에 저장하고 활용하기
- **[Token Optimization](../02-token-optimization/README.md)** - 검증에 필요한 토큰 비용 최소화
- **[Parallelization](../04-parallelization/README.md)** - 여러 검증을 병렬로 실행하기
- **[Groundwork](../05-groundwork/README.md)** - 검증 시스템 설계하기
- **[Agent Best Practices](../06-agent-best-practices/README.md)** - 에이전트 출력 검증하기

---

## 용어 정의 (Glossary)

### 영어 ↔ 한글

| 영어 | 한글 | 설명 |
|------|------|------|
| Verification | 검증 | 결과가 요구사항을 만족하는지 확인 |
| Evaluation (Eval) | 평가 | 결과의 품질을 측정 |
| Grader | 평가자 | 평가를 수행하는 함수/로직 |
| Benchmark | 벤치마크 | 성능 비교의 기준점 |
| Baseline | 기준점 | 초기 성능 수준 |
| Regression | 회귀 | 이전에 작동하던 것이 다시 실패함 |
| Metric | 지표 | 성능/품질의 정량적 측정값 |
| Observability | 관찰성 | 시스템 동작을 파악할 수 있는 정도 |
| Coverage | 커버리지 | 검증이 차지하는 범위 |
| Pass Rate | 통과율 | 성공한 검증의 비율 |
| Latency | 응답 시간 | 요청에서 응답까지 걸리는 시간 |
| Deterministic | 결정론적 | 입력이 같으면 항상 같은 결과 |
| Semantic | 의미론적 | 단순 문자 비교가 아닌 의미 기반 |
| Property-Based | 속성 기반 | 항상 만족해야 할 불변 속성 검증 |

---

## 다음 단계

이 섹션을 완독한 후:

1. **5개 섹션 차례로 학습하기**
   - 각 섹션의 개념 이해하기
   - 실제 예제 코드 살펴보기

2. **프로젝트에 적용하기**
   - 현재 시스템의 검증 전략 분석
   - 부족한 부분 식별
   - 개선 계획 수립

3. **다른 가이드와 연결하기**
   - Token Optimization으로 검증 비용 절감
   - Parallelization으로 검증 속도 개선
   - Agent Best Practices로 에이전트 신뢰성 강화

---

## 문서 네비게이션

```
📑 Verification Loops & Evals 섹션
├── 📌 01-observability-methods.md
│   └── 시스템 상태 관찰 방법
├── 📌 02-benchmarking-workflow.md
│   └── 성능 측정 및 비교 프로세스
├── 📌 03-eval-pattern-types.md
│   └── 검증 전략의 다양한 패턴
├── 📌 04-grader-types.md
│   └── 평가 로직 구현 방식
├── 📌 05-key-metrics.md
│   └── 추적해야 할 핵심 지표
└── 📚 examples/ (향후 추가)
    ├── observability-example.md
    ├── benchmarking-example.md
    ├── eval-patterns-example.md
    ├── grader-example.md
    └── metrics-dashboard-example.md
```

---

## 자주 묻는 질문 (FAQ)

### Q1: Verification과 Testing의 차이점은?

**Testing** = 코드/기능이 올바르게 작동하는가?
**Verification** = 결과가 요구사항을 충족하는가?

특히 LLM 시스템에서는:
- Testing: 함수 호출이 오류를 발생시키는가?
- Verification: LLM이 생성한 텍스트의 품질은 충분한가?

### Q2: 모든 결과를 검증해야 하나요?

아니요. 비용-효과 분석이 필요합니다:

- **높은 리스크** → 100% 검증 (예: 금융 거래)
- **중간 리스크** → 샘플링 검증 (예: 콘텐츠 생성)
- **낮은 리스크** → 스팟 체크 (예: 로그 생성)

### Q3: LLM-as-a-Judge는 신뢰할 수 있나요?

신뢰할 수 있지만 주의가 필요합니다:

✅ 좋은 사용 사례: 의미 기반 평가, 시맨틱 유사도
❌피해야 할 사용 사례: 정확한 수치 계산, 명확한 규칙 위반

### Q4: 얼마나 많은 테스트 케이스가 필요한가?

일반적인 가이드:
- **Unit Evals**: 함수당 3-10개
- **Integration Evals**: 시나리오당 5-20개
- **E2E Evals**: 전체 경로당 10-50개

실제로는 **커버리지와 비용의 균형**을 찾아야 합니다.

### Q5: Regression을 감지하는 가장 좋은 방법은?

1. **Baseline 설정**: 초기 성능 기준점 수립
2. **정기적 벤치마크**: 주 1회 또는 주 2회 실행
3. **자동 알림**: Pass Rate 5% 이상 저하 시 알림
4. **변경 분석**: 회귀 원인 파악 및 대응

---

## 작성 정보

**섹션 작성자**: claude-automate 문서팀
**마지막 수정**: 2026년 1월
**상태**: 작성 중
**관련 버전**: claude-automate v0.3.0+

---

<div align="center">

### 품질 있는 자동화는 검증에서 시작됩니다.

**Trust your automation through systematic verification.**

</div>
