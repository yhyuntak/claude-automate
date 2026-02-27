# Plan File Rules

## Path

`.claude/plans/{YYYY-MM-DD}-{slug}.md`

Example: `.claude/plans/2026-02-22-user-auth.md`

---

## Status Management

```
draft       → created during planning (before implementation starts)
in_progress → when /implement begins
done        → when all ACs are completed in /implement
```

No `abandoned` — if not doing it, delete the file.

---

## File Structure

```markdown
---
status: draft
created: {YYYY-MM-DD}
slug: {feature-name}
test-command: {project test command e.g. npm test, pytest, go test}
---

# Plan: {feature-name}

## Requirements

### Context (Background)
- {taken from conversation}

### What
- {core feature}

### Why
- {goal/value}

### Scope
- ✅ In: {what to do this time}
- ❌ Out: {what not to do}

## Brain Update

- code-map: {structural changes}
- patterns: {new patterns or changes}
- decisions: {architecture decisions}

(Run first during implement. Write "none" if not applicable.)

<!--
AC = work item (progress tracking, checkbox = status)
TC = verification criteria (TDD test target, sub-items per AC)
-->

## AC List

- [ ] AC-1: {work item}
  - TC: {verification condition 1}
  - TC: {verification condition 2}
- [ ] AC-2: {work item}
  - TC: {verification condition}
- [ ] AC-3: {work item} (no TC)

## Implementation Order

1. Brain update
2. [Parallel] AC-1 → {file list} / AC-2 → {file list}
3. [Sequential] AC-3 → {file list} (overlaps {file} with AC-1)

<!--
[Parallel] = no overlapping files, can run simultaneously
[Sequential] = overlapping files, run after preceding AC completes
Determined based on exploration results from planning Step 4
-->
```

---

## test-command

The test command that Stop Hook runs automatically during implement.
- Set during the planning phase
- Use the appropriate command for the project (npm test, pytest, go test, etc.)
- If empty, tests are skipped

---

## Judgment in start-work

| Date | Status | Action |
|------|--------|--------|
| Recent | in_progress | "Continue?" |
| Old | in_progress | "Still doing this?" |
| - | draft | "Ready to start?" |
