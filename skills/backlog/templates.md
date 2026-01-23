# Backlog Templates

## Story Template

Use when adding new backlog items:

```markdown
# [Title]

> [One-line summary - appears in table description column]

## User Story

As a [role] I want [feature]. Because [reason].

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Why

[Why is this feature needed? What problem does it solve?]

## Dependencies

- [List predecessor work if applicable]
- "None" if no dependencies

## Notes

[Additional reference information]

---
Created: {DATE}
```

---

## Idea Template

Use when recording out-of-scope ideas:

```markdown
# [Title]

> [One-line summary]

## Description

[Detailed idea explanation]

## Motivation

[Why did this idea come up? In what context?]

## Related

- [Related features/issues]

## Priority Estimate

- Impact: [High/Medium/Low]
- Effort: [High/Medium/Low]

---
Created: {DATE}
```

---

## Filename Generation Rules

### Story

```
phase{N}-{ID}-{slug}.md
```

1. **Determine Phase**: Based on dependencies
   - No dependencies → Phase 1 or Phase 4
   - Depends on Phase 1 → Phase 2
   - Depends on Phase 2 → Phase 3

2. **Assign ID**: Next number in that Phase
   ```bash
   ls docs/backlog/todo/phase1-* | wc -l  # Check existing count
   # Next number = existing count + 1 (3-digit padded)
   ```

3. **Generate Slug**: Convert title to kebab-case
   - "User Authentication" → `user-authentication`
   - "Immersion Mode" → `immersion-mode`

### Idea

```
idea-{ID}-{slug}.md
```

Or date-based:

```
idea-{YYYYMMDD}-{slug}.md
```

---

## Usage Examples

### Add New Story

```
User: "Add login feature to backlog"

Claude:
1. Determine phase → Phase 1 (foundation feature)
2. Check ID → 3 existing in phase1 → 004
3. Create file → phase1-004-login.md
4. Fill with template content
5. Save to docs/backlog/todo/
```

### Add Idea

```
User: "I'd like to add dark mode later"

Claude:
1. Use idea template
2. Create file → idea-001-dark-mode.md
3. Save to docs/backlog/ideas/
```
