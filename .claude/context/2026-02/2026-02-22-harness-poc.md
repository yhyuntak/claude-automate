# Session: Harness POC + 통합 설계 (2026-02-22)

## 이 세션에서 한 일

### 1. Context Bridge 패턴 POC
- statusline이 매 메시지마다 `context_window.used_percentage`를 stdin JSON으로 받는 것 확인
- statusline에서 `/tmp/claude-context-pct-{session_id}`에 컨텍스트 %를 기록하는 브릿지 구현
- Stop Hook에서 그 파일을 읽어서 임계값 이상이면 exit 2 + stderr로 Claude 차단
- stderr 메시지로 Claude에게 스킬 실행을 지시하면 실제로 스킬이 실행됨을 검증

### 2. Hook 메커니즘 검증
- exit 0: 정상 종료 허용
- exit 2: Claude 차단, stderr가 Claude에게 피드백으로 전달됨
- stop_hook_active: true일 때 exit 0으로 무한루프 방지 (한 턴에 한 번만 차단)
- 새 턴(사용자 메시지 후) stop_hook_active 리셋 확인

### 3. hooks.json 위치 발견
- `.claude/hooks.json`은 유효하지 않음
- `.claude/settings.json`에 hooks 설정을 넣어야 함
- 플러그인은 `hooks/hooks.json` 사용

### 4. compact vs clear 동작 확인
- /compact: session_id 유지, 컨텍스트만 압축
- /clear: session_id 변경, 새 세션 시작
- 결론: compact 대신 새 세션 시작이 깔끔 (plan 파일 + 세션 컨텍스트가 이어가기 담당)

### 5. 통합 하네스 설계 완성 (7개 스킬)

| 순서 | 스킬 | 역할 | 트리거 |
|------|------|------|--------|
| 1 | /start-work | 진입점 — plan/세션 컨텍스트 로드, 백로그 doing 이동 | 사용자 수동 |
| 2 | /brainstorm | 아이디어 → 요구사항 → AC 추출 → 테스트 가능 분류 | start-work에서 연결 |
| 3 | /planning | plan 파일 생성 (AC, 구현 순서, 테스트 계획) | brainstorm 후 |
| 4 | /implement | plan 기반 TDD 루프 (AC별: 테스트→구현→통과) | planning 후 또는 이어가기 |
| 5 | Stop Hook | 테스트 검증(exit 2) + 컨텍스트 감시(≥80% → exit 2) | 자동 (Claude 멈출 때) |
| 6 | /save-context | 세션 컨텍스트 저장만 (Hook 전용, 가벼움) | Stop Hook이 트리거 |
| 7 | /wrap | 전체 마무리 — 컨텍스트 저장 + 백로그 done + plan done + 커밋 | 사용자 수동 |

## 핵심 결정사항

### 1. brainstorm 필수 경유
- planning 직행 금지, brainstorm을 무조건 거침
- brainstorm에서 부족하면 이어가기 유도

### 2. 내장 plan mode 사용 안 함
- EnterPlanMode/ExitPlanMode 제거
- .claude/plans/{slug}.md에 직접 plan 파일 생성

### 3. plan 파일 상태 관리
- status: draft / in_progress / done (3가지만)
- abandoned 없음 — 안 할 거면 파일 삭제
- 날짜 + status 조합으로 start-work에서 판단
  - 최근 + in_progress → "이어갈까요?"
  - 오래된 + in_progress → "아직 할 건가요?"
  - draft → "시작할까요?"

### 4. /wrap vs /save-context 분리
- /wrap: 사용자 수동 실행 (작업 완료 시) — 전체 마무리
- /save-context: Stop Hook이 트리거 (컨텍스트 위기 시) — 저장만

### 5. Stop Hook은 /compact 실행 불가
- /compact는 빌트인 CLI 커맨드라 Claude가 프로그래밍적으로 실행 못함
- 대신 /save-context 후 "새 세션 시작하세요" 안내
- 사용자가 새 세션 → /start-work → plan 파일 읽고 이어감

### 6. start-work 개선 필요
- 현재 백로그 todo→doing 이동 로직 없음
- plan 파일 스캔 기능 없음
- 경로 오타 가능 (docs/backlog/ vs docs/backlogs/)
- 이번 하네스 강화에서 같이 수정

## 데이터 흐름

```
.claude/plans/*.md     ← planning 생성 (draft) / implement 갱신 (in_progress) / wrap 완료 (done)
.claude/context/*      ← save-context, wrap 저장 / start-work 로드
docs/backlogs/         ← start-work (todo→doing) / wrap (doing→done)
/tmp/claude-context-pct-{session_id} ← statusline 기록 / Stop Hook 읽기
```

## POC 파일 현황 (.claude/ 아래)

| 파일 | 용도 | 상태 |
|------|------|------|
| .claude/settings.json | Stop Hook 설정 | POC 활성 (80% 임계값) |
| .claude/hooks/session-stop-poc.sh | 브릿지 + exit 2 스크립트 | POC 동작 확인 |
| .claude/skills/test-hook/SKILL.md | Hook 스킬 트리거 테스트용 | POC 완료, 나중에 삭제 |
| .claude/commands/test-hook.md | 테스트 커맨드 래퍼 | POC 완료, 나중에 삭제 |
| ~/.claude/statusline-command.sh | 브릿지 기록 (1줄 추가) | 글로벌, 운영 중 |

## 플러그인 파일 변경

| 파일 | 변경 | 상태 |
|------|------|------|
| hooks/hooks.json | Stop Hook 비움 (POC 충돌 방지) | 임시, 나중에 복구 |
| hooks/session-stop.sh | 원래 /wrap 리마인더로 복구 | 정상 |

## 다음 세션에서 할 일

### 우선순위 1: 스킬 컨펌 마무리
- [x] brainstorm Phase 5 (AC 추출) — 컨펌 완료
- [ ] planning 스킬 변경 — 설계 완료, 컨펌 대기
- [ ] implement 스킬 (신규) — 설계 완료, 컨펌 대기
- [ ] Stop Hook 운영 설계 — POC 완료, 운영 설계 컨펌 대기
- [ ] save-context 스킬 (신규) — 새로 추가, 설계 필요
- [ ] start-work 개선 — 새로 추가, 설계 필요
- [ ] wrap 개선 — 새로 추가, 설계 필요

### 우선순위 2: 구현
- 컨펌 완료된 것부터 하나씩 구현
- POC 코드를 운영 코드로 전환

### 우선순위 3: 백로그 정리
- phase4-006 (AI+TDD) — 통합 설계로 흡수, 닫기
- phase4-007 (Verification Loop) — 통합 설계로 흡수, 닫기
- phase4-008 (Orchestrator) — 통합 설계로 흡수, 닫기

## 전체 아스키아트 (참고용)

```
새 세션 → /start-work (plan 스캔 + 백로그 선택)
            │
            ├─ plan 이어가기 → /implement (TDD 루프)
            │
            └─ 새 작업 → /brainstorm → /planning → /implement
                                                      │
                                                Stop Hook
                                                ├─ 테스트 실패 → 계속 수정
                                                ├─ 컨텍스트 80% → /save-context → 새 세션
                                                └─ 통과 → 종료

사용자 수동: /wrap (완료 시) — 컨텍스트 저장 + 백로그 done + 커밋
```

## start-work 재설계 (2026-02-22 추가)

### 전체 플로우

```
/start-work
  → Step 1: 세션 컨텍스트 로드 (최근 1개만)
  → Step 2: Plan 파일 스캔 (날짜 + status)
     ├─ in_progress → "이어갈까요?" → /implement
     ├─ draft → "시작할까요?" → /implement
     └─ 없음 → Step 3
  → Step 3: 백로그 선택
     - doing/ + todo/ 한 번에 표시
     - 선택 시 todo→doing 이동 + README 갱신
     - 또는 새로운 작업 (백로그 없이)
  → Step 4: 워크트리 (선택)
  → Step 5: 다음 액션
     ├─ plan 이어가기 → /implement
     └─ 새 작업 → /brainstorm 또는 질문/논의
```

### 현재 대비 변경점
- Plan 파일 스캔 기능 추가 (Step 2 신규)
- 백로그 todo→doing 이동 로직 추가
- README.md 자동 갱신 추가
- 다음 액션: 4가지 → 2가지 (brainstorm / 질문·논의), plan 이어가기 시 /implement
- brainstorm 필수 경유 (새 작업 시)
- 경로 수정: docs/backlog/ → docs/backlogs/

### Plan 파일 규칙
- 경로: `.claude/plans/{date}-{slug}.md`
- status: draft / in_progress / done (3가지)
- abandoned 없음 — 안 할 거면 삭제
- 날짜 + status 조합으로 판단

### 세션 컨텍스트 규칙
- 경로: `.claude/context/{YYYY-MM}/{YYYY-MM-DD}-{slug}.md`
- start-work에서 최근 1개만 로드

### 백로그 선택 화면
- doing/ + todo/ 통합 표시
- doing 항목은 🔄 진행 중으로 표시
- todo 항목은 📋 대기 중으로 표시
- 선택지: 번호 선택 / 새로운 작업 (백로그 없이)
