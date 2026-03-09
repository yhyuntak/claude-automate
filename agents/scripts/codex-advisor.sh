#!/bin/bash
# codex-advisor.sh — Codex CLI headless call with embedded system prompt
# Role: Code Quality & Bug Detection Expert
# Usage: ./codex-advisor.sh "user prompt" [project_path]

# CLI check
if ! command -v codex &> /dev/null; then
  echo "ERROR: Codex CLI not found. Run: npm install -g @openai/codex" >&2
  exit 1
fi

SYSTEM_PROMPT="You are a senior software engineer specializing in code quality and bug detection.

Your strengths:
- Bug detection and root cause analysis (with line numbers)
- Code review focusing on logic errors, edge cases, race conditions
- Performance bottleneck identification
- Security vulnerability detection
- Architecture anti-pattern recognition
- Test coverage gap analysis

When analyzing code:
1. Read the actual source files in the project
2. Find bugs, logic errors, and edge cases with specific file:line references
3. Suggest fixes with clear reasoning
4. Prioritize issues by severity

Always respond in Korean (한국어)."

USER_PROMPT="$1"
PROJECT_PATH="${2:-$PWD}"

cd "$PROJECT_PATH" || exit 1

# Timeout (default 60s, override with ADVISOR_TIMEOUT env var)
TIMEOUT="${ADVISOR_TIMEOUT:-60}"

# Execute with timeout, separate stderr
RESULT=$(timeout "${TIMEOUT}" codex exec --skip-git-repo-check "${SYSTEM_PROMPT}

${USER_PROMPT}" 2>/tmp/codex-advisor-stderr.txt)
EXIT_CODE=$?

# Error handling
if [ $EXIT_CODE -eq 124 ]; then
  echo "ERROR: Timeout: No response within ${TIMEOUT}s" >&2
  exit 1
elif [ $EXIT_CODE -ne 0 ]; then
  STDERR_CONTENT=$(cat /tmp/codex-advisor-stderr.txt 2>/dev/null)
  if echo "$STDERR_CONTENT" | grep -qi "auth\|login\|credential\|token\|api.key"; then
    echo "ERROR: Authentication required. Run: codex (interactive mode to re-login)" >&2
  else
    echo "ERROR: Codex CLI failed (exit code: $EXIT_CODE)" >&2
  fi
  exit 1
fi

echo "$RESULT"
