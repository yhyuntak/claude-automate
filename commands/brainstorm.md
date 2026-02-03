---
description: 아이디어 구체화 - /brainstorm 스킬 호출
---

[BRAINSTORM MODE ACTIVATED]

$ARGUMENTS

---

## 실행

이 커맨드는 brainstorm 스킬을 호출합니다.

```
Skill(skill="brainstorm", args="$ARGUMENTS")
```

---

## 워크플로우 요약

1. **아이디어 청취** - 사용자의 초기 아이디어 파악
2. **코드베이스 탐색** - Read-only로 관련 구조 파악
3. **명확화 질문** - 범위, 우선순위, 제약 조건
4. **요구사항 정리** - What, Why, Scope, Constraints

---

## 제약

- **Read-only**: 파일 수정 불가
- **Brain 참조 안 함**: brainstorm 단계에서는 불필요

---

## 다음 단계

brainstorm 완료 후 → `/planning` 실행하여 구현 계획 수립

---

## 참고

- 스킬 상세: `skills/brainstorm/SKILL.md`

---

**Last Updated**: 2026-02-03
