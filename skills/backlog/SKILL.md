---
name: backlog
description: Query and manage project backlog. Supports task lists, progress tracking, and idea filtering. Auto-activates on keywords like "backlog"/"백로그", "todo"/"할 일", "in progress"/"진행 중", "done"/"완료", "ideas"/"아이디어", etc.
argument-hint: "[todo|doing|done|ideas|phase N]"
---

# Backlog Manager

$ARGUMENTS

This skill activates when it detects backlog-related requests.

---

## Backlog Locations

| Folder | Status | Description |
|--------|--------|-------------|
| `docs/backlog/todo/` | To Do | Work within current scope |
| `docs/backlog/doing/` | In Progress | **1 item only!** (focus) |
| `docs/backlog/done/` | Completed | Finished work |
| `docs/backlog/ideas/` | Ideas | Out of scope |

---

## Query Patterns

| Query | Action |
|-------|--------|
| "show all backlog" / "what needs to be done" | list todo folder |
| "Phase 1 tasks" | filter `phase1-*` |
| "Phase 2 tasks" | filter `phase2-*` |
| "what's in progress" | list doing folder |
| "completed items" | list done folder |
| "idea list" | list ideas folder |

---

## Query Results Format (Table)

**Important**: Output as **table**, not file list

```bash
# Get file list
ls docs/backlog/todo/

# Extract descriptions by parsing first blockquote (>) from each file
```

### Output Format

| Phase | ID | Title | Description |
|-------|-----|-------|-------------|
| 1 | 001 | immersion-mode | Implement immersion mode |
| 1 | 002 | session-feedback | Session feedback system |

**Parsing rules**:
- Filename: `phase{N}-{ID}-{slug}.md`
- Description: First `> ` blockquote in file (one-line summary)

### Extract Description Method

```bash
# Extract first > line from each file
head -5 docs/backlog/todo/phase1-001-xxx.md | grep "^>" | head -1 | sed 's/^> //'
```

---

## Status Changes

### Start Story
> Trigger: "start", "begin", "I'll do this"

```bash
mv docs/backlog/todo/phase1-xxx.md docs/backlog/doing/
# Update README.md (🔄 emoji)
```

### Complete Story
> Trigger: "done", "finished", "complete"

```bash
mv docs/backlog/doing/phase1-xxx.md docs/backlog/done/
# Update README.md (✅ emoji, completion date)
```

### Add Idea
> Trigger: "later", "idea", "record this for now"

Create file using idea template from templates.md

---

## Add New Backlog

`/backlog add` or "add new backlog item"

→ Create file in `docs/backlog/todo/` using story template from templates.md

---

## Explicit Commands

| Command | Action |
|---------|--------|
| `/backlog` | Full status (table) |
| `/backlog todo` | To do items only |
| `/backlog doing` | In progress items only |
| `/backlog done` | Completed items only |
| `/backlog ideas` | Ideas only |
| `/backlog phase 1` | Phase 1 items only |
| `/backlog add` | Add new backlog item |

---

## Reference Files

- Schema: schema.md
- Templates: templates.md
