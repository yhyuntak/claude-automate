# Observability Methods for Verification & Evaluation

> **How to observe, track, and validate Claude's thinking process and actions during automated task execution**

## 개요 (Overview)

Verification(검증) 과정에서 가장 중요한 것은 **무슨 일이 일어났는지 알 수 있어야 한다**는 것입니다.

claude-automate 시스템에서 자동화 작업을 실행할 때:

- Claude의 **생각 과정(thinking stream)**을 추적해야 합니다
- 도구 실행과 그 **부작용(side effects)**을 기록해야 합니다
- 각 단계의 **변경사항을 검증**해야 합니다

이 문서는 Claude의 동작을 관찰하고 검증하기 위한 **두 가지 주요 방법**을 소개합니다:

1. **tmux 프로세스 추적** - Claude의 thinking stream을 실시간으로 모니터링
2. **PostToolUse 훅** - 도구 실행 후 변경사항을 자동으로 기록

---

## 1. tmux를 이용한 Thinking Stream 추적

### 1.1 개념 (Concept)

**Thinking Stream Tracking via tmux** 란 tmux 세션을 통해 Claude의 에이전트 프로세스를 모니터링하고, 생각 과정의 로그를 실시간으로 수집하는 방법입니다.

### 핵심 원리

Claude Code에서 에이전트가 실행될 때:

```
User Request
    ↓
Agent Process (tmux session)
    ├─ Input Processing
    ├─ Thinking Stream (internal reasoning)
    ├─ Tool Selection
    ├─ Tool Execution
    └─ Response Generation
    ↓
Output + Thinking Logs
```

tmux를 사용하면 이 **전체 과정을 외부에서 관찰**할 수 있습니다.

### 1.2 구현 방법 (Implementation)

#### Step 1: tmux 세션 설정

```bash
#!/bin/bash
# Start agent in tmux session

SESSION_NAME="claude-agent-eval"
TASK_LOG="${PWD}/eval-logs/thinking-stream-$(date +%s).log"

mkdir -p "$(dirname "$TASK_LOG")"

# Create new tmux session with logging
tmux new-session -d -s "$SESSION_NAME" \
  -c "$PWD" \
  "bash -c 'exec tee -a \"$TASK_LOG\" | /path/to/agent-runner.sh'"

echo "Agent started in session: $SESSION_NAME"
echo "Thinking stream logged to: $TASK_LOG"
```

#### Step 2: 실시간 모니터링 (Real-time Monitoring)

```bash
#!/bin/bash
# Monitor thinking stream in real-time

SESSION_NAME="claude-agent-eval"
LOG_FILE="${PWD}/eval-logs/thinking-stream.log"

# Attach to session to view live output
tmux capture-pane -t "$SESSION_NAME" -p

# Or follow the log file
tail -f "$LOG_FILE"
```

#### Step 3: Thinking Stream 분석 (Analysis)

```bash
#!/bin/bash
# Analyze thinking patterns from logs

LOG_FILE="$1"

echo "=== Thinking Stream Analysis ==="
echo ""

echo "1. Decision Points:"
grep -E "(decision|choosing|between)" "$LOG_FILE" | head -5

echo ""
echo "2. Tool Selections:"
grep -E "(calling|executing|tool:)" "$LOG_FILE" | head -10

echo ""
echo "3. Error Handling:"
grep -E "(error|failed|exception|retry)" "$LOG_FILE" | head -5

echo ""
echo "4. Final Reasoning:"
grep -E "(conclusion|result|summary)" "$LOG_FILE" | tail -3
```

### 1.3 한국어 예제 (Korean Example)

#### 사용 시나리오: Multi-Agent 작업 검증

```bash
#!/bin/bash
# eval-multi-agent.sh
# 다중 에이전트 작업의 생각 과정을 추적합니다

EVAL_DIR="./eval-results/$(date +%Y-%m-%d_%H-%M-%S)"
mkdir -p "$EVAL_DIR"

# Agent 1: 계획 수립
echo "[1/3] Agent 1: 계획 수립 시작..."
tmux new-session -d -s "agent-planner" \
  "bash -c 'env LOG_FILE=\"$EVAL_DIR/planner.log\" /path/to/planner-agent.sh | tee -a \"$EVAL_DIR/planner.log\"'"

sleep 10

# Agent 2: 구현
echo "[2/3] Agent 2: 구현 시작..."
tmux new-session -d -s "agent-implementer" \
  "bash -c 'env LOG_FILE=\"$EVAL_DIR/implementer.log\" /path/to/implementer-agent.sh | tee -a \"$EVAL_DIR/implementer.log\"'"

sleep 20

# Agent 3: 검증
echo "[3/3] Agent 3: 검증 시작..."
tmux new-session -d -s "agent-verifier" \
  "bash -c 'env LOG_FILE=\"$EVAL_DIR/verifier.log\" /path/to/verifier-agent.sh | tee -a \"$EVAL_DIR/verifier.log\"'"

# Wait for all agents to complete
sleep 30

echo ""
echo "=== 생각 과정 분석 ==="
echo ""

for log in "$EVAL_DIR"/*.log; do
  echo "📋 $(basename $log):"
  echo "---"

  # 주요 결정 지점 추출
  grep "결정\|선택\|분석" "$log" 2>/dev/null | head -3

  echo ""
done

echo "전체 로그: $EVAL_DIR/"
```

#### 실행 결과 예시

```
[1/3] Agent 1: 계획 수립 시작...
[2/3] Agent 2: 구현 시작...
[3/3] Agent 3: 검증 시작...

=== 생각 과정 분석 ===

📋 planner.log:
---
[09:15:23] 요청 분석 중...
[09:15:25] 작업을 5개 단계로 분해하는 것이 최적이라고 판단
[09:15:27] 우선순위: 기초 구조 설정 → 기능 구현 → 테스트 → 문서화 → 배포

📋 implementer.log:
---
[09:15:35] 계획 수신 완료
[09:15:37] 구현 순서 재검토: 의존성 확인
[09:15:40] Step 1/5: 기초 구조 설정 (예상 시간: 15분)

📋 verifier.log:
---
[09:16:10] 구현 결과물 검증 시작
[09:16:12] 5가지 검증 항목 식별
[09:16:15] Step 1: 코드 스타일 검증
```

### 1.4 장점과 단점 (Pros and Cons)

| 측면 | tmux 추적 |
|------|----------|
| **장점** | - 완전한 thinking stream 기록<br>- 실시간 모니터링 가능<br>- 상세한 decision history<br>- Multi-agent 추적 용이 |
| **단점** | - 설정이 복잡할 수 있음<br>- 로그 파일 크기 증가<br>- 민감한 정보 노출 위험<br>- 분석에 시간 소요 |
| **적합한 경우** | - 복잡한 multi-agent 작업<br>- 문제 원인 분석 필요<br>- 성능 최적화 연구<br>- 교육/문서화 목적 |

---

## 2. PostToolUse 훅을 이용한 변경사항 로깅

### 2.1 개념 (Concept)

**PostToolUse Hook Logging** 은 Claude가 도구(tool)를 실행한 **직후에 자동으로 변경사항을 기록**하는 방법입니다.

### 핵심 원리

```
Tool Execution Flow:
    ↓
[Tool Runs]
    ↓
[PostToolUse Hook Triggered]
    ├─ Changes Detected
    ├─ Metadata Extracted
    ├─ Log Entry Created
    └─ Verification Data Stored
    ↓
Audit Trail Available
```

### 2.2 구현 방법 (Implementation)

#### Step 1: PostToolUse 훅 설정

```bash
# File: hooks/post-tool-use.sh
#!/bin/bash
#
# PostToolUse Hook: Record all changes made by Claude's tool execution
#
# Environment Variables Set by Claude:
#   - CLAUDE_TOOL_NAME: Name of the tool that was executed
#   - CLAUDE_TOOL_INPUT: Input provided to the tool
#   - CLAUDE_TOOL_OUTPUT: Output returned from the tool
#   - CLAUDE_TOOL_STATUS: success, error, timeout, etc.
#   - CLAUDE_EXECUTION_ID: Unique ID for this execution
#

set -euo pipefail

# Configuration
LOG_DIR="${CLAUDE_WORKSPACE:-.}/audit-logs"
CHANGE_LOG="$LOG_DIR/changes-$(date +%Y-%m-%d).jsonl"
DIFF_DIR="$LOG_DIR/diffs"

mkdir -p "$LOG_DIR" "$DIFF_DIR"

# Get timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")

# Extract tool information
TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"
TOOL_OUTPUT="${CLAUDE_TOOL_OUTPUT:-}"
TOOL_STATUS="${CLAUDE_TOOL_STATUS:-unknown}"
EXEC_ID="${CLAUDE_EXECUTION_ID:-$(uuidgen)}"

# Function: Log tool execution
log_tool_execution() {
  local entry=$(cat <<EOF
{
  "timestamp": "$TIMESTAMP",
  "execution_id": "$EXEC_ID",
  "tool": "$TOOL_NAME",
  "status": "$TOOL_STATUS",
  "input_summary": "$(echo "$TOOL_INPUT" | head -c 200 | jq -Rs .)",
  "output_summary": "$(echo "$TOOL_OUTPUT" | head -c 200 | jq -Rs .)"
}
EOF
  )
  echo "$entry" >> "$CHANGE_LOG"
}

# Function: Detect file changes
detect_file_changes() {
  local before_file="$1"
  local after_file="$2"
  local target_file="$3"

  if [ ! -f "$before_file" ] || [ ! -f "$after_file" ]; then
    return
  fi

  # Generate unified diff
  local diff_file="$DIFF_DIR/${EXEC_ID}_$(basename "$target_file").patch"
  diff -u "$before_file" "$after_file" > "$diff_file" || true

  # Log the diff
  local diff_summary=$(cat <<EOF
{
  "timestamp": "$TIMESTAMP",
  "execution_id": "$EXEC_ID",
  "type": "file_change",
  "file": "$target_file",
  "tool": "$TOOL_NAME",
  "diff_file": "$diff_file",
  "lines_added": $(diff -u "$before_file" "$after_file" 2>/dev/null | grep '^+' | wc -l),
  "lines_removed": $(diff -u "$before_file" "$after_file" 2>/dev/null | grep '^-' | wc -l)
}
EOF
  )
  echo "$diff_summary" >> "$CHANGE_LOG"
}

# Function: Track command execution
track_command_execution() {
  local cmd="$1"
  local exit_code="$2"

  local entry=$(cat <<EOF
{
  "timestamp": "$TIMESTAMP",
  "execution_id": "$EXEC_ID",
  "type": "command_execution",
  "tool": "$TOOL_NAME",
  "command": "$(echo "$cmd" | jq -Rs .)",
  "exit_code": $exit_code
}
EOF
  )
  echo "$entry" >> "$CHANGE_LOG"
}

# Main logic
log_tool_execution

echo "[PostToolUse] $TOOL_NAME executed at $TIMESTAMP (ID: $EXEC_ID)"
```

#### Step 2: hooks.json 설정

```json
{
  "description": "claude-automate verification and observability hooks",
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/post-tool-use.sh",
            "timeout": 5,
            "captureOutput": true,
            "continueOnError": true
          }
        ]
      }
    ]
  }
}
```

#### Step 3: 실제 로깅 구현

```bash
# File: hooks/advanced-post-tool-use.sh
#!/bin/bash
#
# Advanced PostToolUse Hook with change detection
# 한국어: 고급 PostToolUse 훅 - 변경사항 감지 포함
#

set -euo pipefail

# Configuration
WORKSPACE="${CLAUDE_WORKSPACE:-.}"
AUDIT_LOG="$WORKSPACE/.audit/operations.log"
METRICS_LOG="$WORKSPACE/.audit/metrics.jsonl"

mkdir -p "$WORKSPACE/.audit"

# Initialize baseline snapshot for this execution
SNAPSHOT_DIR="$WORKSPACE/.snapshots"
mkdir -p "$SNAPSHOT_DIR"

EXEC_ID="${CLAUDE_EXECUTION_ID:-$(date +%s%N)}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
TOOL_NAME="${CLAUDE_TOOL_NAME:-unknown}"

# Create detailed audit entry
create_audit_entry() {
  cat <<EOF >> "$AUDIT_LOG"
[$TIMESTAMP] Tool: $TOOL_NAME | Execution: $EXEC_ID
Status: ${CLAUDE_TOOL_STATUS:-unknown}
Input: ${CLAUDE_TOOL_INPUT:0:150}...
Output: ${CLAUDE_TOOL_OUTPUT:0:150}...
---
EOF
}

# Detect and log file system changes
detect_changes() {
  local current_snapshot="$SNAPSHOT_DIR/${EXEC_ID}-after.txt"

  # Create current file listing
  find "$WORKSPACE" -type f \
    ! -path "./.git/*" \
    ! -path "./.snapshots/*" \
    ! -path "./.audit/*" \
    -exec stat -f '%Sm %s %N' {} \; | sort > "$current_snapshot"

  # Compare with previous snapshot if exists
  local previous_snapshot="$SNAPSHOT_DIR/latest-snapshot.txt"
  if [ -f "$previous_snapshot" ]; then
    local changes=$(diff -u "$previous_snapshot" "$current_snapshot" || true)

    if [ -n "$changes" ]; then
      cat <<EOF >> "$METRICS_LOG"
{
  "timestamp": "$TIMESTAMP",
  "execution_id": "$EXEC_ID",
  "tool": "$TOOL_NAME",
  "type": "filesystem_changes",
  "change_count": $(echo "$changes" | grep '^[+-]' | wc -l),
  "summary": "Files modified, created, or deleted"
}
EOF
    fi
  fi

  # Update latest snapshot
  cp "$current_snapshot" "$previous_snapshot"
}

# Log metrics about execution
log_metrics() {
  cat <<EOF >> "$METRICS_LOG"
{
  "timestamp": "$TIMESTAMP",
  "execution_id": "$EXEC_ID",
  "tool": "$TOOL_NAME",
  "status": "${CLAUDE_TOOL_STATUS:-unknown}",
  "input_length": ${#CLAUDE_TOOL_INPUT},
  "output_length": ${#CLAUDE_TOOL_OUTPUT}
}
EOF
}

# Main execution
create_audit_entry
detect_changes
log_metrics

echo "[PostToolUse Hook] Recorded changes from $TOOL_NAME (ID: $EXEC_ID)"
```

### 2.3 한국어 실제 사용 예제 (Practical Korean Example)

```bash
#!/bin/bash
# eval-verification.sh
# 변경사항을 추적하며 검증 작업을 수행합니다

WORKSPACE="./my-project"
EVAL_SESSION=$(date +%Y%m%d_%H%M%S)
AUDIT_DIR="./audits/$EVAL_SESSION"

mkdir -p "$AUDIT_DIR"

echo "=========================================="
echo "검증 세션 시작: $EVAL_SESSION"
echo "=========================================="
echo ""

# Step 1: 초기 상태 스냅샷
echo "[Step 1] 초기 상태 기록 중..."
find "$WORKSPACE" -type f -name "*.md" -o -name "*.ts" | sort > "$AUDIT_DIR/files-before.txt"
git -C "$WORKSPACE" status --porcelain > "$AUDIT_DIR/git-status-before.txt" 2>/dev/null || true

# Step 2: Claude 자동화 작업 실행
echo "[Step 2] Claude 자동화 작업 실행..."
export CLAUDE_WORKSPACE="$WORKSPACE"
export CLAUDE_EXECUTION_ID="eval-$EVAL_SESSION"

# 예: README 업데이트 작업
/path/to/agent-update-docs.sh

# Step 3: 변경사항 수집
echo "[Step 3] 변경사항 분석 중..."
find "$WORKSPACE" -type f -name "*.md" -o -name "*.ts" | sort > "$AUDIT_DIR/files-after.txt"
git -C "$WORKSPACE" status --porcelain > "$AUDIT_DIR/git-status-after.txt" 2>/dev/null || true

# Step 4: 차이점 분석
echo "[Step 4] 변경 내역 비교..."
diff -u "$AUDIT_DIR/files-before.txt" "$AUDIT_DIR/files-after.txt" > "$AUDIT_DIR/file-diff.txt" || true

# Step 5: Audit 로그 분석
echo "[Step 5] Audit 로그 확인..."
if [ -f "$WORKSPACE/.audit/operations.log" ]; then
  echo "작업 기록:"
  tail -20 "$WORKSPACE/.audit/operations.log"
fi

echo ""
echo "=========================================="
echo "검증 완료"
echo "=========================================="
echo "결과 저장 위치: $AUDIT_DIR"
echo "  - files-before.txt: 변경 전 파일 목록"
echo "  - files-after.txt: 변경 후 파일 목록"
echo "  - file-diff.txt: 변경된 파일 목록"
echo "  - git-status-before.txt: 변경 전 git 상태"
echo "  - git-status-after.txt: 변경 후 git 상태"
```

### 2.4 장점과 단점 (Pros and Cons)

| 측면 | PostToolUse 훅 |
|------|---|
| **장점** | - 자동으로 실행됨<br>- 모든 도구 실행 기록<br>- 구조화된 데이터 (JSON)<br>- 낮은 오버헤드<br>- 감시할 내용만 선택 가능 |
| **단점** | - Thinking stream은 포함 안 됨<br>- 도구 실행 후만 가능<br>- 후처리 필요할 수 있음<br>- 훅 실행 시간 overhead |
| **적합한 경우** | - 자동화된 감시 필요<br>- 파일 변경사항 추적<br>- 지속적인 모니터링<br>- 감사(audit) 목적 |

---

## 3. 두 방법 비교 (Comparison)

### 3.1 기능 비교표 (Feature Comparison)

| 기능 | tmux Tracking | PostToolUse Hook |
|------|---|---|
| **Thinking Stream 기록** | ✅ 완전함 | ❌ 불가능 |
| **자동 실행** | ❌ 수동 설정 필요 | ✅ 자동 |
| **실시간 모니터링** | ✅ 가능 | ❌ 후처리 |
| **변경사항 감지** | 🟡 수동 분석 | ✅ 자동 |
| **구조화된 데이터** | ❌ 텍스트 로그 | ✅ JSON 형식 |
| **Multi-agent 추적** | ✅ 최적화됨 | 🟡 가능하지만 복잡 |
| **설정 난이도** | 중간 | 낮음 |
| **성능 영향** | 낮음 | 매우 낮음 |
| **로그 저장 크기** | 크다 (텍스트) | 작다 (JSON) |

### 3.2 사용 사례별 추천 (Use Cases)

#### 언제 tmux Tracking을 사용할까?

```
✅ 다음의 경우 tmux 추적을 선택하세요:

1. 에이전트의 의사결정 과정을 이해하고 싶을 때
   → Thinking stream이 중요하므로

2. 복잡한 multi-agent 워크플로우 분석
   → 각 에이전트의 상호작용을 추적해야 함

3. 문제 원인 분석(root cause analysis)
   → 무엇이 어떻게 잘못되었는지 알아야 함

4. 에이전트 성능 최적화
   → Decision making 과정의 병목 파악 필요

5. 교육/문서화 목적
   → 실제 사례로 설명해야 할 때
```

#### 언제 PostToolUse Hook을 사용할까?

```
✅ 다음의 경우 PostToolUse 훅을 선택하세요:

1. 변경사항 추적이 주 목적
   → 무엇이 바뀌었는지가 중요

2. 지속적인 모니터링/감사(audit)
   → 매 도구 실행마다 자동 기록

3. 프로덕션 환경의 안정성
   → 자동화되고 신뢰할 수 있는 기록

4. 규정 준수(compliance)
   → 모든 작업의 감사 증적(audit trail) 필요

5. 간단한 설정과 유지보수
   → 복잡한 설정 없이 즉시 사용
```

#### 최선의 방법: 두 가지 조합 (Best Practice: Hybrid)

```bash
#!/bin/bash
# Hybrid observability approach
# tmux로 thinking stream을 추적하고
# PostToolUse 훅으로 변경사항을 기록합니다

# 1. tmux로 agent 실행
SESSION="claude-agent"
LOG_FILE="logs/thinking-$(date +%s).log"

tmux new-session -d -s "$SESSION" \
  "env CLAUDE_WORKSPACE=. /path/to/agent.sh 2>&1 | tee '$LOG_FILE'"

echo "Agent started - thinking stream logged to: $LOG_FILE"

# 2. PostToolUse 훅은 이미 설정됨 (자동 실행)
# 결과:
# - Thinking stream은 $LOG_FILE에
# - 변경사항은 .audit/ 디렉토리에
# 두 가지 정보를 함께 얻을 수 있음!
```

---

## 4. 실제 구현 예시 (Practical Implementation Examples)

### 4.1 예제 1: 문서 생성 검증

```bash
#!/bin/bash
# eval-doc-generation.sh
# 문서 생성 작업을 검증합니다

set -euo pipefail

WORKSPACE="./docs-project"
EVAL_ID=$(date +%s)
REPORT="eval-report-$EVAL_ID.md"

echo "# 문서 생성 검증 보고서" > "$REPORT"
echo "생성 시간: $(date)" >> "$REPORT"
echo "" >> "$REPORT"

# 1. 시작 전 상태 기록
echo "## 변경 전 상태" >> "$REPORT"
echo "" >> "$REPORT"
find "$WORKSPACE" -name "*.md" | wc -l | xargs echo "총 MD 파일 수:" >> "$REPORT"

# 2. Thinking stream 추적 시작
echo "작업 실행 중..."
tmux new-session -d -s "doc-gen" \
  "cd '$WORKSPACE' && /path/to/doc-generator.sh"

sleep 10

# 3. 작업 완료 대기
tmux send-keys -t "doc-gen" "" 2>/dev/null || true

# 4. 변경사항 분석
echo "" >> "$REPORT"
echo "## 변경 후 상태" >> "$REPORT"
echo "" >> "$REPORT"
find "$WORKSPACE" -name "*.md" | wc -l | xargs echo "총 MD 파일 수:" >> "$REPORT"

# 5. 생성된 문서 검증
echo "" >> "$REPORT"
echo "## 생성된 문서 검증" >> "$REPORT"
echo "" >> "$REPORT"

for file in "$WORKSPACE"/*.md; do
  if [ -f "$file" ]; then
    lines=$(wc -l < "$file")
    has_title=$(grep -c "^#" "$file" || echo "0")
    echo "- \`$(basename "$file")\`: $lines lines, $has_title headers" >> "$REPORT"
  fi
done

echo ""
echo "검증 완료: $REPORT"
cat "$REPORT"
```

### 4.2 예제 2: 코드 리팩토링 검증

```bash
#!/bin/bash
# eval-refactor.sh
# 코드 리팩토링 작업을 검증합니다

set -euo pipefail

WORKSPACE="./src"
BEFORE_SNAPSHOT="before-refactor.json"
AFTER_SNAPSHOT="after-refactor.json"

# Helper: Create code metrics snapshot
create_snapshot() {
  local output="$1"

  cat > "$output" <<EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "files": {
    "total": $(find "$WORKSPACE" -name "*.ts" | wc -l),
    "ts_files": $(find "$WORKSPACE" -name "*.ts" -type f | wc -l)
  },
  "metrics": {
    "total_lines": $(find "$WORKSPACE" -name "*.ts" -type f -exec wc -l {} + | tail -1 | awk '{print $1}'),
    "functions": $(find "$WORKSPACE" -name "*.ts" -type f -exec grep -c "function\|const.*=.*=>" {} + | paste -sd+ | bc)
  },
  "files_list": [
    $(find "$WORKSPACE" -name "*.ts" -type f | jq -R . | paste -sd,)
  ]
}
EOF
}

echo "리팩토링 검증 시작..."
echo ""

# 1. 리팩토링 전 상태 기록
echo "[1/3] 리팩토링 전 상태 기록..."
create_snapshot "$BEFORE_SNAPSHOT"

# 2. 리팩토링 작업 실행
echo "[2/3] 리팩토링 작업 실행 중..."
tmux new-session -d -s "refactor" \
  "cd '$WORKSPACE' && /path/to/refactor-agent.sh"

# 대기
sleep 15

# 3. 리팩토링 후 상태 기록
echo "[3/3] 리팩토링 후 상태 기록..."
create_snapshot "$AFTER_SNAPSHOT"

# 4. 비교 및 보고
echo ""
echo "=== 리팩토링 영향 분석 ==="
echo ""

echo "파일 변경:"
jq '.files' "$BEFORE_SNAPSHOT" "$AFTER_SNAPSHOT"

echo ""
echo "코드 메트릭 변경:"
echo "변경 전: $(jq '.metrics.total_lines' "$BEFORE_SNAPSHOT") 줄"
echo "변경 후: $(jq '.metrics.total_lines' "$AFTER_SNAPSHOT") 줄"
```

### 4.3 예제 3: 멀티 에이전트 워크플로우 검증

```bash
#!/bin/bash
# eval-multi-agent-workflow.sh
# 복잡한 멀티 에이전트 워크플로우를 검증합니다

set -euo pipefail

WORKSPACE="."
EVAL_SESSION="workflow-$(date +%Y%m%d_%H%M%S)"
EVAL_DIR="./evals/$EVAL_SESSION"

mkdir -p "$EVAL_DIR"

echo "==============================================="
echo "멀티 에이전트 워크플로우 검증 시작"
echo "세션: $EVAL_SESSION"
echo "==============================================="
echo ""

# Agent 1: 계획 수립
run_agent() {
  local agent_name="$1"
  local agent_script="$2"
  local log_file="$EVAL_DIR/${agent_name}.log"

  echo "[Agent] $agent_name 시작..."

  tmux new-session -d -s "$agent_name" \
    "env CLAUDE_EXECUTION_ID='$EVAL_SESSION-$agent_name' \
    bash '$agent_script' 2>&1 | tee '$log_file'"

  echo "  로그: $log_file"
}

# Run agents in sequence
run_agent "planner" "/path/to/planner-agent.sh"
sleep 5

run_agent "implementer" "/path/to/implementer-agent.sh"
sleep 10

run_agent "reviewer" "/path/to/reviewer-agent.sh"
sleep 5

# Wait for completion
echo ""
echo "모든 에이전트 완료 대기 중..."
sleep 10

# Analyze execution
echo ""
echo "==============================================="
echo "실행 분석"
echo "==============================================="
echo ""

for log in "$EVAL_DIR"/*.log; do
  agent=$(basename "$log" .log)
  echo "📊 $agent:"

  # Count decisions made
  decisions=$(grep -c "결정\|선택\|분석" "$log" 2>/dev/null || echo "0")
  echo "  - 결정 지점: $decisions"

  # Count errors
  errors=$(grep -c "error\|failed\|ERROR" "$log" 2>/dev/null || echo "0")
  echo "  - 오류: $errors"

  # Get execution time
  lines=$(wc -l < "$log")
  echo "  - 로그 라인: $lines"

  echo ""
done

# Summary
echo "==============================================="
echo "검증 완료"
echo "결과: $EVAL_DIR/"
echo "==============================================="
```

---

## 5. 체크리스트 및 베스트 프랙티스 (Checklist & Best Practices)

### 5.1 Observability 구현 체크리스트

```
관찰성(Observability) 구현을 위한 체크리스트:

□ Thinking Stream 추적
  □ tmux 세션 설정 완료
  □ 로그 저장 경로 정의
  □ 로그 회전(rotation) 설정
  □ 민감 정보 마스킹

□ PostToolUse 훅 구현
  □ hooks.json 설정
  □ 훅 스크립트 작성
  □ 환경 변수 검증
  □ 에러 처리

□ 데이터 분석
  □ 로그 파싱 스크립트
  □ 메트릭 추출 방법
  □ 보고서 생성 자동화
  □ 시각화 도구

□ 운영/유지보수
  □ 로그 저장소 용량 모니터링
  □ 오래된 로그 정리 정책
  □ 보안 감사 로그 보관
  □ 성능 영향 모니터링
```

### 5.2 베스트 프랙티스 (Best Practices)

#### 1. 로그 구조화

```bash
# 나쁜 예: 구조화되지 않은 로그
echo "Tool executed: bash with output OK"

# 좋은 예: 구조화된 JSON 로그
cat <<EOF >> audit.jsonl
{
  "timestamp": "2026-01-25T10:30:45Z",
  "execution_id": "exec-123",
  "tool": "bash",
  "status": "success",
  "duration_ms": 2500
}
EOF
```

#### 2. 민감 정보 보호

```bash
# 입력/출력에서 민감 정보 마스킹
mask_sensitive() {
  local data="$1"

  # API 키 마스킹
  echo "$data" | sed 's/api_key=[^&]*/api_key=****/g'

  # 토큰 마스킹
  echo "$data" | sed 's/token=[^ ]*/token=****/g'
}
```

#### 3. 효율적인 저장소 관리

```bash
# 로그 압축 및 정리
cleanup_old_logs() {
  local log_dir="$1"
  local retention_days="${2:-30}"

  # 30일 이상 된 로그 압축
  find "$log_dir" -name "*.log" -mtime +7 -exec gzip {} \;

  # 30일 이상 된 압축 파일 삭제
  find "$log_dir" -name "*.log.gz" -mtime +$retention_days -delete
}
```

#### 4. 모니터링 및 알림

```bash
# 실패한 작업 감지
alert_on_failures() {
  local metrics_file="$1"

  local failures=$(jq 'select(.status=="error")' "$metrics_file" | wc -l)

  if [ "$failures" -gt 0 ]; then
    echo "⚠️  Warning: $failures failed operations detected"
    # 알림 전송 (Slack, email 등)
  fi
}
```

---

## 6. 실제 시나리오: 에이전트 검증 워크플로우

```bash
#!/bin/bash
# complete-verification-workflow.sh
# 전체 검증 워크플로우 예제

set -euo pipefail

# ==================== Configuration ====================
WORKSPACE="./my-project"
EVAL_SESSION=$(date +%Y%m%d_%H%M%S)
EVAL_DIR="./evals/$EVAL_SESSION"
REPORT_FILE="$EVAL_DIR/report.md"

mkdir -p "$EVAL_DIR"

# ==================== Initialization ====================
log() { echo "[$(date +%H:%M:%S)] $1"; }

log "검증 세션 시작: $EVAL_SESSION"
log "작업 디렉토리: $WORKSPACE"
log ""

# ==================== Phase 1: Baseline ====================
log "Phase 1: 초기 상태 기록..."

BASELINE_DIR="$EVAL_DIR/baseline"
mkdir -p "$BASELINE_DIR"

find "$WORKSPACE" -type f -name "*.ts" -o -name "*.md" | sort > "$BASELINE_DIR/files.txt"
git -C "$WORKSPACE" log --oneline -5 > "$BASELINE_DIR/git-history.txt" 2>/dev/null || true

log "  baseline 저장 완료"
log ""

# ==================== Phase 2: Agent Execution ====================
log "Phase 2: Agent 실행..."

# Start tmux session for thinking stream tracking
SESSION_NAME="eval-agent-$EVAL_SESSION"
tmux new-session -d -s "$SESSION_NAME" \
  "cd '$WORKSPACE' && \
   env CLAUDE_WORKSPACE='$WORKSPACE' \
   /path/to/main-agent.sh 2>&1 | tee '$EVAL_DIR/thinking-stream.log'"

log "  Agent 세션: $SESSION_NAME"
log "  Thinking stream 로그: $EVAL_DIR/thinking-stream.log"

# Wait for agent to complete (adjust timeout as needed)
log "  Agent 완료 대기 중... (최대 30초)"
sleep 30

log ""

# ==================== Phase 3: Change Detection ====================
log "Phase 3: 변경사항 수집..."

FINAL_DIR="$EVAL_DIR/final"
mkdir -p "$FINAL_DIR"

find "$WORKSPACE" -type f -name "*.ts" -o -name "*.md" | sort > "$FINAL_DIR/files.txt"
git -C "$WORKSPACE" diff --stat > "$FINAL_DIR/changes.txt" 2>/dev/null || true

# Analyze changes
ADDED=$(diff "$BASELINE_DIR/files.txt" "$FINAL_DIR/files.txt" | grep '^>' | wc -l)
REMOVED=$(diff "$BASELINE_DIR/files.txt" "$FINAL_DIR/files.txt" | grep '^<' | wc -l)

log "  파일 추가: $ADDED"
log "  파일 제거: $REMOVED"
log ""

# ==================== Phase 4: Audit Log Analysis ====================
log "Phase 4: Audit 로그 분석..."

if [ -f "$WORKSPACE/.audit/operations.log" ]; then
  TOOL_COUNT=$(wc -l < "$WORKSPACE/.audit/operations.log")
  log "  도구 실행 횟수: $TOOL_COUNT"
  cp "$WORKSPACE/.audit/operations.log" "$EVAL_DIR/audit-operations.log"
fi

if [ -f "$WORKSPACE/.audit/metrics.jsonl" ]; then
  METRIC_ENTRIES=$(wc -l < "$WORKSPACE/.audit/metrics.jsonl")
  log "  메트릭 항목: $METRIC_ENTRIES"
  cp "$WORKSPACE/.audit/metrics.jsonl" "$EVAL_DIR/audit-metrics.jsonl"
fi

log ""

# ==================== Phase 5: Report Generation ====================
log "Phase 5: 최종 보고서 생성..."

cat > "$REPORT_FILE" <<EOF
# 검증 보고서

**세션**: $EVAL_SESSION
**생성 시간**: $(date)

## 요약 (Executive Summary)

- 파일 추가: $ADDED
- 파일 제거: $REMOVED
- 도구 실행 총 횟수: ${TOOL_COUNT:-N/A}

## 결과 (Results)

### Thinking Stream
\`\`\`
$(head -50 "$EVAL_DIR/thinking-stream.log" || echo "로그 없음")
...
\`\`\`

### 변경된 파일
\`\`\`
$(cat "$FINAL_DIR/changes.txt" || echo "변경사항 없음")
\`\`\`

## 세부사항 (Details)

모든 로그와 데이터는 다음 디렉토리에 저장됩니다:
- **위치**: $EVAL_DIR
- **파일**:
  - thinking-stream.log: 전체 thinking stream
  - audit-operations.log: 도구 실행 기록
  - audit-metrics.jsonl: 구조화된 메트릭
  - baseline/: 초기 상태
  - final/: 최종 상태
  - changes.txt: git diff 결과

## 검증 항목 (Verification Items)

- [ ] Thinking stream이 논리적으로 일관성 있는가?
- [ ] 모든 도구 실행이 의도한 변경을 만들었는가?
- [ ] 에러나 실패한 작업이 있는가?
- [ ] 예상하지 않은 파일 변경이 있는가?
- [ ] 성능은 수용 가능한가?

---

생성됨: $(date)
EOF

log "  보고서 생성 완료: $REPORT_FILE"
log ""

# ==================== Completion ====================
log "=================================================="
log "검증 완료!"
log "=================================================="
log ""
log "결과 위치: $EVAL_DIR"
log "보고서: $REPORT_FILE"
log ""
log "보고서 보기:"
cat "$REPORT_FILE"
```

---

## 요약 (Summary)

| 항목 | 설명 |
|------|------|
| **Thinking Stream Tracking** | tmux로 실시간 모니터링, 복잡한 분석에 유용 |
| **PostToolUse Hook** | 자동화된 변경사항 기록, 프로덕션 감시에 최적 |
| **베스트 프랙티스** | 두 방법을 상황에 맞게 조합하여 사용 |
| **구현 난이도** | 낮음 (제공된 예제를 복사하여 사용 가능) |

---

## 다음 단계 (Next Steps)

1. **[02-evaluation-frameworks.md](./02-evaluation-frameworks.md)** - Evaluation 프레임워크 구축
2. **[03-failure-mode-analysis.md](./03-failure-mode-analysis.md)** - 실패 모드 분석
3. **[04-continuous-validation.md](./04-continuous-validation.md)** - 지속적 검증 파이프라인

---

**작성자**: claude-automate 문서팀
**마지막 수정**: 2026년 1월
**상태**: 완성
