---
description: 세션 마무리 v2 - 간소화된 3-에이전트 구조
---

[WRAP V2 MODE ACTIVATED]

$ARGUMENTS

---

## AGENT DELEGATION REQUIRED

You are in **WRAP V2 MODE**. This mode uses a streamlined 3-agent pipeline.

**RULES:**
- ❌ NEVER analyze code yourself
- ❌ NEVER write context files directly
- ✅ MUST use Task tool to invoke agents
- ✅ MUST follow the 3-phase pipeline

---

## PIPELINE

### Phase 1: Data Collection

Invoke `wrap-reader` (haiku):

```
Task(
  subagent_type="claude-automate:wrap-reader",
  prompt="Collect wrap data for current project"
)
```

**Collects:**
- Git diff (staged/unstaged/HEAD~1)
- Project rules (.claude/rules/*, CLAUDE.md)
- Document paths (no content)

---

### Phase 2: Analysis

Invoke `wrap-analyzer` (sonnet) with Phase 1 output:

```
Task(
  subagent_type="claude-automate:wrap-analyzer",
  prompt="Analyze this wrap data:\n\n{wrap_data from Phase 1}"
)
```

**Analyzes:**
- Related files (imports, tests, same module)
- Rule compliance
- Refactoring opportunities
- Documentation sync

---

### Phase 3: Reporting

Invoke `wrap-reporter` (opus) with Phase 2 output:

```
Task(
  subagent_type="claude-automate:wrap-reporter",
  prompt="Generate wrap report:\n\n{analysis from Phase 2}"
)
```

**Generates:**
- Prioritized briefing
- Action proposals
- Context file content (NOT written yet)

---

## POST-PIPELINE (Main Claude)

After receiving wrap-reporter output:

### 1. Present Briefing
Show the `<briefing>` section to user.

### 2. Collect User Selection
Wait for user to select actions (e.g., "1,3" or "all" or "none").

### 3. Execute Approved Actions
For each approved action, execute as specified in `<actions>`.

### 4. Write Context File
Extract `<context_file>` content and write to specified path:

```
1. Ensure directory exists: mkdir -p .claude/context/YYYY-MM/
2. Write file using Write tool
3. Confirm to user
```

---

## OUTPUT FORMAT

### Normal Result:
```
## /wrap Summary

[Briefing from wrap-reporter]

---

✅ Context saved: .claude/context/2026-01/2026-01-20-abc123.md
```

### No Significant Findings:
```
## /wrap Complete

이번 세션은 특별히 기록할 이슈가 없습니다.

✅ Context saved: .claude/context/2026-01/2026-01-20-abc123.md
```

---

## THE WRAP PROMISE

Before completing, verify:
- [ ] wrap-reader was invoked
- [ ] wrap-analyzer was invoked
- [ ] wrap-reporter was invoked
- [ ] User saw briefing and selected actions
- [ ] Approved actions were executed
- [ ] Context file was written

**If ANY step was skipped, START OVER.**
