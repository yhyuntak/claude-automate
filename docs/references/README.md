# AI-Native Development References

AI 기반 개발 워크플로우에 대한 참고 자료 모음.

## Articles

### 1. [Peter Steinberger - Moltbot Creator](./01-peter-steinberger-moltbot.md)
> "I ship code I don't read"

- 5-10개 에이전트 병렬 운영
- 코드 리뷰 대신 아키텍처 논의
- 계획에 시간 투자, 실행은 위임

### 2. [Kieran Klaassen - Code Review Revolution](./02-kieran-klaassen-code-review.md)
> "코드 읽기를 그만뒀더니, 코드 리뷰가 더 좋아졌다"

- 13개 전문 AI 리뷰어 병렬 실행
- 50/50 규칙: 리뷰 50%, 시스템 개선 50%
- Triage 기반 의사결정

### 3. [토스테크 - Software 3.0](./03-toss-software-3.0.md)
> "도구는 바뀌었지만, 좋은 설계의 원칙은 그대로"

- Claude Code ↔ 레이어드 아키텍처 매핑
- 안티패턴도 그대로 적용됨
- HITL: Exception이 Question으로

### 4. [oh-my-claudecode 플러그인 분석](./04-oh-my-claudecode-analysis.md)
> "Multi-agent orchestration for Claude Code"

- 32개 전문 에이전트 + 40+ 스킬
- 5가지 실행 모드 (Autopilot, Ultrapilot, Swarm, Pipeline, Ecomode)
- 3-tier 에이전트 시스템 (Haiku/Sonnet/Opus)

## Common Themes

```
┌─────────────────────────────────────────────────────────┐
│                    핵심 공통점                           │
├─────────────────────────────────────────────────────────┤
│ 1. 코드를 읽지 않는다 → 아키텍처/설계에 집중            │
│ 2. 병렬 에이전트 활용 → 전문화된 역할 분담              │
│ 3. 계획에 시간 투자 → 실행은 위임                       │
│ 4. 배운 것을 시스템에 축적 → 복리 효과                  │
│ 5. 전통적 설계 원칙은 여전히 유효                       │
└─────────────────────────────────────────────────────────┘
```

## Related Tools

- [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) - Multi-agent orchestration
- [claude-hud](https://github.com/anthropics/claude-code/tree/main/plugins/claude-hud) - Status line plugin
- [Moltbot](https://www.molt.bot) - AI agent by Peter Steinberger
