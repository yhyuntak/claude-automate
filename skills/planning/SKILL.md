---
name: planning
description: |
  brainstorm 결과를 plan 파일로 구체화.
  "planning", "계획", "플래닝", "어떻게 만들지" 키워드로 활성화.
argument-hint: "[feature or topic]"
allowed-tools:
  - Read
  - Glob
  - Grep
  - LSP
  - Task
  - Write
  - AskUserQuestion
---

# /planning

$ARGUMENTS

---

## 역할

brainstorm에서 나온 요구사항 + AC를 받아
어떻게 구현할지 자유롭게 탐색하고, plan 파일을 생성한다.
단계 없이 대화 흐름에 맞게 도구를 자유롭게 사용한다.

---

## 도구 사용

- 코드 탐색: 기존 코드 구조/패턴/의존성 확인 시 자유롭게 (Read, Glob, Grep, LSP)
- Devil: 구현 방식 검증 필요 시
  MUST: refs/devil-usage.md를 읽고 호출 기준을 확인하라.
- AskUserQuestion: 물어볼 게 있으면 무조건 사용, multiSelect: true 기본
- Write: plan 파일만 쓰기 가능

---

## Plan 파일

MUST: refs/plan-file.md를 읽고 파일 구조와 규칙을 확인하라.

- 경로: `.claude/plans/{YYYY-MM-DD}-{slug}.md`
- 상태: draft → in_progress → done
- 사용자 컨펌 후에만 Write

---

## 제약

- plan 파일 외 파일 수정 금지
- 코드 작성 금지 (구현은 /implement에서)
- brainstorm 결과(AC)를 임의로 바꾸지 않는다
- 정리를 재촉하지 않는다

---

## 출력

plan 파일 생성 후:
1. AskUserQuestion으로 사용자 최종 확인
2. 확인 시 → /implement로 핸드오프

---

## 검증

MUST: 아래 체크리스트를 모두 확인하라.

- [ ] plan 파일에 필수 섹션이 모두 있는가? (요구사항/AC/구현 순서/테스트 계획)
- [ ] AC가 brainstorm 결과와 일치하는가?
- [ ] 사용자 확인을 받았는가?

실패 시: 해당 부분으로 돌아가 수정 → 재검증.

---

## 주의사항

1. 단계를 강제하지 마라
2. brainstorm 결과를 존중하라
3. 구현은 하지 않는다 — 계획만
4. 사용자가 확인할 때만 파일 생성

---

**Last Updated**: 2026-02-22
