---
description: Start Work - Integrated workflow for session context, backlog review, and worktree setup
---

[START WORK MODE ACTIVATED]

$ARGUMENTS

---

## /start-work: Integrated Work Start Workflow

Handles the complete flow from session initialization to work environment setup in one command.

**Flow:**
1. Display previous session summary
2. Show backlog list
3. Confirm worktree usage
4. Select a backlog task
5. (If worktree) Create environment and switch to it

---

## STEP 1: Load Session Context

### Find Recent Sessions

```bash
ls -t .claude/context/*/*.md 2>/dev/null | head -5
```

### Display Session Summary

When session files exist:
```markdown
## 📋 Previous Session Summary

**2026-01-22 (abc123)** - Feedback system improvements
- Work: Added /write-feedback, /check-feedback
- Incomplete: Integration testing

---
```

When session files do not exist:
```markdown
## 📋 Previous Session

No previous session records found.

---
```

---

## STEP 2: Review Backlog

### Check Backlog Folders

```bash
ls docs/backlog/todo/ 2>/dev/null
ls docs/backlog/doing/ 2>/dev/null
```

### Display Backlog Table

When backlog exists:
```markdown
## 📝 Backlog

| # | Phase | ID | Title | Description |
|---|-------|-----|-------|-------------|
| 1 | 1 | 001 | feature-x | Implement feature X |
| 2 | 1 | 002 | feature-y | Implement feature Y |

**In Progress:** phase1-003-feature-z (if in doing folder)

---
```

When backlog does not exist:
```markdown
## 📝 Backlog

This project has no backlog.
(docs/backlog/ folder does not exist or is empty)

---
```

### Backlog Parsing Rules

- Filename: `phase{N}-{ID}-{slug}.md`
- Description: First `> ` quote in file

```bash
# Extract description
head -5 docs/backlog/todo/phase1-001-xxx.md | grep "^>" | head -1 | sed 's/^> //'
```

---

## STEP 3: Confirm Worktree Usage

**Use AskUserQuestion:**

```
Question: "Use worktree for this project?"
Header: "Worktree"
Options:
  - "Yes": Separate branch using worktree
  - "No": Work in current folder
```

---

## STEP 4: Select Backlog Task

**Use AskUserQuestion:**

```
Question: "Which task to start?"
Header: "Task Selection"
Options:
  - [Backlog list - number and title]
  - "New task (no backlog)": Free work
```

**If no backlog exists:** Skip this step and proceed as Free work automatically (no question needed).

---

## STEP 5: Create Worktree (If Yes selected)

### Branch Naming Rule
- Extract slug from filename: `phase1-001-feature-x` → `feature-x`

### Path Rule
- `../{project-name}-{branch}`
- Example: `../claude-automate-feature-x`

### Get Project Name
```bash
basename $(pwd)
```

### Check Existing Worktree
```bash
git worktree list | grep {branch}
```

- If exists: Display warning "⚠️ worktree already exists: {path}"
- If not: Proceed with creation

### Create Worktree
```bash
git worktree add ../{project}-{branch} -b {branch}
```

### Copy Environment Files

Check for .env files in original project:
```bash
ls .env* 2>/dev/null
```

If .env files exist, copy to worktree:
```bash
cp .env* ../{project}-{branch}/ 2>/dev/null
```

Display result:
```
✓ Copied environment files: .env, .env.local
```

If no .env files found, skip silently.

### Switch to Worktree

**IMPORTANT: Always execute cd to move to worktree:**
```bash
cd ../{project}-{branch}
```

This ensures Claude Code's working directory is the worktree for the rest of the session.

---

## STEP 6: Completion Message

### Worktree Mode

**Read backlog file content:**
```bash
cat docs/backlog/todo/phase1-001-feature-x.md
```

**Display:**
```markdown
## ✅ Work Environment Ready

**Task:** phase1-001-feature-x (Implement feature X)
**Path:** ../claude-automate-feature-x
**Branch:** feature-x

Now working in this folder.

---

## 📄 Task Details

[Full content of the backlog file]

---

💡 Return to main project: `cd ../claude-automate`
```

### Standard Mode

**Read backlog file content:**
```bash
cat docs/backlog/todo/phase1-001-feature-x.md
```

**Display:**
```markdown
## ✅ Work Started

**Task:** phase1-001-feature-x (Implement feature X)

---

## 📄 Task Details

[Full content of the backlog file]
```

### New Task (No Backlog)
```markdown
## ✅ Work Started

Starting free work without backlog.
```

---

## STEP 6.5: Ask Next Action

완료 메시지 출력 후, **반드시** AskUserQuestion 호출:

**Use AskUserQuestion:**

```json
{
  "question": "다음에 무엇을 할까요?",
  "header": "Next Action",
  "multiSelect": false,
  "options": [
    {
      "label": "브레인스토밍",
      "description": "뭘 만들지 구체화 (/brainstorm)"
    },
    {
      "label": "계획 세우기",
      "description": "어떻게 만들지 계획 (/planning)"
    },
    {
      "label": "바로 구현",
      "description": "확인 없이 구현 시작"
    },
    {
      "label": "질문/논의",
      "description": "태스크에 대해 더 논의"
    }
  ]
}
```

> **Note:** `multiSelect: false` - 상호 배타적 선택 (한 가지 행동만 선택)

**CRITICAL:** 이 질문을 건너뛰지 마세요. 도구 호출은 무시할 수 없습니다.

---

## Options

```
/start-work              # Default: Full workflow
/start-work --skip-session   # Skip session summary
/start-work --no-worktree    # Skip worktree prompt (standard mode)
```

---

## Complete Workflow Diagram

```
┌─────────────────────────────────────────────────────┐
│  /start-work                                         │
│     │                                               │
│     ├─ 1. Display session summary                   │
│     │      └─ Check .claude/context/                │
│     │                                               │
│     ├─ 2. Display backlog table                     │
│     │      └─ Check docs/backlog/todo/              │
│     │                                               │
│     ├─ 3. [Ask] "Use worktree?"                     │
│     │      ├─ Yes → Worktree mode                   │
│     │      └─ No → Standard mode                    │
│     │                                               │
│     ├─ 4. [Ask] "Which task?"                       │
│     │      ├─ Select backlog                        │
│     │      └─ New task (no backlog)                 │
│     │                                               │
│     ├─ 5. (If worktree)                             │
│     │      ├─ git worktree add                      │
│     │      ├─ cd switch                             │
│     │      └─ Warning (if already exists)           │
│     │                                               │
│     ├─ 6. Completion message                        │
│     │                                               │
│     └─ 6.5 [Ask] "다음에 무엇을 할까요?"            │
│            ├─ 브레인스토밍 → /brainstorm            │
│            ├─ 계획 세우기 → /planning               │
│            ├─ 바로 구현                             │
│            └─ 질문/논의                             │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Related Commands

- `/session-start`: Session summary only (Step 1)
- `/backlog`: Backlog only (Step 2)
- `/wrap`: Save session when work is complete

---

## CRITICAL RULES

### 1. Use explore Agent for File Reading

When reading files (session context, backlog files, etc.), use explore agent:

```
Task(
  subagent_type="claude-automate:explore-low",
  prompt="Read and summarize: {file_path}"
)
```

**Why:** Prevents context pollution. Main receives summary only.

### 2. AskUserQuestion으로 다음 행동 강제

**STEP 6.5의 AskUserQuestion 호출은 필수입니다.**

텍스트 규칙("구현하지 마세요")은 Claude가 무시할 수 있지만,
도구 호출은 무시할 수 없습니다.

**Why:**
- 사용자 확인 없이 구현 시작 방지
- 사용자가 다음 행동 결정
- "architecture first" 원칙 준수

---

## THE START-WORK PROMISE

Before completion, verify:
- [ ] Session context displayed (via explore agent)
- [ ] Backlog status displayed (explicitly state "none" if missing)
- [ ] User selection received (worktree, task)
- [ ] Environment configured per selection
- [ ] Completion message displayed
- [ ] **AskUserQuestion으로 다음 행동 질문** (필수 - 건너뛰기 불가)
