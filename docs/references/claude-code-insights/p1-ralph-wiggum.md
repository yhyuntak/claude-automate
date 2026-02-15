---
id: P1
title: Ralph Wiggum (Official Plugin)
author: Anthropic
url: https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum
fetched: 2026-02-15
---

# Ralph Wiggum Plugin

## Overview

The Ralph Wiggum Plugin implements an iterative AI development methodology within Claude Code. Named after the Simpsons character, it embodies persistent iteration through self-referential loops.

## Core Mechanism

As described in the documentation: **"Ralph is a Bash loop"** - a continuous cycle that repeatedly feeds prompts back to an AI agent. Rather than requiring external bash scripts, this plugin uses a Stop hook that intercepts exit attempts, creating internal feedback loops within a single session.

The self-referential process works by:
- Maintaining unchanged prompts across iterations
- Preserving file modifications between cycles
- Allowing the AI to review its own previous work and git history
- Enabling autonomous refinement without external intervention

## Primary Commands

**Starting a loop:**
```bash
/ralph-loop "<prompt>" --max-iterations <n> --completion-promise "<text>"
```

**Stopping a loop:**
```bash
/cancel-ralph
```

## Effective Prompt Design

Strong prompts include:
- Explicit completion criteria with specific deliverables
- Phased milestones for complex projects
- Built-in test-driven development workflows
- Maximum iteration limits as safety mechanisms

The documentation emphasizes that `--max-iterations` functions as the primary safeguard, since the `--completion-promise` uses exact string matching only.

## Appropriate Use Cases

**Recommended for:** Well-defined tasks, iterative refinement, greenfield projects, automated verification

**Not recommended for:** Subjective design decisions, single-operation tasks, unclear success metrics, production diagnostics

## Historical Performance

The approach reportedly enabled rapid repository generation during hackathon testing and supported high-value contract completion with minimal computational expense.

---

## Source Code Mechanism Analysis (2026-02-15)

### Plugin 구성

```
plugins/ralph-wiggum/
├── .claude-plugin/
│   ├── plugin.json              # 플러그인 메타데이터
│   └── marketplace.json         # 마켓플레이스 정보
├── commands/
│   ├── ralph-loop.md            # 루프 시작 커맨드
│   └── cancel-ralph.md          # 루프 취소 커맨드
├── hooks/
│   ├── stop-hook.sh             # 세션 종료 인터셉트
│   └── setup-ralph-loop.sh      # 루프 초기화 스크립트
└── README.md
```

**확장점**: Commands (진입) + Hooks (제어) + State Files (상태 관리)

### 데이터 흐름

```
/ralph-loop "<prompt>" --max-iterations N --completion-promise "DONE"
  ↓
setup-ralph-loop.sh → State 파일 생성 (.claude/ralph-loop.local.md)
  ↓ YAML frontmatter: iteration, max_iterations, completion_promise
Claude 작업 수행 → 종료 시도
  ↓
stop-hook.sh 트리거
  ↓ State 파일 읽기 → iteration++ → 종료 조건 체크
  ├─ iteration >= max_iterations → 정상 종료
  ├─ <promise>DONE</promise> 발견 → 정상 종료
  └─ 미충족 → exit 2 (차단) + reinject_prompt JSON 출력
```

### 핵심 메커니즘

| 메커니즘 | 구현 |
|----------|------|
| 종료 차단 | `exit 2` (특수 exit code) |
| 프롬프트 재주입 | JSON `reinject_prompt` 필드 (stderr) |
| 상태 영속화 | `.claude/ralph-loop.local.md` (YAML frontmatter) |
| 완료 감지 | `<promise>...</promise>` 태그 검색 |
| 안전장치 | `max_iterations` 하드 리미트 |

### 확장 가능한 부분

- 프롬프트 설계 (Guardrails, 작업 순서 명시, 탈출 조건)
- Commands 확장 (clarify → plan → execute 3단계)
- Stop Hook 수정 (환경 호환성)
- State 파일 구조 수정

### claude-automate 차용 패턴

1. **Stop Hook 패턴**: `/wrap` 전 필수 검증 강제
2. **YAML Frontmatter 상태 관리**: 세션 컨텍스트 저장
3. **Completion Promise 패턴**: 에이전트 작업 완료 신호
4. **Progressive Guardrails**: 실패에서 학습하는 CLAUDE.md
5. **TODO.md 체크리스트**: Backlog Acceptance Criteria 진행률 추적
