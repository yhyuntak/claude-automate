#!/bin/bash

# Anchor Update Hook (Stop)
# Reminds Claude to update anchor if needed after each turn
# Output format: JSON with hookSpecificOutput.additionalContext

ANCHOR_FILE=".claude/anchor.md"

if [ -f "$ANCHOR_FILE" ]; then
    MESSAGE="<system-reminder>
[ANCHOR CHECK]
If this turn changed or clarified the goal, update .claude/anchor.md.
Keep it concise - just the current objective and any refinements.
</system-reminder>"

    ESCAPED=$(echo "$MESSAGE" | jq -Rs '.')
    echo "{\"continue\": true, \"hookSpecificOutput\": {\"hookEventName\": \"Stop\", \"additionalContext\": $ESCAPED}}"
else
    echo "{\"continue\": true}"
fi
