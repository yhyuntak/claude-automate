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
                    │     (Harness)      │
                    └─────────┬─────────┘
                              │
          ┌───────────┬───────┴───────┬───────────┐
          ▼           ▼               ▼           ▼
    ┌─────────┐ ┌─────────┐   ┌─────────┐ ┌─────────┐
    │ Pattern │ │ Doc Sync│   │ Context │ │ Review  │
    │ Checker │ │ Checker │   │ Builder │ │ Agents  │
    └─────────┘ └─────────┘   └─────────┘ └─────────┘
        AI Agents (실행자)
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

## Current Features

### 아키텍처 레이어 매핑

claude-automate는 토스테크의 레이어드 아키텍처 모델을 따릅니다:

```
Commands    =  Controller (진입점, 사용자 인터페이스)
Agents      =  Service Layer (비즈니스 로직, 분석/검증)
Skills      =  Domain Component (단일 책임, 재사용 가능)
MCP         =  Infrastructure/Adapter (외부 연동)
CLAUDE.md   =  package.json (프로젝트 정체성, 원칙)
```

### Commands (Controller)

| Command | 설명 |
|---------|------|
| `/start-work` | 세션 시작: 이전 컨텍스트 + 백로그 + 워크트리 |
| `/wrap` | 세션 종료: 패턴 검증 + 문서 동기화 + 컨텍스트 저장 |
| `/backlog` | 백로그 조회 및 관리 |
| `/project-init` | 새 프로젝트 초기화 |
| `/verify-web-ui` | Web UI 검증: 시나리오 설계 → 브라우저 테스트 → 분석 |

### Agents (Service Layer)

| Agent | Tier | 역할 |
|-------|------|------|
| `pattern-checker` | Sonnet | 프로젝트 규칙 검증 |
| `pattern-checker-high` | Opus | 복잡한 규칙 충돌 해결 |
| `doc-sync-checker` | Sonnet | 문서-코드 동기화 검증 |
| `doc-sync-checker-high` | Opus | 대규모 문서 구조 변경 |
| `context-builder` | Sonnet | 세션 컨텍스트 생성 |
| `test-planner` | Sonnet | 테스트 시나리오 설계 |
| `verify-web-ui` | Sonnet | Web UI 테스트 실행 + 데이터 수집 |
| `verify-web-ui-orchestrator` | Sonnet | Web UI 검증 오케스트레이션 |

### Skills (Domain Component)

| Skill | 역할 |
|-------|------|
| `backlog` | 백로그 CRUD 및 상태 관리 |
| `feedback` | 피드백 수집 및 조회 |
| `project-init` | 프로젝트 템플릿 생성 |
| `explain-plugins` | 플러그인 시스템 설명 |
| `verify-web-ui` | Web UI 검증 오케스트레이터 |

---

## Roadmap

### Phase 1: 계획-실행 워크플로우 (진행 예정)

Peter Steinberger 스타일의 계획 중심 개발:

- [ ] **phase1-001**: 아키텍처 우선 계획 단계
- [ ] **phase1-002**: 다중 에이전트 병렬 실행
- [ ] **phase1-003**: 결과 통합 및 피드백

### Phase 2: PARA 지식 관리

배운 것을 축적하는 시스템:

- [ ] **phase2-001**: PARA 지식 구조 설계
- [ ] **phase2-002**: 세션 인사이트 자동 추출
- [ ] **phase2-003**: 지식 검색 및 활용

### Phase 3: 병렬 리뷰 에이전트

Kieran Klaassen 스타일의 병렬 리뷰 시스템 (코드 완성 후 검증):

- [ ] **phase3-001**: 병렬 리뷰 에이전트 구조 설계
- [ ] **phase3-002**: Triage 워크플로우 구현
- [ ] **phase3-003**: 리뷰 결과 학습 축적
- [ ] **phase3-004**: 도구 위임 규칙 정의

---

## Quick Start

### 1. 설치

```bash
# Claude Code 플러그인 마켓플레이스에서 설치
/plugin marketplace add yhyuntak/claude-automate
/plugin install claude-automate@claude-automate
```

### 2. 세션 시작

```bash
/start-work
```

이전 세션 컨텍스트를 불러오고, 백로그를 확인하고, 워크트리를 설정합니다.

### 3. 작업 후 마무리

```bash
/wrap
```

패턴 검증, 문서 동기화 확인, 세션 컨텍스트를 자동 저장합니다.

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
