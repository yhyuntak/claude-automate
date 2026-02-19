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

## A6: Everything Claude Code (Affaan Shaikh)

### 핵심 발견: ECC 연속 루프 아키텍처

**근본적 통찰**: ECC의 모든 메커니즘은 하나의 목적을 향한다 — "AI가 혼자 오래 돌아도 괜찮게"

**CA vs ECC 근본 차이**:
- **CA**: 세션 단위 (/start-work → 작업 → /wrap → 종료 → 새 세션). 사람이 적절한 단위로 끊고, 확인하고, 다시 시작.
- **ECC**: 연속 루프 (시작 → 작업 → compact → 계속 → compact → ...). AI가 끊기지 않고 계속 작업.

**ECC의 각 메커니즘이 연속 루프를 지원하는 방식**:
| 메커니즘 | 루프에서의 역할 |
|---------|---------------|
| Strategic Compact | 루프 중 토큰 관리 (50회→제안, 이후 25회마다) |
| PreCompact Hook | 압축 직전 TODO.md, DECISION.md 자동 저장 |
| SessionStart Hook | 재시작해도 상태 복원 |
| Stop Hook (Ralph Wiggum) | 종료 차단 + 프롬프트 재주입 → 계속 작업 |
| Verification Loop | 루프 중 품질 유지 (Build→Test→Lint→Security) |
| Continuous Learning | 루프 돌면서 패턴 축적 |

**철학적 의미**: "AI를 얼마나 신뢰하느냐"의 차이. ECC는 AI 자율성 최대화, CA는 사람 제어 최대화.

**CA 적용 시사점**: CA가 연속 루프를 도입할지, 세션 단위를 유지할지는 철학적 결정. 부분 도입(PreCompact 상태 저장만)도 가능.

---

## A7: AI 코딩에서의 TDD 전략

### 핵심 인사이트

**테스트 가치 구조의 역전**:
- **Unit Test**: AI 코딩에서 가치 낮음. AI가 코드와 테스트를 모두 작성하면 같은 오해를 양쪽에 넣을 수 있음
- **Acceptance Test**: 가치 높음. 사람이 방향을 정의하고 AI가 맞추는 기준
- **Integration Test**: 중간. 실제 연동 확인

**관점 전환**: 테스트를 "자산"이 아니라 "소모품"으로 봄 — AI가 2분만에 재생성 가능

**권장 워크플로우**:
1. 브레인스토밍 → AC(Acceptance Criteria) 구체화
2. 에이전트가 AC 기반 테스트 생성
3. 테스트 통과하도록 구현

**검증된 효과**: Boris Cherny 연구에서 AI+TDD 조합이 품질 2-3배 향상

**현장 적용**: ECC도 /orchestrate 체인에 tdd-guide를 포함하여 이 원칙 적용 중

### CA 적용 시사점

- **/brainstorm**에서 AC를 뽑아내는 수준까지 깊어져야 함
- 사람은 "뭘 만들 건지"만 관리, 테스트 코드 유지보수는 AI 몫
- CA의 "코드를 보지 않고 개발" 원칙과 자연스럽게 연결

---

## A8: ECC Continuous Learning → CA 2가지 학습 시스템 적용

### 핵심 인사이트

ECC의 관찰→패턴감지→분류→축적→신뢰도진화→활용 파이프라인이 CA의 두 가지 목적에 모두 적용 가능

### CA가 원하는 2가지 학습 시스템

| # | 대상 | 목적 | 저장소 | 현재 상태 |
|---|------|------|--------|----------|
| 1 | 사람 | 상위 개념 학습 (초보 개발자의 성장) | PARA Resources | 수동(/save-para) + 반자동(Planning 후 추출) |
| 2 | 프로젝트 | 패턴/아키텍처 자동 문서화 | 프로젝트 내 (미구현) | 없음 |

### ECC 파이프라인을 두 시스템에 매핑

**공통 원리**: 관찰 → 패턴 감지 → 신뢰도 → 축적 → 활용

**PARA(사람 학습)에 적용:**
- 관찰: 대화 중 상위 개념 등장 감지 (Planning 끝날 때만이 아니라 대화 중 아무 때나)
- 패턴 감지: "새로운 개념 논의 중" 인식
- 제안: "이거 PARA에 저장할까요?" (사람 확인 후 저장)
- 핵심: 사람이 "저장해" 안 해도 AI가 먼저 알아채는 것

**프로젝트 자동 문서화에 적용:**
- 관찰: AI가 코드 작성/수정할 때마다 기록
- 패턴 감지: 파일 구조, 기술 스택, 컨벤션 패턴 인식
- 신뢰도: 1번 봄 → 0.3, 3번 확인 → 0.6, 0.5 이상만 문서 반영
- 감쇠: 오래 안 쓰인 패턴 서서히 제거

**ECC 4카테고리 → 프로젝트 문서용 재정의:**
- corrections → conventions (코딩 컨벤션)
- error_resolutions → decisions (아키텍처 결정 + 이유)
- repeated_workflows → file_patterns (파일/폴더 구조)
- tool_preferences → tech_stack (기술 스택)

### CA 적용 시사점

- 같은 뼈대(관찰→감지→축적→활용), 다른 살(사람 학습 vs 프로젝트 이해도)
- 두 시스템은 독립적이지만 ECC의 동일한 원리에서 파생

---

## A9: Iterative Retrieval — 반복 정제 검색의 실전 가치

### 핵심 인사이트

단발 검색은 이름이 다양하거나 간접 연결된 코드를 놓친다. 4단계 반복 루프(DISPATCH→EVALUATE→REFINE→LOOP)로 검색 품질이 크게 향상된다.

### 실전 예시 — "로그인 관련 코드 찾기"

| 방식 | 검색 과정 | 발견 결과 |
|------|----------|----------|
| 단발 검색 | "login" grep 1회 | LoginPage, LoginButton (2개) — AuthService/useSession/middleware 놓침 |
| Iterative | 1차 "login" → 2차 "auth","session" (코드 내 import 추적) → 3차 "middleware" | 5개 모두 발견 |

### 효과가 큰 상황

- 이름이 다양한 경우 (login, auth, session, credential이 같은 도메인)
- 간접 연결 (A→B→C import 체인)
- 큰 프로젝트 (파일 수백 개)

### 효과가 작은 상황

- 작은 프로젝트, 단순 검색 → 오버헤드만 증가

### 종료 조건

관련성 0.7 이상 파일이 3개 이상 OR 반복 3회 도달

### CA 적용 시사점

- 현재 explore 에이전트는 단발 검색 → 끝
- Iterative Retrieval 루프를 explore에 내장하면 검색 품질 향상 가능
- 단, 작은 프로젝트에서는 불필요 → 프로젝트 규모에 따라 선택적 적용

---

## A10: Verification Loop — 자동 검증 파이프라인

### 핵심 인사이트

코드 작성 시점마다 Build→Type Check→Lint→Test→Security→Diff 순차 검증 + 실패 시 최대 3회 자동 재시도. Boris Cherny 워크플로우 기반 품질 2~3배 향상.

### ECC 방식

- PostToolUse Hook으로 코드 작성할 때마다 자동 트리거
- 각 단계 순서대로 실행, 하나 실패하면 다음으로 안 넘어감
- 실패 시 에러 메시지를 writer에게 전달 → 자동 수정 → 재시도 (최대 3회)
- 3회 실패 시 사람에게 보고

### CA와의 차이

- **CA**: /wrap 때 한꺼번에 검증 (이미 많이 작성한 뒤) + 자동 재시도 없음
- **ECC**: 쓸 때마다 검증 (문제를 일찍 잡음) + 자동 재시도 있음

### 트레이드오프

- (+) 문제를 조기 발견, 누적 에러 방지
- (-) 매번 돌리면 속도 저하 가능

### CA 적용 시사점

- /wrap의 검증 범위 확대 (패턴 체크 + 문서 동기화 → Build+Type+Lint+Test+Security 추가)
- 자동 재시도 로직 도입 (writer에게 에러 전달 → 수정 → 재검증)
- Hook 기반(매번) vs 커맨드 기반(수동) 선택 필요 — CA 철학에 따라 결정
- 중간 지점도 가능: 매번은 아니고 "구현 단위 완료 시" 자동 검증

---

## A11. Agent Chaining — CA형 orchestrator 설계

### 핵심 인사이트

ECC의 /orchestrate는 설계+실행을 모두 AI가 자동 처리 (planner→tdd→reviewer→security). CA에서는 brainstorm+planning(사람+AI)이 먼저 이루어지므로, orchestrator는 실행만 담당하는 형태가 자연스러움.

### CA형 orchestrator 흐름

- brainstorm → planning (사람+AI, 방향 확정) → orchestrator (실행만: tdd→writer→reviewer→security)
- ECC: "로그인 만들어" 한 줄로 설계+실행 전부 → 의도와 다를 수 있지만 감수 (AI 자율성 철학)
- CA: 사람이 방향 잡고 → orchestrator가 실행 → 의도 벗어남 방지 필요

### 의도 벗어남 방지 장치 = TDD

- brainstorm에서 나온 AC → Acceptance Test로 변환 → orchestrator 내 writer가 테스트 통과하도록 구현
- 테스트가 "사람의 의도"를 코드 기준으로 고정시키는 역할
- brainstorming을 깊게 할수록 → AC 정확 → 테스트 정확 → 결과가 의도에서 벗어나지 않음

---

## A12. TDD 적용 범위 — brainstorm이 자동으로 결정

### 핵심 인사이트

TDD가 모든 상황에 맞지는 않음. 하지만 별도 감지 로직이 필요 없음 — brainstorm 결과의 AC가 "통과/실패"로 표현 가능한지 여부가 자연스러운 신호.

### TDD 가능 판단 기준

| AC 유형 | 예시 | TDD 가능 |
|---------|------|---------|
| 조건부 동작 | "3회 실패 → 잠금" | ✅ |
| 입출력 명세 | "POST /login → 200 + token" | ✅ |
| 상태 변화 | "결제 후 잔액 차감" | ✅ |
| 감성적 | "깔끔한 UI" | ❌ |
| 탐색적 | "일단 만들어보자" | ❌ |

### 자연스러운 흐름

- brainstorm 마무리 시 AC를 정리하면 자동으로 분류됨
- AI가 "테스트 가능한 AC N개 → TDD, 나머지는 일반 구현"으로 제안
- 사람이 판단할 필요 없이 brainstorm 결과에서 나뉨

### CA 적용 시사점

- /brainstorm 스킬이 AC 정리 + TDD 가능 여부 분류까지 자연스럽게 확장
- TDD 강제가 아니라, AC가 구체적일 때만 자연스럽게 TDD 흐름을 탐

---

## A13. 3-Tier Model Selection — CA와 ECC의 공통 패턴

### 핵심 인사이트

CA와 ECC 모두 Haiku/Sonnet/Opus 3-Tier 모델 선택 전략을 사용. CA에 이미 구현되어 있는 몇 안 되는 공통 메커니즘.

### ECC 적용

| 역할 | Tier | 이유 |
|------|------|------|
| observer (패턴 감지) | Haiku | 단순 반복 |
| writer (코드 작성) | Sonnet | 표준 구현 |
| planner (설계) | Opus | 복잡한 의사결정 |
| doc-updater (문서 갱신) | Haiku | 반복적 작업 |

### CA 적용 (이미 구현)

- explore-low → Haiku, explore → Sonnet, explore-high → Opus
- writer → Sonnet, writer-high → Opus
- Agent Delegation Rules에 판단 기준 정의됨

### 유일한 차이

- **ECC**: orchestrator가 자동으로 적절한 tier 선택
- **CA**: 사람이 판단해서 적절한 에이전트 호출

### CA 적용 시사점

- 이미 잘 하고 있는 부분. 추가 작업 불필요.
- 향후 orchestrator 도입 시, tier 자동 선택 로직만 추가하면 됨.

---

## A14. Tool Restriction — 에이전트 권한 제어

### 핵심 인사이트

에이전트 역할 분리를 도구 접근 레벨에서 강제. CA와 ECC 모두 유사한 접근이지만 강제 수준이 다름.

### ECC 방식

| 에이전트 | Tier | 허용 도구 | 역할 |
|---------|------|---------|------|
| Architect/Planner | Opus | Read, Grep, Glob만 허용 | 설계만, 코드 수정 불가 |
| Writer | Sonnet | 전체 도구 사용 가능 | 구현 담당 |
| Doc-Updater | Haiku | 제한된 반복 작업만 | 문서 갱신 |

### CA 방식 (이미 구현)

| 에이전트 | 도구 제한 | 역할 |
|---------|---------|------|
| explore 에이전트 | 읽기 전용 (코드 수정 불가) | 탐색/분석 |
| writer 에이전트 | 전체 도구 | 구현 담당 |
| devil 에이전트 | 읽기 + 분석 (수정 불가) | 비판적 검토 |

### 핵심 차이

- **ECC**: 도구 접근 자체를 차단 (기술적 강제) — allowedTools 설정으로 물리적 제한
- **CA**: 프롬프트 규칙으로 제한 ("쓰지 마"라고 지시) — 소프트 제한
- ECC가 더 엄격하지만, CA도 실질적으로 동작함

### CA 적용 시사점

- 이미 잘 하고 있는 부분. 추가 작업 불필요.
- 더 엄격한 강제가 필요하면 Claude Code의 allowedTools 설정으로 기술적 차단 가능

---

## A15. Hierarchical Rules — ECC의 21개 규칙 체계 분석

### 핵심 인사이트

ECC는 common(8개) + 언어별(5개 x 3언어) = 21개 규칙 파일로 AI 행동을 통제. 규칙이 단순 코딩 컨벤션을 넘어 TDD 강제, 모델 선택, 에이전트 사용법까지 포함.

### common/ 8개 규칙 요약

| 규칙 파일 | 주요 내용 |
|----------|---------|
| coding-style | 불변성 필수, 파일 200-400줄, 함수 50줄, 중첩 4레벨 |
| git-workflow | Conventional Commits, TDD→Review→Commit 순서 강제 |
| testing | 커버리지 80% 최소, Unit+Integration+E2E 전부 필수, TDD RED→GREEN→IMPROVE 강제 |
| performance | 모델 선택 가이드(Haiku/Sonnet/Opus), 컨텍스트 마지막 20%에서 리팩토링 금지 |
| patterns | Repository 패턴, API Response 봉투 형식 |
| hooks | PreToolUse/PostToolUse/Stop 훅 사용 규칙 |
| agents | 9개 표준 에이전트 정의, 독립 작업은 항상 병렬 실행 |
| security | 커밋 전 보안 체크리스트 8항목, 시크릿 노출 시 즉시 STOP |

### 언어별 규칙 (각 5개 x 3언어)

- common의 추상 원칙을 언어별 구체 코드로 확장
- 예: 불변성 → TS는 spread, Python은 frozen dataclass, Go는 인터페이스 패턴
- paths 프론트매터로 해당 언어 파일 편집 시에만 자동 로드 (Progressive Disclosure)

### 흥미로운 발견 4가지

1. TDD가 규칙으로 강제됨 (testing.md + git-workflow.md 양쪽에서)
2. 모델 선택(Haiku/Sonnet/Opus)이 performance 규칙에 포함 — 코딩 컨벤션과 동급
3. paths 프론트매터로 언어별 규칙 자동 로딩 — 불필요한 규칙 미로드
4. 에이전트 사용법이 "규칙" — "코드 리뷰 에이전트를 써라" = 코딩 컨벤션과 같은 위상

### CA와 비교

| 항목 | CA | ECC |
|------|---|-----|
| 규칙 수 | 4개 (ops 중심) | 21개 (코딩+AI활용+보안 전부) |
| 구조 | 플랫 | 계층 (common + 언어별) |
| 언어 특화 | 없음 (언어 무관 설계) | 3언어별 5개씩 |

CA는 언어 무관 설계이므로 언어별 계층은 불필요. 단, "AI 활용 규칙"(모델 선택, 에이전트 사용법)을 규칙으로 격상시키는 아이디어는 참고할 만함.

---

## A16. Eval Harness — 에이전트 A/B 테스트 프레임워크

### 핵심 인사이트

control(기존) vs experimental(새 방식) 에이전트를 같은 입력에 돌리고, evaluator가 비교 평가하여 승자를 기본값으로 배포. "느낌"이 아닌 증거 기반 의사결정.

### 필요한 구성요소

1. 테스트 케이스 (같은 입력)
2. 실행 환경 (control + experimental 병렬 실행)
3. 평가 기준 (뭐가 더 나은지 판단)
4. 평가자 (evaluator 에이전트 또는 사람)
5. 결과 기록 (버전별 승패 추적)

### CA 적용 시사점

- 현재 단계에서는 과투자 (에이전트 수 적고, 프롬프트 미안정화)
- 에이전트 수도 적고 직접 결과 보면 판단 가능한 단계
- 필요해지는 시점: "프롬프트 바꿨는데 더 나아졌는지 모르겠다"가 반복될 때
- P3 (장기 과제)로 유지

---

## A17. Confidence Scoring — 신뢰도 기반 노이즈 필터링

### 핵심 인사이트

AI가 코드 리뷰 시 발견한 이슈에 신뢰도 점수(0-100)를 매기고, threshold(80) 이상만 보고. False positive를 줄여 사람의 리뷰 피로 방지.

### 작동 방식

- AI가 이슈 발견 시 각각에 신뢰도 점수 부여
- threshold 80 이상만 최종 보고서에 포함
- 낮은 점수는 false positive 가능성 높으므로 자동 필터링

### 효과

- AI 리뷰의 고질적 문제("지적은 많은데 쓸데없는 것 섞임") 해결
- 사람이 중요한 이슈에만 집중 가능
- 리뷰 피로도 감소

### CA 적용 시사점

- devil 에이전트가 현재 발견한 것 전부 보고 → 이슈 많아지면 중요한 게 묻힘
- devil에 신뢰도 점수 도입하면 보고 품질 향상 가능
- 다른 검증 에이전트(pattern-checker 등)에도 확장 가능

---

## A18. Session-Scoped State — 중복 경고 방지

### 핵심 인사이트

같은 파일+같은 규칙 조합에 대해 세션 내 한 번만 경고. 단순하지만 UX를 크게 개선하는 패턴.

### 작동 방식

- 상태 파일: `~/.claude/security_warnings_state_{session_id}.json`
- 키: `{파일경로}-{규칙이름}` → true (이미 경고함)
- 같은 조합은 세션 내에서 한 번만 경고, 반복 안 함
- 세션 끝나면 리셋
- 오래된 파일(30일+)은 10% 확률로 자동 정리 (probabilistic cleanup)

### 해결하는 문제

- AI가 파일 수정할 때마다 같은 경고 반복 → 사용자 피로
- 경고를 무시하게 되는 "경고 피로" 현상 방지

### CA 적용 시사점

- pattern-checker가 같은 패턴 위반 반복 보고 시 적용 가능
- devil 에이전트가 같은 이슈 반복 지적 시 적용 가능
- 구현 간단 (JSON 파일 하나), 효과 큼

---

## A19. Declarative Pattern Configuration — 선언적 패턴 설정

### 핵심 인사이트

보안/품질 규칙을 코드가 아닌 데이터(배열/JSON)로 정의. 규칙 추가 시 코드 수정 없이 항목만 추가하면 확장 가능.

### ECC 방식

- Python 배열로 보안 패턴 정의 (ruleName, substrings, reminder)
- 새 규칙 = 배열에 항목 추가 → 코드 변경 불필요
- 코드(로직)와 데이터(규칙)의 명확한 분리

### CA와 비교

- CA의 pattern-checker도 rules/*.md에 패턴 규칙 정의 → 이미 선언적 접근
- 차이: ECC는 코드 레벨(JSON/Python 배열)에서 선언적, CA는 문서 레벨(마크다운)에서 선언적
- CA 방식이 비개발자에게 더 접근성 높음 (마크다운으로 규칙 추가 가능)

### CA 적용 시사점

- 이미 부분적으로 하고 있는 부분
- 마크다운 기반 선언적 접근은 CA의 강점으로 유지할 만함

---

## 종합 정리: 19개 아티클에서 도출한 핵심 반영 포인트

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

### 6. ECC 연속 루프 아키텍처 (A6)
- CA는 세션 단위 제어, ECC는 연속 루프 (AI 자율성)
- ECC의 모든 메커니즘은 "AI가 혼자 오래 돌아도 괜찮게" 설계됨
- CA 적용 고려: PreCompact 상태 저장, SessionStart 복원 등 부분 도입 가능

### 사소한 피쳐
- PR 리뷰 자동화 (A2) — 워크트리 운영 시

---

### 7. AI+TDD 가치 구조 재정의 (A7)
- 테스트 레벨별 가치 역전: Acceptance Test > Integration > Unit
- 브레인스토밍→AC 구체화→에이전트 테스트 생성→구현 워크플로우
- /brainstorm 심화 필요 (AC 추출까지)

### 8. ECC Continuous Learning → CA 2가지 학습 시스템 (A8)
- ECC 파이프라인(관찰→감지→축적→활용)을 사람 학습과 프로젝트 문서화에 각각 적용 가능
- 사람 학습: AI가 먼저 개념 감지 후 PARA 저장 제안 (현재 수동/반자동 → 자동 감지로 개선 여지)
- 프로젝트 문서화: 코드 작성 중 패턴 관찰 → 신뢰도 기반 문서 반영 (미구현)
- ECC 4카테고리 재정의: corrections→conventions, error_resolutions→decisions, repeated_workflows→file_patterns, tool_preferences→tech_stack

### 9. Iterative Retrieval — 반복 정제 검색 (A9)
- 단발 grep은 이름이 다양하거나 간접 연결된 코드를 놓침
- DISPATCH→EVALUATE→REFINE→LOOP 4단계 루프로 검색 품질 향상
- 큰 프로젝트, 도메인 이름 다양, import 체인 깊은 경우에 효과 큼
- 작은 프로젝트에서는 오버헤드 → 프로젝트 규모에 따라 선택적 적용
- CA 적용: explore 에이전트에 Iterative Retrieval 루프 내장 가능

### 10. Verification Loop — 자동 검증 파이프라인 (A10)
- 코드 작성 시점마다 Build→Type Check→Lint→Test→Security→Diff 순차 검증
- ECC: PostToolUse Hook 자동 트리거 + 실패 시 최대 3회 자동 재시도
- CA: /wrap 때 한꺼번에 검증 vs ECC: 쓸 때마다 검증 (조기 발견)
- CA 적용: /wrap 검증 범위 확대 + 자동 재시도 로직 도입
- 선택지: Hook 기반(매번) vs 커맨드 기반(수동) vs 중간 지점(구현 단위 완료 시)

### 11. CA형 orchestrator 설계 (A11)
- ECC orchestrator: 설계+실행 모두 AI 자동 처리 (AI 자율성 극대화)
- CA orchestrator: brainstorm+planning(사람+AI)이 먼저 → orchestrator는 실행만 담당
- TDD가 의도 벗어남 방지 장치: brainstorm AC → Acceptance Test → 구현
- brainstorming 깊이 = AC 정확도 = orchestrator 결과의 의도 충실도

### 12. TDD 적용 범위 — brainstorm이 자동으로 결정 (A12)
- TDD 가능 여부를 별도 감지 로직 없이 brainstorm 결과 AC에서 자연스럽게 판별
- AC가 "통과/실패"로 표현 가능(조건부 동작, 입출력 명세, 상태 변화)하면 TDD 가능
- AC가 감성적이거나 탐색적이면 TDD 불가 → 일반 구현
- CA 적용: /brainstorm 스킬이 AC 정리 + TDD 가능 여부 분류까지 자연스럽게 확장

### 13. 3-Tier Model Selection — CA와 ECC의 공통 패턴 (A13)
- CA와 ECC 모두 Haiku/Sonnet/Opus 3-Tier 모델 선택 전략 공유 (이미 구현된 공통점)
- ECC: observer→Haiku, writer→Sonnet, planner→Opus, doc-updater→Haiku
- CA: explore-low→Haiku, explore→Sonnet, explore-high→Opus, writer→Sonnet, writer-high→Opus
- 유일한 차이: ECC는 orchestrator가 자동 tier 선택, CA는 사람이 판단해서 호출
- CA 적용: 이미 잘 하고 있는 부분. 향후 orchestrator 도입 시 tier 자동 선택 로직만 추가하면 됨.

### 14. Tool Restriction — 에이전트 권한 제어 (A14)
- ECC: allowedTools 설정으로 도구 접근 자체를 물리적으로 차단 (Architect/Planner → Read/Grep/Glob만)
- CA: 프롬프트 규칙으로 소프트 제한 (explore → 읽기 전용, writer → 전체, devil → 읽기+분석)
- ECC가 더 엄격하지만, CA도 실질적으로 동작함
- CA 적용: 이미 잘 하고 있는 부분. 더 엄격한 강제가 필요하면 allowedTools 설정으로 기술적 차단 가능

### 15. Hierarchical Rules — ECC의 21개 규칙 체계 (A15)
- ECC: common 8개 + 언어별(TS/Python/Go) 5개씩 = 21개 규칙으로 AI 행동 통제
- 단순 코딩 컨벤션을 넘어 TDD 강제, 모델 선택, 에이전트 사용법까지 "규칙"으로 격상
- paths 프론트매터로 언어별 규칙 자동 로딩 (Progressive Disclosure 실현)
- CA는 언어 무관 설계라 언어별 계층 불필요. 단, "AI 활용 방식을 규칙으로 명문화"하는 접근은 참고 가치 있음

### 16. Eval Harness — 에이전트 A/B 테스트 프레임워크 (A16)
- control(기존) vs experimental(새 방식) 에이전트를 같은 입력에 돌려 evaluator가 승자를 결정 → 증거 기반 의사결정
- 구성요소: 테스트 케이스 + 병렬 실행 환경 + 평가 기준 + evaluator + 결과 기록
- 현재 CA 단계에서는 과투자 (에이전트 수 적고, 프롬프트 미안정화)
- 필요해지는 시점: "프롬프트 바꿨는데 더 나아졌는지 모르겠다"가 반복될 때
- P3 (장기 과제)로 유지

### 17. Confidence Scoring — 신뢰도 기반 노이즈 필터링 (A17)
- AI 리뷰 이슈에 신뢰도 점수(0-100) 부여 → threshold(80) 이상만 보고
- AI 리뷰의 고질적 문제("지적은 많은데 쓸데없는 것 섞임") 해결 → false positive 자동 필터링
- 사람이 중요한 이슈에만 집중 가능하고 리뷰 피로도 감소
- CA 적용: devil 에이전트에 신뢰도 점수 도입 → 보고 품질 향상. pattern-checker 등 다른 검증 에이전트에도 확장 가능

### 18. Session-Scoped State — 중복 경고 방지 (A18)
- 같은 파일+같은 규칙 조합에 대해 세션 내 한 번만 경고 → "경고 피로" 방지
- 상태 파일(`~/.claude/security_warnings_state_{session_id}.json`) 하나로 구현, 세션 끝나면 리셋
- 오래된 파일 10% 확률 자동 정리 (probabilistic cleanup)
- CA 적용: pattern-checker 반복 보고, devil 에이전트 반복 지적 방지에 적용 가능. 구현 간단, 효과 큼

### 19. Declarative Pattern Configuration — 선언적 패턴 설정 (A19)
- 보안/품질 규칙을 코드가 아닌 데이터(배열/JSON)로 정의 → 규칙 추가 시 코드 수정 없이 항목만 추가하면 확장 가능
- ECC: Python 배열로 ruleName/substrings/reminder 정의, 코드(로직)와 데이터(규칙) 명확히 분리
- CA: rules/*.md(마크다운)에 패턴 규칙 정의 → 이미 선언적 접근, 비개발자에게 더 접근성 높음
- CA 적용: 이미 부분적으로 하고 있는 부분. 마크다운 기반 선언적 접근은 CA의 강점으로 유지할 만함

---

**Last Updated**: 2026-02-19
