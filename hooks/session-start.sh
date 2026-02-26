#!/bin/bash
# SessionStart Hook — mode 초기화
# compact 상태 관리: 세션 시작 시 mode를 idle로 설정

set -euo pipefail

# stdin 읽기 (필수, 안 읽으면 broken pipe)
cat > /dev/null

# .claude/state/ 디렉토리 보장
mkdir -p .claude/state

# mode를 idle로 초기화
echo "idle" > .claude/state/mode

exit 0
