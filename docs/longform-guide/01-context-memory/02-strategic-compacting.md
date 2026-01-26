# Strategic Context Compacting

> 전략적 컨텍스트 압축: 장기 세션에서의 효율적인 메모리 관리

---

## 핵심 개념 / Core Concepts

### Context Compacting이란?

**Context Compacting** (컨텍스트 압축)은 장기 개발 세션에서 누적된 Claude Code의 컨텍스트 정보를 효율적으로 정리하고 축약하여 Token 사용량을 최적화하는 전략입니다.

Context Compacting is a strategic approach to compress accumulated context information in long development sessions, optimizing token usage while preserving essential information for task continuity.

### 왜 필요한가? / Why It Matters

**Long Session Problem (장기 세션 문제)**

```
시간 흐름 (Time Flow)
├─ 00:00 - Session Start
│  └─ Context: Task A, Task B 기획
│
├─ 02:00 - Mid Session
│  └─ Context 누적:
│     - 완료된 여러 작은 작업들의 디테일
│     - 실패한 시도들의 세부사항
│     - 여러 버전의 코드 스니펫
│     - 디버깅 과정 기록
│
├─ 04:00 - Late Session
│  └─ Context 비대화:
│     - Token 사용량 급증
│     - 응답 시간 지연
│     - 중요 정보 희석
│     - 의사결정 품질 저하
│
└─ 06:00 - Session End (Potential Context Limit Hit)
   └─ 결과: 마지막 작업 효율 크게 감소
```

**Token Efficiency Example (Token 효율 예시)**

```
Before Compacting:
├─ Session Context (uncompacted): 45,000 tokens
├─ Current Task: 5,000 tokens
└─ Total: 50,000 tokens
   → OpenAI API cost impact
   → Slower response time
   → Risk of context cutoff

After Compacting:
├─ Session Context (compacted): 8,000 tokens (-82%)
├─ Current Task: 5,000 tokens
└─ Total: 13,000 tokens
   → 74% reduction in context overhead
   → Faster response, better quality
   → Safe margin from context limits
```

---

## 탐색 vs 실행 컨텍스트 / Exploration vs Execution Context

컨텍스트에는 두 가지 주요 타입이 있으며, 각각 다르게 관리됩니다.

### Exploration Context (탐색 컨텍스트)

**정의**: 문제 해결 과정에서 거쳐간 탐색 과정, 실패한 시도, 디버깅 과정 등

```
Exploration Context 포함 항목:
├─ 시도해본 접근법들 (Approaches tried)
├─ 막혔던 부분과 해결 과정 (Debugging steps)
├─ 버전 비교 (Comparison of versions)
├─ 의도한 설계와 최종 설계의 차이 (Design evolution)
└─ 고민했던 선택지들 (Decision alternatives)

특징:
- 매우 상세함 (Highly detailed)
- 대량의 정보 (Lots of information)
- Token 소비 많음 (High token usage)
- 현재 작업에 직접 관련 낮음 (Low relevance to current work)
- 다음 세션에서 불필요할 확률 높음 (Often not needed later)
```

**예시 (Example)**

```markdown
## Exploration Path (Should be compacted)

### Attempt 1: Hook-based approach
- Tried implementing session-start hook
- Problem: Race condition with plugin initialization
- Solution: Abandoned this approach

### Attempt 2: Automatic context loading on session start
- Created SessionStart hook with bash script
- Issue: Unreliable timing, sometimes hook executed before context loaded
- Duration: 4 hours of debugging
- Result: Decided to make it explicit /session-start command instead

### Detailed Debugging Log
- Line 45: Expected array, got string
- Line 127: Context not properly serialized
- Tried 5 different JSON parsing libraries
- ...
```

**Compaction Result (압축 결과)**

```markdown
## Implementation Decision

Used explicit `/session-start` command instead of automatic hook.
- Reason: Better reliability and explicit control over context loading
- Alternative considered: Automatic hook (rejected due to timing issues)
- Time investment: ~4 hours to determine optimal approach
```

### Execution Context (실행 컨텍스트)

**정의**: 현재 진행 중인 작업에 필수적인 정보와 최종 결정사항

```
Execution Context 포함 항목:
├─ 최종 결정사항 (Final decisions)
├─ 현재 진행 상황 (Current status)
├─ 다음 단계 (Next steps)
├─ 코드/아키텍처 최종 결과 (Final code/architecture)
└─ 외부 의존성 (External dependencies)

특징:
- 압축된 형태 (Compressed format)
- 필수 정보만 포함 (Only essential info)
- Token 효율적 (Token efficient)
- 현재 및 다음 작업에 필수 (Essential for current/next work)
- 다음 세션에서 반드시 필요 (Needed by next session)
```

**예시 (Example)**

```markdown
## Implementation Decisions

### Session Context Loading
**Decision**: Use explicit `/session-start` command
**Why**: Provides explicit control and eliminates race conditions
**Location**: `commands/session-start.md`
**Interface**: Reads from `.claude/context/{YYYY-MM}/{YYYY-MM-DD-*}.md`

## Current Status
- Phase 2: `/session-start` command development
- Files created: context-builder.md, session-start.md
- Next: Integrate with `/start-work` workflow

## Architecture Decisions
- Context files: Timestamped per-session format
- Storage: `.claude/context/{YYYY-MM}/` hierarchical structure
- Format: Markdown with sections: Context, Summary, Problems, Decisions, TODO, Next
```

### Compacting Strategy Table

| 측면 | Exploration | Execution | 압축 결정 |
|------|-----------|-----------|---------|
| **정보 특성** | 과정 중심 | 결과 중심 | 실행만 유지 |
| **세부도** | 매우 상세 | 요약 형태 | 단순화 |
| **유지 기간** | 1-2 세션 | 지속 유지 | 세션마다 새로 작성 |
| **Token 비용** | 높음 | 낮음 | 80-90% 감축 |
| **다음 세션 필요성** | 극히 드물음 | 거의 항상 | 필수 정보만 남김 |

---

## Plan Mode와 Context Clearing

### Plan Mode란?

**Plan Mode** (계획 모드)는 전략적으로 컨텍스트를 초기화하고 새로운 계획으로 세션을 재시작하는 방식입니다.

Plan Mode is a strategic session restart method where accumulated context is cleared and replaced with a fresh strategic plan for continued work.

### Plan Mode가 필요한 경우

```
상황 판단 플로우차트:

┌─────────────────────────────────┐
│ Session 중 이 신호를 느낀다면?   │
└────────────┬────────────────────┘
             │
    ┌────────┴────────┬────────────┬────────────┐
    ↓                 ↓            ↓            ↓
  Divergence     Complexity      Focus Loss   Uncertainty
  (갈등)         (복잡도)       (집중도)     (불확실성)
    │                │            │            │
    ↓                ↓            ↓            ↓
─────────────────────────────────────────────────────────
상황: 두 가지     상황: 너무      상황: 마지막 상황: 다음
선택지 사이       많은 의존성     결정이 불명확 단계가
에서 방향 결정이 이나 복잡한                불명확
필요함          상호작용
─────────────────────────────────────────────────────────

    ↓                ↓            ↓            ↓
  Plan Mode 적절한 경우입니다!
```

### When to Enter Plan Mode

**Plan Mode 진입 체크리스트**

```
□ Context 크기가 40KB 이상 (Context growing beyond control)
□ 마지막 응답이 이전보다 느려짐 (Response time degradation)
□ 현재 작업 방향 불명확함 (Current direction unclear)
□ 여러 선택지 사이에서 결정 필요 (Decision paralysis)
□ 새로운 phase/milestone 시작 (Starting new phase)
□ 3시간 이상의 단일 세션 (Session duration > 3 hours)

체크 개수:
- 0-1개: 계속 진행 (Keep going)
- 2-3개: 상황 모니터링 (Monitor)
- 4+개: Plan Mode 진입하기 (Enter Plan Mode)
```

### Plan Mode Execution Steps

**Step 1: Compact Current Context (현재 컨텍스트 압축)**

```bash
# 현재 상태를 Execution Context만으로 압축하기:

현재 .claude/context.md에서:

## KEEP (실행 컨텍스트)
- 최종 결정사항
- 현재 진행 상황
- 다음 단계
- 중요한 아키텍처 결정

## REMOVE (탐색 컨텍스트)
- 실패한 시도들의 세부사항
- 디버깅 프로세스 전체
- 고려했지만 버린 선택지들
- 상세한 작업 로그
```

**Step 2: Create High-Level Plan (고수준 계획 작성)**

```markdown
## New Work Plan

### Current Status (1-2 문장)
- [지금까지의 성과]
- [마지막 완료된 단계]

### Remaining Work (3-5개 큰 항목)
1. [Phase 1]: Description
2. [Phase 2]: Description
3. [Phase 3]: Description

### Success Criteria (3-4개)
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

### Dependencies & Constraints
- Dependency 1
- Constraint 1
```

**Step 3: Clear Exploration Context (탐색 컨텍스트 제거)**

```
제거할 항목들:
├─ 상세한 디버깅 로그 ✓ 제거
├─ 시도해본 접근법들 ✓ 제거
├─ 고려했던 대안들 ✓ 제거
├─ 버전 비교 및 진화 과정 ✓ 제거
└─ 절차적 작업 단계들 ✓ 제거

유지할 항목들:
├─ 최종 결정 이유 ✓ 유지
├─ 선택된 아키텍처 ✓ 유지
├─ 현재까지 완료한 결과 ✓ 유지
└─ 다음 세션을 위한 정보 ✓ 유지
```

**Step 4: Resume with Fresh Context (새 컨텍스트로 재개)**

```
Before Plan Mode:
├─ Exploration detail: 30,000 tokens
├─ Debugging logs: 12,000 tokens
├─ Decision history: 8,000 tokens
└─ Execution context: 5,000 tokens
Total: 55,000 tokens

After Plan Mode:
├─ High-level plan: 2,000 tokens
├─ Status summary: 1,500 tokens
├─ Remaining work: 1,500 tokens
└─ Execution context: 5,000 tokens
Total: 10,000 tokens (-82%)
```

---

## Auto-Compact vs Manual Compact 비교표

| 측면 | Auto-Compact | Manual Compact | 선택 기준 |
|------|-----------|-------------|---------|
| **언제 실행** | 자동 감지 (Context > 40KB) | 사용자 명시적 요청 | 자동 트리거 선호 |
| **압축 전략** | 규칙 기반 (Rule-based) | 의도 기반 (Intent-based) | 상황에 따라 다름 |
| **정보 손실** | 최소화 (Minimize) | 제어 가능 (Controllable) | 민감 정보는 수동 |
| **Token 절감** | 60-70% | 70-85% | 효율 원하면 수동 |
| **재개 속도** | 즉시 (Immediate) | 준비 시간 필요 (Prep time) | 빠른 재개 원하면 자동 |
| **컨텍스트 명확성** | 높음 (Clear) | 매우 높음 (Very clear) | 명확성 원하면 수동 |
| **실패 위험** | 낮음 (Low) | 중간 (Medium) | 안전성 원하면 자동 |
| **학습 가치** | 낮음 (Low) | 높음 (High) | 학습 원하면 수동 |

### Auto-Compact 메커니즘

**자동 압축이 실행되는 조건:**

```
Context Monitor 계속 확인:
├─ Context 파일 크기: .claude/context.md 감시
├─ 임계값: 40KB 이상
└─ 빈도: 매 세션 종료 시

임계값 도달 시:
├─ 트리거: WRAP 커맨드에서 감지
├─ 실행: 자동으로 context-compactor 호출
├─ 처리: 규칙 기반 압축 알고리즘 적용
└─ 결과: 압축된 context.md + archived context

보고:
└─ 사용자에게 압축 결과 통지
   - 원본 크기: X bytes
   - 압축 후: Y bytes
   - 절감: Z%
   - 보존된 정보: [핵심 항목 목록]
```

**Auto-Compact 규칙 (Heuristic Rules)**

```
1. 완료 상태 판단:
   - "완료" 상태의 작업 → 1줄 요약으로 축약
   - "진행중" 상태의 작업 → 전체 유지

2. 시간 기반 규칙:
   - 3일 이상 전 작업 → 요약 처리
   - 어제-오늘 작업 → 상세 유지

3. 중요도 규칙:
   - 현재 작업과 관련성 0-10%:
     → 1줄 요약으로 축약
   - 현재 작업과 관련성 50% 이상:
     → 상세 유지

4. 유형 별 규칙:
   - 디버깅 로그 → 결과만 남기고 제거
   - 시도 과정 → "Decision: X선택" 형태로 요약
   - 코드 스니펫 → 최종 버전만 유지
```

### Manual Compact 절차

**Manual Compact 실행 방법:**

```bash
# Step 1: 현재 context 상태 확인
cat .claude/context.md | head -100

# Step 2: 압축 대상 파악
# - 탐색 컨텍스트 찾기
# - 불필요한 상세 정보 찾기
# - 정보 중복 찾기

# Step 3: 압축 정책 결정
# - 어디까지 삭제할지 결정
# - 보존할 핵심 정보 결정
# - 보관 전략 결정

# Step 4: 저장소에 보관
# - 원본을 아카이브: .claude/context/archive/{date}-context.md
# - Execution context로 리셋

# Step 5: 새 context로 재개
# - 새로운 계획 수립
# - 압축된 상태에서 작업 계속
```

**Manual Compact 체크리스트:**

```
Before Manual Compact:
□ 원본 context.md 백업 (Backup)
□ 아카이브 위치 확인 (.claude/context/archive/)
□ 보존할 정보 리스트 작성 (Keep list)

During Manual Compact:
□ 문단 단위로 삭제 (Delete by paragraph)
□ 각 단계마다 저장 (Save after each step)
□ Execution context 명확하게 유지 (Keep exec context clear)

After Manual Compact:
□ 새 context 길이 확인 (<15KB 권장)
□ 중요 정보 모두 포함 확인 (All critical info present)
□ 테스트: 새로운 작업 진행 가능한지 확인 (Test with new task)
```

---

## 언제 Compact 해야 하는가? / When to Compact

### 시나리오 1: 마일스톤 완료 시 / Milestone Completion

**상황 (Situation)**

```
프로젝트 진행:
├─ Phase 1: Features A, B, C 구현 (8시간)
├─ Phase 2: Testing & Bug fixes (4시간)
├─ Phase 3: Documentation
│  └─ ✓ 완료
└─ 현재: Phase 4 시작 예정

컨텍스트 상태:
├─ Phase 1의 상세 구현 과정: 15,000 tokens (Now irrelevant)
├─ Phase 2의 버그 추적 과정: 12,000 tokens (Historical only)
├─ Phase 3 작업 완료: 2,000 tokens (Reference needed)
└─ 현재 상태: 3,000 tokens (Critical)
Total: 32,000 tokens
```

**Compact 필요한 이유**

```
1. Phase 1-2는 이미 완료되어 현재 작업과 관련 없음
2. Phase 3는 기록용으로만 필요하고 상세 과정은 불필요
3. Phase 4부터는 새로운 컨텍스트 필요
4. 누적된 상세 정보가 새 작업 집중도 방해
```

**Compact 전략**

```
Phase 1-2 → 1줄 요약으로 축약
"Phase 1-2: Features A-C 구현 및 테스트 완료. 모든 단위 테스트 통과."

Phase 3 → 중요 결과만 유지
"Phase 3: Documentation 완료.
- API docs: /docs/api/
- Architecture: /docs/architecture/
- User guide: /docs/guide/"

새 컨텍스트 작성
"Phase 4 시작: 성능 최적화
- 우선순위: API response time < 100ms
- 범위: Core data processing paths
- 기한: 2일"

결과:
Before: 32,000 tokens
After: 8,000 tokens (75% 절감)
```

### 시나리오 2: 장기 단일 작업 중 피로 / Long Single Task Fatigue

**상황 (Situation)**

```
장기 단일 작업:
├─ Task: "Complex refactoring of core module"
├─ Duration: 6시간 경과
├─ Status: 절반 진행
└─ 현재 컨텍스트:
   ├─ 초기 계획: 1,000 tokens
   ├─ 리팩토링 과정 상세: 25,000 tokens
   ├─ 테스트 결과들: 10,000 tokens
   ├─ 고민했던 설계 선택지: 8,000 tokens
   └─ 현재 상태: 2,000 tokens
   Total: 46,000 tokens
```

**신호 (Symptoms)**

```
- Response quality 저하 감지
- "뭘 하고 있었는지 헷갈림"
- 최근 결정이 명확하지 않음
- Context window 70% 이상 사용 중
```

**Compact 필요한 이유**

```
1. 리팩토링 과정은 기록용, 최종 상태만 필요
2. 테스트 상세 결과는 최종 테스트 결과만 필요
3. 고민했던 선택지들은 불필요 (이미 결정됨)
4. 마지막 절반 완성을 위해 뇌 "메모리" 필요
```

**Compact 전략**

```
이전 리팩토링 과정 → 결과만 축약
Before: "파일 A를 먼저 리팩토링하려다가 의존성 문제 발생...
        파일 B의 의존성 먼저 해결...
        3번의 시도 끝에 순서를 정함..."

After: "파일 리팩토링 순서: B→C→A (의존성 기준)"

테스트 결과 축약
Before: "Test 1 failed: X, Test 2 failed: X, ... (30줄)"
After: "Unit tests: 12/15 passed. Failing: test-util.ts, test-parser.ts, test-edge-cases.ts"

설계 선택지 제거
Before: "고려했던 3가지 리팩토링 방식 비교..." (전체 제거)
After: "(삭제됨 - 이미 결정됨)"

현재 진행 상황 명확히
"리팩토링 진행도: 45%
 - 완료: Files B, C의 리팩토링
 - 현재: File A 진행 중 (75% 완성)
 - 남은 작업: File A 마무리, 통합 테스트"

결과:
Before: 46,000 tokens
After: 9,000 tokens (80% 절감)
⇒ 마지막 절반을 위한 충분한 컨텍스트 확보
```

### 시나리오 3: 새로운 주제로 전환 / Context Switch

**상황 (Situation)**

```
프로젝트 전환:
├─ 이전 작업: "Database optimization" (완료)
│  └─ Context: 28,000 tokens (DB schema, query plans, metrics 등)
│
├─ 새로운 작업: "Frontend component refactoring"
│  └─ 이전 context와 0% 관련성
│
└─ 현재 문제:
   - DB optimization context가 새 작업 방해
   - Frontend context 작성할 공간 필요
   - Token 낭비 심각
```

**신호 (Symptoms)**

```
- 새 작업 컨텍스트 작성 중 token limit 경고
- 과거 작업 정보가 계속 상단에 표시됨
- 새 작업 설명에 불필요한 과거 정보 포함됨
```

**Compact 필요한 이유**

```
1. 이전 작업은 완료되어 더 이상 필요 없음
2. 새로운 작업에 컨텍스트 공간 필요
3. 관련성 0%인 정보는 해로움 (confusion)
```

**Compact 전략**

```
Option A: 완전 리셋 (Full Reset)
- DB optimization context 전체 삭제
- 새로운 Frontend context 작성
- 이전 작업은 필요시 git history로 참조

결과:
├─ Before: 28,000 (DB) + 新context
├─ After: 新context only (~10,000)
└─ Token 절감: ~70%

Option B: 아카이브 유지 (Archive Keeping)
- DB optimization을 .claude/context/archive/db-opt.md로 이동
- 새로운 Frontend context 작성
- 필요시: "frontend-refactor에서 DB 스키마 참고 필요 시 archive에 있음" 메모

권장: Option A (깔끔함)
주의: 아카이브는 .gitignore에 포함되므로 별도 백업 고려
```

---

## 실전 사용법 / Practical Usage Guide

### Basic Compact Flow

**Step 1: 현재 상태 평가**

```bash
# 현재 context 파일 확인
ls -lh .claude/context.md

# 파일 크기 확인
wc -l .claude/context.md

# 상위 내용 확인
head -50 .claude/context.md

# 평가:
# - 20KB 미만: 괜찮음 (OK)
# - 20-40KB: 모니터링 (Monitor)
# - 40KB 이상: Compact 권장 (Recommend compact)
```

**Step 2: 백업 생성**

```bash
# 아카이브 디렉토리 확인
mkdir -p .claude/context/archive

# 현재 context 백업
DATE=$(date +%Y%m%d-%H%M%S)
cp .claude/context.md .claude/context/archive/context-${DATE}.md

# 확인
ls -lh .claude/context/archive/ | tail -3
```

**Step 3: Execution Context 식별**

```markdown
원본 .claude/context.md에서 다음을 식별합니다:

KEEP (유지할 정보):
═══════════════════════════════════════════
□ Current Status (현재 상태 요약)
□ Key Decisions (중요 결정사항)
□ Architecture (아키텍처 결정)
□ Remaining Work (남은 작업)
□ Dependencies (의존성)

REMOVE (제거할 정보):
═══════════════════════════════════════════
□ Exploration history (탐색 과정)
□ Failed attempts (실패한 시도)
□ Detailed debugging (상세 디버깅)
□ Decision alternatives (고려했던 대안)
□ Time-stamped work logs (시간 기반 로그)

MOVE TO ARCHIVE (아카이브로 이동):
═══════════════════════════════════════════
□ Completed phases (완료된 단계)
□ Historical decisions (역사적 결정)
□ Reference materials (참고 자료)
```

**Step 4: 압축 실행**

```bash
# 방법 1: Text editor로 수동 편집
vim .claude/context.md

# 삭제할 섹션을 식별하고 제거
# 저장 후 파일 크기 확인
ls -lh .claude/context.md

# 방법 2: 자동 스크립트 사용 (있으면)
./scripts/compact-context.sh
```

**Step 5: 검증**

```bash
# 파일 크기 확인
echo "New size:"
wc -c .claude/context.md

# 핵심 정보 존재 확인
echo "Critical sections present:"
grep -c "^## " .claude/context.md

# 산술 확인: 원본과 비교
# Before: 45,000 bytes
# After: 9,000 bytes
# Reduction: 80%
```

**Step 6: 새 작업으로 재개**

```markdown
# New Work Session (Post-Compact)

## Status
- Previous sessions archived
- Context compacted to execution essentials
- Ready for new work phase

## Next Steps
1. [New task 1]
2. [New task 2]
3. [New task 3]
```

### Manual Compact Template

**사용할 템플릿 (Template to use):**

```markdown
# Context Compaction Record

## Compaction Metadata
- Date: YYYY-MM-DD HH:MM
- Original size: X bytes
- Compressed size: Y bytes
- Reduction: Z%
- Duration: N hours

## What Was Kept (유지된 정보)
- [ ] Current status summary
- [ ] Key architectural decisions
- [ ] Remaining work items
- [ ] Critical dependencies
- [ ] Important code locations

## What Was Removed (제거된 정보)
- [x] Detailed debugging logs (상세 디버깅 로그)
- [x] Exploration attempts (탐색 시도들)
- [x] Decision alternatives (대안 검토)
- [x] Step-by-step process (단계별 과정)
- [x] Timestamped work log (시간 기반 로그)

## Archive Location
- Backup: `.claude/context/archive/context-{timestamp}.md`
- Reference: If needed, consult archive for detailed history

## Verification Checklist
- [ ] All critical info preserved
- [ ] No important decisions lost
- [ ] Next steps clear
- [ ] Context coherent and readable
- [ ] File size < 15KB

## Notes
[Any special notes about this compaction]
```

### Common Compaction Patterns

**Pattern 1: Multi-Phase Project (다단계 프로젝트)**

```markdown
원본:
## Phase 1: Design & Planning
[상세 디자인 과정 - 10KB]

## Phase 2: Core Implementation
[상세 구현 과정 - 15KB]

## Phase 3: Testing & Refinement
[테스트 과정 및 결과 - 12KB]

## Phase 4: Deployment
[배포 준비 - 5KB]

↓ COMPACT ↓

압축 후:
## Completed Phases (1-3)
- Phase 1 (Design): Completed
- Phase 2 (Core): 50 unit tests passing
- Phase 3 (Testing): All issues resolved

## Current Phase (4)
### Deployment Status
- Pre-checks: Passed
- Next: Run deployment script

### Remaining Tasks
- [ ] Execute deployment
- [ ] Verify in production
- [ ] Monitor metrics
```

**Pattern 2: Long Debugging Session (장기 디버깅)**

```markdown
원본:
## Debugging Process
### Attempt 1: Hook approach
...details... (3KB)

### Attempt 2: Middleware approach
...details... (4KB)

### Attempt 3: Direct injection
...details... (5KB)

... Total: 15KB of attempts ...

↓ COMPACT ↓

압축 후:
## Implementation Decision
- Selected: Direct injection approach
- Why: Cleanest separation of concerns
- Why not: Hook approach had race conditions
- Why not: Middleware added 3 levels of indirection

## Result
- Code location: src/core/injector.ts
- Tests: 8/8 passing
- Performance: < 2ms overhead
```

**Pattern 3: Context Switch (컨텍스트 전환)**

```markdown
원본:
## Project A: Feature X Implementation
[모든 상세 정보 - 25KB]

↓ COMPACT ↓

압축 후:
## Archived: Project A
- Status: Feature X complete
- Location: .claude/context/archive/project-a-{date}.md
- Reference: Consult if Project A work resumes

## Current: Project B
[New work context - 10KB]
```

---

## Code Snippets: Manual Compact

### Bash Script for Backup & Compact

```bash
#!/bin/bash
# compact-context.sh - Context compaction helper

CONTEXT_FILE=".claude/context.md"
ARCHIVE_DIR=".claude/context/archive"

# Step 1: Ensure archive directory exists
mkdir -p "$ARCHIVE_DIR"

# Step 2: Create timestamped backup
BACKUP_FILE="$ARCHIVE_DIR/context-$(date +%Y%m%d-%H%M%S).md"
cp "$CONTEXT_FILE" "$BACKUP_FILE"
echo "✓ Backup created: $BACKUP_FILE"

# Step 3: Show statistics
echo ""
echo "=== Context Statistics ==="
echo "Original size:"
wc -c < "$CONTEXT_FILE" | awk '{print $1 " bytes"}'
echo "Sections:"
grep "^## " "$CONTEXT_FILE" | wc -l

echo ""
echo "Next steps:"
echo "1. Review and edit: vim $CONTEXT_FILE"
echo "2. Remove exploration context, keep execution context"
echo "3. After saving, verify:"
echo "   wc -c $CONTEXT_FILE"
echo ""
```

**실행 방법:**

```bash
# 스크립트 생성
cat > compact-context.sh << 'EOF'
[위의 bash script 내용]
EOF

# 실행 권한 부여
chmod +x compact-context.sh

# 실행
./compact-context.sh
```

### Python Script for Smart Compaction

```python
#!/usr/bin/env python3
"""
smart-compact.py - Intelligent context compaction analyzer
"""

import os
import re
from datetime import datetime

def analyze_context(filepath):
    """Analyze context file for compaction opportunities"""

    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Patterns to detect exploration context
    patterns = {
        'debugging': re.compile(r'(Debug|debug|attempt|try|failed|issue)\s*:', re.I),
        'process': re.compile(r'(Step \d+:|Process:|Procedure:)', re.I),
        'alternatives': re.compile(r'(Consider|alternative|instead|vs\.|compared to)', re.I),
        'historical': re.compile(r'(Previously|Before|Earlier|Initially)', re.I),
    }

    # Analyze each section
    sections = content.split('\n## ')
    results = []

    for section in sections:
        lines = section.split('\n')
        title = lines[0] if lines else "Unknown"

        score = 0
        for pattern_name, pattern in patterns.items():
            matches = len(pattern.findall(section))
            if matches > 3:  # If more than 3 matches
                score += 1

        if score > 0:
            results.append({
                'title': title,
                'compactability': min(score, 3),  # 1-3 scale
                'type': 'Exploration Context (Candidate for removal)',
                'size': len(section)
            })

    return results

if __name__ == '__main__':
    filepath = '.claude/context.md'

    if not os.path.exists(filepath):
        print(f"Error: {filepath} not found")
        exit(1)

    print("=== Context Compaction Analysis ===")
    print(f"File: {filepath}")
    print(f"Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()

    results = analyze_context(filepath)

    if results:
        print(f"Found {len(results)} section(s) for potential compaction:")
        print()
        for r in sorted(results, key=lambda x: x['compactability'], reverse=True):
            print(f"  [{r['type']}]")
            print(f"  Section: {r['title']}")
            print(f"  Size: {r['size']} bytes")
            print(f"  Priority: {'HIGH' if r['compactability'] >= 2 else 'MEDIUM'}")
            print()
    else:
        print("No exploration context detected. Context looks clean!")
```

**실행 방법:**

```bash
# 스크립트 저장
cat > smart-compact.py << 'EOF'
[위의 python script 내용]
EOF

# 실행
python3 smart-compact.py

# 출력 예:
# Found 3 section(s) for potential compaction:
#
#   [Exploration Context (Candidate for removal)]
#   Section: Debugging Process
#   Size: 5234 bytes
#   Priority: HIGH
```

### Interactive Compact Decision Helper

```bash
#!/bin/bash
# interactive-compact.sh - Decision helper for manual compaction

compact_section() {
    local section_name="$1"

    echo "================================"
    echo "Compact: $section_name"
    echo "================================"
    echo ""
    echo "Is this section about:"
    echo "1. Current/future work? → KEEP"
    echo "2. Past processes/exploration? → CONSIDER REMOVING"
    echo "3. Reference information? → ARCHIVE"
    echo ""
    read -p "Your choice (keep/remove/archive): " choice

    case $choice in
        keep) echo "✓ KEEP: $section_name" ;;
        remove) echo "✗ REMOVE: $section_name (can restore from backup)" ;;
        archive) echo "→ ARCHIVE: $section_name" ;;
        *) echo "? SKIP: $section_name (review manually)" ;;
    esac
}

# Main
echo "Context Compaction Decision Helper"
echo "==================================="
echo ""
echo "This will help you decide what to keep/remove/archive"
echo ""

# Extract section names
sections=$(grep "^## " .claude/context.md | sed 's/^## //')

for section in $sections; do
    compact_section "$section"
    echo ""
done

echo "Next steps:"
echo "1. Review backup: ls -lh .claude/context/archive/"
echo "2. Edit context: vim .claude/context.md"
echo "3. Verify size: wc -c .claude/context.md"
```

---

## Summary & Best Practices

### Context Compacting Checklist

```
준비 단계 (Preparation):
□ 현재 context 파일 크기 확인
□ 백업 생성: .claude/context/archive/
□ Execution context 리스트 작성
□ 아카이브할 정보 결정

실행 단계 (Execution):
□ 탐색 컨텍스트 식별
□ 섹션별로 필요성 판단
□ 제거 또는 축약 실행
□ 중요 정보 손실 확인 (검증)

완료 단계 (Completion):
□ 새 파일 크기 확인 (<15KB 권장)
□ 모든 핵심 정보 존재 확인
□ 새 작업 진행 가능성 확인
□ 압축 기록 남기기 (Optional)
```

### Key Principles

```
1. Execution Context First (실행 컨텍스트 우선)
   - 현재 및 다음 작업에 필수적인 정보 먼저 결정

2. Archive, Don't Delete (삭제 아닌 아카이브)
   - 완전 삭제보다는 backup 생성 후 진행
   - 나중에 참고 필요할 수 있음

3. Preserve Decision Rationale (결정 근거 유지)
   - "무엇을 했는가" 아닌 "왜 그렇게 했는가"
   - 상세 과정은 필요 없고 선택 이유는 필요

4. Clarity Over Detail (명확함이 상세함을 이김)
   - 5줄의 명확한 요약 > 50줄의 상세 기록
   - 다음 작업 재개 시 집중력 향상

5. Monitor Regularly (정기적 모니터링)
   - 매 세션마다 context 크기 확인
   - 40KB 도달 전에 미리 compact
```

### Recommended Timing

```
언제 Compact 할 것인가:

✓ 명확한 시점:
├─ Phase/Milestone 완료 직후
├─ 장기 작업(6시간+) 중 피로 느낄 때
├─ 완전히 다른 프로젝트로 전환 시
└─ Context 파일이 40KB 이상 시

△ 고려할 시점:
├─ 새로운 팀원이 합류할 때 (깔끔한 context 제공)
├─ 중요한 회의/데모 전 (명확한 상태 정리)
└─ 주/월 단위 정기 review

✗ 피해야 할 시점:
├─ 매우 중요한 결정을 방금 한 직후 (결정 근거 아직 생생)
├─ 진행 중인 복잡한 작업 (중단 효율 떨어짐)
└─ 급할 때 (실수로 중요 정보 삭제 위험)
```

---

## Related Documentation

- [Session Storage](./01-session-storage.md) - 세션 저장소 기본
- [Strategic Compact Skill](./03-strategic-compact-skill.md) - 자동 compact 스킬
- [Dynamic System Prompt Injection](./04-dynamic-system-prompt-injection.md) - Prompt 최적화
- [Context & Memory Management README](./README.md) - 전체 개요

---

**작성**: claude-automate documentation team
**마지막 수정**: 2026-01-25
**상태**: 문서 완성

