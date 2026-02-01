# Project Brain

> One-line description of what this project does and its core purpose.

---

## Architecture

**Project Structure**
Describe the folder layout and layer organization. Include the main entry points and how components connect.

```
Example structure (replace with actual):
src/
├── controllers/     # Request handlers, entry points
├── services/        # Business logic layer
├── models/          # Data structures
├── utils/           # Shared utilities
└── config/          # Configuration
```

**Key Components**
List the main abstractions and what they do:
- Component 1: Description
- Component 2: Description
- Component 3: Description

**Data Flow**
Brief explanation of how data flows through the system (e.g., "Request → Controller → Service → Database → Response").

**Critical Dependencies**
Major external libraries or services this project depends on:
- Dependency 1 (version, reason for use)
- Dependency 2 (version, reason for use)

---

## Patterns

**Naming Conventions**
Document the patterns used for naming files, functions, classes, variables:
- Files: `camelCase.js` or `kebab-case.js`?
- Classes: `PascalCase` or other?
- Functions: `camelCase` or `snake_case`?
- Constants: `UPPER_CASE` or other?

**Error Handling**
How are errors typically handled in this project?
- Exception throwing pattern
- Try-catch usage
- Error logging approach
- HTTP status code conventions

**API/Function Naming**
Describe the naming pattern for endpoints or exported functions:
- Verb-noun pattern? (e.g., `getUserById`, `createPost`)
- Async handling? (callbacks, promises, async/await?)
- Return value conventions

**Code Organization Pattern**
How are related functions/classes typically organized?
- File-per-function?
- Feature-based folders?
- Layer-based folders?

**Testing Pattern**
What testing approach is used?
- Unit test location and naming (e.g., `__tests__/`, `.test.js`)
- Mocking strategy
- Test runner (Jest, Mocha, other)

---

## Legacy

**Technical Debt**
Known areas that need improvement or refactoring:
- [ ] Issue 1: Description and impact
- [ ] Issue 2: Description and impact
- [ ] Issue 3: Description and impact

**Deprecated Code**
Modules, functions, or patterns that are no longer preferred:
- `old_module.js`: Use `new_module.js` instead. Removal planned for v2.0.
- `legacyAPI()`: Replaced by `modernAPI()`. Deprecation warning added in v1.5.

**Known Workarounds**
Temporary solutions in place that need proper fixes:
- Location: Description of workaround and why it exists
- Location: Description of workaround and why it exists

**Performance Issues**
Known bottlenecks or areas under investigation:
- Component X: Can handle up to 1000 requests/sec, needs optimization for production
- Database query Y: Has N+1 problem in specific conditions

---

## History

| Date | Decision | Reason |
|------|----------|--------|
| 2025-01-15 | Chose Express.js over Fastify | Team familiarity and larger ecosystem; can revisit if performance becomes issue |
| 2025-01-10 | Moved to PostgreSQL from SQLite | Production deployment requires reliable ACID guarantees and concurrent user support |
| 2025-01-05 | Adopted monorepo structure | Multiple related services benefit from shared code and atomic commits |
| YYYY-MM-DD | Key decision about architecture | Why this decision was made and what alternatives were considered |
| YYYY-MM-DD | Important refactoring or pivot | Context for why the project direction changed |
| YYYY-MM-DD | Third-party integration choice | Why this tool/service was selected over alternatives |

**Key Context**
Add important historical context that helps understand current state:
- This project started as a prototype and evolved into production use. Some early architectural decisions are being revisited.
- The team migrated from X to Y because Z happened. Some legacy code still uses the old approach.

---

**Last Updated**: 2026-02-02

**Guidelines for Maintaining This Document**
- Keep it under 2000 tokens when filled
- Update when architectural decisions are made
- Review during onboarding of new team members
- Archive outdated history entries if the table grows too large
