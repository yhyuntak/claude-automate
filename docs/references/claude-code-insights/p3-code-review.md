---
id: P3
title: Code Review (Official Plugin)
author: Anthropic
url: https://github.com/anthropics/claude-code/tree/main/plugins/code-review
fetched: 2026-02-15
---

# Code Review Plugin

## Summary

The Code Review Plugin automates pull request reviews using four parallel agents that independently audit changes. The system scores each issue (0-100) and filters out results below an 80 confidence threshold to minimize false positives.

## Key Components

**Core Function**: The `/code-review` command launches specialized agents to examine code from multiple angles—guideline compliance, bug detection, and historical context analysis.

**Agents Deployed**:
- Two agents verify adherence to CLAUDE.md guidelines
- One agent identifies obvious bugs in modifications
- One agent analyzes git history for context-based concerns

**Confidence Scoring**: Issues receive ratings where "0" indicates low confidence and "100" means absolute certainty. Only findings scoring 80+ appear in final reviews.

## Main Features

- Parallel agent execution for comprehensive coverage
- False positive filtering through confidence thresholds
- Automatic skipping of closed, draft, or previously-reviewed pull requests
- Optional posting as PR comments via `--comment` flag
- Direct code linking with SHA and line ranges

## Usage Pattern

The basic workflow involves running `/code-review` locally to see terminal output, then optionally using `/code-review --comment` to post findings to GitHub. The system automatically filters trivial changes and respects existing reviews.

## Requirements

The plugin requires a Git repository with GitHub integration, the GitHub CLI tool (authenticated), and optionally CLAUDE.md files for enhanced guideline checking.

---

## Source Code Mechanism Analysis (2026-02-15)

### Plugin 구성

```
plugins/code-review/
├── .claude-plugin/
│   └── plugin.json          # 플러그인 메타데이터
├── commands/
│   └── code-review.md       # 메인 커맨드 (에이전트 inline 정의)
└── README.md
```

**확장점**: Commands only (에이전트를 별도 폴더 없이 커맨드 내부에 inline 정의)

### 9-Stage Pipeline

```
Stage 1: Pre-check (Haiku) → PR 상태 검증
Stage 2: CLAUDE.md 수집 (Haiku) → 관련 파일 로드
Stage 3: 변경사항 요약 (Sonnet) → PR diff summary
Stage 4: 병렬 리뷰 (4 에이전트)
  ├─ Agent 1 (Sonnet): CLAUDE.md 준수 검증
  ├─ Agent 2 (Sonnet): CLAUDE.md 준수 검증 (중복 독립 검증)
  ├─ Agent 3 (Opus): 버그 탐지
  └─ Agent 4 (Opus): 로직/보안 검증
Stage 5: 2차 검증 (subagents) → 각 이슈 재검증
Stage 6: 필터링 → Confidence < 80 제거
Stage 7: 터미널 출력
Stage 8: 코멘트 계획 (--comment 시)
Stage 9: GitHub inline comment 작성
```

### 핵심 설계

| 설계 요소 | 구현 |
|----------|------|
| 병렬 에이전트 | Stage 4에서 4개 동시 실행 (Sonnet 2 + Opus 2) |
| 2단계 검증 | Stage 4 (1차) → Stage 5 (2차 subagent 재검증) |
| Confidence Filtering | 0-100 스케일, 80+ threshold |
| Progressive Tiers | Haiku(전처리) → Sonnet(표준) → Opus(심층) |
| Inline Agent | agents/ 폴더 없이 커맨드 내부에 역할 텍스트 명세 |

### Exclusion List (리뷰 제외 대상)

- Pre-existing issues (기존 이슈)
- Pedantic nitpicks (사소한 지적)
- Linter가 잡을 수 있는 것
- 입력에 따라 달라지는 문제

### claude-automate 차용 패턴

1. **병렬 에이전트 + 2단계 검증**: `/wrap` pattern-checker에 적용
2. **Confidence Scoring**: 검증 결과 노이즈 제거
3. **Progressive Tiers**: Haiku(빠른 전처리) → Sonnet(표준) → Opus(정확성)
4. **Inline Agent Definition**: 간단한 커맨드에 에이전트 내장
5. **Exclusion List**: `/wrap`에 "검증 제외 대상" 명시
