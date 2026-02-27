---
name: wrap
description: |
  Task wrap-up at session end.
  Checks plan + cleans up backlog + verifies doc sync + commits.
  Activated by keywords: "wrap", "finish", "done", "end session".
argument-hint: "[commit message]"
allowed-tools:
  - Read
  - Glob
  - Bash
  - Edit
  - Write
  - Task
  - AskUserQuestion
---

# /wrap

$ARGUMENTS

---

## Progress Guidance Rules

Announce the current status to the user when entering each step.

- Entry: "Starting wrap-up."
- Each step: "[N/4] Running {step name}."
- Result: One-line summary after each step completes
- Completion: "Wrap-up complete"

## Step 1: Plan Check

Search for plan files with `status: in_progress` in `.claude/plans/` using Glob.

If found:
- Check whether all ACs are checked (`- [x]`)
- If incomplete ACs exist, print a warning + AskUserQuestion ("There are incomplete ACs. Do you want to proceed anyway?")
- After confirmation, delegate to writer to change plan file status to `done`

If not found: skip

MUST: Write `idle` to `.claude/state/mode`. (`echo idle > .claude/state/mode`)

## Step 2: Backlog Cleanup

Check for backlog files related to the current task in `docs/backlogs/doing/`.

- There may be multiple files in doing/, so find the one matching the current plan slug or conversation history
- If all ACs of a related backlog are complete → move to `done/` with Bash
- Update `docs/backlogs/README.md` (delegate to writer):
  - Status: Doing -1, Done +1
  - Link path: `doing/` → `done/`
  - Status label: `🔄 Doing` → `✅ Done`

If no related backlog: skip

## Step 3: Doc Sync Check

Use the doc-sync-checker agent to verify that changed files match the index.

```
Task(
  subagent_type="claude-automate:doc-sync-checker",
  prompt="Check the list of changed files via git diff. Report any missing or mismatched items compared to the docs/README.md index."
)
```

If sync issues are found in the result:
- AskUserQuestion ("Shall we update the index?")
- On confirmation, delegate to writer to update

If no sync issues: skip

If doc-sync-checker fails: print "Doc sync check failed (warning)" and proceed to Step 4 (fault tolerant)

## Step 4: Commit

Draft a commit message based on the changes.

- If $ARGUMENTS is provided, suggest it as the default message
- Otherwise, generate a message based on `git diff --stat`

Confirm commit message with AskUserQuestion:

```json
{
  "question": "Please review the commit message.",
  "header": "Commit",
  "multiSelect": false,
  "options": [
    { "label": "Commit as is", "description": "Execute commit with the suggested message" },
    { "label": "Edit message", "description": "Enter a custom message" },
    { "label": "Skip commit", "description": "Exit without committing" }
  ]
}
```

- "Commit as is" → run `git add -A && git commit -m "{message}"`
- "Edit message" → receive message via AskUserQuestion and commit
- "Skip commit" → skip and exit gracefully

---

## Constraints

- Do not perform work not in the plan
- All file modifications are delegated to writer (except git commands)
- Always commit only after user confirmation

---

## Verification

MUST: Confirm all items in the checklist below.

- [ ] Is plan file status `done`? (or skip if no plan)
- [ ] Was doing/ file moved to done/? (or skip if no related backlog)
- [ ] Is docs/README.md index up to date?
- [ ] Did the user confirm the commit?
- [ ] Was progress guidance printed at each step?

If failed: return to the relevant Step, fix, and re-verify.

---

## Cautions

1. **Skip each Step if there is no target** — not an error, normal flow
2. **doc-sync-checker failure does not halt wrap** — print warning and continue
3. **Exit gracefully when commit is declined** — do not omit AskUserQuestion
