# PARA Concept Extraction Rule

> Planning 종료 시 상위 레벨 개념을 자동 추출하여 PARA Resources에 저장

---

## 트리거 타이밍

**Planning 단계가 끝날 때** (Clear Context 전에) 실행합니다.

| 상황 | 트리거 |
|------|--------|
| Plan Mode (ExitPlanMode) | Plan 승인 후, 구현 시작 전 |
| 비공식 Planning 논의 | "구현하자", "시작하자" 전환 시점 |
| Plan 에이전트 결과 검토 후 | 사용자가 Plan 승인 시 |

**핵심**: Clear Context 전에 반드시 실행. 컨텍스트가 날아가면 개념도 사라짐.

---

## 실행 흐름

### Step 1: Pre-check

이 Planning 세션에 상위 레벨 개념 논의가 있었는가?

**추출 대상 (Include):**
- 새로 논의된 아키텍처 개념, 디자인 패턴
- 트레이드오프 분석, 품질 속성 논의
- 기술 비교/선택 근거
- 문제 해결에서 도출된 범용 원칙

**제외 (Exclude):**
- 구현 디테일 (코드, 설정값)
- 이 프로젝트에서만 유효한 정보
- 이미 잘 알려진 기초 지식

**스킵 조건**: 단순 설정/오타/커밋 논의만 있었을 때

### Step 2: 개념 식별

Main이 세션에서 논의된 상위 레벨 개념 **1~4개** 식별:
- 개념명
- 한 줄 설명
- 추천 카테고리 (Resources/README.md 기준)
- 추천 태그

### Step 3: 사용자 확인

```
AskUserQuestion (multiSelect: true)
  "이번 Planning에서 다음 개념들을 PARA에 저장할까요?"
  각 개념이 option으로 표시
  description에 추천 카테고리 포함
```

선택 없으면 → 스킵하고 구현으로 진행

### Step 4: 저장 실행

선택된 개념들을 **배치로** writer 에이전트에 위임:

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
PARA Resources에 개념 문서 저장 + 인덱스 업데이트

## Target
~/workspace/mynotes/Resources/{category}/{slug}.md (생성)
~/workspace/mynotes/Resources/{category}/README.md (업데이트)
~/workspace/mynotes/Resources/README.md (업데이트)

## Concepts to Save
{선택된 개념 목록 + 상세 내용}

## Template (save-para 스킬 기준)
---
title: {title}
created: {YYYY-MM-DD}
tags: [{tags}]
source: claude-session
---

# {title}

{content}

---

## 관련 문서

-

## Index Update Rules
1. 카테고리 README.md → 문서 목록 테이블에 항목 추가
2. Resources/README.md → "최근 추가" 테이블 맨 위에 추가 + 문서 수 갱신
"""
)
```

### Step 5: 완료 보고

```markdown
## PARA 저장 완료

- 📝 {concept1} → Resources/{category1}/
- 📝 {concept2} → Resources/{category2}/

이제 구현을 진행합니다.
```

---

## 판단 기준

| 세션 유형 | 판단 |
|----------|------|
| 아키텍처/설계 논의 | ✅ 추출 |
| 기술 비교/트레이드오프 | ✅ 추출 |
| 새 패턴/원칙 발견 | ✅ 추출 |
| 코드 구현만 | ❌ 스킵 |
| 설정/오타 수정 | ❌ 스킵 |
| 버그 수정 (범용 원칙 없음) | ❌ 스킵 |

---

## save-para 스킬과의 관계

| | save-para (수동) | 이 규칙 (자동) |
|---|---|---|
| 트리거 | 사용자가 `/save-para` 호출 | Planning 종료 시 자동 |
| 대상 | 1개 개념 | 1~4개 배치 |
| 카테고리 선택 | 대화형 (AskUserQuestion) | Main이 추천 + 확인 |
| 템플릿 | save-para SKILL.md | 동일 템플릿 사용 |
| 인덱싱 | 동일 | 동일 |
