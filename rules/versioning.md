# Versioning Rule

이 프로젝트의 버전 관리 규칙입니다.

## Semantic Versioning

```
v{MAJOR}.{MINOR}.{PATCH}
```

| 변경 유형 | 버전 증가 | 예시 |
|----------|----------|------|
| 버그 수정, 문서, 기존 개선 | **PATCH** | 0.1.8 → 0.1.9 |
| 새 command/skill/agent 추가 | **MINOR** | 0.1.9 → 0.2.0 |
| 구조 변경, 삭제, breaking change | **MAJOR** | 0.9.0 → 1.0.0 |

## 버전 파일 위치 (2곳!)

```
.claude-plugin/plugin.json      → "version" 필드
.claude-plugin/marketplace.json → plugins[0].version 필드
```

**둘 다 동일하게 업데이트해야 함!**

## 버전업 체크리스트

커밋 전 확인:
1. [ ] 변경 유형 파악 (patch/minor/major)
2. [ ] `.claude-plugin/plugin.json` 버전 업데이트
3. [ ] `.claude-plugin/marketplace.json` 버전 업데이트
4. [ ] 커밋 메시지에 버전 포함: `feat: xxx (v0.2.0)`

## 현재 버전

- **0.1.8** (2026-01-23)
- 다음 기능 추가 시: **0.2.0**

## 히스토리 참고

```
0.1.5: Skills 시스템 초기
0.1.6: Skills 시스템 도입, 피드백 기능 개선
0.1.7: backlog skill 추가
0.1.8: /start-work 통합 워크플로우 추가
```
