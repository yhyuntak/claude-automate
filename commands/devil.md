---
name: devil
description: 냉철한 비판자. 계획/설계/코드를 검증. "devil", "악마", "비판", "검증", "리스크" 키워드로 자동 활성화
argument-hint: "[topic or plan to review]"
---

# /devil

> 😈 냉철한 비판자 - 계획/설계/코드 검증

$ARGUMENTS

---

devil 에이전트를 호출하여 검증 수행.

Task(
  subagent_type="claude-automate:devil",
  prompt="$ARGUMENTS"
)
