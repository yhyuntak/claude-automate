# Session Storage Examples

This directory contains example session state files (.tmp) that demonstrate the session storage pattern described in the [Session Storage guide](../../01-context-memory/01-session-storage.md).

## Files

### `example-session.tmp`

A complete, realistic example session file showing a **database migration and performance optimization** project across multiple sessions.

**What it demonstrates:**
- Multi-session project tracking (started 2026-01-20, currently in-progress as of 2026-01-25)
- Detailed documentation of successful and failed approaches
- Realistic technical decisions with trade-offs
- Performance metrics and comparisons
- Risk analysis and mitigation strategies
- Complex dependencies and blocking issues
- Session continuity tracking
- Session metrics and key learnings

**Why this example is useful:**
- Shows a realistic, complex project (database migration)
- Includes actual technical details (connection pooling, batch sizing, ORM comparison)
- Demonstrates how to handle failures and lessons learned
- Shows proper structure for tracking metrics and decisions
- Includes practical risk/mitigation tables
- Uses proper formatting for easy reading in next session

## How to Use These Examples

### As a Template

When starting new work, copy the structure of `example-session.tmp`:

```bash
# Create new session file based on example
date=$(date +%Y-%m-%d)
cp example-session.tmp /path/to/.claude/sessions/$date-your-feature.tmp
# Then edit the file with your project details
```

### Key Sections to Include

1. **Metadata** (at the top)
   - Created date
   - Updated date
   - Current status
   - Session thread link

2. **Context Summary**
   - Brief description of what you're working on
   - Why it matters
   - Current phase in the project

3. **What We Know**
   - Key technical insights
   - Architecture discoveries
   - Constraints and requirements
   - Team decisions

4. **Successful Approaches**
   - What worked and why
   - Code locations
   - Time investment
   - Validation evidence

5. **Failed Approaches**
   - What didn't work and why
   - Root causes of failures
   - Lessons learned
   - Time spent investigating

6. **Not Yet Attempted**
   - Checkbox list of ideas/approaches to try
   - Enables continuity ("I remember we wanted to try X")

7. **Next Steps**
   - Immediate actions (next session)
   - Short-term goals (this week)
   - Future considerations

8. **Technical Decisions**
   - Major choices made
   - Reasoning and trade-offs
   - Team approval status

9. **Known Issues**
   - Bugs or problems discovered
   - Current status and potential impact
   - Priority and mitigation strategy

10. **Dependencies & Blockers**
    - What's blocking progress
    - External dependencies
    - When they're expected to be resolved

11. **Session Continuity**
    - What was done in previous sessions
    - What's planned for next sessions
    - Evolution of the work

12. **Session Metrics**
    - Time investment breakdown
    - Code changes quantity
    - Tests added
    - Blockers resolved

## Realistic Features in `example-session.tmp`

This example intentionally includes realistic details:

- **Failed approaches with lessons**: Shows that failure is expected and valuable
- **Technical trade-offs**: Every decision has costs and benefits
- **Actual time estimates**: Realistic time investment for each approach
- **Performance metrics**: Before/after comparison with concrete numbers
- **Risk analysis**: Acknowledges what could go wrong and mitigation strategies
- **Multi-session tracking**: Shows how to track work across 3+ sessions
- **Decision log**: Records why choices were made, not just what was chosen

## Variations for Different Project Types

### Bug Investigation

Example structure for hunting down bugs:

```markdown
## What We Know
- Symptoms: Application crashes under load
- Reproduction: Happens after 500+ concurrent users
- Location: Likely in request handler or database layer

## What We've Tried (Successful)
1. **Isolated to database layer** ✓
   - Disabled request handler caching, issue persists

## What We've Tried (Failed)
1. **Blamed middleware memory leaks** → Actually was database
2. **Increased server memory** → Didn't help

## Solution
- Root cause: Connection pool exhaustion
- Fix: Increase pool size from 20 to 100
```

### Feature Implementation

Example structure for implementing new features:

```markdown
## What We Know
- Requirements: Implement user role-based access control
- Constraints: Must not break existing API
- Timeline: Complete by next sprint

## What We've Tried (Successful)
1. **Database schema for roles** ✓
2. **Middleware for role checking** ✓

## What We Haven't Tried Yet
- [ ] Integration with third-party identity provider
- [ ] Performance testing with 1000+ roles
```

### Refactoring Work

Example structure for large refactoring projects:

```markdown
## Current Progress
- Phase 1: Analyzed existing code ✓
- Phase 2: Designed new architecture ✓
- Phase 3: Implemented core modules (50% complete)
- Phase 4: Planned - Testing and optimization

## What We've Tried (Successful)
1. **Modular architecture** ✓
   - Results in 40% less coupling between modules
```

## Tips for Effective Session Files

**DO:**
- ✓ Update at the end of each session while details are fresh
- ✓ Include specific file paths for code references
- ✓ Document time spent on investigations (helps prioritize)
- ✓ Explain WHY approaches failed, not just that they failed
- ✓ List next steps in priority order

**DON'T:**
- ✗ Leave session status ambiguous (use: in_progress, completed, blocked)
- ✗ Forget to document failed approaches (they're learning!)
- ✗ Use vague descriptions ("fixed stuff", "did things")
- ✗ Mix multiple unrelated features in one session file
- ✗ Leave TODO items without priority or context

## Real-World Example

The `example-session.tmp` file documents a realistic database migration project with:

- **4 successful approaches**: PostgreSQL schema design, Knex.js implementation, feature flag strategy, migration script
- **4 failed approaches**: TypeORM, dual-write consistency, daytime migration, cascading deletes
- **6 identified risks** with mitigation strategies
- **Performance metrics**: 6.8x improvement measured and documented
- **Time tracking**: ~24 hours invested, broken down by approach
- **Decision log**: 5 major decisions recorded with outcomes
- **Session continuity**: Plans for 4 different sessions across the project lifecycle

This demonstrates how a well-structured session file enables seamless project continuity.

## See Also

- [Session Storage Guide](../../01-context-memory/01-session-storage.md) - Complete documentation
- [Strategic Compacting](../../01-context-memory/02-strategic-compacting.md) - How to archive old sessions
- [Continuous Learning](../../01-context-memory/06-continuous-learning.md) - Building institutional knowledge
