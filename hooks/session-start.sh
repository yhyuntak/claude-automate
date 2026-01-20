#!/bin/bash

# claude-automate Session Start Hook
# Loads context.md and displays session continuity information
# Output format: JSON { "continue": true, "message": "..." }

CONTEXT_FILE=".claude/context.md"

if [ -f "$CONTEXT_FILE" ]; then
    CONTENT=$(cat "$CONTEXT_FILE" | sed 's/"/\\"/g' | tr '\n' ' ')
    MESSAGE="<session-restore>

[CONTEXT LOADED]

Previous session context found:

---
$(cat "$CONTEXT_FILE")
---

💡 Run /wrap at the end of this session to update context

</session-restore>"

    # Escape for JSON
    ESCAPED=$(echo "$MESSAGE" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')
    echo "{\"continue\": true, \"message\": $ESCAPED}"
else
    echo '{"continue": true}'
fi
