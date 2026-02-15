---
id: A1
title: Claude Code 창시자 워크플로우
author: InfoQ
url: https://www.infoq.com/news/2026/01/claude-code-creator-workflow/
fetched: 2026-02-15
---

# Claude Code 창시자 워크플로우

# Inside the Development Workflow of Claude Code's Creator

## Overview

Boris Cherny, creator of Claude Code at Anthropic, shared his development practices that optimize productivity through AI-assisted coding workflows.

## Key Practices

**Parallel Instance Management**
Cherny runs multiple Claude Code sessions simultaneously—five locally on his MacBook terminal and 5-10 on Anthropic's website. To prevent conflicts, each local session maintains its own Git checkout rather than using branches or worktrees.

**Model Selection**
He exclusively uses Opus 4.5 with thinking capability for coding tasks, preferring its superior quality and reliability over the faster Sonnet model. Despite slower execution speed, Opus proves faster overall and excels at tool use.

**Knowledge Documentation**
Each Anthropic team maintains a `CLAUDE.md` file in Git documenting mistakes and best practices—style conventions, design guidelines, pull request templates—allowing Claude to learn and improve continuously. Cherny's team's file currently contains approximately 2.5k tokens.

**Workflow Optimization**
His development approach emphasizes planning: "If my goal is to write a Pull Request, I will use Plan mode, and go back and forth with Claude until I like its plan. From there, I switch into auto-accept edits mode."

Daily tasks use slash commands triggering sub-agents, stored in `.claude/commands/`. These commands use inline bash to pre-compute information, minimizing model back-and-forth.

**Code Quality Assurance**
Cherny implements a PostToolUse hook running `bun run format` to maintain consistency and prevent CI failures. For permissions, he enables safe commands via `/permissions` rather than using `--dangerously-skip-permissions`.

**Verification Loop**
The most impactful technique involves giving Claude feedback mechanisms—test suites, browser testing, simulator validation—to verify changes. "Claude tests every single change...using the Claude Chrome extension. It opens a browser, tests the UI, and iterates until the code works."

This methodology reportedly improves output quality 2-3 times, allowing engineering teams to focus on code review and strategic direction.
