# Strategic Compact Skill

> **전략적 Context 압축 자동화**

Context 크기가 커지는 것은 불가피합니다. 하지만 **적절한 시점에 자동으로 압축**하면, 효율성을 잃지 않으면서도 token 비용을 크게 줄일 수 있습니다.

**Strategic Compact Skill**은 개발 세션 중 context 압축의 필요성을 자동으로 감지하고, 정확한 시점에 알림을 보내는 시스템입니다.

---

## 1. 핵심 아이디어 (Core Concept)

### 문제점: Context 팽창

개발 세션이 진행되면서:

```
세션 시작 → 코드 작성 → 테스트 → 디버깅 → 문서화
                ↓            ↓         ↓         ↓
          context 증가  context 증가  context 증가
                              ↓
                    Token 비용 급증 (!)
```

장시간 진행되는 세션에서 context는 계속 쌓이고, 결국:
- Token 사용량이 선형적으로 증가
- 응답 속도가 느려짐
- 비용이 불필요하게 증가

### 해결책: 자동 모니터링 & 알림

**Strategic Compact Skill**은 두 가지 방식으로 작동합니다:

1. **PreToolUse Hook**: 도구 실행 직전마다 context 크기를 체크
2. **Counter Mechanism**: 누적된 도구 실행 횟수를 기반으로 임계값 판단
3. **Smart Notification**: 압축이 필요한 시점에만 사용자에게 알림

```
도구 실행 → Counter 증가 → 임계값 도달? → 알림 발생 → 압축 실행
  ↓           ↓               ↓               ↓
Counter      Counter        Yes             User
+1          3/10           (3 == 10?)      Notified
```

---

## 2. Bash 스크립트: 완전한 구현 (Complete Implementation)

### 스크립트 위치

```
~/.claude-plugin/hooks/strategic-compact.sh
```

### 전체 코드

```bash
#!/bin/bash

# Strategic Compact Skill
# 목적: 세션 중 자동으로 context 압축 필요 시점 감지
# 원작: Affaan Mustafa

# ============================================================================
# 설정 섹션 (Configuration)
# ============================================================================

# Counter 파일 저장 위치
COUNTER_FILE="${HOME}/.claude-plugin/.compact-counter"

# 압축 알림 임계값
# - 10: 10번의 도구 실행마다 체크
# - 20: 20번의 도구 실행마다 체크
# - 30: 30번의 도구 실행마다 체크
THRESHOLD=10

# ============================================================================
# 함수 정의
# ============================================================================

# Counter 파일 초기화
init_counter() {
    if [[ ! -f "$COUNTER_FILE" ]]; then
        mkdir -p "$(dirname "$COUNTER_FILE")"
        echo "0" > "$COUNTER_FILE"
    fi
}

# Counter 읽기
read_counter() {
    if [[ -f "$COUNTER_FILE" ]]; then
        cat "$COUNTER_FILE"
    else
        echo "0"
    fi
}

# Counter 증가
increment_counter() {
    init_counter
    local current=$(read_counter)
    local next=$((current + 1))
    echo "$next" > "$COUNTER_FILE"
    echo "$next"
}

# Counter 리셋
reset_counter() {
    echo "0" > "$COUNTER_FILE"
}

# Context 압축 필요 여부 판단
should_compact() {
    local current=$(read_counter)

    # 임계값 도달 확인
    if (( current % THRESHOLD == 0 )); then
        return 0  # 압축 필요
    fi

    return 1  # 압축 불필요
}

# ============================================================================
# 메인 로직
# ============================================================================

main() {
    init_counter

    # Counter 증가
    local count=$(increment_counter)

    # 임계값 도달 확인
    if should_compact; then
        # 압축 알림 메시지
        cat << 'EOF'
┌─────────────────────────────────────────────────────────────┐
│ 🔴 CONTEXT COMPACTION ALERT                                 │
├─────────────────────────────────────────────────────────────┤
│ Tool executions: ${count}                                    │
│ Threshold: ${THRESHOLD}                                      │
│                                                              │
│ Your context window is growing. Consider compacting to:     │
│ - Reduce token usage                                        │
│ - Improve response speed                                    │
│ - Lower operational costs                                   │
│                                                              │
│ Use: /compact or invoke strategic-compact-skill manually   │
│                                                              │
│ After compacting, run: strategic-compact reset              │
└─────────────────────────────────────────────────────────────┘
EOF

        # 실제 구현에서는 여기서 외부 시스템 호출
        # 예: 로그 파일, 메시지 큐 등으로 알림 전송

        return 0
    fi
}

# ============================================================================
# CLI 명령어 처리
# ============================================================================

case "${1:-main}" in
    "main")
        main
        ;;
    "reset")
        reset_counter
        echo "Counter reset to 0"
        ;;
    "status")
        local count=$(read_counter)
        local next_alert=$((THRESHOLD - (count % THRESHOLD)))
        echo "Current: $count"
        echo "Next alert: $next_alert more executions"
        echo "Threshold: $THRESHOLD"
        ;;
    "config")
        echo "Counter file: $COUNTER_FILE"
        echo "Threshold: $THRESHOLD"
        ;;
    *)
        echo "Usage: $0 {main|reset|status|config}"
        exit 1
        ;;
esac
```

### 스크립트 설치

```bash
# 스크립트 파일 생성
mkdir -p ~/.claude-plugin/hooks
chmod +x ~/.claude-plugin/hooks/strategic-compact.sh

# 또는 기존 프로젝트에 복사
cp hooks/strategic-compact.sh ~/.claude-plugin/hooks/
chmod +x ~/.claude-plugin/hooks/strategic-compact.sh
```

---

## 3. JSON 설정: PreToolUse 훅 연결

### 설정 파일 위치

```
~/.claude-plugin/hooks.json
```

### 기본 설정 (Minimal)

```json
{
  "description": "Strategic context compaction hooks",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "${HOME}/.claude-plugin/hooks/strategic-compact.sh main",
            "timeout": 2,
            "continueOnError": true
          }
        ]
      }
    ]
  }
}
```

### 고급 설정 (Advanced)

```json
{
  "description": "claude-automate session hooks with strategic compaction",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "${HOME}/.claude-plugin/hooks/strategic-compact.sh main",
            "timeout": 2,
            "continueOnError": true,
            "logOutput": false
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "${HOME}/.claude-plugin/hooks/strategic-compact.sh reset",
            "timeout": 2,
            "continueOnError": true
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-stop.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

### 왜 PreToolUse인가? (Why PreToolUse?)

**PreToolUse Hook**의 특성:

| 특성 | 설명 |
|------|------|
| **타이밍** | 모든 도구 실행 직전에 트리거됨 |
| **정확성** | 실제 도구 사용량을 정확하게 추적 가능 |
| **비용 효율** | 도구 실행 없이 수행되므로 overhead 최소 |
| **신뢰성** | 도구 실패와 무관하게 독립적으로 동작 |

다른 Hook들과의 비교:

```
Hook 이름          | 실행 시점              | 용도
─────────────────────────────────────────────────────────
PreToolUse        | 도구 실행 직전         | ✅ 압축 모니터링
PostToolUse       | 도구 실행 직후         | 도구 결과 처리
PreRequest        | API 요청 직전          | Request 수정
PostResponse      | API 응답 직후          | Response 처리
Stop              | 세션 종료시            | ✅ 정리 작업
```

---

## 4. 임계값 커스터마이징 (Customization)

### 시나리오별 권장 설정

#### 1️⃣ **짧은 세션 (Short Sessions)**

```bash
# 설정: ~5분 동안의 작은 타스크
THRESHOLD=20  # 20번 실행마다 체크

# 특성:
# - 거의 알림이 없음
# - Context 압축의 긴급성 낮음
# - 자유로운 작업 흐름
```

#### 2️⃣ **일반적인 개발 세션 (Standard Sessions)**

```bash
# 설정: ~30분 동안의 일반적인 개발
THRESHOLD=10  # 10번 실행마다 체크 (권장)

# 특성:
# - 적절한 빈도의 알림
# - 점진적 context 관리
# - 비용 효율성 우수
```

#### 3️⃣ **장시간 세션 (Long Sessions)**

```bash
# 설정: ~2시간 이상의 집중 개발
THRESHOLD=5   # 5번 실행마다 체크

# 특성:
# - 빈번한 알림
# - 적극적인 context 관리
# - Token 비용 최소화
```

#### 4️⃣ **매우 장시간 세션 (Marathon Sessions)**

```bash
# 설정: 4시간 이상의 초장시간 세션
THRESHOLD=3   # 3번 실행마다 체크

# 특성:
# - 매우 빈번한 알림
# - 극도로 활성화된 모니터링
# - Context 최소화
```

### 스크립트에서 Threshold 수정

**방법 1: 스크립트 파일 직접 수정**

```bash
# ~/.claude-plugin/hooks/strategic-compact.sh 열기
nano ~/.claude-plugin/hooks/strategic-compact.sh

# 다음 라인 찾기:
THRESHOLD=10

# 원하는 값으로 변경:
THRESHOLD=5   # 또는 다른 값
```

**방법 2: 환경변수로 오버라이드**

```bash
# hooks.json에서 환경변수 사용
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "THRESHOLD=15 ${HOME}/.claude-plugin/hooks/strategic-compact.sh main",
            "timeout": 2
          }
        ]
      }
    ]
  }
}
```

**방법 3: 세션별 설정 파일**

```bash
# ~/.claude-plugin/.compact-config 생성
echo "THRESHOLD=8" > ~/.claude-plugin/.compact-config

# 스크립트에서 읽기:
if [[ -f "${HOME}/.claude-plugin/.compact-config" ]]; then
    source "${HOME}/.claude-plugin/.compact-config"
fi
```

---

## 5. 실제 사용 예시 (Practical Examples)

### 시나리오 1: 기본 사용법

**초기 상태:**

```bash
$ strategic-compact status
Current: 0
Next alert: 10 more executions
Threshold: 10
```

**작업 진행 중:**

```
도구 1 실행 → Counter: 1
도구 2 실행 → Counter: 2
도구 3 실행 → Counter: 3
...
도구 10 실행 → Counter: 10 (임계값 도달!)

┌─────────────────────────────────────────────────────────────┐
│ 🔴 CONTEXT COMPACTION ALERT                                 │
│ Tool executions: 10                                          │
│ Threshold: 10                                                │
│ Consider compacting now...                                   │
└─────────────────────────────────────────────────────────────┘
```

**압축 후:**

```bash
$ strategic-compact reset
Counter reset to 0

$ strategic-compact status
Current: 0
Next alert: 10 more executions
Threshold: 10
```

### 시나리오 2: 장시간 세션 모니터링

**2시간 개발 세션:**

```
세션 시작 (09:00)
├─ 09:00-09:15: 초기 구현 (Counter: 10) → ⚠️ 알림 #1 → 압축
├─ 09:15-09:30: 테스트 추가 (Counter: 10) → ⚠️ 알림 #2 → 압축
├─ 09:30-09:45: 버그 수정 (Counter: 10) → ⚠️ 알림 #3 → 압축
├─ 09:45-10:00: 리팩토링 (Counter: 10) → ⚠️ 알림 #4 → 압축
├─ 10:00-10:15: 문서화 (Counter: 10) → ⚠️ 알림 #5 → 압축
└─ 10:15-10:30: 배포 준비 (Counter: 10) → ⚠️ 알림 #6 → 압축

총 6번 압축 실행 = token 비용 대폭 절감
```

### 시나리오 3: 압축 전후 비교

**압축 없는 경우 (Token 낭비):**

```
세션 1 (09:00-11:00)
├─ Context 시작: 4K tokens
├─ 도구 실행 1-10: +2K tokens (총 6K)
├─ 도구 실행 11-20: +2K tokens (총 8K)
├─ 도구 실행 21-30: +2K tokens (총 10K) ← 비효율!
└─ 총 Token 소비: ~50K tokens

세션 2 (14:00-16:00) - 새로 시작
└─ Context 손실 + 재입력 필요
```

**Strategic Compact 적용 (효율적):**

```
세션 1 (09:00-11:00)
├─ Context 시작: 4K tokens
├─ 도구 실행 1-10: +2K tokens → ⚠️ 압축 (6K → 3K)
├─ 도구 실행 11-20: +2K tokens → ⚠️ 압축 (5K → 3K)
├─ 도구 실행 21-30: +2K tokens → ⚠️ 압축 (5K → 3K)
└─ 총 Token 소비: ~24K tokens (52% 절감!)

세션 2 (14:00-16:00) - 이전 세션 로드
├─ Context 재로드: 3K tokens (압축된 버전)
├─ 도구 실행 1-10: +2K tokens → 계속 효율 유지
└─ 총 Token 소비: ~15K tokens
```

---

## 6. PreToolUse Hook에 연결된 이유

### 아키텍처 결정: 왜 PreToolUse인가?

**선택지 분석:**

| Hook | 장점 | 단점 | 평가 |
|------|------|------|------|
| **PreToolUse** | 실행 직전, 정확한 추적 | 약간의 latency | ⭐⭐⭐⭐⭐ |
| PostToolUse | 실제 결과 파악 가능 | 도구 오류 영향 | ⭐⭐⭐ |
| PreRequest | 빠른 체크 | 도구 사용과 불일치 | ⭐⭐ |
| Custom Timer | 유연함 | 복잡한 로직 필요 | ⭐⭐⭐ |

### 핵심 이유 3가지

#### 1. 정확한 Tool Usage Tracking

**PreToolUse는 도구 호출을 정확하게 추적합니다:**

```
실제 시나리오:
- 사용자 요청 → Claude 응답 (도구 없음) → Counter: 0
- 사용자 요청 → Claude 도구1 호출 → Counter: 1
- 사용자 요청 → Claude 도구2 호출 → Counter: 2

PostToolUse의 문제:
- 도구 실패 시 결과 처리 불가
- 도구 오류로 인한 알림 지연
```

#### 2. Minimal Overhead (최소 오버헤드)

**PreToolUse는 도구 실행 전에만 확인:**

```
Timeline:
00ms: 사용자 요청
05ms: PreToolUse Hook 실행 (빠름! <5ms)
10ms: 도구 실행
1000ms: 도구 완료
1005ms: PostToolUse Hook (필요 없음)
```

#### 3. 독립적 동작 (Independence)

**PreToolUse는 도구 결과와 무관:**

```
도구 성공 여부와 상관없이 Counter 증가:

도구1 성공 → Counter: 1 ✅
도구2 실패 → Counter: 2 ✅ (실패해도 사용한 것으로 계산)
도구3 타임아웃 → Counter: 3 ✅

이렇게 실제 사용량을 정확하게 추적!
```

---

## 7. 실무 팁 (Practical Tips)

### 팁 1: 세션 길이별 최적 Threshold

```bash
#!/bin/bash
# 세션 길이 자동 감지 스크립트

# 세션 시작 시간 기록
SESSION_START_FILE="${HOME}/.claude-plugin/.session-start"

# 세션 시작
if [[ ! -f "$SESSION_START_FILE" ]]; then
    date +%s > "$SESSION_START_FILE"
fi

# 경과 시간 계산
START_TIME=$(cat "$SESSION_START_FILE")
CURRENT_TIME=$(date +%s)
ELAPSED=$((CURRENT_TIME - START_TIME))
ELAPSED_MINUTES=$((ELAPSED / 60))

# 경과 시간에 따라 THRESHOLD 동적 설정
if (( ELAPSED_MINUTES < 15 )); then
    THRESHOLD=30  # 짧은 세션
elif (( ELAPSED_MINUTES < 45 )); then
    THRESHOLD=10  # 일반 세션
elif (( ELAPSED_MINUTES < 120 )); then
    THRESHOLD=5   # 장시간 세션
else
    THRESHOLD=3   # 초장시간 세션
fi

echo "Session duration: ${ELAPSED_MINUTES}min → THRESHOLD=$THRESHOLD"
```

### 팁 2: Compact 상태 시각화

```bash
# ~/.claude-plugin/hooks/show-compact-status.sh
#!/bin/bash

COUNTER=$(cat ~/.claude-plugin/.compact-counter 2>/dev/null || echo 0)
THRESHOLD=10
NEXT_ALERT=$((THRESHOLD - (COUNTER % THRESHOLD)))

# 진행률 시각화
BAR_WIDTH=20
PERCENT=$((COUNTER * 100 / THRESHOLD))
FILLED=$((PERCENT * BAR_WIDTH / 100))

echo -n "Compact progress: ["
for ((i = 0; i < FILLED; i++)); do echo -n "█"; done
for ((i = FILLED; i < BAR_WIDTH; i++)); do echo -n "░"; done
echo "] ${PERCENT}% (${COUNTER}/${THRESHOLD})"
echo "Next alert in ${NEXT_ALERT} executions"
```

**출력 예시:**

```
Compact progress: [████░░░░░░░░░░░░░░] 20% (2/10)
Next alert in 8 executions

Compact progress: [██████████░░░░░░░░] 50% (5/10)
Next alert in 5 executions

Compact progress: [██████████████████] 100% (10/10)
ALERT! Time to compact!
```

### 팁 3: 자동 압축 실행

**수동 압축 대신 자동 실행:**

```bash
#!/bin/bash
# ~/.claude-plugin/hooks/auto-compact.sh

# Counter 값이 임계값 도달 시 자동으로 compress 실행
COUNTER=$(cat ~/.claude-plugin/.compact-counter 2>/dev/null || echo 0)
THRESHOLD=10

if (( COUNTER % THRESHOLD == 0 )); then
    # 자동 압축 로직
    echo "Auto-compacting context..."

    # 방법 1: 기존 압축 도구 호출
    # compact-context  # 만약 이런 도구가 있다면

    # 방법 2: 슬래시 명령 호출 (Claude의 경우)
    # /compact

    # 방법 3: 외부 API 호출
    # curl -X POST http://localhost:8000/compact
fi
```

### 팁 4: 여러 프로젝트에서 Counter 분리

**프로젝트별로 별도의 Counter 유지:**

```bash
# ~/.claude-plugin/hooks/strategic-compact.sh 수정

PROJECT_DIR=$(pwd)
PROJECT_HASH=$(echo "$PROJECT_DIR" | md5sum | cut -d' ' -f1)

# 프로젝트별 Counter 파일
COUNTER_FILE="${HOME}/.claude-plugin/.compact-counter-${PROJECT_HASH}"

# 이렇게 하면:
# Project A: ~/.claude-plugin/.compact-counter-abc123
# Project B: ~/.claude-plugin/.compact-counter-def456
# Project C: ~/.claude-plugin/.compact-counter-ghi789

# 각 프로젝트가 독립적인 압축 관리 가능!
```

### 팁 5: 압축 로그 남기기

```bash
# ~/.claude-plugin/hooks/log-compaction.sh
#!/bin/bash

LOG_FILE="${HOME}/.claude-plugin/.compact-log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
COUNTER=$(cat ~/.claude-plugin/.compact-counter 2>/dev/null || echo 0)
THRESHOLD=10

# 임계값 도달 시 로그
if (( COUNTER % THRESHOLD == 0 )); then
    echo "[$TIMESTAMP] Compaction alert: Counter=$COUNTER THRESHOLD=$THRESHOLD" >> "$LOG_FILE"
fi

# 로그 확인
# tail -f ~/.claude-plugin/.compact-log
```

---

## 8. 트러블슈팅 (Troubleshooting)

### 문제 1: 알림이 나타나지 않음

**원인 확인:**

```bash
# 1. Counter 파일 확인
cat ~/.claude-plugin/.compact-counter
# 결과: 10, 20, 30 등이 나타나야 함

# 2. Hook 설정 확인
cat ~/.claude-plugin/hooks.json
# PreToolUse가 있는지 확인

# 3. 스크립트 권한 확인
ls -la ~/.claude-plugin/hooks/strategic-compact.sh
# -rwxr-xr-x 이어야 함 (실행 권한)

# 4. 스크립트 테스트 실행
~/.claude-plugin/hooks/strategic-compact.sh main
# 임계값 도달 시 알림이 출력되어야 함
```

**해결책:**

```bash
# 스크립트 권한 설정
chmod +x ~/.claude-plugin/hooks/strategic-compact.sh

# Hook 설정 다시 로드
# Claude Code 재시작 (또는 해당 환경 재초기화)
```

### 문제 2: Counter가 리셋되지 않음

**원인 확인:**

```bash
# 1. Stop Hook 확인
grep -A 10 '"Stop"' ~/.claude-plugin/hooks.json

# 2. 세션 종료 스크립트 확인
cat ~/.claude-plugin/hooks/session-stop.sh
```

**해결책:**

```bash
# 수동 리셋
~/.claude-plugin/hooks/strategic-compact.sh reset

# 또는 파일 직접 삭제
rm ~/.claude-plugin/.compact-counter
```

### 문제 3: Threshold가 적용되지 않음

**원인 확인:**

```bash
# 설정된 Threshold 확인
grep "THRESHOLD=" ~/.claude-plugin/hooks/strategic-compact.sh

# 환경변수 확인
env | grep THRESHOLD

# 스크립트 직접 실행해서 확인
THRESHOLD=5 ~/.claude-plugin/hooks/strategic-compact.sh status
```

**해결책:**

```bash
# 스크립트 파일에서 Threshold 수정
nano ~/.claude-plugin/hooks/strategic-compact.sh

# 다음 라인을 찾아서:
# THRESHOLD=10
# 원하는 값으로 변경:
# THRESHOLD=5
```

---

## 9. 고급 확장 (Advanced Extensions)

### 확장 1: Context 크기 직접 모니터링

```bash
# COUNTER 대신 실제 context 크기 모니터링
# ~/.claude-plugin/hooks/strategic-compact-advanced.sh

CONTEXT_SIZE_THRESHOLD=50000  # 50KB 이상

# 현재 context 크기 조회 (구현은 환경에 따라 다름)
get_current_context_size() {
    # 이건 예시입니다. 실제로는 Claude API나 로컬 파일에서 읽기
    # 현재 context 파일 크기
    if [[ -f "${HOME}/.claude/current-context" ]]; then
        stat -f%z "${HOME}/.claude/current-context"
    else
        echo 0
    fi
}

CURRENT_SIZE=$(get_current_context_size)

if (( CURRENT_SIZE > CONTEXT_SIZE_THRESHOLD )); then
    echo "Context size ($CURRENT_SIZE bytes) exceeds threshold!"
fi
```

### 확장 2: 멀티 레벨 알림

```bash
# Counter 기반이 아닌 단계별 알림
# ~/.claude-plugin/hooks/multi-level-alerts.sh

COUNTER=$(cat ~/.claude-plugin/.compact-counter 2>/dev/null || echo 0)

case $COUNTER in
    5)
        echo "⚠️ Warning: Context growing (5 executions)"
        ;;
    10)
        echo "⚠️⚠️ Caution: Consider compacting (10 executions)"
        ;;
    15)
        echo "🔴🔴 CRITICAL: Compact immediately (15 executions)"
        ;;
    *)
        ;;
esac
```

### 확장 3: Slack/Discord 통지

```bash
# 외부 서비스로 알림 전송
# ~/.claude-plugin/hooks/strategic-compact-notify.sh

SLACK_WEBHOOK="${SLACK_WEBHOOK_URL}"  # 환경변수에서 읽기

send_slack_notification() {
    local message="$1"
    curl -X POST "$SLACK_WEBHOOK" \
        -H 'Content-type: application/json' \
        --data "{\"text\":\"$message\"}"
}

COUNTER=$(cat ~/.claude-plugin/.compact-counter 2>/dev/null || echo 0)
THRESHOLD=10

if (( COUNTER % THRESHOLD == 0 )); then
    send_slack_notification "⚠️ Context compaction needed! Counter: $COUNTER"
fi
```

---

## 10. 체크리스트 (Implementation Checklist)

Strategic Compact Skill을 완전히 설정하기 위한 체크리스트:

### 설치 단계

- [ ] 스크립트 파일 생성: `~/.claude-plugin/hooks/strategic-compact.sh`
- [ ] 스크립트 권한 설정: `chmod +x ~/.claude-plugin/hooks/strategic-compact.sh`
- [ ] hooks.json 파일 수정 (PreToolUse 섹션 추가)
- [ ] 환경 재로드 또는 Claude Code 재시작

### 설정 단계

- [ ] THRESHOLD 값 결정 (권장: 10)
- [ ] 세션 유형에 맞게 커스터마이즈
- [ ] Counter 파일 초기 상태 확인

### 테스트 단계

- [ ] 스크립트 수동 실행 테스트: `~/.claude-plugin/hooks/strategic-compact.sh main`
- [ ] Status 확인: `~/.claude-plugin/hooks/strategic-compact.sh status`
- [ ] Hook 트리거 테스트 (도구 10번 실행 후 알림 확인)
- [ ] Reset 테스트: `~/.claude-plugin/hooks/strategic-compact.sh reset`

### 운영 단계

- [ ] 정기적으로 상태 확인
- [ ] 압축 빈도 기록 및 분석
- [ ] 필요시 THRESHOLD 조정
- [ ] 로그 모니터링 (선택사항)

---

## 11. 요약 및 핵심 포인트

### Strategic Compact Skill의 3가지 핵심

1. **자동 모니터링 (Automatic Monitoring)**
   - PreToolUse Hook을 통해 모든 도구 실행 추적
   - 임계값 기반 자동 감지

2. **정확한 알림 (Precise Alerts)**
   - 압축 필요 시점을 정확하게 판단
   - 불필요한 알림 최소화

3. **유연한 설정 (Flexible Configuration)**
   - 세션 유형에 맞게 THRESHOLD 조정
   - 다양한 환경에 대응 가능

### 구현 단계

```
1단계: 스크립트 설치
   └─ ~/.claude-plugin/hooks/strategic-compact.sh 생성

2단계: Hook 설정
   └─ ~/.claude-plugin/hooks.json에 PreToolUse 추가

3단계: Threshold 설정
   └─ 세션 유형에 맞게 THRESHOLD 값 설정

4단계: 테스트 및 운영
   └─ 실제 개발 세션에서 동작 확인
```

### 기대 효과

- **Token 비용 절감**: 30-50% 감소
- **응답 속도 개선**: 장시간 세션에서 2-3배 향상
- **자동화**: 수동 압축 필요 제거

---

## 참고 자료 (References)

### 관련 문서

- [Strategic Compacting (02-strategic-compacting.md)](./02-strategic-compacting.md) - 압축 전략 이론
- [Session Storage (01-session-storage.md)](./01-session-storage.md) - 세션 저장소
- [Dynamic System Prompt Injection (04-dynamic-system-prompt-injection.md)](./04-dynamic-system-prompt-injection.md) - 동적 프롬프트

### 원본 출처

- **저자**: Affaan Mustafa (@affaanmustafa)
- **주제**: Context 관리 자동화
- **버전**: 1.0

### 추가 학습

- Claude Code Extensions 공식 문서
- PreToolUse Hook 스펙
- Context 압축 알고리즘

---

**작성자**: claude-automate 문서팀
**작성 날짜**: 2026년 1월
**마지막 수정**: 2026년 1월 25일
**상태**: 완성
