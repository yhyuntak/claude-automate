#!/bin/bash
# Stop Hook — 테스트 검증 + 컨텍스트 감시
# 하네스 2.0 운영 스크립트

set -euo pipefail

INPUT=$(cat)

# --- 무한루프 방지 ---
STOP_ACTIVE=$(echo "$INPUT" | jq -r '.stop_hook_active // false')
if [ "$STOP_ACTIVE" = "true" ]; then
  exit 0
fi

# --- 1. 테스트 검증 ---
# in_progress plan 파일에서 test-command 읽기
PLANS_DIR=".claude/plans"
if [[ -d "$PLANS_DIR" ]]; then
  for plan_file in "$PLANS_DIR"/*.md; do
    [[ -f "$plan_file" ]] || continue

    # frontmatter에서 status 확인
    status=$(sed -n '/^---$/,/^---$/{ /^status:/s/status: *//p }' "$plan_file")
    if [[ "$status" == "in_progress" ]]; then
      # test-command 읽기
      test_cmd=$(sed -n '/^---$/,/^---$/{ /^test-command:/s/test-command: *//p }' "$plan_file")
      if [[ -n "$test_cmd" ]]; then
        # 테스트 실행
        if ! eval "$test_cmd" > /dev/null 2>&1; then
          echo "테스트 실패. 수정 후 다시 시도하세요. (command: $test_cmd)" >&2
          exit 2
        fi
      fi
      break  # 첫 번째 in_progress plan만 처리
    fi
  done
fi

# --- 2. 컨텍스트 감시 ---
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
CONTEXT_FILE="/tmp/claude-context-pct-${SESSION_ID}"
if [[ -f "$CONTEXT_FILE" ]]; then
  CONTEXT_PCT=$(cat "$CONTEXT_FILE" 2>/dev/null || echo "0")
  # 정수 비교를 위해 소수점 제거
  CONTEXT_INT=${CONTEXT_PCT%.*}
  if [[ "$CONTEXT_INT" -ge 70 ]]; then
    echo "컨텍스트 ${CONTEXT_PCT}% 사용 (임계값 70%). /save-context를 실행하고 새 세션을 시작하세요." >&2
    exit 2
  fi
fi

# --- 3. 통과 ---
exit 0
