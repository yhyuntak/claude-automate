---
name: implement
description: |
  plan 파일 기반으로 구현 실행.
  "implement", "구현", "구현하자" 키워드로 활성화.
argument-hint: "[plan slug]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - LSP
  - Task
  - Bash
---

# /implement

> plan 파일을 로드하고 AC를 순서대로 구현하는 실행기

$ARGUMENTS

---

## 역할

plan 파일을 로드하고 AC를 순서대로 구현한다.
사용자에게 묻지 않고 plan대로 실행한다.

---

## 실행

1. plan 파일 로드 (`.claude/plans/{date}-{slug}.md`)
2. status를 `in_progress`로 변경
3. AC별 구현:
   - 테스트 가능 AC → 테스트 작성 → 구현 → 테스트 통과
   - 테스트 불가 AC → 일반 구현
   - AC 간 의존성 → 묶어서 처리 (자동 판단)
4. 완료된 AC는 plan 파일에서 체크 (`- [x]`)

---

## 제약

- plan에 없는 작업은 하지 않는다
- 사용자에게 묻지 않는다
- 새 AC 발견 시 plan 파일에 추가 후 진행
- Stop Hook이 품질과 컨텍스트를 감시한다

---

## 검증

MUST: 아래 체크리스트를 모두 확인하라.

- [ ] 모든 테스트 가능 AC의 테스트가 통과하는가?
- [ ] plan 파일의 AC 체크가 갱신되었는가?

실패 시: Stop Hook이 exit 2로 차단 → 수정 후 재시도.

---

## 주의사항

1. **plan대로만 실행** — 범위를 넓히지 않는다
2. **묻지 않는다** — 앞단(brainstorm/planning)에서 이미 결정됨
3. **Stop Hook 신뢰** — 테스트 실패와 컨텍스트 초과를 감시
