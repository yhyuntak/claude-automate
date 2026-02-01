---
description: Session Wrap - Rule checks, document sync, and session context save
---

[WRAP V3 MODE ACTIVATED]

$ARGUMENTS

---

## WRAP V3: Goal-First Architecture

Main decides → Call only necessary agents with defined scope → Integrate results → Save session

**Core principles:**
- Main reviews `git diff --stat` only and makes decisions
- Detailed collection/analysis performed by agents directly
- Minimize main context

---

## STEP 1: Review Diff and Make Decisions

```bash
git diff --stat
git diff --cached --stat
```

Determine based on file list only:

| Change Type | pattern-checker | doc-sync-checker |
|-------------|-----------------|------------------|
| Code files (.ts, .py, etc.) | ✅ | △ (if API) |
| Documentation files (.md) | △ (if rule-related) | ❌ |
| Config files | △ | ❌ |
| New features | ✅ | ✅ |

---

## STEP 2: Determine Scope

Generate scope hints based on changed files:

```
Examples:
- commands/feedback.md changed → scope: "commands-related rules"
- src/api/user.ts changed → scope: "backend, api rules" + "API documentation"
- frontend/components/* changed → scope: "frontend rules"
```

---

## STEP 3: Call Agents (Only needed ones, in parallel)

### Call pattern-checker (If rule checks needed)

```
Task(
  subagent_type="claude-automate:pattern-checker",
  prompt="""
## Changed Files
{file list}

## Scope
Check only rules related to {category}

## Instructions
1. Review detailed diff of above files
2. Read only relevant rules from .claude/rules/
3. Check for violations
4. Return results
"""
)
```

### Call doc-sync-checker (If document sync needed)

```
Task(
  subagent_type="claude-automate:doc-sync-checker",
  prompt="""
## Changed Files
{file list}

## Scope
Check only documentation related to {doc type}

## Instructions
1. Review changes in above files
2. Find related documentation
3. Check for inconsistencies
4. Return results
"""
)
```

---

## STEP 4: Integrate Results

Receive agent results and consolidate:

```markdown
## /wrap Summary

### Rule Check
- [Violations found or "No issues"]

### Document Sync
- [Inconsistencies found or "No issues"]

### Recommended Actions
1. [ ] [Action 1]
2. [ ] [Action 2]
```

---

## STEP 5: Update Backlog Status

### Check Anchor for Current Task

```bash
cat .claude/anchor.md 2>/dev/null
```

If anchor contains a backlog task (e.g., `phase1-001-xxx`):

### Move Backlog File

```bash
# If task was in todo/, move to done/
mv docs/backlogs/todo/{task}.md docs/backlogs/done/
# Or if in doing/, move to done/
mv docs/backlogs/doing/{task}.md docs/backlogs/done/
```

### Update README.md

Update the backlog README to reflect the status change:
- Change status from "Todo" or "Doing" to "Done"
- Update file path link

---

## STEP 6: Commit Changes (If No Issues)

### Commit Criteria

Only commit if:
- [ ] No pattern-checker violations (or all resolved)
- [ ] No doc-sync issues (or all resolved)
- [ ] Changes are staged or ready to stage

### Commit Flow

```bash
# Check status
git status

# Stage changes (specific files, not -A)
git add {changed files}

# Commit with descriptive message
git commit -m "{type}: {description}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

### Commit Message Format

| Type | Usage |
|------|-------|
| feat | New feature |
| fix | Bug fix |
| refactor | Code refactoring |
| docs | Documentation |
| chore | Maintenance |

**If issues remain:** Skip commit, list in Recommended Actions.

---

## STEP 7: Save Session Context

```
Task(
  subagent_type="claude-automate:context-builder",
  prompt="""
## Session Information
- Date: {today's date}
- Main work: {summary of work done this session}
- Changed files: {file list}

## Analysis Results
{Summary of pattern-checker, doc-sync-checker results}

## Instructions
Create a session context file
"""
)
```

Context file path: `.claude/context/YYYY-MM/YYYY-MM-DD-{session-id}.md`

---

## STEP 8: Final Output

```markdown
## /wrap Complete

### Summary
[Brief summary]

### Actions (Optional)
1. [ ] [Action]

### Session Saved
✅ .claude/context/2026-01/2026-01-22-abc123.md
```

---

## Decision Guide

### Simple Cases (Minimal agent calls)
```
Only 1 document modified → context-builder only
Only config files modified → context-builder only
```

### Standard Cases
```
Code modified → pattern-checker + context-builder
API modified → pattern-checker + doc-sync-checker + context-builder
```

### Complex Cases (Escalation)
```
Rule conflicts → Escalate to pattern-checker-high
Document structure change needed → Escalate to doc-sync-checker-high
```

---

## THE WRAP PROMISE

Before completion, verify:
- [ ] Reviewed changed files with diff --stat
- [ ] Called only necessary agents (no unnecessary agent calls)
- [ ] Clearly defined scope for each agent
- [ ] Updated backlog status (if applicable)
- [ ] Committed changes (if no issues)
- [ ] Saved session with context-builder
- [ ] Displayed results to user
