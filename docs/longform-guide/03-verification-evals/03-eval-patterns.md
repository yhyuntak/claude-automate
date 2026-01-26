# Evaluation Patterns: Checkpoint vs Continuous

> 두 가지 주요 평가 패턴을 비교하고, 각 상황에서 어떤 접근법을 선택해야 하는지 배웁니다.

---

## Overview (개요)

**Verification and Evaluation (검증과 평가)**은 자동화 시스템의 신뢰도를 보장하는 핵심입니다.

두 가지 대표적인 평가 패턴이 있습니다:

1. **Checkpoint-Based Evaluation** - 특정 지점에서 검증 수행
2. **Continuous Evaluation** - 프로세스 전반에서 지속적으로 검증

각 패턴은 **서로 다른 워크플로우와 목표**에 최적화되어 있으며, 두 패턴을 **조합하여 사용**할 수도 있습니다.

---

## 1. Checkpoint-Based Evaluation (체크포인트 기반 평가)

### 개념

**Checkpoint-Based Evaluation**은 워크플로우의 **특정 지점**에서만 검증을 수행합니다.

```
시작 → 작업 → [검증 체크포인트] → 작업 → [검증 체크포인트] → 완료
```

### 특징

| 특징 | 설명 |
|------|------|
| **검증 시점** | 명확하고 정의된 단계에서만 발생 |
| **성능** | 불필요한 검증 오버헤드 최소화 |
| **구조** | 선형적이고 예측 가능한 플로우 |
| **복잡도** | 낮음 - 간단한 검증 로직 |
| **피드백 루프** | 체크포인트마다 한 번씩 |

### 평가 다이어그램

```
┌────────────────────────────────────────────────────────────┐
│ CHECKPOINT-BASED EVALUATION WORKFLOW                       │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐       │
│  │Start │      │Work  │      │Work  │      │Complete      │
│  └──▲───┘      └──┬───┘      └──┬───┘      └───┬──┘       │
│     │             │             │             │            │
│     │             ▼             ▼             ▼            │
│     │          ┌─────────────────────────────────┐         │
│     │          │  CHECKPOINT #1: VALIDATION    │         │
│     │          │  - Input verification         │         │
│     │          │  - Schema validation          │         │
│     │          │  - Early exit if needed       │         │
│     │          └────────┬────────────────────┘         │
│     │                   │                               │
│     │                   ▼                               │
│     │          ┌─────────────────────────────────┐      │
│     │          │  CHECKPOINT #2: PROGRESS       │      │
│     │          │  - Intermediate output check   │      │
│     │          │  - State verification          │      │
│     │          │  - Metrics measurement         │      │
│     │          └────────┬────────────────────┘      │
│     │                   │                               │
│     │                   ▼                               │
│     │          ┌─────────────────────────────────┐      │
│     │          │  CHECKPOINT #3: FINALIZATION   │      │
│     │          │  - Final output validation     │      │
│     │          │  - Result verification         │      │
│     │          │  - Success/Failure decision    │      │
│     │          └────────┬────────────────────┘      │
│     │                   │                               │
│     └───────────────────┘                               │
│                                                         │
│  Legend:                                                │
│  ✓ = Pass → Continue to next phase                     │
│  ✗ = Fail → Retry or Escalate                          │
│                                                         │
└────────────────────────────────────────────────────────────┘
```

### 체크포인트 유형 (Types of Checkpoints)

#### 1. Input Checkpoint
```
검증 내용:
- 입력 스키마 확인
- 필수 필드 검증
- 데이터 타입 확인
- 값의 범위 확인
```

#### 2. Progress Checkpoint
```
검증 내용:
- 중간 결과물 확인
- 상태 검증
- 진행률 측정
- 성능 메트릭
```

#### 3. Finalization Checkpoint
```
검증 내용:
- 최종 출력 검증
- 예상 결과와 비교
- 부작용 확인
- 완료 조건 검증
```

### 코드 예제

#### 기본 체크포인트 구조

```python
def checkpoint_based_workflow():
    """
    Linear workflow with checkpoint-based verification
    선형 워크플로우 - 체크포인트 기반 검증
    """

    # ============= CHECKPOINT #1: INPUT VALIDATION =============
    def validate_input(data):
        """
        Validate input data at the beginning
        """
        assert 'name' in data, "Missing 'name' field"
        assert len(data['name']) > 0, "Name cannot be empty"
        assert isinstance(data['age'], int), "Age must be integer"
        assert data['age'] >= 0, "Age cannot be negative"
        return True

    # ============= WORK PHASE #1 =============
    def process_data(raw_data):
        """
        First processing step
        """
        # CHECKPOINT #1: Validate input
        if not validate_input(raw_data):
            raise ValueError("Input validation failed")

        # Process
        processed = {
            'name': raw_data['name'].upper(),
            'age': raw_data['age'],
            'processed_at': datetime.now()
        }

        return processed

    # ============= CHECKPOINT #2: PROGRESS CHECKPOINT =============
    def verify_progress(intermediate_result):
        """
        Verify intermediate state
        """
        assert 'name' in intermediate_result
        assert 'processed_at' in intermediate_result
        assert intermediate_result['age'] >= 0
        return True

    # ============= WORK PHASE #2 =============
    def enrich_data(processed_data):
        """
        Second processing step
        """
        # CHECKPOINT #2: Progress verification
        if not verify_progress(processed_data):
            raise ValueError("Progress checkpoint failed")

        # Enrich with additional data
        enriched = {
            **processed_data,
            'id': hash(processed_data['name']),
            'status': 'enriched'
        }

        return enriched

    # ============= CHECKPOINT #3: FINALIZATION =============
    def validate_final_output(result):
        """
        Final validation before returning
        """
        required_fields = ['name', 'age', 'id', 'status', 'processed_at']
        for field in required_fields:
            assert field in result, f"Missing final field: {field}"

        # Verify business rules
        assert result['status'] == 'enriched', "Invalid final status"
        assert isinstance(result['id'], int), "ID must be integer"

        return True

    # ============= EXECUTION FLOW =============
    raw_input = {
        'name': 'john doe',
        'age': 30
    }

    # Phase 1: Process
    result = process_data(raw_input)

    # Phase 2: Enrich
    result = enrich_data(result)

    # Final checkpoint
    if not validate_final_output(result):
        raise ValueError("Final validation failed")

    return result


# Usage / 사용 예제
try:
    result = checkpoint_based_workflow()
    print("✓ Workflow completed successfully")
    print(f"Result: {result}")
except AssertionError as e:
    print(f"✗ Checkpoint failed: {e}")
except Exception as e:
    print(f"✗ Unexpected error: {e}")
```

#### Checkpoint 클래스 래퍼

```python
from typing import Callable, Any, List
from dataclasses import dataclass
from datetime import datetime

@dataclass
class CheckpointResult:
    """Checkpoint evaluation result"""
    name: str
    passed: bool
    timestamp: datetime
    details: str
    duration_ms: float


class CheckpointValidator:
    """
    Manages checkpoint-based validation
    체크포인트 기반 검증 관리자
    """

    def __init__(self):
        self.checkpoints: List[CheckpointResult] = []
        self.failed = False

    def checkpoint(self, name: str, validator_fn: Callable[[Any], bool], data: Any) -> bool:
        """
        Execute a single checkpoint

        Args:
            name: Checkpoint name
            validator_fn: Function that returns True/False
            data: Data to validate

        Returns:
            True if passed, False if failed
        """
        start = datetime.now()

        try:
            passed = validator_fn(data)
            duration = (datetime.now() - start).total_seconds() * 1000

            result = CheckpointResult(
                name=name,
                passed=passed,
                timestamp=datetime.now(),
                details=f"{'PASS' if passed else 'FAIL'}",
                duration_ms=duration
            )

            self.checkpoints.append(result)

            if not passed:
                self.failed = True
                print(f"✗ CHECKPOINT FAILED: {name}")
                return False

            print(f"✓ CHECKPOINT PASSED: {name} ({duration:.2f}ms)")
            return True

        except Exception as e:
            duration = (datetime.now() - start).total_seconds() * 1000
            result = CheckpointResult(
                name=name,
                passed=False,
                timestamp=datetime.now(),
                details=f"ERROR: {str(e)}",
                duration_ms=duration
            )
            self.checkpoints.append(result)
            self.failed = True
            print(f"✗ CHECKPOINT ERROR: {name}: {e}")
            return False

    def get_report(self) -> dict:
        """Generate checkpoint report"""
        total = len(self.checkpoints)
        passed = sum(1 for cp in self.checkpoints if cp.passed)

        return {
            'total_checkpoints': total,
            'passed': passed,
            'failed': total - passed,
            'success_rate': (passed / total * 100) if total > 0 else 0,
            'total_duration_ms': sum(cp.duration_ms for cp in self.checkpoints),
            'checkpoints': [
                {
                    'name': cp.name,
                    'status': 'PASS' if cp.passed else 'FAIL',
                    'timestamp': cp.timestamp.isoformat(),
                    'duration_ms': cp.duration_ms
                }
                for cp in self.checkpoints
            ]
        }


# Usage / 사용 예제
validator = CheckpointValidator()

# Input validation
validator.checkpoint(
    "Input Schema Validation",
    lambda data: 'name' in data and 'age' in data,
    {'name': 'Alice', 'age': 25}
)

# Progress check
validator.checkpoint(
    "Processing Progress",
    lambda data: len(data['name']) > 0 and data['age'] >= 0,
    {'name': 'ALICE', 'age': 25}
)

# Final output
validator.checkpoint(
    "Final Output Validation",
    lambda data: all(k in data for k in ['name', 'age', 'id', 'status']),
    {'name': 'ALICE', 'age': 25, 'id': 12345, 'status': 'complete'}
)

# Report
print("\n" + "="*50)
print("CHECKPOINT REPORT")
print("="*50)
print(validator.get_report())
```

### 사용 시나리오 (When to Use)

Checkpoint-based evaluation은 다음과 같은 상황에서 최적입니다:

#### 1. Linear Workflows (선형 워크플로우)
```
예제: ETL (Extract, Transform, Load) 파이프라인

Extract → [CHECKPOINT] → Transform → [CHECKPOINT] → Load → [CHECKPOINT]
```

각 단계가 명확하고, 이전 단계가 완료되어야 다음 단계 시작 가능

#### 2. Simple Validations (단순 검증)
```
예제: 입력 폼 검증

1. 필수 필드 체크
2. 데이터 타입 체크
3. 값의 범위 체크
```

복잡한 상호작용 없이 단순한 검증 규칙들

#### 3. Performance-Critical Systems (성능이 중요한 시스템)
```
예제: 실시간 스트림 처리

- 불필요한 검증 제거
- 병목 지점에서만 검증
- 처리량 최적화
```

#### 4. Predetermined Workflows (사전 정의된 워크플로우)
```
예제: 자동 배포 파이프라인

1. Build → [검증]
2. Test → [검증]
3. Deploy → [검증]
```

워크플로우 구조가 이미 결정된 경우

---

## 2. Continuous Evaluation (지속적 평가)

### 개념

**Continuous Evaluation**은 프로세스 **전체에 걸쳐** 지속적으로 상태를 모니터링하고 검증합니다.

```
[모니터링] → 시작 → [검증] → 작업 → [검증] → [검증] → [검증] → 완료
```

### 특징

| 특징 | 설명 |
|------|------|
| **검증 시점** | 지속적, 선택적, 이벤트 기반 |
| **성능** | 약간의 오버헤드가 있지만 더 안전함 |
| **구조** | 비선형적, 유연한 플로우 |
| **복잡도** | 높음 - 복잡한 상태 관리 필요 |
| **피드백 루프** | 빠르고 빈번한 피드백 |

### 평가 다이어그램

```
┌────────────────────────────────────────────────────────────┐
│ CONTINUOUS EVALUATION WORKFLOW                             │
├────────────────────────────────────────────────────────────┤
│                                                             │
│        ╔════════════════════════════════════════════╗      │
│        ║  CONTINUOUS MONITORING LOOP                ║      │
│        ║  (모니터링 루프 - 항상 실행 중)           ║      │
│        ╚════════════════════════════════════════════╝      │
│                        ▲                                    │
│                        │                                    │
│        ┌───────────────┼───────────────┐                  │
│        │               │               │                  │
│        ▼               ▼               ▼                  │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐           │
│  │Work Unit │    │Work Unit │    │Work Unit │  ...     │
│  │    #1    │    │    #2    │    │    #3    │           │
│  └──┬───────┘    └──┬───────┘    └──┬───────┘           │
│     │               │               │                    │
│     ▼               ▼               ▼                    │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐           │
│  │ EVAL #1  │    │ EVAL #2  │    │ EVAL #3  │  ...     │
│  │- State?  │    │- State?  │    │- State?  │           │
│  │- Valid?  │    │- Valid?  │    │- Valid?  │           │
│  │- Drift?  │    │- Drift?  │    │- Drift?  │           │
│  └──┬───────┘    └──┬───────┘    └──┬───────┘           │
│     │               │               │                    │
│     └───────────────┼───────────────┘                    │
│                     │                                     │
│                     ▼                                     │
│         ┌─────────────────────────┐                      │
│         │  EVALUATION AGGREGATOR  │                      │
│         │  - Collect results      │                      │
│         │  - Detect anomalies     │                      │
│         │  - Calculate metrics    │                      │
│         │  - Update state         │                      │
│         └────────┬────────────────┘                      │
│                  │                                        │
│        ┌─────────┴──────────┐                            │
│        │                    │                            │
│        ▼                    ▼                            │
│   [OK - Continue]    [FAIL - Restart/Escalate]         │
│                                                          │
│  Legend:                                                 │
│  📊 = Metric collection                                 │
│  ⚠️ = Anomaly detection                                │
│  🔄 = Feedback loop                                     │
│                                                          │
└────────────────────────────────────────────────────────────┘
```

### 연속 평가 유형 (Types of Continuous Eval)

#### 1. State Monitoring
```
지속적으로 확인:
- 현재 상태가 예상 범위 내인가?
- 상태 변화가 정상인가?
- 부작용은 없는가?
```

#### 2. Drift Detection
```
감지하는 항목:
- 결과의 특성이 변하고 있는가?
- 성능이 저하되고 있는가?
- 데이터 분포가 변하고 있는가?
```

#### 3. Anomaly Detection
```
탐지하는 패턴:
- 비정상적인 입력
- 비정상적인 출력
- 비정상적인 처리 시간
```

### 코드 예제

#### 기본 연속 평가 구조

```python
import time
from typing import Any, Callable, List
from dataclasses import dataclass
from datetime import datetime
from enum import Enum
from collections import deque


class EvalStatus(Enum):
    """Evaluation status"""
    PASS = "pass"
    WARN = "warn"
    FAIL = "fail"


@dataclass
class EvalEvent:
    """A single evaluation event"""
    timestamp: datetime
    status: EvalStatus
    metric_name: str
    value: float
    threshold: float
    message: str


class ContinuousEvaluator:
    """
    Continuous evaluation system for long-running processes
    장기 실행 프로세스용 연속 평가 시스템
    """

    def __init__(self, window_size: int = 100):
        """
        Initialize continuous evaluator

        Args:
            window_size: Number of recent events to keep in memory
        """
        self.events: deque = deque(maxlen=window_size)
        self.metrics: dict = {}
        self.state: dict = {}
        self.evaluators: dict = {}
        self.enabled = True

    def register_evaluator(self, name: str, fn: Callable[[Any], tuple[EvalStatus, float, str]]):
        """
        Register an evaluation function

        Args:
            name: Evaluator name
            fn: Function that returns (status, value, message)
        """
        self.evaluators[name] = fn

    def evaluate(self, data: Any) -> EvalEvent:
        """
        Run evaluation on provided data
        주어진 데이터에 대해 평가 실행

        Returns:
            EvalEvent with results
        """
        if not self.enabled:
            return None

        results = []

        # Run all registered evaluators
        for name, evaluator_fn in self.evaluators.items():
            try:
                status, value, message = evaluator_fn(data)

                event = EvalEvent(
                    timestamp=datetime.now(),
                    status=status,
                    metric_name=name,
                    value=value,
                    threshold=100.0,  # Example threshold
                    message=message
                )

                self.events.append(event)
                results.append(event)

                # Update metric tracking
                if name not in self.metrics:
                    self.metrics[name] = {
                        'count': 0,
                        'sum': 0,
                        'min': float('inf'),
                        'max': float('-inf'),
                        'last_status': EvalStatus.PASS
                    }

                self.metrics[name]['count'] += 1
                self.metrics[name]['sum'] += value
                self.metrics[name]['min'] = min(self.metrics[name]['min'], value)
                self.metrics[name]['max'] = max(self.metrics[name]['max'], value)
                self.metrics[name]['last_status'] = status

                # Print result
                symbol = "✓" if status == EvalStatus.PASS else "⚠" if status == EvalStatus.WARN else "✗"
                print(f"{symbol} [{name}] {message} (value: {value:.2f})")

            except Exception as e:
                print(f"✗ [EVAL ERROR] {name}: {e}")

        return results

    def get_summary(self) -> dict:
        """
        Get summary of all evaluations
        전체 평가의 요약 반환

        Returns:
            Summary dict with statistics
        """
        total_events = len(self.events)

        status_counts = {
            'pass': sum(1 for e in self.events if e.status == EvalStatus.PASS),
            'warn': sum(1 for e in self.events if e.status == EvalStatus.WARN),
            'fail': sum(1 for e in self.events if e.status == EvalStatus.FAIL),
        }

        return {
            'total_events': total_events,
            'status_counts': status_counts,
            'success_rate': (status_counts['pass'] / total_events * 100) if total_events > 0 else 0,
            'metrics': {
                name: {
                    'count': m['count'],
                    'avg': m['sum'] / m['count'] if m['count'] > 0 else 0,
                    'min': m['min'] if m['min'] != float('inf') else 0,
                    'max': m['max'] if m['max'] != float('-inf') else 0,
                    'last_status': m['last_status'].value
                }
                for name, m in self.metrics.items()
            }
        }

    def detect_anomalies(self, metric_name: str, threshold: float = 2.0) -> List[EvalEvent]:
        """
        Detect anomalies in a metric using standard deviation
        표준 편차를 사용하여 이상치 탐지
        """
        if metric_name not in self.metrics:
            return []

        # Get values for this metric
        values = [e.value for e in self.events if e.metric_name == metric_name]

        if len(values) < 3:
            return []

        # Calculate mean and std
        mean = sum(values) / len(values)
        variance = sum((x - mean) ** 2 for x in values) / len(values)
        std = variance ** 0.5

        # Find anomalies
        anomalies = []
        for event in self.events:
            if event.metric_name == metric_name:
                z_score = abs((event.value - mean) / std) if std > 0 else 0
                if z_score > threshold:
                    anomalies.append(event)

        return anomalies


# Usage / 사용 예제
def example_continuous_evaluation():
    """
    Example of continuous evaluation in a processing loop
    처리 루프에서 연속 평가 예제
    """

    evaluator = ContinuousEvaluator(window_size=50)

    # Register evaluators
    # 평가 함수 등록

    def eval_input_quality(data):
        """Evaluate input quality"""
        quality_score = 100 if 'required_field' in data else 50
        status = EvalStatus.PASS if quality_score > 80 else EvalStatus.WARN
        message = f"Input quality: {quality_score}%"
        return status, quality_score, message

    def eval_processing_time(data):
        """Evaluate processing time"""
        proc_time = data.get('processing_ms', 0)
        ideal_time = 100  # ms
        efficiency = (ideal_time / proc_time * 100) if proc_time > 0 else 0
        status = EvalStatus.PASS if efficiency > 80 else EvalStatus.WARN
        message = f"Efficiency: {efficiency:.1f}%"
        return status, efficiency, message

    def eval_output_validity(data):
        """Evaluate output validity"""
        has_required_fields = all(k in data for k in ['result', 'status'])
        validity_score = 100 if has_required_fields else 0
        status = EvalStatus.PASS if validity_score == 100 else EvalStatus.FAIL
        message = f"Output valid: {has_required_fields}"
        return status, validity_score, message

    evaluator.register_evaluator("input_quality", eval_input_quality)
    evaluator.register_evaluator("processing_time", eval_processing_time)
    evaluator.register_evaluator("output_validity", eval_output_validity)

    # Simulate processing loop
    print("\n" + "="*60)
    print("CONTINUOUS EVALUATION - PROCESSING LOOP")
    print("="*60)

    for i in range(1, 6):
        print(f"\n[Iteration {i}]")

        # Simulate work
        data = {
            'required_field': 'value',
            'processing_ms': 80 + (i * 5),  # Increasing processing time
            'result': f'output_{i}',
            'status': 'ok'
        }

        # Continuous evaluation
        evaluator.evaluate(data)

        time.sleep(0.1)  # Simulate work

    # Get summary
    print("\n" + "="*60)
    print("EVALUATION SUMMARY")
    print("="*60)
    summary = evaluator.get_summary()
    print(f"Total Events: {summary['total_events']}")
    print(f"Status: PASS {summary['status_counts']['pass']}, "
          f"WARN {summary['status_counts']['warn']}, "
          f"FAIL {summary['status_counts']['fail']}")
    print(f"Success Rate: {summary['success_rate']:.1f}%")

    # Detect anomalies
    print("\n" + "="*60)
    print("ANOMALY DETECTION")
    print("="*60)
    anomalies = evaluator.detect_anomalies("processing_time", threshold=1.5)
    if anomalies:
        print(f"Found {len(anomalies)} anomalies in 'processing_time':")
        for anom in anomalies:
            print(f"  - {anom.timestamp}: {anom.value:.2f} ({anom.message})")
    else:
        print("No anomalies detected")


if __name__ == "__main__":
    example_continuous_evaluation()
```

#### Drift Detection with History

```python
from collections import defaultdict
from statistics import mean, stdev


class DriftDetector:
    """
    Detect performance drift in continuous evaluation
    연속 평가에서 성능 저하 감지
    """

    def __init__(self, baseline_window: int = 20, alert_threshold: float = 0.15):
        """
        Initialize drift detector

        Args:
            baseline_window: Number of samples to establish baseline
            alert_threshold: Percentage change to trigger alert (0.15 = 15%)
        """
        self.baseline_window = baseline_window
        self.alert_threshold = alert_threshold
        self.history: defaultdict(list) = defaultdict(list)
        self.baseline: dict = {}
        self.drifts: list = []

    def add_measurement(self, metric_name: str, value: float):
        """
        Add a new measurement
        새로운 측정값 추가
        """
        self.history[metric_name].append(value)

        # Establish baseline if we have enough samples
        if len(self.history[metric_name]) == self.baseline_window:
            baseline_values = self.history[metric_name][:self.baseline_window]
            self.baseline[metric_name] = {
                'mean': mean(baseline_values),
                'std': stdev(baseline_values) if len(baseline_values) > 1 else 0,
                'established_at': len(self.history[metric_name])
            }

        # Check for drift if baseline is established
        if metric_name in self.baseline:
            self._check_drift(metric_name, value)

    def _check_drift(self, metric_name: str, value: float):
        """
        Check if current value indicates drift from baseline
        현재 값이 기준선에서 벗어났는지 확인
        """
        baseline = self.baseline[metric_name]
        baseline_mean = baseline['mean']

        # Calculate percentage change
        pct_change = abs(value - baseline_mean) / baseline_mean if baseline_mean != 0 else 0

        if pct_change > self.alert_threshold:
            drift_event = {
                'metric': metric_name,
                'current_value': value,
                'baseline_mean': baseline_mean,
                'pct_change': pct_change,
                'severity': 'HIGH' if pct_change > self.alert_threshold * 2 else 'MEDIUM'
            }
            self.drifts.append(drift_event)
            print(f"⚠️  DRIFT DETECTED: {metric_name} "
                  f"({value:.2f} vs baseline {baseline_mean:.2f}, "
                  f"change: {pct_change*100:.1f}%)")

    def get_drift_report(self) -> dict:
        """Get comprehensive drift report"""
        return {
            'total_drifts_detected': len(self.drifts),
            'metrics_with_drifts': len(set(d['metric'] for d in self.drifts)),
            'recent_drifts': self.drifts[-5:] if self.drifts else [],
            'baseline_status': {
                name: {
                    'mean': b['mean'],
                    'std': b['std'],
                    'samples': len(self.history[name])
                }
                for name, b in self.baseline.items()
            }
        }


# Usage / 사용 예제
detector = DriftDetector(baseline_window=10, alert_threshold=0.20)

# Simulate measurements over time
print("Drift Detection Example")
print("="*50)

for i in range(1, 26):
    # Stable phase (1-10)
    # Drift phase (11-20)
    # Recovery phase (21-25)

    if i <= 10:
        # Baseline: around 100
        value = 95 + (i % 3)
    elif i <= 20:
        # Drifted: around 120 (20% increase)
        value = 120 + (i % 3)
    else:
        # Back to baseline
        value = 98 + (i % 3)

    detector.add_measurement("response_time_ms", value)
    print(f"Sample {i:2d}: {value:6.1f}ms", end="")

    if i in [10, 20]:
        print(" [PHASE CHANGE]")
    else:
        print()

print("\n" + "="*50)
print("DRIFT REPORT")
print("="*50)
report = detector.get_drift_report()
print(f"Total Drifts: {report['total_drifts_detected']}")
print(f"Metrics Affected: {report['metrics_with_drifts']}")
```

### 사용 시나리오 (When to Use)

Continuous evaluation은 다음과 같은 상황에서 최적입니다:

#### 1. Exploratory Refactoring (탐색적 리팩토링)
```
상황: 대규모 코드 리팩토링 중

- 변경사항이 시스템에 미치는 영향을 지속 모니터링
- 성능 저하, 메모리 누수 등을 실시간 감지
- 문제 발생 시 즉시 대응
```

#### 2. Long-Running Sessions (긴 세션)
```
상황: 며칠에 걸친 개발 작업

- 매 작업마다 작은 검증 수행
- 누적된 문제 조기 발견
- 진행 상황 지속 모니터링
```

#### 3. Production Monitoring (프로덕션 모니터링)
```
상황: 실시간 서비스 운영

- 성능 메트릭 지속 수집
- 이상 징후 조기 감지
- SLA 위반 예방
```

#### 4. Adaptive Systems (적응형 시스템)
```
상황: 환경에 따라 동작이 변하는 시스템

- 시스템 상태 지속 모니터링
- 성능 저하(drift) 감지
- 자동 조정 트리거
```

---

## 3. 패턴 비교 (Pattern Comparison)

### 다이어그램: 두 패턴의 차이

```
┌────────────────────────────────────────────────────────────┐
│  COMPARISON: Checkpoint vs Continuous                      │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  ASPECT              CHECKPOINT        CONTINUOUS           │
│  ─────────────────────────────────────────────────────────  │
│                                                             │
│  Timing              ┌─────┐           ┌─┐ ┌─┐ ┌─┐ ┌─┐   │
│                      │CHECK│           │ ││ ││ ││ ││        │
│                      └─────┘           └─┘ └─┘ └─┘ └─┘     │
│                                                             │
│  Frequency           Low (Discrete)    High (Continuous)   │
│                                                             │
│  Coverage            ╔═══════╗         ░░░░░░░░░░░░░░     │
│                      ║       ║         Coverage everywhere  │
│                      ╚═══════╝         ░░░░░░░░░░░░░░     │
│                                                             │
│  Feedback            After each phase  During processing    │
│  Loop                                                       │
│                                                             │
│  Overhead            Low                Medium to High      │
│                                                             │
│  Complexity          Simple             Complex             │
│                                                             │
│  Best For            Linear workflows  Exploratory work,    │
│                      Simple rules      Long sessions        │
│                      Performance       Production systems   │
│                      critical                               │
│                                                             │
│  Example             ETL Pipeline      Multi-agent dev      │
│  Workflow            Form validation   Refactoring          │
│                      CI/CD pipeline    Monitoring           │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

### 선택 기준 (Decision Matrix)

```
┌──────────────────────────────────────────────────────────┐
│  CHOOSE CHECKPOINT-BASED IF...                           │
├──────────────────────────────────────────────────────────┤
│  ☑ Workflow is linear and well-defined                  │
│  ☑ Validation rules are simple                          │
│  ☑ Performance is critical                              │
│  ☑ Each phase has clear input/output                    │
│  ☑ Failure requires immediate halt                      │
│  ☑ Result: 5-10 clear checkpoints                       │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│  CHOOSE CONTINUOUS EVALUATION IF...                      │
├──────────────────────────────────────────────────────────┤
│  ☑ Workflow is exploratory/adaptive                      │
│  ☑ State can degrade gradually                          │
│  ☑ You need anomaly/drift detection                     │
│  ☑ Work spans long sessions                             │
│  ☑ Failure is gradual (not binary)                      │
│  ☑ Production monitoring needed                         │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│  HYBRID APPROACH (RECOMMENDED)                           │
├──────────────────────────────────────────────────────────┤
│  Use BOTH:                                                │
│  • Checkpoints for major phase transitions              │
│  • Continuous eval within each phase                    │
│  • Drift detection across phases                        │
│                                                          │
│  Example:                                                │
│  └─ Phase 1 [CHECKPOINT: Input valid?]                 │
│     └─ Monitor: processing efficiency                   │
│     └─ Detect: drift in outputs                        │
│  └─ Phase 2 [CHECKPOINT: Output complete?]             │
│     └─ Monitor: data quality                           │
│     └─ Detect: anomalies                               │
└──────────────────────────────────────────────────────────┘
```

---

## 4. 저자의 검증 접근법 (Author's Verification Approach)

### 철학 (Philosophy)

**"검증은 일회성이 아니라 지속적인 활동이다."**

좋은 검증 체계는:

1. **조기 실패** - 문제를 빨리 발견할수록 비용이 적게 든다
2. **지속적 모니터링** - 한 번의 검증으로는 부족하다
3. **적응형** - 시스템이 변할수록 검증도 진화해야 한다
4. **자동화** - 수동 검증은 신뢰할 수 없다

### 실제 적용 패턴 (Practical Patterns)

#### 패턴 1: T자형 검증 (T-Shaped Verification)

```
        CONTINUOUS MONITORING
              ▲
              │
              │ (Throughout entire session)
              │
        ┌─────┼─────┐
        │     │     │
    [CP#1]──[CP#2]──[CP#3]
    INPUT  PROGRESS FINAL

    T-Shape:
    - Vertical bar = Continuous eval from start to end
    - Horizontal bar = Checkpoints at critical points
```

**구현 방식:**

```python
class TShaped Validator:
    """T-Shaped Verification Pattern"""

    def __init__(self):
        self.continuous_evals = ContinuousEvaluator()
        self.checkpoints = CheckpointValidator()

    def workflow(self, data):
        """Execute T-shaped verification"""

        # Start continuous monitoring (vertical bar)
        self.continuous_evals.enable()

        try:
            # CHECKPOINT #1: Input validation
            if not self.checkpoints.checkpoint("Input", validate_input, data):
                return False

            # Work phase 1 with continuous monitoring
            result1 = self._phase1_with_monitoring(data)

            # CHECKPOINT #2: Progress
            if not self.checkpoints.checkpoint("Progress", validate_progress, result1):
                return False

            # Work phase 2 with continuous monitoring
            result2 = self._phase2_with_monitoring(result1)

            # CHECKPOINT #3: Final
            if not self.checkpoints.checkpoint("Final", validate_final, result2):
                return False

            return result2

        finally:
            # Stop continuous monitoring and report
            self.continuous_evals.disable()
            self._report_both()

    def _phase1_with_monitoring(self, data):
        """Phase 1 with continuous eval"""
        while processing:
            self.continuous_evals.evaluate(current_state)
            result = do_work()
        return result

    def _report_both(self):
        """Report both checkpoint and continuous results"""
        print("\n=== VERIFICATION REPORT ===")
        print(self.checkpoints.get_report())
        print(self.continuous_evals.get_summary())
```

#### 패턴 2: 계층형 검증 (Hierarchical Verification)

```
Level 1: GATES (Binary pass/fail)
├─ Input valid?
├─ Dependencies available?
└─ Resources sufficient?

Level 2: METRICS (Quantitative)
├─ Performance within bounds?
├─ Quality above threshold?
└─ Coverage adequate?

Level 3: ANALYSIS (Qualitative)
├─ Design sound?
├─ Patterns consistent?
└─ Documentation current?
```

**구현:**

```python
class HierarchicalValidator:
    """Hierarchical Verification with 3 levels"""

    def validate_gates(self, data):
        """Level 1: Binary gates"""
        checks = [
            ('input_valid', lambda d: validate_schema(d)),
            ('dependencies_ok', lambda d: check_dependencies()),
            ('resources_ok', lambda d: check_resources())
        ]

        for name, check in checks:
            if not check(data):
                raise ValidationError(f"GATE FAILED: {name}")

        return True

    def validate_metrics(self, data, results):
        """Level 2: Quantitative metrics"""
        metrics = {
            'performance': self._measure_performance(results),
            'quality': self._measure_quality(results),
            'coverage': self._measure_coverage(results)
        }

        # All metrics must be above threshold
        for name, value in metrics.items():
            if value < THRESHOLD[name]:
                print(f"WARNING: {name} below threshold ({value} < {THRESHOLD[name]})")

        return metrics

    def validate_analysis(self, code, design):
        """Level 3: Qualitative analysis"""
        issues = []

        # Check design soundness
        if not self._check_design(design):
            issues.append("Design issues found")

        # Check pattern consistency
        if not self._check_patterns(code):
            issues.append("Pattern inconsistencies found")

        # Check documentation
        if not self._check_docs(code):
            issues.append("Documentation gaps found")

        return issues
```

#### 패턴 3: 시간기반 검증 (Time-Based Verification)

```
Timeline of a long session:

00:00 ├─ Initial validation (gates)
      │
05:00 ├─ Quick health check
      │  (Light metrics)
      │
10:00 ├─ Progress checkpoint
      │  (Intermediate validation)
      │
15:00 ├─ Drift detection
      │  (Has quality degraded?)
      │
20:00 ├─ Final checkpoint
      │  (Full validation)
      │
      └─ Session report
```

**구현:**

```python
class TimeBasedValidator:
    """Schedule validations based on elapsed time"""

    def __init__(self):
        self.start_time = None
        self.validation_schedule = {
            0: ('initial', self.full_validation),
            5: ('health', self.health_check),
            10: ('progress', self.progress_checkpoint),
            15: ('drift', self.drift_detection),
            20: ('final', self.final_checkpoint)
        }

    def process_with_scheduled_validation(self, data_stream):
        """Process data with scheduled validations"""
        self.start_time = time.time()

        for data in data_stream:
            elapsed_minutes = (time.time() - self.start_time) / 60

            # Check if validation is due
            for schedule_time in sorted(self.validation_schedule.keys()):
                if elapsed_minutes >= schedule_time and \
                   not self._validation_done(schedule_time):
                    name, validator = self.validation_schedule[schedule_time]
                    print(f"\n[{elapsed_minutes:.1f}m] Running {name} validation...")
                    validator(self.current_state)
                    self._mark_validation_done(schedule_time)

            # Process data
            self.process_item(data)

    def health_check(self, state):
        """Quick 5-minute health check"""
        # Fast, lightweight checks
        assert state['items_processed'] > 0
        assert state['errors'] < 10
        print("✓ Health check passed")

    def progress_checkpoint(self, state):
        """10-minute progress validation"""
        # Moderate validation
        assert state['progress'] >= 0.25  # 25% done
        assert state['quality'] >= QUALITY_THRESHOLD
        print("✓ Progress checkpoint passed")
```

### 권장 체크리스트 (Recommended Checklist)

새로운 프로젝트를 시작할 때, 다음을 설정하세요:

```
VERIFICATION SETUP CHECKLIST
═══════════════════════════════════════════════════════════

[ ] 1. GATES (Binary Go/No-Go)
    [ ] Input schema validation
    [ ] Dependency checks
    [ ] Resource availability
    [ ] Permission checks

[ ] 2. CHECKPOINTS (Phase transitions)
    [ ] Define 3-5 major checkpoints
    [ ] For each: what to validate?
    [ ] What triggers failure?
    [ ] What's the recovery path?

[ ] 3. CONTINUOUS MONITORING (During execution)
    [ ] 3-5 key metrics to track
    [ ] Normal range for each metric
    [ ] Threshold for warnings
    [ ] Threshold for failures

[ ] 4. ANOMALY DETECTION
    [ ] Statistical baseline (first 20 runs)
    [ ] Drift detection (2σ threshold)
    [ ] Outlier detection (3σ threshold)

[ ] 5. REPORTING
    [ ] Summary report format
    [ ] Failure notification method
    [ ] Metrics export format
    [ ] Trend analysis (daily/weekly)

[ ] 6. AUTOMATION
    [ ] Auto-trigger checkpoints
    [ ] Auto-aggregate metrics
    [ ] Auto-generate reports
    [ ] Auto-escalate critical issues
```

---

## 5. 실전 예제 (Real-World Example)

### 시나리오: 데이터 파이프라인 검증

```
Raw Data → [CHECKPOINT 1] → Transform → [CHECKPOINT 2] →
Load → [CHECKPOINT 3] → Complete
      ↓
   Monitor quality throughout
   Detect drift in output
   Track performance metrics
```

**전체 구현:**

```python
class DataPipelineValidator:
    """Complete validation for data pipeline"""

    def __init__(self):
        self.checkpoints = CheckpointValidator()
        self.continuous = ContinuousEvaluator()
        self.drift_detector = DriftDetector()

    def run_pipeline(self, source_data):
        """Run complete pipeline with validation"""

        print("="*60)
        print("DATA PIPELINE EXECUTION WITH VALIDATION")
        print("="*60)

        try:
            # ======= PHASE 1: EXTRACT =======
            print("\n[PHASE 1] EXTRACT")

            # Checkpoint 1: Validate input
            self.checkpoints.checkpoint(
                "Extract - Input Valid",
                lambda d: d and len(d) > 0,
                source_data
            )

            extracted = self._extract(source_data)

            # Continuous eval during extraction
            self.continuous.evaluate(extracted)

            # ======= PHASE 2: TRANSFORM =======
            print("\n[PHASE 2] TRANSFORM")

            # Checkpoint 2: Validate extraction
            self.checkpoints.checkpoint(
                "Transform - Input Schema",
                lambda d: all(k in d for k in ['id', 'name', 'value']),
                extracted
            )

            transformed = self._transform(extracted)

            # Continuous eval: quality metrics
            quality_score = self._measure_quality(transformed)
            self.continuous.evaluate({'quality': quality_score})

            # Drift detection: Has quality degraded?
            self.drift_detector.add_measurement('quality', quality_score)

            # ======= PHASE 3: LOAD =======
            print("\n[PHASE 3] LOAD")

            # Checkpoint 3: Validate transform
            self.checkpoints.checkpoint(
                "Load - Output Valid",
                lambda d: len(d) == len(extracted),
                transformed
            )

            loaded = self._load(transformed)

            # Final checkpoint
            self.checkpoints.checkpoint(
                "Load - Complete",
                lambda d: d.get('status') == 'success',
                loaded
            )

            print("\n" + "="*60)
            print("EXECUTION SUCCESSFUL")
            print("="*60)

            return loaded

        except Exception as e:
            print(f"\n✗ PIPELINE FAILED: {e}")
            raise
        finally:
            self._print_reports()

    def _extract(self, data):
        """Extract phase"""
        print("  Extracting data...")
        return [{'id': i, 'name': f'item_{i}', 'value': i*10}
                for i in range(len(data))]

    def _transform(self, data):
        """Transform phase"""
        print("  Transforming data...")
        return [
            {**item, 'normalized_value': item['value'] / 100}
            for item in data
        ]

    def _load(self, data):
        """Load phase"""
        print("  Loading data...")
        return {'status': 'success', 'rows_loaded': len(data)}

    def _measure_quality(self, data):
        """Measure data quality"""
        if not data:
            return 0
        complete = sum(1 for item in data
                      if all(k in item for k in ['id', 'value', 'normalized_value']))
        return (complete / len(data)) * 100

    def _print_reports(self):
        """Print all reports"""
        print("\n" + "="*60)
        print("CHECKPOINT REPORT")
        print("="*60)
        report = self.checkpoints.get_report()
        print(f"Checkpoints: {report['passed']}/{report['total_checkpoints']} passed")

        print("\n" + "="*60)
        print("CONTINUOUS EVAL SUMMARY")
        print("="*60)
        summary = self.continuous.get_summary()
        print(f"Events: {summary['total_events']}")
        print(f"Success Rate: {summary['success_rate']:.1f}%")

        print("\n" + "="*60)
        print("DRIFT DETECTION REPORT")
        print("="*60)
        drift_report = self.drift_detector.get_drift_report()
        print(f"Drifts Detected: {drift_report['total_drifts_detected']}")


# Run the example
if __name__ == "__main__":
    validator = DataPipelineValidator()

    test_data = [
        {'raw': 'data1'},
        {'raw': 'data2'},
        {'raw': 'data3'},
        {'raw': 'data4'},
        {'raw': 'data5'}
    ]

    try:
        result = validator.run_pipeline(test_data)
        print(f"\nFinal Result: {result}")
    except Exception as e:
        print(f"\nFailed with error: {e}")
```

---

## 6. 핵심 요점 정리 (Key Takeaways)

### 선택 가이드 (Quick Decision Guide)

```
Q1: 워크플로우가 선형인가?
    YES → Checkpoint-based 검토
    NO  → Continuous evaluation 검토

Q2: 검증 규칙이 단순한가?
    YES → Checkpoint-based 가능
    NO  → Continuous evaluation 필요

Q3: 성능이 매우 중요한가?
    YES → Checkpoint-based (오버헤드 최소)
    NO  → Hybrid approach (둘 다 사용)

Q4: 장시간 실행되는 작업인가?
    YES → Continuous evaluation (모니터링)
    NO  → Checkpoint-based (명확한 단계)

Q5: 프로덕션 시스템인가?
    YES → Hybrid (안전성 최우선)
    NO  → 워크플로우에 따라 선택
```

### 권장 하이브리드 접근법

**최고의 검증 시스템은 두 패턴을 모두 활용합니다:**

1. **큰 단계에서는 Checkpoint** - 명확하고 강제적
2. **단계 내에서는 Continuous** - 섬세하고 빠른 피드백
3. **장기 추적은 Drift Detection** - 누적된 문제 감지

```
Architecture:
┌─────────────────────────────────────────────┐
│         HYBRID VERIFICATION SYSTEM           │
├─────────────────────────────────────────────┤
│                                             │
│  Checkpoints [At phase transitions]         │
│  ├─ Input validation                       │
│  ├─ State validation                       │
│  └─ Output validation                      │
│                                             │
│  Continuous Eval [During phases]            │
│  ├─ Metric collection                      │
│  ├─ Anomaly detection                      │
│  └─ Quality monitoring                     │
│                                             │
│  Drift Detection [Across sessions]          │
│  ├─ Baseline establishment                 │
│  ├─ Degradation detection                  │
│  └─ Trend analysis                         │
│                                             │
└─────────────────────────────────────────────┘
```

---

## 정리 (Summary)

| 항목 | Checkpoint-Based | Continuous |
|------|------------------|-----------|
| **최적 사용처** | 선형 워크플로우 | 탐색적 작업 |
| **검증 빈도** | 적음 (정의된 지점) | 높음 (지속적) |
| **성능 영향** | 최소 | 중간 정도 |
| **구현 복잡도** | 낮음 | 높음 |
| **이상 감지** | 이진 (통과/실패) | 점진적 (drift) |
| **모니터링** | 사후 (각 단계 후) | 실시간 |
| **추천 환경** | CI/CD, 배포 | 개발, 모니터링 |

**최종 조언**: 시작할 때는 Checkpoint-based로 단순하게 시작하고, 필요에 따라 Continuous evaluation을 추가하세요!

---

## 다음 단계 (Next Steps)

- [04-failure-modes.md](./04-failure-modes.md) - 검증 실패 시 대응 방법
- [05-eval-framework.md](./05-eval-framework.md) - 평가 프레임워크 구축
- [README.md](./README.md) - 검증 및 평가 종합 가이드

---

**작성자**: claude-automate 문서팀
**마지막 수정**: 2026년 1월
**상태**: 완료

---

*이 문서는 Affaan Mustafa의 Claude Code 최적화 관련 작업과 실제 프로덕션 경험을 바탕으로 작성되었습니다.*
