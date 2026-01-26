# Context & Memory Management

## 개요

**Context & Memory Management**는 Claude Automate의 핵심 기능으로, 개발 세션 간의 연속성을 유지하고 효율적인 컨텍스트 관리를 통해 개발 생산성을 극대화합니다.

### 왜 중요한가?

개발 작업은 종종 여러 세션에 걸쳐 진행됩니다. Claude와의 상호작용에서는:

- **문맥 손실**: 이전 세션의 중요한 정보가 새 세션에서 손실될 수 있습니다
- **Token 비효율**: 매 세션마다 동일한 정보를 다시 입력하면 불필요한 token을 소비합니다
- **학습 미흡**: 개발 과정에서 얻은 인사이트가 체계적으로 기록되지 않습니다
- **의사결정 지연**: 이전 작업 상황을 파악하는 데 시간이 소요됩니다

Context & Memory Management는 이러한 문제들을 해결하여:

1. **세션 연속성** - 이전 작업 내용 자동 로드
2. **효율적인 Context** - 필요한 정보만 압축하여 저장
3. **지속적인 학습** - 개발 과정에서의 인사이트 자동 기록
4. **빠른 재개** - 정확한 지점부터 작업 시작 가능

---

## 6개 핵심 서브섹션

이 섹션에서는 Context & Memory Management의 주요 개념과 구현 방식을 다룹니다:

### 1. [Session Storage](./01-session-storage.md)
세션 정보를 어떻게 저장하고 관리하는지 설명합니다.

- Session context 파일의 구조
- 자동 저장 메커니즘
- 세션 메타데이터 관리
- Context 파일 위치 및 네이밍 규칙

### 2. [Strategic Compacting](./02-strategic-compacting.md)
장기 세션에서 context를 효율적으로 압축하는 전략을 다룹니다.

- Context 크기 모니터링
- 정보 손실 없는 압축 기법
- 우선순위 기반 정보 유지
- Compacting 트리거 조건

### 3. [Strategic Compact Skill](./03-strategic-compact-skill.md)
Context 압축을 자동화하는 skill의 구현과 사용법을 설명합니다.

- 자동 모니터링: PreToolUse Hook을 통한 실시간 감지
- Counter Mechanism: 도구 실행 횟수 기반 임계값 로직
- 완전한 Bash 스크립트: 설치 및 커스터마이제이션 방법
- JSON Hook 설정: PreToolUse 훅 연결 방법
- 실무 팁: 세션별 최적 설정 및 트러블슈팅
- 고급 확장: 자동 압축 및 외부 서비스 연동

### 4. [Dynamic System Prompt Injection](./04-dynamic-system-prompt.md)
CLI 플래그를 통한 동적 system prompt 주입 기법을 다룹니다.

- 핵심 개념: System prompt와 dynamic injection의 정의
- @file vs --system-prompt 비교표
- 우선순위 계층 구조 (5단계)
- 실전 설정: CLI Alias 패턴 (4단계 구현)
- 컨텍스트 파일 예시 (dev, review, research)
- 장점/단점 정리 및 저자 의견

### 5. [Memory Persistence Hooks](./05-memory-persistence-hooks.md)
Workflow 중 메모리 상태를 유지하는 hook 메커니즘을 설명합니다.

- Hook 시스템의 구조
- Persistence point 정의
- State 저장 및 복구
- Hook chain 관리

### 6. [Continuous Learning](./06-continuous-learning.md)
개발 세션에서의 인사이트를 자동으로 추출하고 기록하는 방식을 다룹니다.

- TIL (Today I Learned) 시스템
- 인사이트 자동 추출
- 학습 기록 관리
- 피드백 루프 통합

---

## 학습 경로

처음 Context & Memory Management를 학습하는 분이라면:

1. **[Session Storage](./01-session-storage.md)** 부터 시작하여 기본 개념을 이해합니다
2. **[Strategic Compacting](./02-strategic-compacting.md)** 에서 효율성 개념을 학습합니다
3. **[Strategic Compact Skill](./03-strategic-compact-skill.md)** 로 실제 구현을 살펴봅니다
4. **[Dynamic System Prompt Injection](./04-dynamic-system-prompt-injection.md)** 에서 고급 응용을 배웁니다
5. **[Memory Persistence Hooks](./05-memory-persistence-hooks.md)** 로 복잡한 상태 관리를 이해합니다
6. **[Continuous Learning](./06-continuous-learning.md)** 으로 마무리합니다

---

## 주요 개념 요약

| 개념 | 설명 |
|------|------|
| **Session Context** | 현재 개발 세션의 상태와 정보를 담은 문서 |
| **Context Compacting** | Token 효율성을 위해 context 크기를 줄이는 과정 |
| **Dynamic Prompting** | Session 정보에 기반해 system prompt를 실시간으로 조정 |
| **Memory Hooks** | Workflow 단계별로 상태를 저장/복구하는 지점 |
| **Continuous Learning** | 각 세션의 인사이트를 자동으로 수집 및 기록 |

---

## 관련 문서

- [main README](../../README.md) - Claude Automate 프로젝트 개요
- [longform-guide](../) - 기타 longform 가이드들

---

**작성자**: claude-automate 문서팀
**마지막 수정**: 2026년 1월
**상태**: 작성 중

