# Interaction Rule

Rules for interaction between Claude Code and users.

## AskUserQuestion Usage Principles

### Required: multiSelect default value

```json
{
  "multiSelect": true
}
```

**`multiSelect: true` must be used as the default in all questions.**

### Rationale

| multiSelect: false | multiSelect: true |
|-------------------|-------------------|
| Single selection only | Single **or** multiple selection |
| Restrictive | Flexible |
| Requires follow-up when user wants multiple options | Resolved in one step |

**multiSelect: true includes all the functionality of multiSelect: false.**
- User can select just 1 option if desired
- User can select multiple options if desired
- Provides a better UX

### Exceptions

Use `multiSelect: false` **only** in these cases:

1. **Mutually exclusive choices**: When logically only one option can be selected
   - Example: "Which branch should be the base?" (main vs develop)
   - Example: "Which model should be used?" (haiku vs sonnet vs opus)

2. **Sequential choices**: When the next question depends on the previous selection
   - Example: "How would you like to proceed?" → follow-up questions change based on selection

### Checklist

Before using AskUserQuestion:

- [ ] Is `multiSelect: true` set?
- [ ] Are the choices mutually exclusive? (No → keep multiSelect: true)
- [ ] Is there a chance the user wants to select multiple options? (Yes → keep multiSelect: true)

### Good Example

```json
{
  "questions": [{
    "question": "Which features would you like to add?",
    "header": "Feature Selection",
    "multiSelect": true,
    "options": [
      {
        "label": "Authentication System",
        "description": "JWT-based user authentication"
      },
      {
        "label": "File Upload",
        "description": "S3-integrated file upload"
      },
      {
        "label": "Notification System",
        "description": "Email/SMS notifications"
      }
    ]
  }]
}
```

User can select as many as needed (1 is OK, all 3 are OK)

### Bad Example

```json
{
  "multiSelect": false  // Do not use as default
}
```

Even if user wants multiple features, only one can be selected → poor UX

## Scope of Application

- All commands
- All skills
- All agents
- Questions during Claude Code conversations

## Purpose

**Minimize typing, maximize UX** - Allow users to respond with clicks instead of typing long text.
