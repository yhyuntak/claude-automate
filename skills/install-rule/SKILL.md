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

## Instructions

The rules files are included in this skill's `references/` folder and are automatically loaded into your context when this skill runs.

### Step 1: Create target directory

Use Bash tool to create the global rules directory:
- Command: `mkdir -p ~/.claude/rules`

### Step 2: Install each rule file

Use the **Write tool** to create each rule file in `~/.claude/rules/` using the content from the references that are automatically loaded:

1. **interaction.md** - Write to `~/.claude/rules/interaction.md`
   - Use the content from `references/interaction.md` (in your context)

2. **backlog-rules.md** - Write to `~/.claude/rules/backlog-rules.md`
   - Use the content from `references/backlog-rules.md` (in your context)

3. **workflow.md** - Write to `~/.claude/rules/workflow.md`
   - Use the content from `references/workflow.md` (in your context)

### Step 3: Confirm installation

After successfully writing all three files, display this confirmation:

---

## ✅ Rules Installed

Installed to `~/.claude/rules/`:

- **interaction.md** - AskUserQuestion UX rules
- **backlog-rules.md** - Backlog management (todo/doing/done)
- **workflow.md** - Git branching and release strategies

**Total:** 3 rules

These rules will apply to all Claude Code sessions.

---

💡 To update rules, run `/install-rule` again after plugin updates.

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
