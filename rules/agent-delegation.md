# Agent Delegation Rules

> 컨텍스트 보호를 위한 에이전트 위임 규칙

---

## 왜 위임하는가?

메인 컨텍스트에서 직접 파일 읽기/쓰기 → 컨텍스트 오염
에이전트에게 위임 → 결과만 받아서 컨텍스트 깨끗하게 유지

---

## ⛔ 절대 원칙

### 1. 파일 읽기

| 상황 | 처리 방식 |
|------|----------|
| 처음 보는 파일 | `explore-*` 에이전트 **필수** |
| 이미 아는 파일 | 직접 Read 가능 |

### 2. 파일 쓰기

| 상황 | 처리 방식 |
|------|----------|
| 10줄 이상 변경 | `writer-*` 에이전트 **필수** |
| 10줄 미만 변경 | 직접 Edit 가능 |

### 3. 명령 실행

| 상황 | 처리 방식 |
|------|----------|
| 빌드/테스트/배포 | `Bash` 에이전트 **필수** |
| 단순 확인 (git status, ls) | 직접 가능 |

**이 원칙은 예외 없이 적용됩니다.**

---

## 파일 탐색/검색

| 상황 | 에이전트 | 예시 |
|------|----------|------|
| 단순 위치 찾기 | `explore-low` | "이 함수 어디있어?" |
| 구조/관계 파악 | `explore` | "이 모듈 구조 알려줘" |
| 아키텍처 분석 | `explore-high` | "전체 의존성 분석해줘" |

### 판단 기준

```
explore-low (Haiku):
- 특정 함수/클래스 위치 찾기
- 파일 존재 여부 확인
- 단순 grep 검색

explore (Sonnet):
- 모듈 구조 파악
- 파일 간 관계 분석
- 패턴 찾기

explore-high (Opus):
- 전체 아키텍처 분석
- 복잡한 의존성 그래프
- 리팩토링 영향도 분석
```

---

## 코드 작성/수정

| 상황 | 처리 방식 |
|------|----------|
| 짧은 수정 (10줄 이하) | 메인이 직접 |
| 중간 작업 (10-50줄) | `writer` 권장 |
| 큰 구현 (50줄+) | `writer` 필수 |
| 복잡한 구현 | `writer-high` 필수 |

### Writer 2-Tier 구조

| 복잡도 | 에이전트 | 기준 |
|--------|----------|------|
| Standard | `writer` (Sonnet) | 일반 코드, CRUD, 단순 로직 |
| High | `writer-high` (Opus) | 알고리즘, 보안, 아키텍처 |

### writer-high 사용 기준

```
writer-high (Opus):
- 복잡한 알고리즘 구현 (정렬, 탐색, DP, 그래프)
- 보안 관련 코드 (인증, 암호화, 권한)
- 아키텍처 패턴 적용 (Design Pattern 구현)
- 성능 최적화 코드
- 여러 파일에 걸친 대규모 리팩토링
```

### writer 사용 시

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
{뭘 할지}

## Target
{파일 경로}

## Requirements
{요구사항}

## Verification
{검증 방법 - build, test, lint}
"""
)
```

### writer-high 사용 시

```
Task(
  subagent_type="claude-automate:writer-high",
  prompt="""
## Task
{뭘 할지}

## Target
{파일 경로}

## Requirements
{요구사항}

## Complexity Reason
{왜 writer-high가 필요한지 - algorithm/security/architecture/performance/scale}

## Verification
{검증 방법 - build, test, lint, security check}
"""
)
```

---

## 예외 상황

### 직접 처리 가능 (절대 원칙 범위 내)

- 이미 아는 파일의 설정 수정 (1-2줄)
- 오타 수정
- 주석 추가
- 단순 상태 확인 명령 (git status, ls)

### 절대 위임 (예외 없음)

- 처음 보는 파일 탐색 → `explore-*`
- 10줄 이상 코드 변경 → `writer-*`
- 빌드/테스트/배포 → `Bash` 에이전트

---

## 병렬 실행

병렬 가능한 작업은 병렬로 실행한다.

- 탐색: 여러 위치/구조 확인 시 동시 호출
- 구현: 독립 파일은 동시 호출
- 티어: 기존 기준 따름, 에이전트가 상황에 맞게 판단

### 예시

```
# 병렬 탐색
Task(explore-low, "A 위치"), Task(explore-low, "B 위치")

# 병렬 구현
Task(writer, "A.py 수정"), Task(writer, "B.py 수정")
```

---

## 호출 예시

### 파일 찾기

```
Task(
  subagent_type="claude-automate:explore-low",
  prompt="UserService 클래스가 어디 정의되어 있는지 찾아줘"
)
```

### 구조 파악

```
Task(
  subagent_type="claude-automate:explore",
  prompt="""
## Target
src/auth/ 폴더

## Goal
인증 모듈의 구조와 파일 간 관계 파악

## Depth
Standard
"""
)
```

### 코드 작성

```
Task(
  subagent_type="claude-automate:writer",
  prompt="""
## Task
UserService에 logout 메서드 추가

## Target
src/services/UserService.ts

## Requirements
- 세션 무효화
- 로그 남기기

## Verification
npm run build && npm test
"""
)
```

---

**Last Updated**: 2026-02-06
