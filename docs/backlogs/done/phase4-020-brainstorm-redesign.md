# /brainstorm 스킬 재설계

> 자유 대화 기반 아이디어 발산 + 구체화 — Phase 없이 에이전틱하게

---

## User Story

사용자가 아이디어를 가지고 brainstorm을 시작하면,
자유로운 대화를 통해 아이디어를 발전시키고,
정리 요청 시 구조화된 요구사항 + AC로 /planning에 넘긴다.

## AS-IS (현재)

```
Phase 1:   아이디어 청취
Phase 2:   코드베이스 탐색 (read-only)
Phase 3:   명확화 질문 (AskUserQuestion)
Phase 3.5: Angel 에이전트 (선택적)
Phase 4:   요구사항 정리
Phase 4.5: Devil 에이전트 (현실성 검증)
→ /planning 핸드오프
```

문제: 순서가 강제됨. 실제 대화는 Phase가 섞여서 흘러감.

## TO-BE (재설계)

```
/brainstorm
  ┌─────────────────────────────┐
  │  자유 대화                    │
  │                             │
  │  사용 가능한 도구:             │
  │  - 코드 탐색 (read-only)     │
  │  - Angel (생각 확장)          │
  │  - Devil (현실 검증)          │
  │  - AskUserQuestion (명확화)  │
  │                             │
  │  + 아이디어 캡처              │
  │    (백로그 등록 가능)          │
  │                             │
  │  제약:                       │
  │  - 파일 수정 금지             │
  │                             │
  │  종료 조건:                   │
  │  - 사용자가 정리 요청 시       │
  │  → 요구사항 + AC 정리         │
  │  → /planning 핸드오프         │
  └─────────────────────────────┘
```

Phase 없음. 단계 강제 없음. 대화 흐름에 맞게 도구를 자유롭게 사용.

## 하네스 내 위치

```
/start-work
     │
     └── 새 작업 ──→ /brainstorm ◀── 여기
                          │
                          ▼
                     /planning → /implement
```

## Acceptance Criteria

### 스킬 구조
- [ ] Phase/Stage 없이 자유 대화 구조
- [ ] frontmatter에 allowed-tools 명시 (Read, Glob, Grep, LSP, Task, AskUserQuestion)
- [ ] read-only 제약 (Write, Edit, Bash 금지)

### 도구 사용 규칙
- [ ] Angel 에이전트: 하나의 접근법만 고려 중이거나, 대화가 맴돌 때, 사용자 요청 시 호출
- [ ] Devil 에이전트: 방향 잡혔을 때 구멍 확인, 범위 커질 때, 정리 직전 최종 검증, 사용자 요청 시 호출
- [ ] Angel/Devil 습관적 매번 호출 금지
- [ ] AskUserQuestion: 물어볼 게 있으면 무조건 사용, multiSelect: true 기본

### 아이디어 캡처
- [ ] 대화 중 좋은 아이디어가 나왔지만 지금 안 할 때 → AskUserQuestion으로 백로그 등록 확인
- [ ] 승인 시 Task(writer)로 docs/backlogs/todo/ 등록 + README.md 갱신
- [ ] 캡처 후 대화 흐름 끊지 않고 계속
- [ ] Scope Out 항목은 백로그 후보 — 정리 시 "백로그 등록할 거 있나요?" 확인

### AC 추출
- [ ] 요구사항에서 "통과/실패" 판정 가능한 AC로 변환
- [ ] 하나의 AC = 하나의 검증 포인트
- [ ] 모호한 표현 금지 ("잘 동작한다" ❌ → "200 응답을 반환한다" ✅)
- [ ] 각 AC를 테스트 가능(✅) / 불가(❌)로 분류
- [ ] 테스트 가능 AC 없으면 → TDD 없이 일반 구현
- [ ] AC 목록을 AskUserQuestion (multiSelect: true)으로 사용자 확인

### 출력 형식
- [ ] 요구사항 정리: Context / What / Why / Scope (In/Out) / Constraints / Open Questions
- [ ] AC 목록 (테스트 가능 여부 표시)
- [ ] /planning 핸드오프

### 행동 규칙
- [ ] 단계를 강제하지 않는다
- [ ] 정리를 먼저 재촉하지 않는다 — 사용자 페이스에 맞춘다
- [ ] 사용자가 정리 요청할 때만 출력 생성

### refs/ 분리 (Progressive Disclosure)
- [ ] SKILL.md body는 목차 수준으로 유지
- [ ] refs/angel-devil.md — Angel/Devil 호출 기준 (언제 O / 언제 X)
- [ ] refs/ac-extraction.md — AC 추출 방법 + 변환 예시 + 테스트 가능 분류 기준
- [ ] refs/output-format.md — 요구사항 정리 + AC 출력 템플릿
- [ ] SKILL.md에서 MUST: refs/xxx.md를 읽어라 형태로 참조

### 검증 루프
- [ ] 정리 출력 시 필수 섹션 체크 (Context/What/Why/Scope)
- [ ] AC가 1개 이상 존재하는지 확인
- [ ] 사용자 최종 확인 받았는지 확인
- [ ] 실패 시 해당 부분으로 돌아가 수정 → 재검증

## 현재 대비 변경점 요약

- Phase 1~4.5 순서 강제 → 자유 대화 (Phase 없음)
- Angel/Devil 호출 기준 구체화 (언제 O / 언제 X)
- AskUserQuestion multiSelect: true 필수화
- 아이디어 캡처 기능 추가 (대화 중 백로그 등록)
- Scope Out → 백로그 후보 연결
- AC 추출 프로세스 구체화 (변환 방법 + 작성 기준 + 사용자 확인)

## 비기능 요구사항

- 사용자 페이스에 맞춘 대화 (재촉 금지)
- read-only 엄수

## Dependencies

- phase4-019: AI 하네스 2.0 (전체 플로우 정의)

---

**Last Updated**: 2026-02-22
