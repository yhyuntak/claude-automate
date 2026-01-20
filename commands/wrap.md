---
description: 세션 마무리 - 패턴 체크, 사용 분석, 문서 동기화, TIL 추출, 컨텍스트 업데이트
---

[WRAP MODE ACTIVATED]

$ARGUMENTS

## What is /wrap?

세션을 마무리하며 메타 레이어 자동화를 실행합니다:
1. **패턴 체크**: 코드가 프로젝트 규칙을 따르는지 확인
2. **사용 분석**: 반복 패턴 감지 및 자동화 제안 (최근 10세션 중 3회 이상만)
3. **문서 동기화**: 코드-문서 불일치 감지
4. **컨텍스트 업데이트**: 다음 세션을 위한 context.md 갱신

**NOTE**: 평범한 세션에서는 "특별한 거 없음"을 반환할 수 있습니다.

## Execution Protocol

### Layer 1: Data Collection (Parallel)

Launch these agents SIMULTANEOUSLY:

```
parallel {
    diff_data = Task(wrap:diff-reader, "Collect git diff data")
    session_data = Task(wrap:session-reader, "Parse current session logs")
    session_history = Task(wrap:session-reader, "Parse session history --history")  # Multi-session
    rules_data = Task(wrap:rules-reader, "Collect project rules")
    doc_catalog = Task(wrap:doc-scanner, "Scan documentation files")
}
```

### Layer 2: Analysis (Parallel)

After Layer 1 completes, launch analysis agents:

```
parallel {
    pattern_analysis = Task(wrap:pattern-checker, {diff_data, rules_data})
    usage_analysis = Task(wrap:usage-analyzer, {session_data, session_history})  # Uses multi-session
    context_update = Task(wrap:context-builder, {session_data})
    doc_sync = Task(wrap:doc-sync-checker, {diff_data, doc_catalog})
}
```

**NOTE**: til-extractor has been removed. TIL functionality is deprecated.

### Layer 3: Integration

Combine all results:

```
final_summary = Task(wrap:result-integrator, {
    pattern_analysis,
    usage_analysis,
    context_update,
    doc_sync
})

# NOTE: result-integrator may return "특별한 거 없음" if no significant findings
```

### Layer 4: User Interaction

Present choices and execute approved actions:

```
user_choices = present_choices(final_summary)
for choice in user_choices:
    if choice.approved:
        execute(choice.action)
```

## Quick Mode

For faster execution, use specific flags:

```
/wrap --pattern    # Pattern check only
/wrap --usage      # Usage analysis only
/wrap --context    # Context update only
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

### Actions
1. [ ] [Action 1]
2. [ ] [Action 2]
...

Enter numbers to approve (e.g., "1,3") or "all" / "none"
```

## Integration with Sisyphus

/wrap은 sisyphus와 상호 보완적입니다:
- **sisyphus**: 실행 자동화 (작업을 완료)
- **/wrap**: 메타 자동화 (작업 방식을 개선)

사용 순서:
1. 작업 시작: sisyphus 모드로 실행
2. 작업 완료: `/wrap`으로 세션 마무리
3. 다음 세션: context.md로 컨텍스트 복원

## The Boulder Keeps Rolling

/wrap은 단순한 정리 도구가 아닙니다.
매 세션마다 실행하면, 시스템이 점점 더 똑똑해집니다:
- 반복 패턴 (10세션 중 3회+) → 자동화 스킬
- 새 패턴 → 규칙 자동 추가
- 컨텍스트 → 연속성 유지

**평범한 세션에서는 "특별한 거 없음"이 정상입니다.**
