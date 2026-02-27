---
name: docs
description: |
  Project document CRUD + index management.
  Create/edit/delete documents + auto-update docs/README.md index.
  Activates on keywords: "docs", "document".
argument-hint: "[title or description]"
allowed-tools:
  - Read
  - Glob
  - Bash
  - Edit
  - Write
  - Task
  - AskUserQuestion
---

# /docs

$ARGUMENTS

---

## Progress Notification Rules

Notify the user of the current status at each step.

- Entry: "Starting document work in {Direct/Interview} mode."
- Each step: "[N/5] Executing {step name}."
- Completion: "Document work completed."

## Step 1: Mode Detection

Analyze arguments and conversation history to determine mode.

| Condition | Mode |
|-----------|------|
| Specific content available (title, file path, conversation history to document) | **Direct** → Step 2 |
| `/docs` called alone with no context | **Interview** → AskUserQuestion |
| Cannot determine | AskUserQuestion to confirm |

On entering Interview mode, ask what to document:

```json
{
  "question": "What document work would you like to do?",
  "header": "Document Work",
  "multiSelect": false,
  "options": [
    { "label": "Create new document", "description": "Write a new document" },
    { "label": "Edit existing document", "description": "Modify an existing document" },
    { "label": "Delete document", "description": "Delete a document" },
    { "label": "Regenerate index", "description": "Rebuild docs/README.md index from current state" }
  ]
}
```

After determining mode, notify the user:
- Direct: "Starting in **Direct mode**. Proceeding based on provided content."
- Interview: "Starting in **Interview mode**. Clarifying content through questions."

## Step 2: Select Operation Type

Skip this step in Direct mode if the operation type is already clear.

If the operation type is unclear, confirm via AskUserQuestion:

```json
{
  "question": "What operation would you like to perform?",
  "header": "Select Operation Type",
  "multiSelect": false,
  "options": [
    { "label": "Create new document", "description": "Add a new document to docs/" },
    { "label": "Edit existing document", "description": "Modify an existing document" },
    { "label": "Delete document", "description": "Delete a document and remove from index" },
    { "label": "Regenerate index", "description": "Rebuild docs/README.md from current file structure" }
  ]
}
```

## Step 3: Explore docs/ + Determine Location

Use explore agent to understand the docs/ structure.

```
Task(
  subagent_type="claude-automate:explore",
  prompt="Understand the full structure of docs/ folder and current state of README.md index"
)
```

Handle by operation type:

| Type | Action |
|------|--------|
| Create new document | Recommend 2-3 appropriate locations based on existing structure via AskUserQuestion |
| Edit existing document | Confirm target file path |
| Delete document | Confirm target file path |
| Regenerate index | Collect current docs/ file list |

Example location recommendations for new documents:

```json
{
  "question": "Where would you like to save the document?",
  "header": "Select Save Location",
  "multiSelect": false,
  "options": [
    { "label": "docs/references/", "description": "Reference materials and external documents" },
    { "label": "docs/backlogs/", "description": "Backlog task documents" },
    { "label": "docs/ (root)", "description": "Top-level documents" }
  ]
}
```

## Step 4: Execute

Delegate to writer agent based on operation type. All file modifications are handled by writer.

**Create new document:**

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
Create {title} document

## Target
{determined path}/{filename}.md (new file)

## Requirements
- Title: {title}
- Content: {conversation history or user-provided content}
- Follow existing docs/ document style

## Verification
Confirm file exists
"""
)
```

**Edit existing document:**

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
Edit {filename} document

## Target
{target file path}

## Requirements
- Changes: {content to modify}
- Preserve existing document structure

## Verification
Confirm file changes
"""
)
```

**Delete document:**

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
Delete {filename}

## Target
{target file path}

## Requirements
- Delete file via Bash: rm {file path}

## Verification
Confirm file no longer exists
"""
)
```

**Regenerate index:**

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
Regenerate docs/README.md index

## Target
docs/README.md

## Requirements
- Collect all .md files under docs/ using Glob
- Rewrite index table based on current file list
- Preserve existing README.md structure

## Verification
Confirm README.md exists and has correct content
"""
)
```

## Step 5: Update Index

Skip this step if Step 4 was index regeneration.

Update the docs/README.md index after creating/editing/deleting documents. Skip if no changes were made.

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
Update docs/README.md index

## Target
docs/README.md

## Requirements
- Change type: {create/edit/delete}
- Target file: {file path}
- Create: Add new entry to index table
- Edit: Update description for the entry
- Delete: Remove the entry

## Verification
Confirm changes are reflected in README.md
"""
)
```

---

## Constraints

- Do not modify files outside docs/
- Delegate all file modifications to writer
- Handle documents only (not code files)
- Do not write to `.claude/state/mode` (independent from planning/implement loop)

---

## Verification

MUST: Confirm all items in the checklist below.

- [ ] Was the document file successfully created/edited/deleted?
- [ ] Is the docs/README.md index up to date?
- [ ] Was progress notification output at each step?

On failure: Return to the relevant step, fix, and re-verify.

---

## Notes

1. **In Direct mode, actively use conversation history** — Extract content to document from history
2. **In Interview mode, ask one question at a time** — Progress sequentially via AskUserQuestion
3. **Respect existing docs/ structure when recommending locations** — Do not arbitrarily create new folders
4. **Always update index last** — Update index after completing file operations
