---
description: Install project rules to global Claude Code rules directory
---

[INSTALL RULE MODE ACTIVATED]

$ARGUMENTS

---

## 실행

이 커맨드는 install-rule 스킬을 호출합니다.

```
Skill(skill="install-rule", args="$ARGUMENTS")
```

---

## 설치되는 규칙

| 파일 | 설명 |
|------|------|
| interaction.md | AskUserQuestion UX 규칙 |
| backlog-rules.md | 백로그 관리 (todo/doing/done) |
| workflow.md | Git 브랜치 및 릴리즈 전략 |
| agent-delegation.md | 에이전트 위임 규칙 (explore, writer) |

---

## 참고

- 스킬 상세: `skills/install-rule/SKILL.md`
- 설치 위치: `~/.claude/rules/`
- 플러그인 업데이트 후 다시 실행하면 규칙 동기화

---

**Last Updated**: 2026-02-03
