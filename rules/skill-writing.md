# Skill 작성 규칙

> SKILL.md 구조 + 5가지 핵심 규칙

---

## 파일 구조

```
.claude/skills/{skill-name}/
├── SKILL.md              # 본체 (Frontmatter + Body)
├── refs/                 # 참조 파일 (지연 로딩)
└── scripts/              # 실행 스크립트 (필요 시)
```

---

## Frontmatter 구조

```yaml
---
name: skill-name
description: |
  (3인칭) 언제 이 스킬이 발동하는지 설명.
  시작 시 name + description만 로드 (~100토큰).
context: fork          # fork = 메인 컨텍스트 보호 | 생략 = 메인에서 실행
agent: general-purpose
allowed-tools:
  - Read
  - Write
  - Bash
---
```

### context 선택 기준

| 값 | 용도 | 예시 |
|----|------|------|
| `fork` | 무거운 작업 (데이터 읽기, 분석, 리포트 작성) | 분석 스킬, 리포트 스킬 |
| 생략 | 오케스트레이터, 가벼운 조회 | Task() 위임, 상태 확인 |

---

## 5가지 핵심 규칙

### 1. Progressive Disclosure

로딩 순서를 지켜라:

```
시작 시:    name + description만 (~100토큰)
매칭 시:    body 전체 로드
실행 시:    refs/ + scripts/ 지연 로딩
```

body에서 refs/를 `MUST: refs/xxx.md를 읽어라` 형태로 명시 → 필요할 때만 로드.

---

### 2. Body에 "언제 쓸지" 쓰지 마라

description이 담당한다. body = **"무엇을 어떻게"만**.

```markdown
# 나쁜 예
이 스킬은 사용자가 리포트를 요청할 때 사용합니다.

# 좋은 예
## Step 1: 데이터 수집
MUST: refs/data-sources.md를 읽고 소스별 수집 방법을 확인하라.
```

---

### 3. Body 500줄 이내

SKILL.md = 목차. 상세 내용은 refs/로 분리.

| 내용 | 위치 |
|------|------|
| Step 개요 (1-2줄) | SKILL.md body |
| 판단 규칙, 복잡한 로직 | `refs/` |
| 예시, 스키마 | `refs/` |
| 단순 쿼리/커맨드 | body 인라인 가능 |

---

### 4. Claude가 아는 건 쓰지 마라

개념 설명 대신 코드 예시 + 기대 출력으로 대체.

```markdown
# 나쁜 예
SQLite는 경량 데이터베이스입니다. 쿼리를 실행하려면...

# 좋은 예
```bash
sqlite3 data/northstar.db "SELECT * FROM events LIMIT 5;"
```
기대 출력: id | date | type | summary
```

---

### 5. 검증 루프 내장

MUST 키워드 + 체크리스트 + 실패 처리.

```markdown
## 검증

MUST: 아래 체크리스트를 모두 확인하라.

- [ ] 출력 파일이 존재하는가?
- [ ] 필수 섹션이 모두 있는가?
- [ ] 데이터가 최신인가?

실패 시: 해당 Step으로 돌아가 수정 → 재검증.
```

---

## Body 작성 패턴

### 복잡한 Step (refs/ 분리)

```markdown
## Step 2: 분석

섹터별 데이터를 수집하고 이상치를 감지한다.

MUST: refs/analysis-rules.md를 읽고 감지 기준을 확인하라.
```

### 단순 Step (인라인)

```markdown
## Step 1: DB 확인

```bash
sqlite3 data/northstar.db ".tables"
```
```

---

## 전체 예시 구조

```markdown
---
name: my-skill
description: |
  사용자가 X를 요청하면 발동. Y와 Z를 처리한다.
context: fork
agent: general-purpose
allowed-tools:
  - Read
  - Bash
---

## Step 1: ...
(1-2줄 요약)
MUST: refs/step1-detail.md를 읽어라.

## Step 2: ...
(단순한 경우 인라인)

## 검증
- [ ] 조건 A
- [ ] 조건 B

실패 시: Step X로 돌아가 재처리.
```

---

**Last Updated**: 2026-02-22
