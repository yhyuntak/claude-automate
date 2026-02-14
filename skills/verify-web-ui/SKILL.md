---
name: verify-web-ui
description: Web UI 검증. 오케스트레이터 에이전트를 즉시 호출합니다.
user-invocable: true
allowed-tools: Task
---

# verify-web-ui

> Web UI 검증 스킬. 오케스트레이터 에이전트에 즉시 위임합니다.

---

## 실행

이 스킬은 **즉시** `verify-web-ui-orchestrator` 에이전트를 호출합니다.
사용자 요청을 그대로 전달하세요.

```
Task(
  subagent_type="claude-automate:verify-web-ui-orchestrator",
  prompt="{사용자가 전달한 전체 요청}"
)
```

---

## 왜 즉시 위임하는가?

이 스킬은 메인 컨텍스트에서 실행됩니다. 메인 컨텍스트에는 Playwright MCP 등 브라우저 도구가 보이므로, 오케스트레이션 로직이 여기서 실행되면 브라우저를 직접 호출할 위험이 있습니다.

`verify-web-ui-orchestrator` 에이전트는 `allowed-tools`에 MCP 도구가 없어 브라우저를 물리적으로 사용할 수 없습니다. 이 구조적 분리로 안전한 오케스트레이션을 보장합니다.

```
메인 컨텍스트 (MCP 보임)
    → Skill: 즉시 위임만
        → orchestrator 에이전트 (MCP 없음 = 물리적 차단)
            → test-planner (시나리오 설계)
            → verify-web-ui agent (브라우저 테스트, MCP 있음)
            → 프로젝트 특화 에이전트 (병렬)
```
