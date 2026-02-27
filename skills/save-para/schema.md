# save-para Schema

## Input

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| content | string | Y | Content to save (user input) |
| category | string | Y | Category (dynamically retrieved from README.md) |
| title | string | Y | Document title |
| tags | string[] | N | List of tags |

---

## Output

| Field | Type | Description |
|-------|------|-------------|
| file_path | string | Path of the created file |
| category | string | Category where saved |
| indexes_updated | string[] | List of updated READMEs |

---

## File Template

```markdown
---
title: {title}
created: {YYYY-MM-DD}
tags: [{tags}]
source: claude-session
---

# {title}

{content}

---

## Related Documents

-
```

---

## Category Lookup (Dynamic)

**No hardcoding** - look up from README.md at runtime

```
Lookup path: ~/workspace/mynotes/Resources/README.md
Lookup location: "Categories" table or "Classification Criteria" table
```

The category list is managed in mynotes; this skill only references it.

---

## Tag Guide

| Tag | Usage |
|-----|-------|
| #concurrency | Concurrency related |
| #security | Security related |
| #performance | Performance related |
| #pattern | Design patterns |
| #troubleshooting | Problem solving |
| #how-to | Guides/tutorials |
