---
name: verify-web-ui
description: Web UI 검증 오케스트레이터. 시나리오 설계 → 테스트 실행 → 분석 에이전트 병렬 호출.
user-invocable: true
allowed-tools: Bash, Read, Write, Glob, Grep, Task
---

# verify-web-ui: Web UI 검증 오케스트레이터

> 시나리오 설계 → 테스트 실행 → 프로젝트 특화 에이전트 병렬 분석

---

## 아키텍처

```
/verify-web-ui {사용자 요청}
    │
    ▼
[1] test-planner → 시나리오 설계
    │
    ▼
[2] verify-web-ui agent → 테스트 실행 + 데이터 수집
    │
    ▼
[3] 프로젝트 특화 에이전트 자동 탐색 + 병렬 실행
    │
    ▼
[4] 결과 통합 리포트
```

---

## 4단계 파이프라인

### 1단계: 시나리오 설계 (순차)

```
Task(test-planner):
  prompt: |
    ## Context
    {사용자 요청 또는 "auto"}

    ## Target URL
    {URL 또는 "auto"}
  subagent_type: test-planner
```

test-planner가 반환한 시나리오를 다음 단계로 전달.

### 2단계: 테스트 실행 (순차)

```
Task(verify-web-ui):
  prompt: |
    ## 시나리오
    {1단계에서 받은 시나리오}

    ## Target URL
    {URL}
  subagent_type: verify-web-ui
```

데이터 수집 완료까지 대기. 결과 경로(`.claude/verify-data/{timestamp}/`) 확보.

### 3단계: 프로젝트 특화 에이전트 자동 탐색 + 병렬 실행

```bash
# 프로젝트의 .claude/agents/ 에서 verify-* 에이전트 탐색
Glob(".claude/agents/verify-*.md")
```

**제외 대상**: `verify-web-ui`, `test-planner` (이미 실행됨)

발견된 에이전트들을 **하나의 메시지에서 모두 Task 호출** (병렬 실행):

```
# 예시: flovy 프로젝트에서 3개 발견 시
Task(verify-llm-evaluator):
  prompt: |
    데이터 경로: .claude/verify-data/{timestamp}/
    시나리오: {시나리오 요약}
  subagent_type: verify-llm-evaluator

Task(verify-ux-consultant):
  prompt: |
    데이터 경로: .claude/verify-data/{timestamp}/
    시나리오: {시나리오 요약}
  subagent_type: verify-ux-consultant

Task(verify-idea-suggester):
  prompt: |
    데이터 경로: .claude/verify-data/{timestamp}/
    백로그 경로: docs/backlogs/
  subagent_type: verify-idea-suggester
```

**에이전트 없는 프로젝트** (예: my-blog):
- 3단계 스킵
- 1-2단계 결과만으로 리포트 생성

### 4단계: 결과 통합

모든 에이전트 완료 후 통합 리포트 출력:

```markdown
## 검증 결과 리포트

**시나리오**: {시나리오 이름}
**검증 시간**: {timestamp}
**데이터 경로**: .claude/verify-data/{timestamp}/

---

### QA 체크리스트
{verify-web-ui 결과 - 각 단계 pass/fail}

### 분석 결과
{각 특화 에이전트 결과 - 에이전트별 섹션}

---

### 우선 조치 필요
1. {Critical 이슈들}

### 다음 단계
1. {권장 액션들}
```

---

## 에이전트 선택 가이드

사용자 요청에 따라 범위 조정:

| 키워드 | 동작 |
|--------|------|
| "전체", "테스트" | 전체 파이프라인 실행 |
| "시나리오만", "계획만" | 1단계만 실행 |
| "확인", "체크" | 1-2단계만 (분석 생략) |
| 기타 | 전체 파이프라인 실행 |

---

## 사용 예시

### 전체 검증
```
/verify-web-ui 온보딩 전체 테스트해줘
→ test-planner → verify-web-ui → 특화 에이전트 병렬 → 리포트
```

### 변경사항 기반 자동 검증
```
/verify-web-ui 오늘 작업한 내용 테스트
→ git diff 분석 → 영향 받는 UI 시나리오 설계 → 실행 → 리포트
```

### 현재 화면 확인
```
/verify-web-ui 현재 화면 확인
→ 현재 열린 페이지 스냅샷/스크린샷 → 리포트
```

---

## 주의사항

- 1단계와 2단계는 반드시 순차 실행
- 3단계 에이전트들은 반드시 병렬 실행
- 특화 에이전트 탐색은 Glob으로 동적 수행 (하드코딩 금지)
- verify-web-ui agent와 test-planner는 탐색 결과에서 제외
- 데이터 경로는 모든 에이전트에 동일하게 전달
