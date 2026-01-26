# Groundwork (준비 단계)

## 개요 (Overview)

**Groundwork**는 성공적인 프로젝트 개발을 위한 견고한 토대를 마련하는 단계입니다. 좋은 시작이 좋은 결과를 만듭니다. 이 섹션에서는 Claude와 함께 효율적으로 개발을 시작하고, 프로젝트 기초를 잘 설계하는 방법을 배웁니다.

### 왜 Groundwork가 중요한가?

많은 개발자들이 서두르다가 다음과 같은 문제를 겪습니다:

- **컨텍스트 혼란**: Claude에게 프로젝트 정보를 제대로 전달하지 못해 잘못된 결과 생성
- **불명확한 요구사항**: 처음부터 명확하지 않은 목표로 인한 재작업
- **일관성 부족**: 프로젝트 규칙과 패턴이 정의되지 않아 예측 불가능한 결과
- **협업 어려움**: 여러 Claude 인스턴스 간 정보 공유 미흡
- **문서화 누락**: 나중에 프로젝트 이해를 위한 추가 작업 필요

Groundwork는 이러한 문제들을 사전에 예방합니다:

1. **명확한 초기 설정** - 프로젝트 방향성과 요구사항 정의
2. **AI-친화적 문서화** - Claude가 이해하기 쉬운 가이드 작성
3. **재사용 가능한 패턴** - 프로젝트 전체에서 일관되게 적용 가능한 구조
4. **효율적인 협업** - 여러 Claude 인스턴스 간의 원활한 협력

---

## 3개 핵심 섹션 (3 Core Sections)

이 섹션에서는 Groundwork의 주요 개념과 실제 적용 방법을 다룹니다:

### 1. [Two-Instance Kickoff Pattern](./01-two-instance-kickoff.md)

프로젝트 시작 단계에서 **두 가지 관점의 Claude 인스턴스**를 활용하여 요구사항과 기술적 제약을 균형있게 분석하는 패턴을 설명합니다.

**주요 내용:**
- Kickoff 패턴의 핵심 개념
- Product Owner 역할의 Claude 설정 (요구사항, 사용자 스토리)
- Senior Engineer 역할의 Claude 설정 (기술 제약, 아키텍처)
- 두 인스턴스의 병렬 실행 및 결과 통합
- 검증된 프로젝트 정의 생성
- 실제 사례 및 적용 가이드

**🎯 목표**: 명확하고 실현 가능한 프로젝트 정의서 작성

### 2. [llms.txt Pattern](./02-llms-txt-pattern.md)

Claude와 다른 AI 모델들이 효율적으로 이해할 수 있도록 **프로젝트 정보를 구조화된 텍스트 파일**로 작성하는 패턴을 다룹니다.

**주요 내용:**
- llms.txt 파일의 목적과 개념
- 프로젝트별 llms.txt 작성 방법
- API 가이드, 패턴, 컨벤션 문서화
- Claude의 컨텍스트에 llms.txt 통합
- 동적 업데이트 및 관리
- 실전 예제 (백엔드, 프론트엔드, 데이터 과학 프로젝트)

**🎯 목표**: AI가 이해하기 쉬운 프로젝트 가이드 작성

### 3. [Philosophy: Build Reusable Patterns](./03-reusable-patterns-philosophy.md)

**일회성 솔루션이 아닌 재사용 가능한 패턴**을 만드는 개발 철학을 설명합니다. 이 접근법은 프로젝트 규모에 관계없이 일관성을 유지하고 미래의 비슷한 작업을 빠르게 처리할 수 있게 합니다.

**주요 내용:**
- 패턴 사고방식 (Pattern Thinking)
- 일회성 vs 재사용 가능한 솔루션 비교
- 패턴 추상화 및 일반화
- 패턴 문서화 및 공유
- 프로젝트 규칙(Rules) 정의
- Skill과 Template 설계
- 조직 차원의 패턴 라이브러리 구축

**🎯 목표**: 지속 가능하고 확장 가능한 개발 체계 수립

---

## 학습 경로 (Learning Path)

처음 Groundwork를 배우는 경우:

1. **[Two-Instance Kickoff Pattern](./01-two-instance-kickoff.md)** 부터 시작하여 프로젝트 시작 방법을 이해합니다
2. **[llms.txt Pattern](./02-llms-txt-pattern.md)** 에서 프로젝트 정보 구조화 방법을 학습합니다
3. **[Philosophy: Build Reusable Patterns](./03-reusable-patterns-philosophy.md)** 으로 장기적인 개발 철학을 마무리합니다

또는 현재 프로젝트 상황에 따라:

**신규 프로젝트 시작:**
```
1. Two-Instance Kickoff → 요구사항 정의
2. llms.txt Pattern → 프로젝트 가이드 작성
3. Reusable Patterns → 팀 규칙 수립
```

**진행 중인 프로젝트 개선:**
```
1. Reusable Patterns → 현재 패턴 검토
2. llms.txt Pattern → 문서화 개선
3. Two-Instance Kickoff → 새 기능 검증
```

**조직 차원의 체계화:**
```
1. Reusable Patterns → 조직 표준 정의
2. llms.txt Pattern → 조직 가이드 작성
3. Two-Instance Kickoff → 모든 프로젝트에 적용
```

---

## 주요 개념 요약

| 개념 | 한글 | 설명 |
|------|------|------|
| **Two-Instance Kickoff** | 이중 인스턴스 시작 | 두 가지 관점(Product Owner + Engineer)으로 프로젝트 검증 |
| **llms.txt File** | AI 친화 문서 파일 | AI 모델이 이해하기 쉽게 작성한 프로젝트 정보 파일 |
| **Reusable Pattern** | 재사용 가능 패턴 | 프로젝트 전체에서 반복 적용 가능한 구조와 규칙 |
| **Project Rules** | 프로젝트 규칙 | 코드, 커밋, 문서작성 등 프로젝트 컨벤션 |
| **AI-Friendly Documentation** | AI 친화 문서 | Claude가 이해하고 참고하기 쉽게 작성한 문서 |
| **Kickoff Pattern** | 킥오프 패턴 | 프로젝트 또는 기능 시작 시 검증하는 구조화된 방식 |
| **Context Clarity** | 컨텍스트 명확화 | Claude에게 프로젝트 상황을 정확하게 전달 |

---

## 실전 예제 및 체크리스트

### 신규 프로젝트 시작 체크리스트

```
Groundwork 완료 전 확인사항:

[ ] 프로젝트 목표와 요구사항 명확화
    ├─ Product Owner 관점: 비즈니스 요구사항 정의
    ├─ Engineer 관점: 기술적 제약사항 검토
    └─ 통합 결과: 합의된 스코프 정의서

[ ] llms.txt 파일 작성
    ├─ 프로젝트 개요
    ├─ 기술 스택 설명
    ├─ 디렉토리 구조
    ├─ 주요 패턴 및 컨벤션
    └─ API 및 인터페이스 가이드

[ ] 프로젝트 규칙 정의
    ├─ 코딩 스타일 가이드
    ├─ 커밋 메시지 규칙
    ├─ 문서작성 템플릿
    └─ PR 검토 기준

[ ] 재사용 가능 패턴 설계
    ├─ 아키텍처 패턴 (MVC, Clean Architecture 등)
    ├─ 파일 구조 패턴
    ├─ 모듈 작성 템플릿
    └─ 테스트 패턴

[ ] 초기 프로젝트 구조 생성
    ├─ README.md 작성
    ├─ docs/ 디렉토리 구조
    ├─ .claude/ 설정 디렉토리
    └─ 초기 파일들 생성
```

### Groundwork 진행 시간 가이드

| 프로젝트 규모 | Two-Instance Kickoff | llms.txt Pattern | Reusable Patterns | 총 소요 시간 |
|---|---|---|---|---|
| **소규모** (1-2인, <1개월) | 30분 | 30분 | 30분 | ~1.5시간 |
| **중규모** (3-5인, 1-3개월) | 1시간 | 1시간 | 1.5시간 | ~3.5시간 |
| **대규모** (5인+, 3개월+) | 1.5시간 | 1.5시간 | 2시간 | ~5시간 |

---

## 다른 섹션과의 연결

### 이전 단계 (Prerequisites)

Groundwork를 시작하기 전에 이해하면 좋은 내용:

- **[Context & Memory Management](../01-context-memory/README.md)** - 프로젝트 정보를 Claude에게 효과적으로 전달하는 방법
- **[Token Optimization](../02-token-optimization/README.md)** - 두 인스턴스 실행 시 토큰 효율성 관리

### 다음 단계 (Next Steps)

Groundwork 완료 후 배우면 좋은 내용:

- **[Parallelization](../04-parallelization/README.md)** - 정의된 패턴을 여러 인스턴스에 적용
- **[Verification Loops & Evals](../03-verification-evals/README.md)** - 정의된 규칙에 맞게 검증
- **[Agent Best Practices](../06-agent-best-practices/README.md)** - 규칙 기반 Agent 설계

---

## 실제 프로젝트 적용 사례

### 사례 1: 스타트업의 백엔드 API 프로젝트

```
상황: 3명의 팀, Python FastAPI 프로젝트, 2개월 개발 기간

Groundwork 적용:
├─ Two-Instance Kickoff
│  ├─ Product Owner: API 기능 요구사항 정의
│  └─ Senior Engineer: 아키텍처, 성능, 보안 검토
│
├─ llms.txt Pattern
│  ├─ 프로젝트 구조 설명
│  ├─ API 엔드포인트 가이드
│  ├─ 데이터베이스 스키마
│  └─ 에러 처리 패턴
│
└─ Reusable Patterns
   ├─ 엔드포인트 작성 템플릿
   ├─ 데이터베이스 모델 패턴
   ├─ 테스트 작성 표준
   └─ 배포 체크리스트

결과: 개발 속도 35% 향상, 코드 리뷰 시간 50% 단축
```

### 사례 2: 개인 프로젝트 - React 웹앱

```
상황: 1인 개발자, React + TypeScript, 실험적 프로젝트

Groundwork 적용:
├─ Two-Instance Kickoff
│  ├─ Product Owner: 기능 우선순위
│  └─ Engineer: 기술 아키텍처
│
├─ llms.txt Pattern
│  ├─ 컴포넌트 가이드
│  ├─ 상태 관리 패턴
│  └─ 테스트 표준
│
└─ Reusable Patterns
   ├─ 컴포넌트 템플릿
   ├─ 커스텀 훅 작성법
   └─ 스타일 가이드

결과: Claude의 제안이 프로젝트와 일치하는 비율 95% (기존 50%)
```

---

## 주의사항 및 일반적인 실수

### ❌ 과도한 설계 (Over-Engineering)

```
❌ 나쁜 예: 매우 큰 프로젝트처럼 모든 것을 과도하게 정의
   → 작은 프로젝트에서는 오버헤드만 증가

✅ 좋은 예: 프로젝트 규모에 맞는 수준의 Groundwork 정의
   → 필요한 만큼만, 적절한 상세도 유지
```

### ❌ 미완성 llms.txt

```
❌ 나쁜 예: 처음에만 작성하고 이후 업데이트 안 함
   → Claude가 낡은 정보를 참고함

✅ 좋은 예: 주요 변경 사항 시 llms.txt 함께 업데이트
   → 항상 최신 정보 제공
```

### ❌ 과도한 규칙

```
❌ 나쁜 예: 100개 이상의 세부 규칙 정의
   → Claude가 모든 규칙을 따르기 어려움

✅ 좋은 예: 5-10개의 핵심 규칙에 집중
   → 더 정확하고 일관된 결과
```

---

## 유용한 도구 및 리소스

### Claude Automate 관련
- **[/project-init skill](../../skills/project-init/README.md)** - 프로젝트 초기화
- **[Rules System](../../rules/)** - 프로젝트 규칙 정의
- **[.claude/CLAUDE.md](../../.claude/CLAUDE.md)** - 시스템 프롬프트 관리

### 외부 리소스
- **[llms-txt official](https://llmstxt.org/)** - llms.txt 스펙 문서
- **[Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)** - Anthropic 공식 가이드

---

## 관련 문서

### 같은 레벨의 다른 섹션

- **[Context & Memory Management](../01-context-memory/README.md)** - Context 효율성
- **[Token Optimization](../02-token-optimization/README.md)** - 토큰 최적화
- **[Verification Loops & Evals](../03-verification-evals/README.md)** - 품질 검증
- **[Parallelization](../04-parallelization/README.md)** - 병렬화
- **[Agent Best Practices](../06-agent-best-practices/README.md)** - Agent 설계

### 메인 가이드

- **[Longform Guide Overview](../README.md)** - 전체 가이드 소개
- **[main README](../../README.md)** - Claude Automate 프로젝트 개요

---

## 빠른 시작 (Quick Start)

### 1단계: 프로젝트 초기화

```bash
# Claude Automate를 사용한 자동 초기화
/project-init my-awesome-project
```

### 2단계: Two-Instance Kickoff 실행

```bash
# Product Owner 인스턴스
/start-work --role product-owner

# Senior Engineer 인스턴스 (다른 창)
/start-work --role senior-engineer
```

### 3단계: llms.txt 작성

```bash
# 템플릿에서 시작
cp docs/longform-guide/examples/llms.txt.template ./llms.txt
# llms.txt 편집 및 업데이트
```

### 4단계: 프로젝트 규칙 정의

```bash
# .claude/rules/ 디렉토리에서 규칙 정의
vim .claude/rules/project-rules.md
```

---

## 성과 측정

Groundwork의 효과를 다음 지표로 측정할 수 있습니다:

| 지표 | 측정 방법 | 목표 |
|------|---------|------|
| **컨텍스트 정확도** | Claude의 제안이 프로젝트와 일치하는 비율 | 90% 이상 |
| **재작업 비율** | Claude 결과물 수정 필요 비율 | 10% 이하 |
| **개발 속도** | 단위 작업당 소요 시간 | 30% 이상 단축 |
| **코드 일관성** | 코딩 스타일 위배율 | 5% 이하 |
| **문서 최신성** | 코드와 문서의 불일치율 | 5% 이하 |

---

## 핵심 원칙 (Core Principles)

이 섹션을 통해 배우게 될 Groundwork의 핵심 원칙:

1. **명확한 시작** - 모호함은 낭비다. 명확한 요구사항과 제약사항을 정의한다.
2. **AI 관점** - Claude가 이해하기 쉽게 정보를 구조화한다.
3. **재사용성** - 일회성 솔루션이 아닌, 반복 사용 가능한 패턴을 설계한다.
4. **진화** - 처음부터 완벽할 필요는 없다. 프로젝트와 함께 진화시킨다.
5. **일관성** - 규칙과 패턴으로 전체 프로젝트의 일관성을 유지한다.

---

## 다음 단계

Groundwork를 이해했다면:

1. **[Two-Instance Kickoff Pattern](./01-two-instance-kickoff.md)** 부터 시작하세요
2. 실제 프로젝트에 적용해보세요
3. **[llms.txt Pattern](./02-llms-txt-pattern.md)** 문서를 작성하세요
4. **[Reusable Patterns Philosophy](./03-reusable-patterns-philosophy.md)** 를 검토하세요

---

**작성자**: claude-automate 문서팀
**마지막 수정**: 2026년 1월
**상태**: 작성 중

---

<div align="center">

### 좋은 기초가 좋은 건물을 만듭니다.

**철저한 Groundwork로 프로젝트 성공을 보장하세요.**

</div>
