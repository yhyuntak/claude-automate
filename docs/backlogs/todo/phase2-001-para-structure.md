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

### 기술 결정

(작업 시 기록)

### 이슈/해결

(작업 시 기록)

---

**Last Updated**: 2026-01-30
