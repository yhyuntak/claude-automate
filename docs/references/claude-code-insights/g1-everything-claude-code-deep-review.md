---
id: G1-deep
title: Everything Claude Code Deep Review
author: Affaan Mustafa (42K+ stars)
url: https://github.com/affaan-m/everything-claude-code
version: v1.4.1
fetched: 2026-02-16
phase: phase4-003
---

# Everything Claude Code Deep Review

> 토큰 절약과 자동화에 최적화된 프로덕션급 하네스 — 메커니즘 분석과 적용 전략

---

## 1. 설계 철학 비교

### 1.1 ECC의 Token-First 철학

**Everything Claude Code**는 "Context Rot" 방지를 최우선으로 둔다.

핵심 인용 (the-longform-guide.md):
```
"Context decay isn't about running out of context—
it's about context becoming stale."
```

이 철학에서 파생된 설계 원칙:

1. **MCP 대체 전략**: MCP 서버를 최소화하고 CLI-wrapped skills로 교체
   - 이유: MCP는 시스템 프롬프트에 18k+ 토큰 로드 (the-shortform-guide.md)
   - 해결: 필요한 기능만 skill로 재구현 → 토큰 절감

2. **Dynamic System Prompt**: 모드별 컨텍스트 주입
   - `--system-prompt "$(cat contexts/dev.md)"` 패턴 (contexts/ 참조)
   - dev/research/review 모드에 따라 다른 행동 규칙 로드

3. **Minimum Viable Parallelization**: 병렬화를 최소한으로
   - `/fork`보다 subagent 위임 선호
   - 이유: 컨텍스트 분산이 오히려 비효율 초래 가능

4. **Strategic Compact**: 도구 사용 50회마다 compaction 제안
   - PreToolUse hook에서 자동 카운팅 (suggest-compact.js)
   - Phase 전환 시점에만 compact 권장

### 1.2 CA의 Harness-First 철학

**claude-automate**는 "개발자가 AI를 제어하는 운전대" 역할에 집중한다.

핵심 인용 (CLAUDE.md):
```
"코드를 보지 않고 개발 —
아키텍처/패턴/아이디어 레벨에 집중"
```

이 철학에서 파생된 설계 원칙:

1. **에이전트 위임 체계**: 역할 기반 분리
   - explore-low/explore/explore-high (Haiku/Sonnet/Opus)
   - writer/writer-high (Sonnet/Opus)
   - 각 역할에 도구 제한 및 모델 티어 사전 정의

2. **세션 컨텍스트 저장**: 명시적 관리
   - `/start-work` → 이전 세션 컨텍스트 로드
   - `/wrap` → 검증 + 세션 저장
   - `.claude/context/{날짜}/` 디렉토리에 저장

3. **성장하는 시스템**: 학습 축적
   - PARA 기반 지식 관리
   - Planning 후 개념 추출 → Resources에 저장
   - brain.md 설계 (실제 작동은 미구현)

4. **Progressive Disclosure**: 필요시 로드
   - CLAUDE.md (항상 로드)
   - rules/*.md (필요시 로드)
   - docs/references/*.md (배경 지식)
   - skills/*/references/*.md (스킬 사용시)

### 1.3 핵심 차이

| 관점 | ECC | CA |
|------|-----|-----|
| 목표 | 더 적은 토큰으로 더 나은 결과 | 더 나은 통제로 더 나은 결과 |
| 컨텍스트 | 신선함 유지 (compact + 최소 로드) | 누적 + 명시적 관리 (wrap/start-work) |
| 자동화 | Hook 기반 자동화 극대화 | 수동 워크플로우 + 명시적 검증 |
| 병렬화 | Minimum Viable | 병렬 가능한 작업은 동시 호출 |
| 학습 | 자동 (Continuous Learning v2) | 수동 (PARA 축적) |
| MCP | 최소화 (CLI skill 대체) | 필요시 사용 |

**철학적 대립**:
- ECC: "자율성 극대화 — AI가 알아서 하게"
- CA: "제어 극대화 — 개발자가 운전대를"

이 차이는 **안티 골** 정의에서도 드러난다:
- ECC: "Context rot으로 인한 품질 저하" 방지
- CA: "이해하지 못한 채 복사하는 것" 방지

---

## 2. 아키텍처 분석

### 2.1 Agents (13개)

#### 2.1.1 3-Tier Model

| Tier | 모델 | 에이전트 | 역할 |
|------|------|---------|------|
| Opus | opus-4-6 | architect, planner | 의사결정 (읽기 전용) |
| Sonnet | sonnet-4-5 | 10개 | 실행 (도구 사용 가능) |
| Haiku | haiku-4 | doc-updater | 단순 반복 작업 |

**핵심 패턴: Tool Restriction**

architect.md, planner.md는 Read/Grep/Glob만 사용 가능:
```markdown
## Tool Permissions
- Read (allowed)
- Grep (allowed)
- Glob (allowed)
- Edit, Write, Bash (forbidden)
```

**설계 의도**: Opus의 고비용 + 읽기 전용 = 의사결정과 실행 분리

#### 2.1.2 PROACTIVE 호출

각 에이전트 description에 명시:
```markdown
## When to Use
Use this agent PROACTIVELY whenever:
- Planning a new feature
- Before writing any code
- When making architectural decisions
```

**대조**: CA의 에이전트는 명시적 호출만 허용 (agent-delegation.md)

#### 2.1.3 Agent Chaining

orchestrate.md 커맨드에서 체인 정의:
```
planner → tdd-guide → code-reviewer → security-reviewer
```

각 에이전트의 출력이 다음 에이전트의 입력으로 전달.

#### 2.1.4 언어 특화 에이전트

- go-build-resolver.md: Go 빌드 에러 특화
- go-reviewer.md: Go 코드 리뷰 (gofmt, go vet 등)
- python-reviewer.md: Python 코드 리뷰 (PEP8, type hints 등)
- database-reviewer.md: 스키마 변경 검토

**대조**: CA는 범용 에이전트 5개만 존재. 언어 특화 부재.

#### 2.1.5 CA 대응

| ECC | CA | 비고 |
|-----|-----|------|
| planner (Opus) | - | 부재 |
| architect (Opus) | - | 부재 |
| tdd-guide (Sonnet) | - | 부재 |
| code-reviewer (Sonnet) | - | 부재 |
| security-reviewer (Sonnet) | - | 부재 |
| e2e-runner (Sonnet) | - | 부재 |
| refactor-cleaner (Sonnet) | - | 부재 |
| doc-updater (Haiku) | - | 부재 |
| - | explore-low (Haiku) | 단순 탐색 |
| - | explore (Sonnet) | 구조 파악 |
| - | explore-high (Opus) | 아키텍처 분석 |
| - | writer (Sonnet) | 코드 작성 |
| - | writer-high (Opus) | 복잡 구현 |

**Gap**: ECC는 워크플로우별 (plan/tdd/review), CA는 작업 유형별 (explore/write)

---

### 2.2 Skills (37개)

#### 2.2.1 카테고리 분류

| 카테고리 | 개수 | 예시 |
|---------|------|------|
| Framework & Language | 16 | django-*, springboot-*, golang-*, python-* |
| Database | 3 | postgres-patterns, clickhouse-io, database-migrations |
| Workflow & Quality | 8 | continuous-learning-v2, strategic-compact, verification-loop |
| Infrastructure | 4 | docker-patterns, deployment-patterns |
| Testing | 3 | tdd-workflow, e2e-testing, cpp-testing |
| Meta | 3 | eval-harness, configure-ecc, iterative-retrieval |

#### 2.2.2 핵심 스킬 상세

**continuous-learning-v2** (SKILL.md + config.json 패턴):
- 관찰 데이터 수집 → 패턴 탐지 → instinct 저장 → skill/command 생성
- Confidence 기반 진화 (0.3 ~ 0.85)
- 상세 분석: 4.1절 참조

**strategic-compact** (SKILL.md + suggest-compact.js):
- 50회 첫 제안, 이후 25회마다 반복
- Compaction Decision Guide 제공
- 상세 분석: 4.2절 참조

**eval-harness** (Evidence-Driven Development):
- 스킬/에이전트 A/B 테스팅
- 3-agent pipeline: control-agent, experimental-agent, evaluator-agent
- Output quality 비교 후 승자 선택

**iterative-retrieval** (4-phase loop):
- DISPATCH → EVALUATE → REFINE → LOOP
- 최대 3회 반복, relevance >= 0.7 파일 3개+ 조건
- 상세 분석: 4.4절 참조

**verification-loop** (build+type+lint+test+security):
- 코드 변경 후 자동 검증 루프
- Boris Cherny 워크플로우 기반 (품질 2-3배 향상)
- 실패 시 자동 수정 시도 (최대 3회)

**security-review** (SKILL.md + cloud-infrastructure-security.md):
- OWASP Top 10 체크리스트
- 클라우드 인프라 보안 검토
- security-reviewer 에이전트와 연계

**configure-ecc** (interactive wizard):
- 언어 선택 → 규칙 설치 → MCP 설정
- install.sh를 대화형으로 래핑

#### 2.2.3 config.json 보조 패턴

continuous-learning-v2/config.json:
```json
{
  "observer": {
    "schedule": "*/5 * * * *",
    "model": "haiku",
    "max_turns": 3
  },
  "instinct": {
    "confidence_decay": 0.02,
    "min_confidence": 0.3
  }
}
```

**활용**: 스킬별 설정을 JSON으로 분리 → SKILL.md는 개념, config.json은 파라미터

#### 2.2.4 스킬 간 의존성

- django-tdd → django-patterns (TDD는 패턴 지식 필요)
- springboot-tdd → springboot-patterns
- continuous-learning-v2 → continuous-learning (v1 기반 확장)
- django-verification → verification-loop (검증 로직 재사용)

**패턴**: 기본 스킬 + 특화 스킬 계층 구조

#### 2.2.5 CA 대응

| ECC | CA | 비고 |
|-----|-----|------|
| 37개 | 1개 (backlog) | **압도적 Gap** |
| continuous-learning-v2 | - | 자동 학습 부재 |
| verification-loop | verify-web-ui | 범용 검증 부재 |
| security-review | - | 보안 검토 부재 |
| eval-harness | - | A/B 테스팅 부재 |
| iterative-retrieval | - | explore에 미구현 |
| strategic-compact | - | 컨텍스트 관리 부재 |

---

### 2.3 Commands (31개)

#### 2.3.1 카테고리 분류

| 카테고리 | 개수 | 예시 |
|---------|------|------|
| Workflow | 5 | plan, tdd, orchestrate, checkpoint, sessions |
| Multi-Model | 5 | multi-plan, multi-execute, multi-backend, multi-frontend, multi-workflow |
| Code Quality | 5 | code-review, refactor-clean, verify, build-fix, test-coverage |
| Language-Specific | 4 | go-build, go-review, go-test, python-review |
| Learning | 6 | learn, evolve, instinct-status, instinct-import, instinct-export, skill-create |
| Documentation | 2 | update-docs, update-codemaps |
| Infrastructure | 4 | e2e, pm2, setup-pm, eval |

#### 2.3.2 Multi-Model Collaboration (CCG)

**Codex+Gemini 협업 메커니즘**:

multi-execute.md:
```markdown
## Workflow
1. Claude (Code Sovereign) → 전략 수립
2. Codex (via codeagent-wrapper) → 코드 생성
3. Gemini (via codeagent-wrapper) → 대안 제시
4. Claude → 통합 + 최종 결정
```

**codeagent-wrapper**: OpenAI/Google API 호출을 Claude 도구처럼 래핑

**설계 의도**:
- Claude의 추론력 + Codex의 코드 생성력 + Gemini의 창의성
- Claude가 "Code Sovereign" 역할로 최종 통제

**현실성 판단**: 복잡도 높음, API 비용 증가, 실제 효용은 불확실

#### 2.3.3 $ARGUMENTS 인자 전달

plan.md:
```markdown
When user invokes: /plan "Add user authentication"

$ARGUMENTS is replaced with: "Add user authentication"

Full prompt becomes:
  "You are an expert planner. Create a plan for: Add user authentication"
```

**메커니즘**: Claude Code CLI가 `$ARGUMENTS`를 실제 인자로 치환

#### 2.3.4 disable-model-invocation 패턴

checkpoint.md (프론트매터):
```yaml
disable-model-invocation: true
```

**의미**: LLM 호출 없이 스크립트만 실행 (순수 CLI 도구)

**활용 예시**:
- checkpoint.md → git commit + session 저장
- sessions.md → 세션 목록 출력
- setup-pm.md → 패키지 매니저 설정

#### 2.3.5 CA 대응

| ECC | CA | 비고 |
|-----|-----|------|
| 31개 | 2개 (wrap, start-work) | **압도적 Gap** |
| orchestrate | - | Agent chaining 부재 |
| verify | verify-web-ui | 범용 검증 부재 |
| plan | - | Planning 커맨드 부재 |
| tdd | - | TDD 워크플로우 부재 |
| code-review | - | 코드 리뷰 부재 |
| learn/evolve | - | 학습 커맨드 부재 |
| update-docs | - | 문서 동기화 부재 |

---

### 2.4 Rules (23개 = common 8 + language 15)

#### 2.4.1 계층적 상속 구조

```
rules/
├── common/
│   ├── coding-style.md
│   ├── hooks.md
│   ├── patterns.md
│   ├── security.md
│   ├── testing.md
│   ├── git-workflow.md
│   ├── performance.md
│   └── agents.md
├── typescript/
│   ├── coding-style.md
│   ├── hooks.md
│   ├── patterns.md
│   ├── security.md
│   └── testing.md
├── python/
│   └── (동일 구조)
└── golang/
    └── (동일 구조)
```

**패턴**: 각 언어 파일 첫 줄에 상속 명시

typescript/coding-style.md:
```markdown
# TypeScript Coding Style

This file extends ../common/coding-style.md with TypeScript specific content.

## TypeScript Specific Rules
...
```

**효과**:
- common/ = 추상 기반 (모든 언어 공통)
- <language>/ = 구체 구현 (언어별 특화)
- 상대 경로 참조 유지 (install.sh가 구조 보존)

#### 2.4.2 5+1 카테고리

| 카테고리 | common | typescript | python | golang | 설명 |
|---------|--------|-----------|---------|--------|------|
| coding-style | O | O | O | O | 포맷, 네이밍, 컨벤션 |
| hooks | O | O | O | O | Hook 사용 패턴 |
| patterns | O | O | O | O | 디자인 패턴, 아키텍처 |
| security | O | O | O | O | 보안 체크리스트 |
| testing | O | O | O | O | 테스트 전략 |
| agents | O | - | - | - | 에이전트 사용 규칙 |

**common/agents.md**:
```markdown
## Agent Delegation Rules

- Use architect for system design decisions
- Use planner for feature planning
- Use tdd-guide when starting new features
- Chain agents with orchestrate for complex workflows
```

#### 2.4.3 ECC에 CLAUDE.md 없음

**대신**:
- `.claude-plugin/plugin.json` = 프로젝트 정체성 (메타데이터)
- `rules/` = 세부 규칙 (행동 규칙)
- `the-shortform-guide.md` + `the-longform-guide.md` = 철학/원칙

**철학 차이**:
- ECC: "플러그인 = 배포 가능한 도구 모음" (정체성 최소화)
- CA: "CLAUDE.md = 프로젝트 정체성 선언" (정체성 최대화)

#### 2.4.4 CA 대응

| ECC | CA | 비고 |
|-----|-----|------|
| common 8개 | 운영 규칙 4개 | agent-delegation, workflow, interaction, backlog-rules |
| typescript 5개 | - | 코딩 품질 규칙 부재 |
| python 5개 | - | 코딩 품질 규칙 부재 |
| golang 5개 | - | 코딩 품질 규칙 부재 |

**Gap 분석**:
- CA는 **운영 규칙**에 집중 (어떻게 일하는가)
- ECC는 **코딩 품질 규칙**에 집중 (어떻게 코딩하는가)

---

### 2.5 Hooks (14 entries, 6 event types)

#### 2.5.1 이벤트별 분류

**PreToolUse (5개)**:
- dev-server-block.sh: 개발 서버 실행 차단 (exit 2)
- tmux-reminder.sh: tmux 사용 권장 (stderr 메시지)
- git-push-reminder.sh: git push 전 확인 (stderr)
- doc-file-block.sh: .md 파일 Edit/Write 차단 (exit 2)
- suggest-compact.js: 50회마다 compaction 제안

**PostToolUse (5개)**:
- log-pr.sh: PR 관련 활동 로그
- analyze-build.sh: 빌드 로그 분석 (async: true)
- prettier-format.js: Prettier 자동 실행
- typescript-typecheck.js: tsc --noEmit 실행
- console-log-warn.js: console.log 사용 경고

**PreCompact (1개)**:
- pre-compact.js: 압축 전 상태 저장

**SessionStart (1개)**:
- session-start.js: 이전 세션 로드

**Stop (1개)**:
- check-console-log.js: console.log 남아있으면 경고

**SessionEnd (2개)**:
- session-end.js: 세션 저장
- evaluate-session.js: 세션 평가 (continuous-learning)

#### 2.5.2 구현 패턴

**인라인 node -e (단순 로직)**:

hooks.json:
```json
{
  "event": "PreToolUse",
  "command": "node -e \"if (process.env.TOOL_NAME === 'Write' && process.env.TOOL_ARGS.match(/\\.md$/)) { console.error('[BLOCK] Cannot edit .md files'); process.exit(2); }\""
}
```

**외부 .js 파일 (복잡 로직)**:

hooks.json:
```json
{
  "event": "PostToolUse",
  "command": "node scripts/hooks/prettier-format.js"
}
```

prettier-format.js:
```javascript
const utils = require('../lib/utils');
const { TOOL_NAME, TOOL_ARGS } = process.env;

if (TOOL_NAME === 'Write' || TOOL_NAME === 'Edit') {
  const file = utils.extractFilePath(TOOL_ARGS);
  utils.runPrettier(file);
}
```

**공유 유틸리티**: scripts/lib/utils.js

#### 2.5.3 종료 코드 규약

| 코드 | 의미 | 용도 |
|------|------|------|
| 0 | 성공 | 정상 실행 |
| 2 | 블록 | PreToolUse에서 도구 차단 |
| 기타 | 에러 | 로그만 남기고 도구 실행 계속 |

**예시**: dev-server-block.sh
```bash
if [[ "$TOOL_NAME" == "Bash" && "$TOOL_ARGS" =~ (npm|pnpm|yarn|bun)\ run\ dev ]]; then
  echo "[BLOCK] Use tmux for dev server" >&2
  exit 2
fi
```

#### 2.5.4 비동기 패턴

hooks.json:
```json
{
  "event": "PostToolUse",
  "command": "node scripts/hooks/analyze-build.js",
  "async": true,
  "timeout": 30
}
```

**의미**: Hook 실행이 끝날 때까지 기다리지 않고 다음 작업 진행

**활용 예시**: 빌드 로그 분석 (시간 소요), PR 정보 로그 (네트워크 I/O)

#### 2.5.5 CA 대응

| ECC | CA | 비고 |
|-----|-----|------|
| hooks.json 14개 | 0개 | **완전 부재** |
| 6 event types | - | SessionStart/Stop/PreCompact 등 |
| command/prompt/agent 3타입 | - | Hook 인프라 자체 없음 |

**최대 Gap**: 이것이 ECC와 CA의 가장 큰 차이점

---

### 2.6 Contexts (3개)

#### 2.6.1 모드별 행동 전환

**dev.md** (코드 먼저, 설명은 나중에):
```markdown
# Development Mode

## Priority
1. Edit/Write/Bash (execute first)
2. Read/Grep/Glob (verify after)
3. Explanation (only if asked)

## Behavior
- Make changes immediately
- Run tests after changes
- Ask forgiveness, not permission
```

**research.md** (이해 먼저, 행동은 나중에):
```markdown
# Research Mode

## Priority
1. Read/Grep/Glob (understand first)
2. Analysis and summary
3. Edit/Write/Bash (only with approval)

## Behavior
- Explore codebase thoroughly
- Identify patterns and relationships
- Never modify without understanding
```

**review.md** (철저히 읽고, 심각도 순으로 피드백):
```markdown
# Review Mode

## Priority
1. Read all relevant files
2. Identify issues by severity
3. Suggest improvements

## Severity Levels
- CRITICAL: Security, data loss, crashes
- HIGH: Performance, bugs, anti-patterns
- MEDIUM: Code style, readability
- LOW: Nitpicks, suggestions

## Output Format
[SEVERITY] File:Line - Issue description
```

#### 2.6.2 주입 방식

커맨드 프론트매터:
```yaml
system-prompt-file: contexts/dev.md
```

또는 CLI:
```bash
claude --system-prompt "$(cat contexts/dev.md)"
```

**효과**: 같은 Claude 모델이 모드에 따라 다른 "성격"으로 작동

#### 2.6.3 CA 대응

| ECC | CA | 비고 |
|-----|-----|------|
| contexts/ 3개 | .claude/context/ | 유사하지만 다름 |
| 모드 전환 (행동) | 세션 저장 (상태) | 목적 차이 |

**차이점**:
- ECC contexts/ = --system-prompt로 행동 변경
- CA .claude/context/ = 날짜별 세션 컨텍스트 저장

---

### 2.7 인프라 (MCP 15, Schemas 3, Tests 12, Scripts 15+)

#### 2.7.1 mcp-configs

mcp-servers.json (15개 MCP 템플릿):
```json
{
  "mcpServers": {
    "supabase": { "command": "supabase-mcp", ... },
    "github": { "command": "github-mcp", ... },
    "postgres": { ... },
    ...
  }
}
```

**활용**: 사용자가 필요한 MCP만 선택하여 ~/.claude/mcp.json에 복사

**토큰 절약 전략**: 불필요한 MCP는 비활성화

#### 2.7.2 schemas

- hooks.schema.json: hooks.json 검증
- plugin.schema.json: plugin.json 검증
- package-manager.schema.json: .claude/package-manager.json 검증

**CI 통합**: .github/workflows/ci.yml에서 JSON Schema 검증 실행

#### 2.7.3 tests

**CI validators** (tests/ci/validators.test.js):
- agents/ 폴더의 모든 .md 파일 구조 검증
- commands/ 프론트매터 검증
- skills/ SKILL.md 존재 검증
- hooks.json 스키마 검증

**hooks tests** (tests/hooks/):
- suggest-compact.test.js
- prettier-format.test.js
- session-start.test.js

**integration tests** (tests/integration/hooks.test.js):
- Hook 실행 시나리오 테스트

#### 2.7.4 scripts

**ci/** (5개):
- validate-agents.js
- validate-commands.js
- validate-skills.js
- validate-hooks.js
- validate-schemas.js

**hooks/** (9개):
- 실제 Hook 구현 (prettier-format.js, session-start.js 등)

**lib/** (4개):
- utils.js: 파일 경로 추출, Prettier 실행 등
- package-manager.js: npm/pnpm/yarn/bun 자동 감지
- session.js: 세션 저장/로드
- instinct.js: instinct 파일 파싱

#### 2.7.5 CA 대응

| ECC | CA | 비고 |
|-----|-----|------|
| mcp-configs 15개 | - | MCP 템플릿 부재 |
| schemas 3개 | - | 스키마 검증 부재 |
| tests 12+ | - | CI 검증 부재 |
| scripts 15+ | - | 자동화 스크립트 부재 |

**Gap**: 인프라 레이어 전체가 부재

---

## 3. 메커니즘 심층 분석

### 3.1 Continuous Learning v2 (Instinct-Based Architecture)

#### 3.1.1 데이터 흐름

```
PreToolUse/PostToolUse hook → observe.sh
  ↓ 도구 사용 기록 (TOOL_NAME, TOOL_ARGS, 결과)
observations.jsonl (5000자 truncate, append-only)
  ↓ 5분마다 SIGUSR1 시그널
observer agent (Haiku, 5분 스케줄, max-turns 3)
  ↓ 패턴 탐지 (4가지 카테고리)
instincts/{category}/{slug}.md (YAML frontmatter + confidence)
  ↓ 주간 평가 (confirm/contradict/decay)
confidence 업데이트 (0.3 ~ 0.85)
  ↓ /evolve 호출
instinct-cli.py cluster → skill/command/agent 생성
```

#### 3.1.2 observe.sh 구현

continuous-learning-v2/hooks/observe.sh:
```bash
#!/bin/bash

OBSERVATIONS_FILE=".claude/observations.jsonl"
mkdir -p .claude

# 도구 사용 기록
echo "{
  \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",
  \"tool\": \"$TOOL_NAME\",
  \"args\": \"$(echo $TOOL_ARGS | cut -c1-5000)\",
  \"success\": $TOOL_SUCCESS
}" >> $OBSERVATIONS_FILE
```

**5000자 truncate 이유**: 컨텍스트 폭발 방지

#### 3.1.3 observer agent

continuous-learning-v2/agents/observer.md:
```markdown
You are the Observer agent. Your job:

1. Read observations.jsonl (last 100 entries)
2. Identify patterns in 4 categories:
   - corrections: Claude's mistakes that user corrected
   - error_resolutions: How errors were resolved
   - repeated_workflows: Same sequence of tools
   - tool_preferences: Which tools for which tasks

3. For each pattern:
   - Calculate occurrence count
   - Determine confidence (see rules below)
   - Write to instincts/{category}/{slug}.md

## Confidence Rules
- 1-2 occurrences: 0.3 (tentative)
- 3-5 occurrences: 0.5 (emerging)
- 6-10 occurrences: 0.7 (established)
- 11+ occurrences: 0.85 (strong)

## Instinct Format
---
confidence: 0.5
last_seen: 2026-02-16
occurrences: 3
---

# Pattern: {description}

{detailed explanation}
```

**호출 방식** (start-observer.sh):
```bash
claude --model haiku --max-turns 3 --print \
  "Read $OBSERVATIONS_FILE and identify patterns..."
```

#### 3.1.4 Confidence 진화

instinct-cli.py evaluate:
```python
def update_confidence(instinct, events):
    if 'confirmed' in events:
        instinct['confidence'] += 0.05
    if 'contradicted' in events:
        instinct['confidence'] -= 0.1

    # Weekly decay
    weeks_since_last_seen = ...
    instinct['confidence'] -= weeks_since_last_seen * 0.02

    # Clamp
    instinct['confidence'] = max(0.3, min(0.85, instinct['confidence']))
```

**설계 의도**:
- 확인 → 점진적 강화
- 반증 → 빠른 약화
- 시간 경과 → 서서히 감소

#### 3.1.5 instinct → skill/command/agent

instinct-cli.py cluster:
```python
def cluster_instincts(instincts):
    # confidence >= 0.7인 instinct들을 군집화
    clusters = kmeans(instincts, n=5)

    for cluster in clusters:
        if cluster.type == 'workflow':
            generate_skill(cluster)
        elif cluster.type == 'shortcut':
            generate_command(cluster)
        elif cluster.type == 'delegation':
            generate_agent(cluster)
```

**출력 예시**:
```
instincts/repeated_workflows/user-auth-flow.md (confidence: 0.8)
  ↓ /evolve
skills/user-auth/SKILL.md 생성
commands/user-auth.md 생성
```

#### 3.1.6 설계 비평

**강점**:
- 완전 자동화 (사용자 개입 최소)
- 점진적 학습 (confidence 기반)
- 비용 효율 (Haiku 사용)

**약점**:
- 복잡도 높음 (observer + instinct-cli + 스케줄링)
- False positive 가능성 (패턴 오인식)
- 디버깅 어려움 (5분 지연, 비동기)

**CA 반영 전략**:
1. Phase 1: observe.sh만 먼저 (관찰 데이터 축적)
2. Phase 2: 수동 분석 (observations.jsonl 리뷰)
3. Phase 3: observer agent 추가 (자동화)
4. Phase 4: instinct-cli 추가 (진화)

---

### 3.2 Strategic Compact

#### 3.2.1 동작 흐름

```
PreToolUse(Edit|Write) → suggest-compact.js
  ↓ 카운터 증가 (/tmp/claude-tool-count-{sessionId})
50회 도달 → stderr 메시지 출력 (비블로킹)
  ↓ 사용자 확인 후 /compact 호출
PreCompact hook → pre-compact.js
  ↓ 상태 저장 (TODO, 진행 중인 계획 등)
Compaction 실행 (Claude Code 내장)
  ↓ 압축된 컨텍스트 + 저장된 상태 재주입
```

#### 3.2.2 suggest-compact.js 구현

strategic-compact/suggest-compact.js:
```javascript
const fs = require('fs');
const path = require('path');
const SESSION_ID = process.env.SESSION_ID || 'default';
const COUNT_FILE = path.join('/tmp', `claude-tool-count-${SESSION_ID}`);

// 카운터 읽기
let count = 0;
if (fs.existsSync(COUNT_FILE)) {
  count = parseInt(fs.readFileSync(COUNT_FILE, 'utf8'), 10);
}

// 카운터 증가
count++;
fs.writeFileSync(COUNT_FILE, count.toString());

// 제안 로직
let threshold = 50;
if (count > 50) {
  threshold = Math.ceil(count / 25) * 25; // 다음 25의 배수
}

if (count === threshold) {
  console.error(`[StrategicCompact] ${threshold} tool calls reached - consider /compact if transitioning phases`);
}
```

**비블로킹**: stderr 출력만, exit 0 (도구 실행 계속)

#### 3.2.3 Compaction Decision Guide

strategic-compact/SKILL.md:
```markdown
## When to Compact

| Phase Transition | Compact? | Why |
|------------------|----------|-----|
| Research → Planning | Yes | Research context is bulky and no longer needed |
| Planning → Implementation | Yes | Plan is now in TODO.md, conversation can go |
| Mid-implementation | No | Losing implementation state is costly |
| After a failed approach | Yes | Clear the dead-end reasoning |
| Before major refactor | No | Need full context of current implementation |
| After major refactor | Yes | Old code context is stale |

## What to Save Before Compact

1. **TODO.md**: All pending tasks with checkboxes
2. **DECISION.md**: Key architectural decisions
3. **ERROR_LOG.md**: Unresolved errors and their context
4. **PLAN.md**: Current implementation plan

## How to Save

Use PreCompact hook to automatically save these files.
```

#### 3.2.4 pre-compact.js 구현

scripts/hooks/pre-compact.js:
```javascript
const fs = require('fs');
const utils = require('../lib/utils');

// 현재 대화에서 TODO 항목 추출
const todos = utils.extractTodosFromContext();
fs.writeFileSync('TODO.md', todos);

// 의사결정 기록 추출
const decisions = utils.extractDecisionsFromContext();
fs.writeFileSync('DECISION.md', decisions);

console.error('[PreCompact] Saved state to TODO.md and DECISION.md');
```

#### 3.2.5 설계 의도

**문제**: Context decay는 "context 부족"이 아니라 "context 신선함 부족"

**해결**:
- 50회 = 대략 1-2 phase 완료 시점
- 자동 제안 (강제 아님) → 사용자 판단 여지
- PreCompact hook으로 손실 방지

**대조**: CA의 /wrap은 "세션 종료 + 저장", ECC의 compact는 "컨텍스트 압축 + 재시작"

#### 3.2.6 CA 반영 전략

1. suggest-compact.sh 추가 (hooks.json PreToolUse)
2. Compaction Decision Guide를 rules/compaction.md로
3. /wrap과 통합: wrap 전 compaction 제안

---

### 3.3 Hook Architecture

#### 3.3.1 세션 라이프사이클

```
SessionStart hook
  ↓ 이전 세션 로드, 환경 초기화
작업 시작
  ↓
PreToolUse hook(s)
  ↓ 도구 차단/경고/카운팅
[도구 실행]
  ↓
PostToolUse hook(s)
  ↓ 포맷팅, 타입체크, 로그
작업 계속...
  ↓
사용자가 종료 시도
  ↓
Stop hook
  ↓ console.log 체크, 최종 검증
PreCompact hook (if /compact)
  ↓ 상태 저장
SessionEnd hook(s)
  ↓ 세션 저장, 평가
종료
```

#### 3.3.2 두 가지 구현 패턴

**인라인 node -e** (단순 조건 체크):
```json
{
  "event": "PreToolUse",
  "command": "node -e \"if (process.env.TOOL_NAME === 'Bash' && process.env.TOOL_ARGS.match(/rm -rf/)) { console.error('[BLOCK] Dangerous command'); process.exit(2); }\""
}
```

**장점**: 의존성 없음, 빠름
**단점**: 복잡한 로직 불가능

**외부 .js 파일** (복잡 로직):
```json
{
  "event": "PostToolUse",
  "command": "node scripts/hooks/prettier-format.js"
}
```

prettier-format.js:
```javascript
const utils = require('../lib/utils');
const { execSync } = require('child_process');

const file = utils.extractFilePath(process.env.TOOL_ARGS);
if (file && file.match(/\.(ts|tsx|js|jsx)$/)) {
  try {
    execSync(`npx prettier --write ${file}`, { stdio: 'inherit' });
  } catch (err) {
    console.error('[Prettier] Failed:', err.message);
  }
}
```

**장점**: utils.js 재사용, 복잡한 분기, 에러 처리
**단점**: 파일 관리 필요, Node.js 의존성

#### 3.3.3 종료 코드 규약

| 코드 | PreToolUse | PostToolUse | SessionStart/End |
|------|-----------|------------|-----------------|
| 0 | 도구 실행 계속 | 정상 | 정상 |
| 2 | 도구 차단 | (무효) | (무효) |
| 기타 | 에러 로그, 도구 실행 | 에러 로그, 계속 | 에러 로그, 계속 |

**예시**: dev-server-block.sh
```bash
if [[ "$TOOL_NAME" == "Bash" && "$TOOL_ARGS" =~ npm\ run\ dev ]]; then
  echo "[BLOCK] Use tmux for dev server" >&2
  exit 2  # 도구 차단
fi

echo "[INFO] Tool allowed" >&2
exit 0  # 도구 실행 계속
```

#### 3.3.4 비동기 패턴

```json
{
  "event": "PostToolUse",
  "command": "node scripts/hooks/analyze-build.js",
  "async": true,
  "timeout": 30
}
```

**동작**:
- async: false (기본) → Hook 완료까지 대기
- async: true → Hook 백그라운드 실행, 즉시 다음 작업

**활용 예시**:
- 빌드 로그 분석 (시간 소요)
- PR 정보 로깅 (네트워크 I/O)
- 세션 평가 (LLM 호출)

#### 3.3.5 3가지 Hook 타입

**command** (셸 명령):
```json
{
  "event": "SessionStart",
  "command": "echo 'Session started' >> session.log"
}
```

**prompt** (LLM 1회 호출):
```json
{
  "event": "TaskCompleted",
  "prompt": "Review the task result and suggest improvements"
}
```

**agent** (LLM 다회전 + 도구):
```json
{
  "event": "Stop",
  "agent": "code-reviewer",
  "maxTurns": 5
}
```

**대조**: ECC는 command만 사용 (prompt/agent는 공식 문서에만 존재)

#### 3.3.6 CA 반영 전략

1. hooks/hooks.json 생성
2. SessionStart: 이전 세션 로드 (start-work.sh)
3. Stop: 패턴 검증 (pattern-checker 호출)
4. SessionEnd: 세션 저장 (wrap.sh)
5. PreToolUse: doc-file-block (CLAUDE.md/rules/*.md 보호)

---

### 3.4 Iterative Retrieval

#### 3.4.1 4-Phase Loop

```
Phase 1: DISPATCH (넓은 검색)
  ↓ Glob + Grep으로 후보 파일 수집
Phase 2: EVALUATE (관련성 점수)
  ↓ 각 파일을 0-1 척도로 점수화
Phase 3: REFINE (검색 개선)
  ↓ gap 분석 → 새 키워드 추가, 무관 파일 제외
Phase 4: LOOP (조건 체크)
  ↓ relevance >= 0.7 파일 3개+ && gap 없으면 종료
    아니면 Phase 1로 (최대 3회)
```

#### 3.4.2 SKILL.md 인용

iterative-retrieval/SKILL.md:
```markdown
When retrieving context for this task:

1. **DISPATCH**: Start with broad keyword search
   - Use Grep with loose patterns
   - Include file structure clues (imports, exports)
   - Cast a wide net initially

2. **EVALUATE**: Score each file's relevance
   - 0.0 = Completely unrelated
   - 0.3 = Mentioned in passing
   - 0.5 = Moderately related
   - 0.7 = Directly relevant
   - 1.0 = Core implementation

3. **REFINE**: Identify what context is still missing
   - What questions remain unanswered?
   - What keywords should we try?
   - What files should we exclude?

4. **LOOP**: Repeat with refined criteria (max 3 cycles)
   - Stop when: relevance >= 0.7 files >= 3 AND no significant gaps
   - Return: All files with relevance >= 0.7
```

#### 3.4.3 실전 예시

**Iteration 1**:
```
Query: "rate limiting"
Grep: "rate limit"
  → 0 results

Evaluate: gap = "코드베이스에 다른 용어를 사용하는 것 같음"
Refine: keywords += ["throttle", "quota", "limit"]
```

**Iteration 2**:
```
Query: "throttle OR quota OR limit"
Grep: "throttle"
  → 5 files found

Evaluate:
  - middleware/throttle.ts: 0.9
  - config/rate-limits.ts: 0.8
  - tests/throttle.test.ts: 0.7
  - README.md (mention): 0.2
  - package.json: 0.1

Refine: relevance >= 0.7 파일이 3개, gap 없음 → 종료
```

**Return**: middleware/throttle.ts, config/rate-limits.ts, tests/throttle.test.ts

#### 3.4.4 설계 의도

**문제**:
- 한 번 검색 → 놓치는 파일 많음
- 키워드가 정확히 일치하지 않으면 실패

**해결**:
- 반복적 리파인먼트 (검색 → 평가 → 개선)
- 관련성 점수 (0-1) → 명확한 기준
- 최대 3회 → 무한 루프 방지

#### 3.4.5 CA 반영 전략

explore 에이전트에 4-phase loop 추가:
```markdown
## Iterative Retrieval Protocol

When exploring unfamiliar code:

1. DISPATCH: Glob "**/*.{ts,tsx}" + Grep broad keywords
2. EVALUATE: Read first 50 lines, score 0-1
3. REFINE: If relevance < 0.7 or count < 3, add synonyms
4. LOOP: Max 3 iterations

Return only files with relevance >= 0.7.
```

---

## 4. 스킵/반영/논쟁 분류

### 4.1 스킵 (CA 정체성에 맞지 않음)

#### 4.1.1 언어별 스킬 (16개)

**대상**:
- django-*, springboot-*, golang-*, python-*
- django-patterns, django-security, django-tdd, django-verification
- springboot-patterns, springboot-security, springboot-tdd, springboot-verification
- golang-patterns, golang-testing
- python-patterns, python-testing
- java-coding-standards, cpp-testing

**이유**: CA는 범용 harness 목표
- 프로젝트마다 사용 언어/프레임워크 다름
- 언어 특화 지식은 프로젝트별 CLAUDE.md에 작성
- 플러그인에 하드코딩하면 불필요한 토큰 소모

#### 4.1.2 PM2 오케스트레이션

**대상**:
- pm2.md, setup-pm.md
- multi-backend.md, multi-frontend.md, multi-workflow.md

**이유**: 프로덕션 배포 시스템
- CA는 개발 도구 (배포는 범위 밖)
- PM2는 Node.js 생태계 특화
- 복잡도 대비 효용 낮음

#### 4.1.3 Multi-Model Collaboration

**대상**:
- multi-plan.md, multi-execute.md
- Codex+Gemini 협업 (CCG)

**이유**: 복잡도 대비 효용 불확실
- API 비용 증가
- 에러 디버깅 어려움
- Claude Opus 4.6으로 충분

#### 4.1.4 언어별 Rules (15개)

**대상**:
- rules/typescript/, rules/python/, rules/golang/

**이유**: 프로젝트마다 다름
- 코딩 스타일은 팀/회사마다 다름
- 범용 플러그인에 포함 부적합
- 프로젝트별 .claude/rules/에 작성

#### 4.1.5 언어 특화 에이전트

**대상**:
- go-build-resolver.md, go-reviewer.md, python-reviewer.md

**이유**: 범용 에이전트로 충분
- writer/writer-high가 언어 무관 코드 작성 가능
- 필요시 프로젝트별 에이전트 추가 가능
- 플러그인에 13개 에이전트는 과도

---

### 4.2 반영 포인트 (우리 방식으로 구현)

#### 4.2.1 Hook Architecture 기반 자동화

**ECC 메커니즘**:
- hooks.json: 6가지 이벤트, command/prompt/agent 3타입
- PreToolUse: 도구 차단 (exit 2), 경고, 카운팅
- PostToolUse: 포맷팅, 타입체크, 로그
- SessionStart/End: 세션 로드/저장

**CA 반영**:
```json
{
  "hooks": [
    {
      "event": "SessionStart",
      "command": "bash scripts/hooks/session-start.sh"
    },
    {
      "event": "Stop",
      "agent": "pattern-checker",
      "maxTurns": 3
    },
    {
      "event": "SessionEnd",
      "command": "bash scripts/hooks/session-end.sh"
    },
    {
      "event": "PreToolUse",
      "command": "bash scripts/hooks/guard.sh"
    }
  ]
}
```

**구현 우선순위**:
1. SessionStart: 이전 세션 로드 (start-work.sh 통합)
2. SessionEnd: 세션 저장 (wrap.sh 통합)
3. Stop: 패턴 검증 (pattern-checker 호출)
4. PreToolUse: guard hooks (CLAUDE.md 보호, 위험 명령 차단)

#### 4.2.2 Strategic Compact

**ECC 메커니즘**:
- suggest-compact.js: 50회 첫 제안, 25회마다 반복
- Compaction Decision Guide: 언제 compact할지 가이드
- pre-compact.js: 상태 저장 (TODO, DECISION 등)

**CA 반영**:
```bash
# scripts/hooks/suggest-compact.sh
COUNT_FILE="/tmp/claude-tool-count-$SESSION_ID"
count=$(cat $COUNT_FILE 2>/dev/null || echo 0)
count=$((count + 1))
echo $count > $COUNT_FILE

if [ $count -eq 50 ] || [ $((count % 25)) -eq 0 ]; then
  echo "[StrategicCompact] $count tool calls - consider /compact if phase transition" >&2
fi
```

rules/compaction.md:
```markdown
# Compaction Decision Guide

## When to Compact

| Transition | Compact? |
|------------|----------|
| 백로그 작성 → 구현 | Yes |
| 구현 중 | No |
| 실패한 접근 후 | Yes |
| 리팩토링 전 | No |
| 리팩토링 후 | Yes |
```

**통합**: /wrap 전 compaction 제안

#### 4.2.3 Iterative Retrieval

**ECC 메커니즘**:
- 4-phase loop: DISPATCH → EVALUATE → REFINE → LOOP
- 관련성 점수 (0-1), 최대 3회 반복
- relevance >= 0.7 파일 3개+ 조건

**CA 반영**:

explore.md에 추가:
```markdown
## Iterative Retrieval Protocol

### Phase 1: DISPATCH
- Glob "**/*.{관련 확장자}"
- Grep broad keywords

### Phase 2: EVALUATE
- Read first 50 lines
- Score 0-1 (0.7+ = relevant)

### Phase 3: REFINE
- If count < 3 or avg < 0.7:
  - Add synonyms
  - Expand file types
  - Check related directories

### Phase 4: LOOP
- Max 3 iterations
- Return files with score >= 0.7
```

**차별점**: CA는 프롬프트 기반, ECC는 별도 스킬

#### 4.2.4 Contexts 모드 전환

**ECC 메커니즘**:
- contexts/dev.md: "코드 먼저, 설명 나중"
- contexts/research.md: "이해 먼저, 행동 나중"
- contexts/review.md: "철저히 읽고, 심각도순 피드백"

**CA 반영**:

contexts/ 폴더 생성:
```markdown
# contexts/dev.md
## Priority
1. Edit/Write/Bash (execute first)
2. Verify after
3. Explain only if asked

# contexts/research.md
## Priority
1. Read/Grep/Glob (understand first)
2. Analysis
3. Never modify without approval

# contexts/review.md
## Output
[SEVERITY] File:Line - Issue
CRITICAL > HIGH > MEDIUM > LOW
```

커맨드에서 주입:
```yaml
# commands/dev-mode.md
system-prompt-file: contexts/dev.md
```

#### 4.2.5 Agent Chaining

**ECC 메커니즘**:
- orchestrate.md: planner → tdd-guide → code-reviewer → security-reviewer
- 각 에이전트 출력이 다음 에이전트 입력으로

**CA 반영**:

commands/orchestrate.md:
```markdown
# /orchestrate

Run a multi-agent workflow:

1. Plan (planner agent)
2. Verify (pattern-checker)
3. Implement (writer)
4. Review (code-reviewer - 미래)
5. Secure (security-reviewer - 미래)

Each agent's output becomes next agent's input.
```

**우선순위**: P2 (planner/code-reviewer 에이전트 먼저 필요)

#### 4.2.6 CI 검증

**ECC 메커니즘**:
- tests/ci/validators.test.js: agents/commands/skills 구조 검증
- schemas/*.schema.json: JSON Schema 검증
- .github/workflows/ci.yml: PR마다 실행

**CA 반영**:

scripts/ci/validate-agents.js:
```javascript
// agents/*.md 파일 구조 검증
// - frontmatter 필수 필드 (subagent_model)
// - 섹션 구조 (역할, 입력, 출력)
```

.github/workflows/ci.yml:
```yaml
- name: Validate Plugin Structure
  run: |
    node scripts/ci/validate-agents.js
    node scripts/ci/validate-commands.js
    node scripts/ci/validate-skills.js
```

#### 4.2.7 Verification Loop

**ECC 메커니즘**:
- verification-loop/SKILL.md: build+type+lint+test+security
- 실패 시 자동 수정 시도 (최대 3회)
- Boris Cherny 워크플로우 기반

**CA 반영**:

commands/verify.md:
```markdown
# /verify

Run verification loop:

1. Build (tsc/go build/pytest)
2. Type check (tsc --noEmit)
3. Lint (eslint/ruff)
4. Test (jest/pytest)
5. Security (security-scan - 미래)

If failure:
- Analyze error
- Attempt fix
- Retry (max 3 times)
```

skills/verification-loop/SKILL.md:
```markdown
## Verification Protocol

After any code change:
1. Build first (syntax errors block everything)
2. Type check (if statically typed)
3. Lint (style issues)
4. Test (behavior verification)
5. Security scan (if security-critical)

Stop on first failure, fix, retry.
```

---

### 4.3 논쟁 (결정 필요)

#### 4.3.1 Token-First vs Harness-First

**ECC 입장**:
- Context rot이 최대 적
- MCP 최소화, CLI skill 대체
- 50회마다 compaction 제안
- 토큰 절약 = 품질 향상

**CA 입장**:
- 통제 우선, 토큰은 부차적
- MCP 필요시 사용
- 세션 컨텍스트 누적 (wrap/start-work)
- 개발자 제어 = 품질 향상

**논쟁점**:
- ECC의 "context decay" 개념을 CA에 얼마나 반영할 것인가?
- Strategic Compact를 /wrap과 어떻게 통합할 것인가?
- MCP를 정말 최소화해야 하는가?

**잠정 결론**:
- Strategic Compact는 반영 (compaction 제안은 유용)
- MCP 최소화는 선택적 (ENABLE_TOOL_SEARCH 활용)
- Context decay 인식은 하되, 강박적 compact는 No

#### 4.3.2 Continuous Learning: 자동 vs 수동

**ECC 입장**:
- Continuous Learning v2로 완전 자동화
- observe.sh → observer → instinct → skill/command
- 개발자 개입 최소화

**CA 입장**:
- PARA 기반 수동 축적
- Planning 후 개념 추출 → Resources 저장
- 개발자가 명시적 관리

**논쟁점**:
- 자동 학습의 복잡도가 효용을 정당화하는가?
- False positive 패턴 인식 위험은?
- 수동 축적이 더 신뢰할 수 있지 않은가?

**잠정 결론**:
- Phase 1: observe.sh만 (관찰 데이터 축적)
- Phase 2: 수동 분석 (observations.jsonl 리뷰)
- Phase 3: 효용 입증되면 observer 추가
- 완전 자동화는 보류

#### 4.3.3 자율성 vs 제어

**ECC 입장**:
- PROACTIVE 에이전트 호출
- "architect 에이전트를 항상 먼저 호출"
- Hook으로 자동화 극대화
- AI가 알아서 결정

**CA 입장**:
- 명시적 위임 (Task 도구)
- "절대 원칙: 파일 읽기/쓰기 위임 필수"
- 워크플로우 패턴화 (commands/skills)
- 개발자가 운전대

**논쟁점**:
- PROACTIVE 호출을 허용할 것인가?
- Hook의 자동화 수준은 어디까지?
- "너무 많은 커스텀은 방해" (Shankar) 경고를 어떻게 받아들일 것인가?

**잠정 결론**:
- PROACTIVE는 No (명시적 호출 유지)
- Hook 자동화는 Yes (guard/session/compact만)
- 커스텀 최소화는 Yes (commands 10개 이내 목표)

---

## 5. Actionable Items (phase4-005 연결)

| # | 항목 | 카테고리 | 우선순위 | 난이도 | 설명 |
|---|------|---------|---------|--------|------|
| 1 | hooks.json 기반 인프라 도입 | Gap 보완 | P0 | 낮음 | hooks.json + session-start/end + guard hooks 구현 |
| 2 | Strategic Compact hook | 원리 차용 | P0 | 매우 낮음 | suggest-compact.sh + compaction decision guide 추가 |
| 3 | Verification Loop 커맨드 | Gap 보완 | P1 | 중간 | /verify = build+type+lint+test+security+diff 통합 |
| 4 | Iterative Retrieval 패턴 | 원리 차용 | P1 | 중간 | explore 에이전트에 4-phase retrieval loop 추가 |
| 5 | Context 모드 전환 | Gap 보완 | P1 | 낮음 | contexts/ (dev/research/review) 도입 + 커맨드 통합 |
| 6 | Agent chaining (orchestrate) | 원리 차용 | P2 | 중간 | planner → writer → reviewer 체인 워크플로우 |
| 7 | CI 구조 검증 | Gap 보완 | P2 | 낮음 | validate-agents/commands/skills/hooks 스크립트 작성 |
| 8 | Continuous Learning observe.sh | 원리 차용 | P2 | 높음 | 관찰 데이터 축적부터 시작 (observer는 나중) |
| 9 | Token-first 균형점 결정 | 철학 논쟁 | P2 | - | ECC의 context rot 개념을 CA에 어느 수준 반영? |
| 10 | Eval Harness (EDD) | Gap 보완 | P3 | 높음 | 스킬/에이전트 A/B 테스팅 프레임워크 |

---

## 6. 요약 통계

| 영역 | ECC (v1.4.1) | CA (v0.23.1) | Gap |
|------|-------------|-------------|-----|
| **Agents** | 13 (3-tier) | 5 (범용) | 도메인 특화, chaining |
| **Skills** | 37 | 1 | 학습/검증/보안 스킬 |
| **Commands** | 31 | 2 | orchestrate/verify/학습 |
| **Rules** | 23 (common+lang) | 4 (운영) | 코딩 품질 규칙 |
| **Hooks** | 14 (6 events) | 0 | **완전 부재** |
| **Contexts** | 3 | 유사 | 모드 전환 |
| **MCP** | 15 | 0 | 설정 템플릿 |
| **Tests** | 12 | 0 | CI 검증 |
| **Scripts** | 15+ | 0 | 자동화 스크립트 |

**최대 Gap**: Hook 인프라 (ECC 14 vs CA 0)
**최소 Gap**: Contexts (모드 전환 vs 세션 저장, 목적 다름)

---

## 7. 핵심 인사이트

### 7.1 ECC의 강점

1. **완성도 높은 Hook 생태계**: 6가지 이벤트, command/prompt/agent 3타입
2. **토큰 최적화 전문성**: Context rot 개념, Strategic Compact
3. **자동화 극대화**: Continuous Learning v2, Hook 기반 품질 게이트
4. **프로덕션 검증**: 10개월 실전 사용, 42K+ stars

### 7.2 CA의 강점

1. **명확한 정체성**: CLAUDE.md 기반 철학 선언
2. **제어 우선**: 명시적 위임, 에이전트 역할 분리
3. **성장하는 시스템**: PARA 축적, brain.md 설계
4. **Progressive Disclosure**: 필요시만 로드

### 7.3 통합 전략

**ECC에서 가져올 것**:
- Hook 인프라 (SessionStart/End, Stop, PreToolUse)
- Strategic Compact (compaction 제안)
- Iterative Retrieval (4-phase loop)
- Verification Loop (build+type+lint+test)
- CI 검증 (구조 검증 스크립트)

**CA가 유지할 것**:
- Harness-first 철학 (개발자 통제)
- 명시적 위임 (PROACTIVE 호출 No)
- 세션 컨텍스트 누적 (wrap/start-work)
- PARA 기반 수동 학습

**논쟁을 통해 결정할 것**:
- Context rot 대응 수준
- Continuous Learning 자동화 범위
- 자율성 vs 제어 균형점

---

**Last Updated**: 2026-02-16
