---
id: A5
title: 32 Claude Code Tips from Basics to Advanced
author: YK (Agentic Coding)
url: https://agenticcoding.substack.com/p/32-claude-code-tips-from-basics-to
fetched: 2026-02-15
---

# 32 Claude Code Tips: From Basics to Advanced

This comprehensive guide by YK covers practical strategies for maximizing Claude Code's potential across basic and advanced use cases.

## Core Tips Overview

**Tip 0: Customize Your Status Line**
"customize the status line at the bottom of Claude Code to show useful info" including model, directory, git branch, uncommitted files, sync status, and token usage tracking.

**Tip 1: Voice Communication**
Users can communicate faster through voice transcription than typing. Local models like MacWhisper or SuperWhisper work effectively despite occasional transcription errors, as Claude interprets context correctly.

**Tip 2: Problem Decomposition**
Breaking large problems into smaller, solvable components is essential. Instead of attempting A→B directly, create intermediate steps (A→A1→A2→A3→B) that are individually manageable.

**Tip 3: Git and GitHub CLI Integration**
Let Claude handle Git operations including commits, branching, pulling, and pushing. Draft PRs minimize risk before marking changes ready for review.

**Tip 4: Fresh Context Performance**
"AI context is like milk; it's best served fresh and condensed." New conversations perform better than lengthy ones with accumulated context.

**Tip 5: Output Extraction Methods**
Multiple approaches exist: `/copy` command for markdown, `pbcopy` for clipboard access, file-based editing in VS Code, URL opening, and GitHub Desktop integration.

**Tip 6: Terminal Aliases**
Setup shortcuts: `c` for Claude, `ch` for Chrome integration, `gb` for GitHub Desktop, `co` for VS Code, `q` for project directory.

**Tip 7: Proactive Context Compaction**
Use `/compact` command to create handoff documents summarizing progress before starting fresh conversations, enabling seamless continuation with new context.

**Tip 8: Write-Test Cycle Completion**
Autonomous tasks require verification mechanisms. Use tmux for interactive testing, allowing Claude to run processes like `git bisect` independently while checking outputs.

**Tip 9: Cmd+A and Ctrl+A Usage**
Select-all and copy provides access to private content, Reddit posts, and terminal output that Claude cannot fetch directly—a powerful workaround for restricted access.

**Tip 10: Gemini CLI as Fallback**
Create skills enabling Claude to use Gemini's web access for sites like Reddit that Claude Code cannot reach, using tmux pattern for orchestration.

**Tip 11: Personal Workflow Investment**
Invest time customizing tools—whether building custom applications, maintaining concise CLAUDE.md files, or creating system prompt patches.

**Tip 12: Conversation History Search**
Conversations stored locally in `~/.claude/` can be searched with bash commands or by asking Claude directly about past discussions and findings.

**Tip 13: Multitasking with Terminal Tabs**
Manage 3-4 tasks simultaneously using "cascade" method—opening new tabs rightward and sweeping left-to-right during reviews.

**Tip 14: System Prompt Slimming**
Custom patches reduce Claude Code's overhead from 18k to 10k tokens (saving ~7,300 tokens or 41% of static overhead). Lazy-load MCP tools with `ENABLE_TOOL_SEARCH` setting.

**Tip 15: Git Worktrees**
Create separate directory/branch combinations for parallel work on different features without file conflicts.

**Tip 16: Manual Exponential Backoff**
Have Claude check long-running job status with increasing intervals (1min→2min→4min) rather than continuous polling—token-efficient approach.

**Tip 17: Writing Assistant Role**
Claude Code excels as interactive writing partner: provide context, receive drafts via voice, iterate line-by-line with side-by-side terminal and editor setup.

**Tip 18: Markdown Workflow**
Markdown is "the s**t"—more efficient than Google Docs or Notion for drafting with Claude Code assistance, easily convertible to other formats.

**Tip 19: Notion as Link Preservier**
Copy text with links through Notion before pasting into Claude Code to preserve markdown formatting and hyperlinks.

**Tip 20: Containers for Risky Tasks**
Run `--dangerously-skip-permissions` sessions in Docker containers for experimental work—failed processes affect only the sandbox, not the host system.

**Advanced Container Orchestration**: Local Claude Code can control container-based Claude instances via tmux, enabling fully autonomous "worker" agents.

**Tip 21: Learning by Usage**
"The best way to get better at using Claude Code is by using it"—practical experience surpasses supplementary learning resources.

**Tip 22: Conversation Cloning**
Use `/fork` command (or `--fork-session`) to branch conversations and explore different approaches without losing original threads. `/half-clone` reduces token usage by keeping only recent messages.

**Tip 23: Absolute Paths**
Use `realpath` for complete file paths when referencing documents in different directories.

**Tip 24: CLAUDE.md vs Skills vs Commands**
- CLAUDE.md: Simple default prompts loaded always
- Skills: Token-efficient, auto-invoked when relevant
- Slash Commands: Manual invocation, user-focused
- Plugins: Bundled collections of the above

**Tip 25: Interactive PR Reviews**
Claude Code becomes conversation partner for code reviews—retrieve PR info via `gh`, control pace and depth, run tests as needed.

**Tip 26: Research Tool Capability**
"Claude Code is amazing for any sort of research"—use `gh` commands, container approaches, Gemini CLI, MCPs, and Cmd+A method for information gathering.

**Tip 27: Output Verification Methods**
Verify code through tests, visual Git clients, draft PRs, and Claude's self-checking ("double check everything...make a table of verified claims").

**Tip 28: DevOps Engineering**
Claude excels at debugging GitHub Actions failures—dig through logs, identify root causes in specific commits or flaky issues.

**Tip 29: Keep CLAUDE.md Concise**
Start minimal and add repeated instructions. Let Claude edit project or global CLAUDE.md based on feedback patterns.

**Tip 30: Universal Interface Concept**
Claude Code functions as "the universal interface to your computer"—handles video editing, audio transcription, data analysis, Reddit research, and complex workflows through text commands.

**Tip 31: Abstraction Level Selection**
Spectrum ranges from "vibe coding" (high-level, exploratory) to detailed code review—choose appropriate depth based on project criticality and risk.

## Key Takeaways

The guide emphasizes combining software engineering fundamentals with AI capabilities, maintaining token efficiency through context management, and treating Claude Code as a collaborative partner rather than a one-shot tool. Success metrics focus on thoughtful workflow design and continuous optimization based on actual usage patterns.
