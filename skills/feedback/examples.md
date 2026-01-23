# Feedback Examples

## Intent Detection Examples

| User Statement | Detected Intent | Action |
|----------------|-----------------|--------|
| "Save this as feedback" | write | `/write-feedback` |
| "Found a bug" | write (bug) | `/write-feedback` |
| "This needs improvement later, record it" | write | `/write-feedback` |
| "What feedback do I have?" | check | `/check-feedback` |
| "Mark feedback #2 as done" | done | update status |
| "Show only open feedback" | check open | `/check-feedback open` |

---

## Natural Language to Feedback Conversion Examples

### Case 1: Natural Conversation

```
User: I used the wrap feature and thought the results could be more concise.
      Save this as feedback.

Claude: (feedback skill auto-activates)
        Saving feedback.

        Type: improvement
        Content: wrap results could be more concise
        Tags: wrap, ux

        Save complete: ~/.claude/feedback/2026-01-22.jsonl
```

### Case 2: Explicit Command

```
User: /feedback write Please add dark mode

Claude: → /write-feedback Please add dark mode

        Type: idea
        Content: Please add dark mode
        Tags: new-feature, ui
```

### Case 3: View Feedback

```
User: Can I see my feedback list?

Claude: (feedback skill auto-activates)
        → /check-feedback

        | # | Status | Project | Type | Content |
        |---|--------|---------|------|---------|
        | 1 | 🔴 | my-app | 💡 | Add dark mode |
        | 2 | 🔴 | claude-automate | ✨ | Make wrap concise |

        Total: 2 items (🔴 open: 2)
```

### Case 4: Mark Feedback Done

```
User: Mark feedback #1 as done

Claude: (feedback skill auto-activates)

        Feedback #1 marked as done
        Content: Add dark mode
```

---

## Saved JSON Examples

### idea type

```json
{
  "timestamp": "2026-01-22T23:30:00+09:00",
  "session_id": "abc-123",
  "project": "my-app",
  "user_feedback": "Please add dark mode",
  "type": "idea",
  "status": "open",
  "context": {
    "description": "Add dark theme to app",
    "related": "Currently supports light mode only"
  },
  "tags": ["new-feature", "ui", "theme"]
}
```

### bug type

```json
{
  "timestamp": "2026-01-22T23:35:00+09:00",
  "session_id": "abc-123",
  "project": "claude-automate",
  "user_feedback": "Hook not working",
  "type": "bug",
  "status": "open",
  "context": {
    "target": "feedback-hint.sh",
    "symptom": "Feedback keywords not detected",
    "steps": "1. Enter feedback keyword 2. Hint not shown"
  },
  "tags": ["bug", "hook"]
}
```

### improvement type

```json
{
  "timestamp": "2026-01-22T23:40:00+09:00",
  "session_id": "abc-123",
  "project": "claude-automate",
  "user_feedback": "wrap output is too verbose",
  "type": "improvement",
  "status": "open",
  "context": {
    "target": "/wrap",
    "current": "Detailed analysis output",
    "desired": "Concise summary output"
  },
  "tags": ["wrap", "ux", "improvement"]
}
```
