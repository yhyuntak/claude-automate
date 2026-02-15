---
id: G1
title: Everything Claude Code
author: Affaan
url: https://github.com/affaan-m/everything-claude-code
fetched: 2026-02-15
---

# Everything Claude Code

## README

### Project Summary

**Everything Claude Code** is a comprehensive Claude Code configuration collection from an Anthropic hackathon winner, featuring 42K+ stars and 5K+ forks. It provides production-ready agents, skills, hooks, commands, rules, and MCP configurations developed through 10+ months of intensive daily use building real products.

### Core Components

#### Agents (13 total)
Specialized subagents for delegation including:
- Planner (feature implementation planning)
- Architect (system design decisions)
- TDD Guide (test-driven development)
- Code Reviewer (quality and security review)
- Security Reviewer (vulnerability analysis)
- E2E Runner (Playwright testing)
- Refactor Cleaner (dead code cleanup)
- Language-specific reviewers (Go, Python, Database)

#### Skills (30+ categories)
Workflow definitions and domain knowledge covering:
- Coding standards for multiple languages
- Backend/frontend patterns
- Continuous learning with instinct-based system
- TDD workflow and verification loops
- Language-specific patterns (TypeScript, Python, Go, Java, C++, Rust)
- Framework expertise (Django, Spring Boot)
- Database patterns and migrations
- Docker and deployment patterns
- E2E testing with Playwright

#### Commands (37 total)
Quick-execution slash commands including `/plan`, `/tdd`, `/e2e`, `/code-review`, `/build-fix`, `/refactor-clean`, and language-specific variants.

#### Rules
"Always-follow guidelines" organized by language:
- Common principles (coding style, git workflow, testing, security)
- TypeScript/JavaScript specific
- Python specific
- Go specific

#### Hooks
Trigger-based automations for session lifecycle management, memory persistence, and strategic compaction.

### Key Features

#### Cross-Platform Support
Windows, macOS, and Linux compatibility with automatic package manager detection (npm, pnpm, yarn, bun).

#### Continuous Learning v2
Instinct-based system with confidence scoring that automatically learns patterns:
- `/instinct-status` - View learned patterns
- `/instinct-import` - Import from others
- `/instinct-export` - Share your instincts
- `/evolve` - Cluster instincts into reusable skills

#### AgentShield Security Auditor
"Built at Claude Code Hackathon with 912 tests and 98% coverage" - scans configurations for vulnerabilities, misconfigurations, and injection risks using adversarial red-team/auditor pipeline.

#### Skill Creator
Two options for generating skills:
1. **Local Analysis** - Use `/skill-create` command
2. **GitHub App** - Advanced features for large repositories

### Installation

#### Step 1: Install Plugin
```
/plugin marketplace add affaan-m/everything-claude-code
/plugin install everything-claude-code@everything-claude-code
```

#### Step 2: Install Rules (Required)
```bash
git clone https://github.com/affaan-m/everything-claude-code.git
cd everything-claude-code
./install.sh typescript # or python/golang
```

#### Step 3: Start Using
```
/plan "Add user authentication"
/plugin list everything-claude-code@everything-claude-code
```

### Requirements

- **Claude Code CLI**: v2.1.0 or later
- **Important**: Do not manually add hooks field to plugin.json (auto-loaded by convention)

### Language Support

- TypeScript/JavaScript
- Python (with Django support)
- Go
- Java (Spring Boot)
- C++
- Rust

### Documentation

Two comprehensive guides:
1. **Shortform Guide** - Setup, foundations, philosophy (start here)
2. **Longform Guide** - Token optimization, memory persistence, evals, parallelization

Topics covered: token optimization, memory persistence, continuous learning, verification loops, parallelization, and subagent orchestration.

### Latest Updates (v1.4.1 - Feb 2026)

- Fixed instinct import content loss bug
- Interactive installation wizard (`configure-ecc`)
- PM2 and multi-agent orchestration (6 new commands)
- Multi-language rules architecture
- Chinese (zh-CN) translations
- GitHub Sponsors support

### Ecosystem Tools

- **Skill Creator**: Generate skills from git history
- **AgentShield**: Security auditor with three-agent pipeline
- **ecc.tools**: Advanced skill generation platform

### Contribution

The project welcomes contributions with enhanced CONTRIBUTING.md featuring detailed PR templates for each contribution type.

### License

MIT License

---

## Repository Structure

```
.claude-plugin/PLUGIN_SCHEMA_NOTES.md
.claude-plugin/README.md
.claude-plugin/marketplace.json
.claude-plugin/plugin.json
.claude/package-manager.json
.cursor/MIGRATION.md
.cursor/README.md
.cursor/agents/architect.md
.cursor/agents/build-error-resolver.md
.cursor/agents/code-reviewer.md
.cursor/agents/database-reviewer.md
.cursor/agents/doc-updater.md
.cursor/agents/e2e-runner.md
.cursor/agents/go-build-resolver.md
.cursor/agents/go-reviewer.md
.cursor/agents/planner.md
.cursor/agents/python-reviewer.md
.cursor/agents/refactor-cleaner.md
.cursor/agents/security-reviewer.md
.cursor/agents/tdd-guide.md
.cursor/commands/build-fix.md
.cursor/commands/checkpoint.md
.cursor/commands/code-review.md
.cursor/commands/e2e.md
.cursor/commands/eval.md
.cursor/commands/evolve.md
.cursor/commands/go-build.md
.cursor/commands/go-review.md
.cursor/commands/go-test.md
.cursor/commands/instinct-export.md
.cursor/commands/instinct-import.md
.cursor/commands/instinct-status.md
.cursor/commands/learn.md
.cursor/commands/multi-backend.md
.cursor/commands/multi-execute.md
.cursor/commands/multi-frontend.md
.cursor/commands/multi-plan.md
.cursor/commands/multi-workflow.md
.cursor/commands/orchestrate.md
.cursor/commands/plan.md
.cursor/commands/pm2.md
.cursor/commands/python-review.md
.cursor/commands/refactor-clean.md
.cursor/commands/sessions.md
.cursor/commands/setup-pm.md
.cursor/commands/skill-create.md
.cursor/commands/tdd.md
.cursor/commands/test-coverage.md
.cursor/commands/update-codemaps.md
.cursor/commands/update-docs.md
.cursor/commands/verify.md
.cursor/mcp.json
.cursor/rules/common-agents.md
.cursor/rules/common-coding-style.md
.cursor/rules/common-git-workflow.md
.cursor/rules/common-hooks.md
.cursor/rules/common-patterns.md
.cursor/rules/common-performance.md
.cursor/rules/common-security.md
.cursor/rules/common-testing.md
.cursor/rules/context-dev.md
.cursor/rules/context-research.md
.cursor/rules/context-review.md
.cursor/rules/golang-coding-style.md
.cursor/rules/golang-hooks.md
.cursor/rules/golang-patterns.md
.cursor/rules/golang-security.md
.cursor/rules/golang-testing.md
.cursor/rules/hooks-guidance.md
.cursor/rules/python-coding-style.md
.cursor/rules/python-hooks.md
.cursor/rules/python-patterns.md
.cursor/rules/python-security.md
.cursor/rules/python-testing.md
.cursor/rules/typescript-coding-style.md
.cursor/rules/typescript-hooks.md
.cursor/rules/typescript-patterns.md
.cursor/rules/typescript-security.md
.cursor/rules/typescript-testing.md
.cursor/skills/backend-patterns/SKILL.md
.cursor/skills/clickhouse-io/SKILL.md
.cursor/skills/coding-standards/SKILL.md
.cursor/skills/configure-ecc/SKILL.md
.cursor/skills/continuous-learning-v2/SKILL.md
.cursor/skills/continuous-learning-v2/agents/observer.md
.cursor/skills/continuous-learning-v2/config.json
.cursor/skills/continuous-learning-v2/hooks/observe.sh
.cursor/skills/continuous-learning-v2/scripts/instinct-cli.py
.cursor/skills/continuous-learning-v2/scripts/test_parse_instinct.py
.cursor/skills/continuous-learning/SKILL.md
.cursor/skills/continuous-learning/config.json
.cursor/skills/continuous-learning/evaluate-session.sh
.cursor/skills/cpp-testing/SKILL.md
.cursor/skills/django-patterns/SKILL.md
.cursor/skills/django-security/SKILL.md
.cursor/skills/django-tdd/SKILL.md
.cursor/skills/django-verification/SKILL.md
.cursor/skills/eval-harness/SKILL.md
.cursor/skills/frontend-patterns/SKILL.md
.cursor/skills/golang-patterns/SKILL.md
.cursor/skills/golang-testing/SKILL.md
.cursor/skills/iterative-retrieval/SKILL.md
.cursor/skills/java-coding-standards/SKILL.md
.cursor/skills/jpa-patterns/SKILL.md
.cursor/skills/nutrient-document-processing/SKILL.md
.cursor/skills/postgres-patterns/SKILL.md
.cursor/skills/project-guidelines-example/SKILL.md
.cursor/skills/python-patterns/SKILL.md
.cursor/skills/python-testing/SKILL.md
.cursor/skills/security-review/SKILL.md
.cursor/skills/security-review/cloud-infrastructure-security.md
.cursor/skills/security-scan/SKILL.md
.cursor/skills/springboot-patterns/SKILL.md
.cursor/skills/springboot-security/SKILL.md
.cursor/skills/springboot-tdd/SKILL.md
.cursor/skills/springboot-verification/SKILL.md
.cursor/skills/strategic-compact/SKILL.md
.cursor/skills/strategic-compact/suggest-compact.js
.cursor/skills/strategic-compact/suggest-compact.sh
.cursor/skills/tdd-workflow/SKILL.md
.cursor/skills/verification-loop/SKILL.md
.github/FUNDING.yml
.github/PULL_REQUEST_TEMPLATE.md
.github/workflows/ci.yml
.github/workflows/maintenance.yml
.github/workflows/release.yml
.github/workflows/reusable-release.yml
.github/workflows/reusable-test.yml
.github/workflows/reusable-validate.yml
.github/workflows/security-scan.yml
.gitignore
.markdownlint.json
.npmignore
.opencode/MIGRATION.md
.opencode/README.md
.opencode/commands/build-fix.md
.opencode/commands/checkpoint.md
.opencode/commands/code-review.md
.opencode/commands/e2e.md
.opencode/commands/eval.md
.opencode/commands/evolve.md
.opencode/commands/go-build.md
.opencode/commands/go-review.md
.opencode/commands/go-test.md
.opencode/commands/instinct-export.md
.opencode/commands/instinct-import.md
.opencode/commands/instinct-status.md
.opencode/commands/learn.md
.opencode/commands/orchestrate.md
.opencode/commands/plan.md
.opencode/commands/refactor-clean.md
.opencode/commands/security.md
.opencode/commands/setup-pm.md
.opencode/commands/skill-create.md
.opencode/commands/tdd.md
.opencode/commands/test-coverage.md
.opencode/commands/update-codemaps.md
.opencode/commands/update-docs.md
.opencode/commands/verify.md
.opencode/index.ts
.opencode/instructions/INSTRUCTIONS.md
.opencode/opencode.json
.opencode/package-lock.json
.opencode/package.json
.opencode/plugins/ecc-hooks.ts
.opencode/plugins/index.ts
.opencode/prompts/agents/architect.txt
.opencode/prompts/agents/build-error-resolver.txt
.opencode/prompts/agents/code-reviewer.txt
.opencode/prompts/agents/database-reviewer.txt
.opencode/prompts/agents/doc-updater.txt
.opencode/prompts/agents/e2e-runner.txt
.opencode/prompts/agents/go-build-resolver.txt
.opencode/prompts/agents/go-reviewer.txt
.opencode/prompts/agents/planner.txt
.opencode/prompts/agents/refactor-cleaner.txt
.opencode/prompts/agents/security-reviewer.txt
.opencode/prompts/agents/tdd-guide.txt
.opencode/tools/check-coverage.ts
.opencode/tools/index.ts
.opencode/tools/run-tests.ts
.opencode/tools/security-audit.ts
.opencode/tsconfig.json
CONTRIBUTING.md
LICENSE
README.md
README.zh-CN.md
SPONSORS.md
agents/architect.md
agents/build-error-resolver.md
agents/code-reviewer.md
agents/database-reviewer.md
agents/doc-updater.md
agents/e2e-runner.md
agents/go-build-resolver.md
agents/go-reviewer.md
agents/planner.md
agents/python-reviewer.md
agents/refactor-cleaner.md
agents/security-reviewer.md
agents/tdd-guide.md
commands/build-fix.md
commands/checkpoint.md
commands/code-review.md
commands/e2e.md
commands/eval.md
commands/evolve.md
commands/go-build.md
commands/go-review.md
commands/go-test.md
commands/instinct-export.md
commands/instinct-import.md
commands/instinct-status.md
commands/learn.md
commands/multi-backend.md
commands/multi-execute.md
commands/multi-frontend.md
commands/multi-plan.md
commands/multi-workflow.md
commands/orchestrate.md
commands/plan.md
commands/pm2.md
commands/python-review.md
commands/refactor-clean.md
commands/sessions.md
commands/setup-pm.md
commands/skill-create.md
commands/tdd.md
commands/test-coverage.md
commands/update-codemaps.md
commands/update-docs.md
commands/verify.md
commitlint.config.js
contexts/dev.md
contexts/research.md
contexts/review.md
docs/token-optimization.md
docs/ja-JP/...
docs/zh-CN/...
docs/zh-TW/...
examples/CLAUDE.md
examples/django-api-CLAUDE.md
examples/go-microservice-CLAUDE.md
examples/rust-api-CLAUDE.md
examples/saas-nextjs-CLAUDE.md
examples/sessions/...
examples/statusline.json
examples/user-CLAUDE.md
hooks/README.md
hooks/hooks.json
install.sh
mcp-configs/mcp-servers.json
package-lock.json
package.json
plugins/README.md
rules/README.md
rules/common/...
rules/golang/...
rules/python/...
rules/typescript/...
schemas/hooks.schema.json
schemas/package-manager.schema.json
schemas/plugin.schema.json
scripts/ci/...
scripts/hooks/...
scripts/lib/...
scripts/release.sh
scripts/setup-package-manager.js
scripts/skill-create-output.js
skills/api-design/SKILL.md
skills/backend-patterns/SKILL.md
skills/clickhouse-io/SKILL.md
skills/coding-standards/SKILL.md
skills/configure-ecc/SKILL.md
skills/continuous-learning-v2/SKILL.md
skills/continuous-learning/SKILL.md
skills/cpp-testing/SKILL.md
skills/database-migrations/SKILL.md
skills/deployment-patterns/SKILL.md
skills/django-patterns/SKILL.md
skills/django-security/SKILL.md
skills/django-tdd/SKILL.md
skills/django-verification/SKILL.md
skills/docker-patterns/SKILL.md
skills/e2e-testing/SKILL.md
skills/eval-harness/SKILL.md
skills/frontend-patterns/SKILL.md
skills/golang-patterns/SKILL.md
skills/golang-testing/SKILL.md
skills/iterative-retrieval/SKILL.md
skills/java-coding-standards/SKILL.md
skills/jpa-patterns/SKILL.md
skills/nutrient-document-processing/SKILL.md
skills/postgres-patterns/SKILL.md
skills/project-guidelines-example/SKILL.md
skills/python-patterns/SKILL.md
skills/python-testing/SKILL.md
skills/security-review/SKILL.md
skills/security-scan/SKILL.md
skills/springboot-patterns/SKILL.md
skills/springboot-security/SKILL.md
skills/springboot-tdd/SKILL.md
skills/springboot-verification/SKILL.md
skills/strategic-compact/SKILL.md
skills/tdd-workflow/SKILL.md
skills/verification-loop/SKILL.md
tests/ci/validators.test.js
tests/hooks/...
tests/integration/hooks.test.js
tests/lib/...
tests/run-all.js
tests/scripts/...
the-longform-guide.md
the-shortform-guide.md
```

---

## Key Files

### the-shortform-guide.md (Summary)

This comprehensive guide covers the author's 10-month experience using Claude Code after winning an Anthropic hackathon. Here are the core components:

#### Main Organizational Tools

**Skills & Commands** organize workflows through reusable shortcuts stored in `~/.claude/skills/` and `~/.claude/commands/`. Examples include `/refactor-clean` for code cleanup and `/tdd` for testing workflows.

**Hooks** are event-triggered automations that fire on tool use, user input, or completion events. As quoted: "Hooks are trigger-based automations that fire on specific events." They include PreToolUse, PostToolUse, and Stop event types.

**Subagents** delegate focused tasks to separate Claude instances with limited scopes and permissions, working well alongside skills to maintain clean context.

**Rules** in `.claude/rules/` define mandatory practices across security, coding style, testing, and git workflows that Claude follows consistently.

#### External Integrations

**MCPs** (Model Context Protocol) connect Claude to external services like Supabase and GitHub without manual copy-pasting. The critical advice: keep configuration flexible but "disable everything unused" to preserve the 200k context window.

**Plugins** package tools for simpler installation, with LSP plugins providing real-time type checking particularly valuable for frequent terminal users.

#### Practical Optimization Tips

- Use `/fork` for parallel workflows instead of queued messages
- Employ `tmux` for persistent long-running command sessions
- Leverage `mgrep` for superior search capabilities
- Monitor context usage with `/statusline`
- Configure GitHub Actions for automated PR review

#### Editor Recommendation

The author prefers Zed (Rust-based) for its speed and agent panel integration but acknowledges VSCode/Cursor as viable alternatives.

The overarching principle: "don't overcomplicate" configuration while treating context window preservation as essential.

### install.sh (Summary)

This bash script installs coding rules and configurations for either Claude or Cursor IDEs while maintaining directory structure integrity.

#### Key Features

**Target Options:**
The script supports two installation targets via the `--target` flag:
- **Claude (default)**: Installs rules to `~/.claude/rules/`
- **Cursor**: Installs rules, agents, skills, commands, and MCP config to `./.cursor/`

**Usage Pattern:**
```
./install.sh [--target <claude|cursor>] <language> [<language> ...]
```

**Directory Structure Preservation:**
The script emphasizes that "Files with the same name in common/ and <language>/ don't overwrite each other" and "Relative references (e.g. ../common/coding-style.md) remain valid."

#### Installation Process

**For Claude target:**
- Always installs common rules first
- Creates language-specific subdirectories
- Validates language names to prevent path traversal attacks
- Warns users about existing files that may be overwritten

**For Cursor target:**
- Copies flattened rule filenames (like `common-coding-style.md`)
- Installs agents, skills, and commands from source directories
- Includes MCP configuration file if present

**Safety Features:**
The script validates input using regex patterns allowing only "alphanumeric, dash, and underscore" characters in language names, preventing malicious directory navigation attempts.

---

## Notes

- CLAUDE.md file does not exist in this repository (unlike other Claude Code projects)
- The project has extensive multi-language documentation (Japanese, Chinese Simplified, Chinese Traditional)
- Repository includes both .cursor/ and .opencode/ directories for compatibility with different IDEs
- Heavy emphasis on testing with 912 tests for AgentShield and comprehensive test coverage
- Multi-agent orchestration features with PM2 for production deployments
