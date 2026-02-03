# Skill Structure Pattern

> 스킬 작성 시 따르는 구조와 규칙

---

## 언제 사용

- 새 스킬 생성 시
- 기존 스킬 수정 시
- 재사용 가능한 도메인 로직 정의 시

---

## 파일 위치

```
skills/{skill-name}/
├── SKILL.md        # 스킬 정의 (필수)
├── schema.md       # 입출력 스키마 (선택)
├── templates.md    # 템플릿 (선택)
└── references/     # 참고 자료 (선택)
```

---

## 구조 (필수 요소)

### SKILL.md

```markdown
---
name: {skill-name}
description: {한 줄 설명}. Auto-activates on keywords like "{keyword1}", "{keyword2}".
argument-hint: "[arg1|arg2|arg3]"
---

# {Skill Title}

$ARGUMENTS

{스킬 설명}

---

## {섹션 1}

{내용}

---

## {섹션 2}

{내용}

---

## Reference Files

- Schema: schema.md
- Templates: templates.md
```

---

## 예시 코드

### backlog/SKILL.md

```markdown
---
name: backlog
description: Query and manage project backlog. Auto-activates on keywords like "backlog", "todo", "done".
argument-hint: "[todo|doing|done|ideas|phase N]"
---

# Backlog Manager

$ARGUMENTS

This skill activates when it detects backlog-related requests.

---

## Backlog Locations

| Folder | Status | Description |
|--------|--------|-------------|
| `docs/backlog/todo/` | To Do | Work within current scope |
| `docs/backlog/doing/` | In Progress | **1 item only!** |
| `docs/backlog/done/` | Completed | Finished work |

---

## Query Patterns

| Query | Action |
|-------|--------|
| "show all backlog" | list todo folder |
| "what's in progress" | list doing folder |

---

## Explicit Commands

| Command | Action |
|---------|--------|
| `/backlog` | Full status |
| `/backlog todo` | To do items only |
| `/backlog add` | Add new item |

---

## Reference Files

- Schema: schema.md
- Templates: templates.md
```

---

## 따라야 할 것

1. **YAML Frontmatter 필수**: name, description
2. **Auto-activation keywords**: description에 트리거 키워드 명시
3. **argument-hint**: 인자 형식 명시
4. **$ARGUMENTS**: 사용자 입력 자리 표시
5. **테이블 활용**: Query Patterns, Commands 등
6. **Reference Files**: 관련 파일 링크

---

## 피해야 할 것

- 스킬에서 에이전트 호출 (스킬은 가벼워야 함)
- 너무 넓은 책임 (단일 도메인에 집중)
- 복잡한 워크플로우 (커맨드 역할)

---

## Skill vs Command 차이

| 구분 | Skill | Command |
|------|-------|---------|
| 책임 | 단일 도메인 로직 | 워크플로우 오케스트레이션 |
| 크기 | 작고 집중적 | 여러 단계 포함 가능 |
| 에이전트 | 거의 안 씀 | 자주 사용 |
| 재사용 | 높음 | 낮음 |

---

## 실제 구현 참고

- `skills/backlog/SKILL.md` - 백로그 관리
- `skills/feedback/SKILL.md` - 피드백 시스템
- `skills/explain-plugins/SKILL.md` - 플러그인 설명

---

**Last Updated**: 2026-02-03
