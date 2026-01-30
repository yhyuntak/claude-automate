# oh-my-claudecode 플러그인 분석

> Multi-agent orchestration for Claude Code
> Version: 3.8.5
> GitHub: https://github.com/Yeachan-Heo/oh-my-claudecode

## Overview

oh-my-claudecode는 Claude Code를 위한 멀티 에이전트 오케스트레이션 도구로, 32개 전문 에이전트, 40+ 스킬, 31개 명령어를 제공한다.

## 핵심 구성

| 항목 | 개수 |
|------|------|
| **에이전트** | 32개 (3-tier: Haiku/Sonnet/Opus) |
| **스킬** | 40+ |
| **명령어** | 31개 |

## 5가지 실행 모드

### 1. Autopilot (완전 자동)
```
아이디어 → 확장 → 계획 → 실행 → QA → 검증 → 완료
```
- Phase 0: Analyst + Architect로 사양 작성
- Phase 1: 계획 생성 및 Critic 검증
- Phase 2: Ralph + Ultrawork로 병렬 실행
- Phase 3: UltraQA 반복
- Phase 4: 3명의 Architect로 최종 검증

### 2. Ultrapilot (3-5배 빠른 병렬)
```
분석 → 분해 → 파일 분할 → 병렬 실행 (최대 5 워커) → 통합 → 검증
```
- 파일 소유권 기반 배타적 분할
- 공유 파일은 순차 처리

### 3. Swarm (SQLite 기반 조정)
```
N개 에이전트 + 공유 작업 목록 + 원자적 클레임
```
- SQLite 트랜잭션으로 레이스 컨디션 방지
- 5분 미클레임 시 작업 자동 반환

### 4. Pipeline (순차 체인)
```
Stage 1 → Stage 2 → Stage 3 → 완료
```
- 각 Stage는 이전 출력을 입력으로 받음
- 내장 파이프라인: review, implement, debug, research, refactor, security

### 5. Ecomode (토큰 효율)
```
Haiku (기본) → Sonnet (재시도) → Opus (필요시만)
```
- 30-50% 토큰 절약
- Ultrawork의 저비용 버전

## 모드별 비교

| 모드 | 속도 | 토큰 비용 | 사용 사례 |
|------|------|----------|----------|
| Autopilot | 빠름 | 표준 | 완전 자동 구축 |
| Ultrapilot | 3-5배 | 표준 | 대규모 시스템 |
| Swarm | 매우 빠름 | 표준 | 독립 작업 병렬 |
| Pipeline | 중간 | 표준 | 다단계 처리 |
| Ecomode | 빠름 | 30-50% 절약 | 예산 프로젝트 |

## 에이전트 계층화 시스템

### 분석 에이전트
| 에이전트 | 모델 | 용도 |
|---------|------|------|
| `architect` | Opus | 전략 아키텍처, 디버깅 |
| `architect-medium` | Sonnet | 중간 복잡도 분석 |
| `architect-low` | Haiku | 빠른 코드 질문 |

### 실행 에이전트
| 에이전트 | 모델 | 용도 |
|---------|------|------|
| `executor` | Sonnet | 표준 작업 구현 |
| `executor-high` | Opus | 복잡한 다중 파일 변경 |
| `executor-low` | Haiku | 단순 단일 파일 작업 |

### 특화 에이전트
| 카테고리 | 에이전트 |
|---------|---------|
| 디자인 | designer, designer-high, designer-low |
| 연구 | researcher, researcher-low |
| 문서 | writer |
| 시각 | vision |
| 계획 | planner, analyst, critic |
| 테스트 | qa-tester, qa-tester-high |
| 보안 | security-reviewer, security-reviewer-low |
| 빌드 | build-fixer, build-fixer-low |
| TDD | tdd-guide, tdd-guide-low |
| 리뷰 | code-reviewer, code-reviewer-low |

## 핵심 설계 철학

### 1. 오케스트레이션 중심
```
사용자 = 지휘자 (지시만)
Claude = 콘서트마스터 (조정)
에이전트 = 연주자 (전문 담당)
```

### 2. 위임 강제 (Delegation Enforcement)
```
오케스트레이터 (Read, Track)
        ↓ Task tool
에이전트 (Implement)
```
- 오케스트레이터는 `.omc/`, `.claude/`, 문서만 수정 가능
- 모든 코드 변경은 executor에게 위임
- PreToolUse 훅으로 강제

### 3. 아키텍처 중심 의사결정
```
요구사항 → Analyst → Architect → Plan → Execute → Verify
```

### 4. 스마트 모델 라우팅
```
Simple → Haiku (빠르고 저렴)
Medium → Sonnet (균형)
Complex → Opus (깊은 추론)
```

## 검증 프로토콜 (Iron Law)

완료 전 필수 확인:
1. BUILD: `tsc --noEmit` ✓
2. TEST: `npm test` ✓
3. LINT: `eslint src/` ✓
4. FUNCTIONALITY: 기능 작동 ✓
5. ARCHITECT: Opus 검증 ✓
6. TODO: 모든 작업 완료 ✓
7. ERROR_FREE: 에러 없음 ✓

## 주요 명령어

### 실행
- `/autopilot` - 완전 자동 실행
- `/ultrapilot` - 병렬 자동 실행
- `/ultrawork` - 최대 성능 모드
- `/ecomode` - 토큰 효율 모드
- `/swarm` - SQLite 기반 조정
- `/pipeline` - 순차 체인
- `/ralph` - 완료까지 반복

### 분석
- `/analyze` - 깊이 있는 분석
- `/research` - 병렬 연구
- `/deepsearch` - 철저한 검색

### 검증
- `/code-review` - 코드 리뷰
- `/security-review` - 보안 검토
- `/build-fix` - 빌드 에러 수정

### 설정
- `/omc-setup` - 초기 설정
- `/help` - 도움말

## AI-Native 워크플로우와의 연결

| 개념 | oh-my-claudecode 구현 |
|------|----------------------|
| 병렬 에이전트 | 32개 전문 에이전트 + Ultrapilot/Swarm |
| 아키텍처 중심 | Architect 검증 필수 (ralph) |
| 코드 안 읽기 | 위임 강제 (오케스트레이터는 조정만) |
| 시스템 학습 | Notepad wisdom, Learner 스킬 |
| 모델 효율화 | 3-tier 라우팅 (Haiku/Sonnet/Opus) |

## References

- [GitHub Repository](https://github.com/Yeachan-Heo/oh-my-claudecode)
- [Documentation](https://yeachan-heo.github.io/oh-my-claudecode-website/)
