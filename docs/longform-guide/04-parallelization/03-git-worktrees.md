# Git Worktrees for Parallel Development (Git Worktree를 이용한 병렬 개발)

## 핵심 개념 (Core Concept)

**Git Worktree**는 하나의 Git 리포지토리에서 **여러 개의 작업 디렉토리(working directory)**를 동시에 유지할 수 있게 해주는 강력한 기능입니다. 각 worktree는 **다른 브랜치에서 독립적으로 작업**할 수 있으면서도 같은 Git 리포지토리를 공유합니다.

### Why Git Worktrees Matter (왜 중요한가?)

기존 방식에서는:
- 브랜치 전환 시 **매번 checkout으로 파일이 변경**됨
- 두 개의 서로 다른 작업을 병렬로 진행하려면 **클론을 여러 개 생성**해야 함
- 클론 여러 개 = **디스크 낭비, Git 메타데이터 중복**

**Git Worktree 사용 시:**
- 각 worktree는 **독립적인 디렉토리** (파일 변경 없음)
- **Git 메타데이터는 공유** (디스크 절약)
- **병렬 개발**이 매끄럽고 빠름
- **Claude 인스턴스를 각 worktree에 배정** 가능

---

## 클이 솔스 (Git Worktree 생성 및 관리)

### 기본 명령어 (Basic Commands)

#### 1. 새 worktree 생성

```bash
# 1. 새로운 worktree 생성 (새 브랜치 포함)
git worktree add ../feature-auth -b feature/auth-system main

# 설명:
# ../feature-auth      : worktree 디렉토리 경로 (프로젝트 외부 권장)
# -b feature/auth-system : 새 브랜치명 (자동으로 main에서 파생)
# main                 : 브랜치가 파생될 기반 브랜치
```

```bash
# 2. 기존 브랜치에서 worktree 생성
git worktree add ../bugfix-cache origin/bugfix/cache-leak

# 설명:
# origin/bugfix/cache-leak : 원격 브랜치에서 checkout
```

```bash
# 3. detached HEAD 상태의 worktree 생성 (특정 커밋)
git worktree add ../debug-commit --detach HEAD~5

# 설명:
# --detach : HEAD가 특정 커밋을 가리킴 (브랜치 아님)
# HEAD~5   : 5개 커밋 전의 상태로 디버깅 가능
```

#### 2. Worktree 목록 확인

```bash
# 현재 프로젝트의 모든 worktree 보기
git worktree list

# 출력 예시:
# /Users/yoohyuntak/workspace/claude-automate                  (bare)
# /Users/yoohyuntak/workspace/feature-auth                     1a2b3c4 [feature/auth-system]
# /Users/yoohyuntak/workspace/bugfix-cache                     5d6e7f8 [bugfix/cache-leak]
```

```bash
# 자세한 정보 포함
git worktree list --verbose

# 출력 예시:
# /path/to/main                         abc1234 [main] (detached HEAD)
# /path/to/feature-auth                 def5678 [feature/auth-system]
# /path/to/bugfix-cache                 ghi9012 [bugfix/cache-leak]
```

#### 3. Worktree 정리

```bash
# worktree 제거 (브랜치도 함께 삭제)
git worktree remove ../feature-auth

# 또는
cd ../feature-auth
git worktree remove --force /path/to/feature-auth
```

```bash
# 잠금 정보 보기 (worktree가 잠긴 경우)
git worktree lock ../feature-auth

# 잠금 해제
git worktree unlock ../feature-auth
```

---

## 실전 워크플로우 (Practical Workflow)

### 프로젝트 구조 설정

```bash
# 프로젝트 루트 구조 (권장)
.
├── main/                          # Main worktree (기본 작업 디렉토리)
│   ├── src/
│   ├── docs/
│   └── README.md
├── feature-auth/                  # Feature 1 worktree
│   ├── src/
│   └── docs/
├── bugfix-cache/                  # Bug fix worktree
│   ├── src/
│   └── docs/
└── feature-dashboard/             # Feature 2 worktree
    ├── src/
    └── docs/
```

### 초기 설정 스크립트

```bash
#!/bin/bash
# setup-worktrees.sh

PROJECT_NAME="claude-automate"
MAIN_DIR=$(pwd)
PARENT_DIR=$(dirname "$MAIN_DIR")

# Worktree 생성 함수
create_worktree() {
    local name=$1
    local branch=$2
    local base=${3:-main}

    echo "Creating worktree: $name from $base..."
    git worktree add "../$name" -b "$branch" "$base"
    echo "✓ Created: $PARENT_DIR/$name"
}

# 1. Main worktree 생성 (첫 번째 클론일 때만)
# git clone ... claude-automate
# cd claude-automate

# 2. 여러 feature worktree 생성
create_worktree "feature-auth" "feature/auth-system" "main"
create_worktree "feature-dashboard" "feature/dashboard-ui" "main"
create_worktree "bugfix-cache" "bugfix/cache-leak" "main"

# 3. 설정 확인
echo ""
echo "Worktree structure created:"
git worktree list
```

### 다중 Claude 인스턴스 배정

Claude 개발 시, **각 worktree마다 별도의 Claude 인스턴스를 배정**하면:
- 각 작업에 **독립적인 context window** 할당 가능
- **토큰 사용이 격리** (한 작업이 다른 작업에 영향 없음)
- **병렬 처리** 최적화

#### 권장 구조

```bash
# Worktree별 설정 파일 (각 디렉토리마다)
feature-auth/.claude/CLAUDE.md        # Feature 1의 프롬프트
bugfix-cache/.claude/CLAUDE.md        # Bug fix의 프롬프트
feature-dashboard/.claude/CLAUDE.md   # Feature 2의 프롬프트

# 각 파일에 task-specific 지시 포함
```

#### 예시: Feature Branch 설정

```bash
# feature-auth 워크트리로 이동
cd ../feature-auth

# 해당 worktree의 Claude 설정 생성
mkdir -p .claude
cat > .claude/CLAUDE.md << 'EOF'
# Feature: Authentication System

## Context
Working on JWT-based authentication implementation.

## Scope
- Token generation and validation
- Auth middleware setup
- Refresh token mechanism
- Integration tests

## DO NOT
- Touch database schema (handled separately)
- Modify frontend code (feature-dashboard team)
- Change cache implementation (bugfix-cache team)

## FILES TO FOCUS ON
- src/auth/*
- src/middleware/auth.ts
- tests/auth/*.test.ts

## KNOWN BLOCKERS
- Security review pending (expected Jan 27)
EOF

# 이제 이 worktree에서 Claude와 작업
# Claude는 주로 src/auth/와 tests/auth/ 에만 집중
```

---

## 4가지 주요 장점 (4 Key Advantages)

### 1. Git Conflicts 제거 (No Git Conflicts)

**문제점 (Before):**
```bash
# 같은 파일을 여러 브랜치에서 편집하고 checkout
git checkout feature/auth        # auth.ts 변경
# ... 작업 ...
git checkout feature/dashboard   # 같은 auth.ts 편집
# ... 작업 ...
git checkout main                # merge 시 conflict!
```

**해결책 (After with Worktrees):**
```bash
# 각 worktree에서 독립적으로 작업
cd feature-auth/
# src/auth.ts 편집... (feature-auth 브랜치)

cd ../feature-dashboard/
# src/auth.ts 편집... (feature-dashboard 브랜치)

# No checkout = No merge conflicts 발생 가능성 감소
```

**왜 효과가 있는가?**
- 각 worktree는 **완전히 독립적인 파일 시스템**
- Git의 index.lock이나 상태 충돌 **없음**
- 브랜치 간 동시 편집 **안전함**

### 2. 깨끗한 워킹 디렉토리 (Clean Working Directory)

**문제점 (Before):**
```bash
# Feature A 작업 중
git status
# On branch feature/auth
# modified:   src/auth.ts
# modified:   src/cache.ts
# modified:   src/api.ts
#
# → 정말 어떤 파일이 현재 작업인지 불명확

# 브랜치 전환 시 untracked files, unstaged changes 문제
git checkout feature/dashboard
# error: Your local changes to 'src/api.ts' would be overwritten by checkout
```

**해결책 (After):**
```bash
# feature-auth worktree
cd feature-auth/
git status
# On branch feature/auth-system
# modified:   src/auth.ts
#
# → 명확: 인증 기능만 작업 중

# feature-dashboard worktree (동시에)
cd ../feature-dashboard/
git status
# On branch feature/dashboard-ui
# modified:   src/components/Dashboard.tsx
#
# → 각 worktree는 자신의 브랜치만 깨끗하게 관리
```

**왜 효과가 있는가?**
- **각 worktree = 각 브랜치의 깨끗한 상태**
- stash, uncommitted changes 없음
- `git status`가 정확함

### 3. 출력 비교 용이함 (Easy Output Comparison)

**시나리오:**
두 개의 다른 구현을 성능으로 비교하고 싶을 때:

```bash
# Worktree 1: 현재 구현 (with caching)
cd feature-auth/
npm run benchmark

# Output A:
# Token Generation: 5.2ms
# Token Validation: 1.1ms
# Total Time: 6.3ms

# Worktree 2: 새로운 구현 (without caching)
cd ../bugfix-cache/
npm run benchmark

# Output B:
# Token Generation: 8.7ms
# Token Validation: 3.2ms
# Total Time: 11.9ms

# → 쉽게 비교 가능!
```

**실제 사용 사례:**

```bash
#!/bin/bash
# compare-implementations.sh

echo "=== Implementation Comparison ==="
echo ""

echo "Current implementation (feature-auth):"
cd ../feature-auth/
npm run benchmark 2>/dev/null | grep "Total Time"

echo ""
echo "New implementation (bugfix-cache):"
cd ../bugfix-cache/
npm run benchmark 2>/dev/null | grep "Total Time"

echo ""
echo "Recommendation: Choose based on performance needs"
```

**왜 효과가 있는가?**
- **동시 실행 가능**: 두 worktree에서 테스트를 동시에 실행 가능
- **Side-by-side 비교**: 터미널 창 2개만 열면 됨
- **재현 가능**: 정확히 같은 상태에서 비교

### 4. 다양한 접근 방식 벤치마킹 (Benchmark Different Approaches)

**복잡한 기능을 구현할 때:**

```bash
# Approach 1: Monolithic service
git worktree add ../approach-monolith -b approaches/auth-monolith main

# Approach 2: Microservice architecture
git worktree add ../approach-microservice -b approaches/auth-microservice main

# Approach 3: Hybrid approach
git worktree add ../approach-hybrid -b approaches/auth-hybrid main
```

**각 접근 방식을 독립적으로 구현:**

```bash
# Approach 1: Monolith (단순하지만 확장성 부족)
cd ../approach-monolith/
# 구현...
npm run test:performance
# Memory usage: 150MB
# Response time: 45ms

# Approach 2: Microservice (복잡하지만 확장성 좋음)
cd ../approach-microservice/
# 구현...
npm run test:performance
# Memory usage: 320MB
# Response time: 120ms (네트워크 오버헤드)

# Approach 3: Hybrid (균형)
cd ../approach-hybrid/
# 구현...
npm run test:performance
# Memory usage: 210MB
# Response time: 65ms
```

**비교 스크립트:**

```bash
#!/bin/bash
# benchmark-all-approaches.sh

echo "Benchmarking all approaches..."
echo ""

approaches=("monolith" "microservice" "hybrid")
metrics=()

for approach in "${approaches[@]}"; do
    echo "Testing approach: $approach"
    cd "../approach-$approach"

    memory=$(npm run test:memory 2>/dev/null | grep "Memory" | awk '{print $NF}')
    latency=$(npm run test:latency 2>/dev/null | grep "Response" | awk '{print $NF}')

    echo "  Memory: $memory"
    echo "  Latency: $latency"
    echo ""
done

echo "Analysis:"
echo "- Monolith: Simplest but least scalable"
echo "- Microservice: Most complex but best scalability"
echo "- Hybrid: Best balance for this project"
```

**왜 효과가 있는가?**
- **동시 개발**: 3가지 접근을 **병렬로 구현**
- **공정한 비교**: **정확히 같은 환경**에서 테스트
- **빠른 의사결정**: 수 시간 안에 베스트 접근법 선택

---

## 실제 사용 예시 (Real-World Examples)

### Example 1: 동시 feature 개발

```bash
# 프로젝트 구조
project/
├── main/                          # Main branch (stable)
├── feature-auth/                  # Team A: Authentication
├── feature-payments/              # Team B: Payment system
└── feature-notifications/         # Team C: Notifications

# 각 팀이 독립적으로 작업
# Team A
cd feature-auth/
git commit -am "Implement JWT token generation"

# Team B (동시에)
cd ../feature-payments/
git commit -am "Integrate Stripe API"

# Team C (동시에)
cd ../feature-notifications/
git commit -am "Setup email service"

# 모두 완료 후 main으로 merge
cd ../main/
git merge ../feature-auth/
git merge ../feature-payments/
git merge ../feature-notifications/
```

### Example 2: Bug fix와 feature 동시 진행

```bash
# 상황: 프로덕션 버그 발생하면서 새 feature 개발 중

# 기존: feature 작업 중단 → checkout main → bugfix → checkout back
# 문제: 지금까지의 변경사항을 stash해야 함 (번거로움)

# Git worktree 사용:
# feature-auth worktree에서 계속 작업
cd feature-auth/
npm run dev  # 개발 서버 실행 중

# 다른 터미널에서 버그 fix
cd ../bugfix-production/
git log --oneline | head -5  # 버그 찾기
# 버그 fix...
git commit -am "Fix critical cache bug"

# feature-auth는 계속 실행 중 (영향 없음!)
# → 버그 fix와 feature 개발이 완전히 독립적
```

### Example 3: 리뷰와 개발의 병렬화

```bash
# 상황: PR 리뷰 대기 중에 다음 기능 시작

# PR 1: Authentication (리뷰 대기 중)
cd feature-auth/
# (이미 모든 커밋 완료, 리뷰 대기)

# PR 2: Dashboard (새로 시작)
cd ../feature-dashboard/
git commit -am "Initial dashboard layout"

# 동시에 두 PR 관리 가능!
# feature-auth는 리뷰어의 요청을 기다리는 동안
# feature-dashboard는 계속 개발 진행
```

### Example 4: Release branch와 hotfix의 병렬 작업

```bash
# Git Flow 패턴에서의 worktree 활용

# Main branch (production)
cd main/

# Release 준비
git worktree add ../release-1.2.0 -b release/1.2.0 main
cd ../release-1.2.0/
# Version 업데이트, CHANGELOG 작성
npm version minor

# 동시에 다음 feature 개발 (main 기반)
git worktree add ../develop -b develop main
cd ../develop/
# 새로운 feature 구현

# Production 긴급 버그 발견 (hotfix)
git worktree add ../hotfix-critical -b hotfix/critical-bug main
cd ../hotfix-critical/
# 버그 fix...
git commit -am "Fix critical bug"

# 3가지 작업이 독립적으로 진행:
# 1. release/1.2.0: 버전 준비
# 2. develop: 다음 feature 개발
# 3. hotfix/critical-bug: 긴급 버그 수정
```

---

## 심화 주제 (Advanced Topics)

### Worktree 간 코드 공유 (Sharing Code Between Worktrees)

```bash
# 문제: feature-auth에서 구현한 유틸리티를 feature-dashboard에서도 사용하고 싶음

# 해결책 1: 같은 main에서 파생 (권장)
# 둘 다 main의 최신 코드 기반
# 유틸리티가 main에 merge되면 자동으로 사용 가능

# 해결책 2: 명시적 cherry-pick
cd feature-dashboard/
git cherry-pick abc1234  # feature-auth의 유틸리티 커밋

# 해결책 3: 패키지로 분리 (고급)
# shared-utils/ 패키지를 monorepo로 관리
# 모든 worktree에서 동일 버전 사용
```

### Worktree 정리 및 유지보수 (Cleanup & Maintenance)

```bash
# 완료된 worktree 제거
git worktree remove feature-auth
# 또는
git worktree remove --force ../feature-auth

# 손상된 worktree 복구
git worktree repair

# 전체 worktree 상태 확인
git worktree list --porcelain
```

### CI/CD와 Worktree 통합

```bash
#!/bin/bash
# Test all active worktrees

for worktree in $(git worktree list --porcelain | awk '{print $1}'); do
    echo "Testing worktree: $worktree"
    cd "$worktree"
    npm test || exit 1
done

echo "All worktrees passed tests!"
```

---

## 모범 사례 (Best Practices)

### DO: 권장 사항

```bash
✓ 각 worktree는 한 가지 기능/버그에만 집중
✓ worktree 이름은 브랜치 이름과 같게
✓ 작업 완료 후 worktree 제거
✓ main worktree는 항상 stable 상태 유지
✓ 각 worktree에서 자주 commit (브랜치 전환 필요 없음)
```

### DON'T: 피해야 할 것들

```bash
✗ 같은 브랜치의 worktree를 여러 개 만들기
✗ worktree를 정크 폴더로 사용 (완료 후 정리)
✗ main worktree를 feature 개발에 사용
✗ 너무 많은 worktree 보유 (3-5개 권장)
✗ worktree 간에 파일 복사하기 (git merge/cherry-pick 사용)
```

---

## 빠른 참조 (Quick Reference)

| 작업 | 명령어 |
|------|--------|
| 새 worktree 생성 | `git worktree add ../name -b branch main` |
| Worktree 목록 | `git worktree list` |
| Worktree 제거 | `git worktree remove ../name` |
| Worktree 정보 | `git worktree list --verbose` |
| 잠금 | `git worktree lock ../name` |
| 잠금 해제 | `git worktree unlock ../name` |
| 모든 worktree 복구 | `git worktree repair` |

---

## 다음 단계 (Next Steps)

Git Worktree를 마스터했다면:

1. **[Subagent Orchestration](../02-parallelization/01-subagent-orchestration.md)** - 에이전트 병렬화 심화
2. **[Parallel Task Execution](../02-parallelization/02-parallel-tasks.md)** - 병렬 작업 실행 패턴
3. **[CI/CD Integration](../../advanced-topics/cicd-integration.md)** - 자동화 파이프라인 구축

---

## 관련 문서

- [Parallelization Overview](./README.md) - 병렬화 개요
- [Token Optimization](../02-token-optimization/README.md) - 토큰 최적화
- [Agent Best Practices](../06-agent-best-practices/README.md) - 에이전트 설계

---

**작성자**: claude-automate 문서팀
**마지막 수정**: 2026년 1월
**상태**: 작성 완료
**원본 출처**: Git Worktree 공식 문서 및 실제 프로젝트 경험
