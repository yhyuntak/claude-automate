# Skill Writing Rules

> SKILL.md structure + 5 core rules

---

## File Structure

```
.claude/skills/{skill-name}/
├── SKILL.md              # Main body (Frontmatter + Body)
├── refs/                 # Reference files (lazy loaded)
└── scripts/              # Execution scripts (if needed)
```

---

## Frontmatter Structure

```yaml
---
name: skill-name
description: |
  (3rd person) Describe when this skill is triggered.
  On startup, only name + description is loaded (~100 tokens).
context: fork          # fork = protect main context | omit = run in main context
agent: general-purpose
allowed-tools:
  - Read
  - Write
  - Bash
---
```

### context Selection Criteria

| Value | Purpose | Example |
|-------|---------|---------|
| `fork` | Heavy tasks (data reading, analysis, report writing) | analysis skills, report skills |
| omit | Orchestrator, lightweight lookups | Task() delegation, status checks |

---

## 5 Core Rules

### 1. Progressive Disclosure

Respect the loading order:

```
On startup:    only name + description (~100 tokens)
On match:      full body loaded
On execution:  refs/ + scripts/ lazy loaded
```

In the body, reference refs/ with `MUST: read refs/xxx.md` → loaded only when needed.

---

### 2. Do not write "when to use" in the Body

That is the description's responsibility. Body = **"what and how" only**.

```markdown
# Bad example
This skill is used when the user requests a report.

# Good example
## Step 1: Data Collection
MUST: Read refs/data-sources.md to confirm the collection method for each source.
```

---

### 3. Keep Body under 500 lines

SKILL.md = table of contents. Move detailed content to refs/.

| Content | Location |
|---------|----------|
| Step overview (1-2 lines) | SKILL.md body |
| Decision rules, complex logic | `refs/` |
| Examples, schemas | `refs/` |
| Simple queries/commands | Inline in body |

---

### 4. Do not write what Claude already knows

Replace concept explanations with code examples + expected output.

```markdown
# Bad example
SQLite is a lightweight database. To run a query...

# Good example
```bash
sqlite3 data/northstar.db "SELECT * FROM events LIMIT 5;"
```
Expected output: id | date | type | summary
```

---

### 5. Embed a validation loop

MUST keyword + checklist + failure handling.

```markdown
## Validation

MUST: Verify all items in the checklist below.

- [ ] Does the output file exist?
- [ ] Are all required sections present?
- [ ] Is the data up to date?

On failure: return to the relevant Step, fix, and re-validate.
```

---

## Body Writing Patterns

### Complex Step (split to refs/)

```markdown
## Step 2: Analysis

Collect data by sector and detect anomalies.

MUST: Read refs/analysis-rules.md to confirm the detection criteria.
```

### Simple Step (inline)

```markdown
## Step 1: Check DB

```bash
sqlite3 data/northstar.db ".tables"
```
```

---

## Full Example Structure

```markdown
---
name: my-skill
description: |
  Triggered when the user requests X. Handles Y and Z.
context: fork
agent: general-purpose
allowed-tools:
  - Read
  - Bash
---

## Step 1: ...
(1-2 line summary)
MUST: Read refs/step1-detail.md.

## Step 2: ...
(inline if simple)

## Validation
- [ ] Condition A
- [ ] Condition B

On failure: return to Step X and reprocess.
```

---

**Last Updated**: 2026-02-22
