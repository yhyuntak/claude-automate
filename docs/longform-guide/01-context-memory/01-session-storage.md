# Session Storage: Persistent Context Across Claude Code Sessions

## 핵심 개념 (Core Concept)

Claude Code has **no memory between sessions**. Each time you start a new conversation or thread, the agent begins with a clean slate—no knowledge of previous work, decisions, or context. This is both a limitation and an opportunity.

**The Solution**: Use `.claude/sessions/` directory to store `.tmp` files that bridge sessions and allow you to maintain continuous context across project work.

## The Problem

Imagine you're working on a complex feature that requires multiple sessions:

1. **Session 1**: You analyze the codebase, understand the architecture, and plan implementation steps
2. **Session 2**: You start fresh—all that understanding is gone. You have to re-read code, re-analyze patterns
3. **Session 3**: Same problem. Days of accumulated knowledge lost

This is inefficient and leads to:
- Duplicated analysis work
- Lost context about failed approaches
- Repeated mistakes
- Inconsistent decisions

## The Solution: Session State Files

Store session context in `.claude/sessions/` using `.tmp` files. These files act as "long-term memory" for your project work.

## File Structure

```
.claude/
├── sessions/
│   ├── 2026-01-25-feature-auth.tmp      # Current feature work
│   ├── 2026-01-20-bug-caching.tmp       # Bug investigation (completed)
│   └── 2026-01-15-refactor-api.tmp      # Previous work (archived)
├── CLAUDE.md                             # Project-wide configuration
└── context/
    └── 2026-01/                          # Session summaries (different from session state)
```

### File Naming Convention

Use a descriptive naming pattern:

```
{YYYY-MM-DD}-{brief-description}.tmp
```

Examples:
- `2026-01-25-feature-auth.tmp` - Authentication feature implementation
- `2026-01-20-bug-pagination.tmp` - Pagination bug investigation
- `2026-01-15-docs-refactor.tmp` - Documentation refactoring work
- `2026-01-10-performance-profile.tmp` - Performance profiling session

## What to Include in Session Files

Create a `.tmp` file with this structure:

```markdown
# Session State: Feature Name
**Created**: 2026-01-25
**Status**: in_progress | completed | blocked
**Session Thread**: [Link to first message in this work thread]

## Context Summary
[Brief description of what you're working on]

## What We Know
- [Key insight 1]
- [Key insight 2]
- [Architecture discovery 3]

## What We've Tried (Successful Approaches)
1. **Approach**: Authentication with JWT tokens
   - **Result**: ✓ Works well for stateless API
   - **Why it works**: Tokens are stateless, scales easily
   - **Code location**: `src/auth/jwt-handler.ts`

2. **Approach**: Using middleware for token validation
   - **Result**: ✓ Clean separation of concerns
   - **Why it works**: Centralizes auth logic
   - **Code location**: `src/middleware/auth-middleware.ts`

## What We've Tried (Failed Approaches)
1. **Approach**: Session-based authentication
   - **Problem**: Doesn't scale across multiple servers
   - **Why it failed**: Each request must hit same server (sticky sessions)
   - **Lesson learned**: OAuth2/JWT better for distributed systems
   - **Time spent**: ~2 hours

2. **Approach**: Storing tokens in localStorage
   - **Problem**: XSS vulnerability exposure
   - **Why it failed**: Malicious scripts can access tokens
   - **Lesson learned**: Use httpOnly cookies instead
   - **Time spent**: ~1 hour

## What We Haven't Tried Yet
- [ ] Implement refresh token rotation (security hardening)
- [ ] Add rate limiting on auth endpoints
- [ ] Support passwordless authentication (OAuth providers)
- [ ] Implement MFA (multi-factor authentication)

## Next Steps
1. **Immediate** (next session):
   - [ ] Implement refresh token rotation
   - [ ] Add rate limiting
   - [ ] Write integration tests for token flows

2. **Short-term** (this week):
   - [ ] Security audit of auth implementation
   - [ ] Performance testing under load

3. **Future considerations**:
   - [ ] OAuth provider integration
   - [ ] MFA support
   - [ ] API key authentication for services

## Technical Decisions
- **Decision**: Use httpOnly cookies for token storage
  - **Reasoning**: Prevents XSS token theft, automatic HTTP transmission
  - **Trade-off**: Can't access token in JavaScript
  - **Approved**: ✓

- **Decision**: 15-minute token expiry with 7-day refresh tokens
  - **Reasoning**: Balances security and user experience
  - **Trade-off**: Users need to refresh occasionally
  - **Approved**: ✓

## Key Files Involved
- `src/auth/jwt-handler.ts` - JWT creation and validation
- `src/auth/token-service.ts` - Token lifecycle management
- `src/middleware/auth-middleware.ts` - Request authentication
- `tests/auth.integration.test.ts` - Integration tests

## Known Issues
- [ ] **Issue**: Token refresh endpoint not rate-limited yet
  - **Status**: Not yet implemented
  - **Potential impact**: Could be exploited for brute-force attacks
  - **Priority**: HIGH - Fix before production

- [ ] **Issue**: Error messages may leak user existence
  - **Status**: Investigating
  - **Potential impact**: User enumeration vulnerability
  - **Priority**: MEDIUM - Security hardening

## Dependencies & Blockers
- Needs review from security team before deployment
- Waiting for backend team to finalize token format

## Useful Commands & Scripts
```bash
# Generate test JWT tokens for development
npm run generate-test-tokens

# Test auth middleware locally
npm run test:auth

# Check token expiry
npm run check-token-expiry -- --path ./test-token.jwt
```

## Session Continuity
**Previous session** (2026-01-24):
- Analyzed existing authentication code
- Identified security vulnerabilities
- Designed new JWT-based approach

**Current session** (2026-01-25):
- Implemented JWT token creation/validation
- Built auth middleware
- Started writing integration tests

**Expected next session** (2026-01-26):
- Complete integration tests
- Implement refresh token rotation
- Security review

## Session Metrics
- **Total time invested**: ~6 hours across 3 sessions
- **Code lines changed**: ~450 lines in auth module
- **Files modified**: 5 files
- **Tests added**: 12 new test cases
- **Blockers resolved**: 2/3 (1 pending security review)
```

## Setting Up Skills/Commands

### Option 1: Add to `.claude/CLAUDE.md`

Include a reference to session state in your project's `CLAUDE.md`:

```markdown
## Session Management

When working on specific features, create a session state file:

```bash
# Create or update session state
echo "# Session State: [Feature Name]" > .claude/sessions/$(date +%Y-%m-%d)-[description].tmp
```

Example session files in this project:
- `.claude/sessions/2026-01-25-feature-auth.tmp` - Active work on auth feature
- `.claude/sessions/2026-01-20-bug-caching.tmp` - Completed cache bug fix

**How to use**:
1. Start new feature work → Create `.tmp` file in `.claude/sessions/`
2. Throughout session → Update file with findings, tried approaches, next steps
3. End session → Leave file with complete state for next session
4. Next session → Read `.tmp` file first to understand context
5. Session complete → Move to `.claude/context/YYYY-MM/` with detailed summary
```

### Option 2: Create Custom Commands

Create a helper script at `.claude/commands/session-state.sh`:

```bash
#!/bin/bash
# Usage: ./commands/session-state.sh new "feature-auth"
# Usage: ./commands/session-state.sh list
# Usage: ./commands/session-state.sh view "feature-auth"

ACTION=$1
DESCRIPTION=$2
SESSION_DIR=".claude/sessions"

case $ACTION in
  new)
    DATE=$(date +%Y-%m-%d)
    FILE="$SESSION_DIR/$DATE-$DESCRIPTION.tmp"
    cat > "$FILE" << 'EOF'
# Session State: {DESCRIPTION}
**Created**: $(date +%Y-%m-%d)
**Status**: in_progress

## Context Summary
[Add your context here]

## What We Know
-

## What We've Tried (Successful)
1. **Approach**:
   - **Result**:

## What We've Tried (Failed)
1. **Approach**:
   - **Problem**:

## What We Haven't Tried Yet
- [ ]

## Next Steps
1. **Immediate** (next session):
   - [ ]

## Key Files Involved
-

## Known Issues
- [ ]

## Useful Commands
EOF
    echo "Created session file: $FILE"
    ;;

  list)
    echo "Session files:"
    ls -lh "$SESSION_DIR"/*.tmp 2>/dev/null || echo "No session files found"
    ;;

  view)
    FILE="$SESSION_DIR/$DESCRIPTION.tmp"
    if [ -f "$FILE" ]; then
      cat "$FILE"
    else
      echo "Session file not found: $FILE"
    fi
    ;;

  *)
    echo "Usage: session-state.sh [new|list|view] [description]"
    ;;
esac
```

### Option 3: Integrate with `/start-work` Skill

Add this to your skill's initialization:

```javascript
// In your /start-work command
if (sessionStateFile) {
  console.log("Loading session state...");
  const state = await readFile(`.claude/sessions/${sessionStateFile}`);
  console.log("Previous session context:\n");
  console.log(state);
}
```

## Practical Examples

### Example 1: Authentication Feature

You're implementing JWT authentication across 3 sessions.

**Session 1 File** (2026-01-23-feature-auth.tmp):
```markdown
# Session State: JWT Authentication Implementation
**Created**: 2026-01-23
**Status**: in_progress

## What We Know
- Project uses Express.js backend
- Currently no authentication
- Frontend is React SPA

## What We've Tried (Successful Approaches)
1. **JWT token structure decided**
   - Payload includes: userId, email, roles, iat, exp
   - Algorithm: HS256
   - Key stored in environment variable

## Next Steps
1. Implement token generation in auth service
2. Create auth middleware for route protection
3. Add token validation endpoint
```

**Session 2 File** (2026-01-24-feature-auth.tmp):
```markdown
# Session State: JWT Authentication Implementation
**Created**: 2026-01-23
**Updated**: 2026-01-24
**Status**: in_progress

## What We Know
- Token structure finalized and tested
- Auth middleware works for route protection

## What We've Tried (Successful Approaches)
1. **JWT token creation** ✓
   - Service: `src/auth/token-service.ts`
   - Generates tokens with 15-minute expiry

2. **Auth middleware** ✓
   - File: `src/middleware/auth-middleware.ts`
   - Validates tokens on protected routes
   - Returns 401 for invalid/expired tokens

## What We've Tried (Failed Approaches)
1. **Session-based auth**
   - Problem: Doesn't scale with multiple API servers
   - Switched to JWT instead

## What We Haven't Tried Yet
- [ ] Refresh token implementation
- [ ] Token revocation (logout)
- [ ] Role-based access control (RBAC)

## Next Steps
1. **Immediate**:
   - [ ] Implement refresh token endpoint
   - [ ] Add logout endpoint
   - [ ] Write integration tests

2. **Security review**:
   - [ ] Rate limit auth endpoints
   - [ ] Validate token expiry edge cases
```

**Session 3 File** (after work completes):
```markdown
# Session State: JWT Authentication Implementation
**Created**: 2026-01-23
**Completed**: 2026-01-25
**Status**: ✓ COMPLETED

## Summary
Successfully implemented complete JWT authentication system with token refresh and logout.

## What We Know
- Full auth flow works: login → get token → refresh → logout
- Security: httpOnly cookies prevent XSS
- Performance: Token validation is fast (<1ms)

## What We've Tried (Successful Approaches)
1. **JWT token creation and validation** ✓
2. **Auth middleware** ✓
3. **Refresh token mechanism** ✓
4. **Logout endpoint** ✓
5. **Rate limiting on auth endpoints** ✓

## What We've Tried (Failed Approaches)
1. **Session-based auth** → Switched to JWT
2. **Storing token in localStorage** → Switched to httpOnly cookies

## Final Implementation
- Files: `src/auth/*`, `src/middleware/auth-middleware.ts`
- Tests: `tests/auth.integration.test.ts` (15 tests, all passing)
- Routes: `/auth/login`, `/auth/refresh`, `/auth/logout`, `/auth/verify`

## Key Learnings
1. Always use httpOnly cookies for sensitive tokens
2. Refresh tokens enable long sessions without re-login
3. Rate limiting prevents brute-force attacks on auth endpoints

## Deployment Notes
- Environment variables required: JWT_SECRET, TOKEN_EXPIRY, REFRESH_TOKEN_EXPIRY
- Database migration: None required (tokens are stateless)
- Rollback plan: Can disable auth middleware temporarily by setting env var
```

### Example 2: Bug Investigation

Hunting down a memory leak in caching system.

```markdown
# Session State: Memory Leak Investigation
**Created**: 2026-01-20
**Status**: completed

## What We Know
- Application memory grows ~50MB per hour
- Suspected: Cache not clearing properly
- Pattern: Only occurs under high traffic

## What We've Tried (Successful Approaches)
1. **Identified cache implementation** ✓
   - Using Redis with incorrect TTL settings
   - Found in: `src/cache/redis-client.ts:line 42`

2. **Fixed TTL configuration** ✓
   - Changed from 86400s (1 day) to 3600s (1 hour)
   - Added LRU eviction policy

## What We've Tried (Failed Approaches)
1. **Blamed middleware memory leaks**
   - Turned out: Cache was the culprit
   - Lesson: Profile before guessing

2. **Tried garbage collection tuning**
   - Didn't help; root cause was elsewhere
   - Lesson: Focus on data structures first

## Solution
- Changed Redis TTL from 1 day to 1 hour
- Added LRU eviction when cache reaches 100MB
- Result: Memory stable at ~200MB (was growing unbounded)

## Deployment
- No downtime required
- Simple config change in Docker environment variables
- Monitored: Memory usage dropped 60% within 1 hour of deployment
```

### Example 3: Refactoring Work

Multi-session refactoring of API endpoints.

```markdown
# Session State: API Refactoring (REST → GraphQL)
**Created**: 2026-01-10
**Status**: in_progress

## Current Progress
- Phase 1 (Sessions 1-2): Authentication endpoints refactored ✓
- Phase 2 (Current): User CRUD endpoints (50% complete)
- Phase 3 (Planned): Product catalog endpoints
- Phase 4 (Planned): Order management endpoints

## What We Know
- GraphQL schema designed and agreed upon
- Apollo Server 4 configured and running
- 14 REST endpoints still need conversion

## What We've Tried (Successful Approaches)
1. **GraphQL schema design** ✓
   - Resolvers use existing service layer
   - No database changes needed

2. **Auth token middleware for GraphQL** ✓
   - Works the same as REST
   - Guards all protected queries/mutations

## What We Haven't Tried Yet
- [ ] Implement batching/dataloader for N+1 queries
- [ ] Add GraphQL federation for microservices
- [ ] Performance testing (GraphQL vs REST)

## Endpoints Completed (Rest ➜ GraphQL)
1. `POST /auth/login` → `mutation { login }` ✓
2. `GET /users/:id` → `query { user }` ✓
3. `GET /users` → `query { users }` ✓
4. `PUT /users/:id` → `mutation { updateUser }` ✓

## Endpoints In Progress
5. `DELETE /users/:id` → `mutation { deleteUser }` (40% done)
6. `POST /users` → `mutation { createUser }` (20% done)

## Endpoints Remaining
- Product endpoints (6 endpoints)
- Order endpoints (4 endpoints)
- Category endpoints (2 endpoints)

## Blocking Issues
- [ ] Pagination for large datasets (designing resolver)
- [ ] File uploads not yet tested with GraphQL

## Key Files
- `src/graphql/schema.graphql` - Type definitions
- `src/graphql/resolvers/` - All resolver implementations
- `tests/graphql/` - Integration tests
```

## Advantages of Session Storage

### 1. **Continuity Without Cognitive Load**
- Skip the "where was I?" period at session start
- No context switching overhead
- Immediate productivity

### 2. **Prevent Repeated Work**
- Tried approaches are documented
- Don't re-investigate failed paths
- Learn from what didn't work

### 3. **Knowledge Preservation**
- Architecture insights persist
- Design decisions are recorded with rationale
- Learnings survive session boundaries

### 4. **Better Decisions**
- See failed approaches in context
- Make informed trade-offs
- Build on proven successful patterns

### 5. **Easy Handoff**
- Other team members can read session state
- onboarding new developers is faster
- Context is explicit, not implicit

### 6. **Historical Record**
- Track how problems were solved
- See evolution of implementation
- Useful for post-mortems and retrospectives

### 7. **Lower Cognitive Overhead**
- Brain doesn't need to remember context
- Can focus on actual implementation
- Reduces decision fatigue

## Best Practices

### DO:
- ✓ Update session file at end of each session
- ✓ Document why approaches failed, not just that they failed
- ✓ Include code locations for easy reference
- ✓ List next steps with priority
- ✓ Record time spent on investigations (for ROI analysis)
- ✓ Include links to related files and issues
- ✓ Archive completed work in `.claude/context/`

### DON'T:
- ✗ Leave session files ambiguous about status
- ✗ Update after work is done (update during)
- ✗ Skip recording failed approaches ("failures are learning")
- ✗ Leave TODO items without priority
- ✗ Forget to specify which files were modified
- ✗ Assume next session's context—be explicit
- ✗ Mix multiple unrelated features in one session file

## GitHub & Repository Integration

### Storing Session Files

Session files should be in `.gitignore`:

```gitignore
# .gitignore
.claude/sessions/*.tmp
```

Why?
- Session state is personal to the developer
- Contains investigation notes, not production code
- Re-generated each project cycle

### Session Summaries (Different from Session State)

Archive completed work in git:

```
# .claude/context/2026-01/2026-01-25-auth-feature.md
# This is a SUMMARY of completed work, not the .tmp file

Contains:
- What was accomplished
- Code changes made
- Lessons learned
- Commit hashes
```

Example archived session: https://github.com/example/project/blob/main/.claude/context/2026-01/2026-01-25-auth-feature.md

### Team Context

For team projects, maintain shared session index:

```markdown
# .claude/SESSIONS.md (Shared with team)

## Active Sessions
- @alice: 2026-01-25-feature-payments (payment processing)
- @bob: 2026-01-24-bug-cache (memory leak investigation)

## Recent Completions
- @charlie: 2026-01-23-docs-api (API documentation) ✓
- @alice: 2026-01-20-refactor-auth (auth refactoring) ✓

## Blocked Work
- @bob's work blocked on security review (expected 2026-01-27)
```

## Workflow Integration

### Step 1: Session Start

When beginning new work:

```bash
# Create new session file
date=$(date +%Y-%m-%d)
feature="feature-name"
cat > ".claude/sessions/$date-$feature.tmp" << 'EOF'
# Session State: Feature Name
**Created**: $date
**Status**: in_progress

## Context Summary
[Add context]

## What We Know
-

## Next Steps
-
EOF
```

### Step 2: During Session

Update the session file regularly:

```markdown
# After first analysis
## What We Know
- Architecture discovered: [details]
- Database schema understood

# After implementing feature
## What We've Tried (Successful)
1. **Approach**: [details]
   - **Result**: ✓ Works

# When hitting issues
## What We've Tried (Failed)
1. **Approach**: [details]
   - **Problem**: [specific issue]
   - **Lesson learned**: [takeaway]
```

### Step 3: Session End

Complete and archive:

```bash
# Move from .tmp to permanent record
mv .claude/sessions/2026-01-25-feature-auth.tmp \
   .claude/context/2026-01/2026-01-25-feature-auth.md

# Add final status and summary
# (Update status to "completed", add final metrics)
```

## Real-World Example: claude-automate Project

The claude-automate project uses session context files in `.claude/context/2026-01/`:

**Example**: `/Users/yoohyuntak/workspace/claude-automate/.claude/context/2026-01/2026-01-25-110600.md`

This file documents:
- Session purpose: "Project Status Review & Feedback Completion"
- Work summary: feedback verification, feature confirmation
- Problems encountered and solutions
- Decisions made during session
- Incomplete work for next session
- Technical notes and references

Used by: Next session can quickly understand what was accomplished and what needs attention.

## Troubleshooting

### Problem: Session file got too long

**Solution**: Archive to `.claude/context/` and create fresh `.tmp` for continuing work

### Problem: Can't remember what was tried

**Solution**: Session file should have "What We've Tried" sections with detailed notes

### Problem: Next session person doesn't know context

**Solution**: Use clear "Next Session Suggestions" section with specificity, not vague notes

### Problem: Session file is outdated

**Solution**: Update at end of EACH session. Don't wait until work is complete

## Summary

Session storage via `.claude/sessions/*.tmp` files solves a fundamental limitation of Claude Code: **lack of memory across sessions**.

By maintaining structured session state:
1. You preserve context automatically
2. You document failed approaches (learning)
3. You make faster decisions in next session
4. You enable team handoffs
5. You build institutional knowledge

**The key**: Be disciplined about updating session files. They're most valuable when they're current.

Start with your next project. Create `.claude/sessions/`. You'll immediately see the value when session 2 starts and you have full context waiting for you.
