---
name: plan
description: Architecture-first planning - finalize design before code. Auto-activates on keywords like "어떻게 할까", "설계", "구현 방법", "만들자", "계획", "plan", "design", "how should"
argument-hint: "[new|bug|refactor|perf|migrate]"
---

# Plan Skill

$ARGUMENTS

Architecture-first planning skill that ensures design decisions are made before implementation begins.

---

## Philosophy

```
"Spend 80% of your time planning, 20% executing"
- Peter Steinberger
```

In the AI era, the developer's core competency:
- Writing code ❌
- Deciding what, why, and how ✅

---

## Workflow (5 Steps)

### Step 1: Context Understanding

**Goal**: Understand what the user wants to achieve

1. **Scenario Classification**
   - New feature
   - Bug fix
   - Refactoring
   - Performance optimization
   - Migration
   - Other

2. **Dynamic Checklist Generation**
   - Create context-specific checklist of decisions needed
   - Based on scenario type and user input
   - See [schema.md](schema.md) for templates

### Step 2: Exploration (if needed)

**Goal**: Gather information about current codebase state

Call appropriate agents based on scenario:

| Scenario | Agent | Tier Selection |
|----------|-------|----------------|
| New feature / Refactoring | Explore | low: 파일 찾기 / default: 구조 파악 / high: 아키텍처 분석 |
| Bug fix | Debugger | low: 로그 확인 / default: 원인 분석 |
| Refactoring / Migration | Architect | low: 의존성 확인 / default: 영향도 분석 (Opus) |
| Performance | Profiler | low: 복잡도 확인 / default: 병목 분석 |

**Tier 선택 원칙**: 작업 복잡도에 맞는 최소 tier 사용 (토큰 절약)

Update checklist based on findings.

### Step 3: Specification Dialog (Core)

**Goal**: "Extract the brain" - turn ambiguity into concrete decisions

**Principles**:
- **Single Question Principle**: Ask ONE thing at a time
- **multiSelect: true** by default (see interaction.md)
- **Aggressive AskUserQuestion**: Don't assume, ask
- **No ambiguity tolerance**: Vague → Concrete

**Process**:
```
Checklist item unchecked
    ↓
Is it clear? NO → AskUserQuestion
    ↓
User answers
    ↓
Check item ✓
    ↓
Next item
```

**Entry Mode Branching**:

| User Input | Mode | Action |
|------------|------|--------|
| Vague ("improve this", "refactor") | Interview Mode | Start with open questions |
| Specific (mentions file/function) | Direct Mode | Confirm understanding, fill checklist |

### Step 4: Completion Check

**Goal**: Determine if planning is complete

**Criteria**:
- Most checklist items checked
- No critical ambiguities remain
- User seems satisfied

**Action**: AskUserQuestion
```
"핵심 결정들이 정리된 것 같아. 어떻게 할까?"

Options:
□ Start implementation
□ Continue discussion
□ Deep dive into [specific item]
```

**Flow**:
- "Continue discussion" → Back to Step 3
- "Start implementation" → Step 5

### Step 5: Plan Finalization

**Goal**: Save the plan and transition to implementation

1. **Generate plan summary**:
   - Decisions made
   - Implementation direction
   - Cautions/considerations

2. **Save plan**: `.claude/plans/{date}-{slug}.md`
   - Use schema from [schema.md](schema.md)

3. **Transition**: Hand off to implementation

---

## Entry Triggers

**Auto-activation keywords**:
- Korean: "어떻게 할까", "설계", "구현 방법", "만들자", "계획"
- English: "plan", "design", "how should", "let's build", "approach"

**Explicit invocation**:
```bash
/plan              # General planning
/plan new          # New feature planning
/plan bug          # Bug fix planning
/plan refactor     # Refactoring planning
/plan perf         # Performance optimization
/plan migrate      # Migration planning
```

---

## Core Principles

### 1. Brain Extraction

Transform vague → concrete through systematic questioning.

```
Vague: "Add user authentication"
    ↓ (question bombardment)
Concrete: "JWT-based auth, /api/auth/login endpoint,
          24hr session expiry, refresh tokens enabled"
```

### 2. Single Question Principle

**ONE question at a time**. Never batch questions.

❌ Bad:
```
"What authentication method? What session duration?
 What user storage?"
```

✅ Good:
```
"What authentication method do you prefer?"
[user answers]
"How long should sessions last?"
[user answers]
...
```

### 3. Aggressive Clarification

When in doubt, ask. Never assume.

```
User: "Add user management"
    ↓
- Who is "user"? Admin? End user?
- What is "management"? CRUD? Permissions? Profile?
- Scale? 100 users? 1 million?
```

### 4. Dynamic Checklist

Checklist adapts to context. Not fixed template.

See [schema.md](schema.md) for examples per scenario.

---

## Agent Usage Decisions

| Condition | Use Agent? |
|-----------|-----------|
| Parallel work needed | ✅ Multiple file analysis |
| Independent subtask | ✅ Code exploration, analysis |
| 1:1 conversation | ❌ Main Claude handles directly |

**Planning phase**: Conversation = main Claude, Exploration = agents

### Tier Selection

| 복잡도 | Tier | 예시 |
|--------|------|------|
| 단순 | `-low` (Haiku) | "이 함수 어디 있어?", "에러 로그 확인" |
| 표준 | `default` (Sonnet/Opus) | "구조 분석", "원인 파악", "영향도 분석" |
| 복잡 | `-high` (Opus) | "전체 아키텍처 분석", "복잡한 의존성 그래프" |

**상세**: [references/agents.md](references/agents.md) 참조

---

## Reference Files

- [schema.md](schema.md) - Plan document templates, checklist examples
- [references/scenarios.md](references/scenarios.md) - Scenario-specific flows
- [references/agents.md](references/agents.md) - Agent definitions

---

**Last Updated**: 2026-02-01
