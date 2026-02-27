# Interaction Rule

Rules for interaction between Claude Code and users.

## AskUserQuestion Usage Principles

### Required: multiSelect default value

```json
{
  "multiSelect": true
}
```

**All questions must use `multiSelect: true` as the default.**

### Reason

| multiSelect: false | multiSelect: true |
|-------------------|-------------------|
| Single selection only | Single **or** multiple selection |
| Restrictive | Flexible |
| Requires re-asking when user wants multiple options | Resolved in one go |

**multiSelect: true includes all functionality of multiSelect: false.**
- User can select just 1 if desired
- User can select multiple if desired
- Provides better UX

### Exceptions

Use `multiSelect: false` **only** in the following cases:

1. **Mutually exclusive selection**: Logically only one can be selected
   - Example: "Which branch should be the base?" (main vs develop)
   - Example: "Which model should be used?" (haiku vs sonnet vs opus)

2. **Sequential selection**: Next question changes based on previous selection
   - Example: "How would you like to proceed?" → follow-up question varies by selection

### Checklist

Before using AskUserQuestion:

- [ ] Is `multiSelect: true` set?
- [ ] Is the question mutually exclusive? (No → keep multiSelect: true)
- [ ] Is there a chance the user wants to select multiple options? (Yes → keep multiSelect: true)

### Good Example

```json
{
  "questions": [{
    "question": "What features would you like to add?",
    "header": "Feature Selection",
    "multiSelect": true,
    "options": [
      {
        "label": "Authentication system",
        "description": "JWT-based user authentication"
      },
      {
        "label": "File upload",
        "description": "S3-integrated file upload"
      },
      {
        "label": "Notification system",
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
  "multiSelect": false  // Do not use as default
}
```

User can only select one even if they want multiple features → poor UX

## Scope of Application

- All commands
- All skills
- All agents
- Questions during Claude Code conversation

## Purpose

**Minimize typing, maximize UX** - allow users to respond with clicks rather than typing long text.
