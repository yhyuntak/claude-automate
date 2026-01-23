---
name: interaction-rules
description: Always use multiSelect true in AskUserQuestion for optimal UX. Auto-activated when asking user questions.
---

# Interaction Rules

Rules that always apply when interacting with users.

## AskUserQuestion Required Rule

### multiSelect: true as Default

**Always use `multiSelect: true` in all AskUserQuestion calls.**

```json
{
  "questions": [{
    "question": "Your question here",
    "header": "Header",
    "multiSelect": true,  // ← Required!
    "options": [...]
  }]
}
```

### Rationale

| multiSelect: false | multiSelect: true |
|-------------------|-------------------|
| Single selection only | Single **or** multiple selection |
| Restrictive | Flexible |
| Requires re-asking if user wants multiple | Handles both cases at once |

**multiSelect: true includes all functionality of multiSelect: false.**
- User can select just 1 option if desired
- User can select multiple options if desired
- Better UX overall

### Exceptions

Use `multiSelect: false` **only** in these cases:

1. **Mutually exclusive choices**: Logically only one can be selected
   - Example: "Which branch to use as base?" (main vs develop)
   - Example: "Which model to use?" (haiku vs sonnet vs opus)

2. **Sequential choices**: Next question depends on this answer
   - Example: "How to proceed?" → Different follow-up questions

### Good Example

```json
{
  "questions": [{
    "question": "Which features to add?",
    "header": "Feature selection",
    "multiSelect": true,
    "options": [
      {
        "label": "Authentication",
        "description": "JWT-based user auth"
      },
      {
        "label": "File upload",
        "description": "S3-integrated file upload"
      },
      {
        "label": "Notifications",
        "description": "Email/SMS notifications"
      }
    ]
  }]
}
```

User can select as many as needed (1 is OK, 3 is OK)

### Bad Example

```json
{
  "multiSelect": false  // ❌ Do NOT use as default!
}
```

User wants multiple features but can only select one → Bad UX

## Checklist

Before using AskUserQuestion:

- [ ] Set `multiSelect: true`?
- [ ] Are choices mutually exclusive? (No → keep multiSelect: true)
- [ ] Could user want multiple options? (Yes → keep multiSelect: true)

## Purpose

**Minimize typing, maximize UX**

Enable users to respond with clicks instead of typing long text.
