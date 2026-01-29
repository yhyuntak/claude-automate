# MCP & LSP Reference

> External tool integration and code intelligence for Claude Code

---

## MCP (Model Context Protocol)

MCP enables Claude to interact with external tools and services.

### Location

**In Plugin**: `.mcp.json` at plugin root

**Standalone**: `.mcp.json` in project root or `~/.claude/.mcp.json`

### Basic Configuration

```json
{
  "mcpServers": {
    "server-name": {
      "command": "node",
      "args": ["path/to/server.js"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

### Configuration Fields

| Field | Type | Description |
|-------|------|-------------|
| `command` | string | Executable to run |
| `args` | string[] | Command arguments |
| `env` | object | Environment variables |
| `cwd` | string | Working directory |

### Plugin Path Reference

Use `${CLAUDE_PLUGIN_ROOT}` for portable paths:

```json
{
  "mcpServers": {
    "my-server": {
      "command": "node",
      "args": ["${CLAUDE_PLUGIN_ROOT}/servers/my-server.js"]
    }
  }
}
```

### Environment Variables

Reference environment variables with `${}`:

```json
{
  "env": {
    "DATABASE_URL": "${DATABASE_URL}",
    "API_KEY": "${MY_API_KEY}"
  }
}
```

---

## Common MCP Server Examples

### Database Server

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["@anthropic/mcp-server-postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL}"
      }
    }
  }
}
```

### GitHub Server

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["@anthropic/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

### Custom Node Server

```json
{
  "mcpServers": {
    "custom": {
      "command": "node",
      "args": ["${CLAUDE_PLUGIN_ROOT}/servers/custom-server.js"],
      "env": {
        "CONFIG_PATH": "${CLAUDE_PLUGIN_ROOT}/config/server-config.json"
      }
    }
  }
}
```

### Python Server

```json
{
  "mcpServers": {
    "python-server": {
      "command": "python",
      "args": ["-m", "my_mcp_server"],
      "env": {
        "PYTHONPATH": "${CLAUDE_PLUGIN_ROOT}/src"
      }
    }
  }
}
```

---

## LSP (Language Server Protocol)

LSP provides code intelligence (autocomplete, go-to-definition, diagnostics) for languages.

### Location

**In Plugin**: `.lsp.json` at plugin root

### Basic Configuration

```json
{
  "language-id": {
    "command": "language-server-binary",
    "args": ["serve"],
    "extensionToLanguage": {
      ".ext": "language-id"
    }
  }
}
```

### Configuration Fields

| Field | Type | Description |
|-------|------|-------------|
| `command` | string | Language server executable |
| `args` | string[] | Server arguments |
| `extensionToLanguage` | object | File extension to language ID mapping |

---

## Common LSP Server Examples

### Go (gopls)

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

### Rust (rust-analyzer)

```json
{
  "rust": {
    "command": "rust-analyzer",
    "args": [],
    "extensionToLanguage": {
      ".rs": "rust"
    }
  }
}
```

### Python (pyright)

```json
{
  "python": {
    "command": "pyright-langserver",
    "args": ["--stdio"],
    "extensionToLanguage": {
      ".py": "python"
    }
  }
}
```

### TypeScript (tsserver)

```json
{
  "typescript": {
    "command": "typescript-language-server",
    "args": ["--stdio"],
    "extensionToLanguage": {
      ".ts": "typescript",
      ".tsx": "typescriptreact"
    }
  }
}
```

---

## Built-in vs Plugin LSP

Claude Code has built-in LSP support for common languages:
- TypeScript/JavaScript
- Python
- Rust

**Create custom LSP plugins only when** you need support for languages not already covered.

---

## MCP vs LSP

| Aspect | MCP | LSP |
|--------|-----|-----|
| Purpose | External tool integration | Code intelligence |
| Interaction | Tool calls | Background service |
| Examples | Database, API, file system | Autocomplete, diagnostics |
| User sees | Tool results | IDE-like features |

---

## Debugging

### MCP Servers

1. Test server standalone first:
   ```bash
   node path/to/server.js
   ```

2. Check environment variables are set

3. Verify server responds to MCP protocol

### LSP Servers

1. Ensure language server is installed:
   ```bash
   which gopls  # or your server
   ```

2. Test server standalone:
   ```bash
   gopls serve
   ```

3. Check file extension mappings

---

## Best Practices

### MCP
- Use `${CLAUDE_PLUGIN_ROOT}` for all paths
- Document required environment variables
- Handle server errors gracefully
- Set appropriate timeouts

### LSP
- Only add LSP for languages not built-in
- Document installation requirements
- Test language server before distribution

### Security
- Never hardcode secrets in config files
- Use environment variables for sensitive data
- Validate all inputs in custom servers
