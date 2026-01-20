---
description: 세션 마무리 - 패턴 체크, 사용 분석, 문서 동기화, 세션 컨텍스트 저장
---

[WRAP MODE ACTIVATED]

$ARGUMENTS

---

## ⚠️ CRITICAL: MANDATORY AGENT DELEGATION

**YOU MUST USE THE TASK TOOL TO INVOKE SUB-AGENTS.**

DO NOT:
- ❌ Directly read files and summarize yourself
- ❌ Run git commands and analyze yourself
- ❌ Write context files without using context-builder agent
- ❌ Skip any layer of the execution protocol

YOU MUST:
- ✅ Use `Task(subagent_type="claude-automate:agent-name", prompt="...")` for EVERY step
- ✅ Follow the Layer 1 → 2 → 3 → 4 protocol exactly
- ✅ Launch parallel agents simultaneously where indicated
- ✅ Wait for agent results before proceeding to next layer

**If you do the work directly instead of delegating to agents, you are violating this protocol.**

---

## What is /wrap?

세션을 마무리하며 메타 레이어 자동화를 실행합니다:
1. **패턴 체크**: 코드가 프로젝트 규칙을 따르는지 확인
2. **사용 분석**: 반복 패턴 감지 및 자동화 제안 (최근 10세션 중 3회 이상만)
3. **문서 동기화**: 코드-문서 불일치 감지
4. **세션 저장**: `.claude/context/YYYY-MM/YYYY-MM-DD-{session-id}.md` 파일 생성

**NOTE**: 평범한 세션에서는 "특별한 거 없음"을 반환할 수 있습니다.

## Execution Protocol

### Layer 1: Data Collection (Parallel)

Launch these agents SIMULTANEOUSLY using Task tool:

```
// ACTUALLY INVOKE THESE - DO NOT SKIP
Task(subagent_type="claude-automate:diff-reader", prompt="Collect git diff data for this session")
Task(subagent_type="claude-automate:session-reader", prompt="Parse current session logs")
Task(subagent_type="claude-automate:rules-reader", prompt="Collect project rules from .claude/rules/")
Task(subagent_type="claude-automate:doc-scanner", prompt="Scan documentation files in this project")
```

**Send all 4 Task calls in a SINGLE message for parallel execution.**

### Layer 2: Analysis (Parallel)

After Layer 1 completes, launch analysis agents with the collected data:

```
// ACTUALLY INVOKE THESE WITH LAYER 1 RESULTS
Task(subagent_type="claude-automate:pattern-checker", prompt="Analyze patterns. Diff: {diff_data}, Rules: {rules_data}")
Task(subagent_type="claude-automate:usage-analyzer", prompt="Analyze usage patterns. Session: {session_data}")
Task(subagent_type="claude-automate:context-builder", prompt="Create session context file. Session: {session_data}")
Task(subagent_type="claude-automate:doc-sync-checker", prompt="Check doc sync. Diff: {diff_data}, Docs: {doc_catalog}")
```

**Send all 4 Task calls in a SINGLE message for parallel execution.**

### Layer 3: Integration

Combine all Layer 2 results:

```
// ACTUALLY INVOKE THIS WITH LAYER 2 RESULTS
Task(subagent_type="claude-automate:result-integrator", prompt="Integrate results. Pattern: {pattern_analysis}, Usage: {usage_analysis}, Context: {context_file}, DocSync: {doc_sync}")
```

**NOTE**: result-integrator may return "특별한 거 없음" if no significant findings.

### Layer 4: Save Context & User Interaction

```
# 1. Save context file
mkdir -p .claude/context/YYYY-MM/
write(context_file.path, context_file.content)

# 2. Present choices
user_choices = present_choices(final_summary)
for choice in user_choices:
    if choice.approved:
        execute(choice.action)
```

## Context File Structure

`/wrap` 실행 시 세션 컨텍스트가 자동 저장됩니다:

```
.claude/context/
├── 2026-01/
│   ├── 2026-01-20-abc123.md   ← 세션 1
│   ├── 2026-01-20-def456.md   ← 같은 날 다른 세션
│   └── 2026-01-21-xyz789.md
└── 2026-02/
    └── ...
```

**세션 파일 포맷:**
```markdown
# Session: YYYY-MM-DD HH:mm

## 맥락
## 작업 요약
## 문제 → 해결
## 결정사항
## 미완료/TODO
## 다음 세션 제안
```

## Quick Mode

For faster execution, use specific flags:

```
/wrap --pattern    # Pattern check only
/wrap --usage      # Usage analysis only
/wrap --context    # Context save only
/wrap --docs       # Doc sync only
/wrap --all        # Full analysis (default)
```

## Output Format

After analysis, you will see one of:

### When No Significant Findings:
```
## Session Analysis Complete

이번 세션은 특별히 기록하거나 자동화할 내용이 없습니다.
평범한 작업 세션이었습니다.

✅ 세션 컨텍스트 저장됨: .claude/context/2026-01/2026-01-20-abc123.md

---
*다음 세션에서 패턴이 축적되면 다시 분석합니다.*
```

### When Findings Exist:
```
## /wrap Summary

### Findings
- Patterns: [count] issues, [count] suggestions
- Usage: [count] automation opportunities (only if 3+ in last 10 sessions)
- Docs: [count] sync issues

### Session Saved
✅ .claude/context/2026-01/2026-01-20-abc123.md

### Actions
1. [ ] [Action 1]
2. [ ] [Action 2]
...

Enter numbers to approve (e.g., "1,3") or "all" / "none"
```

## Session Workflow

```
┌─────────────────────────────────────────┐
│  /session-start                         │  ← 이전 세션 컨텍스트 로드
│     ↓                                   │
│  [작업 수행]                             │
│     ↓                                   │
│  /wrap                                  │  ← 세션 저장 + 분석
│     ↓                                   │
│  .claude/context/YYYY-MM/file.md 저장   │
└─────────────────────────────────────────┘
```

## Integration with Sisyphus

/wrap은 sisyphus와 상호 보완적입니다:
- **sisyphus**: 실행 자동화 (작업을 완료)
- **/wrap**: 메타 자동화 (작업 방식을 개선)

사용 순서:
1. 작업 시작: `/session-start`로 컨텍스트 로드
2. 작업 수행: sisyphus 모드로 실행
3. 작업 완료: `/wrap`으로 세션 마무리 및 저장

## The Boulder Keeps Rolling

/wrap은 단순한 정리 도구가 아닙니다.
매 세션마다 실행하면, 시스템이 점점 더 똑똑해집니다:
- 반복 패턴 (10세션 중 3회+) → 자동화 스킬
- 새 패턴 → 규칙 자동 추가
- 세션 히스토리 → 연속성 유지

**평범한 세션에서는 "특별한 거 없음"이 정상입니다.**
