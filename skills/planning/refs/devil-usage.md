# Devil Invocation Criteria (planning)

## Role

Validates the entire AC list in Step 7.

## Validation Items

- Flag ambiguous ACs ("works correctly" → needs to be more specific)
- Mark untestable ACs
- Point out missing risks and edge cases
- Check for contradictions or duplicates among ACs

## How to Invoke

```
Task(
  subagent_type="claude-automate:devil",
  prompt="Validate AC list: [AC list]. Point out ambiguous ACs, untestable ACs, and missing risks."
)
```

## Notes

- Invoke once in Step 7 (avoid habitual repetition)
- Invoke after Angel (Step 6) — expand first, then validate
