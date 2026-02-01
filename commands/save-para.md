# /save-para

> 대화 중 인사이트를 PARA Resources에 저장

$ARGUMENTS

---

## 실행

이 커맨드는 `skills/save-para/SKILL.md`를 로드하여 실행합니다.

1. Read `skills/save-para/SKILL.md`
2. Progressive Disclosure 워크플로우에 따라 진행

---

## 빠른 사용법

```
/save-para              # 대화형으로 진행
/save-para Race Condition  # 제목 힌트 제공
```

---

## Progressive Disclosure 워크플로우

```
1. Read ~/workspace/mynotes/README.md
   → PARA 구조 이해

2. Read ~/workspace/mynotes/Resources/README.md
   → 카테고리 목록 동적 추출

3. 사용자 질문 (내용, 카테고리, 제목)

4. Read ~/workspace/mynotes/Resources/{category}/README.md
   → 해당 카테고리 규칙 확인

5. 파일 저장 + 인덱스 업데이트
```

**하드코딩 없음** - README.md를 읽어서 동적으로 작동

---

## 관련

- Skill: `skills/save-para/SKILL.md`
