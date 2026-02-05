---
name: install-rule
description: Install project rules to global Claude Code rules directory
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

### Step 1: Prepare target directory (force overwrite)

Use Bash tool to create directory and **delete existing files**:

```bash
mkdir -p ~/.claude/rules && rm -f ~/.claude/rules/interaction.md ~/.claude/rules/backlog-rules.md ~/.claude/rules/workflow.md ~/.claude/rules/agent-delegation.md
```

**⚠️ 기존 파일이 있어도 무조건 삭제 후 새로 작성합니다.**

### Step 2: Install each rule file

Use the **Write tool** to create each rule file in `~/.claude/rules/` using the content from the references that are automatically loaded:

1. **interaction.md** - Write to `~/.claude/rules/interaction.md`
   - Use the content from `references/interaction.md` (in your context)

2. **backlog-rules.md** - Write to `~/.claude/rules/backlog-rules.md`
   - Use the content from `references/backlog-rules.md` (in your context)

3. **workflow.md** - Write to `~/.claude/rules/workflow.md`
   - Use the content from `references/workflow.md` (in your context)

4. **agent-delegation.md** - Write to `~/.claude/rules/agent-delegation.md`
   - Use the content from `references/agent-delegation.md` (in your context)

### Step 3: Confirm installation

After successfully writing all three files, display this confirmation:

---

## ✅ Rules Installed

Installed to `~/.claude/rules/`:

- **interaction.md** - AskUserQuestion UX rules
- **backlog-rules.md** - Backlog management (todo/doing/done)
- **workflow.md** - Git branching and release strategies
- **agent-delegation.md** - 에이전트 위임 규칙 (explore, writer)

**Total:** 4 rules

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
- **agent-delegation.md** - 에이전트 위임 규칙 (explore, writer)

---

## Notes

- Rules in `~/.claude/rules/` apply globally to all projects
- Rules are included in the skill's `references/` folder
- Re-run `/install-rule` after plugin updates to sync rules
- Existing files are automatically overwritten (no backup)
