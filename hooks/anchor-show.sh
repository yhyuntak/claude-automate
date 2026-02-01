#!/bin/bash

# Anchor Show Hook (UserPromptSubmit)
# Displays current anchor to remind Claude of the session goal
# Output format: JSON { "continue": true, "message": "..." }

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
    echo "{\"continue\": true, \"message\": $ESCAPED}"
else
    echo "{\"continue\": true}"
fi
