---
description: Install project rules to global Claude Code rules directory
---

[INSTALL RULE MODE ACTIVATED]

$ARGUMENTS

---

## /install-rule: Install Project Rules Globally

Copies rules from `rules/` folder to `~/.claude/rules/` so they apply to all Claude Code sessions.

**Purpose:**
- Make project conventions globally available
- Ensure consistent behavior across all sessions
- Override existing rules with project-specific versions

---

## Process

### 1. Check Rules Directory

```bash
ls rules/*.md 2>/dev/null
```

If no rules found:
```markdown
❌ No rules found in rules/ directory.
```

Exit.

---

### 2. Create Target Directory

```bash
mkdir -p ~/.claude/rules
```

---

### 3. Install Rules

For each `.md` file in `rules/`:

```bash
cp -f rules/*.md ~/.claude/rules/
```

**Important:** Use `-f` flag to force overwrite existing files.

---

### 4. Report Installation

```markdown
## ✅ Rules Installed

Installed to `~/.claude/rules/`:

- interaction.md
- backlog-rules.md
- workflow.md

**Total:** 3 rules

These rules will apply to all Claude Code sessions.

---

💡 To update rules, run `/install-rule` again after editing `rules/*.md`.
```

---

## Usage Examples

```bash
/install-rule              # Install all rules
```

---

## Rule Management

| Action | Command |
|--------|---------|
| Install/Update rules | `/install-rule` |
| Edit rules | Edit `rules/*.md` files |
| Remove rule | Delete from `~/.claude/rules/` |
| List installed rules | `ls ~/.claude/rules/` |

---

## Related Files

- `rules/interaction.md` - AskUserQuestion UX rules
- `rules/backlog-rules.md` - Backlog management (todo/doing/done)
- `rules/workflow.md` - Git branching and release strategies

---

## Notes

- Rules in `~/.claude/rules/` apply globally to all projects
- Project-specific `rules/` folder is for source control
- Re-run `/install-rule` after updating rules to apply changes
- Existing files are automatically overwritten (no backup)
