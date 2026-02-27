---
name: implement
description: |
  Runs TDD loop based on plan file to implement ACs.
  Activates on keywords: "implement", "start implementing".
argument-hint: "[plan slug]"
allowed-tools:
  - Read
  - Glob
  - Grep
  - LSP
  - Task
  - Bash
  - AskUserQuestion
---

# /implement

> Executor that loads plan file and implements ACs via TDD loop

$ARGUMENTS

---

## Progress Notification Rules

Notify the user of the current status at each step.

- Entry: "Entering implementation phase. Plan: {slug} ({N} ACs)"
- Each step: "[N/5] Executing {step name}."
- AC processing: "AC-{N}: {content} → {TDD/implementation only}"
- Parallel: "Running AC-{N} and AC-{M} in parallel. (no file overlap)"
- Sequential: "Running AC-{N} sequentially. (file overlap with AC-{M}: {file})"
- Retry: "AC-{N}: red (retry attempt {K}, using {writer/writer-high})"
- Completion: "AC-{N} ✅"

---

## [1/5] Load Plan

Load plan file from `.claude/plans/`.

- Slug specified as argument → load that file
- No argument → search for files with status: draft or in_progress
- Change status → `in_progress`
- Already `in_progress` → resume from incomplete ACs (`- [ ]`)

MUST: Write `implement` to `.claude/state/mode`. (`echo implement > .claude/state/mode`)

## [2/5] Update Brain

Execute the "Brain update" section from the plan.

```
Task(
  subagent_type="claude-automate:writer",
  prompt="Brain update: {brain section content from plan}. Target: files under .claude/brain/"
)
```

Skip if "none".

## [3/5] Iterate ACs

Process ACs in the implementation order from the plan.

### Parallel/Sequential Decision

Follow the notation in the implementation order:
- `[parallel]` → call writer simultaneously
- `[sequential]` → call writer one at a time

### AC with TC → TDD Loop

1. writer: write tests (based on TC)
2. Bash: run tests → confirm red
3. writer: implement
4. Bash: run tests → green?
   - green → check AC ✅
   - red → retry

### Retry Policy

| Attempt | Action |
|---------|--------|
| 1-2 | writer (Sonnet) retry |
| 3 | writer-high (Opus) escalation |
| 4 | Ask user via AskUserQuestion |

### AC without TC → Implementation Only

1. writer: implement
2. Check AC ✅

### AC Checkbox Update

When AC is complete, update the checkbox in the plan file to `- [x]` (via writer).

## [4/5] Update Plan Status

After all ACs are complete, change the frontmatter status in the plan file to `done` (via writer).

## [5/5] Completion

Confirm next action via AskUserQuestion.

```json
{
  "question": "Implementation is complete. What would you like to do next?",
  "header": "Completion",
  "multiSelect": true,
  "options": [
    { "label": "Wrap up with /wrap (Recommended)", "description": "Backlog cleanup + context save + commit" },
    { "label": "Continue working", "description": "Continue with another task" }
  ]
}
```

---

## Constraints

- Do not perform work not in the plan
- Delegate all file modifications to writer agent
- If new AC is discovered, add to plan file before proceeding
- Stop Hook monitors quality via test-command

---

## Verification

MUST: Confirm all items in the checklist below.

- [ ] Are all ACs in the plan file checked?
- [ ] Do tests for ACs with TC pass?
- [ ] Has plan status been changed to done?
- [ ] Was progress notification output at each step?

On failure: Return to the relevant step, fix, and re-verify.

---

## Notes

1. **Execute only what is in the plan** — Do not expand scope
2. **Do not ask questions** — Decisions were already made upstream (planning) (except after 4 retries)
3. **Progress notification is mandatory** — User must always know the current state
4. **Writer delegation is mandatory** — Do not directly Write/Edit files
