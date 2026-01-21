---
description: 피드백 목록 빠르게 확인
---

## Mission

`~/.claude/feedback/` 폴더의 피드백을 빠르게 확인합니다.

## Step 1: 피드백 파일 확인

```bash
ls -la ~/.claude/feedback/
```

## Step 2: 피드백 읽기 및 테이블 출력

최근 피드백 파일들을 읽고 테이블로 표시:

| # | 날짜 | 프로젝트 | 타입 | 내용 (요약) | 태그 |
|---|------|----------|------|-------------|------|

- 각 피드백의 `user_feedback` 필드를 30자 내로 요약
- 최신 순으로 정렬 (최근 10개)
- 타입별 이모지: bug=🐛, idea=💡, improvement=✨, wrap=📝, general=📌

## Step 3: 요약 통계

```
총 N개 피드백 (bug: X, idea: Y, improvement: Z, ...)
```

## 옵션

`$ARGUMENTS`가 있으면:
- `today` - 오늘 피드백만
- `bug` / `idea` / `improvement` - 특정 타입만
- `{project-name}` - 특정 프로젝트만
