# Planning Scenarios

Detailed flows for each scenario type.

---

## Scenario 1: New Feature

### Flow

```
Requirement Understanding → Existing Structure Exploration → Design Decisions → Plan Finalization
         ↓                           ↓                            ↓
    (Question bombardment)        (Explore)               (Question bombardment)
```

### Key Questions

**Phase 1: What & Why**
- What exactly does this feature do?
- Who will use it?
- Why is this needed? (user story)
- Success criteria?

**Phase 2: How (Technical)**
- How does this fit into existing architecture?
- What are the technical choices? (libraries, patterns)
- API design? (if applicable)
- Data model? (if applicable)

**Phase 3: Quality & Risk**
- How will we test this?
- What could go wrong?
- Performance considerations?
- Security considerations?

### Agent Usage

- **Explore**: Understand existing codebase structure
  - Similar features already implemented?
  - Existing patterns to follow?
  - Where should new code live?

### Complexity Assessment

| Complexity | Criteria | Planning Depth |
|------------|----------|---------------|
| Simple | Small, isolated, clear requirements | Light (15min) |
| Medium | Medium scope, some integration | Standard (30min) |
| Complex | Large scope, multiple integrations, unclear | Deep (1hr+) |

---

## Scenario 2: Bug Fix

### Flow

```
Symptom Identification → Root Cause Exploration → Complexity Assessment → (Plan or Quick Fix)
         ↓                        ↓                         ↓
     (Questions)          (Explore/Debugger)         (Automatic decision)
```

### Branching Logic

**Simple Bug** → Skip formal planning, fix directly
- Clear root cause
- Single file change
- Low risk

**Complex Bug** → Full planning
- Unclear root cause
- Multiple files affected
- High risk (core functionality)

### Key Questions

**Phase 1: Understanding**
- Exact symptoms? (what breaks, when, how)
- Reproduction steps?
- Logs/error messages?
- When did it start?

**Phase 2: Analysis**
- Root cause identified?
- Scope of impact?
- Related issues?

**Phase 3: Fix Strategy (if complex)**
- Fix approach?
- Test strategy to prevent regression?
- Need for refactoring?

### Agent Usage

- **Explore**: Find related code
- **Debugger**: Trace execution, analyze logs
  - Stack traces
  - Error patterns
  - State at failure point

---

## Scenario 3: Refactoring

### Flow

```
Current State Analysis → Target State Definition → Impact Scope → Step-by-step Plan
         ↓                       ↓                      ↓
     (Explore)            (Question bombardment)   (Architect)
```

### Key Questions

**Phase 1: Why Refactor**
- What's wrong with current state?
- What's the goal? (better structure, performance, maintainability)
- Is this the right time? (risk vs reward)

**Phase 2: Target Design**
- What should it look like after?
- What principles are we following?
- Examples of good structure to follow?

**Phase 3: Migration**
- Incremental or big-bang?
- How to maintain functionality during transition?
- Test coverage sufficient?

**Phase 4: Risk Management**
- What could break?
- How to minimize disruption?
- Rollback plan?

### Agent Usage

- **Explore**: Deep analysis of current structure
  - Dependencies
  - Usage patterns
  - Code hotspots

- **Architect**: Impact analysis
  - What breaks if we change X?
  - Dependency graph
  - Risk assessment

---

## Scenario 4: Performance Optimization

### Flow

```
Bottleneck Measurement → Root Cause Analysis → Improvement Options → Plan
         ↓                       ↓                      ↓
     (Profiler)              (Explore)          (Question bombardment)
```

### Key Questions

**Phase 1: Baseline**
- Current metrics? (specific numbers)
- Target metrics? (specific numbers)
- Acceptable trade-offs? (memory vs speed, complexity vs gain)

**Phase 2: Diagnosis**
- Where is the bottleneck? (profiling results)
- Why is it slow? (algorithm, I/O, network)
- Quick wins vs structural changes?

**Phase 3: Approach**
- Optimization strategy? (caching, query, algorithm, parallelization)
- Implementation complexity?
- Verification plan? (how to measure improvement)

**Phase 4: Safety**
- Regression tests?
- Performance benchmarks?
- Monitoring strategy?

### Agent Usage

- **Profiler**: Measure and identify bottlenecks
  - CPU profiling
  - Memory profiling
  - Network analysis
  - Database query analysis

- **Explore**: Understand why bottleneck exists
  - Algorithm analysis
  - Data flow tracing

---

## Scenario 5: Migration

### Flow

```
Complete Current State → Target Definition → Risk Analysis → Detailed Plan → Rollback Plan
         ↓                     ↓                  ↓              ↓
    (Explore deeply)    (Question bombardment) (Architect)  (Question bombardment)
```

### Key Questions

**Phase 1: Current State (Deep)**
- Complete understanding of current system?
- All dependencies identified?
- Data structures fully documented?
- Integration points mapped?

**Phase 2: Target State**
- What exactly are we migrating to?
- Why? (benefits must be clear)
- Compatibility requirements?

**Phase 3: Migration Strategy**
- Downtime acceptable? (zero-downtime possible?)
- Incremental or big-bang?
- Data migration approach?
- Validation strategy?

**Phase 4: Risk & Safety**
- What are the risks?
- Rollback plan? (detailed, tested)
- Production migration steps? (exact sequence)
- Monitoring during migration?
- Contingency plans?

**Phase 5: Testing**
- Migration testing plan?
- Staging environment test?
- Data validation?
- Performance comparison?

### Agent Usage

- **Explore**: Complete system understanding
  - All files using old system
  - Data flow mapping
  - Integration points

- **Architect**: Dependency and impact analysis
  - What depends on what
  - Breaking change analysis
  - Risk assessment by component

### Special Considerations

Migrations are **high-risk**. Planning must be thorough:

- ✅ Detailed step-by-step plan
- ✅ Tested rollback procedure
- ✅ Staging validation first
- ✅ Monitoring strategy
- ✅ Communication plan (if affects users)

**Never rush migrations.**

---

## Scenario 6: Other (Flexible)

### When to Use

When the task doesn't fit neatly into the 5 main scenarios:
- Research/investigation tasks
- Documentation updates
- Configuration changes
- Learning/exploration tasks
- Mixed tasks (e.g., "add feature + fix bug")

### Flow

```
Task Understanding → Scope Definition → Custom Checklist → Plan
        ↓                   ↓                  ↓
   (Questions)         (Questions)        (Dynamic)
```

### Key Principle

**Build the checklist dynamically** based on what the task actually needs:

1. **Understand the task** - What are we trying to achieve?
2. **Identify decision points** - What needs to be decided?
3. **Create custom checklist** - Mix and match from other scenarios

### Example: "Update dependencies and add new feature"

```markdown
Decisions Needed:
# From Migration scenario:
- [ ] Which dependencies to update?
- [ ] Breaking changes in updates?
- [ ] Rollback plan if update fails?

# From New Feature scenario:
- [ ] What exactly does the feature do?
- [ ] Where should new code live?
- [ ] Testing approach?

# Custom:
- [ ] Order of operations (update first or feature first)?
- [ ] Can they be done in parallel?
```

### Agent Usage

**Choose based on needs:**

| Need | Agent |
|------|-------|
| Understand codebase | Explore |
| Debug an issue | Debugger |
| Assess impact | Architect |
| Check performance | Profiler |

### Complexity Assessment

For "Other" scenarios, explicitly assess:

1. **Scope**: How many things are we doing?
2. **Risk**: What could go wrong?
3. **Dependencies**: What needs to happen first?

Then decide planning depth accordingly.

---

## Scenario Selection Logic

### Auto-detection Keywords

| Scenario | Keywords |
|----------|----------|
| New Feature | "add", "build", "create", "implement", "new" |
| Bug Fix | "bug", "error", "broken", "fix", "issue", "not working" |
| Refactoring | "refactor", "restructure", "clean up", "reorganize" |
| Performance | "slow", "performance", "optimize", "speed up" |
| Migration | "migrate", "upgrade", "switch to", "move from" |

### Explicit Argument

```bash
/plan new          # Force new feature flow
/plan bug          # Force bug fix flow
/plan refactor     # Force refactoring flow
/plan perf         # Force performance flow
/plan migrate      # Force migration flow
/plan other        # Force flexible flow (build checklist from scratch)
```

### Fallback Behavior

If no scenario is detected and no argument provided:
1. Ask user which scenario best fits
2. If still unclear → Use "Other" scenario with dynamic checklist

---

**Last Updated**: 2026-02-01
