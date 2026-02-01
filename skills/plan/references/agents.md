# Planning Agents

Agent definitions for use in planning workflow.

---

## Agent Roster

| Agent | Available Tiers | Default | Purpose |
|-------|----------------|---------|---------|
| **Explore** | low / default / high | Sonnet | Codebase exploration, structure understanding |
| **Debugger** | low / default | Sonnet | Bug root cause tracing, log analysis |
| **Architect** | low / default | **Opus** | Dependency analysis, impact assessment |
| **Profiler** | low / default | Sonnet | Performance measurement, bottleneck identification |

### Tier Files

```
agents/
├── explore.md          # Sonnet (기본)
├── explore-low.md      # Haiku (단순 탐색)
├── explore-high.md     # Opus (복잡한 구조 분석)
├── debugger.md         # Sonnet (기본)
├── debugger-low.md     # Haiku (단순 로그 확인)
├── architect.md        # Opus (기본, 전략적 결정)
├── architect-low.md    # Sonnet (간단한 의존성 확인)
├── profiler.md         # Sonnet (기본)
└── profiler-low.md     # Haiku (단순 측정)
```

---

## Tier Selection Guide

**원칙**: 작업 복잡도에 맞는 최소 tier 선택 (토큰 절약)

| 복잡도 | Tier | 사용 시점 |
|--------|------|----------|
| Simple | **-low** (Haiku) | 단순 조회, 파일 찾기, 빠른 확인 |
| Standard | **default** (Sonnet/Opus) | 분석, 패턴 파악, 일반 작업 |
| Complex | **-high** (Opus) | 복잡한 구조, 전략적 결정 |

### 예시

```
# 단순: "이 함수 어디 있어?" → explore-low
# 표준: "인증 관련 코드 구조 파악해줘" → explore
# 복잡: "전체 시스템 아키텍처 분석해줘" → explore-high

# 단순: "이 에러 로그 확인해줘" → debugger-low
# 표준: "로그인 버그 원인 분석해줘" → debugger

# 단순: "이 모듈 의존성 확인해줘" → architect-low
# 표준: "리팩토링 영향도 분석해줘" → architect (Opus)

# 단순: "이 함수 복잡도 확인해줘" → profiler-low
# 표준: "API 병목 분석해줘" → profiler
```

---

## Agent 1: Explore

### Role

Understand codebase structure, find relevant code, map relationships.

### When to Use

- **New Feature**: Find similar existing features, understand where new code should live
- **Bug Fix**: Locate relevant code, understand data flow
- **Refactoring**: Analyze current structure deeply
- **Performance**: Understand code paths
- **Migration**: Complete system mapping

### Inputs

- **Target**: What to explore (feature area, module, file)
- **Goal**: What information to find
- **Depth**: Surface-level or deep dive

### Outputs

- File/module relationships
- Existing patterns
- Code organization
- Data flow

### Example Prompts

```
"Explore authentication-related code.
 Find: existing auth patterns, where new JWT code should live."

"Explore user management module deeply.
 Map: all files, dependencies, data structures."

"Find code related to API rate limiting.
 Understand: current implementation approach."
```

---

## Agent 2: Debugger

### Role

Trace bug root causes, analyze logs, understand failure scenarios.

### When to Use

- **Bug Fix**: Always for complex bugs
- **Performance**: Sometimes (if bug-like behavior)

### Inputs

- **Symptoms**: Error messages, failure conditions
- **Logs**: Relevant log files/output
- **Reproduction**: Steps to reproduce
- **Context**: When it started, affected scope

### Outputs

- Root cause hypothesis
- Stack trace analysis
- Related issues
- Fix suggestions

### Example Prompts

```
"Debug intermittent login failure.
 Symptoms: 401 error randomly, no pattern
 Logs: [attach logs]
 Started: after deployment last Tuesday"

"Trace why user data is null in certain cases.
 Reproduction: load profile page after signup"
```

---

## Agent 3: Architect

### Role

Analyze dependencies, assess impact of changes, evaluate architectural decisions.

**Why Opus?** Architectural decisions require high-level reasoning, trade-off analysis, and strategic thinking.

### When to Use

- **Refactoring**: Always (impact analysis critical)
- **Migration**: Always (high-risk decisions)
- **New Feature**: Sometimes (if major architectural change)

### Inputs

- **Current State**: System description
- **Proposed Change**: What will change
- **Scope**: Boundaries of analysis

### Outputs

- Dependency graph
- Impact assessment (what breaks)
- Risk analysis
- Alternative approaches
- Recommendations

### Example Prompts

```
"Analyze impact of moving auth logic to separate service.
 Current: monolithic app
 Proposed: auth microservice
 Scope: all auth-related endpoints"

"Assess dependencies for refactoring user module.
 Current structure: [describe]
 Target structure: [describe]"

"Evaluate migration from REST to GraphQL.
 Risk analysis: breaking changes, client impact
 Recommend: incremental or big-bang?"
```

---

## Agent 4: Profiler

### Role

Measure performance, identify bottlenecks, analyze resource usage.

### When to Use

- **Performance**: Always
- **Migration**: Sometimes (performance validation)

### Inputs

- **Target**: What to profile (endpoint, function, query)
- **Metrics**: What to measure (time, memory, CPU, network)
- **Baseline**: Current performance numbers

### Outputs

- Profiling results
- Bottleneck identification
- Metrics comparison
- Optimization suggestions

### Example Prompts

```
"Profile /api/users endpoint.
 Measure: response time, database query time
 Baseline: currently 2-3 seconds"

"Identify memory bottleneck in data processing.
 Symptoms: memory usage grows to 4GB
 Target: processLargeFile() function"

"Compare performance before/after caching.
 Baseline: 500ms average
 Target: <100ms with cache"
```

---

## Agent Invocation Protocol

### Parallel vs Sequential

**Parallel** (launch together):
```
Multiple independent explorations
Different code areas
Non-dependent tasks
```

**Sequential** (one after another):
```
Second task needs first task's output
Dependency between analyses
Decision point between tasks
```

### Example: Refactoring Flow

```
[Explore] ─┐
           ├─→ [Wait for both] ─→ [Architect]
[Explore] ─┘                       ↓
                            Impact Assessment
```

Two explores run parallel (different modules), then architect uses both results.

### Result Integration

Main Claude (skill) integrates agent results:

```
Agent results → Main Claude → Synthesized insight → User
```

Don't just forward agent outputs. Synthesize and present coherently.

---

## Agent Communication Format

### Request to Agent

```markdown
## Task
{What agent should do}

## Context
{Background information}

## Inputs
- Input 1: {value}
- Input 2: {value}

## Expected Output
{What format, what information}
```

### Response from Agent

```markdown
## Summary
{Brief summary of findings}

## Details
{Detailed analysis}

## Recommendations (if applicable)
{Suggested next steps}
```

---

## Agent Development

### When to Create New Agent

✅ Create when:
- Distinct responsibility
- Different model tier needed
- Parallel execution beneficial
- Reusable across scenarios

❌ Don't create when:
- Can be parameter of existing agent
- Single-use logic
- Responsibility unclear

### Naming Convention

```
{role}.md          # Standard tier (Sonnet)
{role}-high.md     # High tier (Opus)
{role}-low.md      # Low tier (Haiku)
```

---

**Last Updated**: 2026-02-01
