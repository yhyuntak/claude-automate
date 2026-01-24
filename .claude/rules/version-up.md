---
paths: .claude-plugin/*.json
---

# Claude-Automate Version Bump Rules

> Project-specific rules for updating claude-automate versions

---

## Version Files (2 files - BOTH must be updated!)

### 1. `.claude-plugin/plugin.json`
```json
{
  "version": "0.3.0"  ← Update this
}
```

### 2. `.claude-plugin/marketplace.json`
```json
{
  "plugins": [{
    "version": "0.3.0"  ← Update this too!
  }]
}
```

---

## Semantic Versioning Strategy

| Change Type | Version | Example |
|-------------|---------|---------|
| Bug fixes, docs, typos | **PATCH** | 0.3.0 → 0.3.1 |
| New skill/command/agent | **MINOR** | 0.3.0 → 0.4.0 |
| Breaking changes, removals | **MAJOR** | 0.3.0 → 1.0.0 |

---

## Version Bump Checklist

Before every commit with version change:

- [ ] Identify change type (patch/minor/major)
- [ ] Update `.claude-plugin/plugin.json` version
- [ ] Update `.claude-plugin/marketplace.json` version
- [ ] Commit message: `feat: description (v0.X.0)`
- [ ] Push to main: `git push origin main`
- [ ] Create git tag: `git tag -a v0.X.0 -m "Release v0.X.0"`
- [ ] Push tag: `git push origin v0.X.0`

---

## Why Git Tags?

Claude Code plugin system uses **git tags** to identify versions, not just marketplace.json!

Without tag:
- ❌ Plugin shows wrong version
- ❌ Update doesn't work properly

With tag:
- ✅ Correct version displayed
- ✅ `/plugin update` works properly

---

## Current Version: 0.3.0

**Release Date:** 2026-01-24

**Features:**
- project-init skill with templates
- Global rules system (4 rules)
- Korean keyword support
- /install-rule command

---

## Version History

```
0.3.0 (2026-01-24): project-init skill, global rules
0.2.0 (2026-01-23): interaction-rules skill
0.1.9 (2026-01-23): explain-skills spec reference
0.1.8 (2026-01-22): start-work integrated workflow
0.1.7 (2026-01-22): backlog skill
0.1.6 (2026-01-22): Skills system, feedback improvements
```

---

## Common Mistakes

❌ **DON'T:**
- Update only one file (plugin.json OR marketplace.json)
- Forget to create git tag
- Push code without tag

✅ **DO:**
- Update BOTH version files
- Create and push git tag
- Verify version with `/plugin` after update

---

## Quick Commands

```bash
# Update both files (manual)
# Edit .claude-plugin/plugin.json → "version": "0.X.0"
# Edit .claude-plugin/marketplace.json → "version": "0.X.0"

# Commit
git add .claude-plugin/
git commit -m "chore: bump version to v0.X.0"
git push origin main

# Tag and push
git tag -a v0.X.0 -m "Release v0.X.0 - description"
git push origin v0.X.0

# Test
/plugin uninstall claude-automate
/plugin install claude-automate@claude-automate
/plugin  # Should show v0.X.0
```
