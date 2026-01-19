---
description: 세션 마무리 - 패턴 체크, 사용 분석, 문서 동기화, TIL 추출, 컨텍스트 업데이트
---

[WRAP MODE ACTIVATED]

$ARGUMENTS

## What is /wrap?

세션을 마무리하며 메타 레이어 자동화를 실행합니다:
1. **패턴 체크**: 코드가 프로젝트 규칙을 따르는지 확인
2. **사용 분석**: 반복 패턴 감지 및 자동화 제안
3. **문서 동기화**: 코드-문서 불일치 감지
4. **TIL 추출**: 학습 내용 추출 및 저장
5. **컨텍스트 업데이트**: 다음 세션을 위한 context.md 갱신

## Execution Protocol

### Layer 1: Data Collection (Parallel)

Launch these agents SIMULTANEOUSLY:

```
parallel {
    diff_data = Task(wrap:diff-reader, "Collect git diff data")
    session_data = Task(wrap:session-reader, "Parse current session logs")
    rules_data = Task(wrap:rules-reader, "Collect project rules")
    doc_catalog = Task(wrap:doc-scanner, "Scan documentation files")
}
```

### Layer 2: Analysis (Parallel)

After Layer 1 completes, launch analysis agents:

```
parallel {
    pattern_analysis = Task(wrap:pattern-checker, {diff_data, rules_data})
    usage_analysis = Task(wrap:usage-analyzer, {session_data})
    context_update = Task(wrap:context-builder, {session_data})
    doc_sync = Task(wrap:doc-sync-checker, {diff_data, doc_catalog})
    til = Task(wrap:til-extractor, {session_data})
}
```

### Layer 3: Integration

Combine all results:

```
final_summary = Task(wrap:result-integrator, {
    pattern_analysis,
    usage_analysis,
    context_update,
    doc_sync,
    til
})
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
/wrap --til        # TIL extraction only
/wrap --all        # Full analysis (default)
```

## Output Format

After analysis, you will see:

```
## /wrap Summary

### Findings
- Patterns: [count] issues, [count] suggestions
- Usage: [count] automation opportunities
- Docs: [count] sync issues
- TIL: [count] learnings captured

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
- 반복 패턴 → 자동화 스킬
- 새 패턴 → 규칙 자동 추가
- 학습 내용 → TIL 아카이브
- 컨텍스트 → 연속성 유지
