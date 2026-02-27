# Agent Delegation Rules

> Rules for agent delegation to protect the main context

---

## Why delegate?

Reading/writing files directly in the main context → context pollution
Delegating to agents → receive only results, keeping the context clean

---

## ⛔ Absolute Principles

### 1. File Reading

| Situation | Approach |
|-----------|----------|
| Unfamiliar file | `explore-*` agent **required** |
| Already known file | Direct Read allowed |

### 2. File Writing

| Situation | Approach |
|-----------|----------|
| All file modifications (Write/Edit) | `writer-*` agent **required** |

For clean UI and context protection, **all file modifications must be delegated to writer**.

### 3. Command Execution

| Situation | Approach |
|-----------|----------|
| Build/test/deploy | `Bash` agent **required** |
| Simple checks (git status, ls) | Direct execution allowed |

**These principles apply without exception.**

---

## File Exploration/Search

| Situation | Agent | Example |
|-----------|-------|---------|
| Simple location lookup | `explore-low` | "Where is this function?" |
| Structure/relationship analysis | `explore` | "Show me this module's structure" |
| Architecture analysis | `explore-high` | "Analyze the full dependency graph" |

### Decision Criteria

```
explore-low (Haiku):
- Finding a specific function/class location
- Checking if a file exists
- Simple grep searches

explore (Sonnet):
- Understanding module structure
- Analyzing relationships between files
- Finding patterns

explore-high (Opus):
- Full architecture analysis
- Complex dependency graphs
- Refactoring impact analysis
```

---

## Code Writing/Modification

| Situation | Approach |
|-----------|----------|
| All file modifications | `writer` **required** |
| Complex implementations | `writer-high` **required** |

### Writer 2-Tier Structure

| Complexity | Agent | Criteria |
|------------|-------|----------|
| Standard | `writer` (Sonnet) | General code, CRUD, simple logic |
| High | `writer-high` (Opus) | Algorithms, security, architecture |

### When to use writer-high

```
writer-high (Opus):
- Complex algorithm implementation (sorting, search, DP, graphs)
- Security-related code (authentication, encryption, permissions)
- Architecture pattern implementation (Design Patterns)
- Performance optimization code
- Large-scale refactoring spanning multiple files
```

### When using writer

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
{What to do}

## Target
{File path}

## Requirements
{Requirements}

## Verification
{Verification method - build, test, lint}
"""
)
```

### When using writer-high

```
Task(
  subagent_type="claude-automate:writer-high",
  prompt="""
## Task
{What to do}

## Target
{File path}

## Requirements
{Requirements}

## Complexity Reason
{Why writer-high is needed - algorithm/security/architecture/performance/scale}

## Verification
{Verification method - build, test, lint, security check}
"""
)
```

---

## Exceptions

### Can be handled directly

- Simple status check commands (git status, ls)
- Reading already-known files

### Always delegate (no exceptions)

- Exploring unfamiliar files → `explore-*`
- **All file modifications (Write/Edit)** → `writer-*`
- Build/test/deploy → `Bash` agent

---

## Parallel Execution

Run tasks in parallel when possible.

- Exploration: call simultaneously when checking multiple locations/structures
- Implementation: call simultaneously for independent files
- Tier: follow existing criteria, agents decide based on situation

### Examples

```
# Parallel exploration
Task(explore-low, "Location of A"), Task(explore-low, "Location of B")

# Parallel implementation
Task(writer, "Modify A.py"), Task(writer, "Modify B.py")
```

---

## Call Examples

### Finding a file

```
Task(
  subagent_type="claude-automate:explore-low",
  prompt="Find where the UserService class is defined"
)
```

### Understanding structure

```
Task(
  subagent_type="claude-automate:explore",
  prompt="""
## Target
src/auth/ folder

## Goal
Understand the structure and relationships between files in the auth module

## Depth
Standard
"""
)
```

### Writing code

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
Add a logout method to UserService

## Target
src/services/UserService.ts

## Requirements
- Invalidate session
- Write to log

## Verification
npm run build && npm test
"""
)
```

---

**Last Updated**: 2026-02-25
