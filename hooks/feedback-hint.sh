#!/bin/bash
# claude-automate Feedback Hint Hook
# 키워드 "피드백", "feedback" 감지 시 힌트 주입

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // ""')

# 키워드 감지: 피드백, feedback (대소문자 무관)
if echo "$PROMPT" | grep -qiE "^(피드백|feedback)"; then
  # /feedback 커맨드로 시작하면 힌트 불필요 (이미 커맨드 실행 중)
  echo '{"continue": true}'
elif echo "$PROMPT" | grep -qiE "(피드백|feedback)"; then
  # 문장 중간에 키워드가 있으면 힌트 제공
  MESSAGE="<system-reminder>
[FEEDBACK DETECTED]
사용자가 피드백 관련 내용을 언급했습니다.

대화 맥락을 파악하여:
1. 피드백으로 저장할 내용이 있는지 판단
2. 있다면 사용자에게 '/write-feedback' 사용을 안내하거나
3. 사용자 동의 후 직접 ~/.claude/feedback/에 저장

저장 경로: ~/.claude/feedback/{YYYY-MM-DD}.jsonl
</system-reminder>"

  ESCAPED=$(echo "$MESSAGE" | jq -Rs '.')
  echo "{\"continue\": true, \"message\": $ESCAPED}"
else
  echo '{"continue": true}'
fi
