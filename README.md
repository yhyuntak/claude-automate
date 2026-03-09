# claude-automate

> **"코드를 보지 않고 개발하기"** - AI 시대, 개발자의 새로운 역할

🌏 [English](README.en.md) | **한국어**

---

## Vision

개발자는 더 이상 모든 코드를 직접 읽고 쓸 필요가 없습니다.

**claude-automate**는 개발자가 **아키텍처, 패턴, 아이디어** 레벨에 집중할 수 있게 해주는 Claude Code 플러그인입니다. 코드 구현은 AI에게 위임하고, 당신은 **방향 제시와 의사결정**에 집중하세요.

### 핵심 목표

| # | 목표 | 설명 |
|---|------|------|
| 1 | **코드를 보지 않고 개발** | 아키텍처/패턴/아이디어 레벨에 집중 |
| 2 | **성장하는 시스템** | 만들면서 배우고, 배운 것을 축적 |
| 3 | **나만의 Harness** | 직접 수정 가능한 확장 시스템 |
| 4 | **단순함 유지** | 필요한 것부터 하나씩 |

### Harness 컨셉

```
┌─────────────────────────────────────────────────────────────┐
│                       당신 (Driver)                          │
│              아키텍처 · 패턴 · 아이디어 · 의사결정             │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────┴─────────┐
                    │    claude-automate │
                    │  (Harness 2.0)     │
                    │  11 Commands       │
                    │  17 Agents         │
                    │  13 Skills         │
                    └─────────┬─────────┘
                              │
     ┌──────────┬─────────────┼─────────────┬──────────┐
     ▼          ▼             ▼             ▼          ▼
┌─────────┐ ┌───────┐  ┌──────────┐  ┌──────────┐ ┌──────┐
│ explore │ │writer │  │ pattern  │  │ doc-sync │ │angel/│
│ low/mid │ │  /high│  │ checker  │  │ checker  │ │devil │
│  /high  │ │       │  │  /high   │  │  /high   │ │      │
└─────────┘ └───────┘  └──────────┘  └──────────┘ └──────┘
                    AI Agents (실행자, 3-Tier)
```

---

## Philosophy

### 1. "나보다 더 잘 보는 녀석이 나타났다"
> Peter Steinberger (Moltbot 창시자)

5-10개 에이전트를 병렬로 운영하며, 코드 리뷰 대신 아키텍처 논의에 집중합니다. 계획에 시간을 투자하고, 실행은 위임합니다.

### 2. "코드 읽기를 그만뒀더니, 리뷰가 더 좋아졌다"
> Kieran Klaassen

13개 전문 AI 리뷰어가 병렬로 실행됩니다. 50/50 규칙: 리뷰 50%, 시스템 개선 50%. Triage 기반으로 의사결정합니다.

### 3. "코드를 보면 안 된다. 상위 레벨 개념을 확고히"
> 토스테크 Software 3.0

도구는 바뀌었지만 좋은 설계의 원칙은 그대로입니다. Claude Code도 레이어드 아키텍처를 따르고, 안티패턴도 그대로 적용됩니다.

### 4. "참고하되 내 것으로 만들어야 성장"
> oh-my-claudecode 분석에서

다른 사람의 설정을 복사하는 것만으론 부족합니다. 직접 만들고, 이해하고, 수정할 수 있어야 진짜 내 것이 됩니다.

---

## Current Features (v0.24.1)

### 아키텍처 레이어 매핑

claude-automate는 토스테크의 레이어드 아키텍처 모델을 따릅니다:

```
Commands    =  Controller (진입점, 사용자 인터페이스)
Agents      =  Service Layer (비즈니스 로직, 분석/검증)
Skills      =  Domain Component (단일 책임, 재사용 가능)
MCP         =  Infrastructure/Adapter (외부 연동)
CLAUDE.md   =  package.json (프로젝트 정체성, 원칙)
```

### Commands (Controller) — 11개

| Command | 설명 |
|---------|------|
| `/start-work` | 세션 시작: 컨텍스트 복원, plan 이어가기, 백로그 관리 |
| `/planning` | 아이디어를 구체적인 plan 파일로 구체화 |
| `/implement` | plan 기반 AC별 구현 실행 |
| `/save-context` | 세션 컨텍스트 저장 |
| `/wrap` | 세션 종료 마무리: plan 완료 + 백로그 정리 + 컨텍스트 저장 + 커밋 |
| `/angel` | 생각 확장자: 새로운 관점과 가능성 탐색 |
| `/devil` | 냉철한 비판자: 계획/설계/코드 검증 |
| `/verify-web-ui` | Web UI 검증 (Playwright/Chrome DevTools MCP) |
| `/save-para` | 대화 인사이트를 PARA Resources에 저장 |
| `/install-rule` | 프로젝트 규칙을 글로벌 rules에 설치 |
| `/extract-brain` | 대화에서 사고 포인트 추출 |

### Agents (Service Layer) — 17개, 3-Tier

| Agent | Tier | 역할 |
|-------|------|------|
| `explore-low` | Haiku | 빠른 코드베이스 단순 검색/파일 찾기 |
| `explore` | Sonnet | 코드베이스 구조 파악, 관계 매핑 |
| `explore-high` | Opus | 깊은 아키텍처 분석, 복잡한 구조 매핑 |
| `writer` | Sonnet | 코드 작성/수정 (메인 컨텍스트 보호) |
| `writer-high` | Opus | 복잡한 코드 작성 (알고리즘/보안/아키텍처) |
| `pattern-checker` | Sonnet | 프로젝트 규칙 준수 검증 |
| `pattern-checker-high` | Opus | 복잡한 규칙 충돌 해결, 아키텍처 패턴 |
| `doc-sync-checker` | Sonnet | 문서-코드 동기화 검증 |
| `doc-sync-checker-high` | Opus | 대규모 문서 구조 재설계 |
| `context-builder` | Haiku | 세션 컨텍스트 파일 생성 |
| `angel` | Sonnet | 생각 확장자 (brainstorm 촉진) |
| `devil` | Sonnet | 냉철한 비판자 (devil's advocate) |
| `test-planner` | Sonnet | 테스트 시나리오 설계 |
| `verify-web-ui` | Sonnet | Web UI 테스트 실행 |
| `verify-web-ui-orchestrator` | Sonnet | Web UI 검증 오케스트레이션 |
| `gemini-advisor` | Sonnet | UI/UX 관점 외부 LLM 어드바이저 (Gemini CLI) |
| `codex-advisor` | Sonnet | 코드 품질/버그 탐지 외부 LLM 어드바이저 (Codex CLI) |

### Skills (Domain Component) — 13개

**Core 6개** (Harness 2.0 워크플로우):

| Skill | 역할 |
|-------|------|
| `start-work` | 세션 시작 오케스트레이션 |
| `planning` | plan 파일 생성 및 관리 |
| `implement` | AC 기반 구현 실행 |
| `save-context` | 세션 컨텍스트 스냅샷 저장 |
| `wrap` | 세션 종료 워크플로우 |
| `backlog` | 백로그 CRUD 및 상태 관리 |

**Utility 7개**:

| Skill | 역할 |
|-------|------|
| `save-para` | PARA Resources 저장 |
| `feedback` | 피드백 수집 및 조회 |
| `explain-plugins` | 플러그인 시스템 설명 |
| `project-init` | 프로젝트 템플릿 생성 |
| `install-rule` | 글로벌 규칙 설치 |
| `verify-web-ui` | Web UI 검증 오케스트레이터 |
| `multi-review` | 3개 LLM(Claude/Gemini/Codex) 동시 리뷰 및 비교 종합 |

### Hooks

- **Stop Hook**: 세션 종료 시 테스트 검증 + 컨텍스트 70% 감시
- 플러그인 hooks 시스템으로 배포 (`hooks/hooks.json`)

---

## Roadmap

### ✅ Phase 1-3 완료

계획-실행 워크플로우, PARA 지식 관리, 병렬 리뷰 에이전트 등 핵심 기능이 구축되었습니다.

### 🔄 Phase 4: 현재 진행 중

상세 백로그는 [`docs/backlogs/README.md`](docs/backlogs/README.md) 참조.

---

## Quick Start

### 1. 설치

```bash
# Claude Code 플러그인 마켓플레이스에서 설치
/plugin marketplace add yhyuntak/claude-automate
/plugin install claude-automate@claude-automate
```

### 2. Harness 2.0 워크플로우

```bash
/start-work    # 세션 시작: 컨텍스트 복원 + 백로그 확인
/planning      # 아이디어를 구체적인 plan으로
/implement     # plan의 AC 하나씩 실행
/wrap          # 세션 종료: 검증 + 정리 + 커밋
```

보조 도구:

```bash
/angel         # 새로운 관점 탐색
/devil         # 비판적 검증
/verify-web-ui # Web UI 테스트
/save-para     # 인사이트 저장
```

---

## References

더 자세한 배경과 영감의 원천:

| 문서 | 핵심 인사이트 |
|------|--------------|
| [Peter Steinberger](docs/references/01-peter-steinberger-moltbot.md) | "I ship code I don't read" |
| [Kieran Klaassen](docs/references/02-kieran-klaassen-code-review.md) | 13개 병렬 AI 리뷰어 |
| [토스테크](docs/references/03-toss-software-3.0.md) | 레이어드 아키텍처 매핑 |
| [oh-my-claudecode](docs/references/04-oh-my-claudecode-analysis.md) | 멀티 에이전트 오케스트레이션 |

---

## License

MIT

## Author

[yhyuntak](https://github.com/yhyuntak)
