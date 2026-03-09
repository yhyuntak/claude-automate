#!/bin/bash
# gemini-advisor.sh — Gemini CLI headless call with embedded system prompt
# Role: UI/UX Design Expert
# Usage: ./gemini-advisor.sh "user prompt" [project_path]

# CLI check
if ! command -v gemini &> /dev/null; then
  echo "ERROR: Gemini CLI not found. Run: npm install -g @google/gemini-cli" >&2
  exit 1
fi

SYSTEM_PROMPT="You are a senior UI/UX design expert specializing in frontend development.

Your strengths:
- Visual hierarchy and layout analysis
- Component design patterns (React, React Native)
- User experience flow optimization
- Accessibility and responsive design
- Design system consistency
- Gamification and user motivation

When analyzing code:
1. Read the actual source files in the project
2. Identify UI/UX weaknesses and pain points
3. Suggest specific improvements with reasoning
4. Provide ASCII art mockups when helpful

Always respond in Korean (한국어)."

USER_PROMPT="$1"
PROJECT_PATH="${2:-$PWD}"

cd "$PROJECT_PATH" || exit 1

# Timeout (default 60s, override with ADVISOR_TIMEOUT env var)
TIMEOUT="${ADVISOR_TIMEOUT:-60}"

# Execute with timeout, separate stderr
RESULT=$(timeout "${TIMEOUT}" bash -c "echo '${SYSTEM_PROMPT}

${USER_PROMPT}' | gemini" 2>/tmp/gemini-advisor-stderr.txt)
EXIT_CODE=$?

# Error handling
if [ $EXIT_CODE -eq 124 ]; then
  echo "ERROR: Timeout: No response within ${TIMEOUT}s" >&2
  exit 1
elif [ $EXIT_CODE -ne 0 ]; then
  STDERR_CONTENT=$(cat /tmp/gemini-advisor-stderr.txt 2>/dev/null)
  if echo "$STDERR_CONTENT" | grep -qi "auth\|login\|credential\|token"; then
    echo "ERROR: Authentication required. Run: gemini (interactive mode to re-login)" >&2
  else
    echo "ERROR: Gemini CLI failed (exit code: $EXIT_CODE)" >&2
  fi
  exit 1
fi

echo "$RESULT"
