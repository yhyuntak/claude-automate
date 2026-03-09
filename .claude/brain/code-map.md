# Code Map

## 프로젝트 구조

```
claude-automate/
├── agents/                    # 서비스 레이어 (에이전트 정의)
│   ├── angel.md               # 아이디어 확장 (Sonnet)
│   ├── devil.md               # 비판적 검토 (Sonnet)
│   ├── explore.md             # 코드베이스 탐색 (Sonnet)
│   ├── explore-low.md         # 단순 탐색 (Haiku)
│   ├── explore-high.md        # 아키텍처 분석 (Opus)
│   ├── writer.md              # 코드 작성 (Sonnet)
│   ├── writer-high.md         # 복잡한 구현 (Opus)
│   ├── gemini-advisor.md      # [NEW] UI/디자인 어드바이저 (Gemini CLI)
│   ├── codex-advisor.md       # [NEW] 코드/버그 어드바이저 (Codex CLI)
│   ├── scripts/               # [NEW] 외부 CLI 호출 스크립트
│   │   ├── gemini-advisor.sh  # Gemini headless 호출 + 시스템 프롬프트
│   │   └── codex-advisor.sh   # Codex headless 호출 + 시스템 프롬프트
│   └── ...                    # 기타 에이전트
├── skills/                    # 도메인 컴포넌트 (스킬 정의)
│   ├── multi-review/          # [NEW] 3모델 동시 리뷰 스킬
│   │   └── SKILL.md
│   ├── planning/
│   ├── implement/
│   └── ...
├── hooks/                     # 미들웨어
└── .claude-plugin/plugin.json # 플러그인 메타데이터
```

## 패턴

### 외부 CLI 호출 에이전트 패턴
- 에이전트 .md에서 allowed-tools에 Bash 명시
- 에이전트가 agents/scripts/*.sh를 Bash로 실행
- 시스템 프롬프트는 셸 스크립트에 하드코딩 (Claude 토큰 절약)
- 사용자 프롬프트만 $1로 전달

### 설계 결정
- 역할 고정: Gemini = UI/디자인, Codex = 코드/버그
- CLI 구독 활용: Gemini Pro 플랜 + Codex API/Plus
- 프로젝트 경로: cd 후 CLI 호출 (코드베이스 자동 인식)

---

**Last Updated**: 2026-03-08
