---
description: 세션 시작 - 이전 세션 컨텍스트 로드 및 요약
---

[SESSION START]

$ARGUMENTS

## What is /session-start?

새 세션을 시작할 때 실행하여 이전 세션의 컨텍스트를 로드합니다.
최근 5개 세션을 AI가 요약하여 보여줍니다.

## Execution Protocol

### Step 1: Find Recent Sessions

최근 5개의 세션 파일을 찾습니다:

```
.claude/context/
├── YYYY-MM/
│   └── YYYY-MM-DD-*.md
```

**탐색 순서:**
1. 현재 달 폴더에서 최신 파일들
2. 부족하면 이전 달 폴더도 확인
3. 파일명 기준 역순 정렬 (최신 먼저)

### Step 2: Read Session Files

각 세션 파일을 읽습니다. 파일이 없으면 "이전 세션 없음" 메시지 출력.

### Step 3: Summarize and Output

## Output Format

### 세션 파일이 있을 때:

```markdown
## 📋 Session Context Loaded

### 최근 세션 요약

**2026-01-20 (abc123)** - /wrap 시스템 개선
- 작업: hooks.json 수정, TIL 제거
- 미완료: SessionStart 테스트

**2026-01-19 (xyz789)** - 초기 설정
- 작업: 플러그인 구조 생성
- 결정: 멀티세션 분석 도입

---

### 이어서 할 작업
- [ ] SessionStart 훅 테스트
- [ ] 실제 세션으로 검증

### 제안
가장 최근 세션에서 제안된 다음 단계를 시작하세요.
```

### 세션 파일이 없을 때:

```markdown
## 📋 Session Context

이전 세션 기록이 없습니다.

작업을 마치면 `/wrap`을 실행하여 세션을 기록하세요.
```

## Options

```
/session-start          # 기본: 최근 5개 요약
/session-start --all    # 이번 달 전체 표시
/session-start --last   # 마지막 세션만 상세 표시
```

### --all 옵션

이번 달의 모든 세션 파일 목록을 표시합니다.

### --last 옵션

가장 최근 세션 파일의 전체 내용을 표시합니다.

## Implementation Details

### Finding Session Files

```bash
# 최신 5개 파일 찾기
ls -t .claude/context/*/*.md 2>/dev/null | head -5
```

### Parsing Session Files

각 파일에서 추출:
- 제목에서 날짜/시간
- 맥락 섹션 첫 줄
- 작업 요약 전체
- 미완료/TODO 항목

### Summary Generation

최근 5개 세션을 읽고:
1. 각 세션의 핵심 내용 1-2줄로 요약
2. 미완료 작업들을 통합
3. 가장 최근 세션의 "다음 세션 제안"을 표시

## Integration

- **Before work**: `/session-start`로 컨텍스트 로드
- **After work**: `/wrap`으로 세션 저장

```
┌─────────────────────────────────────────┐
│  /session-start                         │
│     ↓                                   │
│  [작업 수행]                             │
│     ↓                                   │
│  /wrap                                  │
│     ↓                                   │
│  .claude/context/YYYY-MM/file.md 저장   │
└─────────────────────────────────────────┘
```
