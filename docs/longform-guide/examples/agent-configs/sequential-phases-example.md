# Complete Sequential Phases Workflow Example

> **Example Scenario**: Building a user authentication system upgrade
>
> This document walks through a complete real-world task using the 5-phase orchestrator pattern with actual prompts, agent interactions, and deliverables.

## Overview

This example demonstrates how the sequential 5-phase pattern works in practice:

1. **Phase 1 - Research**: Understand the current system
2. **Phase 2 - Planning**: Design the new solution
3. **Phase 3 - Implementation**: Write the code
4. **Phase 4 - Review**: Validate the implementation
5. **Phase 5 - Verification**: Confirm deployment readiness

Each phase uses specialized agents with optimal model selection based on task complexity.

---

## Scenario Context

### Business Requirement
Your company's authentication system needs to scale from supporting 5,000 to 500,000 concurrent users. The current session-based system can't handle this load.

### Constraints
- **Zero downtime**: Migration must not impact active users
- **Timeline**: 4 weeks
- **Team**: 3 developers + 1 DevOps
- **Tech Stack**: Node.js/Express, PostgreSQL, Redis

### Success Criteria
1. New system handles 500k concurrent users
2. Authentication latency < 100ms
3. 99.99% uptime SLA
4. Full backward compatibility during migration
5. Comprehensive security audit passed

---

## Phase 1: Research & Discovery

### Overview
The orchestrator delegates to the **Research Agent** (oh-my-claude-sisyphus:explore) running Haiku to quickly gather information.

### Configuration
```yaml
agent: research
model: haiku
timeout: 10 minutes
max_quality_gate: 0.80
cost_limit: $0.05
```

### Phase 1 Prompt

```
RESEARCH PHASE: Authentication System Upgrade
==============================================

Task: Explore the authentication system and understand current implementation

OBJECTIVE:
Gather comprehensive information about:
1. Current authentication architecture
2. Existing auth patterns in use
3. Performance bottlenecks
4. Security considerations
5. Integration points that depend on auth

PROJECT CONTEXT:
- Current system: Session-based authentication
- Users: ~5,000 concurrent
- Target: 500,000 concurrent users
- Tech: Node.js/Express, PostgreSQL, Redis

SEARCH LOCATIONS:
- src/auth/                 (authentication logic)
- src/middleware/           (request middleware)
- src/models/               (user/session models)
- config/                   (configuration files)
- database/migrations/      (schema changes)

REQUIRED DELIVERABLES:
1. File Structure Map
   - List all auth-related files
   - Describe each file's purpose
   - Identify code owners if visible

2. Architecture Diagram (text-based)
   - How user login flow works
   - Where sessions are stored
   - How tokens are managed
   - Integration points with other services

3. Current Implementation Analysis
   - Session management: [findings]
   - Token handling: [findings]
   - Password storage: [findings]
   - Session expiry: [findings]

4. Performance Characteristics
   - Database queries per login: [findings]
   - Cache hit rate: [findings]
   - Known bottlenecks: [findings]

5. Dependencies & Integration Points
   - Services that depend on auth: [list]
   - Third-party integrations: [list]
   - Legacy systems that might break: [list]

6. Patterns & Standards Currently Used
   - Request/response format: [pattern]
   - Error handling approach: [pattern]
   - Logging standards: [pattern]

7. Security Observations
   - How passwords are hashed: [finding]
   - HTTPS enforcement: [finding]
   - CSRF protection: [finding]
   - Rate limiting: [finding]

SEARCH KEYWORDS:
- authenticate, authorization, permission
- token, jwt, session, cookie
- passport, express, middleware
- user, profile, account
- login, logout, signin
- credential, password, hash

OUTPUT FORMAT:
Create a structured report with:
- Clear sections matching the deliverables above
- File paths and line numbers where relevant
- Code snippets for key implementations
- Diagrams using ASCII art or Mermaid
- Risk/opportunity notes
```

### Phase 1 Expected Output

```markdown
# Research Phase Report: Authentication System

## 1. File Structure Map

```
src/
├── auth/
│   ├── session-handler.js    (Session management, 450 lines)
│   ├── passport-config.js    (Passport.js setup, 80 lines)
│   └── utils.js              (Helper functions, 120 lines)
├── middleware/
│   ├── auth-middleware.js    (Request auth check, 60 lines)
│   └── error-handler.js      (Error handling, 110 lines)
├── models/
│   ├── User.js               (User schema, 85 lines)
│   ├── Session.js            (Session schema, 75 lines)
│   └── Permission.js         (Permission schema, 50 lines)
└── routes/
    ├── auth-routes.js        (Auth endpoints, 120 lines)
    └── user-routes.js        (User endpoints, 200 lines)
```

## 2. Architecture Diagram

```
User Login Flow (Current Session-Based):

┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       │ POST /login (username, password)
       │
       ▼
┌──────────────────────────────────────┐
│    Express Server                    │
│  - Receive credentials               │
│  - Query User from PostgreSQL        │
│  - Compare password hash (bcrypt)    │
└──────┬───────────────────────────────┘
       │
       │ If valid:
       │ 1. Create Session record
       │ 2. Generate session_id
       │ 3. Store in Redis (10 min TTL)
       │
       ▼
┌──────────────────────────────────────┐
│    Data Layer                        │
│  - PostgreSQL (User table)           │
│  - Redis (Session cache)             │
│  - 100 queries/login on scale        │
└──────────────────────────────────────┘
       │
       │ Return session_id in cookie
       │
       ▼
┌─────────────┐
│   Client    │
│ (Store      │
│  session_id)│
└─────────────┘

Subsequent Requests:
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       │ Include session_id in cookie
       │
       ▼
┌──────────────────────────────────────┐
│  auth-middleware.js                  │
│  - Extract session_id from cookie    │
│  - Query Redis (or PostgreSQL)       │
│  - Load user context                 │
│  - ~50ms latency per request         │
└──────┬───────────────────────────────┘
       │
       ▼
│  Route Handler (if authenticated)    │
```

## 3. Current Implementation Analysis

### Session Management
- Framework: Express-session + Redis
- Session ID: UUID v4
- TTL: 10 minutes (renewable)
- Storage: Redis (primary), PostgreSQL (fallback)
- Issue: Redis not distributed → sticky sessions needed

### Token Handling
- Type: Session ID tokens (not JWT)
- Transport: Cookies (httpOnly, secure)
- Validation: Query to Redis + PostgreSQL
- Issue: ~50ms latency per request due to lookups

### Password Storage
- Algorithm: bcrypt with salt rounds: 10
- Secure: Yes ✓
- No plaintext passwords: ✓
- Database: PostgreSQL users table

### Session Expiry
- Idle timeout: 10 minutes
- Absolute timeout: 8 hours
- Renewal: Automatic on user activity

## 4. Performance Characteristics

### Database Impact
- Queries per login: 2-3 (user lookup + insert session)
- Queries per request: 1 (session validation)
- With 5k users × 10 req/min = 50k queries/min
- At scale (500k users): 5M queries/min = UNSUSTAINABLE

### Cache Performance
- Redis hit rate: ~95% (good)
- Cache miss → PostgreSQL fallback (~50ms)
- Network latency: 5-10ms per round trip

### Known Bottlenecks
1. Session lookup on every request (DB hit)
2. Redis sticky sessions (horizontal scaling hard)
3. Session replication overhead (Redis sync)
4. Database connection pool exhaustion under load

## 5. Dependencies & Integration Points

Services that depend on auth:
- User profile service (requires auth context)
- API gateway (validates sessions)
- Admin dashboard (requires elevated permissions)
- Third-party OAuth integrations (none currently)

Legacy systems:
- Old mobile app expects cookies (must maintain)
- Custom CRM integration uses basic auth (deprecated but active)

## 6. Patterns & Standards

Current patterns:
- Error responses: JSON with error code + message
- Success format: `{ data: {...}, meta: {...} }`
- Logging: Winston logger with contextual data
- Config: Environment variables + .env file

## 7. Security Observations

✓ Passwords: bcrypt with 10 rounds (industry standard)
✓ HTTPS: Enforced globally via middleware
✓ CSRF: Using csrf-protect middleware
? Rate limiting: No global rate limiter (future work)
✗ Session hijacking: Possible with stolen cookie
⚠ Database secrets: Stored in environment (should use vault)
```

### Phase 1 Quality Gates Validation
- [✓] Found all authentication files (9 files identified)
- [✓] Identified patterns (session-based + Redis)
- [✓] Mapped dependencies (5+ services identified)
- [✓] Documented bottlenecks (4 key issues)
- [✓] Cost: $0.04 (under $0.05 limit)

### Phase 1 Conclusion
✅ Research complete - Ready for Phase 2 (Planning)

---

## Phase 2: Planning & Design

### Overview
The orchestrator delegates to the **Planning Agent** (oh-my-claude-sisyphus:prometheus) running Opus for strategic design decisions.

### Configuration
```yaml
agent: planning
model: opus
timeout: 20 minutes
quality_threshold: 0.95
cost_limit: $0.30
dependencies: phase1_research
```

### Phase 2 Prompt

```
PLANNING PHASE: Authentication System Upgrade Design
====================================================

BUSINESS REQUIREMENTS:
- Scale from 5k to 500k concurrent users
- Zero downtime migration
- 4-week timeline
- < 100ms auth latency
- 99.99% uptime SLA

RESEARCH FINDINGS (from Phase 1):
- Current: Session-based authentication with Redis
- Bottleneck: 50ms query per request
- At scale: 5M DB queries/minute (impossible)
- Tech stack: Node.js/Express, PostgreSQL, Redis
- Dependency: 5+ services rely on auth
- Legacy mobile apps: Expect cookies

TASK: Design a complete authentication system upgrade

DESIGN REQUIREMENTS:
Your plan must address:

1. NEW ARCHITECTURE
   - What auth pattern? (JWT, OAuth2, etc.)
   - How will it handle 500k concurrent?
   - Database schema changes?
   - Cache strategy?
   - Session management approach?

2. MIGRATION STRATEGY
   - How to migrate without downtime?
   - Phased approach? (what phases?)
   - Backward compatibility approach?
   - Rollback procedure?
   - Risk mitigation?

3. TECHNICAL IMPLEMENTATION
   - New token generation service?
   - Changes to middleware?
   - Database migrations?
   - New configuration?
   - Third-party libraries?

4. SECURITY DESIGN
   - Token signing & verification?
   - Refresh token mechanism?
   - Token revocation approach?
   - Rate limiting?
   - Secret management?

5. PERFORMANCE REQUIREMENTS
   - Target auth latency: < 100ms
   - How to achieve this?
   - Caching strategy?
   - Database optimization?
   - Load testing approach?

6. INTEGRATION PLAN
   - How to handle existing dependencies?
   - API compatibility?
   - Legacy mobile app support?
   - CRM integration changes?

7. VERIFICATION PLAN
   - How to test new system?
   - Load testing approach?
   - Security testing?
   - Integration testing?
   - Acceptance criteria?

8. ROLLOUT PLAN
   - Deployment strategy (canary? blue-green?)
   - Monitoring during rollout?
   - Rollback triggers?
   - Communication plan?

CONSTRAINTS:
- Must not break existing mobile apps
- Team: 3 developers, 1 DevOps
- Timeline: 4 weeks (strict)
- Budget: Not specified, assume limited
- Must maintain CRM integration

DELIVERABLES:

Your response must include:

1. Executive Summary
   - Problem statement
   - Proposed solution overview
   - Expected benefits
   - Risks and mitigations

2. Architecture Design
   - System architecture diagram
   - Component responsibilities
   - Data flow diagrams
   - Performance characteristics

3. Implementation Plan
   - Phased approach (Phase 1, 2, 3, etc.)
   - Estimated effort per phase
   - Dependencies between phases
   - Critical path analysis

4. Migration Strategy
   - Dual-write approach details
   - Data migration plan
   - Backward compatibility layer
   - Old system decommission plan

5. Database Design
   - New schema (if needed)
   - Migration scripts
   - Rollback procedures
   - Performance indexes

6. Security Design
   - Token generation algorithm
   - Token validation process
   - Key rotation strategy
   - Secret management approach

7. Integration Plans
   - Client library changes
   - API endpoint mapping
   - Third-party service integration
   - Legacy system compatibility

8. Verification & Testing
   - Test strategy (unit/integration/e2e)
   - Load testing plan (500k users)
   - Security testing scope
   - Success criteria

9. Risk Assessment
   - Top 5 risks
   - Mitigation strategies
   - Contingency plans
   - Success metrics

10. Resource Requirements
    - Developer time estimate
    - Tools/infrastructure needed
    - Training requirements
    - Documentation needed

ACCEPTANCE CRITERIA:
- Plan is detailed enough for implementation without clarification
- Achievable within 4-week timeline
- Addresses all requirements
- Clear risk mitigation
- Realistic resource estimates
- Handles backward compatibility
```

### Phase 2 Expected Output

```markdown
# Authentication System Upgrade: Comprehensive Design Plan

## 1. Executive Summary

### Problem Statement
Current session-based authentication system cannot scale beyond 5k concurrent users.
Root cause: Database query required per-request (50ms latency, scales poorly).

### Proposed Solution
Migrate to JWT-based stateless authentication with efficient local validation.
Eliminates per-request database queries, enabling 500k+ concurrent user support.

### Expected Benefits
- 50x scalability improvement (5k → 500k users)
- 45ms latency reduction (50ms → 5ms)
- Reduced database load (99% fewer queries)
- Horizontal scaling without sticky sessions

### Key Risks & Mitigations
1. **Risk**: Token hijacking (lost cookie)
   **Mitigation**: Short-lived tokens (15min), refresh token rotation

2. **Risk**: Migration breaks legacy mobile app
   **Mitigation**: Dual-auth system (JWT + session) for 2 weeks

3. **Risk**: Keys are compromised
   **Mitigation**: Key rotation policy, secret vault (HashiCorp Vault)

## 2. Architecture Design

### New System Architecture

```
User Login Flow (JWT-Based):

┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       │ POST /login (credentials)
       │
       ▼
┌──────────────────────────────────────┐
│    Express Server                    │
│  - Validate credentials              │
│  - Query User from PostgreSQL (1x)   │
│  - Generate JWT token                │
│  - Return token + refresh token      │
└──────────────────────────────────────┘
       │
       │ Return:
       │ {
       │   access_token: "eyJhbc...",
       │   refresh_token: "xyz123...",
       │   expires_in: 900 (15 min)
       │ }
       │
       ▼
┌─────────────┐
│   Client    │
│ (Store      │
│  tokens)    │
└─────────────┘

Subsequent Requests:
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       │ Include JWT in Authorization header
       │ Authorization: Bearer eyJhbc...
       │
       ▼
┌──────────────────────────────────────┐
│  auth-middleware.js                  │
│  - Extract JWT from header           │
│  - Verify signature locally (2ms)    │
│  - No database query!                │
│  - Extract user context from token   │
│  - 5ms total latency (10x faster)    │
└──────┬───────────────────────────────┘
       │
       ▼
│  Route Handler (if valid)            │

Token Expiry Flow:
┌─────────────────┐
│ Token expires   │
│ (after 15 min)  │
└────────┬────────┘
         │
         │ Client has refresh_token
         │
         ▼
┌──────────────────────────────────────┐
│  POST /auth/refresh                  │
│  - Send refresh token                │
│  - Verify signature (local)          │
│  - Issue new access_token            │
│  - Rotate refresh_token              │
└──────────────────────────────────────┘
         │
         ▼
│  Continue with new access_token     │
```

### Component Breakdown

**Token Generation Service**
- Location: `src/auth/jwt-service.js`
- Responsibility: Generate JWT + refresh tokens
- Inputs: User ID, permissions, metadata
- Output: Tokens with signature

**Token Validation Middleware**
- Location: `src/middleware/auth-middleware.js`
- Responsibility: Validate JWT locally
- Inputs: Authorization header
- Output: User context or 401 Unauthorized

**Refresh Token Handler**
- Location: `src/auth/refresh-handler.js`
- Responsibility: Issue new tokens
- Inputs: Valid refresh token
- Output: New access + refresh tokens

**Key Management Service**
- Location: `src/auth/key-management.js`
- Responsibility: Handle signing keys
- Inputs: Request for key version
- Output: Public/private keys for signing

### Data Flow Diagram

```
┌──────────────────┐
│  User Credentials│
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────┐     ┌─────────────────────┐
│ Password Validation          │────▶│ PostgreSQL          │
│ (bcrypt compare)             │     │ User table          │
└────────┬─────────────────────┘     └─────────────────────┘
         │
         │ Valid ✓
         │
         ▼
┌──────────────────────────────┐     ┌─────────────────────┐
│ Token Generation             │────▶│ src/auth/jwt-service│
│ - Payload: user_id, perms    │     └─────────────────────┘
│ - Sign with private key      │
│ - Set expiry: 15 minutes     │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐     ┌─────────────────────┐
│ Refresh Token Generation     │────▶│ Redis (30 days TTL) │
│ - Generate random token      │     │ refresh_tokens hash │
│ - Store in Redis             │     └─────────────────────┘
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│ Return to Client             │
│ {                            │
│   access_token: "...",       │
│   refresh_token: "...",      │
│   expires_in: 900            │
│ }                            │
└──────────────────────────────┘

Subsequent Request Processing:
┌─────────────────────────────┐
│ GET /api/user/profile       │
│ Authorization: Bearer token │
└────────┬────────────────────┘
         │
         ▼
┌──────────────────────────────┐     ┌─────────────────────┐
│ Extract JWT from header      │────▶│ Authorization header│
│ Split "Bearer <token>"       │     └─────────────────────┘
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐     ┌─────────────────────┐
│ Verify Signature Locally     │────▶│ Public key from     │
│ (no DB query!)               │     │ src/auth/key-mgmt   │
│ Latency: ~2ms                │     └─────────────────────┘
└────────┬─────────────────────┘
         │
         │ Valid Signature ✓
         │
         ▼
┌──────────────────────────────┐
│ Extract Claims from Token    │
│ - user_id, permissions, etc. │
│ - No database query needed   │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│ Attach User to req object    │
│ Continue to Route Handler    │
└──────────────────────────────┘
```

## 3. Implementation Plan

### Phase 1 (Week 1): Foundation
- Create JWT service with token generation
- Implement token validation middleware
- Add refresh token mechanism
- Write comprehensive tests
- Effort: 2 developers, 5 days

### Phase 2 (Week 2): Integration
- Update all routes to use new auth
- Implement dual-auth (JWT + session) for compatibility
- Add token rotation logic
- Database: Create refresh_tokens table
- Effort: 3 developers, 4 days

### Phase 3 (Week 3): Migration & Testing
- Migrate 20% of users to JWT (canary)
- Load test with 100k concurrent users
- Security audit of new system
- Performance optimization
- Effort: 3 developers + 1 DevOps, 5 days

### Phase 4 (Week 4): Rollout
- Migrate remaining 80% of users
- Monitor for issues
- Optimize based on metrics
- Decommission session-based auth
- Effort: 3 developers + 1 DevOps, 3 days

### Critical Path
```
Week 1: JWT Service (blocks everything else)
Week 2: Integration & Testing (can be parallel with Week 1 learning)
Week 3: Canary Deployment (security review must pass first)
Week 4: Full Rollout & Cleanup
```

## 4. Migration Strategy

### Dual-Auth Approach (2 weeks)

```
Timeline:
Day 1-3: Deploy JWT system alongside existing session auth
Day 4-10: New clients use JWT, old clients use sessions
Day 11-14: Migrate all clients to JWT
Day 15: Decommission session auth

Benefits:
- Zero downtime
- Legacy mobile apps continue working
- Easy rollback if issues found
```

### Backward Compatibility Layer

```javascript
// In auth-middleware.js - support both JWT and session tokens

function authenticateRequest(req, res, next) {
  let user;

  // Try JWT first (preferred)
  if (req.headers.authorization) {
    user = validateJWT(req.headers.authorization);
    if (user) return next(); // Success with JWT
  }

  // Fallback to session (legacy)
  if (req.session.user_id) {
    user = validateSession(req.session);
    if (user) return next(); // Success with session
  }

  // No auth found
  return res.status(401).json({ error: "Unauthorized" });
}
```

## 5. Database Design

### New Tables/Columns

```sql
-- New table: refresh_tokens
CREATE TABLE refresh_tokens (
  id UUID PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id),
  token_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP NOT NULL,
  revoked_at TIMESTAMP,
  rotated_from UUID REFERENCES refresh_tokens(id)
);

-- Index for lookups
CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_expires ON refresh_tokens(expires_at);

-- Add audit column to users table (optional)
ALTER TABLE users ADD COLUMN last_token_issue_at TIMESTAMP;
```

### Migration Script

```sql
-- Migration: 2026-01-25-001-add-refresh-tokens-table.sql

BEGIN;

-- Create refresh_tokens table
CREATE TABLE refresh_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMP NOT NULL,
  revoked_at TIMESTAMP,
  rotated_from UUID REFERENCES refresh_tokens(id),
  created_by VARCHAR(100), -- Service/IP that created token
  CONSTRAINT valid_expiry CHECK (expires_at > created_at)
);

-- Add indexes for common queries
CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);
CREATE INDEX idx_refresh_tokens_not_revoked ON refresh_tokens(user_id) WHERE revoked_at IS NULL;

-- Rollback script (keep in comments):
-- DROP TABLE IF EXISTS refresh_tokens CASCADE;
-- (No changes to users table needed, migrations are additive)

COMMIT;
```

### Rollback Procedure

```bash
# If issues found after deployment:
1. Set JWT acceptance to read-only (no new JWT issues)
2. Revert clients back to session auth
3. Give 30 days for refresh tokens to expire naturally
4. Run rollback migration (drop refresh_tokens table)
5. Monitor for 24 hours
```

## 6. Security Design

### Token Generation Algorithm

```
Access Token (JWT):
┌─────────────────────────────────────┐
│ Header                              │
├─────────────────────────────────────┤
│ {                                   │
│   "alg": "RS256",                   │
│   "typ": "JWT",                     │
│   "kid": "2026-01-v1"              │ ← Key version ID
│ }                                   │
├─────────────────────────────────────┤
│ Payload                             │
├─────────────────────────────────────┤
│ {                                   │
│   "user_id": 12345,                 │
│   "email": "user@company.com",      │
│   "permissions": ["read", "write"], │
│   "iat": 1674664400,                │ ← Issued at
│   "exp": 1674665300,                │ ← Expiry (15 min)
│   "iss": "auth.company.com",        │ ← Issuer
│   "sub": "12345"                    │ ← Subject (user_id)
│ }                                   │
├─────────────────────────────────────┤
│ Signature (RS256)                   │
├─────────────────────────────────────┤
│ HMACSHA256(                         │
│   base64(header) + "." +            │
│   base64(payload),                  │
│   private_key                       │
│ )                                   │
└─────────────────────────────────────┘

Refresh Token:
- Type: Random string (no structure)
- Length: 64 bytes (256 bits)
- Storage: Redis + PostgreSQL
- TTL: 30 days
- Rotation: On each use (old token invalid after refresh)
```

### Token Validation Process

```javascript
function validateJWT(token) {
  try {
    // 1. Extract header to get key version
    const header = decodeHeader(token);
    const keyId = header.kid; // "2026-01-v1"

    // 2. Get public key for this version (from cache)
    const publicKey = getPublicKey(keyId);

    // 3. Verify signature
    const claims = jwt.verify(token, publicKey, {
      algorithms: ['RS256'],
      issuer: 'auth.company.com',
      maxAge: '15m'
    });

    // 4. Validate claims
    if (!claims.user_id || !claims.permissions) {
      throw new Error('Invalid claims');
    }

    // 5. Check if user is still active (optional DB check)
    // For high-performance, skip this for most requests
    // Only check on sensitive operations

    return claims;
  } catch (error) {
    throw new UnauthorizedError('Invalid token: ' + error.message);
  }
}
```

### Key Rotation Strategy

```
Rotation Schedule:
- Every 90 days (planned rotation)
- Immediately if compromised (emergency rotation)

Process:
1. Generate new key pair
2. Store both old and new keys with version IDs
3. New tokens signed with new key
4. Old tokens still valid (for 15 min expiry anyway)
5. After 24 hours, old key can be retired
6. Keep old key for 30 days in case of issues

Implementation:
- Keys stored in HashiCorp Vault (not in code)
- Rotated via automated script
- Service pulls keys on startup + every 24 hours
```

### Secret Management

```
Approach: External Secret Vault (HashiCorp Vault)

┌─────────────────┐
│  HashiCorp Vault│
│  (Enterprise)   │
└────────┬────────┘
         │
         │ Manages:
         ├─ JWT signing keys (rotated)
         ├─ Database credentials
         ├─ Encryption keys
         └─ API secrets
         │
         ▼
┌─────────────────┐
│  Service        │
│  - Authenticate │
│  - Request keys │
│  - Cache locally│
│  - Auto-refresh │
└─────────────────┘

Benefits:
- Keys never in code
- Automatic rotation
- Audit trail of all access
- Compliance (SOC2, etc.)
```

## 7. Integration Plans

### Client Library Updates

```javascript
// Old code (session-based):
fetch('/api/user/profile', {
  credentials: 'include' // Send cookies
});

// New code (JWT):
const token = localStorage.getItem('access_token');
fetch('/api/user/profile', {
  headers: {
    'Authorization': `Bearer ${token}`
  }
});

// Utility function for easier use:
async function apiCall(endpoint, options = {}) {
  const token = localStorage.getItem('access_token');
  if (!token && !endpoint.includes('login')) {
    // Try to refresh
    await refreshToken();
  }

  return fetch(`/api${endpoint}`, {
    ...options,
    headers: {
      ...options.headers,
      'Authorization': `Bearer ${localStorage.getItem('access_token')}`
    }
  });
}
```

### API Endpoint Mapping

```
Old (Session-Based):
POST   /login           → 200 with session cookie
GET    /logout          → 200 (clear session)
GET    /api/...         → 401 if no session

New (JWT):
POST   /auth/login      → 200 with access + refresh tokens
POST   /auth/refresh    → 200 with new access token
POST   /auth/logout     → 200 (revoke tokens)
GET    /api/...         → 401 if no JWT

Both work during migration (dual auth):
POST   /login           → 200 with session OR JWT (based on client)
POST   /auth/login      → 200 with JWT (preferred)
GET    /logout          → 200 (legacy)
POST   /auth/logout     → 200 (new)
```

### Legacy System Compatibility

```
CRM Integration (uses basic auth):
- Not changing during Phase 1-3
- Phase 4: Migrate to API key auth
- Timeline: Extended by 2 weeks if needed

Mobile App (expects cookies):
- Week 1-2: Continues with session cookies
- Week 2-3: Upgraded to JWT auth
- Week 4: Session auth disabled
- Risk: Old app versions will break
  Mitigation: Deep link to update app store
```

## 8. Verification & Testing

### Test Strategy

```
Unit Tests (Token Generation):
- JWT generation with valid payload
- JWT generation with invalid payload
- Token signature verification
- Refresh token generation
- Invalid token rejection
- Expired token rejection
- Coverage target: 95%

Integration Tests (Auth Flow):
- Login → token generation → request validation
- Token refresh → new token issuance
- Invalid credentials → 401
- Expired token + valid refresh → new access token
- Revoked token → 401

Load Tests (500k concurrent):
- Generate 100k tokens/second
- Validate 500k tokens/second
- Latency < 5ms (p99)
- No memory leaks over 24 hours
- Database load acceptable

Security Tests:
- JWT tampering → rejected
- Invalid signature → rejected
- Token revocation → respected
- Key rotation → transparent
- No token in logs → verified
```

### Load Testing Plan

```
Tool: Apache JMeter / k6

Test Scenario 1: Login Surge
- 50,000 users login simultaneously
- Measure: Token generation latency, DB load
- Target: < 100ms p99

Test Scenario 2: Steady State
- 500,000 concurrent users
- Each user makes 1 API request every 30 seconds
- Measure: Token validation latency, throughput
- Target: < 5ms p99, 100k req/sec

Test Scenario 3: Token Refresh Surge
- 100,000 tokens expire simultaneously
- Measure: Refresh latency, database impact
- Target: < 50ms p99

Success Criteria:
- All latency targets met
- No 5xx errors
- Database CPU < 70%
```

### Success Criteria

```
Functional:
✓ All existing endpoints work with JWT
✓ Backward compatible with legacy clients
✓ Token refresh mechanism works
✓ Token revocation works

Performance:
✓ Auth latency < 5ms (down from 50ms)
✓ Supports 500k concurrent users
✓ Database load reduced 99%

Security:
✓ No tokens in logs
✓ Keys properly managed
✓ Token tampering detected
✓ Security audit passed

Compatibility:
✓ Legacy mobile app still works
✓ CRM integration still works
✓ Zero authentication downtime

Timeline:
✓ Delivered within 4 weeks
✓ Minimal team overload
```

## 9. Risk Assessment

### Risk 1: Token Hijacking
**Probability**: Medium | **Impact**: High
- **Mitigation**: Short-lived tokens (15 min), refresh token rotation
- **Contingency**: Token revocation system, real-time monitoring
- **Monitoring**: Alert on multiple refresh attempts from different IPs

### Risk 2: Migration Breaks Legacy Mobile App
**Probability**: Medium | **Impact**: Medium
- **Mitigation**: Dual auth for 2 weeks, thorough testing
- **Contingency**: Quick rollback to session-based auth
- **Testing**: Test with actual legacy app version

### Risk 3: Keys Compromised
**Probability**: Low | **Impact**: Critical
- **Mitigation**: Keys in vault, not in code, frequent rotation
- **Contingency**: Immediate key rotation, force token re-issuance
- **Monitoring**: Audit trail of all key access

### Risk 4: Performance Targets Not Met
**Probability**: Low | **Impact**: High
- **Mitigation**: Early load testing, optimization phase built in
- **Contingency**: Caching layer, query optimization
- **Monitoring**: Real-time latency tracking

### Risk 5: Database Schema Migration Issues
**Probability**: Low | **Impact**: Medium
- **Mitigation**: Careful migration planning, rollback script tested
- **Contingency**: Quick rollback to previous schema
- **Testing**: Test migrations in staging first

## 10. Resource Requirements

### Team Allocation
- **3 Developers**:
  - Dev 1: JWT service + key management (full time)
  - Dev 2: Integration + middleware (full time)
  - Dev 3: Testing + migrations (full time)

- **1 DevOps**:
  - Infrastructure for new service (part time Week 1-2)
  - Load testing & monitoring (full time Week 3-4)

### Tools & Infrastructure
- HashiCorp Vault (for key management)
- k6 or JMeter (load testing)
- New PostgreSQL table (minimal storage)
- Redis (already have for refresh tokens cache)

### Training
- All team members: 4 hours JWT/security training
- DevOps: 2 hours vault setup
- QA: 2 hours testing new auth flow

### Documentation
- Design doc (this document)
- API migration guide (4 hours to write)
- Runbook for emergency key rotation (2 hours)
- Monitoring/alerting setup (4 hours)
```

### Phase 2 Quality Gates Validation
- [✓] Plan is detailed and implementation-ready
- [✓] Addresses all business requirements
- [✓] Achievable within 4-week timeline
- [✓] Clear risk mitigation for all identified risks
- [✓] Realistic resource estimates
- [✓] Quality Score: 0.96 (exceeds 0.95 threshold)

### Phase 2 Conclusion
✅ Plan approved - Ready for Phase 3 (Implementation)

---

## Phase 3: Implementation & Development

### Overview
The orchestrator delegates to the **Implementation Agent** (oh-my-claude-sisyphus:sisyphus-junior) running Sonnet for coding.

### Configuration
```yaml
agent: implementation
model: sonnet
timeout: 45 minutes
quality_threshold: 0.88
cost_limit: $0.20
dependencies: phase2_planning
```

### Phase 3 Key Files Created
Based on the plan, these files would be created:

**src/auth/jwt-service.js** (150 lines)
- Token generation logic
- Payload construction
- Signature creation
- Validation logic

**src/middleware/auth-middleware.js** (80 lines)
- Extract JWT from request
- Validate signature
- Attach user to request
- Handle errors

**src/auth/refresh-handler.js** (120 lines)
- Validate refresh tokens
- Generate new access tokens
- Rotate refresh tokens
- Revocation handling

**src/auth/key-management.js** (90 lines)
- Load keys from vault
- Cache public keys
- Auto-refresh on rotation
- Handle key versions

### Phase 3 Expected Metrics
- Files created: 8
- Lines of code: ~600
- Test coverage: 93%
- Implementation time: 30-35 hours
- Cost: ~$0.18

---

## Phase 4: Review & Validation

### Overview
The orchestrator delegates to the **Review Agent** (oh-my-claude-sisyphus:momus) running Opus for critical review.

### Configuration
```yaml
agent: review
model: opus
timeout: 30 minutes
quality_threshold: 0.92
cost_limit: $0.25
dependencies: phase3_implementation
```

### Phase 4 Key Deliverables
- Code review report with findings
- Security audit results
- Architecture validation
- Test coverage analysis
- Recommendations for improvement
- Go/no-go decision for next phase

### Phase 4 Expected Outcome
- Issues found: 3 (1 critical, 2 minor)
- All critical issues resolved before proceeding
- Quality Score: 0.93 (exceeds 0.92 threshold)

---

## Phase 5: Verification & Final Validation

### Overview
The orchestrator delegates to the **Verification Agent** (oh-my-claude-sisyphus:qa-tester) running Sonnet for thorough testing.

### Configuration
```yaml
agent: verification
model: sonnet
timeout: 25 minutes
quality_threshold: 0.90
cost_limit: $0.18
dependencies: phase4_review
```

### Phase 5 Test Execution
- Unit tests: 95 tests, all pass ✓
- Integration tests: 42 tests, all pass ✓
- Load test (500k concurrent): Pass ✓
- Security audit: Pass with 0 critical issues ✓
- Performance targets met: Yes ✓

### Phase 5 Final Approval
```
Deployment Readiness Checklist:
✓ All tests pass
✓ No security issues
✓ Performance targets met
✓ Documentation complete
✓ Rollback procedure tested
✓ Team trained

STATUS: READY FOR PRODUCTION ✓
```

---

## Workflow Summary

### Cost Breakdown
```
Phase 1 (Research):      $0.04  (Haiku model)
Phase 2 (Planning):      $0.28  (Opus model)
Phase 3 (Implementation):$0.18  (Sonnet model)
Phase 4 (Review):        $0.24  (Opus model)
Phase 5 (Verification):  $0.16  (Sonnet model)
                         ─────
Total Workflow Cost:     $0.90

(Compared to using Opus for all phases: $4.50 - 80% savings!)
```

### Timeline
- Phase 1: 10 minutes (Research)
- Phase 2: 20 minutes (Planning)
- Phase 3: 35 hours (Implementation, parallel team work)
- Phase 4: 30 minutes (Review)
- Phase 5: 25 minutes (Verification)
- **Total elapsed time: 36-40 hours (1 week with 4-person team)**

### Quality Metrics
```
Phase Completions:
1. Research:       ✓ Quality: 0.80
2. Planning:       ✓ Quality: 0.96
3. Implementation: ✓ Quality: 0.90
4. Review:         ✓ Quality: 0.93
5. Verification:   ✓ Quality: 0.95

Overall Success Rate: 100% ✓
```

---

## Key Takeaways

### Why This 5-Phase Pattern Works

1. **Research First**: Understand before designing
   - Avoids designing for wrong problem
   - Discovers existing solutions
   - Identifies integration points

2. **Detailed Planning**: Design before coding
   - Saves time during implementation
   - Identifies risks early
   - Aligns team on approach

3. **Focused Implementation**: Code to plan
   - Clear requirements reduce rework
   - Team knows exactly what to build
   - Quality gates prevent bad code

4. **Critical Review**: Validate before deployment
   - Catches issues before production
   - Ensures quality standards
   - Identifies improvements

5. **Final Verification**: Test before shipping
   - Confirms functionality
   - Validates performance
   - Proves deployment readiness

### Model Selection Impact

Using intelligent model selection saved 80% of costs:
- Research (Haiku): $0.04 instead of $0.15
- Implementation (Sonnet): $0.18 instead of $0.30
- Review (Opus): $0.24 (necessary for quality)

**Key principle**: Match model tier to task complexity, not just use the most powerful model for everything.

---

## How to Use This Example

1. **Study the structure**: Understand each phase's purpose
2. **Adapt the prompts**: Customize for your specific use case
3. **Use the YAML config**: Copy `orchestrator.yaml` as starting template
4. **Run with orchestrator**: Delegate to subagents with appropriate models
5. **Monitor outcomes**: Track costs and quality metrics
6. **Iterate**: Refine prompts based on results

---

## Next Steps

To implement this in your own project:

1. **Review** the orchestrator.yaml configuration
2. **Customize** the phase prompts for your domain
3. **Set** quality thresholds appropriate for your project
4. **Define** cost limits and budget constraints
5. **Train** your team on the 5-phase workflow
6. **Execute** first workflow with close monitoring
7. **Optimize** prompts and agent selection based on results
