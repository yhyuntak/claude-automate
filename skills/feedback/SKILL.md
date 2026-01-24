---
name: feedback
description: User feedback system for recording improvements, bugs, and ideas. Auto-activates on keywords like "feedback"/"피드백", "check"/"확인", "save"/"저장", "improvement"/"개선", "bug"/"버그", etc.
user-invocable: true
argument-hint: "[check|options]"
---

# Feedback System

$ARGUMENTS

This skill activates automatically when it detects user feedback intent.
Explicit invocation via `/feedback` is also supported.

---

## Intent Detection

| User Intent | Action |
|-------------|--------|
| Save feedback ("save this", "record it", "add feedback") | Extract content from context → save |
| View feedback ("what do I have?", "list", "check") | Display feedback list as table |
| Mark feedback done ("mark done", "completed") | Find feedback in context → update status |

---

## Save Feedback

1. Extract feedback content from conversation context
2. Construct JSON using schema.md
3. Save to file

**Save path**: `~/.claude/feedback/{YYYY-MM-DD}.jsonl`

---

## View Feedback

Display feedback list as table:

| # | Status | Date | Project | Type | Content (Summary) | Tags |
|---|--------|------|---------|------|-------------------|------|

**Filter options** (natural language or arguments):
- `open` / `done` - by status
- `today` - today only
- `bug` / `idea` / `improvement` - by type

---

## Mark Feedback Done

"Mark the feedback I just worked on as done" or "Complete the backlog feedback"

1. Identify which feedback from conversation context
2. Find feedback in `~/.claude/feedback/`
3. Change `"status": "open"` → `"status": "done"`
4. Save file

---

## Usage Examples

Natural language:
- "Save this as feedback"
- "What feedback do I have?"
- "Mark this one done"

Explicit commands:
- `/feedback` - view feedback list
- `/feedback check open` - open items only
- `/feedback today` - today's feedback only

---

## Reference Files

- Schema: schema.md
- Examples: examples.md
