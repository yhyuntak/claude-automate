# claude-automate

> **"Develop Without Reading Code"** - A New Role for Developers in the AI Era

🌏 **English** | [한국어](README.md)

---

## Vision

Developers no longer need to read and write every line of code themselves.

**claude-automate** is a Claude Code plugin that lets developers focus on **architecture, patterns, and ideas**. Delegate code implementation to AI while you focus on **direction and decision-making**.

### Core Goals

| # | Goal | Description |
|---|------|-------------|
| 1 | **Develop without reading code** | Focus on architecture/patterns/ideas |
| 2 | **Growing system** | Learn while building, accumulate learnings |
| 3 | **Your own Harness** | Extensible system you can modify |
| 4 | **Keep it simple** | One thing at a time |

### Harness Concept

```
┌─────────────────────────────────────────────────────────────┐
│                       You (Driver)                           │
│           Architecture · Patterns · Ideas · Decisions        │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │    claude-automate │
                    │     (Harness)      │
                    └─────────┬─────────┘
                              │
          ┌───────────┬───────┴───────┬───────────┐
          ▼           ▼               ▼           ▼
    ┌─────────┐ ┌─────────┐   ┌─────────┐ ┌─────────┐
    │ Pattern │ │ Doc Sync│   │ Context │ │ Review  │
    │ Checker │ │ Checker │   │ Builder │ │ Agents  │
    └─────────┘ └─────────┘   └─────────┘ └─────────┘
        AI Agents (Executors)
```

---

## Philosophy

### 1. "A better observer has arrived"
> Peter Steinberger (Moltbot creator)

Run 5-10 agents in parallel, focus on architecture discussions instead of code reviews. Invest time in planning, delegate execution.

### 2. "I stopped reading code, and reviews got better"
> Kieran Klaassen

13 specialized AI reviewers run in parallel. 50/50 rule: 50% reviews, 50% system improvement. Triage-based decision making.

### 3. "Don't look at code. Solidify higher-level concepts"
> Toss Tech Software 3.0

Tools have changed, but good design principles remain. Claude Code follows layered architecture, and anti-patterns still apply.

### 4. "Reference others, but make it your own to grow"
> From oh-my-claudecode analysis

Copying someone else's config isn't enough. Build it yourself, understand it, modify it - then it truly becomes yours.

---

## Current Features

### Architecture Layer Mapping

claude-automate follows Toss Tech's layered architecture model:

```
Commands    =  Controller (entry point, user interface)
Agents      =  Service Layer (business logic, analysis/validation)
Skills      =  Domain Component (single responsibility, reusable)
MCP         =  Infrastructure/Adapter (external integration)
CLAUDE.md   =  package.json (project identity, principles)
```

### Commands (Controller)

| Command | Description |
|---------|-------------|
| `/start-work` | Start session: previous context + backlog + worktree |
| `/wrap` | End session: pattern validation + doc sync + context save |
| `/backlog` | View and manage backlog |
| `/project-init` | Initialize new project |

### Agents (Service Layer)

| Agent | Tier | Role |
|-------|------|------|
| `pattern-checker` | Sonnet | Project rule validation |
| `pattern-checker-high` | Opus | Complex rule conflict resolution |
| `doc-sync-checker` | Sonnet | Doc-code sync validation |
| `doc-sync-checker-high` | Opus | Large-scale doc structure changes |
| `context-builder` | Sonnet | Session context creation |

### Skills (Domain Component)

| Skill | Role |
|-------|------|
| `backlog` | Backlog CRUD and state management |
| `feedback` | Feedback collection and retrieval |
| `project-init` | Project template generation |
| `explain-plugins` | Plugin system explanation |

---

## Roadmap

### Phase 1: Parallel Review Agents (Upcoming)

Build Kieran Klaassen-style parallel review system:

- [ ] **phase1-001**: Design parallel review agent structure
- [ ] **phase1-002**: Implement triage workflow
- [ ] **phase1-003**: Accumulate review learnings

### Phase 2: PARA Knowledge Management

System for accumulating learnings:

- [ ] Projects, Areas, Resources, Archive structure
- [ ] Auto-extract insights from sessions
- [ ] Knowledge search and utilization

### Phase 3: Plan-Execute Workflow

Peter Steinberger-style planning-first development:

- [ ] Enhanced planning phase (architecture first)
- [ ] Multi-agent parallel execution
- [ ] Result integration and feedback

---

## Quick Start

### 1. Install

```bash
# Install from Claude Code plugin marketplace
/plugin marketplace add yhyuntak/claude-automate
/plugin install claude-automate@claude-automate
```

### 2. Start Session

```bash
/start-work
```

Load previous session context, check backlog, set up worktree.

### 3. Wrap Up After Work

```bash
/wrap
```

Pattern validation, doc sync check, auto-save session context.

---

## References

Detailed background and sources of inspiration:

| Document | Key Insight |
|----------|-------------|
| [Peter Steinberger](docs/references/01-peter-steinberger-moltbot.md) | "I ship code I don't read" |
| [Kieran Klaassen](docs/references/02-kieran-klaassen-code-review.md) | 13 parallel AI reviewers |
| [Toss Tech](docs/references/03-toss-software-3.0.md) | Layered architecture mapping |
| [oh-my-claudecode](docs/references/04-oh-my-claudecode-analysis.md) | Multi-agent orchestration |

---

## License

MIT

## Author

[yhyuntak](https://github.com/yhyuntak)
