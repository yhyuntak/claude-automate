# Memory Persistence Hooks

> 📌 **Note**: This document describes both the current implementation and the comprehensive architecture envisioned for full memory persistence. The current implementation includes the Stop hook; PreCompact and SessionStart hooks are designed and planned for future implementation as outlined in the session-context-system-plan.

## 핵심 개념 (Core Concepts)

Memory Persistence Hooks는 Claude와의 상호작용 생명주기(lifecycle) 동안 상태를 자동으로 저장하고 복구하는 메커니즘입니다. 이를 통해 session 간의 연속성을 유지하고, 중요한 상태 정보를 지속적으로 보존합니다.

### 세 가지 핵심 훅 (Three Core Hooks)

#### 1. **PreCompact Hook** - 컨텍스트 압축 전 처리

**언제 실행되는가?**
- Session이 장시간 진행되어 context 크기가 임계값을 초과할 때
- 개발자가 명시적으로 compact를 요청할 때

**역할**
- 현재 session의 상태를 스냅샷으로 저장
- 압축할 정보와 유지할 정보를 구분
- 중요한 메타데이터 추출 및 기록

**실행 결과**
```
Session State: {
  "timestamp": "2026-01-25T10:30:00Z",
  "context_size": 45000,
  "critical_decisions": [...],
  "work_summary": "..."
}
```

#### 2. **SessionStart Hook** - 세션 시작 시 상태 복구

**언제 실행되는가?**
- 새로운 session이 시작될 때 (plugin 초기화 시)
- 이전 session의 context를 복구할 필요가 있을 때

**역할**
- 이전 session의 저장된 상태를 찾아 로드
- Context를 재구성하여 현재 session에 주입
- Session 연속성 정보 업데이트

**실행 결과**
```
System Prompt Injection:
- Previous session context loaded
- State restored to: {last_checkpoint}
- Ready for continuation
```

#### 3. **Stop Hook** - 세션 종료 시 정리 및 저장

**언제 실행되는가?**
- User가 session을 종료하려고 할 때
- `/wrap` 커맨드 실행 전

**역할**
- 현재 session의 최종 상태를 저장
- Context 크기를 평가하고 압축 여부 결정
- 다음 session을 위한 준비 작업 수행
- User에게 `/wrap` 실행을 상기시킴

**실행 결과**
```
Session finalized:
- State snapshot saved (currently: reminder message)
- Compression recommendations generated (planned)
- Ready for session-end actions (/wrap)
```

> ✅ **현재 구현 상태**: Stop Hook은 currently implemented이며, user에게 `/wrap` 실행을 상기시키는 reminder message를 표시합니다. 추가 메타데이터 저장 기능은 향후 확장 예정입니다.

---

## 현재 구현 vs. 계획된 구현 (Current vs. Planned Implementation)

### 현재 상태 (Current)

| Hook | 상태 | 기능 |
|------|------|------|
| **PreCompact** | 🔜 Planned | Context 크기 모니터링 기반 자동 스냅샷 (미구현) |
| **SessionStart** | 🔜 Planned | 이전 session context 자동 로드 (미구현) |
| **Stop** | ✅ Implemented | User에게 `/wrap` 실행 reminder 표시 |

### 로드맵 (Roadmap)

```
Phase 1 (Current) ✅
└─ Stop Hook: Session 종료 시 /wrap reminder 표시

Phase 2 (Planned)
├─ SessionStart Hook: Previous session context 복구
├─ PreCompact Hook: Context 압축 전 스냅샷
└─ Comprehensive Hook Chain: 자동 메모리 관리

Phase 3 (Planned)
├─ Strategic Compact Integration: 스냅샷 기반 압축
├─ Metrics & Monitoring: Hook 성능 추적
└─ User Controls: 수동 hook 제어 옵션
```

---

## Session Lifecycle 다이어그램 (Plaintext)

```
┌─────────────────────────────────────────────────────────────────────┐
│                       SESSION LIFECYCLE                             │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────┐
│ Plugin Starts   │
└────────┬────────┘
         │
         v
    ┌──────────────────────────────────┐
    │  ⚡ SessionStart Hook Triggers   │
    │  - Load previous session context │
    │  - Restore state from checkpoint │
    │  - Inject into system prompt     │
    │  Status: Memory Restored         │
    └────────┬─────────────────────────┘
             │
             v
    ┌──────────────────────────────────┐
    │   🔄 Active Session Running      │
    │   - User work in progress        │
    │   - Context grows gradually      │
    │   - Monitoring context size      │
    └────────┬─────────────────────────┘
             │
    ┌────────┴──────────┬──────────────────┐
    │                   │                  │
    v                   v                  v
[Context < Limit]  [Context = Limit]  [Compact Requested]
    │                   │                  │
    └───────────────────┼──────────────────┘
                        │
                        v
    ┌──────────────────────────────────┐
    │ 🔶 PreCompact Hook Triggers      │
    │ - Snapshot current state         │
    │ - Identify critical info         │
    │ - Prepare for compression        │
    │ Status: Ready for Compacting     │
    └────────┬─────────────────────────┘
             │
             v
    ┌──────────────────────────────────┐
    │ 🗜️ Strategic Compacting          │
    │ - Run compression algorithm      │
    │ - Preserve critical decisions    │
    │ - Reduce context size            │
    └────────┬─────────────────────────┘
             │
             v
    ┌──────────────────────────────────┐
    │   ✅ Compacting Complete         │
    │   - New context ready            │
    │   - Session continues with new   │
    │     compressed context           │
    └────────┬─────────────────────────┘
             │
             v
    ┌──────────────────────────────────┐
    │   👤 User Ends Session (Stop)    │
    │   - Triggers /wrap or exit       │
    └────────┬─────────────────────────┘
             │
             v
    ┌──────────────────────────────────┐
    │ 🛑 Stop Hook Triggers            │
    │ - Check if /wrap needed          │
    │ - Evaluate compression needs     │
    │ - Save final state               │
    │ - Remind user to run /wrap       │
    │ Status: Ready for Finalization   │
    └────────┬─────────────────────────┘
             │
             v
    ┌──────────────────────────────────┐
    │ 📝 /wrap Execution               │
    │ - Rule checks performed          │
    │ - Documentation synced           │
    │ - Session context saved to:      │
    │   .claude/context/YYYY-MM/       │
    │   YYYY-MM-DD-{session-id}.md     │
    └────────┬─────────────────────────┘
             │
             v
    ┌──────────────────────────────────┐
    │ 💾 Session Archived              │
    │ - Context persisted              │
    │ - Ready for next session         │
    │ - Loop restarts at SessionStart  │
    └──────────────────────────────────┘
```

---

## 각 훅의 역할 상세 설명 (Detailed Hook Roles)

### 1. PreCompact Hook - "Before We Compress"

**목적 (Purpose)**

Session이 진행되면서 context window가 점점 커집니다. 이를 지능적으로 압축하기 전에, 현재 상태의 "스냅샷"을 저장하는 것이 중요합니다.

```
Session State Timeline:
├─ T1: Session Start (4KB context)
├─ T2: 30분 경과 (15KB context)
├─ T3: 60분 경과 (32KB context)  ← PreCompact Hook!
│       (Context limit 근처)
├─ T4: Compacting 실행
└─ T5: Session continues (8KB compressed context)
```

**PreCompact Hook 실행 내용**

```bash
#!/bin/bash
# pre-compact.sh - Snapshot before compression

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_ID=$(cat .claude/session_id)
CONTEXT_SIZE=$(wc -c < .claude/context.md)

# 현재 상태 스냅샷 저장
cat > .claude/snapshots/pre-compact-${TIMESTAMP}.json <<EOF
{
  "timestamp": "$TIMESTAMP",
  "session_id": "$SESSION_ID",
  "context_size_bytes": $CONTEXT_SIZE,
  "action": "pre_compact_snapshot",
  "checkpoint": {
    "last_decision": "...",
    "critical_files": [...],
    "important_findings": [...]
  }
}
EOF

# 이전 context 백업
cp .claude/context.md .claude/backups/context-${TIMESTAMP}.md

echo "✅ PreCompact snapshot created"
echo "   Location: .claude/snapshots/pre-compact-${TIMESTAMP}.json"
```

**역할**
- 현재 session의 중요한 상태를 메타데이터로 저장
- 압축 후에도 참조할 수 있는 "복구 포인트" 생성
- Compression이 필요한 이유와 현재 상황을 기록

---

### 2. SessionStart Hook - "Restore Previous Context"

**목적 (Purpose)**

새 session이 시작되면, 이전 session에서 수행한 작업을 복구해야 합니다. SessionStart Hook은 이 복구 과정을 자동화합니다.

```
New Session Timeline:
├─ Plugin Initialize (Clear context)
├─ SessionStart Hook Executes ← HERE
│  └─ Previous context restored
│     └─ System prompt injected
│        └─ Agent aware of history
└─ Session Ready for work
```

**SessionStart Hook 실행 내용**

```bash
#!/bin/bash
# session-start.sh - Restore context from previous session

# 1. 가장 최근 session context 파일 찾기
LATEST_CONTEXT=$(ls -t .claude/context/*/*.md 2>/dev/null | head -1)

if [ -z "$LATEST_CONTEXT" ]; then
  echo "No previous session found"
  exit 0
fi

# 2. Session ID 생성
SESSION_ID=$(date +%s | md5sum | cut -c1-6)
echo "$SESSION_ID" > .claude/session_id

# 3. Previous context 로드
PREVIOUS_CONTENT=$(cat "$LATEST_CONTEXT")

# 4. System prompt에 주입할 복구 정보 생성
RECOVERY_PROMPT=$(cat <<EOF
## Previous Session Context (Automatically Restored)

### Last Known State
\`\`\`
$PREVIOUS_CONTENT
\`\`\`

### Session Continuation
You are continuing from a previous session.
All prior decisions, findings, and context are available above.
EOF
)

# 5. 복구 정보를 임시 파일에 저장
echo "$RECOVERY_PROMPT" > .claude/recovery_prompt.txt

echo "✅ SessionStart: Context restored"
echo "   Previous session: $LATEST_CONTEXT"
echo "   Session ID: $SESSION_ID"
```

**역할**
- 이전 session 파일 탐색 (.claude/context/YYYY-MM/*.md)
- 현재 session ID 생성
- 복구된 context를 system prompt에 동적으로 주입
- Agent가 이전 결정사항과 진행 상황을 알게 함

**시스템 프롬프트 주입 예시 (System Prompt Injection Example)**

```markdown
## Session Continuation

Previous session summary:
- Date: 2026-01-24
- Work: Implemented memory persistence hooks
- Status: Documentation in progress
- Next: Complete examples and verification

You are continuing work from above session.
Maintain consistency with previous decisions.
```

---

### 3. Stop Hook - "Prepare for Session End"

**목적 (Purpose)**

User가 session을 종료하려고 할 때, 마지막 정리 작업을 수행합니다. Stop Hook은 `/wrap`을 실행하기 전 중요한 상태 저장을 담당합니다.

```
Session End Timeline:
├─ User triggers exit/stop
├─ Stop Hook Executes ← HERE
│  ├─ Evaluate context size
│  ├─ Save final state
│  └─ Remind to run /wrap
└─ Plugin shuts down
```

**Stop Hook 실행 내용**

```bash
#!/bin/bash
# session-stop.sh - Finalize session before exit

SESSION_ID=$(cat .claude/session_id 2>/dev/null || echo "unknown")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 1. 현재 context 크기 확인
if [ -f .claude/context.md ]; then
  CONTEXT_SIZE=$(wc -c < .claude/context.md)
  CONTEXT_KB=$((CONTEXT_SIZE / 1024))
else
  CONTEXT_KB=0
fi

# 2. Compression 필요 여부 판단
NEEDS_COMPRESSION=false
if [ $CONTEXT_KB -gt 40 ]; then
  NEEDS_COMPRESSION=true
fi

# 3. 종료 상태 기록
cat > .claude/session-end-${SESSION_ID}.json <<EOF
{
  "timestamp": "$TIMESTAMP",
  "session_id": "$SESSION_ID",
  "context_size_kb": $CONTEXT_KB,
  "needs_compression": $NEEDS_COMPRESSION,
  "action": "session_stop"
}
EOF

# 4. User에게 /wrap 실행 안내
MESSAGE=$(cat <<'EOF'
<system-reminder>

[SESSION END REMINDER]

Consider running /wrap to:
• Check code patterns
• Analyze usage patterns
• Sync documentation
• Update context for next session

Type '/wrap' to run, or continue to exit.

EOF
)

# JSON 포맷으로 반환 (plugin hook 프로토콜)
ESCAPED=$(echo "$MESSAGE" | jq -Rs '.')
echo "{\"continue\": true, \"message\": $ESCAPED}"
```

**역할**
- 현재 session의 context 크기 측정
- Compression 필요 여부 판단
- 최종 상태를 메타데이터로 저장
- User에게 `/wrap` 실행을 상기시킴
- Plugin의 graceful shutdown 준비

**Stop Hook 출력 포맷**

```json
{
  "continue": true,
  "message": "[SESSION END REMINDER]\n\nConsider running /wrap to:\n• Check code patterns\n..."
}
```

---

## JSON 설정 전체 코드 (Complete JSON Configuration)

> 📋 **Note**: The JSON configuration below shows the comprehensive, planned architecture. The current `hooks/hooks.json` contains only the Stop hook. Use this as a reference for implementing the additional hooks in future phases.

### `hooks/hooks.json` - Hook 시스템 설정

```json
{
  "description": "claude-automate session hooks - Memory persistence configuration",
  "version": "1.0.0",
  "hooks": {
    "PreCompact": [
      {
        "name": "pre-compact-snapshot",
        "matcher": "*",
        "enabled": true,
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/pre-compact.sh",
            "timeout": 3000,
            "retry": {
              "max_attempts": 2,
              "backoff_ms": 500
            }
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "name": "session-start-recovery",
        "matcher": "*",
        "enabled": true,
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh",
            "timeout": 2000,
            "inject_result": "system_prompt",
            "retry": {
              "max_attempts": 1
            }
          }
        ]
      }
    ],
    "Stop": [
      {
        "name": "session-stop-finalize",
        "matcher": "*",
        "enabled": true,
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-stop.sh",
            "timeout": 5000,
            "continue_on_error": true
          }
        ]
      }
    ]
  },
  "config": {
    "compression": {
      "enabled": true,
      "threshold_kb": 40,
      "aggressive_threshold_kb": 60
    },
    "snapshots": {
      "enabled": true,
      "retention_days": 30,
      "max_snapshots": 20
    },
    "session_tracking": {
      "enabled": true,
      "session_id_length": 6,
      "timestamp_format": "ISO8601"
    }
  }
}
```

### 설정 구조 설명

| 섹션 | 목적 | 설명 |
|------|------|------|
| `hooks` | Hook 등록 | 세 가지 lifecycle 단계의 hook 정의 |
| `PreCompact` | 압축 전 처리 | Context 크기 임계값 근처에서 실행 |
| `SessionStart` | 복구 단계 | 새 session 시작 시 이전 상태 복구 |
| `Stop` | 정리 단계 | Session 종료 시 최종 처리 |
| `timeout` | 실행 제한시간 | 밀리초(ms) 단위로 설정 |
| `config` | 전역 설정 | Compression 임계값, snapshot 보관 등 |

---

## 각 스크립트가 하는 일 (Script Responsibilities)

### 1. pre-compact.sh - 압축 전 스냅샷

**파일 위치**: `hooks/pre-compact.sh`

**주요 기능**

```bash
#!/bin/bash
# pre-compact.sh: Context compression 직전 상태 저장

set -e

# 기본 변수 설정
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-.}"
CONTEXT_DIR=".claude/context"
SNAPSHOTS_DIR=".claude/snapshots"
BACKUPS_DIR=".claude/backups"

# 1️⃣ 디렉토리 초기화
mkdir -p "$SNAPSHOTS_DIR" "$BACKUPS_DIR"

# 2️⃣ 타임스탐프 및 세션 ID 생성
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TIMESTAMP_SHORT=$(date -u +"%Y%m%d-%H%M%S")
SESSION_ID=$(cat .claude/session_id 2>/dev/null || echo "unknown")

# 3️⃣ 현재 context 분석
if [ -f .claude/context.md ]; then
  CONTEXT_SIZE=$(wc -c < .claude/context.md)
  CONTEXT_LINES=$(wc -l < .claude/context.md)
  CONTEXT_KB=$((CONTEXT_SIZE / 1024))
else
  CONTEXT_SIZE=0
  CONTEXT_LINES=0
  CONTEXT_KB=0
fi

# 4️⃣ 중요 정보 추출 (frontmatter 파싱)
if [ -f .claude/context.md ]; then
  # Markdown YAML frontmatter에서 중요 데이터 추출
  LAST_SESSION=$(grep -m1 "^## Session" .claude/context.md | \
                 sed 's/## Session: //' || echo "unknown")
  CRITICAL_COUNT=$(grep -c "^### Critical" .claude/context.md || echo "0")
fi

# 5️⃣ 현재 git 상태 포함
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# 6️⃣ 스냅샷 JSON 생성
cat > "${SNAPSHOTS_DIR}/pre-compact-${TIMESTAMP_SHORT}-${SESSION_ID}.json" <<EOF
{
  "metadata": {
    "timestamp": "$TIMESTAMP",
    "session_id": "$SESSION_ID",
    "action": "pre_compact_snapshot"
  },
  "context": {
    "size_bytes": $CONTEXT_SIZE,
    "size_kb": $CONTEXT_KB,
    "lines": $CONTEXT_LINES
  },
  "git": {
    "branch": "$GIT_BRANCH",
    "commit": "$GIT_COMMIT"
  },
  "analysis": {
    "last_session": "$LAST_SESSION",
    "critical_items_count": $CRITICAL_COUNT
  },
  "recommendation": {
    "compress": $([ $CONTEXT_KB -gt 40 ] && echo "true" || echo "false"),
    "aggressive_compress": $([ $CONTEXT_KB -gt 60 ] && echo "true" || echo "false")
  }
}
EOF

# 7️⃣ Context 백업 생성
cp .claude/context.md "${BACKUPS_DIR}/context-${TIMESTAMP_SHORT}.md.bak"

# 8️⃣ 로그 기록
echo "[$(date)] PreCompact Hook: Context size=${CONTEXT_KB}KB, " \
  "Snapshots saved, Backup created" >> .claude/hooks.log

# 9️⃣ 성공 메시지
echo "✅ PreCompact Hook Complete"
echo "   Snapshot: ${SNAPSHOTS_DIR}/pre-compact-${TIMESTAMP_SHORT}-${SESSION_ID}.json"
echo "   Context Size: ${CONTEXT_KB}KB"
echo "   Needs Compression: $([ $CONTEXT_KB -gt 40 ] && echo 'YES' || echo 'NO')"

exit 0
```

**핵심 역할**

| 단계 | 작업 | 저장 위치 |
|------|------|---------|
| 1 | Context 크기 측정 | 메모리 (JSON에 기록) |
| 2 | 중요 정보 추출 | Snapshot JSON |
| 3 | Git 상태 캡처 | Snapshot JSON |
| 4 | Compression 추천 | Snapshot JSON (true/false) |
| 5 | Context 백업 | `.claude/backups/` |
| 6 | 로그 기록 | `.claude/hooks.log` |

---

### 2. session-start.sh - 세션 복구

**파일 위치**: `hooks/session-start.sh`

**주요 기능**

```bash
#!/bin/bash
# session-start.sh: 이전 session context 복구 및 주입

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-.}"
CONTEXT_DIR=".claude/context"

# 1️⃣ 새 세션 ID 생성
SESSION_ID=$(date +%s | md5sum | cut -c1-6)
echo "$SESSION_ID" > .claude/session_id
echo "$SESSION_ID" > .claude/current_session_id

# 2️⃣ 이전 session 파일 검색 (최신순)
PREVIOUS_SESSION=$(find "$CONTEXT_DIR" -name "*.md" -type f \
                  2>/dev/null | sort -r | head -1)

if [ -z "$PREVIOUS_SESSION" ]; then
  # 이전 session이 없는 경우 - 새로운 시작
  echo "🆕 New session started (no previous context found)"
  echo "   Session ID: $SESSION_ID"
  echo "{\"new_session\": true, \"session_id\": \"$SESSION_ID\"}"
  exit 0
fi

# 3️⃣ 이전 context 읽기
if [ ! -f "$PREVIOUS_SESSION" ]; then
  echo "⚠️  Session file not readable: $PREVIOUS_SESSION"
  exit 1
fi

PREVIOUS_CONTENT=$(cat "$PREVIOUS_SESSION")
PREVIOUS_SESSION_NAME=$(basename "$PREVIOUS_SESSION")

# 4️⃣ 복구 정보를 system prompt 친화적 형식으로 생성
RECOVERY_SECTION=$(cat <<'EOF'
## 🔄 Session Continuation - Automatic Context Recovery

### Previous Session Information
EOF
)

# 5️⃣ 이전 session에서 중요한 부분 추출
# (최대 3000자로 제한하여 token 절약)
CONTEXT_PREVIEW=$(echo "$PREVIOUS_CONTENT" | \
                  head -100 | \
                  tail -50)

RECOVERY_PROMPT="${RECOVERY_SECTION}

**Previous Session File**: ${PREVIOUS_SESSION_NAME}

\`\`\`markdown
${CONTEXT_PREVIEW}
\`\`\`

---

### Important Notes for This Session
1. You are **continuing from a previous session**
2. All prior context, decisions, and work are available above
3. Maintain consistency with previous session decisions
4. If uncertain about previous state, ask the user for clarification
"

# 6️⃣ 복구 정보를 임시 파일로 저장 (system prompt injection용)
RECOVERY_FILE=".claude/recovery_prompt.txt"
echo "$RECOVERY_PROMPT" > "$RECOVERY_FILE"

# 7️⃣ 세션 시작 로그 기록
echo "[$(date)] SessionStart Hook: Previous session=${PREVIOUS_SESSION_NAME}, " \
  "New session ID=${SESSION_ID}" >> .claude/hooks.log

# 8️⃣ Hook 결과 반환
# (Plugin이 이 JSON을 해석하여 system prompt에 주입)
cat <<RESULT
{
  "session_started": true,
  "session_id": "$SESSION_ID",
  "previous_session": "$PREVIOUS_SESSION_NAME",
  "recovery_prompt_file": "$RECOVERY_FILE",
  "inject_into_system_prompt": true,
  "recovery_content_preview": "Context recovered from previous session"
}
RESULT

exit 0
```

**핵심 역할**

| 단계 | 작업 | 영향 |
|------|------|------|
| 1 | Session ID 생성 | 현재 session 식별 |
| 2 | 이전 session 파일 탐색 | `.claude/context/YYYY-MM/*.md` |
| 3 | Context 로드 | 이전 상태 읽기 |
| 4 | System prompt 포맷 생성 | Agent가 이해 가능한 형식 |
| 5 | Token 최적화 | 처음 100줄 중 뒤의 50줄만 사용 |
| 6 | 임시 파일 저장 | Plugin이 주입 가능하도록 |
| 7 | 로그 기록 | Audit trail 유지 |
| 8 | JSON 반환 | Plugin hook 프로토콜 준수 |

---

### 3. session-stop.sh - 세션 종료 정리

**파일 위치**: `hooks/session-stop.sh`

**주요 기능**

```bash
#!/bin/bash
# session-stop.sh: Session 종료 시 최종 처리 및 정리

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-.}"

# 1️⃣ 현재 session 정보 읽기
SESSION_ID=$(cat .claude/session_id 2>/dev/null || echo "unknown")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TIMESTAMP_SHORT=$(date -u +"%Y%m%d-%H%M%S")

# 2️⃣ Context 크기 평가
CONTEXT_SIZE=0
CONTEXT_KB=0
if [ -f .claude/context.md ]; then
  CONTEXT_SIZE=$(wc -c < .claude/context.md)
  CONTEXT_KB=$((CONTEXT_SIZE / 1024))
fi

# 3️⃣ 작업 시간 계산 (optional)
if [ -f .claude/session_start_time ]; then
  START_TIME=$(cat .claude/session_start_time)
  END_TIME=$(date +%s)
  DURATION=$((END_TIME - START_TIME))
  DURATION_MIN=$((DURATION / 60))
else
  DURATION_MIN=0
fi

# 4️⃣ Compression 필요 여부 판단
NEEDS_COMPRESSION=false
NEEDS_AGGRESSIVE_COMPRESSION=false

if [ $CONTEXT_KB -gt 40 ]; then
  NEEDS_COMPRESSION=true
fi
if [ $CONTEXT_KB -gt 60 ]; then
  NEEDS_AGGRESSIVE_COMPRESSION=true
fi

# 5️⃣ 종료 상태 메타데이터 저장
mkdir -p .claude/session-end-logs

cat > ".claude/session-end-logs/session-${TIMESTAMP_SHORT}-${SESSION_ID}.json" <<EOF
{
  "metadata": {
    "timestamp": "$TIMESTAMP",
    "session_id": "$SESSION_ID",
    "action": "session_stop"
  },
  "session_duration": {
    "minutes": $DURATION_MIN,
    "seconds": $DURATION
  },
  "context_state": {
    "size_bytes": $CONTEXT_SIZE,
    "size_kb": $CONTEXT_KB
  },
  "recommendations": {
    "needs_compression": $NEEDS_COMPRESSION,
    "needs_aggressive_compression": $NEEDS_AGGRESSIVE_COMPRESSION,
    "wrap_recommended": true
  }
}
EOF

# 6️⃣ 최종 상태 로그 기록
echo "[$(date)] SessionStop Hook: Session ID=${SESSION_ID}, " \
  "Duration=${DURATION_MIN}min, " \
  "ContextSize=${CONTEXT_KB}KB, " \
  "Compression=${NEEDS_COMPRESSION}" >> .claude/hooks.log

# 7️⃣ User에게 /wrap 실행 안내 메시지
MESSAGE=$(cat <<'EOF'
<system-reminder>

[SESSION END REMINDER]

Consider running /wrap to:
• Check code patterns
• Analyze usage patterns
• Sync documentation
• Update context for next session

Type '/wrap' to run, or continue to exit.

</system-reminder>
EOF
)

# 8️⃣ 메시지를 JSON으로 포맷팅
# (Plugin hook protocol requires JSON response with "continue" field)
ESCAPED=$(echo "$MESSAGE" | jq -Rs '.')

cat <<RESULT
{
  "continue": true,
  "message": $ESCAPED,
  "metadata": {
    "session_id": "$SESSION_ID",
    "context_kb": $CONTEXT_KB,
    "needs_compression": $NEEDS_COMPRESSION
  }
}
RESULT

exit 0
```

**핵심 역할**

| 단계 | 작업 | 저장 |
|------|------|-----|
| 1 | Session 정보 로드 | 메모리 |
| 2 | Context 크기 측정 | 메타데이터 JSON |
| 3 | 작업 시간 계산 | 메타데이터 JSON |
| 4 | Compression 판단 | 메타데이터 JSON (true/false) |
| 5 | 종료 상태 저장 | `.claude/session-end-logs/*.json` |
| 6 | 로그 업데이트 | `.claude/hooks.log` |
| 7 | User 메시지 생성 | Plugin에 전달 |
| 8 | JSON 응답 | Plugin hook protocol 준수 |

---

## Hook Chain을 통한 자동 메모리 관리 (Hook Chaining for Automated Memory Management)

### Hook Chain 흐름도 (Flow)

```
Session Lifecycle에서의 Hook Chain:

NEW SESSION
    ↓
┌─────────────────────────────────────────┐
│ 🔄 SessionStart Hook Executes           │
│                                         │
│ 1. 이전 session 파일 탐색              │
│ 2. Session ID 생성                      │
│ 3. Recovery prompt 생성                 │
│ 4. System prompt에 주입                 │
│ 5. Agent가 previous context 인식       │
└─────────────────────────────────────────┘
    ↓
WORKING (Session in progress)
    ↓
    ├─ Normal case: Context < 40KB ────────────┐
    │                                          │
    └─ Large context: Context >= 40KB ──────┐  │
                                             │  │
                    ┌────────────────────────┘  │
                    ↓                           │
        ┌─────────────────────────────────────┐│
        │ 🔶 PreCompact Hook Executes         ││
        │                                     ││
        │ 1. Context 크기 측정               ││
        │ 2. Snapshot 생성                    ││
        │ 3. Critical info 추출              ││
        │ 4. Backup 생성                      ││
        │ 5. Compression 추천 설정           ││
        └─────────────────────────────────────┘│
                     ↓                         │
        ┌─────────────────────────────────────┐│
        │ 🗜️ Compacting 실행                  ││
        │ (Strategic Compact skill)            ││
        │                                     ││
        │ 1. Important info 우선순위 지정    ││
        │ 2. Context 압축 알고리즘 실행      ││
        │ 3. New compressed context 생성     ││
        └─────────────────────────────────────┘│
                     ↓                         │
        ┌─────────────────────────────────────┐│
        │ ✅ Session continues                ││
        │    with new context                 ││
        └─────────────────────────────────────┘│
                                             │
└──────────────────────────────────────────┘

END SESSION
    ↓
┌─────────────────────────────────────────┐
│ 🛑 Stop Hook Executes                   │
│                                         │
│ 1. Final context size 측정            │
│ 2. Session end 메타데이터 저장         │
│ 3. Compression 필요 여부 판단          │
│ 4. /wrap 실행 안내                     │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│ 📝 /wrap 실행 (Manual)                  │
│                                         │
│ 1. Code pattern 검사                   │
│ 2. Documentation sync                   │
│ 3. Session context 저장                │
│    → .claude/context/YYYY-MM/          │
│       YYYY-MM-DD-{id}.md               │
└─────────────────────────────────────────┘
    ↓
NEXT SESSION ← Loop restarts at SessionStart
```

### Chain 메커니즘 (Chaining Mechanism)

Hook chain은 여러 훅이 순차적으로 또는 조건부로 실행되는 메커니즘입니다:

```json
{
  "hook_chain_rules": {
    "pre_compact_to_compact": {
      "trigger": "PreCompact hook completes with compression_needed=true",
      "action": "Automatically start Strategic Compact skill",
      "data_passed": ["snapshot_json", "context_size_kb", "critical_items"],
      "timeout": 5000
    },
    "session_start_to_dynamic_prompt": {
      "trigger": "SessionStart hook completes",
      "action": "Inject recovery_prompt into system prompt",
      "data_passed": ["recovery_prompt_file", "session_id", "previous_context"],
      "timing": "Before first user message"
    },
    "stop_to_wrap_reminder": {
      "trigger": "Stop hook completes",
      "action": "Display /wrap reminder to user",
      "data_passed": ["session_id", "context_kb", "needs_compression"],
      "continue_session": true
    }
  }
}
```

### Hook Chain 사례 (Use Cases)

#### Case 1: Normal Short Session
```
SessionStart → Work for 20 minutes → Stop Hook → User runs /wrap
├─ SessionStart: Context restored (5KB)
├─ Working: User develops code
├─ Stop Hook: Context size check (8KB - no compression needed)
└─ /wrap: Session saved

Duration: < 45 minutes
Context growth: 5KB → 8KB
Action: No PreCompact triggered
```

#### Case 2: Long Session with Compression
```
SessionStart → Work for 2 hours → PreCompact → Compacting → Continue → Stop → /wrap
├─ SessionStart: Context restored (5KB)
├─ Working: Continuous development
│  ├─ After 60min: Context = 32KB
│  ├─ After 90min: Context = 48KB ← PreCompact triggered!
│  │  ├─ Snapshot created
│  │  ├─ Backup made
│  │  └─ Compacting started
│  ├─ After compression: Context = 12KB
│  └─ Continue working
├─ After 120min: Stop Hook triggered
└─ /wrap executed

Duration: > 2 hours
Context growth: 5KB → 48KB → 12KB
Actions: PreCompact + Compacting
Result: Session continues with fresh context
```

#### Case 3: Critical Decision Point
```
SessionStart → Work → Decision needed → Manual PreCompact → Continue
├─ SessionStart: Previous context injected
├─ User makes important decision
├─ User manually requests PreCompact
│  ├─ Snapshot records the decision
│  ├─ Context backed up
│  └─ Ready to compress if needed
└─ Continue working with decision preserved

Duration: Variable
Context: Preserved at critical point
Action: Manual hook trigger
```

### 자동 메모리 관리의 5 단계 (5 Steps of Automated Memory Management)

```
Step 1: MONITOR
├─ Continuously track context size
├─ Compare against thresholds (40KB, 60KB)
└─ Ready to trigger hooks

Step 2: CAPTURE (PreCompact)
├─ Take snapshot of current state
├─ Identify critical information
├─ Create backup
└─ Prepare compression metadata

Step 3: COMPRESS
├─ Apply strategic compacting algorithm
├─ Preserve critical decisions
├─ Remove verbose repetitions
└─ Optimize context tokens

Step 4: RESTORE (SessionStart)
├─ Load compressed context at session start
├─ Identify previous session info
├─ Inject into system prompt
└─ Agent resumes work

Step 5: FINALIZE (Stop + /wrap)
├─ Measure final state
├─ Save session to file
├─ Generate recommendations
└─ Ready for next session
```

---

## 통합 예제 (Integration Example)

### 시나리오: 2시간 개발 세션

**Timeline:**

```
10:00 AM - 새 세션 시작
  ↓
  SessionStart Hook 실행
  ├─ 이전 세션 파일 로드: session-2026-01-24-abc123.md
  ├─ Session ID 생성: def456
  ├─ Recovery prompt 생성
  └─ System prompt 주입 완료

  [Previous session context]
  - Implemented user authentication
  - Next: Add authorization layer

10:05 AM - 개발 시작

10:45 AM - Context size: 25KB (정상)

11:15 AM - Context size: 38KB (근접)

11:30 AM - Context size: 43KB (임계값 초과!) ⚠️
  ↓
  PreCompact Hook 실행
  ├─ Snapshot 생성
  │  ├─ Context size: 43KB
  │  ├─ Critical items: 7개
  │  └─ Git commit: xyz789
  ├─ Backup 생성: context-20260125-1130.md.bak
  └─ Compacting 권장

  Strategic Compact 실행
  ├─ Important decisions 우선순위 지정
  ├─ Verbose logs 제거
  ├─ 중복 정보 병합
  └─ New context: 11KB

11:32 AM - Session continues with new context

12:00 PM - 추가 개발 (context: 18KB)

12:30 PM - 세션 종료 시도
  ↓
  Stop Hook 실행
  ├─ Final context size: 19KB
  ├─ Duration: 150 minutes
  ├─ Session end log 저장
  ├─ Compression 불필요 (< 40KB)
  └─ /wrap 실행 권장

12:31 PM - User runs /wrap
  ├─ Code pattern 검사
  ├─ Documentation sync
  └─ Session saved: .claude/context/2026-01/2026-01-25-def456.md

12:32 PM - Session complete!
```

**저장된 파일들:**

```
.claude/
├── context.md (현재 working context)
├── session_id (현재: def456)
├── hooks.log
├── snapshots/
│   └── pre-compact-20260125-1130-def456.json
│       {
│         "context_kb": 43,
│         "compression": true,
│         "critical_items": 7
│       }
├── backups/
│   └── context-20260125-1130.md.bak
├── session-end-logs/
│   └── session-20260125-1230-def456.json
│       {
│         "duration_min": 150,
│         "context_kb": 19,
│         "compression_needed": false
│       }
└── context/2026-01/
    ├── 2026-01-24-abc123.md (이전 세션)
    └── 2026-01-25-def456.md (현재 세션 - /wrap으로 저장됨)
```

---

## 핵심 요약 (Key Takeaways)

| 훅 | 실행 시점 | 주요 역할 | 저장 위치 |
|------|---------|---------|---------|
| **PreCompact** | Context >= 40KB | 압축 전 상태 스냅샷 저장 | `.claude/snapshots/` |
| **SessionStart** | 새 세션 시작 | 이전 context 복구 및 주입 | Recovery prompt |
| **Stop** | 세션 종료 전 | 최종 상태 저장 및 /wrap 안내 | `.claude/session-end-logs/` |

### Hook Chain 자동화 흐름

```
Session Start ──→ Load previous context
    ↓
Monitoring ──→ Track context size
    ↓
Large context? ──→ PreCompact ──→ Compacting ──→ Continue
    ↓
Session End ──→ Stop Hook ──→ Remind /wrap ──→ Save session
    ↓
Next session uses preserved context
```

### 메모리 관리의 이점 (Benefits)

- ✅ **연속성**: 세션 간 작업 내용 자동 복구
- ✅ **효율성**: Context 크기 자동 모니터링 및 최적화
- ✅ **신뢰성**: 중요한 결정사항 백업 및 스냅샷
- ✅ **자동화**: 수동 개입 없는 메모리 관리
- ✅ **투명성**: 모든 상태 변화가 로그에 기록

---

## 다음 단계 (Next Steps)

1. **[Strategic Compacting](./02-strategic-compacting.md)** - Context 압축 전략 학습
2. **[Strategic Compact Skill](./03-strategic-compact-skill.md)** - 실제 구현 이해
3. **[Continuous Learning](./06-continuous-learning.md)** - 학습 기록 자동화

---

**작성자**: claude-automate 문서팀
**마지막 수정**: 2026년 1월
**상태**: 완성
