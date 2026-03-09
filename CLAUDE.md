# CLAUDE.md

> Core principles and working guidelines for the claude-automate project

---

## 1. Project Identity

### Core Goals

1. **Develop without reading code** - Focus at the architecture/pattern/idea level
2. **A growing system** - Learn while building, accumulate what is learned
3. **Your own Harness** - An extensible system you can modify directly
4. **Keep it simple** - Start with what is needed, one thing at a time

### Anti-Goals

- A system that cannot be used without complex configuration
- Attempting to implement all features up front
- Copying things without understanding them
- Trying to control everything at the code level

### Universal Harness Principle

claude-automate is a **universal harness** designed to work across any project, not just this repository. When making design decisions, always think: "Will this work for a TypeScript project? A Python project? A Go project?" Never dismiss a feature or concern just because it does not apply to this Markdown+Bash codebase.

### What is a Harness?

A **connector** that lets the Developer (Driver) control the AI (Engine).

```
Driver (You)    →    Harness (claude-automate)    →    Engine (Claude)
Architecture/Decisions    Commands/Agents/Skills         Code Execution
```

### Evolution Principle

This document itself can be **redefined** whenever a better idea emerges.
It is a living document that evolves through experience.

---

## 2. Architecture Principles

### Layer Mapping (Starting Point)

Based on the TossTech Software 3.0 model:

```
Commands    =  Controller       (Entry point, user interface)
Agents      =  Service Layer    (Business logic, analysis/validation)
Skills      =  Domain Component (Single responsibility, reusable)
Hooks       =  Middleware       (Automatic validation, session guard)
MCP         =  Infrastructure   (External integration, adapters)
CLAUDE.md   =  package.json     (Project identity)
rules/*.md  =  eslint.config    (Detailed rules)
```

**Important**: This mapping is a **starting point**, not fixed.
Redefine it whenever a better model emerges.

### Design Principles

1. **SRP (Single Responsibility)**: One agent/skill = one responsibility
2. **Abstraction boundaries**: Clear separation of roles between layers
3. **Progressive Disclosure**: Load detailed information only when needed
4. **Delegation**: Execution to agents, decisions to humans

---

## 3. Tech Stack & Conventions

### Languages

- **Markdown**: All documents, commands, and agent definitions
- **Bash**: Automation scripts, hooks
- **JSON**: Configuration files (plugin.json, hooks.json)

### Folder Structure

```
claude-automate/
├── commands/           # Controller (entry points)
├── agents/             # Service Layer
│   └── scripts/        # External CLI call scripts (Gemini, Codex)
├── skills/             # Domain Components
│   └── {skill-name}/
│       ├── SKILL.md    # Skill definition
│       ├── schema.md   # Input/output schema
│       └── refs/       # Reference materials (lazy-loaded)
├── hooks/              # Hook scripts + configuration
│   ├── hooks.json      # Plugin hooks registration
│   └── session-stop.sh # Stop hook script
├── rules/              # Detailed rules (acts as eslint.config)
├── templates/          # Project templates
├── docs/
│   ├── references/     # External reference materials
│   └── backlogs/       # Backlogs (todo/doing/done)
├── .claude/
│   ├── rules/          # Project-specific rules
│   ├── context/        # Session context (auto-generated)
│   ├── plans/          # Implementation plan files
│   └── brain/          # Project brain system
└── CLAUDE.md           # This document
```

### File Naming Conventions

| Type | Rule | Example |
|------|------|---------|
| Command | `{action}.md` | `wrap.md`, `start-work.md` |
| Agent | `{role}.md`, `{role}-high.md` | `pattern-checker.md` |
| Skill | `{name}/SKILL.md` | `backlog/SKILL.md` |
| Backlog | `phase{N}-{ID}-{slug}.md` | `phase1-001-review-agents.md` |

### Version Management

Semantic Versioning: `v{MAJOR}.{MINOR}.{PATCH}`

- MAJOR: Breaking changes
- MINOR: New feature additions
- PATCH: Bug fixes

---

## 4. Agent/Skill Design Principles

### Agent Creation Rules

**When to create a new agent:**

1. When there is a clearly separated responsibility
2. When a different model Tier is needed (Haiku vs Sonnet vs Opus)
3. When there is a benefit to parallel execution

**When not to create one:**

- When it can be solved with parameters of an existing agent
- When the responsibility is ambiguous
- When the logic will only be used once

### Model Selection 3-Tier

| Tier | Model | Use Case |
|------|-------|----------|
| Low | Haiku | Data collection, simple pattern matching, fast responses |
| Medium | Sonnet | Analysis, decision-making, standard agent tasks |
| High | Opus | Complex conflict resolution, strategic decisions, creative work |

### Agent Template

```markdown
# {agent-name}

> {One-line description}

## Role

{What this agent does}

## Input

- {input 1}
- {input 2}

## Output

{Output format}

## Usage Conditions

- {When to use this agent}
```

### Skill Creation Rules

**When to create a new skill:**

1. When there is reusable domain logic
2. When a clear input/output schema can be defined
3. When it will be used across multiple agents/commands

### Progressive Disclosure Application

```
CLAUDE.md (always loaded)
    ↓ when needed
rules/*.md (detailed rules)
    ↓ when needed
docs/references/*.md (reference materials)
    ↓ when needed
skills/*/references/*.md (skill details)
```

---

## 5. Anti-Pattern Warnings

### God Skill

```
❌ One skill handles everything
✅ Multiple skills separated by responsibility
```

### Spaghetti CLAUDE.md

```
❌ All detailed information crammed into CLAUDE.md
✅ Only principles in CLAUDE.md, details in rules/*.md
```

### Copy-Paste Configuration

```
❌ Copying oh-my-claudecode configuration as-is
✅ Understand the principles and adapt to your own situation
```

### Premature Optimization

```
❌ Implementing features you will not use yet
✅ Only what is needed, when it is needed
```

### Code Smells (Agent Version)

| Smell | Symptom | Resolution |
|-------|---------|------------|
| Oversized agent | Prompt exceeds 500 lines | Separate responsibilities |
| Duplicate agents | Multiple agents with similar roles | Consolidate or parameterize |
| Tier mismatch | Complex analysis assigned to Haiku | Switch to appropriate Tier |

---

## 6. Working Style

### Basic Workflow

```bash
/start-work    # Start session (load context)
# ... work ...
/wrap          # End session (validate + save)
```

### Required Before Code Changes

1. **Explain first**: Describe what and why you are changing
2. **Confirm then execute**: Implement only after agreement
3. **Small units**: One change at a time

### Agent Invocation Principles

- Tasks that can run in parallel should be **invoked simultaneously**
- Tasks with dependencies should be **invoked sequentially**
- **Consolidate and report** results

### Pre-Completion Checklist

- [ ] Pattern validation passed
- [ ] Document sync confirmed
- [ ] Session context saved

---

## 7. Document Management

### Document Location Principles

| Document Type | Location | Reason |
|--------------|----------|--------|
| Core principles | CLAUDE.md | Always loaded |
| Detailed rules | rules/*.md | Loaded when needed |
| External references | docs/references/*.md | Background knowledge |
| Skill details | skills/*/references/*.md | Loaded when skill is used |

### Update Rules on Change

1. **Command change** → Update README.md
2. **Agent added** → Update README.md + CLAUDE.md
3. **Skill added** → Update README.md
4. **Principle change** → Update CLAUDE.md

---

## 8. Reference Documents

For detailed information, see the documents below:

- [README.md](README.md) - Vision, philosophy, roadmap
- [rules/backlog-rules.md](rules/backlog-rules.md) - Backlog management rules
- [rules/workflow.md](rules/workflow.md) - Git workflow
- [rules/interaction.md](rules/interaction.md) - User interaction rules
- [docs/references/](docs/references/) - Collection of reference materials

---

**Last Updated**: 2026-02-23
