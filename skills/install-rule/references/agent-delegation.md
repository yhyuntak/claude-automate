# Agent Delegation Rules

> Agent delegation rules for context protection

---

## Why Delegate?

Reading/writing files directly in main context → context pollution
Delegating to agents → receive only results, keep context clean

---

## File Exploration/Search

| Situation | Agent | Example |
|-----------|-------|---------|
| Simple location search | `explore-low` | "Where is this function?" |
| Structure/relationship analysis | `explore` | "Show me this module's structure" |
| Architecture analysis | `explore-high` | "Analyze the full dependency graph" |

### Decision Criteria

```
explore-low (Haiku):
- Find specific function/class location
- Verify file existence
- Simple grep search

explore (Sonnet):
- Understand module structure
- Analyze relationships between files
- Find patterns

explore-high (Opus):
- Full architecture analysis
- Complex dependency graphs
- Refactoring impact analysis
```

---

## Code Writing/Modification

| Situation | Approach |
|-----------|----------|
| Small change (under 10 lines) | Main can do directly |
| Medium work (10-50 lines) | `writer` recommended |
| Large implementation (50+ lines) | `writer` required |
| Complex implementation | `writer-high` required |

### Writer 2-Tier Structure

| Complexity | Agent | Criteria |
|------------|-------|----------|
| Standard | `writer` (Sonnet) | General code, CRUD, simple logic |
| High | `writer-high` (Opus) | Algorithms, security, architecture |

### When to Use writer-high

```
writer-high (Opus):
- Complex algorithm implementation (sorting, search, DP, graphs)
- Security-related code (authentication, encryption, permissions)
- Architecture pattern application (Design Pattern implementation)
- Performance optimization code
- Large-scale refactoring across multiple files
```

### Using writer

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
{what to do}

## Target
{file path}

## Requirements
{requirements}

## Verification
{verification method - build, test, lint}
"""
)
```

### Using writer-high

```
Task(
  subagent_type="claude-automate:writer-high",
  prompt="""
## Task
{what to do}

## Target
{file path}

## Requirements
{requirements}

## Complexity Reason
{why writer-high is needed - algorithm/security/architecture/performance/scale}

## Verification
{verification method - build, test, lint, security check}
"""
)
```

---

## Exceptions

### Can Be Handled Directly

- Config file edits (1-2 lines)
- Typo fixes
- Adding comments
- Files whose content is already known

### Must Always Delegate

- Exploring unfamiliar codebases
- Changes spanning multiple files
- Complex logic implementation

---

## Invocation Examples

### Find a File

```
Task(
  subagent_type="claude-automate:explore-low",
  prompt="Find where the UserService class is defined"
)
```

### Understand Structure

```
Task(
  subagent_type="claude-automate:explore",
  prompt="""
## Target
src/auth/ folder

## Goal
Understand the structure of the auth module and relationships between files

## Depth
Standard
"""
)
```

### Write Code

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
- Write log entry

## Verification
npm run build && npm test
"""
)
```

---

**Last Updated**: 2026-02-03
