---
name: planning
description: Brain 기반 구현 계획 수립. "planning", "계획", "어떻게 구현", "설계" 키워드로 자동 활성화
argument-hint: "[feature description]"
---

# /planning

> Brain의 패턴과 예시를 참고하여 구현 계획 수립

$ARGUMENTS

---

## 목적

**brainstorm vs planning 구분:**

| 단계 | 목적 | Brain 필요 |
|------|------|-----------|
| brainstorm | **뭘** 만들지 구체화 | ❌ |
| planning | **어떻게** 만들지 계획 | ✅ |

---

## 실행 프로토콜

### Phase 1: 코드베이스 탐색

무엇을 수정/생성할지 파악:

```
- 기존 관련 코드 위치 확인
- 의존성 파악
- 영향 범위 추정
```

### Phase 2: 구현 틀 식별

필요한 구현 유형 파악:

```
예시:
- "새 에이전트 필요" → agent-design 패턴
- "새 커맨드 필요" → command-structure 패턴
- "새 스킬 필요" → skill-structure 패턴
- "API 엔드포인트 필요" → api-design 패턴
```

### Phase 3: Brain 참조

1. `.claude/brain.md` 존재 여부 확인

2. **Brain이 있으면:**
   - 패턴 인덱스 읽기
   - 구현 틀에 맞는 패턴 링크 식별
   - 해당 상세 파일 읽기 (`.claude/brain/patterns/*.md`)
   - 예시 기반 설계

3. **Brain이 없으면:**
   - ⚠️ 경고 표시: "이 프로젝트에 brain.md가 없습니다. 코드베이스 탐색 결과만으로 계획을 수립합니다."
   - 코드베이스 탐색 결과만으로 계획 수립
   - 계획 출력에 "참고한 패턴: 없음 (brain 미설정)" 표시

```bash
# Brain 존재 확인
ls .claude/brain.md

# Brain이 있으면 인덱스 확인
cat .claude/brain.md

# 필요한 패턴 상세 읽기
cat .claude/brain/patterns/{relevant-pattern}.md
```

### Phase 4: Plan Mode 진입

패턴 예시를 참고하여 계획 수립:

```
EnterPlanMode 호출
```

### Phase 5: 계획 문서 작성

Plan Mode 내에서 작성:

```markdown
# 구현 계획: {Feature Name}

## 참고한 패턴
- {pattern 1}: {왜 필요한지}
- {pattern 2}: {왜 필요한지}

## 수정/생성할 파일
| 파일 | 변경 내용 | 참고 패턴 |
|------|----------|----------|
| {path} | {변경 내용} | {pattern} |

## 구현 순서
1. {step 1}
2. {step 2}
3. {step 3}

## 패턴 적용 예시
{brain에서 가져온 예시 기반 설계}

## 검증 방법
- [ ] {검증 항목 1}
- [ ] {검증 항목 2}
```

---

## 출력 형식

Plan Mode 진입 후, 위 형식의 계획 문서 작성.

---

## 주의사항

1. **Brain 먼저**: 패턴 확인 없이 바로 계획 X
2. **예시 기반**: 규칙이 아닌 예시 코드 참고
3. **Progressive Disclosure**: 필요한 패턴만 로드
4. **Plan Mode 필수**: EnterPlanMode로 사용자 승인

---

**Last Updated**: 2026-02-03
