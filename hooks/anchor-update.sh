#!/bin/bash

# Anchor Update Hook (Stop)
# Reminds Claude to update anchor if needed after each turn
# Stop hook uses simple format (no hookSpecificOutput)

ANCHOR_FILE=".claude/anchor.md"

# Stop hook doesn't support hookSpecificOutput, just pass through
echo "{\"continue\": true}"
