# /save-para

> 대화 중 인사이트를 PARA Resources에 저장

$ARGUMENTS

---

## 실행

이 커맨드는 `skills/save-para/SKILL.md`를 로드하여 실행합니다.

1. Read `skills/save-para/SKILL.md`
2. 워크플로우에 따라 진행

---

## 빠른 사용법

```
/save-para              # 대화형으로 진행
/save-para Race Condition  # 제목 힌트 제공
```

---

## 워크플로우 요약

1. **내용 확인** - 사용자에게 저장할 내용 물어보기
2. **카테고리 선택** - concepts, python, architecture 등
3. **제목 확인** - 파일명 결정
4. **저장** - 파일 생성 + README 업데이트

---

## 저장 위치

```
~/workspace/mynotes/Resources/{category}/{slug}.md
```

---

## 관련

- Skill: `skills/save-para/SKILL.md`
- Schema: `skills/save-para/schema.md`
