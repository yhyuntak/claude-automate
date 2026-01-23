---
description: Start Work - Integrated workflow for session context, backlog review, and worktree setup
---

[START WORK MODE ACTIVATED]

$ARGUMENTS

---

## /start-work: Integrated Work Start Workflow

Handles the complete flow from session initialization to work environment setup in one command.

**Flow:**
1. Display previous session summary
2. Show backlog list
3. Confirm worktree usage
4. Select a backlog task
5. (If worktree) Create environment and switch to it

---

## STEP 1: Load Session Context

### Find Recent Sessions

```bash
ls -t .claude/context/*/*.md 2>/dev/null | head -5
```

### Display Session Summary

When session files exist:
```markdown
## 📋 Previous Session Summary

**2026-01-22 (abc123)** - Feedback system improvements
- Work: Added /write-feedback, /check-feedback
- Incomplete: Integration testing

---
```

When session files do not exist:
```markdown
## 📋 Previous Session

No previous session records found.

---
```

---

## STEP 2: Review Backlog

### Check Backlog Folders

```bash
ls docs/backlog/todo/ 2>/dev/null
ls docs/backlog/doing/ 2>/dev/null
```

### Display Backlog Table

When backlog exists:
```markdown
## 📝 Backlog

| # | Phase | ID | Title | Description |
|---|-------|-----|-------|-------------|
| 1 | 1 | 001 | feature-x | Implement feature X |
| 2 | 1 | 002 | feature-y | Implement feature Y |

**In Progress:** phase1-003-feature-z (if in doing folder)

---
```

When backlog does not exist:
```markdown
## 📝 Backlog

This project has no backlog.
(docs/backlog/ folder does not exist or is empty)

---
```

### Backlog Parsing Rules

- Filename: `phase{N}-{ID}-{slug}.md`
- Description: First `> ` quote in file

```bash
# Extract description
head -5 docs/backlog/todo/phase1-001-xxx.md | grep "^>" | head -1 | sed 's/^> //'
```

---

## STEP 3: Confirm Worktree Usage

**Use AskUserQuestion:**

```
Question: "Use worktree for this project?"
Header: "Worktree"
Options:
  - "Yes": Separate branch using worktree
  - "No": Work in current folder
```

---

## STEP 4: Select Backlog Task

**Use AskUserQuestion:**

```
Question: "Which task to start?"
Header: "Task Selection"
Options:
  - [Backlog list - number and title]
  - "New task (no backlog)": Free work
```

Skip this step if no backlog exists.

---

## STEP 5: Create Worktree (If Yes selected)

### Branch Naming Rule
- Extract slug from filename: `phase1-001-feature-x` → `feature-x`

### Path Rule
- `../{project-name}-{branch}`
- Example: `../claude-automate-feature-x`

### Get Project Name
```bash
basename $(pwd)
```

### Check Existing Worktree
```bash
git worktree list | grep {branch}
```

- If exists: Display warning "⚠️ worktree already exists: {path}"
- If not: Proceed with creation

### Create Worktree
```bash
git worktree add ../{project}-{branch} -b {branch}
```

### Switch to Worktree
```bash
cd ../{project}-{branch}
```

---

## STEP 6: Completion Message

### Worktree Mode
```markdown
## ✅ Work Environment Ready

**Task:** phase1-001-feature-x (Implement feature X)
**Path:** ../claude-automate-feature-x
**Branch:** feature-x

Now working in this folder.
Run `/wrap` when done to complete your session.

💡 Return to main project: `cd ../claude-automate`
```

### Standard Mode
```markdown
## ✅ Work Started

**Task:** phase1-001-feature-x (Implement feature X)

Run `/wrap` when done to complete your session.
```

### New Task (No Backlog)
```markdown
## ✅ Work Started

Starting free work without backlog.

Run `/wrap` when done to complete your session.
```

---

## Options

```
/start-work              # Default: Full workflow
/start-work --skip-session   # Skip session summary
/start-work --no-worktree    # Skip worktree prompt (standard mode)
```

---

## Complete Workflow Diagram

```
┌─────────────────────────────────────────────────────┐
│  /start-work                                         │
│     │                                               │
│     ├─ 1. Display session summary                   │
│     │      └─ Check .claude/context/                │
│     │                                               │
│     ├─ 2. Display backlog table                     │
│     │      └─ Check docs/backlog/todo/              │
│     │                                               │
│     ├─ 3. [Ask] "Use worktree?"                     │
│     │      ├─ Yes → Worktree mode                   │
│     │      └─ No → Standard mode                    │
│     │                                               │
│     ├─ 4. [Ask] "Which task?"                       │
│     │      ├─ Select backlog                        │
│     │      └─ New task (no backlog)                 │
│     │                                               │
│     ├─ 5. (If worktree)                             │
│     │      ├─ git worktree add                      │
│     │      ├─ cd switch                             │
│     │      └─ Warning (if already exists)           │
│     │                                               │
│     └─ 6. Completion message                        │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Related Commands

- `/session-start`: Session summary only (Step 1)
- `/backlog`: Backlog only (Step 2)
- `/wrap`: Save session when work is complete

---

## THE START-WORK PROMISE

Before completion, verify:
- [ ] Session context displayed
- [ ] Backlog status displayed (explicitly state "none" if missing)
- [ ] User selection received (worktree, task)
- [ ] Environment configured per selection
- [ ] Completion message displayed
