# Architecture Decisions

> 아키텍처 결정과 그 근거 기록

---

## 결정 기록

| 날짜 | 결정 | 근거 | 상세 |
|------|------|------|------|
| 2026-02-27 | mode 파일 포맷: 단순 문자열 | 단순성 | [상세](#mode-파일-포맷) |
| 2026-02-27 | plan 경로 저장 안 함 | 중복 방지 | [상세](#plan-경로-저장-방식) |

---

## 상세

### mode 파일 포맷

**날짜**: 2026-02-27

**결정**: `.claude/state/mode` 파일에 단순 문자열만 저장 (`idle`, `planning`, `implement`)

**배경**: 세션 mode를 hook 스크립트와 커맨드 간에 공유할 방법 필요

**대안**:
- JSON 포맷: `{"mode": "planning", "since": "2026-02-27T10:00:00"}`
- 단순 문자열: `planning`

**결정 근거**:
- 단순 문자열이 읽기/쓰기 모두 간단 (`cat`, `echo` 사용 가능)
- JSON은 jq 없는 환경에서 파싱이 번거로움
- timestamp 등 추가 정보는 현재 필요 없음

**트레이드오프**:
- 단순성 ↑, 확장성 ↓ (추후 메타데이터 추가 시 포맷 변경 필요)

---

### plan 경로 저장 방식

**날짜**: 2026-02-27

**결정**: 현재 진행 중인 plan 경로를 mode 파일에 저장하지 않고, 필요 시 `grep -l "status: in_progress" .claude/plans/*.md`로 탐색

**배경**: `/implement` 커맨드에서 현재 진행 중인 plan 파일을 찾아야 함

**대안**:
- mode 파일에 경로 저장: `planning:.claude/plans/2026-02-27-feature.md`
- grep으로 탐색: `grep -l "status: in_progress" .claude/plans/*.md`

**결정 근거**:
- plan 파일 자체에 이미 `status: in_progress` 필드가 존재
- mode 파일에 경로 저장 시 plan 파일 이동/삭제 시 불일치 발생 가능
- grep 탐색은 항상 실제 상태 기준으로 찾으므로 일관성 보장
- 중복 저장 불필요

**트레이드오프**:
- 일관성 ↑, 탐색 속도 ↓ (plans 파일 수가 많아지면 grep 느려질 수 있음, 현재는 무시 가능)

---

**Last Updated**: 2026-02-27
