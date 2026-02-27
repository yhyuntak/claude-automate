#!/bin/bash
# PreCompact Hook — inject state message before compact
# reads mode and passes appropriate systemMessage to Claude

set -euo pipefail

# read stdin
cat > /dev/null

# read mode file (default: idle)
MODE="idle"
if [ -f ".claude/state/mode" ]; then
  MODE=$(cat .claude/state/mode 2>/dev/null || echo "idle")
fi

# build systemMessage per mode
case "$MODE" in
  "implement")
    # find in_progress plan file
    PLAN=$(grep -rl "^status: in_progress" .claude/plans/*.md 2>/dev/null | head -1 || true)
    if [ -n "$PLAN" ]; then
      MSG="/implement was in progress.\\nPlan: ${PLAN}\\n→ Read the plan file and continue implementing from the first incomplete AC([ ])."
    else
      MSG=""
    fi
    ;;
  "planning")
    MSG="/planning was in progress.\\n→ Continue the planning session with the user."
    ;;
  *)
    MSG=""
    ;;
esac

# output JSON
printf '{"continue": true, "systemMessage": "%s"}\n' "$MSG"

exit 0
