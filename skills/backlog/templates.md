# Backlog Templates

## 스토리 템플릿

새 백로그 추가 시 사용:

```markdown
# [제목]

> [한 줄 요약 - 테이블 설명 컬럼에 표시됨]

## User Story

[역할]로서 [기능]을 원한다. [이유] 때문에.

## Acceptance Criteria

- [ ] 조건 1
- [ ] 조건 2
- [ ] 조건 3

## Why

[왜 이 기능이 필요한가? 어떤 문제를 해결하는가?]

## Dependencies

- [선행 작업이 있다면 기재]
- 없으면 "없음"

## Notes

[추가 참고 사항]

---
Created: {DATE}
```

---

## 아이디어 템플릿

스코프 밖 아이디어 기록 시 사용:

```markdown
# [제목]

> [한 줄 요약]

## Description

[아이디어 상세 설명]

## Motivation

[왜 이 아이디어가 떠올랐는가? 어떤 상황에서?]

## Related

- [관련 기능/이슈]

## Priority Estimate

- Impact: [High/Medium/Low]
- Effort: [High/Medium/Low]

---
Created: {DATE}
```

---

## 파일명 생성 규칙

### 스토리

```
phase{N}-{ID}-{slug}.md
```

1. **Phase 결정**: 의존성 기반
   - 다른 것에 의존 없음 → Phase 1 또는 Phase 4
   - Phase 1에 의존 → Phase 2
   - Phase 2에 의존 → Phase 3

2. **ID 부여**: 해당 Phase 내 다음 번호
   ```bash
   ls docs/backlog/todo/phase1-* | wc -l  # 기존 개수 확인
   # 다음 번호 = 기존 개수 + 1 (3자리 패딩)
   ```

3. **Slug 생성**: 제목을 케밥케이스로
   - "User Authentication" → `user-authentication`
   - "몰입 모드" → `immersion-mode`

### 아이디어

```
idea-{ID}-{slug}.md
```

또는 날짜 기반:

```
idea-{YYYYMMDD}-{slug}.md
```

---

## 사용 예시

### 새 스토리 추가

```
사용자: "로그인 기능 백로그 추가해줘"

Claude:
1. Phase 결정 → Phase 1 (기반 기능)
2. ID 확인 → phase1에 3개 있음 → 004
3. 파일 생성 → phase1-004-login.md
4. 템플릿으로 내용 작성
5. docs/backlog/todo/에 저장
```

### 아이디어 추가

```
사용자: "다크모드 나중에 하면 좋겠다"

Claude:
1. 아이디어 템플릿 사용
2. 파일 생성 → idea-001-dark-mode.md
3. docs/backlog/ideas/에 저장
```
