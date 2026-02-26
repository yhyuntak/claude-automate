#!/bin/bash
# PreCompact Hook — compact 전 상태 메시지 주입
# mode를 읽고 적절한 systemMessage를 Claude에게 전달

set -euo pipefail

# stdin 읽기
cat > /dev/null

# mode 파일 읽기 (없으면 idle)
MODE="idle"
if [ -f ".claude/state/mode" ]; then
  MODE=$(cat .claude/state/mode 2>/dev/null || echo "idle")
fi

# mode별 systemMessage 구성
case "$MODE" in
  "implement")
    # in_progress plan 파일 탐색
    PLAN=$(grep -rl "^status: in_progress" .claude/plans/*.md 2>/dev/null | head -1 || true)
    if [ -n "$PLAN" ]; then
      MSG="현재 /implement 실행 중이었습니다.\\nPlan: ${PLAN}\\n→ plan 파일을 읽고 미완료 AC([ ])부터 이어서 구현하세요."
    else
      MSG=""
    fi
    ;;
  "planning")
    MSG="현재 /planning 실행 중이었습니다.\\n→ 사용자와 이어서 계획을 진행하세요."
    ;;
  *)
    MSG=""
    ;;
esac

# JSON 출력
printf '{"continue": true, "systemMessage": "%s"}\n' "$MSG"

exit 0
