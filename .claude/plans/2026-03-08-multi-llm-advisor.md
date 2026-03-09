---
status: done
created: 2026-03-08
slug: multi-llm-advisor
test-command:
---

# Plan: multi-llm-advisor

## Requirements

### Context (Background)
- Claude Code에서 Gemini CLI, Codex CLI를 headless로 호출하여 다른 LLM의 의견을 받을 수 있음을 확인함
- Gemini는 UI/디자인 분석에, Codex(GPT)는 코드/버그 분석에 각각 다른 강점을 보임
- 3모델 동시 리뷰 시 서로 보완적인 결과가 나옴 (실제 flovy 프로젝트로 검증)
- 시스템 프롬프트를 셸 스크립트에 내장하면 Claude 토큰 절약 가능

### What
- Gemini CLI, Codex CLI를 호출하는 에이전트 2개 등록
- 시스템 프롬프트를 내장한 셸 스크립트 생성
- 3모델 동시 호출 + 비교하는 멀티 리뷰 스킬 생성

### Why
- 단일 LLM으로는 놓치는 관점을 다중 LLM으로 커버
- 각 모델의 강점을 역할 고정으로 활용 (Gemini=UI, Codex=코드)
- 셸 스크립트로 시스템 프롬프트를 내장하여 Claude 토큰 소비 최소화

### Scope
- ✅ In: gemini-advisor 에이전트, codex-advisor 에이전트, 셸 스크립트 2개, multi-review 스킬
- ❌ Out: API 기반 호출 (CLI만 사용), 자동 라우팅 (역할 고정), Brain 초기화 (별도 작업)

## Brain Update

- code-map: agents/gemini-advisor.md, agents/codex-advisor.md, agents/scripts/ 폴더 추가
- patterns: 외부 CLI 호출 에이전트 패턴 (Bash로 셸 스크립트 실행, 시스템 프롬프트 외부화)
- decisions: 역할 고정 (Gemini=UI/디자인, Codex=코드/버그), CLI 구독 활용 (Gemini Pro 플랜 + Codex API)

## AC List

- [x] AC-1: gemini-advisor 에이전트 등록
  - TC: agents/gemini-advisor.md에 name, description, model, allowed-tools(Bash 포함) frontmatter 존재
  - TC: Task(subagent_type="claude-automate:gemini-advisor", prompt="테스트") 호출 시 Gemini CLI 응답이 반환됨
- [x] AC-2: codex-advisor 에이전트 등록
  - TC: agents/codex-advisor.md에 name, description, model, allowed-tools(Bash 포함) frontmatter 존재
  - TC: Task(subagent_type="claude-automate:codex-advisor", prompt="테스트") 호출 시 Codex CLI 응답이 반환됨
- [x] AC-3: 셸 스크립트 생성 (gemini-advisor.sh, codex-advisor.sh)
  - TC: 시스템 프롬프트가 스크립트에 하드코딩되어 있고, $1로 추가 프롬프트만 받음
  - TC: chmod +x 실행 권한 부여됨
  - TC: CLI 미설치 시 "Gemini CLI not found. Run: npm install -g @google/gemini-cli" 출력 + exit 1
  - TC: 인증 실패 감지 시 "Authentication required. Run: gemini (interactive)" 출력
- [x] AC-4: 프로젝트 경로 자동 감지 + 컨텍스트 인식
  - TC: 스크립트가 $2 또는 $PWD 경로에서 cd 후 CLI 호출
  - TC: 프로젝트 폴더에서 실행 시 CLI가 파일명을 언급하는 응답 반환 (cd ~/workspace/claude-automate && ./agents/scripts/gemini-advisor.sh "agents/ 폴더 파일 목록" 으로 검증)
- [x] AC-5: 타임아웃 + 에러 처리
  - TC: ADVISOR_TIMEOUT 환경변수로 타임아웃 설정 가능 (기본값 60초)
  - TC: 타임아웃 시 "Timeout: No response within ${ADVISOR_TIMEOUT}s" 출력 + exit 1
  - TC: CLI stderr 출력은 분리하고, exit code != 0 시 에러 메시지 반환
- [x] AC-6: 멀티 리뷰 스킬 생성
  - TC: skills/multi-review/SKILL.md 존재, frontmatter에 name, description 포함
  - TC: Claude(explore-high) + gemini-advisor + codex-advisor 3개 Task()가 병렬 dispatch
  - TC: 3모델 응답을 비교 테이블(관점, 고유 발견, 강점)로 종합
  - TC: 1~2모델 실패 시 성공한 모델 결과만 출력 + "⚠️ {모델명} 응답 실패" 표시

## Implementation Order

1. [Sequential] AC-3 → agents/scripts/gemini-advisor.sh, agents/scripts/codex-advisor.sh (다른 AC의 기반)
2. [Parallel] AC-1 → agents/gemini-advisor.md / AC-2 → agents/codex-advisor.md (독립 파일)
3. [Sequential] AC-4 → AC-3 스크립트 수정 (경로 처리 로직 추가)
4. [Sequential] AC-5 → AC-3 스크립트 수정 (타임아웃 + 에러 처리 추가)
5. [Sequential] AC-6 → skills/multi-review/SKILL.md (AC-1, AC-2 완료 후)
