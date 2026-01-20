# /wrap 시스템 개선 계획 v2

> Momus 리뷰 반영 + 사용자 논의 결과

## 1. 개요

### 문제
현재 `/wrap` 명령의 핵심 문제:

| 에이전트 | 문제 | 증상 |
|----------|------|------|
| `usage-analyzer` | 과잉 제안 | 한 번 사용한 것도 스킬로 제안 |
| `result-integrator` | 억지 생성 | 평범한 세션에서도 무조건 뭔가를 출력 |

### 근본 원인
- **단일 세션 분석의 한계**: 현재 wrap은 현재 세션만 분석
- **"출력 강제" 암묵적 가정**: 빈 결과를 허용하지 않음

### 목표
1. **임계값 도입**: 최근 10세션 중 3회 이상 반복 시에만 "진짜 패턴"으로 인정
2. **빈 결과 허용**: "특별한 거 없음" 반환 가능
3. **피드백 수집**: 사용자 선택 로깅 (MVP)

### 제거 결정
- **`til-extractor.md`**: 완전 제거 (TIL 판단이 주관적이라 자동화 어려움)

---

## 2. 작업 목록 (ROI 기준 우선순위)

### Phase 1: 빠른 승리 (간단한 수정, 높은 효과)
- [x] **1.1** `usage-analyzer.md` - 임계값 상향 (최근 10세션 중 3회+) ✅
- [x] **1.2** `result-integrator.md` - 빈 결과 허용 ✅

### Phase 2: TIL 제거
- [x] **2.1** `til-extractor.md` 제거 ✅
- [x] **2.2** `wrap.md`에서 til-extractor 호출 제거 ✅

### Phase 3: 멀티 세션 분석
- [x] **3.1** `session-reader.md` - 최근 10세션 읽기 기능 추가 ✅
- [x] **3.2** `usage-analyzer.md` - 멀티 세션 데이터 활용 (1.1에서 완료) ✅

### Phase 4: 피드백 MVP
- [x] **4.1** 피드백 저장 구조 (`~/.claude/feedback/`) ✅
- [x] **4.2** 선택/거부 로깅 구현 (result-integrator.md에 통합) ✅

### Phase 5: 통합 및 검증
- [x] **5.1** `wrap.md` 명령 업데이트 ✅
- [ ] **5.2** 실제 세션으로 테스트 (수동 필요)

---

## 3. 각 작업별 상세

### 1.1 usage-analyzer.md - 임계값 상향

**현재 문제:**
- 단일 세션에서 한 번 사용한 것도 스킬 제안
- 임계값 없음

**변경 내용:**

```markdown
## CRITICAL: Pattern Detection Threshold

### Minimum Threshold for Suggestion
| 항목 | 최소 기준 |
|------|----------|
| 스킬 제안 | 최근 10세션 중 3회 이상 반복 |
| 워크플로우 제안 | 최근 10세션 중 3회 이상 동일 패턴 |

### What is NOT a Pattern
- 단일 세션에서의 일회성 사용
- 최근 10세션 중 2회 이하 반복
- 프로젝트 특정 일회성 작업

## Output Format (변경)

<usage_analysis>
<pattern_validity>
- Sessions analyzed: [count]
- Threshold: 3+ occurrences in last 10 sessions
</pattern_validity>

<!-- 임계값 미달 시 -->
<no_significant_patterns>
현재 세션에서 유의미한 자동화 패턴이 발견되지 않았습니다.
충분한 반복 데이터가 축적되면 다시 분석합니다.
</no_significant_patterns>
</usage_analysis>
```

**핵심 로직 (pseudocode):**

```python
def should_suggest_skill(pattern, session_history):
    if not session_history:
        return False  # 단일 세션만으로는 제안 안 함

    # 최근 10세션에서 몇 번 나왔는지
    count = session_history.count_pattern(pattern, max_sessions=10)

    return count >= 3

def analyze(session_data, session_history=None):
    suggestions = []

    for pattern in detected_patterns:
        if should_suggest_skill(pattern, session_history):
            suggestions.append(create_suggestion(pattern))

    if not suggestions:
        return NO_SIGNIFICANT_PATTERNS

    return suggestions
```

---

### 1.2 result-integrator.md - 빈 결과 허용

**현재 문제:**
- 항상 무언가를 출력해야 한다는 암묵적 가정

**변경 내용:**

```markdown
## CRITICAL: Empty Result Handling

### When All Agents Return Empty
모든 분석 에이전트가 유의미한 결과를 반환하지 않으면:

<wrap_summary>
## Session Analysis Complete

이번 세션은 특별히 기록하거나 자동화할 내용이 없습니다.
평범한 작업 세션이었습니다.

---
*다음 세션에서 패턴이 축적되면 다시 분석합니다.*
</wrap_summary>

### Mixed Results
일부만 결과가 있으면 해당 항목만 표시 (없는 항목은 언급하지 않음)
```

---

### 2.1-2.2 TIL 제거

**작업:**
1. `agents/til-extractor.md` 파일 삭제
2. `commands/wrap.md`에서 til-extractor 호출 부분 제거

---

### 3.1 session-reader.md - 최근 10세션 읽기

**Claude Code 세션 데이터 위치 (확인됨):**
```
~/.claude/projects/{encoded-project-path}/
├── sessions-index.json     # 세션 목록
└── {session-id}.jsonl      # 세션별 대화
```

**sessions-index.json 구조:**
```json
{
  "entries": [
    {
      "sessionId": "abc123",
      "firstPrompt": "...",
      "messageCount": 17,
      "created": "2026-01-19T13:36:12.789Z"
    }
  ]
}
```

**변경 내용:**

```markdown
## Multi-Session Mode (새 기능)

프롬프트에 `--history` 포함 시:

1. `~/.claude/projects/{project}/sessions-index.json` 읽기
2. 최근 10개 세션 필터링
3. 각 세션의 `.jsonl` 파일에서 사용자 프롬프트 추출

## Output Format (Multi-Session)

<session_history>
<summary>
- Sessions analyzed: 10
- Date range: [start] ~ [end]
</summary>

<aggregated_data>
- Prompt frequency: {pattern: count}
- Agent usage: {agent: count}
</aggregated_data>
</session_history>
```

**핵심 로직 (pseudocode):**

```python
def read_recent_sessions(max_sessions=10):
    project_path = get_current_project_encoded_path()
    index_file = f"~/.claude/projects/{project_path}/sessions-index.json"

    sessions = parse_json(index_file)["entries"]
    recent = sorted(sessions, key=lambda s: s["created"], reverse=True)[:max_sessions]

    aggregated = {
        "prompt_patterns": Counter(),
        "agents_used": Counter()
    }

    for session in recent:
        jsonl_path = f"~/.claude/projects/{project_path}/{session['sessionId']}.jsonl"
        data = parse_jsonl(jsonl_path)

        for entry in data:
            if entry.get("type") == "user":
                pattern = extract_pattern(entry["message"]["content"])
                aggregated["prompt_patterns"][pattern] += 1

    return aggregated
```

**성능 고려:**
- 각 세션 .jsonl 파일이 600KB~3.6MB
- 최근 10개만 파싱하여 성능 제한

---

### 4.1-4.2 피드백 MVP

**위치:** `~/.claude/feedback/`

**MVP 범위:** 로깅만 (자기 개선 로직은 후속 버전)

**구조:**
```
~/.claude/feedback/
└── {project-encoded}/
    └── {date}.json
```

**피드백 형식:**
```json
{
  "session_id": "abc123",
  "timestamp": "2026-01-19T14:30:00Z",
  "suggestions": [
    {
      "type": "skill_suggestion",
      "content": "Create /debug-env skill",
      "approved": false
    }
  ]
}
```

---

## 4. 검증 방법

### 단계별 검증

| 단계 | 검증 방법 |
|------|----------|
| 1.1 usage-analyzer | 단일 세션 데이터로 실행 시 "없음" 반환 확인 |
| 1.2 result-integrator | 모든 에이전트 빈 결과 시 "특별한 거 없음" 출력 확인 |
| 2.x TIL 제거 | wrap 실행 시 TIL 섹션 없음 확인 |
| 3.x 멀티 세션 | `~/.claude/projects/` 데이터로 10세션 파싱 확인 |
| 4.x 피드백 | 제안 거부 후 `~/.claude/feedback/` 파일 생성 확인 |

### 성공 기준

- [ ] 평범한 세션에서 불필요한 제안이 나오지 않음
- [ ] 일회성 사용이 스킬 제안으로 나오지 않음
- [ ] "특별한 거 없음" 출력이 정상 동작
- [ ] 최근 10세션 중 3회+ 반복만 제안됨
- [ ] 피드백 데이터가 올바르게 저장됨

---

## 5. 변경 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|----------|
| v1 | 2026-01-20 | 초기 계획 (Prometheus) |
| v2 | 2026-01-20 | Momus 리뷰 반영: TIL 제거, 임계값 변경 (10세션/3회), 순서 변경 (ROI) |
| v3 | 2026-01-20 | **구현 완료**: 모든 에이전트 수정, til-extractor 삭제, wrap.md 업데이트 |

---

## 6. 구현 완료 요약

### 수정된 파일
| 파일 | 변경 내용 |
|------|----------|
| `agents/usage-analyzer.md` | 임계값 (10세션/3회), no_significant_patterns 출력, session_history 입력 |
| `agents/result-integrator.md` | 빈 결과 허용, Empty Check Phase 0, 피드백 MVP 로직 |
| `agents/session-reader.md` | 멀티세션 모드 (--history), sessions-index.json 파싱 |
| `commands/wrap.md` | til-extractor 제거, session_history 추가, 빈 결과 문서화 |

### 삭제된 파일
- `agents/til-extractor.md` (TIL 기능 제거)

### 핵심 변경 사항
1. **임계값**: 최근 10세션 중 3회 이상만 패턴으로 인정
2. **빈 결과**: "특별한 거 없음" 반환 가능
3. **TIL 제거**: 주관적 판단 문제로 완전 제거
4. **피드백 MVP**: `~/.claude/feedback/`에 선택/거부 로깅

---

*Generated by Prometheus + Momus Review + Ultrawork Implementation*
*Date: 2026-01-20*
