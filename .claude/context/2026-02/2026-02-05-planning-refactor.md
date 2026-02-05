# Session: 2026-02-05 Planning Refactor & Global Agent Cleanup

## Context

Planning 스킬의 Brain 기반 구현을 위해 체계적으로 에이전트 구조를 정리하는 세션. 전역 에이전트 7개를 devil/angel 2개로 통합하고, planning/brainstorm 스킬을 개선하여 v0.15.0 릴리즈 준비.

## Work Summary

### Global Agent 정리
- 전역 에이전트 7개 삭제 (silicon-valley-veteran, silicon-valley-pm-veteran, silicon-valley-design-veteran, tech-devil-advocate, execution-feasibility-advisor, creative-problem-solver, innovation-cto)
- devil.md 생성: 냉철한 비판자 역할 (검증, 위험 분석, 실행성 평가)
- angel.md 생성: 생각 확장자 역할 (아이디어 발산, 가능성 탐색, 창의적 사고)
- /devil, /angel 커맨드 생성

### Planning 스킬 개선
- 요구사항 충분도 판단 로직 추가 (MINIMUM, BASIC, GOOD 3단계)
- devil 검증 2회 호출: 요구사항 초안 검증 → 최종 계획 검증
- ASCII 시각화 기능 제안 (Flowchart, Gantt, Decision Tree)
- 요구사항 템플릿 구조 개선

### Brainstorm 스킬 개선
- Phase 3.5 angel 연동 추가 (아이디어 발산 촉진)
- 요구사항 템플릿 개선 및 정규화

### 버전 관리
- .claude-plugin/plugin.json, marketplace.json v0.15.0 갱신
- 프로젝트 버전 준비 완료

## Problems & Solutions

**문제**: agents/ 폴더의 devil.md, angel.md에 frontmatter 누락
→ **해결**: pattern-checker 실행 → 자동 수정 (---로 묶인 Markdown 헤더 추가)

**문제**: planning 스킬의 devil 호출 순서와 메시지 형식 정의 필요
→ **해결**: 요구사항 검증 → 계획 수립 → 최종 검증으로 3단계 구조화, 명확한 지시사항 템플릿 작성

## Decisions

1. **Global Agent 단순화 (7 → 2)**
   - 근거: 다양한 관점이 필요하지만, 체계적 구조가 필요. devil(비판)/angel(확장)로 분리
   - 영향: planning/brainstorm에서 일관된 에이전트 호출 가능

2. **Devil의 검증 2회 호출**
   - 근거: 초안 검증(빠른 피드백) + 최종 검증(완성도 확인)
   - 영향: 요구사항 품질 향상, 불완전한 계획 조기 발견

3. **Angel 에이전트 도입**
   - 근거: brainstorm Phase 3.5에서 아이디어 발산 촉진 필요
   - 영향: 창의적 아이디어 생성 → 더 나은 아키텍처 설계

4. **ASCII 시각화 기능 추가 제안**
   - 근거: 복잡한 계획을 시각적으로 표현하면 이해도 상승
   - 상태: 스킬 정의에 기록 (향후 구현 예정)

## Incomplete/TODO

- [ ] v0.15.0 릴리즈 (태그 생성 + GitHub Release)
- [ ] devil/angel 커맨드 사용성 테스트
- [ ] planning/brainstorm 스킬 엔드투엔드 테스트
- [ ] ASCII 시각화 기능 구현 (향후 v0.16.0 고려)
- [ ] 전역 에이전트 문서 (.claude/agents/) 업데이트 (프로젝트별 agents/ 사용 가이드)

## Next Session Suggestions

1. **v0.15.0 릴리즈** - 태그 생성 및 GitHub Release 작성
2. **Planning 통합 테스트** - devil 검증 워크플로우 실제 동작 확인
3. **Brainstorm Phase 3.5 테스트** - angel 에이전트 연동 확인
4. **ASCII 시각화 스펙 작성** - Flowchart, Gantt, Decision Tree 상세 정의
5. **에이전트 가이드 문서** - 프로젝트별 agents/ 생성 및 관리 방법

---

**Created**: 2026-02-05T14:30:00Z
**Phase**: v0.15.0 Preparation
**Files Modified**: 12+
**Files Deleted**: 7
**Files Created**: 6
