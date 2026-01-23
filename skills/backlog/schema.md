# Backlog Schema

## Folder Structure

```
docs/backlog/
├── README.md        # Overall status (auto-updated by Claude)
├── todo/            # To do (current scope)
├── doing/           # In progress (1 item only!)
├── done/            # Completed
├── ideas/           # Ideas (out of scope)
└── _archive/        # Completed epics
```

---

## Folder Meanings

| Folder | Meaning | Rules |
|--------|---------|-------|
| `todo/` | What we're doing now | Clear work within scope |
| `doing/` | What we're working on now | **1 item only!** (focus) |
| `done/` | What's completed | Record completion date |
| `ideas/` | What we'll do later | Out-of-scope ideas |

---

## Filename Rules

```
phase{N}-{id}-{slug}.md
```

| Part | Description | Example |
|------|-------------|---------|
| `phase{N}` | Phase number | `phase1`, `phase2` |
| `{id}` | 3-digit sequence | `001`, `002` |
| `{slug}` | Kebab-case title | `immersion-mode` |

**Examples**: `phase1-001-immersion-mode.md`, `phase2-005-account-delete.md`

---

## Phase System (Dependency-Based)

> Ordered by **dependencies**, not priority

| Phase | Meaning | Description |
|-------|---------|-------------|
| Phase 1 | Foundation features | Core functionality others depend on |
| Phase 2 | First dependencies | Can be implemented after Phase 1 |
| Phase 3 | Second dependencies | Can be implemented after Phase 2 |
| Phase 4 | Independent features | Can be implemented anytime, no dependencies |

---

## File Internal Structure

### Story File

```markdown
# [Title]

> One-line summary (displayed in table description column)

## User Story
[As a user I want to ~]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Why
[Why is this needed]

## Dependencies
- List any predecessor work if applicable

---
Created: YYYY-MM-DD
Completed: YYYY-MM-DD (when complete)
```

### Idea File

```markdown
# [Title]

> One-line summary

## Description
[Detailed explanation]

## Related
[Related information]

---
Created: YYYY-MM-DD
```

---

## README.md Auto-Update

Claude manages automatically:

```markdown
# Backlog

## Status

| Status | Count |
|--------|-------|
| 🔄 Doing | 1 |
| 📋 Todo | 5 |
| ✅ Done | 12 |
| 💡 Ideas | 8 |

## In Progress

| Phase | ID | Title | Description |
|-------|-----|-------|-------------|
| 1 | 003 | user-auth | Implement user authentication |

## To Do

| Phase | ID | Title | Description |
|-------|-----|-------|-------------|
| 1 | 004 | ... | ... |
| 2 | 001 | ... | ... |

---
Last Updated: YYYY-MM-DD
```

---

## Scope Management Principles

```
doing/ has 1 item only → maintain focus
todo/ is current scope → clear boundaries
ideas/ is out of scope → prevent scope creep
```

**Key**: Improvements/features from testing go to `ideas/` → control scope
