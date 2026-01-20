#!/bin/bash

# claude-automate Session Stop Hook
# Reminds user to run /wrap before ending session
# Output format: JSON { "continue": true, "message": "..." }

MESSAGE="<system-reminder>

[SESSION END REMINDER]

Consider running /wrap to:
• Check code patterns
• Analyze usage patterns
• Sync documentation
• Update context for next session

Type '/wrap' to run, or continue to exit.

</system-reminder>"

ESCAPED=$(echo "$MESSAGE" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')
echo "{\"continue\": true, \"message\": $ESCAPED}"
