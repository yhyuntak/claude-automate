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

---

## Source Code Mechanism Analysis (2026-02-15)

### Hook 동작 상세

**입력 (stdin JSON)**:
```json
{
  "session_id": "abc123",
  "tool_name": "Edit",
  "tool_input": { "file_path": "...", "new_string": "..." }
}
```

**처리 로직**:
1. 파일 경로/내용 추출
2. `SECURITY_PATTERNS` 배열 순회 → path_check 또는 substring 매칭
3. 세션 상태 확인 (`~/.claude/security_warnings_state_{session_id}.json`)
4. warning_key = `{file_path}-{rule_name}` → 중복 체크
5. 신규 → stderr 경고 + exit(2) 차단 / 중복 → exit(0) 통과

### Exit Code Protocol

| Exit Code | 의미 | 결과 |
|-----------|------|------|
| 0 | 정상 통과 | 툴 실행 진행 |
| 1 | 에러 | 비정상 종료 |
| 2 | 보안 경고 | 툴 실행 차단 |

### 선언적 패턴 설정 구조

```python
SECURITY_PATTERNS = [
    {
        "ruleName": "eval_injection",
        "substrings": ["eval("],
        "reminder": "⚠️ eval() 사용 감지..."
    },
    {
        "ruleName": "github_actions_workflow",
        "path_check": lambda path: ".github/workflows/" in path,
        "reminder": "⚠️ GitHub Actions 워크플로우..."
    }
]
```

**확장**: 배열에 새 dict 추가만으로 커스텀 룰 생성 가능

### 세션 상태 관리

- 파일: `~/.claude/security_warnings_state_{session_id}.json`
- 키: `{file_path}-{rule_name}` → 같은 조합은 세션 내 1회만 경고
- 정리: 30일 이상 파일을 10% 확률로 자동 삭제 (Probabilistic Cleanup)
- Fail-Safe: 상태 저장 실패해도 Hook 자체는 정상 동작

### claude-automate 차용 패턴

1. **선언적 패턴 설정**: 룰 데이터와 로직 분리 (pattern-checker에 적용)
2. **Session-Scoped State**: 중복 경고 방지 메커니즘
3. **Exit Code Protocol**: Hook 표준 프로토콜 (0=통과, 2=차단)
4. **Probabilistic Cleanup**: 상태 파일 자동 정리
5. **Fail-Safe Error Handling**: Hook 실패가 워크플로우를 막지 않음
