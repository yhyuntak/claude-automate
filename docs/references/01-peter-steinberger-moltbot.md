# The Creator of Moltbot: "I Ship Code I Don't Read"

> Source: [The Pragmatic Engineer Newsletter](https://newsletter.pragmaticengineer.com/p/the-creator-of-clawd-i-ship-code)
> Author: Gergely Orosz
> Date: 2026-01-29

## Overview

Peter Steinberger, creator of Moltbot (formerly Clawdbot) and founder of PSPDFKit, ships more code than most teams. In January 2026, he made **6,600+ commits alone**.

> "From the commits, it might appear like it's a company. But it's not. This is one dude [me] sitting at home having fun."

## Key Insights

### 1. Managing Dev Teams Teaches You to Let Go of Perfectionism
Running PSPDFKit with 70+ people forced Peter to accept that code wouldn't always match his exact preferences. This skill transfers directly to working with AI agents.

### 2. Close the Loop
AI agents must be able to verify their own work. Design systems so agents can compile, lint, execute, and validate output themselves.

### 3. Pull Requests are Dead, Long Live "Prompt Requests"
Peter views PRs as "prompt requests" - more interested in seeing the prompts that generated code than the code itself.

### 4. Code Reviews are Dead - Architecture Discussions Replace Them
Even in Discord, he doesn't talk code with his core team: they only talk about architecture and big decisions.

### 5. Run 5-10 Agents and Stay in "Flow" State
Peter queues up multiple agents working on different features simultaneously.

### 6. Spend Time Planning, Prefer Codex
Peter spends significant time going back-and-forth with an agent to come up with a solid plan. He challenges the agent, tweaks it, pushes back. When satisfied with the plan, he kicks it off and moves to the next one.

**Why Codex over Claude Code?** Codex goes off and does long-running tasks. Claude Code comes back for clarifications, which he finds distracting after fleshing out a plan.

### 7. Under-prompt Intentionally
Sometimes gives vague prompts to let the AI explore directions he hadn't considered.

### 8. Local CI Beats Remote CI
Runs tests locally through agents rather than waiting for remote CI pipelines (saves ~10 minutes per cycle).

### 9. Most Code is Boring Data Transformation
> "The majority of application code is just 'massaging data in different forms' and doesn't warrant obsessive attention."

Focus energy on system design instead.

### 10. Engineers Who Thrive with AI Care About Outcomes
Engineers who love solving algorithmic puzzles struggle going "AI-native." People who love shipping products excel.

## Key Takeaway

> "Software engineering isn't dead with AI - quite the opposite."

Peter operates as a **software architect** who:
- Keeps high-level structure in his head
- Deeply cares about architecture, tech debt, extensibility, modularity
- Acts as "benevolent dictator" ensuring project direction and style

Moltbot's success comes from its **extensibility** - and Peter spends energy making it easy to add new capabilities while maintaining coherent direction.

## References

- [Moltbot](https://www.molt.bot)
- [Peter's Blog: Shipping at Inference-Speed](https://steipete.me/posts/2025/shipping-at-inference-speed)
- [Peter on X](https://x.com/steipete)
