# PARA 지식 구조 설계

> Projects, Areas, Resources, Archive 기반 지식 관리 시스템

---

## User Story

개발자가 세션에서 배운 것들이 체계적으로 분류되어, 나중에 비슷한 문제를 만났을 때 쉽게 찾아 활용할 수 있다.

## Acceptance Criteria

- [ ] PARA 폴더 구조 정의 (docs/knowledge/)
- [ ] 각 카테고리별 저장 규칙 명확화
- [ ] 지식 분류 기준 문서화
- [ ] 마이그레이션 경로 (기존 docs/ → PARA)

## 비기능 요구사항

- 검색 가능: 키워드로 빠르게 찾기
- 발견 가능: 브라우징으로도 탐색 가능
- 최소 마찰: 저장할 때 고민 최소화

## Dependencies

- 없음 (독립적으로 시작 가능)
- Phase 1 기초 태스크 - 다른 트랙과 병렬 진행 가능

---

## 구현 노트 (작업 중 추가)

### PARA 개요

```
Projects    = 현재 진행 중인 프로젝트 (기한 있음)
Areas       = 지속적으로 관리하는 영역 (기한 없음)
Resources   = 관심 주제 참고 자료 (언젠가 유용)
Archive     = 완료/비활성화된 것들
```

### claude-automate에 적용

```
docs/knowledge/
├── projects/       # 현재 Phase 작업들
├── areas/          # 패턴, 컨벤션, 베스트 프랙티스
├── resources/      # 외부 참고 자료, 아티클
└── archive/        # 완료된 Phase, 더 이상 유효하지 않은 것
```

### 2026-01-31 논의 내용

**핵심 방향: 옵시디언 vault로 통합**

```
위치: ~/workspace/mynotes
현재 상태: 구조 없이 사용 중
목표: PARA 구조로 재편
```

**Resources = 지식 축적소**

```
Resources/
├── architecture/     # 아키텍처 패턴
├── patterns/         # 디자인 패턴, 코딩 패턴
├── learnings/        # 세션에서 배운 것들
└── tech-references/  # 기술 레퍼런스
```

**목적: 초보 개발자 성장**

> AI 시대에 코드 작성 능력보다 "무엇을, 왜, 어떻게" 결정하는 능력이 중요.
> 아키텍처, 패턴, 트레이드오프에 대한 이해가 핵심.
> PARA의 Resource가 이런 지식 축적에 적합.

**Claude Code 연동 비전**

```
작업하면서 배움 → 자동 추출 → Resource에 저장
새 작업 시 → 지식 참조 → 더 나은 결정
```

**통합 계획**

- 프로젝트별 docs/ → 옵시디언 Projects/로 통합
- 범용 지식 → Resources/로 분류
- 완료된 프로젝트 → Archive/로 이동

### 기술 결정

(작업 시 기록)

### 이슈/해결

(작업 시 기록)

---

**Last Updated**: 2026-01-31
