# Token Optimization (토큰 최적화)

## 개요

**Token Optimization**은 Claude와 함께 작업할 때 **비용과 속도**를 극대화하기 위한 핵심 전략입니다. 제한된 토큰 예산으로 더 좋은 결과를 얻는 방법을 배웁니다.

### 왜 중요한가?

Claude API를 사용할 때, 토큰은 두 가지 의미를 가집니다:

- **경제적 비용**: 더 많은 토큰 = 더 높은 요금
- **응답 속도**: 더 효율적인 토큰 사용 = 더 빠른 응답

마찬가지로 **Context Window의 한계**는 때때로 문제가 됩니다:

- **제한된 Context**: 200K 토큰도 충분하지 않을 수 있습니다
- **불필요한 반복**: 매번 동일한 정보를 다시 입력하는 낭비
- **느린 응답**: 큰 Context를 처리하는 시간 비용

Token Optimization은 이러한 문제들을 해결합니다:

1. **모델 선택 전략** - 올바른 모델을 올바른 작업에 사용
2. **도구 기반 토큰 절약** - Tool 호출로 불필요한 정보 전송 방지
3. **배경 처리** - 장시간 작업을 비동기로 실행
4. **동적 Context** - 필요한 정보만 동적으로 주입
5. **System Prompt 최적화** - 핵심 지시만 포함

---

## 6개 핵심 섹션

이 섹션에서는 Token Optimization의 주요 개념과 실제 적용 방법을 다룹니다:

### 1. [Subagent Architecture](./01-subagent-architecture.md)

**멀티 에이전트 시스템**에서 토큰을 효율적으로 사용하는 아키텍처를 다룹니다.

- Subagent와 Orchestrator의 역할 분담
- 각 에이전트에 필요한 최소한의 정보만 전달
- 에이전트 간 Context 최소화
- Specialized agent (Haiku, Sonnet, Opus)의 활용
- 병렬 에이전트 실행으로 대기 시간 절약

**핵심 개념**: Small agent가 Haiku로, complex reasoning은 Opus로 처리하여 비용 최소화

---

### 2. [Model Selection Quick Reference](./02-model-selection.md)

**모델 선택 (Model Tier Strategy)**은 가장 직접적인 토큰 절약 방법입니다.

- Haiku (빠름, 저비용): 데이터 수집, 패턴 매칭, 간단한 검색
- Sonnet (균형): 분석, 의사결정, 표준 업무
- Opus (강력함, 고비용): 복잡한 추론, 전략적 결정

각 모델별 최적 사용 사례와 토큰 비용 비교

**핵심 개념**: 올바른 도구를 올바른 작업에 사용하면 비용이 70% 이상 절감될 수 있습니다

---

### 3. [Tool Optimizations](./03-tool-optimizations.md)

**Claude Code의 각 도구별** 토큰을 절약하는 기법을 다룹니다.

- **Bash Tool**: 파일 읽기 대신 기본 처리로 token 절약
- **Read Tool**: 대용량 파일의 범위 읽기 (offset/limit)
- **Glob Tool**: grep 대신 Glob으로 파일 검색 (토큰 절약)
- **Grep Tool**: 정규식 최적화와 필터링
- **Edit Tool**: 대량 변경의 배치 처리
- **Browser Tools**: 성능 추적과 스크린샷 최소화

Tool 조합으로 불필요한 컨텍스트 전송 방지

**핵심 개념**: 올바른 Tool 조합은 같은 작업을 30% 더 효율적으로 수행합니다

---

### 4. [Background Processes](./04-background-processes.md)

**장시간 작업을 비동기로 실행**하여 대기 시간을 제거합니다.

- `run_in_background: true` 매개변수 활용
- npm install, build, test 등 장시간 작업 백그라운드 처리
- 동시 실행 가능한 작업 식별 (최대 5개)
- 배경 작업 모니터링 및 결과 수집

Foreground와 Background 작업의 명확한 분류

**핵심 개념**: 순차 처리를 병렬로 바꾸면 전체 실행 시간이 80% 단축될 수 있습니다

---

### 5. [Modular Codebase Benefits](./05-modular-codebase-benefits.md)

**모듈화된 코드베이스**는 토큰 효율성에 직접 영향을 미칩니다.

- 작은 파일 = 필요한 부분만 읽기 가능
- 명확한 인터페이스 = 전체 구현을 이해할 필요 없음
- 독립적인 컴포넌트 = Parallel processing 가능
- 함수 단위 문서 = Context window 절약

코드 구조가 토큰 효율성을 어떻게 결정하는지 이해

**핵심 개념**: 좋은 아키텍처는 토큰 절약이 아니라 토큰 효율성을 구조적으로 가능하게 합니다

---

### 6. [System Prompt Slimming](./06-system-prompt-slimming.md)

**System Prompt는 매 요청마다 포함**되므로, 최소화하는 것이 중요합니다.

- System Prompt 크기 측정 방법
- 필수 지시와 선택적 지시의 분류
- Dynamic prompt injection으로 필요한 것만 추가
- Skill 기반 instruction 분산
- Prompt caching으로 반복 비용 절감

System Prompt가 1KB 감소하면 모든 요청에서 토큰 절약

**핵심 개념**: 50행의 System Prompt 최적화는 매달 수천 개 토큰을 절약합니다

---

## 학습 경로

처음 Token Optimization을 배우는 경우:

1. **[Subagent Architecture](./01-subagent-architecture.md)** 부터 시작하여 멀티 에이전트 패턴을 이해합니다
2. **[Model Selection Quick Reference](./02-model-selection.md)** 에서 즉시 적용 가능한 모델 선택 기준을 배웁니다
3. **[Tool Optimizations](./03-tool-optimizations.md)** 으로 일상적인 작업 최적화를 배웁니다
4. **[Background Processes](./04-background-processes.md)** 로 병렬 처리를 마스터합니다
5. **[Modular Codebase Benefits](./05-modular-codebase-benefits.md)** 에서 아키텍처 관점 이해
6. **[System Prompt Slimming](./06-system-prompt-slimming.md)** 으로 마무리합니다

---

## 주요 개념 요약

| 개념 | 설명 | 토큰 절약율 |
|------|------|-----------|
| **Model Tier** | 올바른 모델 선택 | 50-70% |
| **Subagent Pattern** | 전문가 에이전트 활용 | 30-40% |
| **Tool Optimization** | 적절한 도구 선택 | 20-30% |
| **Background Processing** | 병렬 작업 | 시간 절약 (비용은 동일) |
| **Modular Architecture** | 작은 모듈 기반 설계 | 40-50% |
| **System Prompt Lean** | 최소화된 지시 | 15-25% |

---

## 빠른 적용 가이드

### 지금 바로 적용 가능한 최적화 (Top 5)

**1. Model Tier 전략**
```python
# 나쁜 예: 모든 작업에 Opus 사용
Task(subagent_type="claude-opus")  # 비용 비싸고 느림

# 좋은 예: 작업별로 적절한 모델 선택
Task(subagent_type="oh-my-claude-sisyphus:explore")  # Haiku - 빠르고 저렴
Task(subagent_type="oh-my-claude-sisyphus:sisyphus-junior")  # Sonnet - 균형
Task(subagent_type="oh-my-claude-sisyphus:oracle")  # Opus - 복잡한 추론
```
**절약**: 70% 비용 감소

---

**2. Background Processing**
```python
# 나쁜 예: 설치 작업을 blocking으로 처리
Bash(command="npm install", timeout=30000)  # 30초 대기

# 좋은 예: 백그라운드에서 실행
Bash(command="npm install", run_in_background=True)  # 즉시 반환
# ... 다른 작업 수행 ...
TaskOutput(task_id="...")  # 결과 확인
```
**절약**: 시간 절약 (전체 실행 80% 단축)

---

**3. Tool 선택 최적화**
```python
# 나쁜 예: grep을 bash로 구현
Bash(command="grep -r 'pattern' .")  # 많은 파일 처리 토큰 낭비

# 좋은 예: Grep Tool 사용
Grep(pattern="pattern", path=".")  # 최적화된 검색
```
**절약**: 30% 토큰 절약

---

**4. 범위 읽기**
```python
# 나쁜 예: 전체 파일 읽기
Read(file_path="/path/to/large/file.py")  # 5000줄 모두 로드

# 좋은 예: 필요한 부분만 읽기
Read(file_path="/path/to/large/file.py", offset=100, limit=50)  # 50줄만 읽기
```
**절약**: 90% 토큰 절약 (필요한 부분에 따라)

---

**5. System Prompt 최소화**
```
# 현재 System Prompt 크기 측정
# 50행 초과? → 다음을 검토하세요:
# - 예제는 정말 필요한가?
# - 설명을 짧게 할 수 있는가?
# - 일부는 Agent별로 분산할 수 있는가?

# 결과: 매 요청마다 200-500 토큰 절약
```
**절약**: 매달 1,000,000+ 토큰 절약

---

## 관련 문서

### 같은 레벨의 다른 섹션

- [Context & Memory Management](../01-context-memory/README.md) - Context 효율성
- [Verification Loops & Evals](../03-verification-evals/README.md) - 품질 검증
- [Parallelization](../04-parallelization/README.md) - 병렬 처리 전략
- [Groundwork](../05-groundwork/README.md) - 프로젝트 설계
- [Agent Best Practices](../06-agent-best-practices/README.md) - Agent 설계

### 예제

- [`examples/agent-configs/`](../examples/agent-configs/) - Agent 설정 예제
- [`examples/`](../examples/) - 전체 예제 모음

### 메인 가이드

- [Longform Guide Overview](../README.md) - 전체 가이드 소개
- [main README](../../README.md) - Claude Automate 프로젝트 개요

---

## 토큰 절약 계산기

### 월간 토큰 절약 추정

```
기본 설정:
- 일일 API 호출: 100회
- 평균 System Prompt: 2KB (약 500 토큰)
- 평균 요청: 500 토큰
- 평균 응답: 1000 토큰

현재 비용 (최적화 전):
일일: 100 * (500 + 500 + 1000) = 200,000 토큰
월간: 200,000 * 30 = 6,000,000 토큰

최적화 후 (Model Tier + Tool 선택 + Prompt 최소화):
- Model Tier (50% 절약)
- Tool Optimization (20% 절약)
- Prompt Lean (15% 절약)
- 총 절약: ~70%

월간 비용: 6,000,000 * 0.30 = 1,800,000 토큰
월간 절약: 4,200,000 토큰 (약 $60-80)
```

---

## 주요 용어

| 용어 | 한글 | 설명 |
|------|------|------|
| **Token** | 토큰 | Claude API에서 비용 계산의 기본 단위 |
| **Context Window** | 컨텍스트 윈도우 | 한 번의 요청에서 처리할 수 있는 최대 토큰 수 |
| **System Prompt** | 시스템 프롬프트 | 모든 요청에 포함되는 기본 지시 |
| **Subagent** | 하위 에이전트 | 특정 작업을 수행하는 전문 에이전트 |
| **Model Tier** | 모델 계층 | Haiku, Sonnet, Opus 등의 모델 수준 |
| **Background Task** | 백그라운드 작업 | 비동기로 실행되는 작업 |
| **Tool Optimization** | 도구 최적화 | 올바른 도구 선택으로 토큰 절약 |

---

## 실전 팁

### 체크리스트: Token Optimization 시작하기

- [ ] **현재 토큰 사용량 측정**: API 대시보드에서 월간 사용량 확인
- [ ] **Model Tier 분석**: 각 에이전트가 어떤 모델을 사용 중인지 확인
- [ ] **System Prompt 크기 검토**: 현재 System Prompt 행 수 계산
- [ ] **Tool 사용 패턴 분석**: 가장 자주 사용하는 도구 파악
- [ ] **Background Task 기회 식별**: 병렬화 가능한 작업 찾기
- [ ] **코드베이스 모듈성 평가**: 파일 크기와 응집도 확인

### 30일 최적화 로드맵

**Week 1: 학습 및 분석**
- 이 가이드 읽기
- 현재 시스템 분석
- 절약 기회 식별

**Week 2: Model Tier 적용**
- 각 작업별 모델 재분류
- Haiku를 사용 가능한 곳에 적용
- 복잡한 작업만 Opus 사용

**Week 3: Tool 최적화**
- Tool 선택 기준 정의
- 대용량 파일 범위 읽기 적용
- Background task 도입

**Week 4: System Prompt 최소화**
- System Prompt 검토 및 단축
- Dynamic prompt injection 도입
- 결과 측정

**예상 절약**: 첫 달 40-50%

---

## 다음 단계

Token Optimization을 완료했다면:

1. **[Agent Best Practices](../06-agent-best-practices/README.md)** - 에이전트 설계 패턴 학습
2. **[Parallelization](../04-parallelization/README.md)** - 병렬 처리 심화
3. **[Context & Memory Management](../01-context-memory/README.md)** - Context 효율성 연계

---

**작성자**: claude-automate 문서팀
**마지막 수정**: 2026년 1월
**상태**: 작성 완료
**원본 출처**: Affaan Mustafa's Claude Code Strategy
