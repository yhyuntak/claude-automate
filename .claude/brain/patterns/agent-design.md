# Agent Design Pattern

> 에이전트 작성 시 따르는 구조와 규칙

---

## 언제 사용

- 새 에이전트 생성 시
- 기존 에이전트 수정 시
- 에이전트 책임 분리 시

---

## 파일 위치

```
agents/{agent-name}.md
agents/{agent-name}-high.md  # Tier 분리 시
agents/{agent-name}-low.md   # Tier 분리 시
```

---

## 구조 (필수 요소)

```markdown
---
name: {agent-name}
description: {한 줄 설명}
model: {haiku | sonnet | opus}
---

# 역할 설명

## Mission
{이 에이전트가 하는 일}

## Input
{Main Claude로부터 받는 입력 형식}

## Workflow
{단계별 작업 방식}

## Output Format
{결과 반환 형식}

## Escalation (선택)
{상위 Tier로 넘기는 조건}

## Constraints
{제약 조건}
```

---

## 예시 코드

### explore.md (Standard Tier)

```markdown
---
name: explore
description: Codebase exploration and structure understanding for planning
model: sonnet
---

You are an Explore Agent. Your job: understand codebase structure, find relevant code, map relationships.

## Mission

1. Navigate and understand codebase structure
2. Find code related to a specific topic/feature
3. Map dependencies and relationships
4. Identify existing patterns to follow

## Input

Main Claude passes exploration request:

\`\`\`
## Target
{What to explore - feature area, module, file}

## Goal
{What information to find}

## Depth
{Surface-level | Standard | Deep dive}
\`\`\`

## Output Format

\`\`\`xml
<exploration_result>
<summary>
## Summary
{Brief overview of findings}
</summary>

<structure>
## Structure
{Directory/file tree relevant to target}
</structure>

<patterns>
## Existing Patterns
- {Pattern 1}: {description and example location}
</patterns>

<recommendations>
## Recommendations
- Where new code should live: {location}
- Patterns to follow: {pattern names}
</recommendations>
</exploration_result>
\`\`\`

## Escalation

Escalate to `explore-high` when:
- Complex architectural relationships
- Cross-module dependencies unclear
- Multiple conflicting patterns found

## Constraints

- **Read-only**: Exploration only, no modifications
- **Focused**: Stay within scope of request
- **Evidence-based**: Cite specific file locations
```

---

## 따라야 할 것

1. **YAML Frontmatter 필수**: name, description, model
2. **model 선택 기준**:
   - `haiku`: 단순 수집, 패턴 매칭
   - `sonnet`: 분석, 표준 작업 (기본값)
   - `opus`: 복잡한 판단, 창의적 작업
3. **Input/Output 명확히**: 다른 에이전트와의 인터페이스
4. **Escalation 조건**: 상위 Tier 필요 시 명시
5. **Constraints**: 에이전트 행동 제한

---

## 피해야 할 것

- 너무 넓은 책임 (God Agent)
- 모호한 Input/Output
- Tier 불일치 (복잡한 작업에 haiku)
- 중복 기능 (기존 에이전트와 겹침)

---

## 실제 구현 참고

- `agents/explore.md` - 탐색 에이전트
- `agents/pattern-checker.md` - 패턴 검증 에이전트
- `agents/writer.md` - 코드 작성 에이전트

---

**Last Updated**: 2026-02-03
