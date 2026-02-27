---
name: save-para
description: Saves insights from conversations to PARA Resources. Auto-activated by keywords like "save to PARA", "save to resources", "save knowledge".
argument-hint: "[title]"
---

# save-para

> Save things learned during a conversation to PARA Resources

---

## Progressive Disclosure Workflow

This skill operates **without hardcoded structures**, reading README.md files sequentially to work dynamically.

### Step 1: Confirm PARA Root

```
Read: ~/workspace/mynotes/README.md
→ Understand PARA structure (Projects, Areas, Resources, Archive)
→ Navigate to Resources/ folder
```

### Step 2: Understand Resources Structure

```
Read: ~/workspace/mynotes/Resources/README.md
→ Extract category list from "Classification Criteria" table
→ Confirm current folder structure from "Categories" table
```

### Step 3: Ask User (Dynamic Options)

**Content confirmation:**
```
AskUserQuestion:
  question: "What content would you like to save?"
  options:
    - Summary suggestion of recently discussed content
    - "Enter manually"
```

**Category selection (use list read from README.md):**
```
AskUserQuestion:
  question: "Which category would you like to save to?"
  options:
    - (Dynamically generated from "Categories" table in Resources/README.md)
    - "Create new category"
```

### Step 4: Check Category README

```
Read: ~/workspace/mynotes/Resources/{selected category}/README.md
→ Understand the rules/format for that category
→ Check existing document list (to prevent duplicates)
```

### Step 5: Confirm Title/Filename

```
AskUserQuestion:
  question: "Shall we use '{suggested title}' as the title?"
  options:
    - "Yes"
    - "Enter manually"
```

### Step 6: Save

1. **Create file**: `~/workspace/mynotes/Resources/{category}/{slug}.md`
2. **Apply template** (see below)
3. **Update index** (see below)

---

## Template

```markdown
---
title: {title}
created: {YYYY-MM-DD}
tags: [{tags}]
source: claude-session
---

# {title}

{content}

---

## Related Documents

-
```

---

## Index Update

### Category README.md

Add new entry to document list table:
```markdown
| [[new-doc]] | First sentence | #tag1 #tag2 |
```

### Resources/README.md

Add to the top of the "Recently Added" table:
```markdown
| [[new-doc]] | {category} | #tag | {date} |
```

Update document count in the "Categories" table

---

## When Creating a New Category

1. Create `Resources/{new-category}/` folder
2. Create `Resources/{new-category}/README.md` (refer to existing category README format)
3. Update "Classification Criteria" and "Categories" tables in `Resources/README.md`

---

## Completion Message

```markdown
## Saved!

- **File**: Resources/{category}/{slug}.md
- **Category**: {category}
- **Tags**: {tags}

Index has been updated.
```

---

## Filename Rules

- Lowercase English letters
- Spaces → hyphens (-)
- Non-English titles → generate English slug

Example: "Race Condition Solution" → `race-condition.md`
