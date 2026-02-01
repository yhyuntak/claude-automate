#!/bin/bash

# Anchor Show Hook (UserPromptSubmit)
# Displays current anchor to remind Claude of the session goal
# Output format: JSON with hookSpecificOutput.additionalContext

ANCHOR_FILE=".claude/anchor.md"

if [ -f "$ANCHOR_FILE" ]; then
    CONTENT=$(cat "$ANCHOR_FILE")

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
