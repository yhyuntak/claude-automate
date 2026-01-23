---
name: explain-skills
description: Claude Code Skills 시스템 가이드. Skills 작성법, 구조, 설정 방법 설명
argument-hint: "[topic]"
---

# Claude Code Skills 가이드

$ARGUMENTS

---

## 📚 Complete Documentation

This skill provides quick reference for Claude Code Skills. For comprehensive documentation:

- **[Agent Skills Open Standard](references/agentskills-spec.md)** - The complete agentskills.io specification with progressive disclosure, validation, and best practices
- **[Claude Code Extensions](references/claude-code-extensions.md)** - Claude Code-specific features including invocation control, subagents, hooks, and advanced configurations

**Quick overview below** | **Deep dive in references** ↑

---

## 1. Skills vs Commands

| 구분 | Commands (구식) | Skills (현재 표준) |
|------|-----------------|-------------------|
| 경로 | `.claude/commands/name.md` | `.claude/skills/name/SKILL.md` |
| 지원 파일 | 단일 파일만 | 디렉토리 구조 지원 |
| 호출 | `/name` | `/name` (동일) |
| 추가 기능 | 제한적 | Frontmatter, 자동 로드 제어, 지원 파일 |

**권장**: 새 기능은 Skills로 작성

---

## 2. 폴더 구조

### 기본 구조
```
.claude/skills/<skill-name>/
├── SKILL.md          # 필수 - 메인 지시사항
├── reference.md      # 선택 - 상세 문서
├── examples.md       # 선택 - 사용 예제
└── scripts/          # 선택 - 실행 스크립트
```

### 위치별 우선순위
1. Enterprise (조직 전체)
2. Personal `~/.claude/skills/` (모든 프로젝트)
3. Project `.claude/skills/` (현재 프로젝트만)
4. Plugin `<plugin>/skills/`

---

## 3. SKILL.md 구조

```markdown
---
name: my-skill                          # 슬래시 명령어 이름
description: 이 skill이 하는 일         # Claude 자동 트리거 판단용
argument-hint: "[args]"                 # 자동완성 힌트
disable-model-invocation: true          # 수동 호출만 (선택)
user-invocable: false                   # 메뉴에서 숨김 (선택)
allowed-tools: Read, Grep, Bash         # 허용 도구 제한 (선택)
context: fork                           # Subagent 독립 실행 (선택)
agent: Explore                          # Subagent 타입 (선택)
---

실제 지시사항이 여기 들어갑니다.

$ARGUMENTS  ← 사용자 인자가 이 위치에 삽입됨
```

---

## 4. Frontmatter 필드 레퍼런스

| 필드 | 타입 | 설명 |
|------|------|------|
| `name` | string | 디렉토리명 대신 사용할 이름 |
| `description` | string | Claude가 자동 로드 판단할 때 참조 |
| `argument-hint` | string | `/skill [hint]` 형태로 표시 |
| `disable-model-invocation` | boolean | `true` = 수동 호출만 가능 |
| `user-invocable` | boolean | `false` = 사용자 호출 불가 (배경 지식용) |
| `allowed-tools` | string[] | 허용할 도구 목록 |
| `context` | string | `fork` = Subagent로 실행 |
| `agent` | string | Subagent 타입 (Explore, Plan 등) |

---

## 5. 호출 방식 매트릭스

| 설정 | 사용자 호출 | Claude 자동 호출 |
|------|-------------|------------------|
| 기본값 | ✅ `/skill` | ✅ 자동 |
| `disable-model-invocation: true` | ✅ `/skill` | ❌ 불가 |
| `user-invocable: false` | ❌ 불가 | ✅ 자동 |

### 언제 무엇을 쓰나?
- **기본값**: 일반적인 도우미 기능
- **disable-model-invocation**: 부작용 있는 작업 (배포, 삭제, 커밋)
- **user-invocable: false**: 배경 지식, 컨텍스트 정보

---

## 6. String Substitutions

| 변수 | 설명 |
|------|------|
| `$ARGUMENTS` | 사용자가 전달한 모든 인자 |
| `${CLAUDE_SESSION_ID}` | 현재 세션 ID |

### 동적 명령 실행
```markdown
## PR 정보
!`gh pr view`

위 PR을 요약하세요.
```
`!`command`` 형식으로 쉘 명령 실행 후 결과 삽입

---

## 7. 실전 예제

### 예제 1: 코드 설명 (자동 로드)
```markdown
---
name: explain-code
description: 코드를 다이어그램과 비유로 설명. 복잡한 코드 설명 시 사용
---

코드 설명 시:
1. 일상 비유로 시작
2. ASCII 다이어그램으로 흐름 표시
3. 단계별 설명
```

### 예제 2: 배포 (수동만)
```markdown
---
name: deploy
description: 프로덕션 배포
disable-model-invocation: true
allowed-tools: Bash
---

$ARGUMENTS 환경에 배포:
1. npm test
2. npm build
3. 배포 실행
```

### 예제 3: API 컨벤션 (배경 지식)
```markdown
---
name: api-conventions
description: API 설계 규칙
user-invocable: false
---

REST API 작성 시:
- GET /resources/{id}
- POST /resources
- 에러: { "error": "...", "code": "..." }
```

---

## 8. 체크리스트

- [ ] `.claude/skills/<name>/SKILL.md` 생성
- [ ] `description` 작성 (Claude 자동 트리거 기준)
- [ ] 부작용 있으면 `disable-model-invocation: true`
- [ ] 지원 파일 필요시 동일 디렉토리에 추가
- [ ] `/skill-name`으로 테스트

---

## 참고 자료

### 📖 This Skill's Documentation
- [Agent Skills Open Standard](references/agentskills-spec.md) - Complete agentskills.io specification
- [Claude Code Extensions](references/claude-code-extensions.md) - Claude Code-specific features

### 🌐 External Resources
- [agentskills.io](https://agentskills.io) - Official open standard
- [Claude Code Skills Guide](https://code.claude.com/docs/ko/skills) - Official Claude Code docs
- [Example Skills](https://github.com/anthropics/skills) - Anthropic's example repository
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) - Community resources
