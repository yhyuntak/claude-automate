# Backlogs

> 프로젝트 뇌 시스템 구현 백로그

---

## 현황

| 상태 | 개수 |
|------|------|
| Todo | 5 |
| Doing | 1 |
| Done | 0 |

---

## Phase 1: brain.md 기반 구축

| Phase | ID | Title | Status |
|-------|-----|-------|--------|
| 1 | 001 | [brain.md 구조 정의](doing/phase1-001-brain-structure.md) | 🔄 Doing |
| 1 | 002 | [/start-work에 brain 로드](todo/phase1-002-start-work-brain-load.md) | Todo |
| 1 | 003 | [/wrap에 brain 업데이트](todo/phase1-003-wrap-brain-update.md) | Todo |

## Phase 2: 핵심 동작 개선

| Phase | ID | Title | Status |
|-------|-----|-------|--------|
| 2 | 001 | [핵심 동작 (Read/Analyze/Write) 개선](todo/phase2-001-core-operations.md) | Todo |
| 2 | 002 | [/wrap, /start-work 컨텍스트 최적화](todo/phase2-002-context-optimization.md) | Todo |

## Phase 3: 에이전트 고도화

| Phase | ID | Title | Status |
|-------|-----|-------|--------|
| 3 | 001 | [에이전트 고도화](todo/phase3-001-agents.md) | Todo |

---

## 의존성

```
phase1-001 (brain 구조)
    ├──→ phase1-002 (start-work)
    └──→ phase1-003 (wrap)
              │
              ▼
         phase2-001 (핵심 동작)
              │
              ▼
         phase2-002 (컨텍스트 최적화)
              │
              ▼
         phase3-001 (에이전트)
```

---

**Last Updated**: 2026-02-01
