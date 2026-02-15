# 플러그인 리뷰 및 설치

> Ralph Wiggum, Context7, Code Review, Security Guidance 조사/테스트

---

## User Story

인기 Claude Code 플러그인들을 조사하고 테스트하여, 설치 여부를 결정한다.

## Acceptance Criteria

- [x] P1 (Ralph Wiggum) - 자율 코딩 루프 조사 및 테스트
- [x] P2 (Context7) - 실시간 문서 주입 조사 및 테스트 (스킵 - 이미 알고 있음)
- [x] P3 (Code Review) - 병렬 AI 코드 리뷰 조사 및 테스트
- [x] P4 (Security Guidance) - 보안 스캔 조사 및 테스트
- [x] 각 플러그인 설치/미설치 결정 및 근거

## Dependencies

- phase4-001 완료 후 시작 가능

---

## 구현 노트

### 결정 사항

| Plugin | 결정 | 이유 |
|--------|:----:|------|
| Ralph Wiggum | 원리만 차용 | Stop Hook 패턴만 알면 됨. 루프 자체는 단순한 while loop |
| Context7 | 스킵 | 이미 알고 있는 MCP 서버 |
| Code Review | 원리만 차용 | 교차 검증 패턴 + Confidence Scoring 참고 |
| Security Guidance | 원리만 차용 | 선언적 룰 배열 + PreToolUse Hook + Session State 패턴 |

### 기억할 패턴

1. **교차 검증** - 같은 역할 에이전트 2개로 신뢰도 확보 (Code Review)
2. **Stop Hook** - exit 2로 세션/툴 차단 (Ralph, Security)
3. **선언적 룰 설정** - 데이터 배열로 룰 관리 (Security)
4. **Confidence Filtering** - 80+ threshold로 노이즈 제거 (Code Review)
5. **Session-Scoped State** - 중복 경고 방지 (Security)

### 참조 문서

- docs/references/claude-code-insights/p1-ralph-wiggum.md (메커니즘 분석 추가됨)
- docs/references/claude-code-insights/p3-code-review.md (메커니즘 분석 추가됨)
- docs/references/claude-code-insights/p4-security-guidance.md (메커니즘 분석 추가됨)

---

**Last Updated**: 2026-02-16
