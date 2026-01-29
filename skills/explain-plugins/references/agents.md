# Agents Reference

> Custom subagent definitions for specialized tasks

---

## Overview

Agents are specialized AI assistants that can be invoked for specific tasks. They have their own context, capabilities, and instructions.

---

## Agent Location

**In Plugin**: `agents/*.md`

**Standalone**: `.claude/agents/*.md` or `~/.claude/agents/*.md`

All `.md` files in agents directories are automatically discovered and loaded.

---

## Agent File Format

```markdown
---
description: What this agent specializes in
model: sonnet                     # Optional: haiku, sonnet, opus
capabilities:
  - Capability 1
  - Capability 2
allowed-tools: Read, Grep, Bash   # Optional: restrict tools
---

# Agent Name

Detailed instructions for the agent...

## When to Use

Describe scenarios when this agent should be invoked.

## Approach

How the agent should approach tasks.

## Constraints

Any limitations or rules the agent must follow.
```

---

## Frontmatter Fields

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | **Required**. What the agent does (used for auto-selection) |
| `model` | string | Model to use: `haiku`, `sonnet`, `opus` |
| `capabilities` | string[] | List of agent capabilities |
| `allowed-tools` | string | Space-separated list of allowed tools |

---

## Example Agents

### Code Analyzer

```markdown
---
description: Analyzes code architecture, patterns, and dependencies. Use for understanding complex codebases.
model: sonnet
capabilities:
  - Static code analysis
  - Dependency mapping
  - Pattern detection
  - Architecture documentation
allowed-tools: Read, Grep, Glob
---

# Code Analyzer

You are a code analysis specialist. Your task is to understand and document code architecture.

## Approach

1. Start with entry points and main files
2. Map dependencies and imports
3. Identify design patterns
4. Document architecture decisions

## Output Format

Provide analysis in structured markdown with:
- Overview section
- Component diagram (ASCII)
- Key patterns identified
- Recommendations
```

### Test Generator

```markdown
---
description: Generates comprehensive test cases for code. Use when writing tests or improving coverage.
model: sonnet
capabilities:
  - Unit test generation
  - Integration test planning
  - Edge case identification
  - Mock setup
allowed-tools: Read, Grep, Write
---

# Test Generator

You are a testing specialist focused on comprehensive test coverage.

## Approach

1. Analyze the code to be tested
2. Identify all code paths
3. List edge cases and error conditions
4. Generate test cases with clear assertions

## Test Structure

- Arrange: Set up test data and mocks
- Act: Execute the function/method
- Assert: Verify expected outcomes
```

### Documentation Writer

```markdown
---
description: Creates and maintains technical documentation. Use for README, API docs, or inline comments.
model: haiku
capabilities:
  - README generation
  - API documentation
  - Code comments
  - Usage examples
allowed-tools: Read, Grep, Write
---

# Documentation Writer

You are a technical writer specializing in developer documentation.

## Guidelines

- Write clear, concise documentation
- Include practical examples
- Use consistent formatting
- Keep documentation close to code

## Documentation Types

### README
- Project overview
- Quick start guide
- Installation instructions
- Usage examples

### API Docs
- Endpoint descriptions
- Request/response formats
- Error codes
- Authentication
```

---

## Invoking Agents

### Via Task Tool

```
Task(
  subagent_type="plugin-name:agent-name",
  prompt="Analyze the authentication module"
)
```

### Auto-Selection

Claude can automatically select appropriate agents based on:
- Task description matching agent's `description`
- Required capabilities
- Context of the conversation

---

## Agent vs Skill

| Aspect | Agent | Skill |
|--------|-------|-------|
| Purpose | Specialized task execution | Knowledge/workflow templates |
| Invocation | Task tool or auto-selected | Claude auto-loads or user `/skill` |
| Context | Isolated (forked context) | Shared with main conversation |
| Output | Returns results to parent | Influences current response |
| Best for | Complex multi-step tasks | Consistent patterns/guidelines |

---

## Model Selection Guidelines

| Complexity | Model | Examples |
|------------|-------|----------|
| Simple lookups, formatting | `haiku` | Doc generation, simple search |
| Standard development | `sonnet` | Code analysis, test generation |
| Complex reasoning | `opus` | Architecture design, debugging |

---

## Tool Restrictions

Limit agent capabilities with `allowed-tools`:

```markdown
---
allowed-tools: Read Grep Glob
---
```

**Common tool sets**:
- **Read-only**: `Read, Grep, Glob`
- **Analysis**: `Read, Grep, Glob, Bash`
- **Development**: `Read, Grep, Glob, Write, Edit, Bash`

---

## Best Practices

### Design
- Give agents focused, specific responsibilities
- Write clear descriptions for accurate auto-selection
- Include examples in instructions

### Instructions
- Be explicit about approach and output format
- List constraints and limitations
- Provide context about when to use

### Testing
- Test agents with various prompts
- Verify tool restrictions work correctly
- Check model selection is appropriate
