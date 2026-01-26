# 빈 레포 시작 시 2 인스턴스 패턴 (Two-Instance Kickoff Pattern)

## 핵심 개념 (Core Concept)

**Two-Instance Kickoff Pattern**은 새로운 프로젝트나 빈 저장소에서 시작할 때 **두 개의 Claude Instance를 동시에 실행**하여 효율적으로 프로젝트를 설정하고 기초를 다지는 패턴입니다.

### 왜 필요한가? (Why It Matters)

빈 레포에서 프로젝트를 시작할 때의 문제:

```
단일 인스턴스 (순차 처리)
1. 프로젝트 구조 설계 (30분)
2. 기본 파일 생성 (20분)
3. 설정 파일 작성 (20분)
4. 문서 작성 (30분)
5. 상세 아키텍처 분석 (40분)
━━━━━━━━━━━━━━━━━━━━━━━
총 시간: 2시간 20분 ❌

장점: 순서가 명확함
단점: 느림, 컨텍스트 손실
```

```
두 개 인스턴스 (병렬 처리)
Instance 1 (Scaffolding)    Instance 2 (Research)
├─ 구조 설계 (30분)         ├─ 요구사항 분석 (20분)
├─ 파일 생성 (20분)         ├─ 웹 검색 (15분)
└─ 설정 작성 (20분)         ├─ PRD 작성 (35분)
                           └─ 아키텍처 설계 (20분)
━━━━━━━━━━━━━━━━━━━━━━━
총 시간: 1시간 10분 ✓

장점: 50% 빠름, 컨텍스트 분리
단점: 조정 필요, 파일 병합 필요
```

---

## 패턴의 두 가지 역할 분담 (Role Division)

### Instance 1: Scaffolding Agent (좌측 - 코딩)

**주요 책임**: 프로젝트 구조와 설정 파일 생성

#### 수행하는 작업:

1. **프로젝트 구조 생성**
   - 디렉토리 구조 설계 및 생성
   - 표준 파일 배치
   - 폴더별 목적 정의

2. **설정 파일 작성**
   - `package.json` / `pyproject.toml` 등
   - `.claude/CLAUDE.md` (Claude 설정)
   - `.claude/rules.md` (프로젝트 규칙)
   - `tsconfig.json` / `babel.config.js` 등
   - `.gitignore`, `.env.example` 등

3. **컨벤션 수립**
   - 코드 스타일 가이드
   - 파일 네이밍 규칙
   - 디렉토리 구조 규칙
   - Git commit 규칙

4. **기본 Agent 설정**
   - `.claude/agents/` 디렉토리 구조
   - Agent 정의 파일 템플릿
   - Agent 선택 규칙

#### 특징:

- 빠르고 결정적 (deterministic)
- 파일 생성 중심
- 구조적 결정이 필요
- 자주 참조되는 파일 생성

#### 예시 결과물:

```
my-project/
├── src/
│   ├── components/
│   ├── services/
│   ├── utils/
│   └── index.ts
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── docs/
│   ├── architecture/
│   ├── api/
│   └── guides/
├── .claude/
│   ├── CLAUDE.md
│   ├── rules.md
│   ├── agents/
│   │   ├── scaffolding-agent.yaml
│   │   ├── research-agent.yaml
│   │   └── execute-agent.yaml
│   └── sessions/
├── package.json
├── tsconfig.json
├── .gitignore
└── .env.example
```

---

### Instance 2: Deep Research Agent (우측 - 조사)

**주요 책임**: 프로젝트의 요구사항, 아키텍처, 상세 문서 작성

#### 수행하는 작업:

1. **서비스 연결 및 웹 검색**
   - 필요한 라이브러리/서비스 조사
   - 최신 기술 트렌드 검색
   - 경쟁 제품/기존 솔루션 분석
   - 기술 선택 근거 수집

2. **상세 PRD (Product Requirements Document) 작성**
   - 프로젝트 목표 정의
   - 사용자 스토리 작성
   - 기능 요구사항 명세
   - 비기능 요구사항 (성능, 보안 등)
   - 성공 기준 정의

3. **아키텍처 Mermaid Diagrams 작성**
   - 시스템 아키텍처 다이어그램
   - 데이터 흐름도 (Data Flow Diagram)
   - 컴포넌트 관계도
   - 배포 아키텍처
   - 시퀀스 다이어그램

4. **문서 참조 및 기초 설계**
   - 기술 스택 선택 근거
   - 아키텍처 설계 문서
   - API 설계 초안
   - 데이터베이스 스키마 초안

#### 특징:

- 조사와 분석 중심
- 웹 검색 및 리서치 필요
- 의사결정 지원
- 설계와 계획 수립

#### 예시 결과물:

```
docs/
├── PRD.md
│   ├── 프로젝트 개요
│   ├── 사용자 스토리
│   ├── 기능 요구사항
│   └── 성공 기준
├── ARCHITECTURE.md
│   ├── 시스템 아키텍처
│   ├── 컴포넌트 설명
│   └── 기술 스택 선택 근거
├── TECH_STACK.md
│   ├── 후보 기술 분석
│   ├── 선택 이유
│   └── 리스크 분석
├── API_DESIGN.md
│   ├── 엔드포인트 설계
│   └── 스키마 정의
├── DATABASE_SCHEMA.md
│   └── 초기 스키마 설계
└── diagrams/
    ├── architecture.mmd
    ├── dataflow.mmd
    ├── components.mmd
    └── deployment.mmd
```

---

## 실전 구현 (Practical Implementation)

### 시작 단계별 가이드

#### 1단계: 두 Instance 동시 시작 (2-5분)

**Instance 1 시작:**
```bash
# 터미널 1: Scaffolding instance
cd /path/to/empty-repo

# Claude Code 시작
# /rename "Scaffolding: Project Structure Setup"
```

**Instance 2 시작:**
```bash
# 터미널 2: Research instance
cd /path/to/empty-repo

# Claude Code 시작
# /rename "Research: Requirements & Architecture"
```

#### 2단계: Instance 1 - 레이아웃 구성 (30-40분)

**Instance 1이 수행할 작업:**

1. **프로젝트 구조 설계**
   ```
   /plan

   질문에 답변:
   - 프로젝트 유형? (Web App, Library, CLI, etc.)
   - 언어? (JavaScript, Python, Rust, etc.)
   - 프레임워크? (React, Django, FastAPI, etc.)
   - 팀 규모? (Solo, Small, Large)
   - 배포 대상? (npm, PyPI, Docker, etc.)
   ```

2. **디렉토리 구조 생성**
   ```bash
   # 예: Node.js + React 프로젝트

   mkdir -p src/{components,hooks,services,utils,types,styles}
   mkdir -p tests/{unit,integration}
   mkdir -p docs/{architecture,api,guides}
   mkdir -p public
   mkdir -p .claude/{agents,sessions}
   ```

3. **핵심 설정 파일 작성**
   - `package.json` (프로젝트 메타데이터, 의존성)
   - `tsconfig.json` (TypeScript 설정)
   - `.env.example` (환경변수 템플릿)
   - `.gitignore` (Git 무시 규칙)
   - `.prettierrc` / `.eslintrc.json` (코드 스타일)

4. **`.claude/` 설정 생성**
   ```markdown
   # .claude/CLAUDE.md

   프로젝트 이름, 목표, 기본 규칙 정의

   # .claude/rules.md

   코드 스타일, 커밋 규칙, 네이밍 컨벤션
   ```

5. **초기 Agent 정의**
   - `.claude/agents/main-agent.yaml`
   - `.claude/agents/scaffolding-agent.yaml`
   - 등등

#### 3단계: Instance 2 - 연구 및 분석 (30-40분)

**Instance 2가 수행할 작업:**

1. **요구사항 분석**
   ```
   /plan

   질문에 답변:
   - 핵심 목표는?
   - 주요 기능은?
   - 타겟 사용자는?
   - 성공의 기준은?
   ```

2. **웹 검색 및 조사**
   - 유사 솔루션 분석
   - 기술 트렌드 조사
   - 라이브러리/프레임워크 비교
   - 성능/보안 고려사항 검색

3. **상세 문서 작성**
   ```markdown
   # docs/PRD.md

   프로젝트 요구사항 정의서
   - 목표
   - 사용자 스토리
   - 기능 명세
   - 제약사항

   # docs/ARCHITECTURE.md

   시스템 설계
   - 아키텍처 다이어그램
   - 컴포넌트 설명
   - 데이터 흐름
   ```

4. **다이어그램 작성**
   - Mermaid 다이어그램 (architecture, dataflow, 등)
   - 플로우차트, 시퀀스 다이어그램
   - 배포 다이어그램

5. **기술 스택 분석 및 정리**
   ```markdown
   # docs/TECH_STACK.md

   선택한 기술 및 선택 이유
   - 프론트엔드: React 18 (이유: ...)
   - 백엔드: Node.js + Express (이유: ...)
   - 데이터베이스: PostgreSQL (이유: ...)
   - 캐시: Redis (이유: ...)
   ```

#### 4단계: 두 Instance 동기화 및 병합 (15-20분)

**병합 체크리스트:**

```
Instance 1 (Scaffolding) 결과:
✓ 프로젝트 디렉토리 구조
✓ package.json, 설정 파일
✓ .claude/CLAUDE.md, .claude/rules.md
✓ .gitignore, .env.example

Instance 2 (Research) 결과:
✓ docs/PRD.md
✓ docs/ARCHITECTURE.md
✓ docs/TECH_STACK.md
✓ docs/diagrams/*.mmd

병합 작업:
1. Instance 2의 docs/ 폴더를 프로젝트에 복사
2. Instance 2의 다이어그램 링크를 README에 추가
3. CLAUDE.md에 프로젝트 목표 추가
4. rules.md에 기술 스택 정보 추가
5. 최종 README.md 작성
6. 초기 커밋 생성
```

---

## 패턴 활용: /rename, /fork 사용 (Advanced Techniques)

### /rename 명령어 활용

Instance를 시작할 때 명확한 이름을 지정하여 역할을 명시합니다:

```bash
# Instance 1 (Scaffolding)
/rename "Scaffolding: [Project Name] Structure & Config"

# Instance 2 (Research)
/rename "Research: [Project Name] PRD & Architecture"
```

**장점:**
- 목적이 명확함
- 컨텍스트 손실 없음
- 다른 팀원이 이해하기 쉬움
- 나중에 다시 시작할 때 참고 가능

### /fork 명령어 활용

연구 중 발견한 내용을 바탕으로 새로운 Instance를 분기하기:

```bash
# Instance 2에서 새로운 기술 검토 필요 시
/fork "Technical Deep-Dive: [Technology Name]"

# 새로운 Instance에서:
# - 라이브러리 벤치마킹
# - 성능 테스트
# - 보안 분석
```

**활용 사례:**
- 기술 선택이 애매할 때 심화 조사
- 복잡한 아키텍처 결정 필요
- 특정 라이브러리의 장단점 분석 필요

---

## 시작 설정: 좌측(코딩) / 우측(질문) 배치

### 권장 IDE 배치 (Recommended Workspace Setup)

```
┌─────────────────────────────────────────┐
│                Monitor                   │
├──────────────────┬──────────────────────┤
│   VS Code        │    Claude Code       │
│   (Local)        │    (Instance 1)      │
│                  │                      │
│ ├─ File Tree     │ Scaffolding Agent    │
│ ├─ Terminal 1    │ - Building structure │
│ └─ Editor        │ - Creating configs   │
│                  │                      │
├──────────────────┼──────────────────────┤
│   Terminal 2     │    Claude Code       │
│   (Research)     │    (Instance 2)      │
│                  │                      │
│ ├─ Watch Mode    │ Research Agent       │
│ └─ Logs          │ - Analyzing reqs     │
│                  │ - Writing docs       │
│                  │ - Creating diagrams  │
└──────────────────┴──────────────────────┘
```

### 좌측 작업영역 (Left: Coding Instance)

**화면 구성:**
- 상단 좌측: 파일 탐색기
- 상단 우측: 에디터 (생성되는 파일 미리보기)
- 하단: 터미널 (파일 생성 명령어)

**빠른 참조:**
```bash
# Terminal 에서 자주 실행되는 명령어

# 구조 확인
tree src/ -I node_modules

# 파일 생성 확인
find . -type f -name "*.json" | head -20

# .claude 구조 확인
ls -la .claude/
```

### 우측 작업영역 (Right: Research Instance)

**화면 구성:**
- 상단: Claude Code (분석 진행)
- 중단: 생성되는 문서 미리보기
- 하단: 웹 검색 결과 참고

**빠른 참조:**
```
주요 산출물 위치:
- docs/PRD.md (사용자 요구사항)
- docs/ARCHITECTURE.md (시스템 설계)
- docs/diagrams/ (Mermaid 다이어그램)
- docs/TECH_STACK.md (기술 선택 근거)
```

---

## 실제 예시: Node.js + React 프로젝트 (Real Example)

### 예시 프로젝트 설정

**프로젝트명:** MyApp
**유형:** Web Application
**스택:** Node.js + Express + React + PostgreSQL

### Instance 1 수행 (30분)

```bash
# 1. 구조 생성
mkdir -p src/{components,hooks,services,utils,types,styles}
mkdir -p tests/{unit,integration,e2e}
mkdir -p docs/{architecture,api,guides}
mkdir -p public
mkdir -p .claude/{agents,sessions}
mkdir -p server/{routes,middleware,models,services}

# 2. 설정 파일 생성
# package.json
{
  "name": "myapp",
  "version": "0.1.0",
  "description": "MyApp - Modern Web Application",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "test": "vitest",
    "lint": "eslint src --ext .ts,.tsx"
  },
  "dependencies": { ... },
  "devDependencies": { ... }
}

# 3. .claude 설정
# .claude/CLAUDE.md (프로젝트 개요)
# .claude/rules.md (코딩 규칙)

# 4. .gitignore, .env.example
```

**Instance 1 산출물:**
```
myapp/
├── src/
├── server/
├── tests/
├── docs/
├── public/
├── .claude/
├── package.json
├── tsconfig.json
├── vite.config.ts
├── .gitignore
├── .env.example
└── .prettierrc
```

### Instance 2 수행 (30분)

```markdown
# docs/PRD.md

## 프로젝트 개요

MyApp은 협업 작업 관리 플랫폼입니다.

### 핵심 기능
- 프로젝트 생성 및 관리
- 작업 항목 추적
- 팀 협업
- 실시간 알림

### 사용자 스토리
- 사용자는 프로젝트를 생성할 수 있다
- 사용자는 팀원을 초대할 수 있다
- 사용자는 작업을 할당받을 수 있다
- 사용자는 진행 상황을 추적할 수 있다

# docs/ARCHITECTURE.md

## 시스템 아키텍처

\`\`\`mermaid
graph TB
    Client[React Client]
    Server[Express Server]
    DB[(PostgreSQL)]
    Cache[Redis Cache]

    Client -->|REST API| Server
    Server -->|Query| DB
    Server -->|Cache| Cache
\`\`\`

# docs/TECH_STACK.md

## 기술 선택

### Frontend
- React 18: UI 라이브러리
- Vite: 번들러 (Webpack 대비 빠름)
- TypeScript: 타입 안정성

### Backend
- Express: 경량 웹 프레임워크
- PostgreSQL: 관계형 DB (데이터 무결성)
- Redis: 세션/캐시 저장소

### 왜 이 선택?
- React: 최신, 큰 커뮤니티
- Vite: 개발 속도 빠름
- Express: 간단한 학습곡선
- PostgreSQL: 복잡한 관계 쿼리 지원
```

**Instance 2 산출물:**
```
docs/
├── PRD.md
├── ARCHITECTURE.md
├── TECH_STACK.md
├── API_DESIGN.md
├── DATABASE_SCHEMA.md
└── diagrams/
    ├── architecture.mmd
    ├── dataflow.mmd
    ├── components.mmd
    └── database_schema.mmd
```

### 병합 (15분)

```bash
# 최종 README.md 작성
# 초기 커밋
git add .
git commit -m "feat: initialize project structure and documentation"

# Instance 2 docs 폴더 내용 통합
# CLAUDE.md와 PRD 정보 동기화
```

---

## 언제 이 패턴을 사용할까? (When to Use)

### 이 패턴이 효과적인 경우:

✅ **완전히 새로운 프로젝트 시작**
- 빈 저장소에서 시작
- 요구사항이 명확한 경우
- 팀이 기술 스택에 합의한 경우

✅ **큰 규모의 프로젝트**
- 여러 모듈이 필요
- 복잡한 아키텍처
- 상세 문서가 필요

✅ **팀 협업 프로젝트**
- 다른 팀원이 조인할 예정
- 명확한 구조와 규칙이 필요
- 온보딩 문서 필요

✅ **새로운 기술 스택 습득**
- 기술 선택에 확신 필요
- 비교 분석 필요
- 아키텍처 설계 중요

### 이 패턴이 불필요한 경우:

❌ **작은 스크립트나 바이너리**
- 간단한 CLI 도구
- 프로토타입
- 학습용 코드

❌ **명확하지 않은 요구사항**
- 먼저 탐색 단계 필요
- 인터뷰/조사 필요
- 기술 선택이 불확실

---

## 문제 해결 (Troubleshooting)

### 문제 1: 두 Instance 간 파일 충돌

**증상:** `.claude/rules.md` 등이 중복 생성됨

**해결책:**
```bash
# Instance 1이 생성한 파일을 우선
# Instance 2의 중복 파일은 검토 후 병합

# 파일 비교
diff .claude/rules.md.instance1 .claude/rules.md.instance2

# 선택적 병합
cat .claude/rules.md.instance1 .claude/rules.md.instance2 > .claude/rules.md
```

### 문제 2: Instance 간 컨텍스트 불일치

**증상:** Instance 2가 생성한 문서의 기술 스택이 Instance 1과 다름

**해결책:**
```
1. 중간에 동기화 포인트 설정
   - 15분 후: 기술 스택 확정 공유
   - 25분 후: 디렉토리 구조 공유

2. Instance 2가 docs/TECH_STACK.md 작성 시
   Instance 1이 선택한 기술 확인 후 작성

3. 충돌 발생 시 Instance 2 (Research)를 우선
   - 더 신뢰할 수 있는 분석 정보
```

### 문제 3: 한 Instance가 다른 Instance보다 훨씬 빨리 끝남

**증상:** Instance 1이 10분 만에 끝나고 Instance 2는 아직 진행 중

**해결책:**
```
Instance 1이 먼저 끝난 경우:
1. Instance 2의 현황 확인
2. Instance 2 지원 작업 수행:
   - 생성된 파일들의 품질 검토
   - docs/ 폴더 구조 준비
   - 다이어그램용 폴더 생성

Instance 2가 먼저 끝난 경우:
1. Instance 1이 완료될 때까지 대기 (권장)
2. 또는 Instance 1 지원:
   - 설정 파일 검토
   - 타입 정의 확인
```

---

## 고급 활용: 3개 이상 Instance 확장 (Advanced: Scaling)

### Instance 3 추가: Infrastructure Setup (선택사항)

큰 프로젝트에서 인프라가 복잡한 경우:

```bash
/rename "Infrastructure: Docker & Deployment Setup"
```

**수행 작업:**
- Docker, docker-compose 설정
- 배포 파이프라인 (CI/CD)
- 환경 설정
- 모니터링 설정

### Instance 4 추가: API Design (선택사항)

API 설계가 복잡한 경우:

```bash
/rename "API Design: REST/GraphQL Specification"
```

**수행 작업:**
- OpenAPI/GraphQL 스펙 작성
- 엔드포인트 정의
- 데이터 타입 정의
- 인증/인가 설계

---

## Best Practices (최적 사례)

### DO (권장):

✅ **명확한 Instance 이름 지정**
```
좋은 예:
"Scaffolding: E-commerce Platform - Structure & Config"
"Research: E-commerce Platform - Requirements & Tech Analysis"

나쁜 예:
"Instance 1"
"Claude 2"
```

✅ **중간 동기화 지점 설정**
```
15분 후: 기술 스택 확정
25분 후: 디렉토리 구조 최종 확인
35분 후: 최종 병합 전 충돌 확인
```

✅ **각 Instance의 결과물을 명확히 구분**
```
Instance 1 → src/, .claude/
Instance 2 → docs/
```

✅ **최종 병합 전 코드 검토**
```bash
# 모든 파일이 올바르게 생성되었는지 확인
find . -type f -name "*.json" -o -name "*.md" | xargs head -5

# 구조 확인
tree -L 2 -I node_modules
```

### DON'T (피해야 할):

❌ **동시에 같은 파일 수정**
```
나쁜 예:
Instance 1이 package.json 수정
Instance 2도 package.json 수정 → 충돌!

좋은 예:
Instance 1: package.json 생성
Instance 2: docs/TECH_STACK.md에서 참조만 함
```

❌ **명확하지 않은 작업 분담**
```
나쁜 예:
두 Instance가 모두 다이어그램 작성 → 중복

좋은 예:
Instance 2만 diagrams/ 폴더에 모든 다이어그램 작성
```

❌ **병합 없이 별도로 진행**
```
나쁜 예:
각 Instance가 독립적으로 커밋 → 히스토리 복잡

좋은 예:
두 Instance 완료 후 한 번에 병합 → 깔끔한 히스토리
```

---

## 타이밍과 속도 최적화 (Timing & Speed)

### 이상적인 타이밍 (Ideal Timeline)

```
⏱ 0-2분: 두 Instance 동시 시작 + /rename
          ├─ Instance 1: 프로젝트 유형 결정
          └─ Instance 2: 프로젝트 목표 정의

⏱ 2-15분: Instance 1 진행 (구조 생성)
           Instance 2 진행 (웹 검색 시작)

⏱ 15분: 중간 동기화
        ├─ Instance 1: 기술 스택 최종 확인 → Instance 2에 전달
        ├─ Instance 2: 기술 스택 정보 확인 → 아키텍처 설계 시작
        └─ 이 시점에서 패턴 변경 (필요시)

⏱ 15-30분: Instance 1 계속 (설정 파일, .claude/ 작성)
            Instance 2 계속 (PRD, 초안 다이어그램)

⏱ 30-40분: Instance 1 완료
            Instance 2 계속 (최종 문서, 다이어그램 정리)

⏱ 40-50분: Instance 2 완료

⏱ 50-60분: 병합 및 최종 검토
           ├─ 파일 통합
           ├─ 링크 확인
           ├─ README.md 작성
           └─ 초기 커밋
```

### 병목 지점 제거 (Removing Bottlenecks)

**만약 Instance 1이 지정된 시간 안에 못 끝낼 경우:**
```
원인 분석:
- 기술 스택 결정 어려움?
  → Instance 2에 조사 요청
- 디렉토리 구조 복잡?
  → 단순화 후 나중에 리팩토링
- 설정 파일이 많음?
  → 필수 파일만 먼저, 나머지는 추후 작성

해결책:
- Instance 1: MVP(최소 버전) 구조만 생성
- Instance 2: 상세 구조안을 문서화
- 나중에 Instance 1에서 상세 구조로 확장
```

**만약 Instance 2가 지정된 시간 안에 못 끝낼 경우:**
```
원인 분석:
- 웹 검색에 시간 오래 걸림?
  → 먼저 문서 작성, 나중에 링크 추가
- 다이어그램이 복잡?
  → 간단한 다이어그램부터 시작
- 기술 스택 결정이 어려움?
  → 장단점만 정리, Instance 1과 협의

해결책:
- Instance 2: 핵심 문서(PRD, Architecture)에 집중
- 상세 분석(Performance, Security)은 추후
- Draft 상태로 일단 마무리
```

---

## 체크리스트 (Checklist)

### 프로젝트 시작 전

- [ ] 프로젝트 유형 결정 (Web, CLI, Library, etc.)
- [ ] 언어 및 프레임워크 선택 (또는 Instance 2에서 결정)
- [ ] 팀 규모 파악 (Solo, Small, Large)
- [ ] 배포 환경 결정 (npm, PyPI, Docker, etc.)

### Instance 1 (Scaffolding) 완료 후

- [ ] `src/` 및 주요 디렉토리 생성됨
- [ ] `package.json` (또는 `pyproject.toml` 등) 작성됨
- [ ] `.claude/CLAUDE.md` 작성됨
- [ ] `.claude/rules.md` 작성됨
- [ ] `.gitignore` 작성됨
- [ ] `.env.example` 작성됨
- [ ] `tsconfig.json` (또는 해당 설정 파일) 작성됨
- [ ] `.claude/agents/` 디렉토리 구조 준비됨

### Instance 2 (Research) 완료 후

- [ ] `docs/PRD.md` 작성됨
- [ ] `docs/ARCHITECTURE.md` 작성됨
- [ ] `docs/TECH_STACK.md` 작성됨
- [ ] 최소 3개 이상의 Mermaid 다이어그램 작성됨
- [ ] 기술 선택 근거가 명확함
- [ ] 사용자 스토리가 정의됨

### 병합 및 최종

- [ ] 두 Instance의 파일을 모두 프로젝트에 통합
- [ ] `docs/` 폴더가 완성됨
- [ ] `README.md` 작성됨
- [ ] 모든 링크가 유효함 (파일, 다이어그램 등)
- [ ] `.gitignore`에 임시 파일 추가됨 (`.tmp`, `.env`)
- [ ] 초기 커밋 생성됨
- [ ] 기본 브랜치가 clean 상태

---

## 다음 단계 (Next Steps)

Two-Instance Kickoff 완료 후:

### 즉시 다음 (Within 1 hour):
1. **첫 번째 기능 구현 시작**
   - Instance 1에서 코딩 시작
   - PRD의 첫 번째 사용자 스토리부터

2. **CI/CD 파이프라인 구축** (복잡한 프로젝트의 경우)
   - GitHub Actions / GitLab CI 설정
   - 테스트 자동화

### 단기 (Within 1 day):
1. **프로젝트 규칙 수정**
   - 실제 작업하며 발견된 개선사항 반영
   - `.claude/rules.md` 업데이트

2. **처음 몇 개 컴포넌트 구현**
   - Instance 1을 계속 사용
   - 또는 새로운 Instance에서 기능별 개발

### 중기 (Within 1 week):
1. **문서 상세화**
   - API 문서 작성
   - 아키텍처 세부 사항 추가
   - 배포 가이드 작성

2. **팀 온보딩**
   - 새 팀원에게 README 공유
   - 기술 스택 설명
   - 개발 환경 설정 안내

---

## 관련 문서 (Related Documentation)

### 같은 레벨
- [Session Storage: Persistent Context](../01-context-memory/01-session-storage.md) - 세션 상태 관리
- [Subagent Architecture](../02-token-optimization/01-subagent-architecture.md) - Instance 선택 전략
- [Parallelization Patterns](../04-parallelization/README.md) - 병렬화 심화

### 다음 단계
- [Agent Design Patterns](../06-agent-best-practices/README.md) - Instance 설계
- [Verification Strategies](../03-verification-evals/README.md) - 결과 검증

### 메인 가이드
- [Longform Guide Overview](../README.md) - 전체 가이드
- [Groundwork Overview](./README.md) - Groundwork 섹션 개요

---

## 실전 비디오 가이드 (Video Tutorial - Coming Soon)

이 패턴의 실제 적용 과정을 보여주는 비디오 가이드가 준비 중입니다:

1. **2-Instance Setup** (5분)
   - 두 Instance 동시 시작
   - /rename 활용

2. **Instance 1 Deep-Dive** (15분)
   - 프로젝트 구조 생성
   - 설정 파일 작성
   - .claude/ 설정

3. **Instance 2 Deep-Dive** (20분)
   - 요구사항 분석
   - 아키텍처 설계
   - 다이어그램 작성

4. **Merging & Finalization** (10분)
   - 병합 과정
   - 최종 검토
   - 초기 커밋

---

## FAQ (자주 묻는 질문)

### Q: 인스턴스가 3개 필요하면?
**A:** 프로젝트가 매우 크다면 Instance 3를 추가하세요:
- Instance 3: Infrastructure & DevOps
- 하지만 대부분 2개로 충분합니다.

### Q: 만약 둘 다 같은 파일을 수정하면?
**A:** 이를 피하도록 설계했습니다. 명확한 역할 분담이 핵심입니다.
- Instance 1: src/, .claude/, config 파일
- Instance 2: docs/, diagrams

### Q: 만약 요구사항이 중간에 바뀌면?
**A:** Instance를 멈추고 재협의 필요:
1. 두 Instance에서 새 요구사항 공유
2. 기술 스택 재검토
3. 필요시 처음부터 시작

### Q: 이 패턴 없이 시작하면 안 돼?
**A:** 물론 가능합니다. 하지만:
- 순차 처리로 50% 더 느림
- 구조와 문서가 덜 완성됨
- 나중에 리팩토링 필요할 가능성

### Q: 초기 설정이 완벽해야 하나?
**A:** 아니요. MVP(최소 기능 제품) 수준으로 충분합니다:
- 필수 디렉토리와 파일만
- 나중에 리팩토링 가능
- 하지만 기본 구조와 문서는 필수

---

## 요약 (Summary)

**Two-Instance Kickoff Pattern**:

1. **두 개의 역할로 나누기**
   - Instance 1 (Scaffolding): 구조와 설정
   - Instance 2 (Research): 요구사항과 아키텍처

2. **동시 진행으로 50% 시간 단축**
   - 병렬 처리의 장점 활용
   - 컨텍스트 손실 방지

3. **명확한 작업 분담**
   - 충돌 최소화
   - 품질 유지

4. **최종 병합으로 완벽한 시작**
   - 구조와 문서가 모두 준비됨
   - 즉시 개발 시작 가능

이 패턴으로 **견고한 기초**를 빠르게 다질 수 있습니다.

---

## 참고 자료 (References)

- [Claude Automate Project](../../README.md)
- [Longform Guide](../README.md)
- [Parallelization Guide](../04-parallelization/README.md)
- [Agent Best Practices](../06-agent-best-practices/README.md)

---

<div align="center">

### 빈 레포에서 완벽한 시작을 만드세요
### Create Perfect Project Foundation from Empty Repository

**Two-Instance Kickoff = 50% 빠른 시작 + 완벽한 문서화**

</div>
