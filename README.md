# claude-automate

> Self-Evolving Development System - Claude Code 메타 레이어 자동화 플러그인

## 설치

```bash
/plugin marketplace add yhyuntak/claude-automate
/plugin install claude-automate@claude-automate
```

## 기능

### 1. 프로젝트 패턴 체커
코드가 프로젝트 규칙을 따르는지 자동 검사

### 2. 사용 패턴 분석
반복되는 프롬프트 패턴 감지 → 스킬 자동 생성 제안

### 3. 세션 연속성
`context.md` 자동 관리로 세션 간 컨텍스트 유지

### 4. 문서 자동 동기화
코드 변경 시 관련 문서 자동 업데이트 제안

### 5. TIL 추출
세션에서 학습한 내용을 자동 추출하여 기록

## 사용법

```bash
/claude-automate:wrap
```

## 구조

```
claude-automate/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── wrap.md           # /wrap 커맨드 (기존)
│   ├── wrap-v2.md        # /wrap-v2 커맨드 (3-에이전트 구조)
│   ├── session-start.md  # 세션 시작 시 컨텍스트 로드
│   └── feedback.md       # /feedback 피드백 저장
├── agents/
│   ├── wrap-reader.md    # Phase 1: 데이터 수집 (haiku)
│   ├── wrap-analyzer.md  # Phase 2: 분석 (sonnet)
│   ├── wrap-reporter.md  # Phase 3: 리포팅 (opus)
│   └── ...               # 기타 에이전트
├── hooks/
│   ├── hooks.json        # 훅 설정
│   ├── session-stop.sh   # 세션 종료 리마인더
│   └── feedback-hint.sh  # 피드백 키워드 감지
└── .gitignore
```

## 모델 티어링

| 모델 | 용도 |
|------|------|
| Haiku | 데이터 수집, 단순 작업 |
| Sonnet | 분석, 판단 |
| Opus | 복잡한 충돌/전략 |

## 라이선스

MIT
