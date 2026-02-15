---
id: A2
title: How I use Claude Code
author: Steve Sewell (Builder.io)
url: https://www.builder.io/blog/claude-code
fetched: 2026-02-15
---

# How I Use Claude Code

# How I Use Claude Code: Key Insights from Steve Sewell

Steve Sewell, who previously championed Cursor extensively, has switched to Claude Code and reports he won't return to Cursor's agents. Here are the main takeaways from his detailed breakdown:

## Essential Setup Tips

**VS Code Extension**: Install the Claude Code extension for easy access across VS Code, Cursor, and other IDEs. You can run multiple instances simultaneously on different codebase sections.

**Skip Permission Prompts**: Run `claude --dangerously-skip-permissions` to avoid constant approval requests for file edits and command execution.

**Clear Chat Regularly**: Use `/clear` frequently to prevent token waste and avoid unnecessary context compaction.

## Workflow Improvements

Sewell's interaction model has fundamentally shifted—Claude Code is now his primary interface rather than a secondary tool. He uses Cursor only for quick completions and tab suggestions, reserving Claude Code for substantial coding tasks.

## Notable Features

- **GitHub Integration**: The `/install-github-app` command enables automatic PR reviews. Customize the review prompt to focus on bugs and security issues rather than style concerns.

- **Terminal UI Advantages**: Despite initial skepticism, the terminal interface provides effective @-tagging, slash commands, and precise context control.

## Technical Quirks

Key shortcuts and behaviors:
- Use Control+V (not Command+V) for image pasting
- Press Escape (not Control+C) to stop Claude
- Press Escape twice to access previous message history
- Shift+drag files to reference them properly

## Performance on Large Codebases

Claude Code excels where competitors struggle. Sewell describes successfully updating an 18,000-line React component—a task previous AI agents couldn't accomplish. Claude demonstrates superior pattern recognition and codebase navigation across complex projects.

## Cost-Benefit Analysis

At $100/month for maximum access, Sewell argues this represents direct-from-manufacturer pricing compared to resellers like Cursor, offering superior value and model integration since Anthropic controls both the underlying model and the application.
