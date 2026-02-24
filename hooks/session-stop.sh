#!/bin/bash
# Stop Hook — 테스트 검증
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
    status=$(grep -m1 '^status:' "$plan_file" | sed 's/status: *//')
    if [[ "$status" == "in_progress" ]]; then
      # test-command 읽기
      test_cmd=$(grep -m1 '^test-command:' "$plan_file" | sed 's/test-command: *//')
      if [[ -n "$test_cmd" && "$test_cmd" != "null" ]]; then
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
# --- 2. 통과 ---
exit 0
