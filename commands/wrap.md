---
description: 세션 마무리 - 규칙 체크, 문서 동기화, 세션 컨텍스트 저장
---

[WRAP V3 MODE ACTIVATED]

$ARGUMENTS

---

## WRAP V3: Goal-first 구조

메인이 판단 → 필요한 에이전트만 스코프 지정해서 호출 → 결과 통합 → 세션 저장

**핵심 원칙:**
- 메인은 `git diff --stat`만 보고 판단
- 상세 수집/분석은 에이전트가 직접
- 메인 컨텍스트 최소화

---

## STEP 1: Diff 확인 및 판단

```bash
git diff --stat
git diff --cached --stat
```

파일 목록만 보고 판단:

| 변경 유형 | pattern-checker | doc-sync-checker |
|----------|-----------------|------------------|
| 코드 파일 (.ts, .py 등) | ✅ | △ (API면) |
| 문서 파일 (.md) | △ (규칙 관련이면) | ❌ |
| 설정 파일 | △ | ❌ |
| 새 기능 추가 | ✅ | ✅ |

---

## STEP 2: 스코프 결정

변경 파일 기반으로 스코프 힌트 생성:

```
예시:
- commands/feedback.md 변경 → scope: "commands 관련 규칙"
- src/api/user.ts 변경 → scope: "backend, api 규칙" + "API 문서"
- frontend/components/* 변경 → scope: "frontend 규칙"
```

---

## STEP 3: 에이전트 호출 (필요한 것만, 병렬)

### pattern-checker 호출 (규칙 체크 필요시)

```
Task(
  subagent_type="claude-automate:pattern-checker",
  prompt="""
## 변경 파일
{파일 목록}

## 스코프
{카테고리} 관련 규칙만 체크

## 지시사항
1. 위 파일들의 상세 diff 확인
2. .claude/rules/에서 관련 규칙만 읽기
3. 위반 여부 체크
4. 결과 반환
"""
)
```

### doc-sync-checker 호출 (문서 동기화 필요시)

```
Task(
  subagent_type="claude-automate:doc-sync-checker",
  prompt="""
## 변경 파일
{파일 목록}

## 스코프
{문서 유형} 관련 문서만 확인

## 지시사항
1. 위 파일들의 변경 내용 확인
2. 관련 문서 찾기
3. 불일치 여부 체크
4. 결과 반환
"""
)
```

---

## STEP 4: 결과 통합

에이전트 결과를 받아서 통합:

```markdown
## /wrap Summary

### 규칙 체크
- [위반 사항 또는 "이상 없음"]

### 문서 동기화
- [불일치 사항 또는 "이상 없음"]

### 권장 액션
1. [ ] [액션 1]
2. [ ] [액션 2]
```

---

## STEP 5: 세션 컨텍스트 저장 (항상 마지막에)

```
Task(
  subagent_type="claude-automate:context-builder",
  prompt="""
## 세션 정보
- 날짜: {오늘 날짜}
- 주요 작업: {이번 세션에서 한 일 요약}
- 변경 파일: {파일 목록}

## 분석 결과
{pattern-checker, doc-sync-checker 결과 요약}

## 지시사항
세션 컨텍스트 파일 생성해줘
"""
)
```

컨텍스트 파일 경로: `.claude/context/YYYY-MM/YYYY-MM-DD-{session-id}.md`

---

## STEP 6: 최종 출력

```markdown
## /wrap Complete

### Summary
[간단 요약]

### Actions (선택)
1. [ ] [액션]

### Session Saved
✅ .claude/context/2026-01/2026-01-22-abc123.md
```

---

## 판단 가이드

### 단순 케이스 (에이전트 최소 호출)
```
문서 1개만 수정 → context-builder만
설정 파일만 수정 → context-builder만
```

### 일반 케이스
```
코드 수정 → pattern-checker + context-builder
API 수정 → pattern-checker + doc-sync-checker + context-builder
```

### 복잡 케이스 (에스컬레이션)
```
규칙 충돌 → pattern-checker-high로 에스컬레이션
문서 구조 변경 필요 → doc-sync-checker-high로 에스컬레이션
```

---

## THE WRAP PROMISE

완료 전 확인:
- [ ] diff --stat으로 변경 파일 확인함
- [ ] 필요한 에이전트만 호출함 (불필요한 에이전트 호출 X)
- [ ] 스코프를 명확히 지정함
- [ ] context-builder로 세션 저장함
- [ ] 사용자에게 결과 보여줌
