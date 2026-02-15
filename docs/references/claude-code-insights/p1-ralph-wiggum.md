---
id: P1
title: Ralph Wiggum (Official Plugin)
author: Anthropic
url: https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum
fetched: 2026-02-15
---

# Ralph Wiggum Plugin

## Overview

The Ralph Wiggum Plugin implements an iterative AI development methodology within Claude Code. Named after the Simpsons character, it embodies persistent iteration through self-referential loops.

## Core Mechanism

As described in the documentation: **"Ralph is a Bash loop"** - a continuous cycle that repeatedly feeds prompts back to an AI agent. Rather than requiring external bash scripts, this plugin uses a Stop hook that intercepts exit attempts, creating internal feedback loops within a single session.

The self-referential process works by:
- Maintaining unchanged prompts across iterations
- Preserving file modifications between cycles
- Allowing the AI to review its own previous work and git history
- Enabling autonomous refinement without external intervention

## Primary Commands

**Starting a loop:**
```bash
/ralph-loop "<prompt>" --max-iterations <n> --completion-promise "<text>"
```

**Stopping a loop:**
```bash
/cancel-ralph
```

## Effective Prompt Design

Strong prompts include:
- Explicit completion criteria with specific deliverables
- Phased milestones for complex projects
- Built-in test-driven development workflows
- Maximum iteration limits as safety mechanisms

The documentation emphasizes that `--max-iterations` functions as the primary safeguard, since the `--completion-promise` uses exact string matching only.

## Appropriate Use Cases

**Recommended for:** Well-defined tasks, iterative refinement, greenfield projects, automated verification

**Not recommended for:** Subjective design decisions, single-operation tasks, unclear success metrics, production diagnostics

## Historical Performance

The approach reportedly enabled rapid repository generation during hackathon testing and supported high-value contract completion with minimal computational expense.
