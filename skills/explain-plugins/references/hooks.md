# Hooks Reference

> Event handlers for automating Claude Code workflows

---

## Overview

Hooks are event handlers that execute automatically when specific events occur in Claude Code. They enable automation, validation, logging, and custom workflows.

---

## Hook Location

**In Plugin**: `hooks/hooks.json`

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "pattern",
        "hooks": [
          {
            "type": "command",
            "command": "your-command"
          }
        ]
      }
    ]
  }
}
```

**In Settings**: `~/.claude/settings.json` or `.claude/settings.local.json`

```json
{
  "hooks": {
    "PostToolUse": [...]
  }
}
```

---

## Available Events

| Event | Trigger | Common Use Cases |
|-------|---------|------------------|
| `SessionStart` | Session begins | Load context, show status |
| `SessionEnd` | Session ends | Save state, cleanup |
| `UserPromptSubmit` | User sends message | Input validation, logging |
| `PreToolUse` | Before tool execution | Validation, confirmation |
| `PostToolUse` | After tool execution | Linting, formatting, logging |
| `PreCompact` | Before context compaction | Save important context |
| `Stop` | Before session stops | Final cleanup, save state |
| `SubagentStop` | Subagent completes | Process results |
| `Notification` | Notification occurs | Custom notifications |

---

## Hook Configuration

### Basic Structure

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint:fix $FILE",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### Hook Types

**Command Hook**
```json
{
  "type": "command",
  "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh",
  "timeout": 30
}
```

**Script Hook** (inline script)
```json
{
  "type": "script",
  "script": "echo 'Processing: $FILE'",
  "timeout": 10
}
```

---

## Matchers

Matchers filter which events trigger the hook.

### Tool Matchers (PreToolUse, PostToolUse)

```json
{
  "matcher": "Write|Edit"
}
```

| Pattern | Matches |
|---------|---------|
| `Write` | Only Write tool |
| `Write\|Edit` | Write or Edit tools |
| `Bash` | Only Bash tool |
| `*` | All tools |

### Path Matchers

```json
{
  "matcher": "Write|Edit",
  "pathPattern": "**/*.ts"
}
```

---

## Environment Variables

Available in hook commands:

| Variable | Description | Available In |
|----------|-------------|--------------|
| `$FILE` | File path being operated on | PostToolUse (Write/Edit) |
| `$TOOL_INPUT` | Tool input JSON | PreToolUse, PostToolUse |
| `$TOOL_OUTPUT` | Tool output | PostToolUse |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin root directory | All hooks |
| `${CLAUDE_SESSION_ID}` | Current session ID | All hooks |

---

## Common Patterns

### Auto-Lint on File Save

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "pathPattern": "**/*.{ts,tsx,js,jsx}",
        "hooks": [
          {
            "type": "command",
            "command": "npx eslint --fix $FILE",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### Format on Save

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "pathPattern": "**/*.py",
        "hooks": [
          {
            "type": "command",
            "command": "black $FILE",
            "timeout": 15
          }
        ]
      }
    ]
  }
}
```

### Session Start Context

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "cat ~/.claude/context/session-context.md"
          }
        ]
      }
    ]
  }
}
```

### Session End Save

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/save-session.sh"
          }
        ]
      }
    ]
  }
}
```

### Validate Before Tool Use

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate-command.sh"
          }
        ]
      }
    ]
  }
}
```

### User Input Processing

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/log-prompt.sh"
          }
        ]
      }
    ]
  }
}
```

---

## Hook Response

Hooks can return JSON to influence Claude's behavior:

### Continue (default)
```json
{"continue": true}
```

### Block with Message
```json
{
  "continue": false,
  "message": "Operation blocked: reason here"
}
```

### Inject Context
```json
{
  "continue": true,
  "context": "Additional context for Claude to consider"
}
```

---

## Timeout Handling

- Default timeout: 30 seconds
- Set custom timeout per hook
- Timed out hooks are treated as failed
- Failed hooks don't block execution (unless configured)

```json
{
  "type": "command",
  "command": "long-running-script.sh",
  "timeout": 120
}
```

---

## Debugging Hooks

1. **Check hook output**: Hook stdout/stderr appears in Claude Code logs
2. **Test commands manually**: Run hook commands outside Claude Code first
3. **Use echo for debugging**: Add `echo` statements to trace execution
4. **Check file paths**: Verify `${CLAUDE_PLUGIN_ROOT}` resolves correctly

---

## Best Practices

### Performance
- Keep hooks fast (<5 seconds for common operations)
- Use async processing for heavy tasks
- Set appropriate timeouts

### Safety
- Validate inputs before processing
- Handle errors gracefully
- Don't block critical operations unnecessarily

### Organization
- Group related hooks in separate files
- Use descriptive script names
- Document hook purposes
