---
name: save-context
description: |
  세션 컨텍스트 저장. Stop Hook이 컨텍스트 70% 도달 시 트리거.
  수동 호출도 가능.
allowed-tools:
  - Read
  - Glob
  - Write
  - Task
  - AskUserQuestion
---

# /save-context

> 세션 컨텍스트를 상황별 템플릿으로 저장

$ARGUMENTS

---

## 역할

현재 세션 상태를 파악하고, 상황에 맞는 템플릿으로
`.claude/context/{YYYY-MM}/{YYYY-MM-DD}-{slug}.md`에 저장한다.

---

## 실행

1. Claude가 대화 내용을 보고 상황 추천
2. AskUserQuestion으로 사용자 확인 (multiSelect: true)
   - implement 중 (AC 진행 상황 저장)
   - planning 중 (설계 논의 저장)
   - brainstorm 중 (아이디어 저장)
   - 자유 대화 (대화 요약 저장)
3. 선택된 템플릿으로 컨텍스트 작성
   MUST: refs/context-templates.md를 읽고 템플릿을 확인하라.
4. `.claude/context/{YYYY-MM}/{YYYY-MM-DD}-{slug}.md`에 저장
5. "새 세션에서 /start-work로 이어가세요" 안내

---

## 제약

- AC는 plan 파일이 SSOT — 컨텍스트에는 plan 경로만 저장
- 저장 외 다른 작업 하지 않는다 (백로그 이동, 커밋 등은 /wrap)

---

## 검증

MUST: 아래 체크리스트를 모두 확인하라.

- [ ] 컨텍스트 파일이 생성되었는가?
- [ ] 공통 헤더가 포함되어 있는가? (상태, plan 경로, 다음 행동)
- [ ] 사용자 확인을 받았는가?

실패 시: 해당 부분으로 돌아가 수정 → 재검증.

---

## 주의사항

1. **가볍게** — 저장만 하고 끝. 마무리 작업은 /wrap
2. **사용자 확인 필수** — Claude 추천 + 사용자 확인
3. **plan AC 중복 금지** — plan 경로만 참조
