# 백로그 관리 규칙

> Task 기반 백로그 시스템

---

## 폴더 구조

```
docs/backlogs/
├── README.md           # 전체 현황 대시보드
├── todo/               # 대기 중인 작업
├── doing/              # 진행 중인 작업 (1개만!)
└── done/               # 완료된 작업
```

---

## 파일명 규칙

```
phase{N}-{ID}-{slug}.md

예: phase1-001-user-auth.md
    phase1-002-api-setup.md
    phase2-001-dashboard.md
```

- **phase{N}**: 단계 번호 (phase1, phase2, ...)
- **{ID}**: 3자리 숫자 (001, 002, ...)
- **{slug}**: 영문 소문자, 하이픈으로 연결

---

## 상태 관리

### 상태 종류

| 상태 | 폴더 | 설명 |
|------|------|------|
| Todo | `todo/` | 대기 중, 아직 시작 안 함 |
| Doing | `doing/` | **현재 작업 중 (1개만!)** |
| Done | `done/` | 완료됨 |

### 상태 변경 방법

```bash
# 작업 시작: todo → doing
mv docs/backlogs/todo/phase1-001-user-auth.md \
   docs/backlogs/doing/

# 작업 완료: doing → done
mv docs/backlogs/doing/phase1-001-user-auth.md \
   docs/backlogs/done/
```

### Claude 자동 처리

**작업 시작 트리거**:
- "진행한다", "시작하자", "할게", "해보자"
- → Task 파일을 `doing/`으로 이동

**작업 완료 트리거**:
- Task의 모든 Acceptance Criteria 충족 시
- → Task 파일을 `done/`으로 이동

---

## README.md 업데이트

상태 변경 시 README.md도 함께 업데이트:

1. **현황 개수**: Todo/Doing/Done 개수 갱신
2. **Task 링크**: 새 경로로 업데이트
3. **상태 표시**: 이모지 변경

### 예시

```markdown
# 변경 전
| 1 | 001 | [사용자 인증](todo/phase1-001-user-auth.md) | Todo |

# 변경 후 (작업 시작)
| 1 | 001 | [사용자 인증](doing/phase1-001-user-auth.md) | 🔄 Doing |

# 변경 후 (작업 완료)
| 1 | 001 | [사용자 인증](done/phase1-001-user-auth.md) | ✅ Done |
```

---

## Task 템플릿

```markdown
# {제목}

> {한 줄 설명}

---

## User Story

사용자가 [행동]하면, [결과]를 얻는다.

## Acceptance Criteria

- [ ] 기준 1
- [ ] 기준 2
- [ ] 기준 3

## 비기능 요구사항

- 성능: ...
- 보안: ...

## Dependencies

- phase1-xxx 완료 후 시작 가능

---

## 구현 노트 (작업 중 추가)

### 기술 결정
- ...

### 이슈/해결
- ...

---

**Last Updated**: YYYY-MM-DD
```

---

## 백로그 작성 원칙

> CLAUDE.md의 "백로그/스토리 작성 원칙" 참조

### 포함할 것
- User Story (As a user, I want to...)
- Acceptance Criteria
- 비기능 요구사항
- 우선순위
- 의존성

### 포함하지 말 것
- 구체적인 코드 예시
- 세부 아키텍처
- 기술 스택 선택
- 구현 방법
- 파일/폴더 구조

### 이유
```
"설계와 구현은 함께 고민하면서 성장하는 과정"

미리 다 정해놓으면:
- 고민할 기회가 없어짐
- 상황에 맞지 않는 결정이 될 수 있음
- 유연성이 떨어짐

구현 시점에 결정하면:
- 최선의 선택 가능
- 현재 상황에 맞는 결정
- 학습과 성장 기회
```

---

**Last Updated**: {LAST_UPDATE_DATE}
