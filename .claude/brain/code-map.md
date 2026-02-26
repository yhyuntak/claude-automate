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

## 의존성 관계

- `session-start.sh` → `.claude/state/mode` 파일 읽기/쓰기
- `pre-compact.sh` → `.claude/context/` 폴더 쓰기
- `/start-work`, `/planning` 커맨드 → `.claude/state/mode` 파일 업데이트
- `/implement` 커맨드 → `.claude/plans/*.md` (status: in_progress 탐색)

---

**Last Updated**: 2026-02-27
