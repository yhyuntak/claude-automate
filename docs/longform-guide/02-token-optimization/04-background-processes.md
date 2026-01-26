# Background Processes (백그라운드 프로세스)

## 개요 | Overview

**Background Processes**는 Claude Code에서 장시간 작업을 비동기로 실행하여 **대기 시간을 제거**하고 **토큰 효율성을 극대화**하는 핵심 기법입니다.

일반적인 개발 작업 중 상당 부분은 결과를 기다려야 합니다:
- npm 패키지 설치
- 코드 빌드
- 테스트 스위트 실행
- Docker 이미지 빌드
- 파일 시스템 작업

이러한 작업들을 **백그라운드에서 실행**하면:

1. **시간 절약**: 전체 실행 시간이 80% 단축될 수 있습니다
2. **병렬 처리**: 기다리는 동안 다른 작업 수행 가능
3. **토큰 효율성**: 동일한 결과를 더 짧은 시간에 달성
4. **응답성 향상**: 사용자는 진행 상황을 계속 모니터링 가능

---

## 핵심 개념 | Core Concepts

### What Are Background Processes?

배경 프로세스는 **메인 작업 흐름과 독립적으로 실행**되는 비동기 작업입니다.

```
--- 순차 실행 (Blocking) ---
Task A (30초) → Task B (10초) → Task C (5초) = 총 45초

--- 백그라운드 실행 (Non-blocking) ---
Task A (백그라운드, 30초)
Task B (1초) → Task C (3초) → ... 다른 작업들
Task A 결과 확인 (30초 후) = 총 ~35초
```

### When to Use Background Processes

**백그라운드 실행이 유용한 경우:**

| 작업 유형 | 실행 시간 | 예시 |
|---------|---------|------|
| Package Installation | 30초 ~ 5분 | `npm install`, `pip install`, `cargo build` |
| Build Processes | 10초 ~ 10분 | `npm run build`, `make`, `tsc` |
| Test Suites | 20초 ~ 30분 | `npm test`, `pytest`, `cargo test` |
| Docker Operations | 1분 ~ 30분 | `docker build`, `docker pull` |
| Git Operations | 5초 ~ 5분 | `git clone`, `git fetch` |
| File System Tasks | 5초 ~ 10분 | 대량 파일 이동, 압축 |

**백그라운드 실행이 부적절한 경우:**

| 작업 유형 | 이유 |
|---------|------|
| Quick status checks | 이미 빠르므로 오버헤드만 증가 |
| File reads | 즉시 결과 필요 |
| 사용자 입력이 필요한 작업 | 인터랙션 불가능 |
| 에러 처리가 즉시 필요한 작업 | 에러 감지 지연 |

---

## Tmux를 사용한 백그라운드 실행 | Background Execution with Tmux

### What is Tmux?

**Tmux (Terminal Multiplexer)**는 터미널 세션을 관리하고 분리된 프로세스를 실행할 수 있게 해주는 도구입니다.

```
┌─────────────────────────────┐
│    Tmux Server (메인)       │
├─────────────────┬───────────┤
│  Session 1      │ Session 2 │
│  (npm build)    │ (tests)   │
├────────┬────────┼───────────┤
│Window 1│Window 2│ Window 1  │
│  Pane1 │ Pane2  │  Pane1    │
└────────┴────────┴───────────┘
```

### Why Tmux for Background Processes?

Tmux의 주요 장점:

1. **Server-Client Architecture**: 프로세스가 독립적으로 실행됨
2. **Session Persistence**: 터미널이 끊겨도 프로세스 계속 실행
3. **Output Capture**: 완전한 출력 로그 캡처 가능
4. **Flexible Monitoring**: 언제든지 세션에 접속 가능

### Basic Tmux Commands

#### 세션 생성 및 관리
```bash
# 새로운 세션 생성 및 명령어 실행
tmux new-session -d -s "session_name" "command"

# 예: npm install을 백그라운드에서 실행
tmux new-session -d -s "npm_install" "npm install"

# 세션 목록 확인
tmux list-sessions

# 세션의 전체 출력 확인
tmux capture-pane -t "session_name" -p

# 마지막 100줄만 확인
tmux capture-pane -t "session_name" -p -S -100

# 세션에 접속 (모니터링)
tmux attach-session -t "session_name"

# 세션에서 나가기
tmux detach  # Ctrl+B, then D

# 세션 종료
tmux kill-session -t "session_name"
```

#### 출력 관리
```bash
# 세션 생성과 동시에 출력을 파일로 리다이렉트
tmux new-session -d -s "build" "npm run build > build.log 2>&1"

# 실시간 모니터링 (tail)
tail -f build.log

# 세션의 최근 출력 확인
tmux capture-pane -t "build" -p -S -50
```

### Shorthand Guide: Practical Examples

#### 예 1: npm install 백그라운드 실행
```bash
# 1. 세션 생성 및 설치 시작
tmux new-session -d -s "install" "cd /project && npm install"

# 2. 다른 작업 수행하는 동안 상태 확인
tmux capture-pane -t "install" -p

# 3. 완료 대기
while tmux list-sessions | grep -q install; do
  echo "Installing..."
  sleep 5
done
echo "Install complete!"
```

#### 예 2: 테스트 스위트 실행
```bash
# 1. 테스트 시작 (출력은 파일로)
tmux new-session -d -s "test" "npm test > test-results.log 2>&1"

# 2. 진행 상황 모니터링
tail -f test-results.log

# 3. 완료 후 결과 확인
tmux capture-pane -t "test" -p | tail -50
tmux kill-session -t "test"
```

#### 예 3: 빌드 프로세스 (출력 요약 vs 전체 스트리밍)
```bash
# 방법 1: 출력 요약 (토큰 효율적)
tmux new-session -d -s "build" "npm run build > build.log 2>&1"
sleep 60  # 빌드 대기
tail -20 build.log  # 마지막 20줄만 확인

# 방법 2: 전체 스트리밍 (디버깅 용이)
tmux new-session -d -s "build" "npm run build"
tmux capture-pane -t "build" -p  # 모든 출력 확인
```

---

## Output Summary vs Full Streaming | 출력 요약 vs 전체 스트리밍

### Strategy 1: Output Summary (권장 - 토큰 효율적)

**언제 사용**: 대부분의 경우, 최종 결과만 필요할 때

```bash
#!/bin/bash
# 백그라운드에서 명령 실행
tmux new-session -d -s "task" "your_long_command > output.log 2>&1"

# 프로세스 완료 대기
while tmux list-sessions | grep -q task; do
  sleep 2
done

# 마지막 N줄만 읽기 (토큰 효율적)
echo "=== Task Output Summary ==="
tail -30 output.log

# 전체 라인 수 확인
wc -l output.log
```

**장점:**
- 불필요한 중간 출력 제거
- 토큰 사용량 최소화
- 빠른 결과 처리

**단점:**
- 디버깅이 필요한 경우 전체 출력을 다시 읽어야 함
- 에러의 맥락 손실 가능

### Strategy 2: Full Streaming (디버깅 필요할 때)

**언제 사용**: 실시간 모니터링이 필요하거나 에러 분석이 필요할 때

```bash
#!/bin/bash
# 백그라운드에서 명령 실행
tmux new-session -d -s "task" "your_long_command"

# 실시간 모니터링
while tmux list-sessions | grep -q task; do
  clear
  echo "=== Real-time Output ==="
  tmux capture-pane -t "task" -p
  sleep 5
done

# 최종 출력 캡처
echo "=== Final Output ==="
tmux capture-pane -t "task" -p
```

**장점:**
- 실시간 진행 상황 파악
- 에러 발생 즉시 감지
- 완전한 컨텍스트 유지

**단점:**
- 토큰 사용량 증가 (반복적인 캡처)
- 불필요한 중간 상태 저장

### 하이브리드 접근: Smart Monitoring

```bash
#!/bin/bash
# 초기 모니터링: 첫 10초는 실시간
tmux new-session -d -s "task" "your_long_command > output.log 2>&1"

for i in {1..10}; do
  echo "Initial monitoring [$i/10]..."
  tail -10 output.log
  sleep 1
done

# 이후: 주기적으로만 체크 (토큰 효율적)
while tmux list-sessions | grep -q task; do
  echo "Still running... ($(date))"
  sleep 30
done

# 최종 요약만 확인
echo "=== Final Summary ==="
tail -30 output.log
```

**최적의 균형:**
- 초기 단계에서 실시간 모니터링
- 이후 주기적 확인으로 전환
- 최종 요약만 저장

---

## Input/Output Token Cost Comparison | 입출력 토큰 비용 비교

### Token 기초 개념

Claude의 가격은 **입력(Input)과 출력(Output) 토큰**으로 계산됩니다.

**Opus 4.5 가격 (2026년 1월 기준):**
```
Input Token:  $5 / 1M 토큰   ($0.000005 / 토큰)
Output Token: $25 / 1M 토큰  ($0.000025 / 토큰)
```

**중요**: **출력 토큰이 입력 토큰보다 5배 비쌉니다!**

### 시나리오별 비용 분석

#### 시나리오 1: npm install (60초 작업)

**❌ Blocking 방식 (출력 전체 스트리밍)**
```
상황:
- 설치 시작
- 30초마다 진행 상황 확인 (2회)
- 매번 전체 출력 (2KB = 약 500 토큰) 캡처
- 마지막 전체 출력 확인

비용 계산:
- System Prompt:      500 토큰 (입력)
- 사용자 요청:       200 토큰 (입력)
- 중간 출력 1회:    500 토큰 (출력) × 2회 = 1,000 토큰
- 최종 출력:        500 토큰 (출력)
- Claude 응답:      200 토큰 (출력)

합계:
입력: 700 토큰
출력: 1,700 토큰
총합: 2,400 토큰

비용: (700 × $0.000005) + (1,700 × $0.000025)
    = $0.0035 + $0.0425
    = $0.046 (약 4.6원)
```

**✅ Background + Output Summary 방식**
```
상황:
- 백그라운드에서 설치 시작
- 완료 후 마지막 30줄만 확인
- 1회의 최종 출력만 처리

비용 계산:
- System Prompt:      500 토큰 (입력)
- 사용자 요청:       150 토큰 (입력)
- 최종 출력:        200 토큰 (출력)  # 30줄 = 500이 아니라 200
- Claude 응답:      150 토큰 (출력)

합계:
입력: 650 토큰
출력: 350 토큰
총합: 1,000 토큰

비용: (650 × $0.000005) + (350 × $0.000025)
    = $0.00325 + $0.00875
    = $0.0120 (약 1.2원)

절약: 74% 비용 감소 ($0.034 절약)
```

#### 시나리오 2: Build Process (5분 작업)

**❌ Blocking + Full Monitoring**
```
상황:
- 빌드 시작
- 10초마다 진행 상황 확인 (30회)
- 매번 전체 출력 (10KB = 약 2,500 토큰) 캡처
- 최종 출력 확인

비용 계산:
- System Prompt:           500 토큰 (입력)
- 사용자 요청들:         1,500 토큰 (입력)
- 반복 출력 (30회):  2,500 × 30 = 75,000 토큰 (출력)
- 최종 출력:            2,500 토큰 (출력)
- Claude 응답들:       10,000 토큰 (출력)

합계:
입력: 2,000 토큰
출력: 87,500 토큰
총합: 89,500 토큰

비용: (2,000 × $0.000005) + (87,500 × $0.000025)
    = $0.01 + $2.1875
    = $2.1975 (약 220원)
```

**✅ Background + Hybrid Monitoring**
```
상황:
- 백그라운드에서 빌드 시작
- 첫 60초: 10초마다 확인 (6회)
- 이후: 30초마다 확인 (8회)
- 최종: 마지막 50줄 확인

비용 계산:
- System Prompt:           500 토큰 (입력)
- 모니터링 요청들:       1,000 토큰 (입력)
- 초기 출력 (6회):    1,500 × 6 = 9,000 토큰 (출력)
- 중간 출력 (8회):      500 × 8 = 4,000 토큰 (출력)
- 최종 출력:              500 토큰 (출력)
- Claude 응답들:        2,000 토큰 (출력)

합계:
입력: 1,500 토큰
출력: 15,500 토큰
총합: 17,000 토큰

비용: (1,500 × $0.000005) + (15,500 × $0.000025)
    = $0.0075 + $0.3875
    = $0.395 (약 39원)

절약: 82% 비용 감소 ($1.80 절약)
```

#### 시나리오 3: Test Suite (30분 작업)

**❌ Blocking + Streaming Everything**
```
상황:
- 테스트 실행
- 30초마다 진행 상황 (60회)
- 매번 15KB 출력 (약 3,750 토큰) 캡처

비용 계산:
입력:  3,000 토큰
출력: 225,000 토큰
총합: 228,000 토큰

비용: (3,000 × $0.000005) + (225,000 × $0.000025)
    = $0.015 + $5.625
    = $5.64 (약 564원)

시간: 30분 대기 + 처리 시간
```

**✅ Background + Smart Summary**
```
상황:
- 백그라운드 실행
- 초기: 6회 모니터링 (1분)
- 중간: 10회 주기 체크 (15분)
- 최종: 마지막 100줄 확인

비용 계산:
입력:  2,000 토큰
출력: 18,000 토큰
총합: 20,000 토큰

비용: (2,000 × $0.000005) + (18,000 × $0.000025)
    = $0.01 + $0.45
    = $0.46 (약 46원)

절약: 92% 비용 감소 ($5.18 절약)
시간: 2분 대기 (병렬 작업 가능)
```

### Cost Analysis Summary Table

| 시나리오 | 작업 시간 | Blocking 비용 | Background 비용 | 절약율 | 시간 절약 |
|---------|---------|-------------|----------------|-------|---------|
| npm install | 60초 | $0.046 | $0.012 | 74% | 58초 |
| Build | 5분 | $2.20 | $0.40 | 82% | 4분 50초 |
| Tests | 30분 | $5.64 | $0.46 | 92% | 28분 |
| Docker Build | 15분 | $8.50 | $0.70 | 92% | 14분 40초 |

**월 100개 작업 기준:**
- Blocking 방식: 약 $280 + 시간 낭비
- Background 방식: 약 $18 + 생산성 향상

**절약: 월 $262 + 시간 효율성**

---

## Claude Code Implementation | Claude Code 구현

### Bash Tool의 Background Parameter

Claude Code Bash tool에서 백그라운드 실행:

```python
# ✅ 올바른 사용법
Bash(
    command="npm install",
    run_in_background=True,
    description="Install dependencies"
)

# 다른 작업 수행...
other_task()

# 결과 확인
TaskOutput(task_id="...")
```

### Supported Background Tasks

다음 작업들은 백그라운드 실행에 최적화됨:

```
✅ Background 권장:
- npm install / yarn install / pip install
- npm run build / make / cargo build
- npm test / pytest / cargo test
- docker build / docker pull
- git clone / git fetch
- 대용량 파일 처리

❌ Background 부적절:
- git status / ls / pwd
- cat / head / tail (파일 읽기)
- grep 검색
- 즉시 입력 필요한 대화형 명령
```

### Monitoring Background Tasks

```python
# 백그라운드 작업 시작
task_result = Bash(
    command="npm run build > build.log 2>&1",
    run_in_background=True
)

# task_id 저장
task_id = task_result.get("task_id")

# 이후 다른 작업 수행...

# 결과 확인
build_output = TaskOutput(task_id=task_id)

# 출력 처리 (요약)
if build_output.success:
    # 마지막 30줄만 처리
    lines = build_output.stdout.split('\n')
    summary = '\n'.join(lines[-30:])
    print(f"Build complete:\n{summary}")
else:
    # 에러: 전체 출력 필요
    print(f"Build failed:\n{build_output.stdout}")
```

---

## Best Practices | 최적 사례

### 1. 명확한 Task 분류

```python
# ✅ 좋은 예
def run_build():
    # 백그라운드 작업 명확히
    build_task = Bash(
        command="npm run build",
        run_in_background=True,
        description="Build TypeScript"
    )

    # 다른 작업 동시 진행
    lint_result = Bash(command="npm run lint")

    # 빌드 완료 대기
    build_result = TaskOutput(task_id=build_task["task_id"])

    return build_result

# ❌ 나쁜 예
def run_build():
    # 블로킹 실행 (대기 낭비)
    Bash(command="npm run build")
    Bash(command="npm run lint")  # 빌드 완료까지 대기
```

### 2. 에러 처리

```python
# ✅ 좋은 예: 에러 감시
async_task = Bash(
    command="npm install",
    run_in_background=True
)

# 10초마다 상태 확인
max_retries = 60
for i in range(max_retries):
    result = TaskOutput(task_id=async_task["task_id"])

    if result.get("status") == "completed":
        if result.get("return_code") == 0:
            print("Success!")
            break
        else:
            # 에러 발생 시 전체 출력 읽기
            print(f"Error: {result['stderr']}")
            break

    time.sleep(10)

# ❌ 나쁜 예: 에러 무시
Bash(command="npm install", run_in_background=True)
# 결과 확인하지 않음
```

### 3. 출력 효율성

```python
# ✅ 토큰 효율적: 요약만 저장
task = Bash(
    command="npm test > test.log 2>&1",
    run_in_background=True
)

result = TaskOutput(task_id=task["task_id"])

# 마지막 50줄만 Claude에게 전달
lines = result["stdout"].split('\n')
summary = '\n'.join(lines[-50:])

# Claude에게 요약만 전달
"Test results:\n" + summary
```

### 4. Timeout 설정

```python
# ✅ 적절한 타임아웃
Bash(
    command="npm install",
    run_in_background=True,
    timeout=300000  # 5분
)

# ❌ 타임아웃 없음
Bash(
    command="npm install",
    run_in_background=True
    # 무제한 대기?
)
```

---

## Common Pitfalls | 피해야 할 실수

### 1. 결과 확인 빠뜨리기

```python
# ❌ 나쁜 예
Bash(
    command="npm install",
    run_in_background=True
)
# 결과를 확인하지 않음 - 설치 실패했을 수도!

print("Installation complete")  # 거짓일 수 있음

# ✅ 좋은 예
result = Bash(
    command="npm install",
    run_in_background=True
)

final_result = TaskOutput(task_id=result["task_id"])
if final_result["return_code"] == 0:
    print("Installation complete")
else:
    print(f"Installation failed: {final_result['stderr']}")
```

### 2. 의존성 무시

```python
# ❌ 나쁜 예
Bash(command="npm install", run_in_background=True)  # Task A
Bash(command="npm run build", run_in_background=True)  # Task B
# Task B는 Task A가 완료되어야 하는데, 바로 시작됨!

# ✅ 좋은 예
task_a = Bash(command="npm install", run_in_background=True)

# A 완료 대기
TaskOutput(task_id=task_a["task_id"])

# 이후 B 시작
Bash(command="npm run build", run_in_background=True)
```

### 3. 과도한 모니터링

```python
# ❌ 나쁜 예: 토큰 낭비
for i in range(300):  # 30분 동안 초마다 확인
    TaskOutput(task_id=task_id)
    time.sleep(1)  # 매초 Claude에게 상태 확인!

# ✅ 좋은 예: 효율적 모니터링
for i in range(12):  # 12번만 확인
    result = TaskOutput(task_id=task_id)
    if result.get("status") == "completed":
        break
    time.sleep(150)  # 2.5분마다 확인
```

### 4. 출력 파일 관리 미흡

```python
# ❌ 나쁜 예
for i in range(100):
    Bash(
        command="npm test > test.log 2>&1",
        run_in_background=True
    )
# test.log가 100번 덮어써짐

# ✅ 좋은 예
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
Bash(
    command=f"npm test > test_{timestamp}.log 2>&1",
    run_in_background=True
)
```

---

## Advanced Techniques | 고급 기법

### Parallel Task Orchestration

```python
# 여러 독립적 작업을 병렬로 실행
tasks = {}

# 3개 작업 동시 시작
tasks['install'] = Bash(
    command="npm install",
    run_in_background=True
)

tasks['lint'] = Bash(
    command="npm run lint",
    run_in_background=True
)

tasks['type-check'] = Bash(
    command="npm run type-check",
    run_in_background=True
)

# 모든 작업 완료 대기
results = {}
for name, task in tasks.items():
    results[name] = TaskOutput(task_id=task["task_id"])

# 결과 수집
all_passed = all(
    r.get("return_code") == 0
    for r in results.values()
)

print(f"All tasks passed: {all_passed}")
```

### Conditional Background Execution

```python
# 로컬 환경 체크 후 결정
def should_run_in_background(command: str, est_time: int) -> bool:
    # 30초 이상이면 백그라운드 실행
    return est_time > 30

# 동적 결정
install_time_estimate = 60  # 초

result = Bash(
    command="npm install",
    run_in_background=should_run_in_background(
        "npm install",
        install_time_estimate
    )
)
```

### Output Streaming to File

```python
# 출력을 파일에 스트리밍하여 토큰 절약
Bash(
    command="npm test > test_results.log 2>&1",
    run_in_background=True
)

# 나중에 필요한 부분만 읽기
Bash(
    command="tail -50 test_results.log"
)
```

---

## Tmux Commands Reference | Tmux 명령어 참조

### Session Management (세션 관리)

| 명령어 | 설명 |
|--------|------|
| `tmux new-session -d -s name "cmd"` | 새 세션 생성 및 명령 실행 |
| `tmux list-sessions` | 모든 세션 목록 |
| `tmux attach-session -t name` | 세션에 접속 |
| `tmux detach` | 세션에서 분리 (Ctrl+B, D) |
| `tmux kill-session -t name` | 세션 종료 |
| `tmux rename-session -t old new` | 세션 이름 변경 |

### Output Capture (출력 캡처)

| 명령어 | 설명 |
|--------|------|
| `tmux capture-pane -t name -p` | 세션의 전체 출력 표시 |
| `tmux capture-pane -t name -p -S -100` | 마지막 100줄 표시 |
| `tmux capture-pane -t name -p -S -30` | 마지막 30줄 표시 |
| `tmux capture-pane -t name -p > file.txt` | 출력을 파일로 저장 |

### Window & Pane (윈도우 및 팬)

| 명령어 | 설명 |
|--------|------|
| `tmux new-window -t name -n winname` | 새 윈도우 생성 |
| `tmux list-windows -t name` | 세션의 윈도우 목록 |
| `tmux split-window -h` | 윈도우를 좌우로 분할 |
| `tmux split-window -v` | 윈도우를 상하로 분할 |

### Advanced (고급)

| 명령어 | 설명 |
|--------|------|
| `tmux send-keys -t name "cmd" C-m` | 세션에 명령 전송 |
| `tmux show-session -t name` | 세션 설정 표시 |
| `tmux list-commands` | 모든 명령어 목록 |

---

## Shorthand Guide: Quick Reference

### 가장 일반적인 5가지 패턴

#### 1. 설치 작업
```bash
tmux new-session -d -s "npm_install" "cd /project && npm install"
tmux capture-pane -t "npm_install" -p | tail -20
```

#### 2. 빌드 작업
```bash
tmux new-session -d -s "build" "npm run build > build.log 2>&1"
tail -f build.log
```

#### 3. 테스트 실행
```bash
tmux new-session -d -s "test" "npm test > test.log 2>&1"
# 완료 대기
sleep 300
tmux capture-pane -t "test" -p -S -50
```

#### 4. 세션 모니터링
```bash
# 10초마다 상태 확인
while tmux list-sessions | grep -q "install"; do
  echo "Still running... $(date)"
  sleep 10
done
echo "Complete!"
```

#### 5. 다중 작업
```bash
tmux new-session -d -s "work" "sh -c 'npm install && npm run build'"
# 또는
tmux new-session -d -s "install" "npm install"
tmux new-session -d -s "lint" "npm run lint"
```

---

## 요약 | Summary

**Background Processes의 핵심:**

1. **시간 절약**: 장시간 작업을 백그라운드에서 실행하여 80% 시간 단축
2. **토큰 효율**: 출력 요약으로 74-92% 비용 절약
3. **Tmux 활용**: 터미널 세션 분리로 안정적인 실행
4. **Smart Monitoring**: 초기 모니터링 + 주기적 확인 + 최종 요약
5. **Error Handling**: 결과 확인으로 실패 감지

**즉시 적용 가능:**
- `run_in_background: true` 파라미터 사용
- 30초 이상 작업은 백그라운드 실행
- 최종 출력만 처리하여 토큰 절약
- Tmux로 세션 모니터링

**월 절약 효과:**
- 비용: $200+ 절약
- 시간: 10-20시간 절약
- 생산성: 병렬 작업으로 효율 증대

---

## 관련 문서 | Related Documentation

### 같은 수준의 다른 섹션
- [Subagent Architecture](./01-subagent-architecture.md) - 멀티 에이전트 패턴
- [Model Selection Reference](./02-model-selection-reference.md) - 모델 선택 전략
- [Tool-Specific Optimizations](./03-tool-specific-optimizations.md) - 도구별 최적화
- [Modular Codebase Benefits](./05-modular-codebase-benefits.md) - 아키텍처 설계
- [System Prompt Slimming](./06-system-prompt-slimming.md) - Prompt 최적화

### 병렬화 관련
- [Parallelization](../04-parallelization/README.md) - 병렬 처리 심화

### 상위 문서
- [Token Optimization Overview](./README.md) - 토큰 최적화 개요
- [Longform Guide](../README.md) - 전체 가이드

---

## References & Resources | 참고 자료

### Tmux Documentation
- [Tmux Official Manual](https://manpages.ubuntu.com/manpages/focal/man1/tmux.1.html)
- [Tmux Quick Reference](https://tmuxcheatsheet.com/)

### Claude API Pricing
- [Claude API Documentation](https://docs.anthropic.com/en/docs/about-claude/models/overview)
- [Token Counting](https://docs.anthropic.com/en/docs/resources/tokens)

### Related Tools
- [Task Scheduler MCP](https://modelcontextprotocol.io)
- [Process Management](https://www.gnu.org/software/coreutils/)

---

**작성자**: claude-automate 문서팀
**마지막 수정**: 2026년 1월
**상태**: 작성 완료
**원본 출처**: Affaan Mustafa's Claude Code Strategy, Claude API Documentation
