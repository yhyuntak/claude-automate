# ADR (Architecture Decision Records) 자동 생성

> 중요한 아키텍처 결정 시 자동으로 기록

---

## 언제 ADR을 생성하나?

다음 상황에서 **자동으로** ADR 파일을 생성:

1. **기술 선택**: 새 라이브러리, 프레임워크, 서비스 도입
2. **패턴 변경**: 기존 아키텍처 패턴 변경 또는 새 패턴 도입
3. **구조 변경**: 디렉토리 구조, 레이어 분리 방식 변경
4. **중요한 트레이드오프**: 성능 vs 가독성, 단순함 vs 확장성 등

---

## ADR 파일 위치

```
docs/adr/
├── README.md           # ADR 목록
├── 001-postgresql.md
├── 002-llm-router.md
└── NNN-제목.md
```

---

## ADR 템플릿

```markdown
# ADR-NNN: [제목]

**Date**: YYYY-MM-DD
**Status**: Accepted | Deprecated | Superseded by ADR-XXX

## Context
왜 이 결정이 필요했나? 어떤 문제를 해결하려 했나?

## Decision
무엇을 선택했나?

## Alternatives Considered
다른 옵션들은? 왜 선택하지 않았나?

## Rationale
왜 이 결정을 내렸나? (장단점 분석)

## Consequences
이 결정으로 인한 영향은? (긍정/부정 모두)
```

---

## 작성 규칙

1. **번호**: 순차적 3자리 (001, 002, ...)
2. **파일명**: `NNN-간단한-영문-제목.md`
3. **언어**: 한국어 (코드/기술 용어는 영문 유지)
4. **분량**: 1페이지 이내 (간결하게)

---

## README.md 업데이트

ADR 생성 후 `docs/adr/README.md`에 추가:

```markdown
| # | 제목 | 날짜 | 상태 |
|---|------|------|------|
| 001 | [PostgreSQL 선택](001-postgresql.md) | 2024-06-15 | Accepted |
```

---

## 자동 생성 트리거

Claude가 다음을 감지하면 ADR 생성 제안 또는 자동 생성:

- "~로 바꾸자", "~를 도입하자" 등 기술 결정 대화
- 새 패키지 설치 (`uv add`, `pnpm add`)
- 디렉토리 구조 변경
- 기존 패턴과 다른 코드 작성 시

---

**Last Updated**: 2026-01-08
