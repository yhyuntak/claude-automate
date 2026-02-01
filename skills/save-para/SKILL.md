---
name: save-para
description: 대화 중 인사이트를 PARA Resources에 저장. "파라 저장", "리소스에 저장", "지식 저장" 키워드로 자동 활성화.
argument-hint: "[제목]"
---

# save-para

> 대화 중 배운 내용을 PARA Resources에 저장

---

## 저장 위치

```
~/workspace/mynotes/Resources/
├── concepts/       # 언어 무관 개념
├── architecture/   # 아키텍처 패턴
├── python/         # Python 특화
├── javascript/     # JavaScript 특화
├── react/          # React 특화
├── infra/          # 인프라, DevOps
└── _inbox/         # 임시 (분류 전)
```

---

## 워크플로우

### 1. 내용 확인 (필수)

**항상 사용자에게 물어보기:**

```
AskUserQuestion:
  question: "어떤 내용을 저장할까요?"
  options:
    - 최근 논의한 내용 요약 제안
    - "직접 입력"
```

### 2. 카테고리 선택

```
AskUserQuestion:
  question: "어느 카테고리에 저장할까요?"
  options:
    - concepts (언어 무관 개념)
    - architecture (아키텍처 패턴)
    - python
    - javascript
    - react
    - infra
    - _inbox (나중에 분류)
    - "새 카테고리 생성"
```

### 3. 제목/파일명 확인

```
AskUserQuestion:
  question: "제목은 '{제안된 제목}'으로 할까요?"
  options:
    - "네"
    - "직접 입력"
```

### 4. 저장 실행

1. **파일 생성**
   ```
   ~/workspace/mynotes/Resources/{category}/{slug}.md
   ```

2. **템플릿 적용**
   ```markdown
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
   ```

3. **README.md 업데이트**
   - 해당 카테고리 README.md 테이블에 추가
   - Resources/README.md "최근 추가" 테이블에 추가

---

## 인덱스 업데이트 로직

### 카테고리 README.md

```markdown
## 문서 목록

| 제목 | 설명 | 태그 |
|------|------|------|
| [[새문서]] | 첫 문장 | #tag1 #tag2 |  ← 추가
```

### Resources/README.md

```markdown
## 최근 추가

| 제목 | 카테고리 | 태그 | 생성일 |
|------|----------|------|--------|
| [[새문서]] | concepts | #tag | 2026-02-01 |  ← 맨 위에 추가
```

---

## 완료 메시지

```markdown
## 저장 완료!

- **파일**: Resources/concepts/race-condition.md
- **카테고리**: concepts
- **태그**: #concurrency #backend

인덱스가 업데이트되었습니다.
```

---

## 파일명 규칙

- 영문 소문자
- 공백 → 하이픈 (-)
- 한글 제목 → 영문 slug 생성

예: "Race Condition 해결법" → `race-condition.md`
