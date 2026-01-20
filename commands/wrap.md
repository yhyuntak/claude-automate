---
description: 세션 마무리 - 패턴 체크, 사용 분석, 문서 동기화, 세션 컨텍스트 저장
---

[WRAP MODE ACTIVATED]

$ARGUMENTS

---

## ⚠️ MANDATORY AGENT DELEGATION

You are now in **WRAP MODE**. This mode requires MANDATORY delegation to specialist agents.

**CRITICAL RULES:**
- ❌ NEVER do analysis yourself - ALWAYS delegate to agents
- ❌ NEVER write context files directly - use `context-builder`
- ❌ NEVER run git commands directly - use `diff-reader`
- ✅ MUST use Task tool to invoke agents
- ✅ MUST launch parallel agents in a SINGLE message

**If you do the work directly instead of delegating, you are VIOLATING this protocol.**

---

## DELEGATE TO SPECIALISTS

Route tasks to these agents IMMEDIATELY:

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| `diff-reader` | Git diff 데이터 수집 | 코드 변경사항 분석 시 |
| `session-reader` | 세션 로그 파싱 | 현재 세션 내용 추출 시 |
| `rules-reader` | 프로젝트 규칙 수집 | 패턴 체크 시 |
| `doc-scanner` | 문서 파일 스캔 | 문서 동기화 체크 시 |
| `pattern-checker` | 코드 패턴 분석 | 규칙 준수 확인 시 |
| `usage-analyzer` | 사용 패턴 분석 | 자동화 기회 탐지 시 |
| `context-builder` | 세션 컨텍스트 생성 | 세션 파일 저장 시 |
| `doc-sync-checker` | 문서-코드 동기화 | 불일치 감지 시 |
| `result-integrator` | 결과 통합 | 최종 요약 생성 시 |

---

## EXECUTION FLOW

### Phase 1: Data Collection (PARALLEL)

Launch ALL of these agents in a **SINGLE message**:
- `diff-reader` - git diff 수집
- `session-reader` - 세션 로그 파싱
- `rules-reader` - 프로젝트 규칙 수집
- `doc-scanner` - 문서 파일 스캔

### Phase 2: Analysis (PARALLEL)

After Phase 1 results return, launch ALL of these:
- `pattern-checker` - 패턴 분석 (diff + rules 전달)
- `usage-analyzer` - 사용 분석 (session data 전달)
- `context-builder` - 컨텍스트 생성 (session data 전달)
- `doc-sync-checker` - 문서 동기화 (diff + docs 전달)

### Phase 3: Integration

Launch `result-integrator` with all Phase 2 results.

### Phase 4: Save & Present

1. Save context file from `context-builder` output
2. Present findings to user
3. Offer action choices

---

## Context File Structure

`/wrap` 실행 시 세션 컨텍스트가 저장됩니다:

```
.claude/context/
├── 2026-01/
│   ├── 2026-01-20-abc123.md
│   └── 2026-01-20-def456.md
└── 2026-02/
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

---

## Output Format

### When No Significant Findings:
```
## Session Analysis Complete

이번 세션은 특별히 기록하거나 자동화할 내용이 없습니다.

✅ 세션 컨텍스트 저장됨: .claude/context/2026-01/2026-01-20-abc123.md
```

### When Findings Exist:
```
## /wrap Summary

### Findings
- Patterns: [count] issues
- Usage: [count] automation opportunities
- Docs: [count] sync issues

### Session Saved
✅ .claude/context/2026-01/2026-01-20-abc123.md

### Actions
1. [ ] [Action 1]
2. [ ] [Action 2]

Enter numbers to approve (e.g., "1,3") or "all" / "none"
```

---

## THE WRAP PROMISE

Before completing, verify:
- [ ] ALL agents were invoked (not done directly)
- [ ] Context file was saved via `context-builder`
- [ ] Results were integrated via `result-integrator`
- [ ] User was presented with findings

**If you did ANY work directly instead of delegating, START OVER.**
