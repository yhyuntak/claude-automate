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

**IMPORTANT:** The rules are included in this skill's `references/` folder and are automatically loaded into your context. Use the **Write tool** to create each rule file in `~/.claude/rules/`:

1. Write `~/.claude/rules/interaction.md` using content from `references/interaction.md`
2. Write `~/.claude/rules/backlog-rules.md` using content from `references/backlog-rules.md`
3. Write `~/.claude/rules/workflow.md` using content from `references/workflow.md`

**Do NOT use bash cp or cat commands.** The references are in your context, use Write tool directly.

---

### 3. Report Installation

After writing all files, confirm with:

```markdown
## ✅ Rules Installed

Installed to `~/.claude/rules/`:

- interaction.md (AskUserQuestion UX rules)
- backlog-rules.md (Backlog management)
- workflow.md (Git branching and release)

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
