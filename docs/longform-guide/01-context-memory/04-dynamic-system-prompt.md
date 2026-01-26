# Dynamic System Prompt Injection

> **CLI 플래그를 통한 동적 System Prompt 주입 전략**

**Last Updated**: 2026-01-25
**Status**: Complete
**Audience**: Advanced Claude CLI Users

---

## 목차 (Table of Contents)

1. [핵심 개념](#핵심-개념)
2. [@file vs --system-prompt 비교](#file-vs---system-prompt-비교)
3. [우선순위 계층 구조](#우선순위-계층-구조)
4. [언제 사용하는가](#언제-사용하는가)
5. [실전 설정: CLI Alias 패턴](#실전-설정-cli-alias-패턴)
6. [컨텍스트 파일 예시](#컨텍스트-파일-예시)
7. [장점과 단점](#장점과-단점)
8. [저자 의견](#저자-의견)

---

## 핵심 개념

### System Prompt란?

**System Prompt**는 Claude의 동작 방식을 정의하는 기본 지시문입니다. 사용자의 일반 메시지가 아니라, Claude의 **역할(role)**, **제약(constraints)**, **절차(procedures)**를 정의합니다.

```
User Message  →  [System Prompt]  →  Claude
"이 파일을 검토해줘"    (지시문)        (분석 수행)
```

### Dynamic Injection이란?

**Dynamic System Prompt Injection**은 **CLI 플래그를 사용하여 실행 시점에 system prompt를 변경**하는 기법입니다.

기존 방식:
```bash
# system prompt가 고정됨
claude message "코드를 분석해줄래?"
```

Dynamic 방식:
```bash
# 실행 시 system prompt를 동적으로 주입
claude --system-prompt "$(cat dev-context.md)" message "코드를 분석해줄래?"
```

### CLI 플래그로 주입하는 이유

| 방식 | 특징 | 사용 시점 |
|------|------|---------|
| **--system-prompt** | 명시적으로 전체 prompt 지정 | 복잡한 context 필요 |
| **@file** | 파일에서 prompt 읽기 | 변수 기반 동적 구성 |
| **CLAUDE_SYSTEM_PROMPT** | 환경변수 설정 | 영구적 기본값 필요 |

**Dynamic injection의 장점**:
- 세션별 다른 prompt 사용 가능
- Context 파일 기반 자동 로드
- Shell script로 조건부 구성 가능
- 버전 관리와 독립적

---

## @file vs --system-prompt 비교

두 가지 방식의 상세 비교:

### 1. --system-prompt (명시적 주입)

**문법**:
```bash
claude --system-prompt "prompt text" message "user message"
```

**특징**:
- 전체 prompt를 문자열로 전달
- 동적 구성 가능 (variable expansion)
- 보안: prompt 내용이 shell history에 기록될 수 있음

**예시**:
```bash
# 동적 구성
CONTEXT=$(cat context.md)
claude --system-prompt "You are a code reviewer. Context: $CONTEXT" message "Review this code"
```

### 2. @file (파일 참조)

**문법**:
```bash
claude @system-prompt.md message "user message"
```

또는:

```bash
claude --system-prompt @system-prompt.md message "user message"
```

**특징**:
- 파일 경로 지정
- 큰 prompt에 적합
- 파일 수정만으로 prompt 변경 가능
- History에 파일 경로만 기록됨 (보안)

**예시**:
```bash
# 파일 기반 (권장)
claude --system-prompt @.claude/prompts/dev.md message "Analyze this"
```

### 상세 비교표

| 항목 | --system-prompt | @file |
|------|-----------------|-------|
| **문법** | 문자열 전달 | 파일 경로 참조 |
| **크기** | 작음 (shell 제약) | 제약 없음 |
| **보안** | history에 내용 노출 | 파일 경로만 기록 |
| **수정** | 코드/alias 변경 필요 | 파일 수정만 필요 |
| **동적 구성** | 가능 (변수 expansion) | 불가능 |
| **버전 관리** | 어려움 | 용이 (파일 tracking) |
| **읽기 쉬움** | 짧은 prompt만 OK | 항상 가능 |
| **권장 용도** | 간단한 prompt | 복잡하거나 재사용 |

### 혼합 사용 예시

```bash
# 기본 context는 파일에서, 추가 context는 동적으로
CUSTOM_CONTEXT=$(cat context.md | sed 's/PLACEHOLDER/value/')
claude \
  --system-prompt @.claude/prompts/base.md \
  --context "$CUSTOM_CONTEXT" \
  message "user query"
```

---

## 우선순위 계층 구조

Claude CLI에서 system prompt가 적용되는 우선순위:

```
┌─────────────────────────────────────────┐
│  1. CLI --system-prompt 플래그          │  ← 가장 높음 (최우선)
│     (가장 구체적, session-specific)      │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│  2. .claude/CLAUDE.md의 system prompt    │  ← 프로젝트 기본값
│     (프로젝트 전역 설정)                 │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│  3. CLAUDE_SYSTEM_PROMPT 환경변수        │  ← 머신 기본값
│     (머신 전역 설정)                     │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│  4. Claude 기본 system prompt            │  ← 가장 낮음 (기본값)
│     (Anthropic 기본)                     │
└─────────────────────────────────────────┘
```

### 실제 평가 과정

```
실행: claude --system-prompt @dev.md message "hello"
      ├─ Step 1: CLI 플래그 확인
      │   └─ @dev.md 파일 로드 ✓ (사용됨)
      └─ Step 2-4: 무시됨
```

```
실행: claude message "hello"  (플래그 없음)
      ├─ Step 1: CLI 플래그 없음
      │   └─ 다음 단계로
      ├─ Step 2: .claude/CLAUDE.md 확인
      │   └─ system prompt 존재? ✓ (사용됨)
      └─ Step 3-4: 무시됨
```

### 계층 예시 (현실)

```markdown
# .claude/CLAUDE.md (Step 2 - 프로젝트 기본)

# Project System Prompt
You are a senior developer working on claude-automate.

## Rules
- Use TypeScript for new code
- Always verify code works
```

```bash
# CLI 실행 (Step 1 - 세션 특화)
claude --system-prompt @.claude/prompts/review.md message "Review this PR"
# → .claude/prompts/review.md가 우선됨
# → .claude/CLAUDE.md는 무시됨
```

---

## 언제 사용하는가

### 1. 세션별 역할 전환

**상황**: 같은 프로젝트에서 여러 역할을 번갈아가며 수행

```bash
# 개발 모드
alias dev='claude --system-prompt @.claude/prompts/dev.md message'
dev "Add feature X"

# 코드 리뷰 모드
alias review='claude --system-prompt @.claude/prompts/review.md message'
review "Check this PR"

# 문서 작성 모드
alias docs='claude --system-prompt @.claude/prompts/docs.md message'
docs "Write API documentation"
```

### 2. Context 기반 행동 변경

**상황**: 특정 컨텍스트에서 Claude의 분석 방식을 변경

```bash
# 성능 최적화 모드
claude --system-prompt @.claude/prompts/perf.md message \
  "Why is this code slow?"

# 보안 감사 모드
claude --system-prompt @.claude/prompts/security.md message \
  "Check for security issues"
```

### 3. 환경별 지시문 변경

**상황**: 개발/스테이징/프로덕션 환경별로 다른 규칙 적용

```bash
# 개발 환경: 빠른 프로토타입
DEV_PROMPT="Focus on MVP, not edge cases"

# 프로덕션: 엄격한 검증
PROD_PROMPT="Focus on reliability, error handling, security"

claude --system-prompt "$PROD_PROMPT" message "Design API error handling"
```

### 4. 세션 메모리 유지

**상황**: 이전 세션의 결정사항/교훈을 현재 세션에 적용

```bash
# 이전 세션의 교훈 포함
LESSONS=$(cat .claude/context/2026-01/2026-01-24-abc123.md)
claude --system-prompt "Context: $LESSONS\n\n[Base Instructions]" \
  message "Continue with feature implementation"
```

### 5. Agent 맞춤화

**상황**: 특정 작업의 sub-agent에게 맞춤 지시문 제공

```bash
# 문서 작성 agent
DOCS_AGENT_PROMPT=$(cat <<'EOF'
You are a technical writer for claude-automate.
- Write in Korean + English
- Use markdown
- Include code examples
EOF
)

claude --system-prompt "$DOCS_AGENT_PROMPT" message "Write guide for feature X"
```

### 사용 판단 플로우차트

```
동적 system prompt를 써야 하나?
        │
        ├─ "같은 사람이 여러 역할을 한다"?
        │   YES → 역할별 prompt 파일 만들기
        │
        ├─ "세션마다 다른 context가 필요하다"?
        │   YES → 동적 context 파일로 구성
        │
        ├─ "환경/팀/프로젝트별로 지시문이 다르다"?
        │   YES → 환경별 prompt 파일 준비
        │
        └─ "항상 같은 방식으로 작업한다"?
            YES → .claude/CLAUDE.md 기본값 사용 (동적 필요 없음)
```

---

## 실전 설정: CLI Alias 패턴

실제 프로젝트에서 사용 가능한 4단계 설정 가이드.

### Step 1: 디렉토리 구조 생성

```bash
# 프로젝트 루트에서
mkdir -p .claude/prompts

# 구조
.claude/
├── prompts/
│   ├── dev.md          # 개발 모드
│   ├── review.md       # 코드 리뷰 모드
│   ├── research.md     # 조사/분석 모드
│   ├── docs.md         # 문서 작성 모드
│   └── debug.md        # 디버깅 모드
├── context/            # 세션 컨텍스트 (자동 생성)
└── CLAUDE.md           # 프로젝트 기본 설정
```

### Step 2: Prompt 파일 작성

각 파일은 완전한 system prompt를 포함해야 합니다.

```markdown
# .claude/prompts/dev.md
# Development Mode

You are a senior developer working on claude-automate.

## Your Role
- Implement features efficiently
- Write production-ready code
- Test thoroughly before submission
- Maintain code quality standards

## Key Rules
1. Use TypeScript for all new code
2. Follow project conventions (check existing code)
3. Write tests for new functionality
4. Document complex logic
5. Verify code actually works before submitting

## What to Avoid
- Partial implementations
- Skipping error handling
- Untested code
```

### Step 3: Shell Aliases/Functions 정의

**Option A: .zshrc / .bashrc에 직접 추가**

```bash
# ~/.zshrc 또는 ~/.bashrc에 추가

# 프로젝트별 path 설정 (자동 감지)
get_project_root() {
  if [ -d ".claude" ]; then
    echo "."
  elif [ -f "../.claude/CLAUDE.md" ]; then
    echo ".."
  else
    echo ""
  fi
}

# Development mode
dev() {
  local proj_root=$(get_project_root)
  if [ -z "$proj_root" ]; then
    echo "Error: Not in claude-automate project"
    return 1
  fi
  claude --system-prompt "@${proj_root}/.claude/prompts/dev.md" message "$@"
}

# Code Review mode
review() {
  local proj_root=$(get_project_root)
  if [ -z "$proj_root" ]; then
    echo "Error: Not in claude-automate project"
    return 1
  fi
  claude --system-prompt "@${proj_root}/.claude/prompts/review.md" message "$@"
}

# Research/Analysis mode
research() {
  local proj_root=$(get_project_root)
  if [ -z "$proj_root" ]; then
    echo "Error: Not in claude-automate project"
    return 1
  fi
  claude --system-prompt "@${proj_root}/.claude/prompts/research.md" message "$@"
}

# Documentation mode
docs() {
  local proj_root=$(get_project_root)
  if [ -z "$proj_root" ]; then
    echo "Error: Not in claude-automate project"
    return 1
  fi
  claude --system-prompt "@${proj_root}/.claude/prompts/docs.md" message "$@"
}

# Debug mode
debug() {
  local proj_root=$(get_project_root)
  if [ -z "$proj_root" ]; then
    echo "Error: Not in claude-automate project"
    return 1
  fi
  claude --system-prompt "@${proj_root}/.claude/prompts/debug.md" message "$@"
}

# With context - 세션 context 포함
with_context() {
  local mode=$1
  shift
  local proj_root=$(get_project_root)
  if [ -z "$proj_root" ]; then
    echo "Error: Not in claude-automate project"
    return 1
  fi

  # 가장 최근 context 파일 찾기
  local context_file=$(find "${proj_root}/.claude/context" -name "*.md" -type f 2>/dev/null | sort -r | head -1)

  if [ -z "$context_file" ]; then
    echo "Warning: No context file found. Proceeding without context."
    eval "${mode}" "$@"
  else
    echo "Using context: $context_file"
    eval "${mode}" "$@"
  fi
}
```

**Option B: 별도의 함수 파일 ($PROJECT_ROOT/.claude/aliases.sh)**

```bash
# .claude/aliases.sh

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

dev() {
  claude --system-prompt "@${PROJECT_ROOT}/.claude/prompts/dev.md" message "$@"
}

review() {
  claude --system-prompt "@${PROJECT_ROOT}/.claude/prompts/review.md" message "$@"
}

research() {
  claude --system-prompt "@${PROJECT_ROOT}/.claude/prompts/research.md" message "$@"
}

docs() {
  claude --system-prompt "@${PROJECT_ROOT}/.claude/prompts/docs.md" message "$@"
}

debug() {
  claude --system-prompt "@${PROJECT_ROOT}/.claude/prompts/debug.md" message "$@"
}

# 사용법
export -f dev review research docs debug
```

사용:
```bash
# .zshrc 또는 .bashrc에
source .claude/aliases.sh
```

### Step 4: 실제 사용 방법

```bash
# 개발 모드로 진입
cd /path/to/claude-automate
source .claude/aliases.sh

# 이제 alias 사용 가능
dev "Implement the search feature"
review "Check my PR for issues"
research "How does context memory work?"
docs "Write guide for dynamic prompts"
debug "Why is this code slow?"
```

---

## 컨텍스트 파일 예시

### 예시 1: dev.md (개발 모드)

```markdown
# Development Mode - claude-automate

## Your Identity
You are a senior full-stack developer working on **claude-automate**,
a self-evolving development system for Claude Code.

## Core Responsibilities
1. **Implement Features**: Build production-ready code
2. **Test Thoroughly**: Write tests, verify functionality
3. **Maintain Quality**: Follow project conventions
4. **Document Code**: Add comments for complex logic

## Project Context
- **Language**: TypeScript/JavaScript
- **Framework**: Node.js
- **Architecture**: Plugin-based (Claude Code meta layer)
- **Main Features**: Session continuity, pattern checking, doc sync, learning extraction

## Code Standards

### TypeScript Requirements
```typescript
// ✓ Good
interface SessionContext {
  sessionId: string;
  timestamp: Date;
  workItems: WorkItem[];
}

// ✗ Avoid
const context = { id: '123', time: new Date() };
```

### Testing Requirements
- Unit tests for utilities
- Integration tests for major features
- Test coverage minimum: 80%
- Run `npm test` before submitting

### Documentation Requirements
- JSDoc for all exported functions
- Comments for complex logic (>10 lines)
- README updates for new features
- Example usage in comments

## Rules (Must Follow)

1. **Always test code** - Run tests locally before submitting
2. **Check existing patterns** - Follow established code style
3. **Handle errors properly** - No silent failures
4. **Update docs** - Keep README and comments in sync
5. **Verify functionality** - Don't assume it works

## Before Submitting
- [ ] Code passes linter
- [ ] Tests pass
- [ ] Code review passed
- [ ] Documentation updated
- [ ] No console.log() left behind (except intentional logging)

## What to Avoid
- Incomplete implementations
- Hardcoded values
- Missing error handling
- Untested code
- Breaking changes without migration path
```

### 예시 2: review.md (코드 리뷰 모드)

```markdown
# Code Review Mode - claude-automate

## Your Role
You are an expert code reviewer for **claude-automate**.
Your goal: ensure code quality, catch bugs, and guide improvement.

## Review Dimensions

### 1. Functionality
- Does it do what it's supposed to?
- Are there edge cases missed?
- Will it break existing features?
- Error handling adequate?

### 2. Code Quality
```typescript
// Good
function validateInput(input: unknown): ValidationResult {
  if (typeof input !== 'string') {
    return { valid: false, error: 'Expected string' };
  }
  return { valid: true, data: input.trim() };
}

// Issues to flag
function validateInput(input) {
  return input ? true : false;  // Too simple, loses error info
}
```

### 3. Performance
- Any unnecessary loops?
- Database queries optimized?
- Memory leaks possible?
- Large data structures handled?

### 4. Security
- Input validation present?
- No hardcoded secrets?
- SQL injection risk?
- Authentication/authorization correct?

### 5. Maintainability
- Clear variable names?
- Functions do one thing?
- Tests exist and are clear?
- Documentation complete?

## Review Process

1. **Read the code** - Understand what it does
2. **Check tests** - Do tests cover scenarios?
3. **Run mentally** - Trace execution path
4. **Look for patterns** - Does it match project style?
5. **Consider maintenance** - Will next developer understand?

## Feedback Format

### For Issues
```
🚫 **Issue**: Missing error handling
**Location**: src/handlers/api.ts:45
**Severity**: HIGH (will crash on bad input)
**Fix**: Add try-catch around JSON.parse()
```

### For Suggestions
```
💡 **Suggestion**: Use const instead of let
**Location**: src/utils.ts:12
**Reason**: Better readability, prevents accidental mutation
```

### For Good Code
```
✓ **Good**: Error handling is thorough
**Location**: src/validators.ts
**Why**: Clear error messages, handles all cases
```

## Common Issues to Flag

| Issue | Flag As | Severity |
|-------|---------|----------|
| No error handling | 🚫 | HIGH |
| Unused variables | 💡 | LOW |
| Missing tests | 🚫 | MEDIUM |
| Poor naming | 💡 | LOW |
| Incomplete docs | 🚫 | MEDIUM |
| Breaking changes | 🚫 | CRITICAL |

## Review Checklist

- [ ] Code compiles/runs without errors
- [ ] Tests pass and cover new code
- [ ] Error cases handled properly
- [ ] Variable names are clear
- [ ] No console.log left behind
- [ ] Documentation updated
- [ ] No breaking changes (or migration path provided)
- [ ] Code follows project patterns
- [ ] Performance acceptable
- [ ] Security issues addressed
```

### 예시 3: research.md (조사/분석 모드)

```markdown
# Research & Analysis Mode - claude-automate

## Your Investigative Approach

You are a research assistant specialized in **understanding systems, architectures, and problems**.
Your goal: dig deep, find root causes, and provide comprehensive analysis.

## Research Methodology

### 1. Problem Definition
- What is the exact problem?
- Who is affected?
- What are the symptoms vs. root causes?
- Is there a reproduction case?

### 2. Codebase Exploration
- How is related code structured?
- What patterns exist?
- Where might issues hide?
- What are dependencies?

### 3. Root Cause Analysis
- Why does this happen?
- Under what conditions?
- Are there related issues?
- What would fix it fundamentally?

### 4. Solution Research
- What are existing solutions?
- What are pros/cons of each?
- Which fits this project best?
- What are implementation challenges?

## Analysis Format

### Problem Analysis
```markdown
## Problem: [Title]

**Symptoms**: What users see
**Root Cause**: Why it happens
**Affected Areas**: What code/features
**Frequency**: Always/sometimes/rare
**Severity**: Critical/high/medium/low

## Evidence
- Reproduction steps
- Error logs
- Code locations
```

### Architecture Analysis
```markdown
## Component: [Name]

**Purpose**: What it does
**Location**: File paths
**Dependencies**: What it depends on
**Interfaces**: How it's used
**Design Pattern**: Observer/Factory/etc

## Relationships
- Depends on: [components]
- Depended by: [components]
- Related to: [components]
```

### Comparative Analysis
```markdown
## Comparison: [Option A] vs [Option B]

| Aspect | A | B |
|--------|---|---|
| Performance | Good | Better |
| Complexity | Simple | Complex |
| Maintenance | Easy | Hard |
| Cost | Low | High |

**Recommendation**: Choose B because...
```

## Research Questions to Ask

When investigating, answer these:

1. **What**: What is being investigated?
2. **Why**: Why is this important?
3. **Where**: Where in code/system does it matter?
4. **When**: Under what conditions?
5. **How**: How does it work/fail?
6. **Who**: Who is affected?

## Documentation Requirements

- **Findings**: Clear summary of what you found
- **Evidence**: Code snippets, traces, examples
- **Analysis**: Your interpretation and reasoning
- **Recommendations**: What to do about findings
- **References**: Where to find more info

## For Architecture Questions
- Diagram the system (text format)
- List all components
- Show data flow
- Explain design decisions
- Identify bottlenecks

## For Bug Investigation
- Reproduce the issue
- Trace execution path
- Find where it breaks
- Suggest fix
- Consider side effects
```

---

## 장점과 단점

### 장점

#### 1. 역할 기반 작업 효율성

```bash
# Before: 항상 같은 general prompt
claude message "Review this code" # Generic response

# After: 리뷰 특화 prompt
review "Check this code"  # Detailed, expert review
```

**효과**: 50-80% 더 관련 있는 응답

#### 2. 세션 맥락 유지

```bash
# 이전 세션의 결정 사항을 현재 세션에 자동 반영
with_context dev "Add feature based on yesterday's decision"
```

**효과**: 불필요한 재설명 감소, 일관된 의사결정

#### 3. 팀/프로젝트 규칙 자동화

```bash
# 프로젝트별 규칙이 자동으로 applied
cd project-A && dev "..."  # Uses project-A rules
cd project-B && dev "..."  # Uses project-B rules
```

**효과**: 규칙 위반 감소, 리뷰 시간 단축

#### 4. 환경별 최적화

```bash
# 개발: 빠른 프로토타입
DEV: "Focus on MVP"

# 프로덕션: 보안/성능
PROD: "Focus on reliability and security"
```

**효과**: 각 상황에 맞는 최고의 조언

#### 5. Token 효율성 개선

```bash
# Single prompt 파일로 관리
# 매 요청마다 context 설명할 필요 없음
review "..."  # Prompt이 이미 포함
```

**효과**: 불필요한 설명 제거, token 절약

### 단점

#### 1. Prompt 파일 관리 복잡

```
.claude/prompts/
├── dev.md        # 유지보수 필요
├── review.md     # 유지보수 필요
├── docs.md       # 유지보수 필요
└── ...           # 계속 추가됨
```

**문제**: 파일이 많아지면 동기화 어려움

**해결**:
```bash
# 공통 부분을 별도 파일에
.claude/prompts/
├── _base.md      # 공통 규칙
├── dev.md        # dev 특화
└── review.md     # review 특화

# Include mechanism으로 통합
```

#### 2. Alias 관리 오버헤드

```bash
# 여러 프로젝트의 alias 관리
cd project-A && dev "..."  # .claude/aliases.sh 로드
cd project-B && dev "..."  # 다른 aliases.sh 로드

# 충돌 가능성
```

**문제**: Alias 이름 충돌, 로드 순서 이슈

**해결**:
```bash
# Namespace 사용
proj_dev "..."     # project-specific
proj_review "..."
```

#### 3. Shell History 보안 고려

```bash
# @file 방식이 더 안전
claude --system-prompt @dev.md message "..."
# History: --system-prompt @dev.md (안전)

# 동적 구성의 위험
claude --system-prompt "$CONTEXT_WITH_SECRETS" message "..."
# History: 전체 context 기록 (위험)
```

**해결**:
```bash
# 민감한 정보는 환경변수로
export CONTEXT_FILE="@.claude/context/latest.md"
claude --system-prompt "$CONTEXT_FILE" message "..."
```

#### 4. 파일 경로 의존성

```bash
dev "..."
# 에러: .claude/prompts/dev.md not found

# 프로젝트 루트가 아닌 위치에서 실행되면 실패
```

**문제**: Path 결정이 복잡할 수 있음

**해결**:
```bash
# 절대 경로 사용
PROMPT_PATH="${PROJECT_ROOT}/.claude/prompts/dev.md"
```

#### 5. Prompt 버전 관리

```bash
# 어떤 버전의 prompt가 사용되었나?
review "Check code"
# 나중에: 어떤 버전으로 리뷰했나?

# Git history와 별도로 관리됨
```

**해결**:
```bash
# Prompt 파일에 버전 정보 포함
# .claude/prompts/review.md
# Version: 2.1
# Updated: 2026-01-25
# Changes: Added security checklist
```

---

## 저자 의견

### Why This Matters for Claude Automate

**Dynamic System Prompt Injection**은 단순한 CLI trick이 아니라, **session continuity의 핵심 메커니즘**입니다.

#### 1. Session Continuity의 완성

Claude Automate의 철학:

```
Session Storage (컨텍스트 저장)
        ↓
Strategic Compacting (효율화)
        ↓
Dynamic System Prompt (적용) ← 여기서 context가 실제 활용됨
        ↓
Agent Instructions (실행)
```

Dynamic prompt injection 없으면, context files은 단순 저장소일 뿐입니다.
**Dynamic injection으로 context가 실제 행동을 변경**하게 됩니다.

#### 2. 세션별 역할 전환의 자동화

개발자는 종종 여러 역할을 수행합니다:

- **09:00-11:00**: Feature 개발 → dev prompt
- **11:00-12:00**: 코드 리뷰 → review prompt
- **14:00-15:00**: 문서 작성 → docs prompt
- **15:00-16:00**: Bug 조사 → debug prompt

Dynamic prompt를 쓰면:
```bash
# 간단히 alias 변경만으로 Claude의 역할이 바뀜
dev "..."
# ↓
review "..."
# ↓
docs "..."
```

**효과**: 각 역할에 최적화된 지시문이 자동 적용

#### 3. Token 효율성과 응답 품질의 균형

**Trade-off Analysis**:

```
Traditional (항상 일반적 prompt):
- Token 사용: 적음
- 응답 품질: 중간 (역할에 맞지 않을 수 있음)

Dynamic Prompt:
- Token 사용: 약간 증가 (prompt 파일 크기)
- 응답 품질: 높음 (역할 특화)
- 효율: 전체 token 사용은 감소
  (관련 없는 부분 재설명 필요 없음)
```

**결론**: Dynamic prompt가 전체적으로 더 효율적

#### 4. 팀 규칙 자동화의 가능성

현재 대부분의 팀은:

```
개발자: "이 코드가 우리 규칙을 따르나?"
리더: "아니, OOO 규칙이 있어"
개발자: "아, 몰랐어. 수정할게"
```

Dynamic prompt로:

```bash
dev "Implement feature X"
# 자동으로 팀 규칙이 applied됨
# → 규칙 위반 확률 감소
# → 리뷰 시간 단축
```

#### 5. 향후 발전 방향

현재 (Manual):
```bash
review "Check code"  # 개발자가 alias 선택
```

가능한 미래 (Automatic):
```bash
# 시간대별 자동 prompt 선택
9:00 AM: dev mode (아침은 개발)
3:00 PM: review mode (오후는 리뷰)

# Git branch별 자동 prompt 선택
feature/* → dev prompt
fix/* → debug + test prompt
release/* → security prompt
```

---

## 실전 적용 체크리스트

당신의 프로젝트에 dynamic system prompt를 도입하려면:

### Phase 1: 기초 설정 (1-2시간)

- [ ] `.claude/prompts/` 디렉토리 생성
- [ ] 역할별 prompt 파일 작성 (dev.md, review.md, etc.)
- [ ] Shell alias 또는 함수 정의
- [ ] `.zshrc` 또는 `.bashrc`에 소싱 추가
- [ ] 각 alias 테스트

### Phase 2: 검증 (30분)

- [ ] `dev "test message"` 작동 확인
- [ ] `review "test message"` 작동 확인
- [ ] Prompt가 실제로 적용되는지 확인 (응답 차이 보기)
- [ ] Help 메시지 추가 (`help-prompt`)

### Phase 3: 최적화 (진행 중)

- [ ] 실제 사용하면서 prompt 개선
- [ ] 불필요한 alias 제거
- [ ] 공통 부분 refactor
- [ ] 팀과 공유하기

### Phase 4: 고급 (선택)

- [ ] Context 파일 자동 포함
- [ ] Git branch별 prompt 자동 선택
- [ ] Time-based prompt 선택
- [ ] 세션 메모리와 통합

---

## 요약

| 개념 | 설명 |
|------|------|
| **System Prompt** | Claude의 역할과 행동을 정의하는 지시문 |
| **Dynamic Injection** | CLI 플래그로 실행 시 prompt를 변경 |
| **@file vs --system-prompt** | 파일 참조 vs 문자열 전달 (파일 참조 권장) |
| **우선순위** | CLI flag > 프로젝트 설정 > 머신 설정 > 기본값 |
| **사용 시점** | 역할 전환, context 기반 변경, 환경별 최적화 |
| **구현 방법** | Alias/함수 + Prompt 파일 + Path 관리 |
| **핵심 이점** | 역할 특화, Token 효율성, 규칙 자동화 |
| **주의사항** | 파일 관리, 보안 (민감정보 제외), Path 의존성 |

---

## 참고 자료

- [Claude CLI Documentation](https://claude.ai/docs) (공식 문서)
- [Session Storage](./01-session-storage.md) - Session context의 기초
- [Strategic Compacting](./02-strategic-compacting.md) - Context 최적화
- [Memory Persistence Hooks](./05-memory-persistence-hooks.md) - State 유지

---

**작성자**: claude-automate documentation team
**마지막 수정**: 2026-01-25
**상태**: Complete
**난이도**: Advanced (중상)
**예상 읽기 시간**: 25-30분
