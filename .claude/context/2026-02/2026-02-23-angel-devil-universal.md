# Session: Angel/Devil 범용 사고 도구 전환 (2026-02-23)

## 상태: 완료
## Plan: .claude/plans/2026-02-23-angel-devil-universal.md
## 다음 행동: /start-work로 새 태스크 선택

## 완료 내용
- agents/devil.md: 역할·입력·핵심질문·질문스타일·사용예시를 범용 표현으로 교체
- agents/angel.md: 질문 옵션(10배 스케일, 즉시), 출력 형식(영감 소스), 사용 조건 범용화
- commands/devil.md: description + 키워드("비판적 사고") 업데이트
- skills/brainstorm/refs/angel-devil.md: "기술적" 제거
- skills/planning/refs/devil-usage.md: "구현" 제거
- v0.25.0 릴리즈 (커밋 + 태그 + 푸시 완료)

## 주요 결정
- Option A 선택: 범용 버전 별도 생성이 아닌, 기존 angel/devil을 범용으로 교체
- 최소 변경 원칙: 이미 범용적인 부분은 건드리지 않고, 개발 예시는 삭제하지 않되 비개발 예시 추가
- 출력 형식(🟢🟡🔴 판정)과 AskUserQuestion 기반 질문 구조는 유지

## 남은 작업
- 새 세션에서 비개발 주제로 devil/angel 실제 테스트 (이번 세션에서는 플러그인 캐시 때문에 불가)
