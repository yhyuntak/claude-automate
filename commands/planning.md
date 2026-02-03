---
description: Brain 기반 구현 계획 수립 - /planning 스킬 호출
---

[PLANNING MODE ACTIVATED]

$ARGUMENTS

---

## 실행

이 커맨드는 planning 스킬을 호출합니다.

```
Skill(skill="planning", args="$ARGUMENTS")
```

---

## 워크플로우 요약

1. **코드베이스 탐색** - 수정/생성 대상 파악
2. **구현 틀 식별** - 필요한 패턴 유형 파악
3. **Brain 참조** - `.claude/brain.md` → 상세 패턴 파일
4. **Plan Mode 진입** - EnterPlanMode 호출
5. **계획 문서 작성** - 패턴 기반 구현 계획

---

## 참고

- 스킬 상세: `skills/planning/SKILL.md`
- Brain 인덱스: `.claude/brain.md`
- 패턴 파일: `.claude/brain/patterns/`

---

**Last Updated**: 2026-02-03
