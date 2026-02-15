---
id: P3
title: Code Review (Official Plugin)
author: Anthropic
url: https://github.com/anthropics/claude-code/tree/main/plugins/code-review
fetched: 2026-02-15
---

# Code Review Plugin

## Summary

The Code Review Plugin automates pull request reviews using four parallel agents that independently audit changes. The system scores each issue (0-100) and filters out results below an 80 confidence threshold to minimize false positives.

## Key Components

**Core Function**: The `/code-review` command launches specialized agents to examine code from multiple angles—guideline compliance, bug detection, and historical context analysis.

**Agents Deployed**:
- Two agents verify adherence to CLAUDE.md guidelines
- One agent identifies obvious bugs in modifications
- One agent analyzes git history for context-based concerns

**Confidence Scoring**: Issues receive ratings where "0" indicates low confidence and "100" means absolute certainty. Only findings scoring 80+ appear in final reviews.

## Main Features

- Parallel agent execution for comprehensive coverage
- False positive filtering through confidence thresholds
- Automatic skipping of closed, draft, or previously-reviewed pull requests
- Optional posting as PR comments via `--comment` flag
- Direct code linking with SHA and line ranges

## Usage Pattern

The basic workflow involves running `/code-review` locally to see terminal output, then optionally using `/code-review --comment` to post findings to GitHub. The system automatically filters trivial changes and respects existing reviews.

## Requirements

The plugin requires a Git repository with GitHub integration, the GitHub CLI tool (authenticated), and optionally CLAUDE.md files for enhanced guideline checking.
