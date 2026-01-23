---
name: explain-skills
description: Claude Code Skills system guide. Explains how to write skills, folder structure, and configuration methods.
argument-hint: "[topic]"
---

# Claude Code Skills Guide

$ARGUMENTS

---

## 📚 Complete Documentation

This skill provides quick reference for Claude Code Skills. For comprehensive documentation:

- **[Agent Skills Open Standard](references/agentskills-spec.md)** - The complete agentskills.io specification with progressive disclosure, validation, and best practices
- **[Claude Code Extensions](references/claude-code-extensions.md)** - Claude Code-specific features including invocation control, subagents, hooks, and advanced configurations

**Quick overview below** | **Deep dive in references** ↑

---

## 1. Skills vs Commands

| Category | Commands (Legacy) | Skills (Current Standard) |
|----------|-------------------|--------------------------|
| Path | `.claude/commands/name.md` | `.claude/skills/name/SKILL.md` |
| Supported Files | Single file only | Directory structure supported |
| Invocation | `/name` | `/name` (same) |
| Additional Features | Limited | Frontmatter, auto-load control, support files |

**Recommendation**: Write new features as Skills

---

## 2. Folder Structure

### Basic Structure
```
.claude/skills/<skill-name>/
├── SKILL.md          # Required - main instructions
├── reference.md      # Optional - detailed docs
├── examples.md       # Optional - usage examples
└── scripts/          # Optional - executable scripts
```

### Priority by Location
1. Enterprise (organization-wide)
2. Personal `~/.claude/skills/` (all projects)
3. Project `.claude/skills/` (current project only)
4. Plugin `<plugin>/skills/`

---

## 3. SKILL.md Structure

```markdown
---
name: my-skill                          # Slash command name
description: What this skill does       # Used by Claude for auto-trigger
argument-hint: "[args]"                 # Autocomplete hint
disable-model-invocation: true          # Manual invocation only (optional)
user-invocable: false                   # Hide from menu (optional)
allowed-tools: Read, Grep, Bash         # Restrict allowed tools (optional)
context: fork                           # Run subagent independently (optional)
agent: Explore                          # Subagent type (optional)
---

Actual instructions go here.

$ARGUMENTS  ← User arguments are inserted at this position
```

---

## 4. Frontmatter Fields Reference

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Name to use instead of directory name |
| `description` | string | Referenced by Claude for auto-load decision |
| `argument-hint` | string | Displayed as `/skill [hint]` |
| `disable-model-invocation` | boolean | `true` = manual invocation only |
| `user-invocable` | boolean | `false` = user cannot invoke (for background knowledge) |
| `allowed-tools` | string[] | List of permitted tools |
| `context` | string | `fork` = run as subagent |
| `agent` | string | Subagent type (Explore, Plan, etc.) |

---

## 5. Invocation Matrix

| Setting | User Invocation | Claude Auto-Invocation |
|---------|-----------------|------------------------|
| Default | ✅ `/skill` | ✅ Auto |
| `disable-model-invocation: true` | ✅ `/skill` | ❌ Disabled |
| `user-invocable: false` | ❌ Disabled | ✅ Auto |

### When to Use What?
- **Default**: General helper functions
- **disable-model-invocation**: Tasks with side effects (deploy, delete, commit)
- **user-invocable: false**: Background knowledge, context information

---

## 6. String Substitutions

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed by user |
| `${CLAUDE_SESSION_ID}` | Current session ID |

### Dynamic Command Execution
```markdown
## PR Information
!`gh pr view`

Please summarize the PR above.
```
Use `!`command`` format to execute shell command and insert result

---

## 7. Real-World Examples

### Example 1: Code Explanation (Auto-Load)
```markdown
---
name: explain-code
description: Explain code with diagrams and analogies. Use when explaining complex code.
---

When explaining code:
1. Start with everyday analogy
2. Show flow with ASCII diagram
3. Step-by-step explanation
```

### Example 2: Deployment (Manual Only)
```markdown
---
name: deploy
description: Production deployment
disable-model-invocation: true
allowed-tools: Bash
---

Deploy to $ARGUMENTS environment:
1. npm test
2. npm build
3. Execute deployment
```

### Example 3: API Conventions (Background Knowledge)
```markdown
---
name: api-conventions
description: API design rules
user-invocable: false
---

When writing REST API:
- GET /resources/{id}
- POST /resources
- Errors: { "error": "...", "code": "..." }
```

---

## 8. Checklist

- [ ] Create `.claude/skills/<name>/SKILL.md`
- [ ] Write `description` (basis for Claude auto-trigger)
- [ ] Add `disable-model-invocation: true` if has side effects
- [ ] Add support files to same directory if needed
- [ ] Test with `/skill-name`

---

## Reference Materials

### 📖 This Skill's Documentation
- [Agent Skills Open Standard](references/agentskills-spec.md) - Complete agentskills.io specification
- [Claude Code Extensions](references/claude-code-extensions.md) - Claude Code-specific features

### 🌐 External Resources
- [agentskills.io](https://agentskills.io) - Official open standard
- [Claude Code Skills Guide](https://code.claude.com/docs/skills) - Official Claude Code docs
- [Example Skills](https://github.com/anthropics/skills) - Anthropic's example repository
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) - Community resources
