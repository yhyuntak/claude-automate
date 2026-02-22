# /implement 스킬 (신규)

> plan 파일 기반 구현 실행기 — TDD 루프 + 에이전틱 판단

---

## User Story

planning에서 plan 파일이 생성되면,
implement가 plan대로 묵묵히 구현을 실행한다.
사용자 개입 없이, Stop Hook만 감시한다.

## 하네스 내 위치

```
/start-work
     │
     ├── plan 이어가기 ──→ /implement ◀── 여기
     │
     └── 새 작업 ──→ /brainstorm → /planning → /implement
                                                    │
                                               Stop Hook
```

## Acceptance Criteria

### 스킬 구조
- [ ] plan 파일 로드 + status를 in_progress로 변경
- [ ] AC별 구현: 테스트 가능 → TDD, 테스트 불가 → 일반 구현
- [ ] 완료된 AC는 plan 파일에서 체크
- [ ] plan에 없는 작업은 하지 않는다
- [ ] 사용자에게 묻지 않는다

### frontmatter
- [ ] allowed-tools: Read, Write, Edit, Glob, Grep, LSP, Task, Bash
- [ ] 전체 쓰기 권한 (코드 작성 스킬)

### Stop Hook 연동
- [ ] 테스트 실패 시 Stop Hook이 exit 2 → 계속 수정
- [ ] 컨텍스트 ≥80% 시 Stop Hook이 exit 2 → /save-context → 새 세션

### 검증
- [ ] 모든 테스트 가능 AC의 테스트가 통과하는가?
- [ ] plan 파일의 AC 체크가 갱신되었는가?

## 비기능 요구사항

- plan대로 묵묵히 실행 (사용자 개입 최소)
- Stop Hook이 품질/컨텍스트 감시

## Dependencies

- phase4-019: AI 하네스 2.0 (전체 플로우 정의)
- phase4-021: /planning 스킬 재설계 (plan 파일 형식 정의)

---

**Last Updated**: 2026-02-22
