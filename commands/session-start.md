---
description: Session Start - Load and summarize previous session context
---

[SESSION START]

$ARGUMENTS

## What is /session-start?

Loads the context from previous sessions when starting a new session.
Displays a summary of the last 5 sessions for quick context recovery.

## Execution Protocol

### Step 1: Find Recent Sessions

Locates the most recent 5 session files:

```
.claude/context/
├── YYYY-MM/
│   └── YYYY-MM-DD-*.md
```

**Search order:**
1. Latest files in current month folder
2. Previous month folder if needed
3. Files sorted by name in reverse order (newest first)

### Step 2: Read Session Files

Reads each session file. Displays "No previous sessions" if files not found.

### Step 3: Summarize and Output

## Output Format

### When session files exist:

```markdown
## 📋 Session Context Loaded

### Recent Session Summary

**2026-01-20 (abc123)** - /wrap system improvements
- Work: Modified hooks.json, removed TIL
- Incomplete: SessionStart test validation

**2026-01-19 (xyz789)** - Initial setup
- Work: Created plugin structure
- Decision: Multi-session analysis introduced

---

### Next tasks to continue
- [ ] Test SessionStart hook
- [ ] Validate with actual session

### Suggestion
Begin with the next steps proposed in the most recent session.
```

### When session files do not exist:

```markdown
## 📋 Session Context

No previous session records found.

Run `/wrap` after completing work to save your session.
```

## Options

```
/session-start          # Default: Summary of last 5
/session-start --all    # Show all sessions this month
/session-start --last   # Show last session in full detail
```

### --all option

Displays a complete list of all session files for the current month.

### --last option

Displays the full contents of the most recent session file.

## Implementation Details

### Finding Session Files

```bash
# Find latest 5 files
ls -t .claude/context/*/*.md 2>/dev/null | head -5
```

### Parsing Session Files

Extract from each file:
- Date and time from filename
- First line of context section
- Complete work summary
- Incomplete/TODO items

### Summary Generation

Read last 5 sessions and:
1. Summarize each session's core content in 1-2 lines
2. Consolidate incomplete tasks
3. Display "next session suggestions" from most recent session

## Integration

- **Before work**: Run `/session-start` to load context
- **After work**: Run `/wrap` to save session

```
┌─────────────────────────────────────────┐
│  /session-start                         │
│     ↓                                   │
│  [Perform work]                         │
│     ↓                                   │
│  /wrap                                  │
│     ↓                                   │
│  .claude/context/YYYY-MM/file.md saved  │
└─────────────────────────────────────────┘
```
