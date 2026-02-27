---
name: verify-web-ui
description: Web UI verification. Immediately delegates to the orchestrator agent.
user-invocable: true
allowed-tools: Task
---

# verify-web-ui

> Web UI verification skill. Immediately delegates to the orchestrator agent.

---

## Execution

This skill **immediately** invokes the `verify-web-ui-orchestrator` agent.
Pass the user's request as-is.

```
Task(
  subagent_type="claude-automate:verify-web-ui-orchestrator",
  prompt="{full request as provided by the user}"
)
```

---

## Why Delegate Immediately?

This skill runs in the main context. The main context has access to browser tools such as Playwright MCP, so if orchestration logic ran here, it could directly invoke the browser.

The `verify-web-ui-orchestrator` agent has no MCP tools in its `allowed-tools`, making it physically incapable of using the browser. This structural separation ensures safe orchestration.

```
Main context (MCP visible)
    → Skill: delegate only
        → orchestrator agent (no MCP = physically blocked)
            → test-planner (scenario design)
            → verify-web-ui agent (browser testing, has MCP)
            → project-specific agents (parallel)
```
