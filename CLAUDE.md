# CLAUDE.md

> claude-automate 프로젝트의 핵심 원칙과 작업 지침

---

## 1. 프로젝트 정체성

### 핵심 목표

1. **코드를 보지 않고 개발** - 아키텍처/패턴/아이디어 레벨에 집중
2. **성장하는 시스템** - 만들면서 배우고, 배운 것을 축적
3. **나만의 Harness** - 직접 수정 가능한 확장 시스템
4. **단순함 유지** - 필요한 것부터 하나씩

### 하지 않는 것 (Anti-Goals)

- 복잡한 설정 없이는 사용 불가능한 시스템
- 모든 기능을 미리 구현하려는 시도
- 이해하지 못한 채 복사하는 것
- 코드 레벨에서 모든 것을 통제하려는 것

### Harness란?

개발자(Driver)가 AI(Engine)를 제어하는 **연결 장치**입니다.

```
Driver (당신)    →    Harness (claude-automate)    →    Engine (Claude)
아키텍처/의사결정       명령/에이전트/스킬               코드 실행
```

### 진화 원칙

이 문서 자체도 더 나은 아이디어가 생기면 **재정의 가능**합니다.
경험을 통해 발전하는 살아있는 문서입니다.

---

## 2. 아키텍처 원칙

### 레이어 매핑 (시작점)

토스테크 Software 3.0 모델을 기반으로 합니다:

```
Commands    =  Controller       (진입점, 사용자 인터페이스)
Agents      =  Service Layer    (비즈니스 로직, 분석/검증)
Skills      =  Domain Component (단일 책임, 재사용 가능)
MCP         =  Infrastructure   (외부 연동, 어댑터)
CLAUDE.md   =  package.json     (프로젝트 정체성)
rules/*.md  =  eslint.config    (세부 규칙)
```

**중요**: 이 매핑은 **시작점**이지 고정된 것이 아닙니다.
더 좋은 모델이 생기면 언제든 재정의하세요.

### 설계 원칙

1. **SRP (Single Responsibility)**: 하나의 에이전트/스킬 = 하나의 책임
2. **추상화 경계**: 레이어 간 명확한 역할 분리
3. **Progressive Disclosure**: 필요할 때만 상세 정보 로드
4. **위임**: 실행은 에이전트에게, 의사결정은 사람에게

---

## 3. 기술 스택 & 컨벤션

### 언어

- **Markdown**: 모든 문서, 명령, 에이전트 정의
- **Bash**: 자동화 스크립트, 훅
- **JSON**: 설정 파일 (plugin.json, hooks.json)

### 폴더 구조

```
claude-automate/
├── commands/           # Controller (진입점)
├── agents/             # Service Layer
├── skills/             # Domain Components
│   └── {skill-name}/
│       ├── SKILL.md    # 스킬 정의
│       ├── schema.md   # 입출력 스키마
│       └── references/ # 참고 자료
├── rules/              # 세부 규칙 (eslint.config 역할)
├── docs/
│   ├── references/     # 외부 참고 자료
│   └── backlogs/       # 백로그 (todo/doing/done)
├── .claude/
│   ├── rules/          # 프로젝트별 규칙
│   └── context/        # 세션 컨텍스트 (자동 생성)
└── CLAUDE.md           # 이 문서
```

### 파일 명명 규칙

| 유형 | 규칙 | 예시 |
|------|------|------|
| Command | `{action}.md` | `wrap.md`, `start-work.md` |
| Agent | `{role}.md`, `{role}-high.md` | `pattern-checker.md` |
| Skill | `{name}/SKILL.md` | `backlog/SKILL.md` |
| Backlog | `phase{N}-{ID}-{slug}.md` | `phase1-001-review-agents.md` |

### 버전 관리

Semantic Versioning: `v{MAJOR}.{MINOR}.{PATCH}`

- MAJOR: 호환성 깨지는 변경
- MINOR: 새 기능 추가
- PATCH: 버그 수정

---

## 4. 에이전트/스킬 설계 원칙

### 에이전트 생성 규칙

**언제 새 에이전트를 만드는가?**

1. 명확히 분리된 책임이 있을 때
2. 다른 모델 Tier가 필요할 때 (Haiku vs Sonnet vs Opus)
3. 병렬 실행의 이점이 있을 때

**만들지 말아야 할 때:**

- 기존 에이전트의 파라미터로 해결 가능할 때
- 책임이 모호할 때
- 한 번만 사용될 로직일 때

### 모델 선택 3-Tier

| Tier | 모델 | 용도 |
|------|------|------|
| Low | Haiku | 데이터 수집, 단순 패턴 매칭, 빠른 응답 |
| Medium | Sonnet | 분석, 의사결정, 표준 에이전트 작업 |
| High | Opus | 복잡한 충돌 해결, 전략적 결정, 창의적 작업 |

### 에이전트 템플릿

```markdown
# {agent-name}

> {한 줄 설명}

## 역할

{이 에이전트가 하는 일}

## 입력

- {input 1}
- {input 2}

## 출력

{출력 형식}

## 사용 조건

- {언제 이 에이전트를 사용하는가}
```

### 스킬 생성 규칙

**언제 새 스킬을 만드는가?**

1. 재사용 가능한 도메인 로직이 있을 때
2. 명확한 입출력 스키마가 정의될 때
3. 여러 에이전트/커맨드에서 사용될 때

### Progressive Disclosure 적용

```
CLAUDE.md (항상 로드)
    ↓ 필요시
rules/*.md (세부 규칙)
    ↓ 필요시
docs/references/*.md (참고 자료)
    ↓ 필요시
skills/*/references/*.md (스킬 상세)
```

---

## 5. 안티패턴 경고

### God Skill

```
❌ 하나의 스킬이 모든 것을 처리
✅ 책임별로 분리된 여러 스킬
```

### Spaghetti CLAUDE.md

```
❌ 모든 상세 정보가 CLAUDE.md에
✅ 원칙만 CLAUDE.md에, 상세는 rules/*.md에
```

### Copy-Paste Configuration

```
❌ oh-my-claudecode 설정을 그대로 복사
✅ 원리를 이해하고 내 상황에 맞게 수정
```

### Premature Optimization

```
❌ 사용하지 않을 기능을 미리 구현
✅ 필요할 때 필요한 것만
```

### 코드 스멜 (에이전트 버전)

| 스멜 | 증상 | 해결 |
|------|------|------|
| 너무 큰 에이전트 | 프롬프트가 500줄 이상 | 책임 분리 |
| 중복 에이전트 | 비슷한 역할의 여러 에이전트 | 통합 또는 파라미터화 |
| Tier 불일치 | Haiku에 복잡한 분석 | 적절한 Tier로 변경 |

---

## 6. 작업 방식

### 기본 워크플로우

```bash
/start-work    # 세션 시작 (컨텍스트 로드)
# ... 작업 ...
/wrap          # 세션 종료 (검증 + 저장)
```

### 코드 변경 전 필수

1. **설명 먼저**: 무엇을, 왜 변경하는지 설명
2. **확인 후 실행**: 동의를 얻은 후 구현
3. **작은 단위**: 한 번에 하나의 변경

### 에이전트 호출 원칙

- 병렬 가능한 작업은 **동시에 호출**
- 의존성이 있는 작업은 **순차적으로 호출**
- 결과를 **통합하여 보고**

### 완료 전 검증

- [ ] 패턴 검증 통과
- [ ] 문서 동기화 확인
- [ ] 세션 컨텍스트 저장

---

## 7. 문서 관리

### 문서 위치 원칙

| 문서 유형 | 위치 | 이유 |
|----------|------|------|
| 핵심 원칙 | CLAUDE.md | 항상 로드 |
| 세부 규칙 | rules/*.md | 필요시 로드 |
| 외부 참조 | docs/references/*.md | 배경 지식 |
| 스킬 상세 | skills/*/references/*.md | 스킬 사용시 |

### 변경 시 업데이트 규칙

1. **Command 변경** → README.md 업데이트
2. **Agent 추가** → README.md + CLAUDE.md 업데이트
3. **Skill 추가** → README.md 업데이트
4. **원칙 변경** → CLAUDE.md 업데이트

---

## 8. 참고 문서

상세 정보는 아래 문서에서 확인:

- [README.md](README.md) - 비전, 철학, 로드맵
- [rules/backlog-rules.md](rules/backlog-rules.md) - 백로그 관리 규칙
- [rules/workflow.md](rules/workflow.md) - Git 워크플로우
- [rules/interaction.md](rules/interaction.md) - 사용자 상호작용 규칙
- [docs/references/](docs/references/) - 참고 자료 모음

---

**Last Updated**: 2026-01-30
