# Development Workflow

> Git branch strategy + tag-based releases + backlog management

---

## Git Branch Strategy

Choose one of two options when starting a project:

### Option A: Simple (main only)

**Recommended for**: Personal projects, small projects

```
feature/xxx ──> main ──> tag (v0.1.0)
```

**Work flow**:
```bash
# 1. Create work branch (optional)
git checkout -b feature/new-feature

# 2. Work + commit
git add .
git commit -m "feat: implement new feature"

# 3. Merge into main
git checkout main
git merge feature/new-feature
git push origin main

# 4. Clean up branch
git branch -d feature/new-feature
```

---

### Option B: Standard (develop/main/tags)

**Recommended for**: Team projects, requiring separate deployment environments

```
v0.1.0 (tag) ──> Production
    |
main (release ready)
    ^
develop (in development)
    ^
feature/xxx (work branch)
```

**Branch types**:
| Type | Purpose | Merge target | Example |
|------|---------|--------------|---------|
| `feature/*` | New feature | `develop` | `feature/user-auth` |
| `fix/*` | Bug fix | `develop` | `fix/login-error` |
| `hotfix/*` | Urgent fix | `main` + `develop` | `hotfix/security-patch` |

**Work flow**:
```bash
# 1. Create branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/new-feature

# 2. Work + commit
git add .
git commit -m "feat: implement new feature"

# 3. Merge into develop
git checkout develop
git merge feature/new-feature
git push origin develop

# 4. Clean up branch
git branch -d feature/new-feature
```

---

## Version Management (Semantic Versioning)

```
v{MAJOR}.{MINOR}.{PATCH}

MAJOR: Breaking changes (v1.0.0 -> v2.0.0)
MINOR: New features added (v0.1.0 -> v0.2.0)
PATCH: Bug fixes (v0.1.0 -> v0.1.1)
```

### Release Procedure

**Option A (Simple):**
```bash
# Create tag from main
git tag -a v0.1.0 -m "First release"
git push origin v0.1.0
```

**Option B (Standard):**
```bash
# 1. Merge develop into main
git checkout main
git pull origin main
git merge develop
git push origin main

# 2. Create tag
git tag -a v0.1.0 -m "First release"
git push origin v0.1.0

# 3. (Optional) Create GitHub Release
gh release create v0.1.0 --title "v0.1.0" --notes "Release notes..."
```

---

## Backlog Management

> Details: [backlog-rules.md](backlog-rules.md)

Backlogs are managed in the `docs/backlogs/` folder with a todo/doing/done structure.

### Integrated Workflow

**1. Select and start task**
```bash
# Select task from todo/ folder in README.md
mv docs/backlogs/todo/phase1-001-feature.md \
   docs/backlogs/doing/
```

**2. Implement + commit**
```bash
git add .
git commit -m "feat: implement phase1-001"
git push origin main  # or develop
```

**3. Complete task**
```bash
mv docs/backlogs/doing/phase1-001-feature.md \
   docs/backlogs/done/

# Update README.md (status, link path, counts)
```

---

## Commit Message Rules

```
<type>: <description>

# Types
feat:     new feature
fix:      bug fix
refactor: refactoring
docs:     documentation changes
chore:    other (dependencies, config, etc.)
style:    code style
test:     add/modify tests
```

---

**Last Updated**: {LAST_UPDATE_DATE}
