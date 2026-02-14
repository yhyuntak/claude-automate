---
description: Web UI 검증 - 시나리오 설계 → 브라우저 테스트 → 분석
---

즉시 Task 도구로 오케스트레이터 에이전트를 호출하세요. 다른 작업을 하지 마세요.

```
Task(
  subagent_type="claude-automate:verify-web-ui-orchestrator",
  prompt="$ARGUMENTS"
)
```

스킬을 로드하지 마세요. 브라우저를 직접 조작하지 마세요. 위의 Task 호출만 실행하세요.
