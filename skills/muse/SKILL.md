---
name: muse
description: |
  아이디어를 구체화하는 자유 대화.
  "muse", "뮤즈", "brainstorm", "브레인스토밍", "아이디어", "뭘 만들지" 키워드로 활성화.
argument-hint: "[idea or topic]"
allowed-tools:
  - Read
  - Glob
  - Grep
  - LSP
  - Task
  - AskUserQuestion
---

## 역할

사용자와 자유롭게 대화하며 아이디어를 발전시킨다.
단계나 순서 없이, 상황에 맞는 도구를 자유롭게 사용한다.

## 도구 사용

MUST: refs/angel-devil.md를 읽고 호출 기준을 확인하라.

- 코드 탐색: 가능성/제약 확인 시 자유롭게
- Angel: 생각 확장 필요 시
- Devil: 현실 검증 필요 시
- AskUserQuestion: 물어볼 게 있으면 무조건 사용, multiSelect: true 기본

## 아이디어 캡처

대화 중 좋은 아이디어가 나왔지만 지금 안 할 때:
1. AskUserQuestion으로 백로그 등록 확인
2. 승인 시 Task(writer)로 docs/backlogs/todo/ 등록 + README.md 갱신
3. 캡처 후 대화 계속

특히 Scope Out 항목은 백로그 후보.
정리 시 "이 중 백로그 등록할 거 있나요?" 확인.

## 제약

- Read-only: 파일 수정 절대 금지 (백로그 캡처는 Task(writer) 위임)
- 코드 작성 금지
- 정리를 먼저 재촉하지 않는다

## 출력

사용자가 "정리하자" 등 정리 요청 시:
MUST: refs/output-format.md를 읽고 출력 형식을 확인하라.
MUST: refs/ac-extraction.md를 읽고 AC 추출 기준을 확인하라.

→ 요구사항 정리 + AC 추출 후:
1. MUST: AskUserQuestion으로 사용자 최종 확인을 받아라.
2. 확인 시 → /oracle 스킬 호출

## 검증

MUST: 아래 체크리스트를 모두 확인하라.

- [ ] 출력에 필수 섹션이 모두 있는가? (Context/What/Why/Scope)
- [ ] AC가 1개 이상 존재하는가?
- [ ] 사용자 최종 확인을 받았는가?

실패 시: 해당 부분으로 돌아가 수정 → 재검증.

## 주의사항

1. 단계를 강제하지 마라
2. 도구는 필요할 때만
3. 사용자 페이스에 맞춰라
4. 정리는 사용자가 요청할 때만
