# Stop Hook 운영 설계

> 자동 테스트 검증 + 컨텍스트 감시 — implement 품질 보호

---

## User Story

implement 중 Claude가 멈출 때마다 자동으로
테스트 통과 여부와 컨텍스트 사용량을 확인하여
품질과 세션 안정성을 보호한다.

## 하네스 내 위치

```
/implement (TDD 루프)
     │
     ▼
Stop Hook (자동) ◀── 여기
  ① 테스트 실패 → exit 2 → 계속 수정
  ② 컨텍스트 ≥75% → exit 2 → /save-context
  ③ 통과 → exit 0
```

## Acceptance Criteria

### 테스트 검증
- [ ] .claude/plans/*.md에서 status: in_progress인 파일 탐색
- [ ] 없으면 테스트 스킵 (implement 중 아님)
- [ ] 있으면 frontmatter의 test-command 읽기
- [ ] test-command 실행 → 실패 시 exit 2 + stderr "테스트 실패"

### 컨텍스트 감시
- [ ] /tmp/claude-context-pct-{session_id}에서 사용률 읽기
- [ ] ≥75% → exit 2 + stderr "/save-context 실행해"
- [ ] <75% → 통과

### 무한루프 방지
- [ ] stop_hook_active 플래그로 한 턴에 한 번만 차단

### POC → 운영 전환
- [ ] POC 스크립트를 운영 스크립트로 교체
- [ ] 임계값 80% → 75% 변경

## Dependencies

- phase4-019: AI 하네스 2.0 (전체 플로우 정의)
- phase4-022: /implement 스킬 (test-command 실행 대상)

---

**Last Updated**: 2026-02-22
