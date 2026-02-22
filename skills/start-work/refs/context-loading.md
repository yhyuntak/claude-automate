# Context Loading Rules

세션 컨텍스트를 로드하는 규칙.

## 경로

```
.claude/context/{YYYY-MM}/{YYYY-MM-DD}-{slug}.md
```

예시: `.claude/context/2026-02/2026-02-22-harness-poc.md`

## 로드 규칙

최근 파일 1개만 로드한다. 여러 개를 읽지 않는다.

```bash
ls -t .claude/context/*/*.md 2>/dev/null | head -1
```

파일이 없으면 `.claude/context/` 폴더 자체가 없는 경우도 포함한다.

## 표시 형식

파일이 있을 때:

```markdown
## 이전 세션 요약

**날짜**: 2026-02-22
**파일**: harness-poc

{파일 내용 요약 - 주요 작업, 미완료 항목, 결정사항}
```

파일이 없을 때:

```markdown
## 이전 세션

이전 세션 기록이 없습니다.
```

## 읽기 방법

파일을 직접 Read로 읽은 후 요약한다.
내용이 길면 상위 항목만 요약한다. 전체를 그대로 출력하지 않는다.
