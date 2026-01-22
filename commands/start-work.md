---
description: 작업 시작 - 세션 컨텍스트 로드, 백로그 확인, worktree 생성까지 통합 워크플로우
---

[START WORK MODE ACTIVATED]

$ARGUMENTS

---

## /start-work: 통합 작업 시작 워크플로우

세션 시작부터 작업 환경 설정까지 하나의 플로우로 처리합니다.

**플로우:**
1. 이전 세션 요약 표시
2. 백로그 목록 표시
3. worktree 사용 여부 확인
4. 백로그 선택
5. (worktree 시) 환경 생성 및 이동

---

## STEP 1: 세션 컨텍스트 로드

### 최근 세션 찾기

```bash
ls -t .claude/context/*/*.md 2>/dev/null | head -5
```

### 세션 요약 출력

세션 파일이 있으면:
```markdown
## 📋 이전 세션 요약

**2026-01-22 (abc123)** - 피드백 시스템 개선
- 작업: /write-feedback, /check-feedback 추가
- 미완료: 통합 테스트

---
```

세션 파일이 없으면:
```markdown
## 📋 이전 세션

이전 세션 기록이 없습니다.

---
```

---

## STEP 2: 백로그 확인

### 백로그 폴더 확인

```bash
ls docs/backlog/todo/ 2>/dev/null
ls docs/backlog/doing/ 2>/dev/null
```

### 백로그 테이블 출력

백로그가 있으면:
```markdown
## 📝 백로그

| # | Phase | ID | 제목 | 설명 |
|---|-------|-----|------|------|
| 1 | 1 | 001 | feature-x | 기능 X 구현 |
| 2 | 1 | 002 | feature-y | 기능 Y 구현 |

**진행 중:** phase1-003-feature-z (doing 폴더에 있으면)

---
```

백로그가 없으면:
```markdown
## 📝 백로그

이 프로젝트에 백로그가 없습니다.
(`docs/backlog/` 폴더가 없거나 비어있음)

---
```

### 백로그 파싱 규칙

- 파일명: `phase{N}-{ID}-{slug}.md`
- 설명: 파일 내 첫 번째 `> ` 인용문

```bash
# 설명 추출
head -5 docs/backlog/todo/phase1-001-xxx.md | grep "^>" | head -1 | sed 's/^> //'
```

---

## STEP 3: Worktree 사용 여부 확인

**AskUserQuestion 사용:**

```
질문: "이 프로젝트에서 worktree를 사용할까요?"
헤더: "Worktree"
옵션:
  - "Yes": worktree로 브랜치 분리
  - "No": 현재 폴더에서 작업
```

---

## STEP 4: 백로그 선택

**AskUserQuestion 사용:**

```
질문: "어떤 작업을 시작할까요?"
헤더: "작업 선택"
옵션:
  - [백로그 목록 - 번호와 제목]
  - "새 작업 (백로그 없이)": 자유 작업
```

백로그가 없으면 이 단계 스킵.

---

## STEP 5: Worktree 생성 (Yes 선택 시)

### 브랜치명 규칙
- 파일명에서 slug 추출: `phase1-001-feature-x` → `feature-x`

### 경로 규칙
- `../{project-name}-{branch}`
- 예: `../claude-automate-feature-x`

### 프로젝트명 확인
```bash
basename $(pwd)
```

### 기존 worktree 확인
```bash
git worktree list | grep {branch}
```

- 이미 있으면: "⚠️ worktree가 이미 존재합니다: {경로}" 경고 출력
- 없으면: 생성 진행

### Worktree 생성
```bash
git worktree add ../{project}-{branch} -b {branch}
```

### 이동
```bash
cd ../{project}-{branch}
```

---

## STEP 6: 완료 메시지

### Worktree 모드
```markdown
## ✅ 작업 환경 준비 완료

**작업:** phase1-001-feature-x (기능 X 구현)
**경로:** ../claude-automate-feature-x
**브랜치:** feature-x

현재 이 폴더에서 작업합니다.
완료 후 `/wrap`으로 세션을 마무리하세요.

💡 원래 프로젝트로 돌아가기: `cd ../claude-automate`
```

### 일반 모드
```markdown
## ✅ 작업 시작

**작업:** phase1-001-feature-x (기능 X 구현)

완료 후 `/wrap`으로 세션을 마무리하세요.
```

### 새 작업 (백로그 없이)
```markdown
## ✅ 작업 시작

백로그 없이 자유 작업을 시작합니다.

완료 후 `/wrap`으로 세션을 마무리하세요.
```

---

## 옵션

```
/start-work              # 기본: 전체 플로우
/start-work --skip-session   # 세션 요약 스킵
/start-work --no-worktree    # worktree 질문 스킵 (일반 모드)
```

---

## 전체 플로우 다이어그램

```
┌─────────────────────────────────────────────────────┐
│  /start-work                                         │
│     │                                               │
│     ├─ 1. 세션 요약 표시                              │
│     │      └─ .claude/context/ 확인                  │
│     │                                               │
│     ├─ 2. 백로그 테이블 표시                          │
│     │      └─ docs/backlog/todo/ 확인               │
│     │                                               │
│     ├─ 3. [Ask] "worktree 사용?"                     │
│     │      ├─ Yes → worktree 모드                   │
│     │      └─ No → 일반 모드                        │
│     │                                               │
│     ├─ 4. [Ask] "어떤 작업?"                         │
│     │      ├─ 백로그 선택                            │
│     │      └─ 새 작업 (백로그 없이)                   │
│     │                                               │
│     ├─ 5. (worktree 시)                             │
│     │      ├─ git worktree add                      │
│     │      ├─ cd 이동                               │
│     │      └─ 경고 (이미 존재 시)                     │
│     │                                               │
│     └─ 6. 완료 메시지                                │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## 연관 커맨드

- `/session-start`: 세션 요약만 (Step 1)
- `/backlog`: 백로그만 (Step 2)
- `/wrap`: 작업 종료 시 세션 저장

---

## THE START-WORK PROMISE

완료 전 확인:
- [ ] 세션 컨텍스트 표시함
- [ ] 백로그 상태 표시함 (없으면 "없음" 명시)
- [ ] 사용자 선택 받음 (worktree, 작업)
- [ ] 선택에 따라 환경 설정함
- [ ] 완료 메시지 출력함
