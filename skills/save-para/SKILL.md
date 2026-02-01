---
name: save-para
description: 대화 중 인사이트를 PARA Resources에 저장. "파라 저장", "리소스에 저장", "지식 저장" 키워드로 자동 활성화.
argument-hint: "[제목]"
---

# save-para

> 대화 중 배운 내용을 PARA Resources에 저장

---

## Progressive Disclosure 워크플로우

이 스킬은 **하드코딩된 구조 없이** README.md를 순차적으로 읽어서 동적으로 작동합니다.

### Step 1: PARA 루트 확인

```
Read: ~/workspace/mynotes/README.md
→ PARA 구조 이해 (Projects, Areas, Resources, Archive)
→ Resources/ 폴더로 진입
```

### Step 2: Resources 구조 파악

```
Read: ~/workspace/mynotes/Resources/README.md
→ "분류 기준" 테이블에서 카테고리 목록 추출
→ "카테고리" 테이블에서 현재 폴더 구조 확인
```

### Step 3: 사용자 질문 (동적 옵션)

**내용 확인:**
```
AskUserQuestion:
  question: "어떤 내용을 저장할까요?"
  options:
    - 최근 논의한 내용 요약 제안
    - "직접 입력"
```

**카테고리 선택 (README.md에서 읽은 목록 사용):**
```
AskUserQuestion:
  question: "어느 카테고리에 저장할까요?"
  options:
    - (Resources/README.md의 "카테고리" 테이블에서 동적으로 생성)
    - "새 카테고리 생성"
```

### Step 4: 카테고리 README 확인

```
Read: ~/workspace/mynotes/Resources/{선택한 카테고리}/README.md
→ 해당 카테고리의 규칙/형식 파악
→ 기존 문서 목록 확인 (중복 방지)
```

### Step 5: 제목/파일명 확인

```
AskUserQuestion:
  question: "제목은 '{제안된 제목}'으로 할까요?"
  options:
    - "네"
    - "직접 입력"
```

### Step 6: 저장 실행

1. **파일 생성**: `~/workspace/mynotes/Resources/{category}/{slug}.md`
2. **템플릿 적용** (아래 참조)
3. **인덱스 업데이트** (아래 참조)

---

## 템플릿

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

---

## 인덱스 업데이트

### 카테고리 README.md

문서 목록 테이블에 새 항목 추가:
```markdown
| [[새문서]] | 첫 문장 | #tag1 #tag2 |
```

### Resources/README.md

"최근 추가" 테이블 맨 위에 추가:
```markdown
| [[새문서]] | {category} | #tag | {date} |
```

"카테고리" 테이블의 문서 수 갱신

---

## 새 카테고리 생성 시

1. `Resources/{new-category}/` 폴더 생성
2. `Resources/{new-category}/README.md` 생성 (기존 카테고리 README 형식 참조)
3. `Resources/README.md`의 "분류 기준" 및 "카테고리" 테이블 업데이트

---

## 완료 메시지

```markdown
## 저장 완료!

- **파일**: Resources/{category}/{slug}.md
- **카테고리**: {category}
- **태그**: {tags}

인덱스가 업데이트되었습니다.
```

---

## 파일명 규칙

- 영문 소문자
- 공백 → 하이픈 (-)
- 한글 제목 → 영문 slug 생성

예: "Race Condition 해결법" → `race-condition.md`
