# Code Map

> 프로젝트 구조, 주요 파일, 모듈 관계

---

## 모듈 구조

(planning 시 explore 에이전트가 탐색한 결과가 여기에 축적됩니다)

---

## 주요 파일

| 파일 | 역할 |
|------|------|
| `hooks/session-start.sh` | PreToolUse hook - 세션 시작 시 mode 파일 초기화 |
| `hooks/pre-compact.sh` | PreCompact hook - compact 전 컨텍스트 저장 |
| `.claude/state/mode` | 현재 세션 mode 저장 (idle/planning/implement) |

---

## 폴더 구조 변경

### hooks/ 폴더 (업데이트)

```
hooks/
├── hooks.json          # 플러그인 hooks 등록
├── session-stop.sh     # Stop Hook (기존)
├── session-start.sh    # PreToolUse Hook (신규) - mode 초기화
└── pre-compact.sh      # PreCompact Hook (신규) - 컨텍스트 저장
```

### .claude/state/ 폴더 (신규)

```
.claude/state/
└── mode                # 세션 mode 파일 (단순 문자열: idle/planning/implement)
```

---

### skills/docs/ 폴더 (신규)

```
skills/docs/
├── SKILL.md            # docs CRUD + 인덱스 관리 스킬 정의
└── refs/               # 참조 파일
```

**역할**: `docs/` 폴더 내 문서 생성/수정/삭제 + `docs/README.md` 인덱스 자동 관리

### skills/wrap/ 구조 변경

```
skills/wrap/
├── SKILL.md
└── refs/               # refs/completion-context.md 삭제됨
```

**변경**: `refs/completion-context.md` 제거 (불필요 파일 정리)

### rules/ 폴더

```
rules/
├── backlog-rules.md    # 백로그 관리 규칙
├── workflow.md         # Git 워크플로우
├── interaction.md      # 사용자 상호작용 규칙
└── skill-writing.md    # SKILL.md 작성 규칙 (Frontmatter + 5가지 핵심 규칙)
```

**역할**: 프로젝트 세부 규칙 모음 (CLAUDE.md의 eslint.config 역할)

**skill-writing.md**: SKILL.md 구조(Frontmatter + Body), Progressive Disclosure, context fork/생략 선택 기준, 5가지 핵심 규칙(Progressive Disclosure / body 제한 / Claude 상식 제외 / refs 분리 / 검증 루프) 정의

### docs/README.md 인덱스 (신규)

```
docs/
├── README.md           # discovery-based 인덱스 (실제 파일 목록)
└── ...
```

**역할**: discovery-based 포맷으로 docs/ 폴더 내 실제 파일만 나열하는 인덱스

---

## 의존성 관계

- `session-start.sh` → `.claude/state/mode` 파일 읽기/쓰기
- `pre-compact.sh` → `.claude/context/` 폴더 쓰기
- `/start-work`, `/planning` 커맨드 → `.claude/state/mode` 파일 업데이트
- `/implement` 커맨드 → `.claude/plans/*.md` (status: in_progress 탐색)
- `skills/docs/SKILL.md` → `docs/README.md` 인덱스 읽기/쓰기

---

**Last Updated**: 2026-02-27
