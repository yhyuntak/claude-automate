# Plugin Structure Reference

> Complete guide to Claude Code plugin directory structure and manifest

---

## Directory Structure

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json           # Required: Plugin manifest
├── commands/                 # Slash commands (.md files)
├── agents/                   # Subagent definitions (.md files)
├── skills/                   # Agent skills (subdirectories)
│   └── skill-name/
│       └── SKILL.md          # Required for each skill
├── hooks/
│   └── hooks.json            # Event handler configuration
├── .mcp.json                 # MCP server definitions
├── .lsp.json                 # LSP server definitions
└── scripts/                  # Helper scripts and utilities
```

### Critical Rules

1. **Manifest location**: `plugin.json` MUST be in `.claude-plugin/` directory
2. **Component locations**: All directories (commands, agents, skills, hooks) MUST be at plugin root level, NOT nested inside `.claude-plugin/`
3. **Optional components**: Only create directories for components the plugin uses
4. **Naming convention**: Use kebab-case for all directory and file names

---

## Plugin Manifest (plugin.json)

### Minimal Required

```json
{
  "name": "plugin-name"
}
```

### Full Example

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "Brief explanation of plugin purpose",
  "author": {
    "name": "Author Name",
    "email": "author@example.com",
    "url": "https://example.com"
  },
  "homepage": "https://docs.example.com",
  "repository": "https://github.com/user/plugin-name",
  "license": "MIT",
  "keywords": ["testing", "automation", "ci-cd"]
}
```

### Name Requirements

- Use kebab-case format (lowercase with hyphens)
- Must be unique across installed plugins
- No spaces or special characters
- Becomes the namespace prefix for skills/commands

**Valid**: `code-review-assistant`, `test-runner`, `api-docs`
**Invalid**: `Code_Review`, `my plugin`, `MyPlugin`

---

## Custom Path Configuration

```json
{
  "name": "plugin-name",
  "commands": "./custom-commands",
  "agents": ["./agents", "./specialized-agents"],
  "hooks": "./config/hooks.json",
  "mcpServers": "./.mcp.json"
}
```

**Rules**:
- Custom paths supplement defaults (don't replace)
- Must be relative to plugin root
- Must start with `./`
- Support arrays for multiple locations

---

## Auto-Discovery Mechanism

Claude Code automatically discovers and loads components:

1. **Plugin manifest**: Reads `.claude-plugin/plugin.json` when plugin enables
2. **Commands**: Scans `commands/` directory for `.md` files
3. **Agents**: Scans `agents/` directory for `.md` files
4. **Skills**: Scans `skills/` for subdirectories containing `SKILL.md`
5. **Hooks**: Loads configuration from `hooks/hooks.json` or manifest
6. **MCP servers**: Loads configuration from `.mcp.json` or manifest
7. **LSP servers**: Loads configuration from `.lsp.json` or manifest

**No restart required**: Changes take effect on next Claude Code session.

---

## Common Plugin Patterns

### Minimal Plugin
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
└── commands/
    └── hello.md
```

### Skill-Focused Plugin
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    ├── skill-one/
    │   └── SKILL.md
    └── skill-two/
        └── SKILL.md
```

### Full-Featured Plugin
```
my-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
├── agents/
├── skills/
├── hooks/
│   ├── hooks.json
│   └── scripts/
├── .mcp.json
├── .lsp.json
└── scripts/
```

---

## Portable Path References

Use `${CLAUDE_PLUGIN_ROOT}` for all intra-plugin path references:

```json
{
  "command": "bash ${CLAUDE_PLUGIN_ROOT}/scripts/run.sh"
}
```

**Where to use**:
- Hook command paths
- MCP server command arguments
- Script execution references
- Resource file paths

**Never use**:
- Hardcoded absolute paths (`/Users/name/plugins/...`)
- Relative paths from working directory (`./scripts/...`)
- Home directory shortcuts (`~/plugins/...`)

---

## File Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Commands | kebab-case `.md` | `code-review.md` → `/code-review` |
| Agents | kebab-case `.md` | `test-generator.md` |
| Skills | kebab-case directory | `api-testing/SKILL.md` |
| Scripts | kebab-case with extension | `validate-input.sh` |
| Config | Standard names | `hooks.json`, `.mcp.json` |

---

## Standalone vs Plugin Comparison

| Aspect | Standalone (`.claude/`) | Plugin |
|--------|-------------------------|--------|
| Location | Project's `.claude/` directory | Separate directory with manifest |
| Skill names | `/skill-name` | `/plugin-name:skill-name` |
| Sharing | Manual copy | Marketplace distribution |
| Updates | Manual | Version-controlled |
| Use case | Personal, project-specific | Team sharing, reusable |

### Migration Path

1. Start with standalone in `.claude/` for quick iteration
2. Convert to plugin when ready to share:

```bash
# Create plugin structure
mkdir -p my-plugin/.claude-plugin
echo '{"name": "my-plugin", "version": "1.0.0"}' > my-plugin/.claude-plugin/plugin.json

# Copy existing files
cp -r .claude/commands my-plugin/
cp -r .claude/skills my-plugin/
cp -r .claude/agents my-plugin/
```

---

## Testing Plugins

```bash
# Test plugin locally
claude --plugin-dir ./my-plugin

# Multiple plugins
claude --plugin-dir ./plugin-one --plugin-dir ./plugin-two
```

---

## Best Practices

### Organization
- Group related components together logically
- Keep `plugin.json` minimal—rely on auto-discovery
- Include README files at plugin root and in component directories

### Naming
- Use consistent naming across components
- Favor descriptive names over abbreviations
- Balance brevity with clarity (2-3 words for commands)

### Portability
- Always use `${CLAUDE_PLUGIN_ROOT}` for paths
- Test on multiple systems (macOS, Linux, Windows)
- Document dependencies and versions

### Maintenance
- Use semantic versioning in plugin.json
- Document breaking changes
- Test thoroughly after changes
