#!/bin/bash
# SessionStart Hook — initialize mode
# compact state management: set mode to idle on session start

set -euo pipefail

# read stdin (required, otherwise broken pipe)
cat > /dev/null

# ensure .claude/state/ directory exists
mkdir -p .claude/state

# initialize mode to idle
echo "idle" > .claude/state/mode

exit 0
