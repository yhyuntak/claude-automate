#!/bin/bash

# POC: Context Bridge + Skill Trigger via Stop Hook
# statusline → /tmp file → hook → stderr → Claude → skill

INPUT=$(cat)

# 무한루프 방지
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_ACTIVE" = "true" ]; then
  exit 0
fi

# Read context percentage from statusline bridge file
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')
CTX_PCT=$(cat /tmp/claude-context-pct-${SESSION_ID} 2>/dev/null || echo 0)

# 80% 이상 → exit 2로 차단 + 스킬 실행 지시
if [ "$CTX_PCT" -ge 80 ]; then
  echo "컨텍스트가 ${CTX_PCT}%입니다. /test-hook 스킬을 실행하세요." >&2
  exit 2
fi

exit 0
