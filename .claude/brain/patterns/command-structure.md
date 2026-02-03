# Command Structure Pattern

> 커맨드 작성 시 따르는 구조와 규칙

---

## 언제 사용

- 새 커맨드 생성 시
- 기존 커맨드 수정 시
- 사용자 진입점 정의 시

---

## 파일 위치

```
commands/{command-name}.md
```

---

## 구조 (필수 요소)

```markdown
---
description: {한 줄 설명}
---

[ACTIVATION MODE 이름]

$ARGUMENTS

---

## 워크플로우

### STEP 1: {단계명}
{수행 내용}

### STEP 2: {단계명}
{수행 내용}

...

---

## 에이전트 호출 (필요 시)

\`\`\`
Task(
  subagent_type="claude-automate:{agent-name}",
  prompt="""
  {에이전트에게 전달할 내용}
  """
)
\`\`\`

---

## Final Output
{사용자에게 보여줄 최종 결과 형식}
```

---

## 예시 코드

### wrap.md (복잡한 커맨드)

```markdown
---
description: Session Wrap - Rule checks, document sync, and session context save
---

[WRAP V3 MODE ACTIVATED]

$ARGUMENTS

---

## STEP 1: Review Diff and Make Decisions

\`\`\`bash
git diff --stat
git diff --cached --stat
\`\`\`

Determine based on file list only:
- Code files → pattern-checker
- API changes → doc-sync-checker

---

## STEP 2: Determine Scope

Generate scope hints based on changed files.

---

## STEP 3: Call Agents (Only needed ones, in parallel)

### Call pattern-checker (If rule checks needed)

\`\`\`
Task(
  subagent_type="claude-automate:pattern-checker",
  prompt="""
## Changed Files
{file list}

## Scope
Check only rules related to {category}

## Instructions
1. Review detailed diff of above files
2. Read only relevant rules
3. Check for violations
4. Return results
"""
)
\`\`\`

---

## STEP 4: Integrate Results

Receive agent results and consolidate into summary.

---

## Final Output

\`\`\`markdown
## /wrap Complete

### Summary
[Brief summary]

### Actions (Optional)
1. [ ] [Action]

### Session Saved
✅ .claude/context/2026-01/2026-01-22-abc123.md
\`\`\`
```

---

## 따라야 할 것

1. **YAML Frontmatter**: description 필수
2. **$ARGUMENTS**: 사용자 입력 자리 표시
3. **단계별 구조**: STEP N 형식으로 명확히
4. **에이전트 위임**: 복잡한 작업은 에이전트에게
5. **병렬 호출**: 독립적인 에이전트는 동시 호출
6. **Final Output**: 사용자에게 보여줄 형식 명시

---

## 피해야 할 것

- 커맨드에서 직접 복잡한 로직 수행 (에이전트 위임)
- 에이전트 결과를 그대로 전달 (통합/요약 필요)
- 불필요한 에이전트 호출

---

## Command vs Skill 차이

| 구분 | Command | Skill |
|------|---------|-------|
| 위치 | `commands/` | `skills/{name}/` |
| 역할 | 워크플로우 오케스트레이션 | 재사용 가능한 도메인 로직 |
| 호출 | 사용자가 직접 | 커맨드나 대화에서 |
| 에이전트 사용 | 자주 사용 | 드물게 사용 |

---

## 실제 구현 참고

- `commands/wrap.md` - 세션 종료 (에이전트 오케스트레이션)
- `commands/start-work.md` - 세션 시작 (통합 워크플로우)
- `commands/session-start.md` - 컨텍스트 로드 (단순)

---

**Last Updated**: 2026-02-03
