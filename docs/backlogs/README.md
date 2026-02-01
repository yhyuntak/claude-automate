# claude-automate 백로그

> AI-Native Development Harness - "코드를 보지 않고 개발하기"

---

## 현황

| 상태 | 개수 |
|------|------|
| Todo | 9 |
| Doing | 0 |
| Done | 1 |

**전체 진행률**: 1/10 (10%)

---

## Phase 1: 계획-실행 워크플로우

> Peter Steinberger 스타일의 계획 중심 개발

**목표**: 코드 작성 전 아키텍처 확정, 실행은 에이전트에게 위임

| Phase | ID | Task | 상태 |
|-------|-----|------|------|
| 1 | 001 | [아키텍처 우선 계획 단계](done/phase1-001-architecture-first-planning.md) | ✅ Done |
| 1 | 002 | [다중 에이전트 병렬 실행](todo/phase1-002-multi-agent-execution.md) | Todo |
| 1 | 003 | [결과 통합 및 피드백](todo/phase1-003-result-integration.md) | Todo |

---

## Phase 2: PARA 지식 관리

> 배운 것을 축적하는 시스템 - 복리 효과

**목표**: 세션에서 배운 것이 자동으로 축적되어 미래 세션에서 활용

| Phase | ID | Task | 상태 |
|-------|-----|------|------|
| 2 | 001 | [PARA 지식 구조 설계](todo/phase2-001-para-structure.md) | Todo |
| 2 | 002 | [세션 인사이트 자동 추출](todo/phase2-002-insight-extraction.md) | Todo |
| 2 | 003 | [지식 검색 및 활용](todo/phase2-003-knowledge-search.md) | Todo |

---

## Phase 3: 병렬 리뷰 에이전트

> Kieran Klaassen 스타일의 병렬 리뷰 시스템

**목표**: 코드 리뷰를 AI에게 완전히 위임하고, 개발자는 결과만 확인

| Phase | ID | Task | 상태 |
|-------|-----|------|------|
| 3 | 001 | [병렬 리뷰 에이전트 구조 설계](todo/phase3-001-parallel-review-agents.md) | Todo |
| 3 | 002 | [Triage 워크플로우 구현](todo/phase3-002-triage-workflow.md) | Todo |
| 3 | 003 | [리뷰 결과 학습 축적](todo/phase3-003-review-learning.md) | Todo |
| 3 | 004 | [도구 위임 규칙 정의](todo/phase3-004-tool-delegation-rules.md) | Todo |

---

## 논리적 워크플로우

```
┌─────────────────────────────────────────────────────────────┐
│                      개발 워크플로우                          │
└─────────────────────────────────────────────────────────────┘

Phase 1: 계획-실행         Phase 2: 지식 축적        Phase 3: 리뷰
─────────────────         ─────────────────        ─────────────
     │                         │                        │
     ▼                         ▼                        ▼
┌─────────┐              ┌─────────┐              ┌─────────┐
│  계획   │───실행───▶   │  학습   │───피드백──▶  │  검증   │
│ (Plan) │              │(Learn) │              │(Review)│
└─────────┘              └─────────┘              └─────────┘
     │                         ▲                        │
     │                         │                        │
     └─────────────────────────┴────────────────────────┘
                        지속적 개선 루프
```

---

## Phase별 의존성

```
Phase 1 (계획-실행) ─────────────────────┐
    │                                    │
    ├─ phase1-001: 독립 시작 가능         │
    ├─ phase1-002: 001 필요              │ (계획 후 실행)
    └─ phase1-003: 002 필요              │
                                         │
Phase 2 (지식) ◀─────────────────────────┤
    │                                    │
    ├─ phase2-001: 독립 시작 가능         │  (Phase 1과 병렬 가능)
    ├─ phase2-002: 001 필요              │
    └─ phase2-003: 001, 002 필요         │
                                         │
Phase 3 (리뷰) ◀─────────────────────────┘
    │
    ├─ phase3-001: Phase 1 완료 후        (코드가 있어야 리뷰)
    ├─ phase3-002: 001 필요
    ├─ phase3-003: 001, 002 필요 → Phase 2로 피드백
    └─ phase3-004: 독립 시작 가능
```

---

## 작업 시작 방법

1. Todo에서 작업 선택
2. 파일을 `doing/`으로 이동
3. 작업 완료 후 `done/`으로 이동
4. 이 README.md 상태 업데이트

```bash
# 예: phase1-001 시작
mv docs/backlogs/todo/phase1-001-architecture-first-planning.md \
   docs/backlogs/doing/
```

---

**Last Updated**: 2026-02-01
