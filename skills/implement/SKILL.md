---
name: implement
description: |
  plan 파일 기반으로 TDD 루프를 돌며 AC를 구현한다.
  "implement", "구현", "구현하자" 키워드로 활성화.
argument-hint: "[plan slug]"
allowed-tools:
  - Read
  - Glob
  - Grep
  - LSP
  - Task
  - Bash
  - AskUserQuestion
---

# /implement

> plan 파일을 로드하고 TDD 루프로 AC를 구현하는 실행기

$ARGUMENTS

---

## 진행 안내 규칙

각 단계 진입 시 사용자에게 현재 상황을 안내한다.

- 진입: "구현 단계에 진입합니다. Plan: {slug} (AC {N}개)"
- 각 단계: "[N/5] {단계명} 실행합니다."
- AC 처리: "AC-{N}: {내용} → {TDD/구현만}"
- 병렬: "AC-{N}, AC-{M}을 병렬로 실행합니다. (파일 겹침 없음)"
- 순차: "AC-{N}을 순차로 실행합니다. (AC-{M}과 {file} 겹침)"
- 재시도: "AC-{N}: red (재시도 {K}회차, {writer/writer-high})"
- 완료: "AC-{N} ✅"

---

## [1/5] Plan 로드

plan 파일을 `.claude/plans/`에서 로드한다.

- 인자로 slug 지정 → 해당 파일 로드
- 인자 없음 → status: draft 또는 in_progress 파일 탐색
- status → `in_progress`로 변경
- 이미 `in_progress` → 미완료 AC(`- [ ]`)부터 이어가기

MUST: `.claude/state/mode`에 `implement`를 기록하라. (`echo implement > .claude/state/mode`)

## [2/5] Brain 업데이트

plan의 "Brain 업데이트" 섹션을 실행한다.

```
Task(
  subagent_type="claude-automate:writer",
  prompt="Brain 업데이트: {plan의 Brain 섹션 내용}. 대상: .claude/brain/ 하위 파일들"
)
```

"없음"이면 스킵.

## [3/5] AC 순회

plan의 구현 순서대로 AC를 처리한다.

### 병렬/순차 판단

구현 순서의 표기를 따른다:
- `[병렬]` → writer 동시 호출
- `[순차]` → writer 하나씩

### TC 있는 AC → TDD 루프

1. writer: 테스트 작성 (TC 기반)
2. Bash: 테스트 실행 → red 확인
3. writer: 구현
4. Bash: 테스트 실행 → green?
   - green → AC 체크 ✅
   - red → 재시도

### 재시도 정책

| 시도 | 처리 |
|------|------|
| 1~2회 | writer (Sonnet) 재시도 |
| 3회 | writer-high (Opus) 에스컬레이션 |
| 4회 | AskUserQuestion으로 사용자에게 |

### TC 없는 AC → 구현만

1. writer: 구현
2. AC 체크 ✅

### AC 체크 업데이트

AC 완료 시 plan 파일의 체크박스를 `- [x]`로 업데이트한다 (writer).

## [4/5] plan status 변경

모든 AC 완료 후 plan 파일의 frontmatter status를 `done`으로 변경한다 (writer).

## [5/5] 완료

AskUserQuestion으로 다음 행동을 확인한다.

```json
{
  "question": "구현이 완료되었습니다. 다음에 무엇을 할까요?",
  "header": "완료",
  "multiSelect": true,
  "options": [
    { "label": "/wrap으로 마무리 (Recommended)", "description": "백로그 정리 + 컨텍스트 저장 + 커밋" },
    { "label": "계속 작업", "description": "다른 작업 이어서 진행" }
  ]
}
```

---

## 제약

- plan에 없는 작업은 하지 않는다
- 모든 파일 수정은 writer 에이전트로 위임한다
- 새 AC 발견 시 plan 파일에 추가 후 진행
- Stop Hook이 test-command로 품질을 감시한다

---

## 검증

MUST: 아래 체크리스트를 모두 확인하라.

- [ ] plan 파일의 모든 AC가 체크되었는가?
- [ ] TC 있는 AC의 테스트가 통과하는가?
- [ ] plan status가 done으로 변경되었는가?
- [ ] 진행 안내가 각 단계마다 출력되었는가?

실패 시: 해당 단계로 돌아가 수정 → 재검증.

---

## 주의사항

1. **plan대로만 실행** — 범위를 넓히지 않는다
2. **묻지 않는다** — 앞단(planning)에서 이미 결정됨 (재시도 4회 초과 제외)
3. **진행 안내 필수** — 사용자가 현재 상태를 항상 알 수 있게
4. **writer 위임 필수** — 직접 Write/Edit 하지 않는다
