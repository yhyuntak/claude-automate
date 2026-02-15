---
id: P2
title: Context7
author: Upstash
url: https://github.com/upstash/context7
fetched: 2026-02-15
---

# Context7 MCP Server

## What is Context7?

Context7 is a Model Context Protocol (MCP) server that addresses a critical problem in AI-assisted coding: LLMs often work with outdated or hallucinated library documentation. The tool integrates with code editors like Cursor and Claude Code to provide up-to-date, version-specific documentation directly within your development environment.

## Key Features

The platform resolves the "stale knowledge cutoff" issue by pulling current documentation from source repositories. When you add "use context7" to prompts, it retrieves relevant API documentation and code examples in real-time.

## Installation Methods

**Cursor Setup** requires adding configuration to `~/.cursor/mcp.json` with either:
- Remote server connection via HTTPS endpoint
- Local NPX-based installation

**Claude Code** supports both command-line installation and remote HTTP connections with OAuth support.

**Alternative Platforms** include Opencode, with both local and remote configurations available.

## Usage Pattern

Rather than manually researching documentation across browser tabs, users can simply append "use context7" to their prompts. The system automatically identifies relevant libraries and retrieves current documentation, enabling more accurate code generation.

## Core Tools

Two primary MCP tools power the system:

1. **Library resolution** - Maps general library names to Context7-compatible identifiers
2. **Documentation retrieval** - Fetches version-specific docs using exact library IDs

## Additional Capabilities

The platform supports specifying exact library versions in prompts and allows users to configure MCP rules for automatic invocation, reducing repetitive typing in development workflows.

The project maintains a MIT license and integrates with 30+ different coding environments and AI clients.
