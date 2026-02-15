---
id: A4
title: How I Use Every Claude Code Feature
author: Shrivu Shankar
url: https://blog.sshh.io/p/how-i-use-every-claude-code-feature
fetched: 2026-02-15
---

# How I Use Every Claude Code Feature

## Overview
Shrivu Shankar shares comprehensive insights into Claude Code usage, covering both hobby and professional implementations consuming "several billion tokens per month" for code generation.

## Key Features & Practices

### CLAUDE.md File
The foundational configuration file functions as the agent's constitution. Shankar's professional monorepo maintains a strictly curated 13KB file documenting only tools used by 30%+ of engineers.

**Critical guidelines:**
- "Start with Guardrails, Not a Manual" - document based on what Claude gets wrong
- Avoid @-mentioning extensive documentation; instead, pitch why and when to read files
- Replace negative constraints with alternatives rather than stating "Never use X"
- Use the file as a forcing function to simplify codebase complexity

### Context Management
Running `/context` mid-session reveals token allocation. Fresh sessions in complex monorepos cost ~20k baseline tokens (10%), leaving 180k for actual work.

**Three workflows:**
1. `/compact` - avoided due to opacity and poor optimization
2. `/clear` + `/catchup` - default restart method reading changed git files
3. "Document & Clear" - dumping progress to markdown before clearing state

### Slash Commands
Minimal setup with only `/catchup` and `/pr` commands. The author cautions against extensive custom command lists, arguing they contradict agent autonomy principles.

### Subagents vs. Master-Clone Architecture
Custom subagents present context management trade-offs. Rather than specialized subagents, Shankar prefers leveraging Claude's built-in `Task()` feature, allowing the main agent to decide delegation dynamically while maintaining holistic reasoning.

### Skills & MCP
Skills formalize the "scripting-based agent model," providing more robustness than rigid API-like Model Context Protocol tools. MCPs now serve as data gateways providing high-level access rather than mirroring REST APIs.

### Hooks Implementation
Two primary strategies:
- **Block-at-Submit Hooks** - validates test passage before commits
- **Hint Hooks** - non-blocking feedback for suboptimal patterns

Critically, avoid blocking at write time; let agents complete plans before final validation.

### Planning Mode
Essential for large feature changes. Professional implementations use custom planning tools aligned with internal design formats and best practices enforcement.

### Claude Code SDK
Three primary applications:
- Massive parallel scripting for large-scale refactors
- Building internal chat tools for non-technical users
- Rapid agent prototyping before full deployment

### GitHub Actions Integration
The Claude Code GHA enables operationalization beyond personal tooling. Organizations review logs for common mistakes and engineering misalignments, creating data-driven improvements to CLAUDE.md and tooling.

### Settings.json Configuration
Notable customizations include:
- Proxy configuration for traffic inspection
- Extended timeout values for complex commands
- Enterprise API key usage for usage-based pricing
- Permission auditing for auto-run commands

## Philosophical Approach

Shankar emphasizes "shoot and forget" delegation—setting context and allowing autonomous execution rather than micromanaging the agent's process. Success metrics focus on final pull request quality over intermediate output style.
