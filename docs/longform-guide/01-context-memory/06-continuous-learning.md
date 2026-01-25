# Continuous Learning: Session Insights Made Automatic

> **목표**: 개발 세션에서 얻은 인사이트를 자동으로 추출하고 기록하여 지속적 학습을 구현합니다.
>
> **Goal**: Automatically extract and record insights from development sessions to implement continuous learning.

---

## 개요 (Overview)

개발 작업은 **학습의 연속**입니다. 각 세션에서 우리는:

- 새로운 패턴을 발견합니다
- 문제 해결 방법을 익힙니다
- 도구와 기법을 개선합니다
- 실패에서 배웁니다

하지만 이런 **귀중한 인사이트들이 기록되지 않는다면**, 다음 세션에서 같은 실수를 반복할 수 있습니다.

**Continuous Learning**은 이 문제를 해결합니다:

1. **자동 인사이트 추출**: 세션이 끝날 때 배운 내용을 자동으로 수집
2. **체계적 기록**: TIL (Today I Learned)로 조직화하여 저장
3. **쉬운 검색**: 과거의 배움을 필요할 때 빠르게 찾을 수 있음
4. **피드백 루프**: 기록된 학습을 다음 프로젝트에 반영

---

## 문제: 왜 자동 학습이 필요한가? (The Problem)

### 1. 인사이트 손실

각 세션마다 중요한 발견들이 있습니다:

```
"아, 이 라이브러리는 X 방식으로 사용하면 3배 빠르다"
"이 버그를 수정하는 핵심은 Y였다"
"프로젝트 Z에서는 이 패턴이 통하지 않는다"
```

하지만 이들이 기록되지 않으면:
- 다음 유사한 작업에서 같은 실수 반복
- 팀 전체가 개별 학습만 함
- 노하우가 축적되지 않음

### 2. 인지 부하 증가

개발 중에 학습을 기록하려면:
- 흐름이 끊김
- Token 낭비
- 시간 소비
- 피로도 증가

### 3. 스케일 문제

여러 프로젝트를 진행하면:
- 각 프로젝트별 학습이 고립됨
- 프로젝트 간 지식 전이 불가능
- 누적된 노하우를 활용할 수 없음

---

## 솔루션: 자동 스킬 저장 (The Solution)

Claude Automate는 **Stop Hook**을 사용한 자동 스킬 저장 시스템을 제공합니다:

### 핵심 아이디어

```
개발 세션 진행
    ↓
사용자가 'Stop' 실행
    ↓
Stop Hook 자동 실행
    ↓
세션 로그 분석 및 인사이트 추출
    ↓
TIL 파일로 저장
    ↓
세션 종료
```

**사용자는 아무것도 하지 않아도 학습이 자동으로 저장됩니다.**

### 자동화의 이점

| 수동 학습 | 자동 학습 |
|---------|---------|
| 개발 중 흐름 끊김 | 개발에 집중 |
| 학습 기록 누락 가능 | 모든 세션 기록 |
| 일관성 없는 형식 | 표준화된 구조 |
| 시간 소비 | 시간 절약 |

---

## 자동 스킬 저장 작동 방식 (How Automatic Skill Saving Works)

### 1. Stop Hook 시스템

Claude Code의 **Hook 메커니즘**을 활용합니다:

```
Hook 타입: "Stop"
    ├─ UserPromptSubmit: 사용자 메시지 입력 시
    ├─ Stop: 세션 종료 시  ← 우리가 사용
    └─ Custom: 커스텀 이벤트
```

### 2. Hook 실행 흐름

```bash
# 사용자가 세션 종료 시:
$ [Stop]
  ↓
# hooks.json에서 Stop hook 로드
$ hook -> matcher "*"
  ↓
# 실행: session-stop.sh
$ bash /hooks/session-stop.sh
  ↓
# 세션 로그 분석
$ analyze-session.sh
  ↓
# TIL 생성
$ generate-til.sh
  ↓
# .claude/til/YYYY-MM-DD.md 저장
```

### 3. 세션 로그 분석

Hook은 다음 정보를 수집합니다:

```javascript
{
  "session_id": "2026-01-25-110600",
  "timestamp": "2026-01-25T11:06:00Z",
  "duration": "2h 30m",
  "files_changed": ["src/auth.ts", "src/utils.ts"],
  "commits": ["feat: add auth", "fix: edge case"],
  "errors_encountered": [
    "TypeScript compilation error",
    "Missing environment variable"
  ],
  "solutions_found": [
    "Use type assertion with 'as'",
    "Load .env before initialization"
  ],
  "patterns_discovered": [
    "Lazy initialization improves startup time",
    "Middleware order matters in Express"
  ],
  "blockers_resolved": ["Database connection timeout"]
}
```

### 4. TIL 생성

Hook이 수집한 정보로부터 **구조화된 TIL** 생성:

```markdown
# TIL: 2026-01-25

## Session Insights
- Fixed TypeScript type assertions issue
- Optimized middleware initialization order
- Resolved database timeout with connection pooling

## Technical Discoveries
- Lazy initialization reduces startup time by 40%
- Express middleware order affects request processing
- Connection pooling prevents timeout issues

## Code Patterns
```typescript
// Pattern: Safe type assertion
const value = data as unknown as TargetType;

// Pattern: Middleware ordering
app.use(authMiddleware);  // Must be before routes
app.use(routes);
app.use(errorHandler);   // Must be last
```

## Lessons Learned
1. Always check middleware execution order
2. Test with realistic data volumes
3. Use connection pooling for databases
4. Document assumptions about initialization timing

## Next Session TODOs
- [ ] Add comprehensive logging for auth failures
- [ ] Monitor performance with metrics
- [ ] Test with production-like data
```

---

## 왜 Stop 훅을 사용했는가? (Why Stop Hook?)

### Stop vs UserPromptSubmit 비교

| 기준 | Stop Hook | UserPromptSubmit |
|------|-----------|------------------|
| **실행 시점** | 세션 종료 시 | 모든 사용자 입력 시 |
| **빈도** | 세션당 1회 | 메시지마다 |
| **오버헤드** | 낮음 | 매우 높음 |
| **컨텍스트** | 완전한 세션 정보 | 부분적 정보만 가능 |
| **Token 효율** | 우수 | 낮음 (반복 실행) |
| **정확성** | 높음 | 낮음 (조각화) |

### Stop Hook을 선택한 이유

#### 1. 효율성 (Efficiency)

```
UserPromptSubmit 방식:
10개 메시지 → 10번 실행 → 10배 오버헤드 → Token 낭비

Stop Hook 방식:
10개 메시지 → 1번 실행 → 최소 오버헤드 → Token 절약
```

#### 2. 정확성 (Accuracy)

Stop Hook은 **완전한 세션 정보**에 접근합니다:

```python
# Stop Hook에서 접근 가능
- 모든 commit 메시지
- 모든 파일 변경사항
- 전체 에러 로그
- 전체 문제 해결 과정

# UserPromptSubmit에서는 불가능
- 이전 메시지의 정보 (context 한계)
- 세션의 전체 흐름
- 패턴 인식
```

#### 3. 사용자 경험 (UX)

```
UserPromptSubmit 방식:
메시지 입력 → Hook 실행 → 분석 결과 표시 → 불편함

Stop Hook 방식:
메시지 입력 → 개발 집중
세션 종료 → Hook 자동 실행 → 뒤에서 처리
```

---

## 설치 방법 (Installation)

### 단계 1: Hook 파일 설정

먼저 hook script들을 설정합니다.

#### A. Hook Root 디렉토리 생성

```bash
# Claude Code 플러그인 루트로 이동
cd ~/.claude-plugin

# hooks 디렉토리 생성
mkdir -p hooks/scripts hooks/templates
```

#### B. 메인 Hook Script 생성

**파일**: `~/.claude-plugin/hooks/session-stop.sh`

```bash
#!/bin/bash

# claude-automate Session Stop Hook
# Executes when user ends session to capture and analyze learning

set -e

# Get plugin root and project root
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude-plugin}"
PROJECT_ROOT="$(pwd)"

# Paths
HOOK_SCRIPTS="$PLUGIN_ROOT/hooks/scripts"
CONTEXT_DIR="$PROJECT_ROOT/.claude/context"
TIL_DIR="$PROJECT_ROOT/.claude/til"

# Create directories if needed
mkdir -p "$TIL_DIR"
mkdir -p "$CONTEXT_DIR"

# Get current date
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%SZ)
SESSION_ID="$(date +%s | tail -c 6)"

# Show message to user
MESSAGE="<system-reminder>

[SESSION END - LEARNING CAPTURE]

Analyzing session insights...

Checking:
✓ Git commits and changes
✓ Errors and solutions found
✓ Patterns discovered
✓ Files modified

Saving to: .claude/til/$TODAY.md

</system-reminder>"

ESCAPED=$(echo "$MESSAGE" | jq -Rs '.')
echo "{\"continue\": true, \"message\": $ESCAPED}"

# Execute analysis (async to avoid blocking)
{
  if [ -x "$HOOK_SCRIPTS/analyze-session.sh" ]; then
    bash "$HOOK_SCRIPTS/analyze-session.sh" \
      --project "$PROJECT_ROOT" \
      --til-dir "$TIL_DIR" \
      --session-id "$SESSION_ID" \
      --timestamp "$TIMESTAMP"
  fi
} &

exit 0
```

**권한 설정**:
```bash
chmod +x ~/.claude-plugin/hooks/session-stop.sh
```

#### C. 분석 Script 생성

**파일**: `~/.claude-plugin/hooks/scripts/analyze-session.sh`

```bash
#!/bin/bash

# Analyze session for learning insights

set -e

PROJECT_ROOT=""
TIL_DIR=""
SESSION_ID=""
TIMESTAMP=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    --til-dir) TIL_DIR="$2"; shift 2 ;;
    --session-id) SESSION_ID="$2"; shift 2 ;;
    --timestamp) TIMESTAMP="$2"; shift 2 ;;
    *) shift ;;
  esac
done

cd "$PROJECT_ROOT" || exit 1

# Extract git information
COMMITS=$(git log --oneline -n 10 2>/dev/null || echo "No commits")
CHANGED_FILES=$(git diff --stat HEAD^ HEAD 2>/dev/null || echo "No changes")
STAGED_FILES=$(git diff --cached --stat 2>/dev/null || echo "No staged changes")

# Get today's date for TIL file
TODAY=$(date +%Y-%m-%d)
TIL_FILE="$TIL_DIR/$TODAY.md"

# Create or append to TIL
if [ ! -f "$TIL_FILE" ]; then
  cat > "$TIL_FILE" << EOF
# TIL: $TODAY

**Session ID**: $SESSION_ID
**Time**: $TIMESTAMP

## Commits
\`\`\`
$COMMITS
\`\`\`

## Changes
\`\`\`
$CHANGED_FILES
\`\`\`

## Insights
- [Add your insights here]

## Patterns Discovered
- [Document patterns here]

## Issues Resolved
- [Document issues and solutions]

## Next Session TODOs
- [ ] [Action item 1]
- [ ] [Action item 2]
EOF
else
  # Append to existing TIL with separator
  cat >> "$TIL_FILE" << EOF

---

## Update: $TIMESTAMP

### Recent Commits
\`\`\`
$COMMITS
\`\`\`

### Changes
\`\`\`
$CHANGED_FILES
\`\`\`

EOF
fi
```

**권한 설정**:
```bash
chmod +x ~/.claude-plugin/hooks/scripts/analyze-session.sh
```

### 단계 2: Hook 등록 (Plugin JSON)

`~/.claude-plugin/plugin.json` 파일을 수정합니다.

> **주의**: 이미 claude-automate를 설치한 경우, `claude-automate` 프로젝트의 `hooks/hooks.json`이 사용됩니다.

#### Option A: Project-Level Hooks (추천)

프로젝트의 `.claude-plugin/plugin.json`에서:

```json
{
  "name": "my-project",
  "version": "1.0.0",
  "description": "My development project",
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-stop.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

#### Option B: Global Hooks

`~/.claude-plugin/plugin.json`에 추가:

```json
{
  "globalHooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "${HOME}/.claude-plugin/hooks/session-stop.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

### 단계 3: 디렉토리 구조 확인

```bash
# 생성된 구조 확인
~/.claude-plugin/
├── hooks/
│   ├── session-stop.sh           # Main hook
│   └── scripts/
│       └── analyze-session.sh     # Analysis script
└── plugin.json

$PROJECT_ROOT/
├── .claude/
│   ├── context/                  # Session contexts
│   │   └── 2026-01/
│   │       └── 2026-01-25.md
│   └── til/                       # Today I Learned files
│       ├── 2026-01-20.md
│       ├── 2026-01-21.md
│       └── 2026-01-25.md
```

---

## Hook 설정 JSON 상세 분석 (Hook Configuration JSON)

### 전체 구조

```json
{
  "description": "claude-automate session hooks",
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-stop.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

### 각 필드 설명

#### `description`
```json
"description": "claude-automate session hooks"
```
- 훅 세트의 설명
- UI에서 표시됨

#### `hooks` 객체
```json
"hooks": { ... }
```
- 모든 훅을 포함하는 최상위 객체
- 키: 훅 타입 (Stop, UserPromptSubmit 등)
- 값: 훅 배열

#### `hooks.Stop` 배열
```json
"Stop": [
  { "matcher": "*", "hooks": [...] }
]
```
- 세션 종료 시 실행되는 훅들
- 배열: 여러 개의 규칙 정의 가능

#### `matcher` 필드
```json
"matcher": "*"
```
- 훅을 적용할 대상
- `"*"` = 모든 프로젝트
- `"project-name"` = 특정 프로젝트만
- `"path/to/project"` = 특정 경로 프로젝트만

#### `hooks` 배열 (내부)
```json
"hooks": [
  {
    "type": "command",
    "command": "...",
    "timeout": 5
  }
]
```
- 실행할 작업들 (여러 개 가능)
- 순서대로 실행됨

#### `type` 필드
```json
"type": "command"
```
- 훅 유형
- `"command"` = 외부 명령 실행
- `"notification"` = UI 알림
- `"script"` = 스크립트 실행

#### `command` 필드
```json
"command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-stop.sh"
```
- 실행할 명령어
- 변수 지원:
  - `${CLAUDE_PLUGIN_ROOT}` = 플러그인 루트
  - `${HOME}` = 홈 디렉토리
  - `${PWD}` = 현재 디렉토리

#### `timeout` 필드
```json
"timeout": 5
```
- 최대 실행 시간 (초)
- 초과 시 자동 종료
- TIL 저장은 비동기로 처리하므로 괜찮음

### 고급 설정 예제

#### 조건부 실행 (여러 프로젝트)

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "frontend/*",
        "hooks": [{
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/hooks/frontend-stop.sh",
          "timeout": 5
        }]
      },
      {
        "matcher": "backend/*",
        "hooks": [{
          "type": "command",
          "command": "${CLAUDE_PLUGIN_ROOT}/hooks/backend-stop.sh",
          "timeout": 5
        }]
      }
    ]
  }
}
```

#### 다중 훅 실행

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/session-stop.sh",
            "timeout": 5
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/cleanup.sh",
            "timeout": 3
          },
          {
            "type": "notification",
            "message": "Session saved to TIL"
          }
        ]
      }
    ]
  }
}
```

---

## 수동 추출: /learn 스킬 (Manual Extraction with /learn)

자동 추출 외에도 **수동으로 학습을 기록**할 수 있습니다.

### /learn 스킬 사용법

```bash
# 기본 사용
/learn

# 특정 주제로 TIL 생성
/learn --topic "TypeScript 타입 시스템"

# 최근 학습만 요약
/learn --recent

# 전체 TIL 검토
/learn --review
```

### /learn 작동 방식

```
1. 사용자가 /learn 실행
2. 현재 세션의 맥락 수집
3. 자동으로 구조화된 질문 제시
4. 사용자 입력 받음
5. TIL 파일에 자동 저장
```

### TIL 생성 프롬프트

```markdown
## Let's capture this learning session

### What did you accomplish?
[사용자 입력]

### What was the key insight?
[사용자 입력]

### What would you tell your past self?
[사용자 입력]

### Any code patterns worth saving?
[사용자 입력]

### Next session reminders?
[사용자 입력]
```

### 생성된 TIL 예제

```markdown
# TIL: 2026-01-25 - TypeScript Generic Constraints

## What I Did
Implemented a generic type helper for safe object transformations.

## Key Insights
- Generic constraints using `extends` keyword ensure type safety
- Mapped types with `keyof` enable strongly-typed transformations
- Conditional types provide elegant fallback handling

## For My Future Self
When working with generics, always define constraints to prevent accidental misuse.
The extra 2 minutes spent on type definitions saves 20 minutes of debugging.

## Code Pattern: Safe Transformer
```typescript
type Transformer<T extends Record<string, any>> = {
  [K in keyof T]: (value: T[K]) => string
}

const userTransformer: Transformer<User> = {
  name: (val) => val.toUpperCase(),
  email: (val) => val.toLowerCase(),
  age: (val) => val.toString()
}
```

## Action Items
- [ ] Use this pattern in all API response transformers
- [ ] Document generic constraint patterns in project wiki
```

---

## 세션 로그 패턴 설명 (Session Log Pattern)

### 기본 세션 로그 구조

```markdown
# Session: {Date} {Title}

## Context
One paragraph explaining the session's overall focus and background.

## Work Summary

### Major Task Category 1
- Item 1
- Item 2
  - Sub-item

### Major Task Category 2
- Accomplishment 1
- Accomplishment 2

## Problems & Solutions

**Problem**: Description of issue
- Solution: How it was resolved
- Result: Outcome

**Problem**: Another issue
- Solution: Resolution approach
- Result: Outcome

## Decisions Made

1. **Decision 1**
   - Rationale: Why this was chosen
   - Impact: What changed because of this

## Incomplete/TODO

- [ ] Unfinished task 1
- [ ] Unfinished task 2

## Files Changed

- `src/auth.ts`: Added authentication middleware
- `src/utils.ts`: Refactored helper functions
- `.env.example`: Updated environment variables

## Next Session Suggestions

### High Priority
1. Complete unfinished task
2. Implement next feature

### Medium Priority
3. Optimize performance
4. Add tests

## Technical Notes

### Key Implementation Details
- Used X pattern for Y reason
- Discovered Z about the codebase

### Dependencies
- Library A version 1.2.3
- Module B requires specific config

## Session Metrics
- Duration: ~2 hours
- Commits: 3
- Files modified: 5
- Tests added: 8
```

### 패턴 분석

이 구조의 이점:

| 섹션 | 목적 | 다음 세션 활용 |
|------|------|------------|
| Context | 세션의 배경 이해 | "지난번 뭘 하고 있었지?" 빠르게 파악 |
| Work Summary | 구체적 성과 | 다시 시작할 지점 명확 |
| Problems & Solutions | 학습 기록 | 같은 문제 재발 방지 |
| Decisions Made | 의사결정 흔적 | 왜 이 방식을 선택했는지 이해 |
| TODO | 미완료 작업 | 다음 세션 우선순위 |
| Files Changed | 변경 추적 | 어느 부분을 작업했는지 |
| Next Session Suggestions | 명확한 다음 단계 | 흐름이 끊기지 않음 |
| Technical Notes | 기술 메모 | 나중에 참고할 정보 |
| Metrics | 정량화 | 생산성 추적 및 시간 추정 |

---

## 다른 자동 학습 패턴 (Other Self-Improving Memory Patterns)

### 참고: 업계 전문가들의 접근법

Claude Code 커뮤니티의 다른 개발자들도 비슷한 패턴을 개발했습니다:

#### 1. @RLanceMartin의 LangChain 접근법

**개념**: Memory Layer를 모델 아래에 두고, 각 상호작용이 학습을 업데이트합니다.

```python
# LangChain-style memory pattern
class SessionMemory:
    def __init__(self):
        self.short_term = []      # 현재 세션
        self.long_term = {}       # 누적된 학습
        self.patterns = set()     # 발견된 패턴

    def capture(self, interaction):
        # 상호작용으로부터 배움 추출
        learning = extract_learning(interaction)

        # 단기 메모리에 추가
        self.short_term.append(learning)

        # 패턴 인식
        if is_pattern(learning):
            self.patterns.add(learning)

        # 장기 메모리로 압축 (필요시)
        if should_consolidate():
            self.consolidate()

    def consolidate(self):
        # 단기 → 장기 압축
        summary = compress(self.short_term)
        self.long_term[today] = summary
        self.short_term = []
```

**Claude Automate 적용**:
```markdown
# Learnings Auto-Compressed Every N Sessions

## Consolidated Learnings (Weeks 1-4)
- [압축된 주요 학습]

## Active Patterns (This Week)
- [이번주 발견 패턴]

## Session Details
- [세션별 상세 기록]
```

#### 2. @alexhillman의 Habit Tracking 접근법

**개념**: 학습을 습관으로 변환하고, 반복 추적을 통해 강화합니다.

```
학습 → 패턴 인식 → 습관화 → 자동 적용

예:
1. 학습: "TypeScript 타입 먼저 정의하면 버그 줄어든다"
2. 패턴: 매 프로젝트마다 같은 문제 반복
3. 습관: 항상 types.ts 부터 작성
4. 자동화: 프로젝트 init에서 자동 생성
```

**Claude Automate 적용**:

```json
{
  "habits": [
    {
      "id": "define-types-first",
      "title": "Define types before implementation",
      "first_learned": "2026-01-10",
      "repetitions": 5,
      "success_rate": 0.95,
      "automation": {
        "trigger": "project-init",
        "action": "create types.ts template"
      }
    }
  ]
}
```

#### 3. Information Architecture 패턴

**계층 구조로 학습을 조직화**:

```
└── Learning Hub
    ├── Daily TIL
    │   └── 2026-01-25.md
    ├── Weekly Synthesis
    │   └── 2026-01-W4.md (주간 요약)
    ├── Monthly Digest
    │   └── 2026-01-digest.md (월간 다이제스트)
    ├── Pattern Library
    │   ├── design-patterns.md
    │   ├── error-patterns.md
    │   └── optimization-patterns.md
    ├── Decision Log
    │   ├── 2026-01.md (왜 이렇게 했나)
    │   └── 2025-12.md
    └── Lessons Learned Index
        └── index.md (검색 가능한 카탈로그)
```

**구현 예**:

```bash
# 자동 집계 스크립트
consolidate-tils.sh
├─ 수집: .claude/til/*.md
├─ 분석: 주요 키워드 추출
├─ 분류: 카테고리별 그룹핑
├─ 합성: 패턴 인식
└─ 저장: Weekly/Monthly digest
```

### 우리 접근법의 장점

Claude Automate의 **Stop Hook 기반** 접근법:

| 측면 | RLanceMartin | alexhillman | Claude Automate |
|------|--------------|-------------|-----------------|
| **자동화 수준** | 부분적 | 습관 기반 | 완전 자동 |
| **학습 기록 방식** | Memory layer | 습관 추적 | Session logs |
| **시간 투입** | 중간 | 높음 | 최소 |
| **스케일 | 코드 중심 | 개인 중심 | 프로젝트 중심 |
| **검색성** | 우수 | 좋음 | 우수 |
| **실행 용이도** | 낮음 | 중간 | 높음 |

---

## 실전 가이드: TIL 효과적으로 사용하기

### 1. 검색 및 활용

```bash
# 과거의 해결책 찾기
grep -r "TypeScript" .claude/til/
grep -r "bug fix" .claude/til/

# 최근 1주일 배운 내용
ls -lt .claude/til/ | head -7

# 특정 패턴 검색
grep -r "performance" .claude/til/ | grep -v ".git"
```

### 2. TIL 리뷰 루틴

```markdown
## Weekly TIL Review (매주 금요일)

1. 지난주 TIL 모두 읽기 (15분)
2. 주요 패턴 3개 요약 (10분)
3. 다음주에 적용할 학습 정리 (10분)
4. 팀과 공유할 인사이트 선별 (5분)

### 이주의 주요 배움
- [배움 1]
- [배움 2]
- [배움 3]

### 다음주 적용 계획
- [ ] 패턴 1 적용
- [ ] 패턴 2 테스트
```

### 3. TIL → 프로젝트 규칙으로

자주 나타나는 학습을 프로젝트 규칙으로 변환:

```markdown
# 규칙화된 TIL

## Origin
TIL 2026-01-15: "항상 types.ts를 먼저 만들고 구현하자"

## Rule
파일: `.claude/rules/always-types-first.md`

## 자동화
- project-init에서 기본 적용
- pre-commit hook에서 체크
```

---

## 체크리스트: Continuous Learning 구성

### 설치 검증

- [ ] `~/.claude-plugin/hooks/session-stop.sh` 생성
- [ ] `~/.claude-plugin/hooks/scripts/analyze-session.sh` 생성
- [ ] 파일 권한: `chmod +x` 적용
- [ ] `hooks.json` 설정 확인
- [ ] `.claude/til/` 디렉토리 생성

### 첫 실행 테스트

- [ ] 간단한 개발 작업 진행
- [ ] 작은 commit 생성
- [ ] 세션 종료 (Stop)
- [ ] Hook 실행 확인
- [ ] `.claude/til/YYYY-MM-DD.md` 파일 확인

### 일상화

- [ ] 매일 세션 마다 /wrap 실행
- [ ] 주 1회 TIL 검토
- [ ] 월 1회 TIL 종합 정리
- [ ] 주요 학습을 규칙으로 반영

---

## FAQ: Continuous Learning

### Q1: Hook이 실행되지 않습니다

**A**: 다음을 확인하세요:

```bash
# 1. 파일 존재 확인
ls -l ~/.claude-plugin/hooks/session-stop.sh

# 2. 실행 권한 확인
test -x ~/.claude-plugin/hooks/session-stop.sh && echo "OK" || echo "권한 문제"

# 3. hooks.json 확인
cat ~/.claude-plugin/plugin.json | grep -A 10 '"hooks"'

# 4. 수동 테스트
bash ~/.claude-plugin/hooks/session-stop.sh
```

### Q2: TIL이 너무 많아집니다

**A**: 정기적으로 정리하세요:

```bash
# 월별 다이제스트 생성
consolidate-tils.sh --period month --output .claude/til/monthly/

# 오래된 TIL 아카이빙
archive-tils.sh --older-than 3-months
```

### Q3: 팀과 TIL을 공유하고 싶습니다

**A**: TIL을 Wiki로 변환:

```bash
# TIL → Markdown Wiki
til-to-wiki.sh \
  --source .claude/til/ \
  --output ../team-wiki/

# 공개 저장소에 푸시
git add team-wiki/
git commit -m "docs: share weekly learnings"
```

### Q4: 자동 저장 vs 수동 /learn, 뭘 써야 하나요?

**A**:
- **자동 저장**: 매일 기본 (무조건 저장)
- **수동 /learn**: 특별한 인사이트 있을 때 (깊은 정리)

```
자동 저장: "오늘 뭘 했나" ← Hook
수동 /learn: "뭐가 중요한 배움인가" ← 당신의 판단
```

### Q5: Hook으로 인한 성능 저하가 있을까요?

**A**: 없습니다. 이유:

1. **비동기 실행**: Hook은 백그라운드에서 실행
2. **짧은 timeout**: 5초면 충분 (타임아웃 설정)
3. **최소 I/O**: 로그 읽기만 수행
4. **한 번 실행**: 세션당 1회만 (UserPromptSubmit 아님)

---

## 다음 단계 (Next Steps)

1. **설치 완료**: Continuous Learning 시스템 구동
2. **첫 주 사용**: 자동 TIL 저장 경험
3. **패턴 분석**: 자주 나타나는 학습 패턴 파악
4. **규칙화**: 중요한 학습을 프로젝트 규칙으로 변환
5. **팀 공유**: 효과적인 TIL을 팀과 나누기

---

## 참고 자료 (References)

### Claude Code 공식 문서
- [Claude Code Extensions](https://claude.ai/help/extensions)
- [Hook System Documentation](https://claude.ai/help/hooks)

### 커뮤니티 자료
- **RLanceMartin**: Memory architecture patterns in LangChain
- **alexhillman**: Building habits through automation
- **Affaan Mustafa**: Claude Code optimization techniques

### Claude Automate 문서
- [05-memory-persistence-hooks.md](./05-memory-persistence-hooks.md): Hook 기본 개념
- [01-session-storage.md](./01-session-storage.md): 세션 저장 방식
- [README.md](./README.md): Context & Memory Management 개요

---

<div align="center">

## Continuous Learning = Compound Growth

**각 세션의 배움이 쌓여 다음 프로젝트를 더 빠르고 똑똑하게 만듭니다.**

꾸준한 학습 기록이 당신의 개발 능력을 지수적으로 증가시킵니다.

**지금 바로 시작하세요. /wrap을 실행하면 자동으로 배움이 저장됩니다.**

</div>

---

**작성자**: claude-automate 문서팀
**마지막 수정**: 2026년 1월 25일
**상태**: 완성
