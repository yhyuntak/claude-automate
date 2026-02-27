# 스킬 정리 + 문서 시스템 구축

> save-context/start-work 삭제, wrap 재설계, 문서 스킬 신규, docs 인덱스 표준화

---

## User Story

개발자가 작업 마무리(wrap) 시 관련 문서가 자동으로 싱크 체크되고,
문서 작업 시 체계적으로 관리되어 중구난방 문서 생성을 방지한다.

## Acceptance Criteria

### Part 1: 스킬 삭제

- [x] save-context 스킬 삭제
  - PreCompact hook이 대체 (v0.30.0)
  - 트리거 없음 (Stop Hook 컨텍스트 감시 v0.26.1에서 제거)
  - refs/ 폴더 포함 전체 삭제

- [x] start-work 스킬 삭제
  - Plan 스캔 → implement가 이미 함
  - 컨텍스트 로드 → PreCompact가 대체
  - 백로그 선택 → /backlog 스킬로 충분
  - 워크트리 → 사용자가 직접 판단
  - 다음 액션 안내 → 사용자가 직접 /planning, /implement, /backlog 호출
  - refs/ 폴더 포함 전체 삭제

### Part 2: wrap 재설계

- [x] wrap SKILL.md 재작성
  - Step 1: Plan 확인 + mode → idle (유지)
  - Step 2: Backlog doing → done (유지, 있을 때만)
  - Step 3: 문서 싱크 체크 (신규)
    - git diff로 변경된 파일 목록 확인
    - docs/README.md 인덱스 읽기
    - 변경 트리거 매칭 → 영향 문서 식별
    - doc-sync-checker 에이전트로 확인
    - 인덱스 없으면 스킵
  - Step 4: 커밋 (유지, AskUserQuestion 확인)
  - 컨텍스트 저장 Step 제거
  - allowed-tools에서 Write/Edit 제거 (writer 위임)
  - refs/completion-context.md 삭제

### Part 3: 문서 스킬 신규 생성

- [x] skills/docs/SKILL.md 생성
  - 문서 생성: 템플릿 기반 (POC, 아키텍처 결정, 프로젝트 목표 등)
  - 위치 추천: docs/ 인덱스 읽고 기존 구조 파악 → AskUserQuestion으로 추천
  - 인덱스 자동 등록: docs/README.md에 새 문서 + 변경 트리거 추가
  - 기존 문서 업데이트: 인덱스에서 찾아서 수정

### Part 4: docs/ 인덱스 표준화

- [x] 인덱스 포맷 정의
  - docs/README.md에 테이블 형태
  - 컬럼: 문서명 | 경로 | 변경 트리거 (glob 패턴)
  - CLAUDE.md, README.md도 인덱스에 포함 (docs/ 하위가 아니더라도 프로젝트 루트 문서도 대상)
  - 예시:
    ```
    | API 가이드 | api/guide.md | src/api/** |
    | DB 스키마 | db/schema.md | migrations/** |
    | CLAUDE.md | CLAUDE.md | 원칙/아키텍처 변경 시 |
    | README.md | README.md | 새 기능 추가/삭제 시 |
    ```
  - wrap이 git diff + 트리거 패턴 매칭
  - 인덱스 없는 프로젝트 → 문서 싱크 스킵

- [x] claude-automate 프로젝트에 인덱스 적용
  - 현재 docs/ 구조 기반으로 인덱스 작성

## 비기능 요구사항

- wrap의 문서 싱크는 인덱스 없으면 에러 없이 스킵
- 문서 스킬은 범용 (프로젝트 무관하게 동작)
- 인덱스 포맷은 단순하게 (markdown 테이블)

## Dependencies

- v0.30.0 완료 (SessionStart + PreCompact hook) ✅

---

## 구현 노트 (작업 중 추가)

### 배경 결정
- save-context 삭제 이유: PreCompact hook 도입 + 연속 대화 워크플로우로 세션 컨텍스트 저장 의미 퇴색
- start-work 삭제 이유: 각 스킬 직접 호출이 더 자연스러움 (planning/implement/backlog)
- start-work 삭제: 다음 액션 안내도 불필요 (사용자가 직접 스킬 호출하는 게 더 자연스러움)
- wrap 문서 싱크: 코드 변경 후 문서 업데이트 누락 방지
- wrap 문서 싱크 범위: docs/ 하위뿐 아니라 CLAUDE.md, README.md도 인덱스에 포함하여 체크
- 문서 스킬: 중구난방 문서 생성 방지, 체계적 관리

### 구현 순서 제안
1. Part 1 (삭제) → 가장 단순, 먼저 처리
2. Part 4 (인덱스 정의) → Part 2, 3의 기반
3. Part 3 (문서 스킬) → 인덱스 포맷 활용
4. Part 2 (wrap 재설계) → 문서 싱크 = 인덱스 + doc-sync-checker

---

**Last Updated**: 2026-02-27
