# Feedback JSON Schema

## Required Fields

| Field | Type | Description |
|-------|------|-------------|
| timestamp | string | ISO 8601 format (e.g., 2026-01-22T23:30:00+09:00) |
| session_id | string | Current session ID |
| project | string | Current project name |
| user_feedback | string | Original feedback text |
| type | enum | wrap, idea, improvement, bug, general |
| status | enum | open, done |
| tags | string[] | Auto-generated tags |

## Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| context | object | Type-specific additional information |

---

## Type Classification Rules

| Keywords/Context | type |
|------------------|------|
| wrap-related suggestions, not useful | `wrap` |
| new feature needed, would be nice to have | `idea` |
| improve, change to, this way | `improvement` |
| error, doesn't work, bug, strange | `bug` |
| everything else | `general` |

---

## Context Structure (By Type)

### wrap
```json
{
  "suggestions": [
    {"index": 1, "title": "...", "content": "..."}
  ],
  "target_indices": [2]
}
```

### idea
```json
{
  "description": "New feature description",
  "related": "Related information"
}
```

### improvement
```json
{
  "target": "Target command/feature",
  "current": "Current behavior",
  "desired": "Desired behavior"
}
```

### bug
```json
{
  "target": "Target",
  "symptom": "Symptom",
  "steps": "Reproduction steps"
}
```

### general
```json
{
  "note": "Free-form note"
}
```

---

## Auto-Generated Tags

Extract keywords from context:
- Commands: `command`, `wrap`, `feedback`, `session`
- Agents: `agent`, `reader`, `analyzer`
- Features: `new-feature`, `improvement`, `bug`, `ux`

---

## Complete Example

```json
{
  "timestamp": "2026-01-22T23:30:00+09:00",
  "session_id": "abc-123-def",
  "project": "claude-automate",
  "user_feedback": "Add description column to /check-feedback",
  "type": "improvement",
  "status": "open",
  "context": {
    "target": "/check-feedback",
    "current": "# Status Date Project Type Content Tags",
    "desired": "# Status Date Project Type Content Description Tags"
  },
  "tags": ["command", "check-feedback", "ux"]
}
```
