---
id: P4
title: Security Guidance (Official Plugin)
author: Anthropic (David Dworken)
url: https://github.com/anthropics/claude-code/tree/main/plugins/security-guidance
fetched: 2026-02-15
---

# Security Guidance Plugin

## Overview

Security Guidance is a security-focused plugin (v1.0.0) that warns about potential security vulnerabilities when editing files. The plugin intercepts file editing operations and alerts developers about risky coding patterns before changes are committed.

## Core Mechanism

The plugin uses a **PreToolUse hook** that activates before Edit, Write, or MultiEdit operations. When triggered, it runs a Python script that analyzes file paths and content against a set of security patterns.

## Configuration

### Plugin Metadata
```json
{
  "name": "security-guidance",
  "version": "1.0.0",
  "description": "Security reminder hook that warns about potential security issues when editing files, including command injection, XSS, and unsafe code patterns",
  "author": {
    "name": "David Dworken",
    "email": "dworken@anthropic.com"
  }
}
```

### Hook Configuration
```json
{
  "description": "Security reminder hook that warns about potential security issues when editing files",
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 ${CLAUDE_PLUGIN_ROOT}/hooks/security_reminder_hook.py"
          }
        ],
        "matcher": "Edit|Write|MultiEdit"
      }
    ]
  }
}
```

## Security Patterns Detected

The plugin checks for 9 categories of security vulnerabilities:

### 1. GitHub Actions Workflow Injection
- **Pattern**: `.github/workflows/*.yml` or `*.yaml` files
- **Risk**: Command injection through untrusted inputs (issue titles, PR descriptions, commit messages)
- **Guidance**: Use environment variables instead of direct interpolation

### 2. Child Process Execution (Node.js)
- **Pattern**: `child_process.exec`, `exec()`, `execSync()`
- **Risk**: Command injection vulnerabilities
- **Guidance**: Use `execFile` or the codebase's `execFileNoThrow` utility

### 3. Dynamic Function Creation
- **Pattern**: `new Function`
- **Risk**: Code injection through arbitrary code evaluation
- **Guidance**: Consider alternative approaches that don't evaluate arbitrary code

### 4. Eval Usage
- **Pattern**: `eval()`
- **Risk**: Arbitrary code execution
- **Guidance**: Use `JSON.parse()` for data parsing or alternative design patterns

### 5. React dangerouslySetInnerHTML
- **Pattern**: `dangerouslySetInnerHTML`
- **Risk**: XSS vulnerabilities with untrusted content
- **Guidance**: Sanitize content with libraries like DOMPurify or use safe alternatives

### 6. Document.write XSS
- **Pattern**: `document.write`
- **Risk**: XSS attacks and performance issues
- **Guidance**: Use DOM manipulation methods like `createElement()` and `appendChild()`

### 7. innerHTML XSS
- **Pattern**: `.innerHTML =` or `.innerHTML=`
- **Risk**: XSS vulnerabilities with untrusted content
- **Guidance**: Use `textContent` for plain text or sanitize HTML with DOMPurify

### 8. Pickle Deserialization (Python)
- **Pattern**: `pickle`
- **Risk**: Arbitrary code execution with untrusted content
- **Guidance**: Use JSON or other safe serialization formats

### 9. OS System Command Injection (Python)
- **Pattern**: `os.system`, `from os import system`
- **Risk**: Command injection with user-controlled arguments
- **Guidance**: Use only with static arguments, never with user input

## Features

### Session-Based Warning State
- Warnings are shown once per session per file+pattern combination
- State files are stored in `~/.claude/security_warnings_state_{session_id}.json`
- Automatic cleanup of state files older than 30 days (10% chance per run)

### Blocking Behavior
- When a pattern is detected, the hook exits with code 2 to block tool execution
- Warning is displayed to stderr
- User can proceed after acknowledging the warning

### Configuration
- Can be disabled by setting `ENABLE_SECURITY_REMINDER=0` environment variable
- Debug logging available to `/tmp/security-warnings-log.txt`

## Implementation Details

### Pattern Matching
The hook uses two types of pattern matching:

1. **Path-based**: Checks if file path matches specific patterns
   - Example: GitHub Actions workflow files in `.github/workflows/`

2. **Content-based**: Searches for specific substrings in file content
   - Example: `eval(`, `innerHTML =`, `pickle`, etc.

### Warning Format
Each warning includes:
- Description of the security risk
- Explanation of the vulnerability
- Safe alternatives or best practices
- Code examples showing unsafe vs. safe patterns

## Use Cases

**Recommended for:**
- Preventing common security vulnerabilities during development
- Educational reminders about secure coding practices
- Catching risky patterns before code review

**Not recommended for:**
- Complete security audit replacement
- Zero-false-positives requirement (pattern matching has limitations)
- Performance-critical operations (adds overhead to file edits)

## Technical Architecture

```
File Edit Operation (Edit/Write/MultiEdit)
    ↓
PreToolUse Hook Triggered
    ↓
Python Script Execution (security_reminder_hook.py)
    ↓
Pattern Matching (path + content)
    ↓
Session State Check (already shown?)
    ↓
Warning Display + Block (exit code 2) OR Allow (exit code 0)
```

## Example Warning

For GitHub Actions workflow injection:
```
You are editing a GitHub Actions workflow file. Be aware of these security risks:

1. Command Injection: Never use untrusted input directly in run: commands
2. Use environment variables: Instead of ${{ github.event.issue.title }}, use env:

Example of UNSAFE pattern to avoid:
run: echo "${{ github.event.issue.title }}"

Example of SAFE pattern:
env:
  TITLE: ${{ github.event.issue.title }}
run: echo "$TITLE"
```
