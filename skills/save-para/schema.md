# save-para 스키마

## 입력

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| content | string | O | 저장할 내용 (사용자 입력) |
| category | string | O | 카테고리 (concepts, python 등) |
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

---

**Last Updated**: {YYYY-MM-DD}
```

---

## 카테고리 목록

| 카테고리 | 설명 | 예시 |
|----------|------|------|
| concepts | 언어 무관 개념 | CORS, JWT, Race Condition |
| architecture | 아키텍처 패턴 | Clean Architecture, Event-Driven |
| python | Python 특화 | FastAPI, SQLAlchemy |
| javascript | JS 특화 | Promise, EventEmitter |
| react | React 특화 | Hooks, 상태관리 |
| infra | 인프라/DevOps | Docker, CI/CD |
| _inbox | 임시 저장 | 분류 전 |

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
