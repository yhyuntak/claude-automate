---
name: explain-plugins
description: Claude Code Plugin system guide. Explains plugin structure, skills, agents, hooks, commands, MCP/LSP servers, and configuration methods.
argument-hint: "[topic]"
---

# Claude Code Plugin Guide

$ARGUMENTS

---

## Complete Documentation

This skill provides quick reference for Claude Code Plugins. For comprehensive documentation:

- **[Plugin Structure](references/plugin-structure.md)** - Complete plugin directory structure and manifest
- **[Agent Skills Spec](references/agentskills-spec.md)** - The agentskills.io specification
- **[Claude Code Extensions](references/claude-code-extensions.md)** - Claude Code-specific skill features
- **[Hooks](references/hooks.md)** - Event handlers and automation
- **[Agents](references/agents.md)** - Subagent definitions
- **[MCP & LSP](references/mcp-lsp.md)** - External tool and code intelligence integration

**Quick overview below** | **Deep dive in references above**

---

## 1. Plugin Structure Overview

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json           # Required: Plugin manifest
├── commands/                 # /plugin:command slash commands
├── agents/                   # Subagent definitions
├── skills/                   # Agent Skills (auto-invoked)
│   └── skill-name/
│       └── SKILL.md
├── hooks/
│   └── hooks.json            # Event handlers
├── .mcp.json                 # MCP server definitions
├── .lsp.json                 # LSP server definitions
└── scripts/                  # Helper scripts
```

**Critical Rule**: Only `plugin.json` goes inside `.claude-plugin/`. All other directories at plugin root.

---

## 2. Component Summary

| Component | Location | Purpose | Invocation |
|-----------|----------|---------|------------|
| **Commands** | `commands/*.md` | User slash commands | `/plugin:command` |
| **Skills** | `skills/*/SKILL.md` | Auto-invoked knowledge | Claude auto-detects |
| **Agents** | `agents/*.md` | Subagent definitions | Task tool or auto |
| **Hooks** | `hooks/hooks.json` | Event reactions | Auto-triggered |
| **MCP** | `.mcp.json` | External tools | Auto-connected |
| **LSP** | `.lsp.json` | Code intelligence | Auto-connected |

---

## 3. Plugin Manifest (plugin.json)

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "What this plugin does",
  "author": {
    "name": "Author Name",
    "url": "https://github.com/username"
  },
  "repository": "https://github.com/user/plugin-name",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"]
}
```

**Name rules**: kebab-case, lowercase, no spaces. Becomes namespace prefix.

---

## 4. Skills (Auto-Invoked)

Skills are knowledge/workflows that Claude automatically loads when relevant.

```
skills/code-review/
├── SKILL.md              # Required
├── references/           # Detailed docs (loaded on demand)
├── scripts/              # Executable code
└── assets/               # Templates, resources
```

**SKILL.md format**:
```markdown
---
name: code-review
description: Reviews code for best practices. Use when reviewing PRs or code quality.
disable-model-invocation: true    # User-only invocation
user-invocable: false             # Claude-only (hidden knowledge)
allowed-tools: Read, Grep, Bash   # Tool restrictions
context: fork                     # Run as subagent
agent: Explore                    # Subagent type
model: opus                       # Model override
---

Instructions here...
$ARGUMENTS
```

**Invocation Matrix**:
| Setting | User | Claude |
|---------|------|--------|
| Default | Yes | Yes |
| `disable-model-invocation: true` | Yes | No |
| `user-invocable: false` | No | Yes |

---

## 5. Commands (User-Invoked)

Simple slash commands for user invocation.

**Location**: `commands/hello.md` → `/plugin:hello`

```markdown
---
description: Greet the user
---

Greet $ARGUMENTS warmly.
```

---

## 6. Agents (Subagents)

Custom subagent definitions for specialized tasks.

**Location**: `agents/code-analyzer.md`

```markdown
---
description: Analyzes code architecture and patterns
capabilities:
  - Static analysis
  - Pattern detection
  - Dependency mapping
---

Detailed agent instructions...
```

---

## 7. Hooks (Event Handlers)

React to Claude Code events automatically.

**Location**: `hooks/hooks.json`

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

**Available Events**:
| Event | Trigger |
|-------|---------|
| `SessionStart` | Session begins |
| `SessionEnd` | Session ends |
| `UserPromptSubmit` | User sends message |
| `PreToolUse` | Before tool execution |
| `PostToolUse` | After tool execution |
| `PreCompact` | Before context compaction |
| `Stop` | Before session stops |
| `SubagentStop` | Subagent completes |
| `Notification` | Notification occurs |

---

## 8. MCP Servers

External tool integration via Model Context Protocol.

**Location**: `.mcp.json`

```json
{
  "mcpServers": {
    "database": {
      "command": "node",
      "args": ["${CLAUDE_PLUGIN_ROOT}/servers/db-server.js"],
      "env": {
        "DB_URL": "${DATABASE_URL}"
      }
    }
  }
}
```

---

## 9. LSP Servers

Code intelligence for languages not built-in.

**Location**: `.lsp.json`

```json
{
  "go": {
    "command": "gopls",
    "args": ["serve"],
    "extensionToLanguage": {
      ".go": "go"
    }
  }
}
```

---

## 10. Standalone vs Plugin

| Approach | Skill Name | Best For |
|----------|------------|----------|
| **Standalone** (`.claude/`) | `/hello` | Personal, project-specific |
| **Plugin** | `/plugin:hello` | Sharing, versioning, reuse |

**Start standalone** → **Convert to plugin** when ready to share.

---

## 11. Testing & Development

```bash
# Test plugin locally
claude --plugin-dir ./my-plugin

# Multiple plugins
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

---

## 12. Path References

Always use `${CLAUDE_PLUGIN_ROOT}` for portable paths:

```json
{
  "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/run.sh"
}
```

---

## Reference Materials

### This Skill's Documentation
- [Plugin Structure](references/plugin-structure.md)
- [Agent Skills Spec](references/agentskills-spec.md)
- [Claude Code Extensions](references/claude-code-extensions.md)
- [Hooks](references/hooks.md)
- [Agents](references/agents.md)
- [MCP & LSP](references/mcp-lsp.md)

### External Resources
- [Claude Code Plugins](https://code.claude.com/docs/en/plugins) - Official docs
- [agentskills.io](https://agentskills.io) - Skills open standard
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) - Community resources
