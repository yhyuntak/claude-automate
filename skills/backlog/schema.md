# Backlog Schema

## 폴더 구조

```
docs/backlog/
├── README.md        # 전체 현황 (Claude 자동 갱신)
├── todo/            # 할 일 (스코프 내)
├── doing/           # 진행 중 (1개만!)
├── done/            # 완료
├── ideas/           # 아이디어 (스코프 밖)
└── _archive/        # 완료된 Epic
```

---

## 폴더 의미

| 폴더 | 의미 | 규칙 |
|------|------|------|
| `todo/` | 이번에 할 것 | 명확한 스코프 내 작업 |
| `doing/` | 지금 하는 것 | **1개만!** (집중) |
| `done/` | 완료된 것 | 완료일 기록 |
| `ideas/` | 나중에 할 것 | 스코프 밖 아이디어 |

---

## 파일명 규칙

```
phase{N}-{id}-{slug}.md
```

| 부분 | 설명 | 예시 |
|------|------|------|
| `phase{N}` | Phase 번호 | `phase1`, `phase2` |
| `{id}` | 3자리 순번 | `001`, `002` |
| `{slug}` | 케밥케이스 제목 | `immersion-mode` |

**예시**: `phase1-001-immersion-mode.md`, `phase2-005-account-delete.md`

---

## Phase 시스템 (의존성 기반)

> 중요도가 아닌 **의존성 순서**로 구분

| Phase | 의미 | 설명 |
|-------|------|------|
| Phase 1 | 기반 피처 | 다른 피처들이 의존하는 핵심 기능 |
| Phase 2 | 1차 의존 | Phase 1 완료 후 구현 가능 |
| Phase 3 | 2차 의존 | Phase 2 완료 후 구현 가능 |
| Phase 4 | 독립 피처 | 언제든 구현 가능, 의존성 없음 |

---

## 파일 내부 구조

### 스토리 파일

```markdown
# [제목]

> 한 줄 요약 (테이블의 설명 컬럼으로 표시됨)

## User Story
[사용자로서 ~하고 싶다]

## Acceptance Criteria
- [ ] 조건 1
- [ ] 조건 2

## Why
[왜 필요한가]

## Dependencies
- 선행 작업 있으면 기재

---
Created: YYYY-MM-DD
Completed: YYYY-MM-DD (완료 시)
```

### 아이디어 파일

```markdown
# [제목]

> 한 줄 요약

## Description
[상세 설명]

## Related
[관련 정보]

---
Created: YYYY-MM-DD
```

---

## README.md 자동 갱신

Claude가 자동으로 관리:

```markdown
# Backlog

## 현황

| 상태 | 개수 |
|------|------|
| 🔄 Doing | 1 |
| 📋 Todo | 5 |
| ✅ Done | 12 |
| 💡 Ideas | 8 |

## 진행 중

| Phase | ID | 제목 | 설명 |
|-------|-----|------|------|
| 1 | 003 | user-auth | 사용자 인증 구현 |

## 할 일 (Todo)

| Phase | ID | 제목 | 설명 |
|-------|-----|------|------|
| 1 | 004 | ... | ... |
| 2 | 001 | ... | ... |

---
Last Updated: YYYY-MM-DD
```

---

## 스코프 관리 원칙

```
doing/에는 1개만 → 집중력 유지
todo/는 이번 스코프 → 명확한 범위
ideas/는 스코프 밖 → 폭발 방지
```

**핵심**: 테스트 후 나온 개선점/피처는 `ideas/`로 → 스코프 통제
