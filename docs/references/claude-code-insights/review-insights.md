# 아티클 리뷰 인사이트

> phase4-002: 아티클 리뷰에서 도출한 하네스 반영 포인트

---

## A1: Claude Code 창시자 워크플로우 (Boris Cherny)

### 스킵
- 병렬 인스턴스 (별도 checkout) — worktree 대신 현실적이나 현재 적용 불필요
- Opus 선택 — 이미 적용 중
- Plan → Auto-accept 패턴 — 이미 적용 중

### 반영 포인트

**1. Brain 활성화 (프로젝트 지식 축적)**
- 현황: brain.md 설계는 있으나 실제 기록/작동 안 함
- Boris: 팀마다 CLAUDE.md에 실수/best practices 축적 → Claude가 학습
- 우리 Brain: 프로젝트 아키텍처, 패턴, 코드맵 (기술 지식)
- Boris의 CLAUDE.md: Claude가 반복하는 실수, 작업 규칙 (행동 규칙)
- 과제: 두 레이어 모두 실제로 축적되는 구조 필요

**2. 전역 Hook 체계**
- 현황: hooks.json 기반 자동화 없음, /wrap에서 수동 검증만
- Boris: PostToolUse hook으로 bun run format 자동 실행
- 과제: 전역 플러그인으로서 모든 프로젝트에 적용될 Hook 설계 필요
- 참고: Hook은 린트뿐 아니라 모든 셸 명령 가능

**3. Verification Loop 확장**
- 현황: verify-web-ui (UI e2e)만 존재
- Boris: 테스트/브라우저/시뮬레이터로 모든 변경 검증 → 품질 2-3배 향상
- 과제: 전역으로 적용 가능한 검증 루프 설계 필요

---

## A2: How I Use Claude Code (Steve Sewell, Builder.io)

### 스킵
- 대부분 사용 팁 위주 (단축키, 퍼미션, /clear 등)

### 사소한 피쳐
- **PR 리뷰 자동화**: 워크트리 여러 개 운영 시 PR 리뷰 시스템 유용할 수 있음. `/install-github-app` + 버그/보안 중심 커스텀 프롬프트

## A3: Claude Code Best Practices (Anthropic 공식)

### 기존 방향 검증
- 우리 하네스가 이미 공식 Best Practices 대부분 커버 중 (검증, Plan→Code, subagent 위임, CLAUDE.md 관리)

### 반영 포인트

**1. Hook = deterministic, CLAUDE.md = advisory**
- CLAUDE.md 지시는 무시 가능, Hook은 무조건 실행
- `/wrap` 수동 검증 → Hook 자동화로 전환 가능성

**2. Hook 기능이 매우 강력**
- 3가지 타입: command (셸), prompt (LLM 1회), agent (LLM 다회전+도구)
- 14가지 이벤트: SessionStart, PreToolUse, PostToolUse, Stop, TaskCompleted 등
- **플러그인 hooks/hooks.json으로 배포하면 설치한 모든 프로젝트에 자동 적용**
- Stop hook (agent 타입): Claude 멈추기 전 자동 검증 루프 가능
- SessionStart(compact): 컨텍스트 압축 후 중요 정보 재주입
- TaskCompleted: 태스크 완료 전 품질 게이트

## A4: How I Use Every Claude Code Feature (Shrivu Shankar)

### 스킵
- CLAUDE.md 30% 규칙, 가드레일 접근 — A1/A3과 중복
- Hook Block-at-Submit + Hint — A1과 같은 맥락
- GHA 데이터 기반 CLAUDE.md 개선 — 참고만

### 논쟁 포인트

**1. "자율성 vs 제어" 논쟁**
- Shankar: 커스텀 명령 최소화 (/catchup, /pr만), 에이전트 자율성 극대화
- 우리: 스킬/커맨드로 워크플로우 패턴화 (Harness = 운전대)
- Shankar: 커스텀 subagent 대신 Task() 동적 위임 선호
- 우리: writer/explore 등 역할별 사전 정의 (모델 티어 + 도구 제한 제어)
- **결론**: 철학 차이. "shoot and forget" vs "driver controls harness". 단, "너무 많으면 방해" 경고는 유효

**2. "Document & Clear" 패턴**
- 진행상황을 마크다운에 덤프 후 /clear
- 우리 /wrap의 세션 컨텍스트 저장과 유사한 개념

## A5: 32 Claude Code Tips (YK, Agentic Coding)

### 스킵
- 대부분 사용 팁/트릭 위주 (Git, /fork, tmux, voice 등)
- Tip 24 (CLAUDE.md vs Skills vs Commands) — 우리가 이미 적용 중인 구조 확인

### 반영 포인트

**1. MCP 레이지 로드 (Tip 14)**
- `ENABLE_TOOL_SEARCH` 설정으로 MCP 도구 필요시만 로드
- 시스템 프롬프트 18k→10k 토큰 (41% 절약)
- Playwright 등 프로젝트별 불필요한 MCP 로드 방지에 유효

### 참고
- Tip 0 (Status Line 커스텀) — 세팅 시도 중 미해결

---

## 종합 정리: 5개 아티클에서 도출한 핵심 반영 포인트

### 1. Brain 활성화 (A1)
- brain.md 설계는 있으나 실제 작동 안 함
- 프로젝트 지식(아키, 패턴, 코드맵) 축적 구조 필요

### 2. 전역 Hook 체계 (A1, A3)
- 플러그인 hooks/hooks.json으로 전역 배포 가능
- 3가지 타입 (command/prompt/agent), 14가지 이벤트
- /wrap 수동 검증 → Hook 자동화 전환 가능성
- Stop hook으로 자동 검증 루프, TaskCompleted로 품질 게이트

### 3. Verification Loop 확장 (A1, A3)
- UI e2e 외에 전역 적용 가능한 검증 루프 필요
- Hook 기반 자동 검증이 해답일 수 있음

### 4. MCP 레이지 로드 (A5)
- 프로젝트별 불필요한 MCP 토큰 절약

### 5. "자율성 vs 제어" 인식 (A4)
- 우리 Harness 철학과 반대 의견 존재
- "너무 많은 커스텀 명령은 방해" 경고 유효

### 사소한 피쳐
- PR 리뷰 자동화 (A2) — 워크트리 운영 시

---

**Last Updated**: 2026-02-15
