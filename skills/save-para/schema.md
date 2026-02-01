# save-para 스키마

## 입력

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| content | string | O | 저장할 내용 (사용자 입력) |
| category | string | O | 카테고리 (README.md에서 동적 조회) |
| title | string | O | 문서 제목 |
| tags | string[] | X | 태그 목록 |

---

## 출력

| 필드 | 타입 | 설명 |
|------|------|------|
| file_path | string | 생성된 파일 경로 |
| category | string | 저장된 카테고리 |
| indexes_updated | string[] | 업데이트된 README 목록 |

---

## 파일 템플릿

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

## 카테고리 조회 (동적)

**하드코딩 금지** - 실행 시 README.md에서 조회

```
조회 경로: ~/workspace/mynotes/Resources/README.md
조회 위치: "카테고리" 테이블 또는 "분류 기준" 테이블
```

카테고리 목록은 mynotes에서 관리되며, 이 스킬은 단지 참조만 합니다.

---

## 태그 가이드

| 태그 | 용도 |
|------|------|
| #concurrency | 동시성 관련 |
| #security | 보안 관련 |
| #performance | 성능 관련 |
| #pattern | 디자인 패턴 |
| #troubleshooting | 문제 해결 |
| #how-to | 가이드/튜토리얼 |
