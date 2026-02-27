---
name: planning
description: |
  Creates an implementation plan. Includes automatic mode detection, codebase exploration, AC extraction, and validation.
  Activated by keywords: "planning", "plan", "how to build", "design".
argument-hint: "[feature or topic]"
allowed-tools:
  - Read
  - Glob
  - Grep
  - LSP
  - Task
  - AskUserQuestion
---

# /planning

$ARGUMENTS

---

## Progress Guidance Rules

Announce the current status to the user when entering each step.

- Entry: "Entering {Direct/Interview} mode."
- Each step: "[N/10] Running {step name}."
- Result: One-line summary after each step completes

Step list:
- Step 1: "[1/10] Mode Detection"
- Step 2: "[2/10] Interview"
- Step 3: "[3/10] Reading Brain"
- Step 4: "[4/10] Codebase Exploration"
- Step 5: "[5/10] AC Draft Extraction"
- Step 6: "[6/10] Angel Expansion"
- Step 7: "[7/10] Devil Validation"
- Step 8: "[8/10] User Confirmation"
- Step 9: "[9/10] Plan File Creation"
- PARA: "[10/10] PARA Concept Extraction"

## Step 1: Mode Detection

MUST: Write `planning` to `.claude/state/mode`. (`echo planning > .claude/state/mode`)

MUST: Read refs/mode-detection.md and confirm the detection criteria.

Analyze arguments and conversation history to determine the mode.

| Condition | Mode |
|-----------|------|
| Specific requirements present (file name, feature name, clear behavior) | **Direct** → Step 3 |
| Vague request (improve, refactor, want to do something) | **Interview** → Step 2 |
| Cannot determine | Confirm with AskUserQuestion |

After deciding the mode, inform the user:
- Direct: "Entering **Direct mode**. Building a plan based on specific requirements."
- Interview: "Entering **Interview mode**. Asking questions to clarify the idea."

## Step 2: Interview (only when vague)

Clarify the user's idea.

Rules:
- Ask **one question at a time** (use AskUserQuestion)
- For things verifiable in the codebase, **use explore first instead of asking**
- Each question evolves based on the previous answer
- Once sufficiently clarified → proceed to Step 3

Question classification:
| Type | Handling |
|------|----------|
| Codebase facts ("What pattern are you using?") | Verify with explore agent → do not ask |
| User preferences ("Which approach do you prefer?") | AskUserQuestion |
| Scope decisions ("Should this be included?") | AskUserQuestion |
| Technical constraints ("Performance requirements?") | AskUserQuestion |

## Step 3: Reading Brain

Read the `.claude/brain/index.md` index.

- index.md exists → check related files (code-map, patterns, decisions)
- index.md absent → do full exploration in Step 4, then include brain bootstrap (index.md + initial files) in the plan's Brain update section

Skip exploration in Step 4 for information already in the brain.

## Step 4: Codebase Exploration

Use the explore agent to understand the code structure needed for implementation.

```
Task(
  subagent_type="claude-automate:explore",
  prompt="Understand the code structure, patterns, and dependencies related to [implementation target]"
)
```

Exploration targets:
- Existing code to modify/extend
- Related patterns and conventions
- Dependencies and impact scope

If there is anything worth recording in the brain from the exploration results, make a note (include in plan in Step 9).

## Step 5: AC Draft Extraction

Extract ACs from two sources:

| Source | AC Type | Example |
|--------|---------|---------|
| Conversation/Interview | User perspective | "Session ends on logout" |
| Step 4 exploration result | Technical perspective | "Refresh token must also be invalidated" |

AC/TC writing criteria:
- AC = work item (what to do)
- TC = verification criteria (how to confirm, sub-items of AC)
- TC must be a statement that can be judged as "pass/fail"
- One TC = one verification point
- ACs that cannot be tested are marked "(no TC)"
- No vague expressions ("works well" → "returns 200 response")

## Step 6: Angel Expansion

Expand ACs with the Angel agent.

```
Task(
  subagent_type="claude-automate:angel",
  prompt="Current AC/TC list: [AC/TC list]. Check if there are any missing work items at the AC level or missing edge cases/validation conditions at the TC level."
)
```

Merge additional ACs suggested by Angel into the draft.

## Step 7: Devil Validation

MUST: Read refs/devil-usage.md and confirm the invocation criteria.

Validate the entire AC set with the Devil agent.

```
Task(
  subagent_type="claude-automate:devil",
  prompt="Validate AC/TC list: [AC/TC list]. Point out ambiguous ACs, untestable TCs, missing risks, and AC-TC mismatches."
)
```

Revise ACs based on Devil feedback:
- Ambiguous AC → clarify
- Untestable AC → mark as (not testable)
- Missing risks → add as AC

## Step 8: User Confirmation

Present the final AC list with AskUserQuestion.

```json
{
  "question": "Please review the AC list. Are there any additions, modifications, or deletions?",
  "header": "AC Confirmation",
  "multiSelect": true,
  "options": [
    { "label": "Proceed as is", "description": "Finalize AC list and create plan file" },
    { "label": "Need to modify ACs", "description": "Want to modify/add/delete ACs" },
    { "label": "Start over", "description": "Want to change direction" }
  ]
}
```

- "Proceed as is" → Step 9
- "Need to modify ACs" → revise then repeat Step 8
- "Start over" → back to Step 1

## Step 9: Plan File Creation

MUST: Read refs/plan-file.md and confirm the file structure.

Delegate plan file writing to the writer agent.

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
Create plan file

## Target
.claude/plans/{YYYY-MM-DD}-{slug}.md

## Content
Write the plan file including all of the following:

- Requirements (Context/What/Why/Scope)
- Brain updates (things to record discovered in Step 4)
- AC list (finalized in Step 8)
- Implementation order (Brain updates → AC order)
- Test plan

## Format
Follow the structure in refs/plan-file.md
"""
)
```

---

## Step 10: PARA Concept Extraction

Check whether there are any high-level concepts worth learning from this Planning session.

### Skip Conditions

Skip this Step and proceed directly to "Next Action" when:

- Only simple implementation/configuration/typo fix discussions occurred
- No new architecture/pattern/principle discussions took place

### Extraction Targets

- Newly discussed architecture concepts, design patterns
- Trade-off analysis, technology comparison/selection rationale
- General principles derived from problem solving

### Execution

1. Identify 1-3 concept candidates from this conversation (concept name + one-line description)
2. Confirm whether to save with AskUserQuestion:

```
AskUserQuestion:
  "Would you like to save the following concepts from this Planning session to PARA?"
  multiSelect: true
  Each concept displayed as an option
  Recommended category included in description
```

3. No selection → skip
4. Selection made → delegate to writer:

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
Save concept documents to PARA Resources

## Pre-check
First explore ~/workspace/mynotes/Resources/ to check if the same or similar concept already exists.
- If exists: enhance existing document (Edit)
- If not: create new document (Write)

## Target
~/workspace/mynotes/Resources/{category}/{slug}.md

## Template
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

## Index Update
Add entry to category README.md
"""
)
```

---

MUST: Confirm next action with AskUserQuestion.

```json
{
  "question": "The plan file has been created. What would you like to do next?",
  "header": "Next Action",
  "multiSelect": true,
  "options": [
    { "label": "Run /implement (Recommended)", "description": "Start implementation immediately based on the plan" },
    { "label": "Revise plan", "description": "Review/revise the plan file again" },
    { "label": "Later", "description": "Do not implement now" }
  ]
}
```

---

## Constraints

- No file modifications other than the plan file
- No code writing (implementation is done in /implement)
- No brain file modifications (record only in plan, executed in implement)

---

## Verification

MUST: Confirm all items in the checklist below.

- [ ] Is mode detection accurate? (Direct/Interview)
- [ ] Was brain read? (if absent, note "absent")
- [ ] Was codebase explored with explore?
- [ ] Was Angel expansion run?
- [ ] Was Devil validation run?
- [ ] Was user confirmation obtained?
- [ ] Does the plan file contain all required sections?
- [ ] Was PARA concept extraction run/skipped?

If failed: return to the relevant Step, fix, and re-verify.

---

## Cautions

1. **No "freely" allowed** — always follow Step order
2. **Explore first, ask later** — do not ask about things that can be found in the code
3. **Do not implement** — planning only
4. **Record brain in plan only** — do not modify it directly
