#!/bin/bash

# Anchor Show Hook (UserPromptSubmit)
# Displays current anchor to remind Claude of the session goal
# Output format: JSON with hookSpecificOutput.additionalContext

ANCHOR_FILE=".claude/anchor.md"

if [ -f "$ANCHOR_FILE" ]; then
    CONTENT=$(cat "$ANCHOR_FILE")

    # tmux 상태바에 앵커 표시 (tmux 서버 실행 중이면 동작)
    GOAL=$(sed -n '3p' "$ANCHOR_FILE" | head -c 40)
    tmux set -g status-right " 🎯 $GOAL " 2>/dev/null

    MESSAGE="<system-reminder>
┌─ 🎯 ANCHOR ─────────────────────────────────────────┐
${CONTENT}
└─────────────────────────────────────────────────────┘

Update .claude/anchor.md if the goal changes or becomes more specific.
</system-reminder>"

    ESCAPED=$(echo "$MESSAGE" | jq -Rs '.')
    echo "{\"continue\": true, \"hookSpecificOutput\": {\"hookEventName\": \"UserPromptSubmit\", \"additionalContext\": $ESCAPED}}"
else
    MESSAGE="<system-reminder>
[NO ANCHOR]
.claude/anchor.md가 없습니다.
사용자의 현재 목표를 파악해서 .claude/anchor.md를 생성해주세요.

형식:
# Anchor

{목표}

**Started**: {날짜}
</system-reminder>"

    ESCAPED=$(echo "$MESSAGE" | jq -Rs '.')
    echo "{\"continue\": true, \"hookSpecificOutput\": {\"hookEventName\": \"UserPromptSubmit\", \"additionalContext\": $ESCAPED}}"
fi
