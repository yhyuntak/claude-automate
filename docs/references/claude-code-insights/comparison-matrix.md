---
title: ECC vs claude-automate 비교 매트릭스
created: 2026-02-16
phase: phase4-003
sources:
  - g1-everything-claude-code-deep-review.md
  - review-insights.md
---

# ECC vs claude-automate 비교 매트릭스

> Everything Claude Code (ECC) vs claude-automate (CA) 전체 비교 분석

---

## 요약 통계

| 항목 | ECC (v1.4.1) | CA (v0.23.1) |
|------|-------------|-------------|
| Agents | 13 | 5 |
| Skills | 37 | 1 |
| Commands | 31 | ~10 (commands + skills 합산) |
| Rules | 23 (common 8 + lang 15) | 4 |
| Hooks | 14 entries (6 event types) | 0 |
| Contexts | 3 | ~유사 (세션 컨텍스트) |
| MCP Configs | 15 | 0 |
| Schemas | 3 | 0 |
| Tests | 12 files | 0 |
| Scripts | 15+ | 0 |
| 언어 지원 | TS/Python/Go/Java/C++ | 언어 무관 (범용) |
| Stars | 42K+ | 개인 프로젝트 |
| 버전 | v1.4.1 | v0.23.1 |

---

## 설계 철학 비교

| 관점 | ECC | CA |
|------|-----|-----|
| 핵심 목표 | Token 효율 최적화 | Developer가 AI를 제어 |
| 패러다임 | Token-first (Context Rot 방지) | Harness-first (운전대) |
| 학습 방식 | 자동 (Instinct + Hook 100% 캡처) | 수동 (PARA + /save-para) |
| 에이전트 설계 | 도메인 특화 (reviewer, builder) | 범용 역할 (explore, writer) |
| 커맨드 철학 | 풍부한 커맨드 (31개) | 최소 핵심 (2개) |
| 병렬화 | MVP (Minimum Viable Parallelization) | 적극적 병렬 (agent-delegation) |
| 확장 전략 | 언어별 × 관심사별 매트릭스 | 범용 + 필요시 확장 |
| 세션 관리 | Hook 기반 자동 (start/end/compact) | 커맨드 기반 수동 (/wrap, /start-work) |
| 타겟 사용자 | 언어별 개발자 | 언어 무관 개발자 |
| 제어 초점 | 자동화 최대화 | 통제 최대화 |

---

## 기능별 상세 비교

### 4.1 Agent 비교

| 기능 | ECC | CA | 비고 |
|------|-----|-----|------|
| Model tier 분리 | Y (opus/sonnet/haiku) | Y (explore-high/writer-high) | 동일 개념, 다른 적용 |
| Tool restriction | Y (frontmatter) | Y (agent-delegation.md) | ECC가 더 세밀 |
| 도메인 특화 | Y (13개 전문 에이전트) | N (범용 5개) | CA는 의도적 범용 |
| Agent chaining | Y (/orchestrate) | N | Gap |
| PROACTIVE 호출 | Y (description에 지시) | N (명시적 위임만) | 철학 차이 |
| Reviewer 에이전트 | Y (code/security/db/go/python) | N | Gap |
| 언어별 에이전트 | Y (go-*, python-*) | N | 스킵 (범용 목적) |
| 병렬 실행 강조 | Y (MVP) | Y (적극적) | CA가 더 강조 |
| Context 오염 방지 | Y (tool restriction) | Y (위임 규칙) | 접근 다름 |
| 에이전트 수 | 13 | 5 | ECC: 전문화, CA: 범용 |

### 4.2 Skill 비교

| 기능 | ECC | CA | 비고 |
|------|-----|-----|------|
| SKILL.md 표준 | Y | Y | 동일 구조 |
| config.json 보조 | Y | N | CA는 SKILL.md만 |
| 학습 시스템 | Y (continuous-learning v1/v2) | N | 최대 Gap |
| 검증 루프 | Y (verification-loop) | Y (verify-web-ui만) | CA는 UI만 |
| 보안 리뷰 | Y (OWASP 기반) | N | Gap |
| 코드 품질 | Y (coding-standards, TDD) | N | Gap |
| Eval Harness | Y (EDD) | N | Gap |
| Iterative Retrieval | Y (4-phase loop) | N | 원리 차용 대상 |
| Strategic Compact | Y (tool count + 제안) | N | 즉시 차용 가능 |
| 언어별 패턴 | Y (16개) | N | 스킵 (범용) |
| PARA 저장 | N | Y (/save-para) | CA 고유 |
| 백로그 관리 | N | Y (backlog skill) | CA 고유 |
| Multi-stage workflow | Y (planner-reviewer 분리) | Y (planning/brainstorm) | 유사 접근 |
| Skill 파일 수 | 37 | 1 | ECC: 세분화, CA: 최소화 |

### 4.3 Command 비교

| 기능 | ECC | CA | 비고 |
|------|-----|-----|------|
| 세션 시작 | Y (/sessions) | Y (/start-work) | 유사 |
| 세션 종료 | Y (hook 자동) | Y (/wrap) | ECC: 자동, CA: 수동 |
| 계획 수립 | Y (/plan) | Y (/planning) | 유사 |
| 코드 리뷰 | Y (/code-review) | N | Gap |
| TDD | Y (/tdd) | N | Gap |
| 빌드 수정 | Y (/build-fix) | N | Gap |
| 검증 | Y (/verify) | Y (verify-web-ui) | CA는 UI만 |
| 오케스트레이션 | Y (/orchestrate) | N | Gap |
| 학습/진화 | Y (/learn, /evolve) | N | Gap |
| Multi-model | Y (/multi-*) | N | 스킵 |
| 브레인스토밍 | N | Y (/brainstorm) | CA 고유 |
| 규칙 설치 | N | Y (/install-rule) | CA 고유 |
| 프로젝트 초기화 | N | Y (/project-init) | CA 고유 |
| 스킬 생성 | Y (/new-skill) | N | Gap |
| 컨텍스트 압축 | Y (/compact) | N | Gap |
| 커맨드 수 | 31 | ~10 | ECC: 풍부, CA: 최소 |

### 4.4 Rule 비교

| 기능 | ECC | CA | 비고 |
|------|-----|-----|------|
| 에이전트 위임 규칙 | Y (agents.md) | Y (agent-delegation.md) | 유사 |
| 코딩 스타일 | Y (common + 언어별) | N | Gap |
| 보안 규칙 | Y (common + 언어별) | N | Gap |
| 테스팅 규칙 | Y (common + 언어별) | N | Gap |
| Git 워크플로우 | Y (git-workflow.md) | Y (workflow.md) | 유사 |
| Hook 규칙 | Y (hooks.md) | N | Gap |
| 상호작용 규칙 | N | Y (interaction.md) | CA 고유 |
| 백로그 규칙 | N | Y (backlog-rules.md) | CA 고유 |
| 계층적 상속 | Y (common → language) | N | CA는 flat |
| PARA 개념 추출 | N | Y (para-concept-extraction.md) | CA 고유 |
| 언어별 규칙 | Y (15개 언어) | N | 스킵 (범용) |
| Rule 파일 수 | 23 | 4 | ECC: 세분화, CA: 최소화 |

### 4.5 Hook 비교

| 기능 | ECC | CA | 비고 |
|------|-----|-----|------|
| PreToolUse | Y (5개) | N | **완전 부재** |
| PostToolUse | Y (5개) | N | |
| PreCompact | Y (1개) | N | |
| SessionStart | Y (1개) | N | |
| SessionEnd | Y (2개) | N | |
| Stop | Y (1개) | N | |
| hooks.json | Y (170줄) | N | |
| Git 자동 커밋 | Y (PostToolUse) | N | |
| Context 자동 저장 | Y (SessionEnd) | N | |
| 도구 사용 검증 | Y (PreToolUse) | N | |
| 컨텍스트 압축 제안 | Y (PreCompact) | N | |
| 학습 자동화 | Y (observe.sh) | N | |
| Hook 인프라 | Y (완전 구현) | N | 가장 큰 Gap |

### 4.6 기타

| 기능 | ECC | CA | 비고 |
|------|-----|-----|------|
| MCP 설정 | Y (15 서버) | N | Gap |
| JSON Schema 검증 | Y (3개) | N | Gap |
| CI 테스트 | Y (12파일) | N | Gap |
| 자동화 스크립트 | Y (15+) | N | Gap |
| Context 모드 전환 | Y (dev/research/review) | N | Gap |
| 세션 컨텍스트 저장 | Y (hook 자동) | Y (/wrap 수동) | 접근 다름 |
| PARA 지식 관리 | N | Y | CA 고유 |
| 브레인스토밍 도구 | N | Y (angel/devil/brainstorm) | CA 고유 |
| 프로젝트 초기화 | N | Y (/project-init) | CA 고유 |
| Instinct 시스템 | Y (자동 학습) | N | Gap |
| 버전 관리 자동화 | Y (hooks) | Y (version-up.md) | 접근 다름 |
| 문서 동기화 검증 | Y (CI) | N | Gap |
| 복잡도 경고 | Y (compactness-warning) | N | Gap |

---

## Gap Analysis

| Gap | ECC 구현 | CA 현황 | 차용 가치 | 난이도 | 비고 |
|-----|---------|---------|----------|--------|------|
| Hook 시스템 | 14 entries, 6 event types | 없음 | 매우 높음 | 낮음 | 모든 자동화의 기반 |
| Strategic Compact | suggest-compact.js + pre-compact.js | 없음 | 높음 | 매우 낮음 | 55줄 스크립트 |
| Verification Loop | 6단계 통합 검증 | UI e2e만 | 높음 | 중간 | /verify 커맨드 |
| Context 모드 | 3개 모드 (dev/research/review) | 없음 | 중간 | 낮음 | 행동 전환 |
| Agent Chaining | /orchestrate 워크플로우 | 없음 | 중간 | 중간 | 에이전트 체인 |
| CI 검증 | 5개 validator | 없음 | 중간 | 낮음 | 구조 무결성 |
| 학습 시스템 | Instinct + observe.sh | PARA 수동 | 높음 | 높음 | 자동 vs 수동 |
| 코딩 품질 규칙 | common + 3언어 | 없음 | 낮음 | 낮음 | 프로젝트별로 다름 |
| Eval Harness | EDD 프레임워크 | 없음 | 중간 | 높음 | 스킬 A/B 테스트 |
| 보안 리뷰 | OWASP 기반 체크리스트 | 없음 | 중간 | 중간 | 보안 스킬 |
| Iterative Retrieval | 4-phase loop | 없음 | 높음 | 중간 | explore 강화 |
| Code Review 자동화 | /code-review 커맨드 | 없음 | 중간 | 중간 | 품질 검증 |
| TDD 워크플로우 | /tdd 커맨드 | 없음 | 낮음 | 낮음 | 스타일 차이 |
| 복잡도 경고 | compactness-warning 스킬 | 없음 | 중간 | 낮음 | 토큰 관리 |
| MCP 자동 설정 | 15개 서버 프리셋 | 없음 | 낮음 | 낮음 | 프로젝트별로 다름 |

---

## CA 고유 강점

| 기능 | 설명 | ECC에 없는 이유 |
|------|------|----------------|
| PARA 지식 관리 | 세션 인사이트를 체계적으로 저장 | ECC는 자동 instinct에 의존 |
| Angel/Devil 사고 확장 | 다관점 사고 도구 | ECC는 단일 관점 실행 중심 |
| Brainstorm/Planning 스킬 | 아이디어 구체화 → 계획 | ECC는 planner agent로 대체 |
| Agent delegation 규칙 | 에이전트 위임 명시적 규칙 | ECC는 PROACTIVE 자동 호출 |
| Backlog 관리 | todo/doing/done 워크플로우 | ECC는 TodoWrite만 |
| 세션 컨텍스트 .md | 날짜별 세션 기록 | ECC는 JSON 기반 |
| Interaction 규칙 | multiSelect 등 UX 규칙 | ECC에 해당 없음 |
| PARA 개념 자동 추출 | Planning 종료 시 자동 저장 제안 | ECC는 자동 학습만 |
| 프로젝트 초기화 | /project-init 워크플로우 | ECC는 언어별 템플릿 |
| 규칙 설치 시스템 | /install-rule 커맨드 | ECC는 규칙 고정 |
| 범용 설계 | 언어 무관 에이전트/스킬 | ECC는 언어 특화 |
| 통제 우선 | 명시적 위임, 수동 검증 | ECC는 자동화 우선 |

---

## 아키텍처 비교

### 확장 전략

**ECC: 매트릭스 확장**
```
언어 (TS, Python, Go, Java, C++)
  ×
관심사 (Review, Build, Security, Test)
  =
언어별 × 관심사별 에이전트/규칙
```

**CA: 범용 + 필요시 확장**
```
범용 역할 (Explore, Write, Plan)
  +
프로젝트별 커스터마이징
  =
언어 무관 에이전트 + 필요시 확장
```

### 학습 시스템

**ECC: 자동 학습**
```
Hook (100% 캡처)
  →
observe.sh (자동 기록)
  →
Instinct (자동 적용)
  →
/evolve (지속 개선)
```

**CA: 수동 학습**
```
세션 종료 (/wrap)
  →
인사이트 식별 (사용자 판단)
  →
PARA 저장 (/save-para)
  →
향후 참조 (수동)
```

### 세션 관리

**ECC: Hook 기반 자동**
```
SessionStart hook → 컨텍스트 로드
PostToolUse hook → Git 자동 커밋
SessionEnd hook → 컨텍스트 저장
PreCompact hook → 압축 제안
```

**CA: 커맨드 기반 수동**
```
/start-work → 컨텍스트 로드
사용자 판단 → Git 수동 커밋
/wrap → 검증 + 저장
사용자 판단 → 압축 결정
```

---

## 철학적 차이 요약

| 관점 | ECC | CA |
|------|-----|-----|
| 핵심 가치 | 자동화 | 통제 |
| Token 관리 | Compact 자동 제안 | 수동 판단 |
| 학습 | Hook 100% 캡처 | PARA 선별 저장 |
| 에이전트 호출 | PROACTIVE 자동 | 명시적 위임만 |
| 검증 | Hook 자동 실행 | 커맨드 수동 실행 |
| 확장성 | 언어별 전문화 | 범용 + 필요시 |
| 복잡도 | 높음 (자동화 대가) | 낮음 (의도적 최소화) |
| 대상 사용자 | 특정 언어 전문가 | 언어 무관 개발자 |
| 진입 장벽 | 높음 (많은 기능) | 낮음 (핵심만) |
| 유연성 | 낮음 (구조 고정) | 높음 (커스터마이징) |

---

## 결론 요약

### 핵심 차이

```
ECC = "모든 것을 자동화"
  - Hook 인프라로 100% 자동 캡처
  - Instinct로 자동 학습
  - 언어별 전문 에이전트
  - Token 효율 최우선

CA = "의사결정을 통제"
  - Harness로 AI 제어
  - PARA로 선별 학습
  - 범용 에이전트
  - 개발자 통제 최우선
```

### CA에 가장 필요한 것 (우선순위)

1. **Hook 인프라** (모든 자동화의 기반)
   - 난이도: 낮음
   - 가치: 매우 높음
   - 비고: PreCompact, SessionEnd 우선

2. **Strategic Compact** (즉시 차용 가능)
   - 난이도: 매우 낮음
   - 가치: 높음
   - 비고: 55줄 스크립트, 바로 적용

3. **Verification Loop** (품질 강화)
   - 난이도: 중간
   - 가치: 높음
   - 비고: UI 검증에서 통합 검증으로

4. **Iterative Retrieval** (explore 강화)
   - 난이도: 중간
   - 가치: 높음
   - 비고: 4-phase loop 원리 차용

5. **Context 모드 전환** (행동 전환)
   - 난이도: 낮음
   - 가치: 중간
   - 비고: dev/research/review 전환

### ECC가 CA에서 배울 수 있는 것

1. **PARA 지식 관리** - 구조적 인사이트 저장
2. **명시적 통제** - 자동화와 통제의 균형
3. **범용 설계** - 언어 무관 접근
4. **브레인스토밍 도구** - 사고 확장 지원
5. **사용자 중심 UX** - multiSelect 등 상호작용 규칙

### 최종 평가

| 항목 | ECC | CA |
|------|-----|-----|
| 기능 풍부도 | ★★★★★ | ★★☆☆☆ |
| 자동화 수준 | ★★★★★ | ★★☆☆☆ |
| 통제 수준 | ★★☆☆☆ | ★★★★★ |
| 학습 곡선 | ★☆☆☆☆ (가파름) | ★★★★☆ (완만) |
| 커스터마이징 | ★★☆☆☆ | ★★★★★ |
| Token 효율 | ★★★★★ | ★★★☆☆ |
| 언어 지원 | ★★★★★ (전문화) | ★★★★★ (범용) |
| 유지보수성 | ★★★☆☆ | ★★★★☆ |

**결론**: ECC와 CA는 서로 다른 철학을 가진 보완적 시스템. ECC는 자동화, CA는 통제에 강점. 상호 학습 가능.

---

**Last Updated**: 2026-02-16
