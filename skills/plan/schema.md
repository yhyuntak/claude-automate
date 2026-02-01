# Plan Schema

Plan document templates and dynamic checklist examples.

---

## Plan Document Template

```markdown
# Plan: {Title}

> {One-line description}

**Created**: {YYYY-MM-DD}
**Scenario**: {new|bug|refactor|perf|migrate}

---

## Context

### What
{What needs to be built/fixed/changed}

### Why
{Reason/motivation for this work}

### Current State
{Relevant current state of codebase}

---

## Decisions Made

### Architecture
- {Key architectural decision 1}
- {Key architectural decision 2}

### Technical Choices
- {Technology/library choice 1}: {Reason}
- {Technology/library choice 2}: {Reason}

### API/Interface Design
- {Endpoint/function signature}
- {Data structures}

### Non-Functional Requirements
- Performance: {targets}
- Security: {requirements}
- Scalability: {considerations}

---

## Implementation Direction

### Approach
{High-level approach description}

### Files/Modules Affected
- `{file1}`: {what changes}
- `{file2}`: {what changes}

### Step-by-step Plan
1. {Step 1}
2. {Step 2}
3. {Step 3}

### Dependencies
- {External dependency 1}
- {Internal dependency 1}

---

## Considerations

### Risks
- {Risk 1}: {Mitigation}
- {Risk 2}: {Mitigation}

### Trade-offs
- {Trade-off 1}: {Chosen direction and why}

### Testing Strategy
- {Test approach}
- {Coverage targets}

### Rollback Plan (if applicable)
- {How to revert if needed}

---

## Open Questions

- [ ] {Question 1}
- [ ] {Question 2}

---

## Change History

| Date | Change | Reason |
|------|--------|--------|
| {YYYY-MM-DD} | {What changed} | {Why it changed} |

---

**Status**: {draft|ready|in-progress|completed}
```

---

## Dynamic Checklist Examples

### New Feature: "Authentication System"

```markdown
Decisions Needed:
- [ ] Authentication method (JWT / Session / OAuth)
- [ ] User storage (DB schema, table structure)
- [ ] Session expiry policy (duration, refresh token?)
- [ ] Security requirements (password rules, 2FA, etc.)
- [ ] API endpoint structure (/api/auth/...)
- [ ] Error handling approach
- [ ] Rate limiting strategy
- [ ] Token storage location (client-side)
```

### Bug Fix: "Intermittent Login Failure"

```markdown
Information Needed:
- [ ] Reproduction steps
- [ ] Error logs/messages
- [ ] When did it start?
- [ ] Affected scope (all users? specific conditions?)
- [ ] Frequency (always? sometimes? pattern?)
- [ ] Environment (dev/staging/prod?)
- [ ] Recent changes that might be related
```

**Complexity Assessment**:
- Simple (clear cause) → May skip formal planning
- Complex (unclear root cause) → Full planning needed

### Refactoring: "Module Separation"

```markdown
Decisions Needed:
- [ ] Target structure (what modules?)
- [ ] Migration approach (incremental vs big-bang)
- [ ] Test coverage verification
- [ ] Affected dependencies (what breaks?)
- [ ] Backward compatibility needs
- [ ] Breaking change strategy
- [ ] Timeline (one PR vs multiple?)
```

### Performance Optimization: "API Response Time"

```markdown
Analysis Needed:
- [ ] Current baseline metrics
- [ ] Target performance (specific numbers)
- [ ] Bottleneck identification (profiling results)
- [ ] Optimization approach (caching/query/algorithm)
- [ ] Trade-offs (memory vs speed, complexity vs gain)
- [ ] Measurement strategy (how to verify improvement)
- [ ] Regression prevention (performance tests)
```

### Migration: "Database Schema Change"

```markdown
Critical Decisions:
- [ ] New schema design
- [ ] Data migration strategy
- [ ] Downtime acceptable? (zero-downtime plan?)
- [ ] Rollback plan (how to revert)
- [ ] Backward compatibility period
- [ ] Data validation approach
- [ ] Migration testing plan (staging first?)
- [ ] Production migration steps (detailed)
- [ ] Monitoring during migration
```

---

## Checklist Evolution

Checklist is **dynamic** - it evolves during planning:

```
Initial checklist (Step 1)
    ↓
+ Items discovered during exploration (Step 2)
    ↓
+ Items discovered during dialog (Step 3)
    ↓
Final checklist → Plan document
```

**Principle**: Start with obvious items, grow as understanding deepens.

---

## Plan Status States

| Status | Meaning | Next Action |
|--------|---------|-------------|
| draft | Planning in progress | Continue dialog |
| ready | Plan complete, ready to start | Begin implementation |
| in-progress | Implementation started | Track progress |
| completed | Work finished | Archive |

---

## File Naming Convention

```
.claude/plans/{YYYY-MM-DD}-{slug}.md

Examples:
.claude/plans/2026-01-31-jwt-auth-system.md
.claude/plans/2026-01-31-fix-login-bug.md
.claude/plans/2026-01-31-refactor-api-layer.md
```

**Slug rules**:
- Lowercase
- Hyphen-separated
- Descriptive (what, not how)
- 3-5 words ideal

---

## Change History Template

When plan changes during implementation, record it:

```markdown
## Change History

| Date | Change | Reason |
|------|--------|--------|
| 2026-01-31 | Initial plan | - |
| 2026-02-01 | Changed auth from Session to JWT | Performance requirement discovered |
| 2026-02-02 | Added rate limiting | Security review feedback |
```

**Principle**: Every significant deviation from the original plan should be recorded with its reasoning.

---

**Last Updated**: 2026-02-01
