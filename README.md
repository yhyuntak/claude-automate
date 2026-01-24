# claude-automate

> Self-Evolving Development System - Automation Plugin for Claude Code Meta Layer

## Overview

**claude-automate** is a comprehensive automation plugin for Claude Code that streamlines your development workflow. It automatically enforces project patterns, maintains session continuity, synchronizes documentation with code changes, and extracts learning insights from your development sessions.

## Features

### 1. Project Pattern Checker
Automatically validates that code changes follow your project's rules and conventions.

### 2. Usage Pattern Analysis
Detects repeated prompt patterns in your workflow and suggests automatic skill generation to streamline repetitive tasks.

### 3. Session Continuity
Automatically manages `context.md` files to maintain context across development sessions, so you can pick up exactly where you left off.

### 4. Automatic Documentation Sync
Monitors code changes and suggests documentation updates to keep your docs in sync with your implementation.

### 5. Learning Extraction (TIL)
Automatically extracts and records insights and lessons learned from each development session.

## Installation

```bash
/plugin marketplace add yhyuntak/claude-automate
/plugin install claude-automate@claude-automate
```

## Usage

The main command is `/wrap`, which concludes your development session:

```bash
/wrap
```

This command:
- Verifies code follows project patterns
- Checks if documentation needs updates
- Saves your session context automatically

Other useful commands:
- `/project-init` - Initialize new project with templates and structure
- `/start-work` - Begin a work session with context loading and worktree setup
- `/session-start` - Load previous session summary
- `/backlog` - View and manage your project backlog
- `/feedback` - View feedback from previous sessions
- `/install-rule` - Install project rules to global Claude Code configuration

## Project Structure

```
claude-automate/
├── .claude-plugin/
│   ├── plugin.json              # Plugin metadata and version
│   └── marketplace.json         # Marketplace configuration
│
├── commands/
│   ├── wrap.md                  # /wrap command - session wrap-up with goal-first architecture
│   ├── start-work.md            # /start-work command - integrated workflow for session setup
│   ├── session-start.md         # Session context loading
│   ├── install-rule.md          # /install-rule command - install project rules globally
│   └── feedback.md              # Feedback management commands
│
├── agents/
│   ├── pattern-checker.md       # Validates code against project rules
│   ├── pattern-checker-high.md  # Complex rule conflict resolution (Opus)
│   ├── doc-sync-checker.md      # Monitors documentation consistency
│   ├── doc-sync-checker-high.md # Complex doc structure changes (Opus)
│   └── context-builder.md       # Creates session context files
│
├── skills/
│   ├── explain-skills/          # Skill system documentation and references
│   ├── feedback/                # Feedback system with schema and examples
│   ├── backlog/                 # Project backlog management
│   ├── project-init/            # New project initialization with templates
│   └── [other skills]/
│
├── rules/
│   ├── interaction.md           # AskUserQuestion UX rules
│   ├── backlog-rules.md         # Backlog management (todo/doing/done)
│   └── workflow.md              # Git branching and release strategies
│
├── .claude/
│   ├── rules/
│   │   └── version-up.md        # Version bump rules (project-specific)
│   ├── context/                 # Session context files (auto-generated)
│   └── CLAUDE.md                # Main Claude configuration
│
└── .gitignore
```

## How It Works: WRAP Architecture

The `/wrap` command uses a **Goal-first** (WRAP V3) architecture optimized for efficiency:

### Step 1: Analyze Changes
Review only file changes with `git diff --stat` to understand what was modified.

### Step 2: Route to Agents
Based on change types, dispatch to specialized agents:

| File Type | Pattern Checker | Doc Sync Checker |
|-----------|-----------------|------------------|
| Code files (.ts, .py, etc.) | ✅ Check | △ If API |
| Documentation (.md) | △ If rules-related | ❌ Skip |
| Configuration files | △ Check | ❌ Skip |
| New features | ✅ Check | ✅ Check |

### Step 3: Parallel Execution
Agents collect and analyze in parallel - you wait for the slowest, not the sum.

### Step 4: Integrated Results
Results are combined into a single summary with recommended actions.

### Step 5: Session Saved
Context is automatically saved to `.claude/context/YYYY-MM/YYYY-MM-DD-{session-id}.md` for future reference.

## Model Tiering Strategy

The plugin optimizes cost and latency by using the right model for each task:

| Model | Primary Use |
|-------|------------|
| **Haiku** | Data collection, simple pattern matching |
| **Sonnet** | Analysis, decision-making, standard agent work |
| **Opus** | Complex conflict resolution, strategic decisions |

## Key Commands

### `/start-work`
Unified workflow for starting your development session:
1. Shows previous session summary
2. Displays project backlog
3. Sets up optional git worktree for branch isolation
4. Prepares your working environment

Options:
- `/start-work --skip-session` - Skip previous session summary
- `/start-work --no-worktree` - Skip worktree setup

### `/wrap`
Concludes your development session with comprehensive checks:
1. Validates code against project rules
2. Checks documentation consistency
3. Saves session context
4. Provides recommended next actions

### `/check-feedback` & `/write-feedback`
Session feedback system for recording learnings and notes between sessions.

### `/backlog`
View and manage project tasks organized by phase.

## Session Context System

Each development session is automatically tracked in `.claude/context/`:

```
.claude/context/
├── 2026-01/
│   ├── 2026-01-20-a8013.md      # Session from Jan 20
│   ├── 2026-01-22-f7bf0.md      # Session from Jan 22
│   └── 2026-01-23-session.md    # Current session
```

Session files contain:
- **Date and session ID** for unique identification
- **Summary of work done** during the session
- **Files changed** in the session
- **Analysis results** from pattern and doc sync checks
- **Recommended actions** for next session

This context is automatically loaded at the start of your next session with `/start-work`.

## Configuration

### Project Rules

Create `.claude/rules/` files to define your project's conventions:

- `versioning.md` - Semantic versioning strategy
- `interaction.md` - Communication and interaction patterns
- Add custom rules as needed

### Custom Skills

Skills are defined in the `skills/` directory and extend the plugin's functionality. Each skill includes:
- `SKILL.md` - Skill description and usage
- `schema.md` - Input/output specifications
- `templates.md` - Usage examples

### Hooks Configuration

Configure automation hooks in `.claude/hooks/hooks.json` to trigger actions at specific points in your workflow.

## Development Workflow Example

Here's a typical development session:

```bash
# 1. Start your session
/start-work

# 2. Choose your task from backlog or start freely
# 3. Make your code changes
# 4. When finished, wrap up the session
/wrap

# /wrap will:
# ✅ Check code follows project patterns
# ✅ Verify documentation is up-to-date
# ✅ Save your session context
# ✅ Suggest next steps
```

## Extensibility

The plugin is designed to be extended with new:
- **Agents**: Custom specialized agents in `agents/`
- **Skills**: New capabilities in `skills/`
- **Commands**: New commands in `commands/`
- **Hooks**: Automated triggers in `.claude/hooks/`

Each component is modular and can be developed independently.

## Requirements

- Claude Code (Claude API client)
- Git (for version control and worktree support)
- Bash/Shell environment

## License

MIT

## Author

[yhyuntak](https://github.com/yhyuntak)

---

For more detailed documentation on specific features, see the command files in the `commands/` directory and skill documentation in `skills/`.
