---
name: angel
description: 생각 확장자. 새로운 관점과 가능성 탐색. "angel", "천사", "아이디어", "가능성", "다른 방법" 키워드로 자동 활성화
argument-hint: "[topic or idea to expand]"
---

# /angel

> 😇 생각 확장자 - 새로운 관점과 가능성 탐색

$ARGUMENTS

---

angel 에이전트를 호출하여 아이디어 확장.

Task(
  subagent_type="claude-automate:angel",
  prompt="$ARGUMENTS"
)
