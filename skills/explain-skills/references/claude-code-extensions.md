# Claude Code Extensions to Agent Skills

> Claude Code-specific features extending the agentskills.io open standard

Claude Code supports the full [Agent Skills open standard](agentskills-spec.md) and adds additional features for better control and integration.

---

## Additional Frontmatter Fields

Claude Code extends the standard frontmatter with these fields:

```yaml
---
# Standard fields (from agentskills.io)
name: my-skill
description: What this skill does...

# Claude Code specific extensions
argument-hint: "[args]"              # Autocomplete hint
disable-model-invocation: true       # Prevent Claude auto-load
user-invocable: false                # Hide from user menu
allowed-tools: Bash Read             # Permission pre-approval
model: sonnet                        # Model override
context: fork                        # Subagent isolation
agent: Explore                       # Subagent type
hooks: {...}                         # Lifecycle hooks
---
```

---

## Invocation Control

### `disable-model-invocation: true`

**Effect:** Prevents Claude from automatically loading the skill.

**Behavior:**
- Skill description **NOT** included in Claude's context at startup
- Only users can invoke via `/skill-name`
- Claude cannot discover or activate this skill

**Use cases:**
- Actions with side effects (deployment, commits, database changes)
- Timing-sensitive operations
- Operations requiring explicit user approval

**Example:**
```yaml
---
name: deploy
description: Deploy application to production
disable-model-invocation: true
---

Deploy $ARGUMENTS to production:

1. Run test suite
2. Build application
3. Push to deployment target
4. Verify deployment success
```

### `user-invocable: false`

**Effect:** Prevents users from manually invoking the skill.

**Behavior:**
- Skill description **IS** included in Claude's context at startup
- Claude can auto-load when relevant
- Skill hidden from `/` autocomplete menu
- Users cannot call `/skill-name`

**Use cases:**
- Background knowledge/reference content
- Context that Claude should know but isn't a user command
- Architectural documentation
- Legacy system explanations

**Example:**
```yaml
---
name: legacy-system-context
description: Explains architecture and quirks of the legacy backend system
user-invocable: false
---

# Legacy Backend System

This system was built in 2015 using Ruby on Rails...
```

---

## Invocation Behavior Matrix

| Frontmatter | User Can Invoke | Claude Can Invoke | Description in Context |
|---|---|---|---|
| (default) | ✅ Yes | ✅ Yes | ✅ Yes |
| `disable-model-invocation: true` | ✅ Yes | ❌ No | ❌ No |
| `user-invocable: false` | ❌ No | ✅ Yes | ✅ Yes |
| Both set to restrict | ✅ Yes | ❌ No | ❌ No |

---

## `argument-hint` Field

Shows expected arguments in autocomplete and help text.

```yaml
---
name: review-pr
argument-hint: "[pr-number]"
---
```

**Displays as:** `/review-pr [pr-number]`

**Best practices:**
- Use square brackets for required args: `[required]`
- Use angle brackets for optional: `<optional>`
- Examples: `[issue-id]`, `<branch-name>`, `[source] [target]`

---

## `allowed-tools` Field

Pre-approve specific tools for use during skill execution, bypassing permission prompts.

```yaml
---
name: git-helper
allowed-tools: Bash(git:*) Read Grep
---
```

**Syntax:**
- Tool names: `Bash`, `Read`, `Edit`, `Write`, `Grep`, `Glob`
- Patterns: `Bash(git:*)` allows only git commands
- Multiple tools: Space-delimited list

**Security note:** Use with caution. Only pre-approve safe, well-scoped tools.

---

## `model` Field

Override the default model for this skill's execution.

```yaml
---
name: complex-analysis
model: opus
---
```

**Valid values:**
- `haiku` - Fast, cost-effective
- `sonnet` - Balanced (default)
- `opus` - Most capable

**Use cases:**
- Complex reasoning tasks → `opus`
- Simple, repetitive tasks → `haiku`
- Default balanced work → `sonnet`

---

## `context` and `agent` Fields

Run the skill in an isolated subagent context.

```yaml
---
name: deep-search
context: fork
agent: Explore
---
```

### `context: fork`

Creates an isolated execution environment:
- Separate conversation history
- Independent tool permissions
- Isolated file operations
- Results returned to parent agent

### `agent` Field

Specify subagent type (requires `context: fork`):

| Agent Type | Model | Use Case |
|---|---|---|
| `Explore` | Haiku | Fast codebase search |
| `Plan` | Opus | Strategic planning |
| `general-purpose` | Sonnet | Multi-step tasks |
| `Bash` | Sonnet | Terminal operations |

**Example:**
```yaml
---
name: analyze-codebase
context: fork
agent: Explore
description: Analyze codebase structure and patterns
---

Analyze the codebase focusing on $ARGUMENTS.
```

---

## `hooks` Field

Define lifecycle hooks scoped to this skill.

```yaml
---
name: monitored-task
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "echo 'Running: ${TOOL_INPUT}'"
---
```

**Hook types:**
- `PreToolUse` - Before tool execution
- `PostToolUse` - After tool execution
- `UserPromptSubmit` - After user input
- `Stop` - Before session ends

**Use cases:**
- Logging
- Validation
- Side effects
- Metrics collection

---

## String Substitutions

Claude Code supports variable substitution in skill content:

### Built-in Variables

| Variable | Expands To |
|---|---|
| `$ARGUMENTS` | All arguments passed to the skill |
| `${CLAUDE_SESSION_ID}` | Current session identifier |

**Example:**
```markdown
---
name: greet
---

Hello! You said: $ARGUMENTS

Session ID: ${CLAUDE_SESSION_ID}
```

**Invocation:** `/greet world`
**Expands to:**
```
Hello! You said: world

Session ID: abc123...
```

### Dynamic Command Execution

Execute shell commands inline with `` !`command` `` syntax:

```markdown
---
name: current-pr
---

## Current PR Information

!`gh pr view`

Please review the PR above.
```

**How it works:**
1. Skill loaded
2. Command executed: `gh pr view`
3. Output injected into skill content
4. Claude receives the complete context

**Security note:** Commands execute when skill loads. Ensure safe, idempotent commands.

---

## Skill Locations & Priority

Claude Code searches for skills in this order (highest to lowest priority):

### 1. Enterprise-managed (Organization-wide)
Managed by organization administrators, distributed to all users.

### 2. Personal (`~/.claude/skills/`)
Available across **all projects** for the current user.

**Example:**
```
~/.claude/skills/
├── my-helper/
│   └── SKILL.md
└── code-review/
    ├── SKILL.md
    └── references/
        └── checklist.md
```

### 3. Project (`.claude/skills/`)
Available **only** in the current project directory.

**Example:**
```
my-project/
└── .claude/skills/
    └── project-deploy/
        └── SKILL.md
```

**Override behavior:** Project skills override personal skills with the same name.

### 4. Plugin (`<plugin>/skills/`)
Bundled with plugins, available where the plugin is active.

**Example:**
```
my-plugin/
├── skills/
│   ├── skill-one/
│   │   └── SKILL.md
│   └── skill-two/
│       └── SKILL.md
└── .claude-plugin/
    └── plugin.json
```

---

## Permission Control

Three methods to control which skills Claude can access:

### 1. Disable All Skills

Deny the `Skill` tool in `/permissions`:

```
Deny: Skill
```

### 2. Allow/Deny Specific Skills

Use permission patterns:

```
# Allow only specific skills
Allow: Skill(commit) Skill(review-pr:*)

# Deny specific skills
Deny: Skill(deploy:*) Skill(dangerous:*)
```

**Pattern syntax:**
- `Skill(name)` - Exact match
- `Skill(prefix:*)` - Wildcard match
- `Skill(*)` - All skills

### 3. Per-Skill Control

Add `disable-model-invocation: true` to individual skills:

```yaml
---
name: risky-operation
disable-model-invocation: true
---
```

---

## Supporting Files in Skill Directory

Claude Code recognizes these special files:

### `SKILL.md`
**Required.** Main skill instructions and metadata.

### `references/*.md`
Additional documentation loaded on demand.

### `scripts/`
Executable code (Python, Bash, JavaScript).

### `assets/`
Templates, images, data files.

### Examples and templates
Any `.md` files for examples or templates.

**Directory structure example:**
```
my-skill/
├── SKILL.md
├── references/
│   ├── API.md
│   └── REFERENCE.md
├── scripts/
│   ├── process.py
│   └── requirements.txt
├── assets/
│   └── template.json
└── examples/
    └── EXAMPLES.md
```

---

## Best Practices (Claude Code)

### When to Use `disable-model-invocation: true`

✅ **Use for:**
- `/commit` - Git commits
- `/deploy` - Deployments
- `/delete` - Destructive operations
- `/send-message` - External communications
- Operations with side effects

❌ **Don't use for:**
- Read-only analysis
- Code generation
- Documentation lookups
- Safe, reversible operations

### When to Use `user-invocable: false`

✅ **Use for:**
- Architecture documentation
- Coding conventions
- Legacy system context
- Background knowledge
- Style guides

❌ **Don't use for:**
- Actionable commands
- User-facing utilities
- Tools users would invoke

### Model Selection

| Task Complexity | Model | Reasoning |
|---|---|---|
| Simple lookups, formatting | `haiku` | Fast, cheap |
| Standard development tasks | `sonnet` | Default |
| Complex reasoning, planning | `opus` | Most capable |

### Subagent Usage

Use `context: fork` + `agent: Explore` when:
- Deep codebase searches
- Isolated analysis tasks
- Long-running investigations
- Need clean separation from main context

---

## Migration from Commands

Claude Code previously used `.claude/commands/*.md` (deprecated).

### Migration steps:

1. Create skill directory:
   ```bash
   mkdir -p .claude/skills/my-command
   ```

2. Move and rename:
   ```bash
   mv .claude/commands/my-command.md .claude/skills/my-command/SKILL.md
   ```

3. Add frontmatter:
   ```yaml
   ---
   name: my-command
   description: What this command does
   ---
   ```

4. Test:
   ```bash
   /my-command
   ```

5. Remove old command file after verification

---

## Resources

### Official Documentation
- **Claude Code Skills Guide**: https://code.claude.com/docs/en/skills
- **Agent Skills Spec**: https://agentskills.io
- **Best Practices**: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices

### Examples
- **Anthropic Examples**: https://github.com/anthropics/skills
- **Community Skills**: https://github.com/hesreallyhim/awesome-claude-code

### Tools
- **skills-ref**: Validation and tooling library
  ```bash
  pip install skills-ref
  skills-ref validate ./my-skill
  ```
