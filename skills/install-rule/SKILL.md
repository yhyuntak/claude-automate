---
name: install-rule
description: Install project rules to global Claude Code rules directory
user-invocable: true
argument-hint: ""
---

# Install Project Rules Globally

$ARGUMENTS

This skill copies rules from the plugin's references to `~/.claude/rules/` so they apply to all Claude Code sessions.

---

## Purpose

- Make project conventions globally available
- Ensure consistent behavior across all sessions
- Override existing rules with project-specific versions

---

## Process

### 1. Create Target Directory

```bash
mkdir -p ~/.claude/rules
```

---

### 2. Install Rules

Copy all reference files to global rules directory:

```bash
cp -f skills/install-rule/references/*.md ~/.claude/rules/
```

**Important:** Use `-f` flag to force overwrite existing files.

---

### 3. Report Installation

List the installed files:

```bash
ls -1 ~/.claude/rules/
```

Output format:

```markdown
## ✅ Rules Installed

Installed to `~/.claude/rules/`:

- interaction.md
- backlog-rules.md
- workflow.md

**Total:** 3 rules

These rules will apply to all Claude Code sessions.

---

💡 To update rules, run `/install-rule` again after plugin updates.
```

---

## Usage

```bash
/install-rule              # Install all rules
```

---

## Rule Management

| Action | Command |
|--------|---------|
| Install/Update rules | `/install-rule` |
| Remove rule | Delete from `~/.claude/rules/` |
| List installed rules | `ls ~/.claude/rules/` |

---

## Included Rules

- **interaction.md** - AskUserQuestion UX rules
- **backlog-rules.md** - Backlog management (todo/doing/done)
- **workflow.md** - Git branching and release strategies

---

## Notes

- Rules in `~/.claude/rules/` apply globally to all projects
- Rules are included in the skill's `references/` folder
- Re-run `/install-rule` after plugin updates to sync rules
- Existing files are automatically overwritten (no backup)
