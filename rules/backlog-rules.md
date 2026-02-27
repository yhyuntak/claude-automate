# Backlog Management Rules

> Task-based backlog system

---

## Folder Structure

```
docs/backlogs/
├── README.md           # Overall status dashboard
├── todo/               # Pending tasks
├── doing/              # In-progress tasks (only 1 at a time!)
└── done/               # Completed tasks
```

---

## File Naming Convention

```
phase{N}-{ID}-{slug}.md

Examples: phase1-001-user-auth.md
          phase1-002-api-setup.md
          phase2-001-dashboard.md
```

- **phase{N}**: Phase number (phase1, phase2, ...)
- **{ID}**: 3-digit number (001, 002, ...)
- **{slug}**: Lowercase English letters, connected with hyphens

---

## Status Management

### Status Types

| Status | Folder | Description |
|--------|--------|-------------|
| Todo | `todo/` | Pending, not yet started |
| Doing | `doing/` | **Currently in progress (only 1!)** |
| Done | `done/` | Completed |

### How to Change Status

```bash
# Start task: todo → doing
mv docs/backlogs/todo/phase1-001-user-auth.md \
   docs/backlogs/doing/

# Complete task: doing → done
mv docs/backlogs/doing/phase1-001-user-auth.md \
   docs/backlogs/done/
```

### Claude Auto-processing

**Task start triggers**:
- "let's proceed", "let's start", "I'll do it", "let's try"
- → Move task file to `doing/`

**Task completion triggers**:
- When all Acceptance Criteria for a task are met
- → Move task file to `done/`

---

## README.md Updates

When status changes, also update README.md:

1. **Status counts**: Refresh Todo/Doing/Done counts
2. **Task links**: Update to new path
3. **Status display**: Update emoji

### Example

```markdown
# Before change
| 1 | 001 | [User Authentication](todo/phase1-001-user-auth.md) | Todo |

# After change (task started)
| 1 | 001 | [User Authentication](doing/phase1-001-user-auth.md) | 🔄 Doing |

# After change (task completed)
| 1 | 001 | [User Authentication](done/phase1-001-user-auth.md) | ✅ Done |
```

---

## Task Template

```markdown
# {Title}

> {One-line description}

---

## User Story

When a user [action], they get [outcome].

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Non-functional Requirements

- Performance: ...
- Security: ...

## Dependencies

- Can start after phase1-xxx is complete

---

## Implementation Notes (added during work)

### Technical Decisions
- ...

### Issues/Resolutions
- ...

---

**Last Updated**: YYYY-MM-DD
```

---

## Backlog Writing Principles

> See CLAUDE.md "Backlog/Story Writing Principles"

### Include

- User Story (As a user, I want to...)
- Acceptance Criteria
- Non-functional requirements
- Priority
- Dependencies

### Do Not Include

- Specific code examples
- Detailed architecture
- Technology stack choices
- Implementation details
- File/folder structure

### Rationale

```
"Design and implementation are a growth process to work through together"

Deciding everything upfront:
- Removes the opportunity to think things through
- Can lead to decisions that don't fit the actual situation
- Reduces flexibility

Deciding at implementation time:
- Allows the best possible choices
- Decisions fit the current situation
- Opportunities for learning and growth
```

---

**Last Updated**: {LAST_UPDATE_DATE}
