# Examples & Resources Guide

> 이 가이드는 **한국어(Korean)**와 **영어(English)**로 제공됩니다.
> This guide is provided in **Korean** and **English**.

---

## English Version

### Overview

The `examples/` directory contains practical, copy-paste-ready configurations and templates for implementing claude-automate features in your projects. Each subdirectory demonstrates a specific use case with working examples.

**Contents:**
- **`contexts/`** - Context file structures and session storage templates
- **`hooks/`** - Automation hook scripts and configuration examples
- **`agent-configs/`** - Agent configuration files and setup instructions
- **`sessions/`** - Session management examples and patterns

All examples are production-ready and can be used immediately in your projects.

---

### 1. Context Files (`contexts/`)

Context files manage persistent information between Claude sessions. They follow a structured format for optimal session continuity.

#### What Are Context Files?

Context files store:
- **Session Summary** - What was accomplished in previous sessions
- **Current Work Status** - Incomplete tasks and in-progress items
- **Key Decisions** - Architecture choices and design decisions
- **Next Steps** - Recommended actions for the next session
- **File Changes** - Which files were modified

#### Directory Structure

```
.claude/context/
├── YYYY-MM/
│   ├── YYYY-MM-DD-session-id-1.md    # First session of the day
│   ├── YYYY-MM-DD-session-id-2.md    # Second session of the day
│   └── YYYY-MM-DD-session-id-3.md    # Continuation session
└── [previous months]/
    └── YYYY-MM-DD-*.md
```

**File naming convention:**
- `YYYY-MM-DD` - Date (year-month-day)
- `session-id` - First 5 characters of commit hash or random identifier
- `.md` - Markdown format

#### Installation & Usage

1. **Create context directory structure:**

```bash
mkdir -p .claude/context/$(date +%Y-%m)
```

2. **After each session, run:**

```bash
/wrap
```

This automatically creates a context file like:
```
.claude/context/2026-01/2026-01-25-a1b2c.md
```

3. **Load context at session start:**

```bash
/start-work
```

This automatically loads and displays your previous session context.

#### Context File Template

Create `.claude/context/YYYY-MM/template-context.md`:

```markdown
# Session: [DATE] [TITLE]

## Context
[Brief description of what this session is about]

## Work Summary

### Accomplishments
- [Item 1]
- [Item 2]
- [Item 3]

### Files Changed
- Modified: `src/file1.ts`
- Added: `src/file2.ts`
- Deleted: `src/file3.ts`

## Current State

### In Progress
- [ ] Task 1 - [Description]
- [ ] Task 2 - [Description]

### Completed
- [x] Task A - [Description]
- [x] Task B - [Description]

## Problems & Solutions

**Problem**: [Issue encountered]
- Solution: [How it was resolved]
- Result: [Outcome]

## Key Decisions

1. **Decision**: [What was decided]
   - Rationale: [Why this choice]
   - Impact: [Consequences]

## Incomplete/TODO

- [ ] [Next action]
- [ ] [Future work]
- [ ] [To investigate]

## Next Session Suggestions

### High Priority
1. [Critical next step]
2. [Important task]

### Medium Priority
3. [Regular task]
4. [Enhancement]

## Session Metrics

- **Duration**: ~[time] minutes
- **Files changed**: [number]
- **Issues found**: [number]
- **Completion rate**: [percentage]
```

#### Best Practices

- **Be specific**: Use concrete details, not vague descriptions
- **Include metrics**: Session duration, lines changed, tests passed
- **Document problems**: Always record issues and solutions for future reference
- **Use checklists**: Check off completed items to track progress
- **Link files**: Reference specific file paths for quick navigation
- **Session frequency**: Create a new context file for each major session (every 1-4 hours)

---

### 2. Hook Scripts (`hooks/`)

Hooks are automation scripts that trigger at specific points in your workflow.

#### Hook Types

**Session Hooks:**
- `Stop` - Runs when ending a Claude session
- `Start` - Runs when starting a new session

**Development Hooks:**
- `PreCommit` - Runs before git commit
- `PostCommit` - Runs after git commit

**Custom Hooks:**
- Create your own triggers for project-specific automation

#### Hook Configuration File

Create `.claude/hooks/hooks.json`:

```json
{
  "description": "Project automation hooks",
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-stop.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "Start": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

**Configuration fields:**
- `description` - What these hooks do
- `hooks` - Object mapping hook types to configurations
- `matcher` - File pattern (`*` matches all files)
- `type` - Either `command` (shell script) or `webhook`
- `command` - Path to shell script (supports `${CLAUDE_PLUGIN_ROOT}`)
- `timeout` - Maximum seconds to wait (5-30 recommended)

#### Installation Steps

1. **Create hooks directory:**

```bash
mkdir -p .claude/hooks
```

2. **Copy hooks.json:**

```bash
cp docs/longform-guide/examples/hooks/hooks.json .claude/hooks/
```

3. **Create hook scripts in `hooks/` directory** (project root):

```bash
mkdir -p hooks
```

4. **Add scripts** (see examples below)

5. **Make scripts executable:**

```bash
chmod +x hooks/*.sh
```

6. **Test hooks** (optional):

```bash
bash hooks/session-stop.sh
```

#### Example Hook Scripts

**Session Stop Reminder** (`hooks/session-stop.sh`):

```bash
#!/bin/bash

# Reminds user to run /wrap before ending session

MESSAGE="[SESSION END REMINDER]

Consider running /wrap to:
• Check code patterns
• Sync documentation
• Update session context

Type '/wrap' to proceed."

ESCAPED=$(echo "$MESSAGE" | jq -Rs '.')
echo "{\"continue\": true, \"message\": $ESCAPED}"
```

**Session Start Hook** (`hooks/session-start.sh`):

```bash
#!/bin/bash

# Display session start message and check status

MESSAGE="[SESSION START]

Getting ready...
• Loading previous context
• Checking git status
• Preparing work environment"

ESCAPED=$(echo "$MESSAGE" | jq -Rs '.')
echo "{\"continue\": true, \"message\": $ESCAPED}"
```

**Custom Pattern Checker** (`hooks/custom-pattern.sh`):

```bash
#!/bin/bash

# Custom project-specific pattern validation

if grep -r "console.log" src/ 2>/dev/null | grep -v test; then
  echo "{\"continue\": false, \"message\": \"Error: console.log found in production code\"}"
  exit 1
fi

echo "{\"continue\": true, \"message\": \"✓ Pattern check passed\"}"
```

#### Hook Output Format

All hooks must return JSON:

```json
{
  "continue": true,
  "message": "Your message here"
}
```

- `continue: true` - Allow session to proceed
- `continue: false` - Stop and show error

---

### 3. Agent Configurations (`agent-configs/`)

Agent configurations define how AI agents should behave when executing tasks.

#### What Are Agent Configs?

Agent configs specify:
- **Model tier** - Which Claude model to use (Haiku, Sonnet, Opus)
- **Capabilities** - What the agent can do
- **Constraints** - What the agent cannot do
- **Tools available** - Which tools the agent can access
- **Temperature/parameters** - LLM behavior tuning

#### Configuration Template

Create `agents/pattern-checker-config.md`:

```markdown
# Pattern Checker Agent Configuration

## Identity
- **Name**: pattern-checker
- **Model**: Claude Sonnet
- **Purpose**: Validate code changes against project rules
- **Owner**: Project Lead

## Capabilities
- [ ] Read code files
- [ ] Parse git diffs
- [ ] Compare against rules
- [ ] Generate reports
- [ ] Suggest fixes

## Tools Available
- `Grep` - Search for patterns in files
- `Read` - Read file contents
- `Bash` - Run shell commands

## Constraints
- **Cannot**: Modify code directly
- **Cannot**: Create commits
- **Cannot**: Delete files
- **Can**: Generate recommendations

## Input Format

```json
{
  "files_changed": ["src/app.ts", "src/utils.ts"],
  "rules_file": ".claude/rules/patterns.md",
  "max_issues": 10
}
```

## Output Format

```json
{
  "status": "success|error",
  "issues": [
    {
      "file": "src/app.ts",
      "line": 42,
      "rule": "no-console-log",
      "severity": "warning|error",
      "message": "console.log found in production code",
      "suggestion": "Use logger.info() instead"
    }
  ],
  "summary": "5 issues found"
}
```

## LLM Parameters

- **Model**: Claude Sonnet (medium tier for balanced speed/quality)
- **Temperature**: 0.2 (low for deterministic pattern matching)
- **Max tokens**: 2000 (enough for detailed analysis)
- **Top P**: 0.9 (focused but not overly constrained)

## Activation Rules

Trigger this agent when:
- [ ] Code files are modified
- [ ] PR/MR is opened
- [ ] `/wrap` command is executed

## Error Handling

If agent fails:
1. Log error to `.claude/logs/pattern-checker-error.log`
2. Return error status with message
3. Continue with other agents (don't block)

## Success Criteria

- [ ] All files analyzed
- [ ] All rules checked
- [ ] Report generated
- [ ] No crashes
```

#### Agent Configuration Best Practices

1. **Model Selection:**
   - **Haiku**: Simple pattern matching, data collection
   - **Sonnet**: Analysis, decision-making
   - **Opus**: Complex reasoning, conflict resolution

2. **Tool Assignment:**
   - Give agents only tools they need
   - Limit file access scope when possible
   - Use read-only tools for safety

3. **Error Handling:**
   - Always define what to do on failure
   - Provide fallbacks
   - Log errors for debugging

4. **Performance:**
   - Set appropriate timeouts
   - Use temperature 0-0.3 for deterministic tasks
   - Use temperature 0.7+ for creative tasks

---

### 4. Session Management (`sessions/`)

Session files track ongoing work across multiple interaction sessions.

#### Session File Structure

Create `.claude/context/2026-01/2026-01-25-session.md`:

```markdown
# Session: 2026-01-25 [Project Work]

## Status Indicators
- **Session Status**: Active / Paused / Complete
- **Start Time**: 2026-01-25 10:00 UTC
- **Est. Duration**: 2-3 hours
- **Goal**: [What this session aims to accomplish]

## Current Task

### Active Task
- **Title**: [Current focus]
- **Estimated completion**: [time/percentage]
- **Blockers**: [Any issues preventing progress]
- **Related files**: [Files being modified]

### Task Progress

```
████████░░ 80% [Describe what's done]
```

## Context

### Session Goals
1. Goal 1 - [Description]
2. Goal 2 - [Description]
3. Goal 3 - [Description]

### Work Log (Reverse Chronological)

**10:45** - Completed feature X implementation
- Files: `src/feature-x.ts`, `tests/feature-x.test.ts`
- Status: Ready for review
- Next: Documentation update

**10:30** - Fixed bug in Y module
- Issue: [Description]
- Solution: [What was changed]
- Files: `src/module-y.ts`

**10:00** - Session start
- Loaded previous context
- Reviewed backlog
- Selected tasks

## Files Modified This Session

| File | Type | Status | Notes |
|------|------|--------|-------|
| `src/app.ts` | Modified | Complete | Updated routing logic |
| `src/utils.ts` | Added | In Progress | Helper functions |
| `tests/app.test.ts` | Modified | Complete | Updated tests |

## Decisions Made

1. **Decision**: [What was decided]
   - **Rationale**: [Why]
   - **Impact**: [Consequences]
   - **Alternatives considered**: [Other options]

## Problems Encountered

| Problem | Severity | Status | Solution |
|---------|----------|--------|----------|
| Build error in TypeScript | High | Resolved | Updated tsconfig.json |
| Test failure | Medium | In Progress | Debugging test isolation |
| Performance issue | Low | Pending | Will investigate next session |

## Next Steps

### Before Ending This Session
- [ ] Run test suite
- [ ] Commit changes
- [ ] Update documentation
- [ ] Run `/wrap` command

### For Next Session
1. Continue implementing feature Y
2. Write integration tests
3. Get code review
4. Deploy to staging

## Session Notes

### Key Learnings
- [Something you learned]
- [Important discovery]
- [Useful technique]

### Resources Used
- [Documentation link]
- [Stack Overflow answer]
- [GitHub reference]

### Time Spent by Activity
- Coding: 60 minutes
- Testing: 20 minutes
- Debugging: 15 minutes
- Documentation: 10 minutes
- Break: 15 minutes
- **Total**: 2 hours
```

#### Session Best Practices

- **Update frequently**: Log changes every 15-30 minutes
- **Be descriptive**: Include context for future reference
- **Track decisions**: Note why choices were made
- **Record problems**: Document issues and solutions
- **Estimate time**: Help plan future sessions
- **Link references**: Include documentation/resource links

---

### System Prompt Integration

#### Using Context Files with `--system-prompt`

Context files can be included in Claude's system prompt for better continuity.

**Basic integration:**

```bash
claude-code --system-prompt "$(cat .claude/context/current-session.md)"
```

**With template:**

```bash
# Load last session context
LAST_SESSION=$(ls -t .claude/context/*/2026-01-*.md | head -1)
claude-code --system-prompt "$(cat "$LAST_SESSION")"
```

**With multiple contexts:**

```bash
# Combine context files
{
  echo "# System Context"
  echo ""
  cat .claude/rules/patterns.md
  echo ""
  echo "# Previous Session"
  cat .claude/context/$(date +%Y-%m)/$(ls .claude/context/$(date +%Y-%m) | tail -1)
} | claude-code --system-prompt -
```

#### Example Workflow Script

Create `bin/start-session.sh`:

```bash
#!/bin/bash

PROJECT_ROOT=$(git rev-parse --show-toplevel)
CONTEXT_DIR="$PROJECT_ROOT/.claude/context/$(date +%Y-%m)"

# Create context directory if needed
mkdir -p "$CONTEXT_DIR"

# Get most recent session
LAST_SESSION=$(ls -t "$CONTEXT_DIR"/*.md 2>/dev/null | head -1)

if [ -f "$LAST_SESSION" ]; then
  echo "Loading previous session context from: $LAST_SESSION"
  SYSTEM_PROMPT=$(cat "$LAST_SESSION")
else
  echo "No previous session found, starting fresh"
  SYSTEM_PROMPT="# New Development Session"
fi

# Export for claude-code
export CLAUDE_SYSTEM_CONTEXT="$SYSTEM_PROMPT"

echo "Session ready. Running claude-code..."
# Your claude-code invocation here
```

**Usage:**

```bash
chmod +x bin/start-session.sh
./bin/start-session.sh
```

---

## Quick Start Checklist

**Getting started with examples:**

- [ ] Copy `.claude/context/` template to your project
- [ ] Set up hooks with `hooks.json`
- [ ] Create your first context file
- [ ] Run `/wrap` to generate session context
- [ ] Use `/start-work` to load context next session
- [ ] Review agent configurations for your project
- [ ] Test hooks with manual execution

---

## File Paths Reference

All paths are relative to project root:

```
project-root/
├── .claude/
│   ├── context/          ← Session storage (auto-generated)
│   │   └── YYYY-MM/
│   ├── hooks/            ← Hook configuration
│   │   └── hooks.json
│   └── rules/            ← Project rules
├── hooks/                ← Hook scripts
│   ├── session-stop.sh
│   └── session-start.sh
├── agents/               ← Agent configurations
│   ├── pattern-checker-config.md
│   └── doc-checker-config.md
└── docs/
    └── longform-guide/
        └── examples/     ← This directory
```

---

## Troubleshooting

**Context not loading?**
- Check `.claude/context/` directory exists
- Verify file naming format: `YYYY-MM-DD-*.md`
- Ensure read permissions on context files

**Hooks not triggering?**
- Verify `hooks.json` is in `.claude/hooks/`
- Check script paths are absolute or use `${CLAUDE_PLUGIN_ROOT}`
- Make scripts executable: `chmod +x hooks/*.sh`
- Test manually: `bash hooks/hook-name.sh`

**Agent not working?**
- Verify agent config file exists
- Check input JSON format matches specification
- Review error logs: `.claude/logs/`
- Ensure required tools are available

---

## Next Steps

1. **Set up your first context file** - Copy template to `.claude/context/`
2. **Configure hooks** - Create `hooks.json` and hook scripts
3. **Define agents** - Copy agent config templates
4. **Run your first `/wrap`** - Generate automatic session context
5. **Start next session** - Use `/start-work` to load context

For detailed guides on each component, see:
- Context management: `docs/longform-guide/01-context-memory/01-session-storage.md`
- Hooks & persistence: `docs/longform-guide/01-context-memory/05-memory-persistence-hooks.md`
- Agent architecture: `docs/longform-guide/06-agent-best-practices/README.md`

---

---

## Korean Version (한국어 버전)

### 개요

`examples/` 디렉토리는 claude-automate 기능을 프로젝트에 구현하기 위한 실용적이고 바로 복사해서 사용할 수 있는 설정과 템플릿을 포함합니다. 각 서브디렉토리는 특정 사용 사례를 실제 예제와 함께 보여줍니다.

**포함 내용:**
- **`contexts/`** - Context 파일 구조 및 세션 저장소 템플릿
- **`hooks/`** - 자동화 hook 스크립트 및 설정 예제
- **`agent-configs/`** - Agent 설정 파일 및 설정 지침
- **`sessions/`** - 세션 관리 예제 및 패턴

모든 예제는 프로덕션 준비가 완료되어 있으며 프로젝트에서 즉시 사용할 수 있습니다.

---

### 1. Context 파일 (`contexts/`)

Context 파일은 Claude 세션 간에 지속되는 정보를 관리합니다. 최적의 세션 연속성을 위해 구조화된 형식을 따릅니다.

#### Context 파일이란?

Context 파일에는 다음이 저장됩니다:
- **세션 요약** - 이전 세션에서 달성한 내용
- **현재 작업 상태** - 미완료 작업 및 진행 중인 항목
- **주요 결정** - 아키텍처 선택 및 설계 결정
- **다음 단계** - 다음 세션을 위한 권장 조치
- **파일 변경사항** - 수정된 파일 목록

#### 디렉토리 구조

```
.claude/context/
├── YYYY-MM/
│   ├── YYYY-MM-DD-session-id-1.md    # 이날의 첫 번째 세션
│   ├── YYYY-MM-DD-session-id-2.md    # 이날의 두 번째 세션
│   └── YYYY-MM-DD-session-id-3.md    # 연속 세션
└── [previous months]/
    └── YYYY-MM-DD-*.md
```

**파일 명명 규칙:**
- `YYYY-MM-DD` - 날짜 (연-월-일)
- `session-id` - 커밋 해시의 첫 5글자 또는 임의 식별자
- `.md` - 마크다운 형식

#### 설치 및 사용

1. **Context 디렉토리 구조 생성:**

```bash
mkdir -p .claude/context/$(date +%Y-%m)
```

2. **각 세션 후 실행:**

```bash
/wrap
```

이것은 자동으로 다음과 같은 context 파일을 생성합니다:
```
.claude/context/2026-01/2026-01-25-a1b2c.md
```

3. **세션 시작 시 context 로드:**

```bash
/start-work
```

이는 자동으로 이전 세션 context를 로드하고 표시합니다.

#### Context 파일 템플릿

`.claude/context/YYYY-MM/template-context.md` 생성:

```markdown
# Session: [날짜] [제목]

## 배경

[이 세션이 무엇에 관한 것인지 간단한 설명]

## 작업 요약

### 완료 사항
- [항목 1]
- [항목 2]
- [항목 3]

### 파일 변경사항
- 수정: `src/file1.ts`
- 추가: `src/file2.ts`
- 삭제: `src/file3.ts`

## 현재 상태

### 진행 중
- [ ] 작업 1 - [설명]
- [ ] 작업 2 - [설명]

### 완료됨
- [x] 작업 A - [설명]
- [x] 작업 B - [설명]

## 문제 및 해결책

**문제**: [발생한 문제]
- 해결책: [어떻게 해결했는지]
- 결과: [결과]

## 주요 결정

1. **결정**: [무엇이 결정되었는지]
   - 이유: [왜 이 선택을 했는지]
   - 영향: [결과]

## 미완료/TODO

- [ ] [다음 작업]
- [ ] [향후 작업]
- [ ] [조사할 항목]

## 다음 세션 추천사항

### 높은 우선순위
1. [중요한 다음 단계]
2. [중요한 작업]

### 중간 우선순위
3. [일반 작업]
4. [개선사항]

## 세션 지표

- **기간**: ~[시간] 분
- **변경 파일**: [개수]
- **발견 문제**: [개수]
- **완료율**: [백분율]
```

#### 최적 사례

- **구체적으로**: 모호한 설명 대신 구체적인 세부사항 사용
- **지표 포함**: 세션 기간, 변경 라인 수, 통과한 테스트
- **문제 문서화**: 항상 문제와 해결책을 기록하여 향후 참고
- **체크리스트 사용**: 완료된 항목을 확인하여 진행 상황 추적
- **파일 링크**: 빠른 탐색을 위해 구체적인 파일 경로 참조
- **세션 빈도**: 각 주요 세션마다 새 context 파일 생성 (1-4시간마다)

---

### 2. Hook 스크립트 (`hooks/`)

Hook은 워크플로우의 특정 지점에서 트리거되는 자동화 스크립트입니다.

#### Hook 유형

**세션 Hook:**
- `Stop` - Claude 세션을 종료할 때 실행
- `Start` - 새 세션을 시작할 때 실행

**개발 Hook:**
- `PreCommit` - git commit 전에 실행
- `PostCommit` - git commit 후에 실행

**사용자 정의 Hook:**
- 프로젝트별 자동화를 위한 고유 트리거 생성

#### Hook 설정 파일

`.claude/hooks/hooks.json` 생성:

```json
{
  "description": "프로젝트 자동화 hook",
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-stop.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "Start": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-start.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

**설정 필드:**
- `description` - Hook이 하는 것
- `hooks` - Hook 유형을 설정에 매핑하는 객체
- `matcher` - 파일 패턴 (`*`은 모든 파일 일치)
- `type` - `command` (셸 스크립트) 또는 `webhook`
- `command` - 셸 스크립트 경로 (`${CLAUDE_PLUGIN_ROOT}` 지원)
- `timeout` - 최대 대기 시간 (5-30초 권장)

#### 설치 단계

1. **Hook 디렉토리 생성:**

```bash
mkdir -p .claude/hooks
```

2. **hooks.json 복사:**

```bash
cp docs/longform-guide/examples/hooks/hooks.json .claude/hooks/
```

3. **hook 스크립트를 `hooks/` 디렉토리에 생성** (프로젝트 루트):

```bash
mkdir -p hooks
```

4. **스크립트 추가** (아래 예제 참조)

5. **스크립트 실행 가능하게 만들기:**

```bash
chmod +x hooks/*.sh
```

6. **Hook 테스트** (선택사항):

```bash
bash hooks/session-stop.sh
```

#### 예제 Hook 스크립트

**세션 종료 알림** (`hooks/session-stop.sh`):

```bash
#!/bin/bash

# 세션 종료 전에 /wrap 실행 알림

MESSAGE="[세션 종료 알림]

/wrap 실행을 고려하세요:
• 코드 패턴 확인
• 문서 동기화
• 세션 context 업데이트

'/wrap'을 입력하거나 계속 진행하세요."

ESCAPED=$(echo "$MESSAGE" | jq -Rs '.')
echo "{\"continue\": true, \"message\": $ESCAPED}"
```

**세션 시작 Hook** (`hooks/session-start.sh`):

```bash
#!/bin/bash

# 세션 시작 메시지 표시 및 상태 확인

MESSAGE="[세션 시작]

준비 중...
• 이전 context 로드
• Git 상태 확인
• 작업 환경 준비"

ESCAPED=$(echo "$MESSAGE" | jq -Rs '.')
echo "{\"continue\": true, \"message\": $ESCAPED}"
```

**사용자 정의 패턴 체크** (`hooks/custom-pattern.sh`):

```bash
#!/bin/bash

# 프로젝트별 패턴 검증

if grep -r "console.log" src/ 2>/dev/null | grep -v test; then
  echo "{\"continue\": false, \"message\": \"오류: 프로덕션 코드에서 console.log 발견\"}"
  exit 1
fi

echo "{\"continue\": true, \"message\": \"✓ 패턴 확인 통과\"}"
```

#### Hook 출력 형식

모든 hook은 JSON을 반환해야 합니다:

```json
{
  "continue": true,
  "message": "메시지"
}
```

- `continue: true` - 세션 계속 진행
- `continue: false` - 중지 및 오류 표시

---

### 3. Agent 설정 (`agent-configs/`)

Agent 설정은 작업 실행 시 AI agent의 동작을 정의합니다.

#### Agent 설정이란?

Agent 설정은 다음을 지정합니다:
- **모델 티어** - 사용할 Claude 모델 (Haiku, Sonnet, Opus)
- **능력** - Agent가 할 수 있는 것
- **제약** - Agent가 할 수 없는 것
- **사용 가능한 도구** - Agent가 접근할 수 있는 도구
- **온도/매개변수** - LLM 동작 튜닝

#### 설정 템플릿

`agents/pattern-checker-config.md` 생성:

```markdown
# Pattern Checker Agent 설정

## 신원
- **이름**: pattern-checker
- **모델**: Claude Sonnet
- **목적**: 코드 변경사항이 프로젝트 규칙을 따르는지 검증
- **담당자**: 프로젝트 리더

## 능력
- [ ] 코드 파일 읽기
- [ ] Git diff 분석
- [ ] 규칙과 비교
- [ ] 보고서 생성
- [ ] 수정 제안

## 사용 가능 도구
- `Grep` - 파일에서 패턴 검색
- `Read` - 파일 내용 읽기
- `Bash` - 셸 명령 실행

## 제약사항
- **불가**: 코드 직접 수정
- **불가**: 커밋 생성
- **불가**: 파일 삭제
- **가능**: 권장사항 생성

## 입력 형식

```json
{
  "files_changed": ["src/app.ts", "src/utils.ts"],
  "rules_file": ".claude/rules/patterns.md",
  "max_issues": 10
}
```

## 출력 형식

```json
{
  "status": "success|error",
  "issues": [
    {
      "file": "src/app.ts",
      "line": 42,
      "rule": "no-console-log",
      "severity": "warning|error",
      "message": "프로덕션 코드에서 console.log 발견",
      "suggestion": "대신 logger.info() 사용"
    }
  ],
  "summary": "5개 문제 발견"
}
```

## LLM 매개변수

- **모델**: Claude Sonnet (속도/품질 균형)
- **온도**: 0.2 (패턴 매칭을 위한 낮은 값)
- **최대 토큰**: 2000 (상세 분석에 충분)
- **Top P**: 0.9 (초점을 맞추되 과도하지 않음)

## 활성화 규칙

다음과 같을 때 이 agent 트리거:
- [ ] 코드 파일 수정됨
- [ ] PR/MR 열림
- [ ] `/wrap` 명령 실행

## 오류 처리

Agent 실패 시:
1. 오류를 `.claude/logs/pattern-checker-error.log`에 로깅
2. 오류 상태 및 메시지 반환
3. 다른 agent와 계속 진행 (차단하지 않음)

## 성공 기준

- [ ] 모든 파일 분석됨
- [ ] 모든 규칙 확인됨
- [ ] 보고서 생성됨
- [ ] 충돌 없음
```

#### Agent 설정 최적 사례

1. **모델 선택:**
   - **Haiku**: 단순 패턴 매칭, 데이터 수집
   - **Sonnet**: 분석, 의사결정
   - **Opus**: 복잡한 추론, 충돌 해결

2. **도구 할당:**
   - Agent에 필요한 도구만 제공
   - 가능한 한 파일 접근 범위 제한
   - 안전성을 위해 읽기 전용 도구 사용

3. **오류 처리:**
   - 항상 실패 시 조치 정의
   - 대체 방안 제공
   - 디버깅을 위해 오류 로깅

4. **성능:**
   - 적절한 타임아웃 설정
   - 결정론적 작업에는 온도 0-0.3 사용
   - 창의적 작업에는 온도 0.7+ 사용

---

### 4. 세션 관리 (`sessions/`)

세션 파일은 여러 상호작용 세션에 걸쳐 진행 중인 작업을 추적합니다.

#### 세션 파일 구조

`.claude/context/2026-01/2026-01-25-session.md` 생성:

```markdown
# Session: 2026-01-25 [프로젝트 작업]

## 상태 표시
- **세션 상태**: 활성 / 일시 중지 / 완료
- **시작 시간**: 2026-01-25 10:00 UTC
- **예상 기간**: 2-3시간
- **목표**: [이 세션이 달성하려는 것]

## 현재 작업

### 활성 작업
- **제목**: [현재 초점]
- **예상 완료**: [시간/백분율]
- **차단 요소**: [진행을 방해하는 문제]
- **관련 파일**: [수정 중인 파일]

### 작업 진행률

```
████████░░ 80% [완료된 것 설명]
```

## 배경

### 세션 목표
1. 목표 1 - [설명]
2. 목표 2 - [설명]
3. 목표 3 - [설명]

### 작업 로그 (최신 순)

**10:45** - 기능 X 구현 완료
- 파일: `src/feature-x.ts`, `tests/feature-x.test.ts`
- 상태: 검토 준비
- 다음: 문서 업데이트

**10:30** - Y 모듈 버그 수정
- 문제: [설명]
- 해결책: [변경 사항]
- 파일: `src/module-y.ts`

**10:00** - 세션 시작
- 이전 context 로드
- 백로그 검토
- 작업 선택

## 이번 세션에서 수정된 파일

| 파일 | 유형 | 상태 | 비고 |
|------|------|------|------|
| `src/app.ts` | 수정됨 | 완료 | 라우팅 로직 업데이트 |
| `src/utils.ts` | 추가됨 | 진행 중 | 도우미 함수 |
| `tests/app.test.ts` | 수정됨 | 완료 | 테스트 업데이트 |

## 내린 결정

1. **결정**: [무엇이 결정되었는지]
   - **이유**: [왜]
   - **영향**: [결과]
   - **검토한 대안**: [다른 선택지]

## 발생한 문제

| 문제 | 심각도 | 상태 | 해결책 |
|------|--------|------|--------|
| TypeScript 빌드 오류 | 높음 | 해결됨 | tsconfig.json 업데이트 |
| 테스트 실패 | 중간 | 진행 중 | 테스트 격리 디버깅 |
| 성능 문제 | 낮음 | 대기 중 | 다음 세션에 조사 예정 |

## 다음 단계

### 이 세션 종료 전
- [ ] 테스트 스위트 실행
- [ ] 변경사항 커밋
- [ ] 문서 업데이트
- [ ] `/wrap` 명령 실행

### 다음 세션을 위해
1. 기능 Y 구현 계속
2. 통합 테스트 작성
3. 코드 검토 요청
4. 스테이징에 배포

## 세션 노트

### 주요 학습
- [배운 것]
- [중요한 발견]
- [유용한 기법]

### 사용한 자료
- [문서 링크]
- [Stack Overflow 답변]
- [GitHub 참조]

### 활동별 소요 시간
- 코딩: 60분
- 테스트: 20분
- 디버깅: 15분
- 문서: 10분
- 휴식: 15분
- **합계**: 2시간
```

#### 세션 최적 사례

- **자주 업데이트**: 15-30분마다 변경사항 기록
- **구체적으로**: 향후 참고를 위해 문맥 포함
- **결정 추적**: 왜 선택을 했는지 기록
- **문제 기록**: 문제 및 해결책 문서화
- **시간 추정**: 향후 세션 계획에 도움
- **참조 링크**: 문서/자료 링크 포함

---

### 시스템 프롬프트 통합

#### Context 파일을 `--system-prompt`와 함께 사용

Context 파일을 Claude의 시스템 프롬프트에 포함하여 더 나은 연속성을 얻을 수 있습니다.

**기본 통합:**

```bash
claude-code --system-prompt "$(cat .claude/context/current-session.md)"
```

**템플릿 사용:**

```bash
# 마지막 세션 context 로드
LAST_SESSION=$(ls -t .claude/context/*/2026-01-*.md | head -1)
claude-code --system-prompt "$(cat "$LAST_SESSION")"
```

**여러 context 결합:**

```bash
# Context 파일 결합
{
  echo "# 시스템 Context"
  echo ""
  cat .claude/rules/patterns.md
  echo ""
  echo "# 이전 세션"
  cat .claude/context/$(date +%Y-%m)/$(ls .claude/context/$(date +%Y-%m) | tail -1)
} | claude-code --system-prompt -
```

#### 예제 워크플로우 스크립트

`bin/start-session.sh` 생성:

```bash
#!/bin/bash

PROJECT_ROOT=$(git rev-parse --show-toplevel)
CONTEXT_DIR="$PROJECT_ROOT/.claude/context/$(date +%Y-%m)"

# 필요하면 context 디렉토리 생성
mkdir -p "$CONTEXT_DIR"

# 가장 최근 세션 가져오기
LAST_SESSION=$(ls -t "$CONTEXT_DIR"/*.md 2>/dev/null | head -1)

if [ -f "$LAST_SESSION" ]; then
  echo "이전 세션 context 로드: $LAST_SESSION"
  SYSTEM_PROMPT=$(cat "$LAST_SESSION")
else
  echo "이전 세션을 찾을 수 없어 새로 시작합니다"
  SYSTEM_PROMPT="# 새 개발 세션"
fi

# claude-code를 위해 내보내기
export CLAUDE_SYSTEM_CONTEXT="$SYSTEM_PROMPT"

echo "세션 준비 완료. claude-code 실행 중..."
# claude-code 호출
```

**사용:**

```bash
chmod +x bin/start-session.sh
./bin/start-session.sh
```

---

### 빠른 시작 체크리스트

**예제 시작하기:**

- [ ] `.claude/context/` 템플릿을 프로젝트에 복사
- [ ] `hooks.json`으로 Hook 설정
- [ ] 첫 번째 context 파일 생성
- [ ] `/wrap` 실행하여 세션 context 생성
- [ ] 다음 세션에 `/start-work` 사용하여 context 로드
- [ ] 프로젝트용 agent 설정 검토
- [ ] Hook을 수동으로 실행하여 테스트

---

### 파일 경로 참조

모든 경로는 프로젝트 루트 기준입니다:

```
project-root/
├── .claude/
│   ├── context/          ← 세션 저장소 (자동 생성)
│   │   └── YYYY-MM/
│   ├── hooks/            ← Hook 설정
│   │   └── hooks.json
│   └── rules/            ← 프로젝트 규칙
├── hooks/                ← Hook 스크립트
│   ├── session-stop.sh
│   └── session-start.sh
├── agents/               ← Agent 설정
│   ├── pattern-checker-config.md
│   └── doc-checker-config.md
└── docs/
    └── longform-guide/
        └── examples/     ← 이 디렉토리
```

---

### 문제 해결

**Context가 로드되지 않음?**
- `.claude/context/` 디렉토리 존재 여부 확인
- 파일 명명 형식 확인: `YYYY-MM-DD-*.md`
- Context 파일에 대한 읽기 권한 확인

**Hook이 트리거되지 않음?**
- `hooks.json`이 `.claude/hooks/`에 있는지 확인
- 스크립트 경로가 절대 경로이거나 `${CLAUDE_PLUGIN_ROOT}` 사용 확인
- 스크립트 실행 가능하게 만들기: `chmod +x hooks/*.sh`
- 수동 테스트: `bash hooks/hook-name.sh`

**Agent가 작동하지 않음?**
- Agent 설정 파일이 존재하는지 확인
- 입력 JSON 형식이 사양과 일치하는지 확인
- 오류 로그 검토: `.claude/logs/`
- 필요한 도구를 사용할 수 있는지 확인

---

### 다음 단계

1. **첫 번째 context 파일 설정** - `.claude/context/`에 템플릿 복사
2. **Hook 설정** - `hooks.json` 및 hook 스크립트 생성
3. **Agent 정의** - Agent 설정 템플릿 복사
4. **첫 번째 `/wrap` 실행** - 자동 세션 context 생성
5. **다음 세션 시작** - `/start-work` 사용하여 context 로드

각 구성요소에 대한 자세한 가이드는 다음을 참조하세요:
- Context 관리: `docs/longform-guide/01-context-memory/01-session-storage.md`
- Hook 및 영속성: `docs/longform-guide/01-context-memory/05-memory-persistence-hooks.md`
- Agent 아키텍처: `docs/longform-guide/06-agent-best-practices/README.md`

---

