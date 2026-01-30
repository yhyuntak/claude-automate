# I Stopped Reading Code, and My Code Reviews Got Better

> Source: Every - Source Code
> Author: Kieran Klaassen (General Manager at Cora)
> Date: 2026-01-23

## The Problem

A simple bug report about email signature formatting led to a fix that touched **27 files** and **1,000+ lines of code**. Kieran didn't write a single line.

> "A year ago, I would have spent an afternoon reading that code. This time, I made decisions in 15 minutes, and the code deployed without a single bug."

## Why Manual Code Review Doesn't Scale

AI broke the ratio:
- Developer writes 200 lines → Manager spends 20-40 minutes reviewing
- Traditional ratio: 5:1 or 10:1 (writing:reviewing)
- **AI changed writing time dramatically, but human review time stayed the same**

Something had to give.

## The New Approach: 13 Parallel AI Reviewers

Instead of reading code, Kieran runs **13 specialized AI agents** in parallel:

| Agent | Focus Area |
|-------|------------|
| `kieran-rails-reviewer` | Personal style preferences |
| `code-simplicity-reviewer` | Over-engineering detection |
| `data-integrity-guardian` | Database migration validation |
| `security-sentinel` | Authentication bypass checks |
| + 9 more | Each with specific focus |

### Why So Many Agents?

> "A single reviewer, human or AI, won't catch everything in a 27-file change. Security expert spots auth gaps but misses DB issues. Performance expert catches slow queries but ignores style drift."

## The Workflow

### 1. Review Command
```
/workflows:review
```
Kicks off all 13 agents simultaneously.

### 2. Triage Command
```
/triage
```
- Ranks all findings by severity
- Presents each with: problem, why it matters, what to do
- Options: Accept (create fix), Skip, or Provide specific instructions

### 3. Interrogate Claude Instead of Reading Diffs

Questions to ask:
- "What did you change and why?"
- "What assumptions did you make?"
- "What could break this?"
- "Why did you ignore kieran-reviewer's feedback?"

## The 50/50 Rule

> "Half your time reviewing output, half making the system smarter."

After the signature fix fiasco (10 versions, 4 bugs introduced), they created `refactor-email-content-rendering.md`:
- Chart showing all user setting combinations
- Simple rules for which system handles formatting
- Exact Gmail signature format expectations (tested, not assumed)

**This document becomes part of the project** - next time anyone (human or AI) touches email rendering, the AI reads it first.

## Compound Effect

> "Better AI models make everyone's output better. But YOUR system gets better because it accumulates knowledge unique to YOUR team."

- Agents learn your preferences
- Review process reveals your blind spots
- That's where compounding happens

## Quick Start (No Custom Tools)

Before approving any AI-generated output, ask:

1. **"What was the hardest decision here?"**
2. **"What alternatives did you reject, and why?"**
3. **"What are you least confident about?"**

> "That two-minute conversation surfaces what 30 minutes of unfocused manual inspection would miss. The AI knows where the tricky parts are. It just won't volunteer them unless you ask."

## Key Insight

The trade-off:
- ❌ Reading every line
- ✅ Time spent making the system smarter

> "The 27 files that touched email signature rendering are waiting for the next feature. I still won't read all of them. But when I'm done, the system will know more than when I started."
