# Backlog Management Rules

> Task-based backlog system

---

## Folder Structure

```
docs/backlogs/
├── README.md           # Overall status dashboard
├── todo/               # Pending tasks
├── doing/              # Tasks in progress (1 only!)
└── done/               # Completed tasks
```

---

## Filename Rules

```
phase{N}-{ID}-{slug}.md

Example: phase1-001-user-auth.md
         phase1-002-api-setup.md
         phase2-001-dashboard.md
```

- **phase{N}**: Phase number (phase1, phase2, ...)
- **{ID}**: 3-digit number (001, 002, ...)
- **{slug}**: Lowercase English, connected with hyphens

---

## Status Management

### Status Types

| Status | Folder | Description |
|--------|--------|-------------|
| Todo | `todo/` | Pending, not started yet |
| Doing | `doing/` | **Currently in progress (1 only!)** |
| Done | `done/` | Completed |

### How to Change Status

```bash
# Start task: todo -> doing
mv docs/backlogs/todo/phase1-001-user-auth.md \
   docs/backlogs/doing/

# Complete task: doing -> done
mv docs/backlogs/doing/phase1-001-user-auth.md \
   docs/backlogs/done/
```

### Claude Automatic Handling

**Task start trigger**:
- "proceed", "let's start", "I'll do it", "let's try"
- -> Move Task file to `doing/`

**Task completion trigger**:
- When all Acceptance Criteria of a Task are met
- -> Move Task file to `done/`

---

## README.md Updates

Also update README.md when status changes:

1. **Status counts**: Refresh Todo/Doing/Done counts
2. **Task links**: Update to new paths
3. **Status display**: Change emoji

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

When a user [action], they get [result].

## Acceptance Criteria

- [ ] Criteria 1
- [ ] Criteria 2
- [ ] Criteria 3

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

> See "Backlog/Story Writing Principles" in CLAUDE.md

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
- Implementation methods
- File/folder structure

### Reason
```
"Design and implementation grow together through the process of thinking"

Deciding everything upfront:
- Removes opportunity to think it through
- May result in decisions that don't fit the situation
- Reduces flexibility

Deciding at implementation time:
- Best choices possible
- Decisions fit the current situation
- Opportunity to learn and grow
```

---

**Last Updated**: {LAST_UPDATE_DATE}
