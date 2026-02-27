#!/bin/bash
# Stop Hook — test validation
# Harness 2.0 operation script

set -euo pipefail

INPUT=$(cat)

# --- prevent infinite loop ---
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_ACTIVE" = "true" ]; then
  exit 0
fi

# --- 1. test validation ---
# read test-command from in_progress plan file
PLANS_DIR=".claude/plans"
if [[ -d "$PLANS_DIR" ]]; then
  for plan_file in "$PLANS_DIR"/*.md; do
    [[ -f "$plan_file" ]] || continue

    # check status from frontmatter
    status=$(grep -m1 '^status:' "$plan_file" | sed 's/status: *//')
    if [[ "$status" == "in_progress" ]]; then
      # read test-command
      test_cmd=$(grep -m1 '^test-command:' "$plan_file" | sed 's/test-command: *//')
      if [[ -n "$test_cmd" && "$test_cmd" != "null" ]]; then
        # run test
        if ! eval "$test_cmd" > /dev/null 2>&1; then
          echo "Test failed. Fix the issues and try again. (command: $test_cmd)" >&2
          exit 2
        fi
      fi
      break  # process only the first in_progress plan
    fi
  done
fi
# --- 2. pass ---
exit 0
