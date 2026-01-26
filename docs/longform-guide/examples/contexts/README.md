# Context Templates - Ready-to-Use System Prompts

> **즉시 사용 가능한 시스템 프롬프트 컨텍스트 파일**

**Context Files (컨텍스트 파일)**: Claude와 함께 일할 때 역할과 행동을 정의하는 **System Prompt** 템플릿들입니다.

각 파일은 완전히 작성되고 검증된 **프로덕션 레디(Production Ready)** 상태이며, 즉시 사용 가능합니다.

---

## 📁 Available Templates (사용 가능한 템플릿)

### 1. 개발 모드 (Development Mode) - `dev.md`

**사용하는 경우**: 새로운 기능 구현, 버그 수정, 코드 작성
**When to Use**: Implementing new features, fixing bugs, writing code

**특징**:
- Production-ready code 작성에 집중
- 철저한 테스트 요구
- 프로젝트 규칙 준수
- 코드 품질 유지

**포함 내용**:
- 개발자의 역할과 책임
- TypeScript 코드 표준
- 테스트 요구사항
- 반드시 따를 규칙 (Must-Follow Rules)
- 제출 전 체크리스트
- 피해야 할 것들

**사용 방법**:
```bash
# 시스템 프롬프트로 사용
claude --system-prompt @docs/longform-guide/examples/contexts/dev.md message "Implement feature X"

# Alias로 설정 (권장)
alias dev='claude --system-prompt @docs/longform-guide/examples/contexts/dev.md message'
dev "Implement feature X"
```

**분량**: 620 줄 | **읽기 시간**: 15-20분 | **난이도**: Intermediate

---

### 2. 코드 리뷰 모드 (Code Review Mode) - `review.md`

**사용하는 경우**: 코드 품질 검토, PR 검수, 버그 찾기
**When to Use**: Reviewing code quality, inspecting PRs, finding bugs

**특징**:
- Expert code reviewer 역할 수행
- 5가지 검토 관점 (기능성, 품질, 성능, 보안, 유지보수성)
- 구체적이고 건설적인 피드백
- 이슈, 제안, 칭찬 구분

**포함 내용**:
- 코드 리뷰어의 역할
- 5가지 검토 관점 (Dimensions)
- 리뷰 프로세스
- 피드백 형식 (Issues, Suggestions, Questions, Praise)
- 일반적인 이슈 및 심각도 표
- 리뷰 체크리스트
- 좋은 리뷰 작성 팁

**사용 방법**:
```bash
alias review='claude --system-prompt @docs/longform-guide/examples/contexts/review.md message'
review "Check this code for quality issues"
```

**분량**: 788 줄 | **읽기 시간**: 20-25분 | **난이도**: Intermediate

---

### 3. 조사/탐색 모드 (Research & Exploration Mode) - `research.md`

**사용하는 경우**: 심층 조사, 아키텍처 분석, 근본 원인 파악
**When to Use**: Deep investigation, architecture analysis, root cause analysis

**특징**:
- 시스템 분석가 (Systems Analyst) 역할
- 5W1H 조사 방법론
- 문제 중심 분석
- 증거 기반 결론

**포함 내용**:
- 조사 방법론 (5W1H)
- 분석 유형 (문제, 아키텍처, 성능, 설계)
- 조사 프로세스 (3단계)
- 분석 형식 및 템플릿
- 도움이 되는 질문들
- 효율적인 조사 팁

**사용 방법**:
```bash
alias research='claude --system-prompt @docs/longform-guide/examples/contexts/research.md message'
research "Analyze why this code is slow"
research "Review the architecture of this module"
```

**분량**: 887 줄 | **읽기 시간**: 25-30분 | **난이도**: Advanced

---

## 🚀 Quick Start (빠르게 시작하기)

### Step 1: 파일 위치 확인

```bash
# 파일들이 이 위치에 있습니다
/docs/longform-guide/examples/contexts/
├── dev.md          # 개발 모드
├── review.md       # 코드 리뷰 모드
├── research.md     # 조사/탐색 모드
└── README.md       # 이 파일
```

### Step 2: Shell Alias 설정

프로젝트 루트에서 `.zshrc` 또는 `.bashrc`에 추가:

```bash
# Context 파일의 절대 경로
PROJECT_ROOT="/Users/yoohyuntak/workspace/claude-automate"

# Alias 설정
alias dev="claude --system-prompt @${PROJECT_ROOT}/docs/longform-guide/examples/contexts/dev.md message"
alias review="claude --system-prompt @${PROJECT_ROOT}/docs/longform-guide/examples/contexts/review.md message"
alias research="claude --system-prompt @${PROJECT_ROOT}/docs/longform-guide/examples/contexts/research.md message"
```

또는 더 간단하게:

```bash
# 프로젝트 루트에 .claude/aliases.sh 파일 생성
source "${PROJECT_ROOT}/docs/longform-guide/examples/contexts/setup-aliases.sh"
```

### Step 3: 사용하기

```bash
# 개발 모드
dev "Implement the search feature"

# 코드 리뷰 모드
review "Check this code for issues"

# 조사 모드
research "Analyze the performance of this function"
research "What's the architecture of the auth module?"
```

---

## 📖 Understanding Each Mode (각 모드 이해하기)

### Development Mode (개발 모드)

```
목표: Production-ready 코드 작성
특징: 엄격한 표준, 철저한 테스트, 품질 중심
태도: "이 코드는 완벽한가?"
```

**좋은 사용 예**:
```bash
dev "Implement user authentication with JWT"
dev "Fix the N+1 query issue in the reports module"
dev "Add error handling to the API endpoint"
```

### Code Review Mode (코드 리뷰 모드)

```
목표: 코드 품질 보증
특징: 객관적 검토, 다차원 분석, 건설적 피드백
태도: "이 코드를 개선할 방법은?"
```

**좋은 사용 예**:
```bash
review "Is this error handling sufficient?"
review "Check for security vulnerabilities in this auth code"
review "Review the performance of this database query"
```

### Research Mode (조사 모드)

```
목표: 깊이 있는 이해와 분석
특징: 근본 원인 추적, 체계적 분석, 증거 기반
태도: "정말로 무엇이 문제인가?"
```

**좋은 사용 예**:
```bash
research "Why is this code slow? Find the root cause"
research "How is the session management architecture designed?"
research "Analyze the differences between approach A and approach B"
```

---

## ✅ Verification (검증)

각 파일은 다음을 충족합니다:

- ✅ **완전성 (Completeness)**: 모든 필요한 섹션 포함
- ✅ **명확성 (Clarity)**: 한국어 + 영어 병행
- ✅ **실용성 (Practicality)**: 즉시 사용 가능한 템플릿
- ✅ **구조화 (Structure)**: 명확한 목차와 네비게이션
- ✅ **예시 포함 (Examples)**: 코드 예시와 사용 예시
- ✅ **체크리스트 (Checklists)**: 실행 가능한 체크리스트

---

## 🔧 Customization (커스터마이징)

이 파일들은 **템플릿**입니다. 프로젝트별로 커스터마이징할 수 있습니다:

```bash
# 프로젝트별 커스텀 파일 생성
.claude/prompts/
├── dev.md                  # 프로젝트 특화 버전
├── review.md
├── research.md
└── templates/
    ├── dev-template.md     # 원본 템플릿 참조
    ├── review-template.md
    └── research-template.md
```

**커스터마이징 예**:
```markdown
# 프로젝트별 dev.md

<!-- 기존 dev.md 내용 포함 -->
<!-- Template: ../../longform-guide/examples/contexts/dev.md -->

## 우리 프로젝트 특화 규칙

### 추가 요구사항
- AWS Lambda 배포 고려
- DynamoDB 쿼리 최적화 필수
- 특정 보안 표준 준수
```

---

## 📚 Related Documentation (관련 문서)

- [Dynamic System Prompt Injection Guide](../../../01-context-memory/04-dynamic-system-prompt.md)
- [Strategic Compacting](../../../01-context-memory/02-strategic-compacting.md)
- [Session Storage](../../../01-context-memory/01-session-storage.md)

---

## 💡 Tips (팁)

### Tip 1: 역할 전환의 힘 (The Power of Role Switching)

```bash
# 같은 코드를 다른 관점에서 분석
dev "Write this function"
# ↓
review "Is my implementation good?"
# ↓
research "Can we improve the architecture?"
```

### Tip 2: Context 파일과 함께 (With Context Files)

```bash
# Context file + mode 조합
claude \
  --context @.claude/context/previous-session.md \
  --system-prompt @docs/longform-guide/examples/contexts/dev.md \
  message "Continue with implementation"
```

### Tip 3: 팀과 공유 (Share with Team)

```bash
# 팀원 모두가 같은 기준으로 작업
# git으로 관리
cp docs/longform-guide/examples/contexts/dev.md .claude/prompts/dev.md
git add .claude/prompts/dev.md
git commit -m "Add team dev mode context"
git push
```

---

## 📝 Notes (주의사항)

1. **파일 경로**: `@파일경로`는 절대경로를 권장합니다
2. **권한**: 파일이 readable이어야 합니다
3. **크기**: 큰 파일이므로 처음 호출 시 약간의 시간 소요 가능
4. **캐싱**: Claude CLI가 파일을 캐싱할 수 있으므로, 파일 수정 후 약간의 지연 가능

---

## 🤔 FAQ (자주 묻는 질문)

**Q: 어느 파일을 먼저 사용해야 하나요?**
A: `dev.md`부터 시작하세요. 가장 일반적인 사용 사례입니다.

**Q: 여러 파일을 동시에 사용할 수 있나요?**
A: 아니요, 한 번에 하나의 system prompt만 사용 가능합니다. 역할을 전환하세요.

**Q: 파일을 수정해도 되나요?**
A: 네, 커스터마이징하세요! 하지만 원본은 백업해두는 것이 좋습니다.

**Q: 다른 프로젝트에서도 사용할 수 있나요?**
A: 네! 이들은 일반적인 템플릿이므로 다른 프로젝트에도 적용 가능합니다.

---

**마지막 수정**: 2026-01-25
**상태**: Production Ready
**총 코드**: 2,295 줄
**총 추정 읽기 시간**: 60-75분

---

<div align="center">

### 다양한 관점으로 작업하세요. 더 나은 결과를 얻으세요.

</div>
