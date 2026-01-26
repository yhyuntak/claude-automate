# 모듈화된 코드베이스: 토큰 비용 최적화

## Overview (개요)

**모듈화된 코드베이스(Modular Codebase)는 토큰 효율성의 기초입니다.**

이 문서에서는 왜 파일 구조와 모듈 크기가 Claude와 작업할 때 토큰 비용에 직접적인 영향을 미치는지, 그리고 어떻게 이를 최적화하는지 설명합니다.

### 핵심 원리

Claude가 파일을 읽을 때, **전체 파일 내용이 context에 로드됩니다.** 불필요한 코드까지 읽어야 하므로 토큰을 낭비하게 됩니다.

```
파일 크기 ↑ → 로드되는 토큰 ↑ → Context 사용 ↑ → 비용 ↑
```

---

## 핵심 개념

### 1. Claude의 파일 읽기 방식

Claude Code가 파일을 읽을 때의 토큰 비용을 이해해야 합니다.

#### ❌ 문제: 큰 단일 파일 (Monolithic File)

```
src/services.js (5,000 줄)
├── UserService (500줄)
├── ProductService (600줄)
├── OrderService (700줄)
├── PaymentService (800줄)
├── EmailService (500줄)
├── CacheService (600줄)
├── LoggingService (400줄)
└── ... 기타 (800줄)
```

**문제점:**
- UserService만 필요해도 **5,000줄 전체를 읽어야 함**
- 불필요한 4,500줄의 코드가 context에 로드됨
- 매번 동일한 토큰 낭비 반복
- 코드 이해 어려움 (모든 것이 섞여있음)

**토큰 비용**: 약 15,000 - 20,000 토큰 (전체 파일)

#### ✅ 해결: 모듈화된 파일 (Modular Files)

```
src/services/
├── user-service.ts (500줄)
├── product-service.ts (600줄)
├── order-service.ts (700줄)
├── payment-service.ts (800줄)
├── email-service.ts (500줄)
├── cache-service.ts (600줄)
├── logging-service.ts (400줄)
└── index.ts (50줄)
```

**장점:**
- UserService만 필요하면 **500줄만 읽음**
- 필요한 파일만 context에 로드
- 명확한 책임 분리 (Single Responsibility)
- 코드 이해가 쉬움

**토큰 비용**: 약 1,500 - 2,000 토큰 (필요한 파일만)

**절감 효과**: 87.5% 토큰 절감 (20,000 → 2,500)

---

### 2. 수백 줄 vs 수천 줄: 경계값

파일 크기별 토큰 비용과 인지 부담을 분석합니다.

#### 파일 크기 분류

| 파일 크기 | 줄 수 | 토큰 | 특징 | 인지 부담 |
|----------|------|------|------|---------|
| **Tiny** | < 50줄 | 150-300 | 단순 유틸 함수 | 매우 낮음 |
| **Small** | 50-200줄 | 300-1,000 | 단일 기능 모듈 | 낮음 |
| **Medium** | 200-500줄 | 1,000-2,500 | 복잡한 클래스 | 중간 |
| **Large** | 500-1,000줄 | 2,500-5,000 | 여러 관련 기능 | 높음 |
| **Monolithic** | > 1,000줄 | > 5,000 | 다양한 책임 | 매우 높음 |

#### 최적 파일 크기

**권장 사항:**
- **이상적**: 200-400줄 (사람이 한 번에 이해 가능)
- **최대값**: 500줄 (이 이상이면 분할 고려)
- **절대 금지**: 1,000줄 이상 (거의 항상 분할 가능)

**이유:**
1. **토큰 효율성**: 필요한 부분만 로드
2. **인지 부담**: 개발자와 Claude 모두 이해하기 쉬움
3. **유지보수성**: 변경 영향 범위 최소화
4. **테스트**: 단위 테스트 작성 용이

---

### 3. Claude가 파일을 읽을 때의 토큰 비용

#### 실제 계산 예시

**Python 기준 (일반적으로 1줄 ≈ 3-5 토큰)**

```
함수:
def process_user_data(user_id, action):
    # 약 1줄 = 3-5 토큰
    # 100줄 함수 = 300-500 토큰
```

#### 예제: 실제 파일 읽기 비용

```
시나리오: UserRepository의 findById() 메서드를 찾아야 함
```

**❌ 선택지 1: 대형 파일 (1,500줄) - UserRepository.ts**
```
파일 전체 로드 → 1,500줄 × 4토큰 = 6,000 토큰 낭비
읽기 시간: 5-10초
```

**✅ 선택지 2: 모듈화 파일 (150줄) - user.repository.ts**
```
파일 전체 로드 → 150줄 × 4토큰 = 600 토큰 (효율적)
읽기 시간: 1-2초
```

**절감**: 5,400 토큰 (90% 감소), 4-8초 시간 절감

---

## 최적 디렉토리 구조

### 패턴: `root/src/modules/` 구조

Claude와 효율적으로 작업하기 위한 최적의 디렉토리 구조입니다.

```
project-root/
│
├── docs/                          # 문서 (별도 유지)
│   ├── API.md
│   └── ARCHITECTURE.md
│
├── src/
│   │
│   ├── modules/                   # 핵심: 기능별 모듈
│   │   │
│   │   ├── user/
│   │   │   ├── user.entity.ts         (50-100줄) - 데이터 모델
│   │   │   ├── user.repository.ts     (150-200줄) - DB 접근
│   │   │   ├── user.service.ts        (200-300줄) - 비즈니스 로직
│   │   │   ├── user.controller.ts     (100-150줄) - API 엔드포인트
│   │   │   ├── user.dto.ts            (50-80줄) - 요청/응답 스키마
│   │   │   ├── user.validation.ts     (80-120줄) - 입력 검증
│   │   │   └── index.ts               (10-20줄) - 공개 인터페이스
│   │   │
│   │   ├── product/
│   │   │   ├── product.entity.ts      (40-80줄)
│   │   │   ├── product.repository.ts  (150-200줄)
│   │   │   ├── product.service.ts     (200-300줄)
│   │   │   ├── product.controller.ts  (120-160줄)
│   │   │   ├── product.dto.ts         (50-80줄)
│   │   │   ├── product.validation.ts  (80-120줄)
│   │   │   └── index.ts               (10-20줄)
│   │   │
│   │   ├── order/
│   │   │   ├── order.entity.ts        (60-100줄)
│   │   │   ├── order.repository.ts    (180-250줄)
│   │   │   ├── order.service.ts       (250-350줄)
│   │   │   ├── order.controller.ts    (150-200줄)
│   │   │   ├── order.dto.ts           (80-120줄)
│   │   │   ├── order.validation.ts    (100-150줄)
│   │   │   └── index.ts               (10-20줄)
│   │   │
│   │   ├── payment/
│   │   │   ├── payment.entity.ts      (50-100줄)
│   │   │   ├── payment.gateway.ts     (200-300줄) - 외부 API 연동
│   │   │   ├── payment.service.ts     (200-300줄)
│   │   │   ├── payment.controller.ts  (100-150줄)
│   │   │   ├── payment.dto.ts         (60-100줄)
│   │   │   └── index.ts               (10-20줄)
│   │   │
│   │   └── auth/
│   │       ├── auth.strategy.ts       (150-200줄) - JWT/OAuth
│   │       ├── auth.guard.ts          (100-150줄) - 접근 제어
│   │       ├── auth.service.ts        (200-300줄)
│   │       ├── auth.dto.ts            (40-60줄)
│   │       └── index.ts               (10-20줄)
│   │
│   ├── shared/                    # 공유 코드 (작은 파일들)
│   │   │
│   │   ├── constants/
│   │   │   ├── config.ts              (20-50줄)
│   │   │   ├── errors.ts              (30-60줄)
│   │   │   └── messages.ts            (40-80줄)
│   │   │
│   │   ├── utils/
│   │   │   ├── logger.ts              (50-100줄)
│   │   │   ├── validators.ts          (60-120줄)
│   │   │   ├── formatters.ts          (50-100줄)
│   │   │   ├── crypto.ts              (50-100줄)
│   │   │   ├── date-helper.ts         (40-80줄)
│   │   │   └── index.ts               (20줄)
│   │   │
│   │   ├── decorators/
│   │   │   ├── auth.decorator.ts      (30-50줄)
│   │   │   ├── validation.decorator.ts (40-70줄)
│   │   │   └── index.ts               (10줄)
│   │   │
│   │   ├── middleware/
│   │   │   ├── error-handler.ts       (60-100줄)
│   │   │   ├── request-logger.ts      (40-80줄)
│   │   │   ├── cors.ts                (30-60줄)
│   │   │   └── index.ts               (10줄)
│   │   │
│   │   ├── types/
│   │   │   ├── index.ts               (100-150줄) - 전역 타입
│   │   │   ├── errors.ts              (50-80줄)
│   │   │   └── api-response.ts        (30-50줄)
│   │   │
│   │   └── index.ts                   (20-30줄)
│   │
│   ├── config/                    # 설정 (매우 작음)
│   │   ├── database.config.ts        (30-50줄)
│   │   ├── cache.config.ts           (20-40줄)
│   │   ├── env.config.ts             (30-50줄)
│   │   └── index.ts                  (10줄)
│   │
│   ├── app.ts                     # 메인 앱 초기화 (50-100줄)
│   └── main.ts                    # 진입점 (10-20줄)
│
├── test/                          # 테스트 (모듈 구조 반영)
│   ├── unit/
│   │   ├── modules/
│   │   │   ├── user.service.spec.ts
│   │   │   ├── product.service.spec.ts
│   │   │   ├── order.service.spec.ts
│   │   │   └── payment.service.spec.ts
│   │   └── shared/
│   │       └── validators.spec.ts
│   │
│   └── integration/
│       ├── user-flow.spec.ts
│       └── order-flow.spec.ts
│
├── .env.example
├── package.json
├── tsconfig.json
├── .gitignore
└── README.md
```

---

## 구조의 핵심 원칙

### 1. 모듈 독립성 (Module Independence)

**각 모듈은 독립적으로 동작할 수 있어야 합니다.**

```typescript
// ✅ 올바른 방식
// src/modules/user/index.ts
export { UserService } from './user.service';
export { UserController } from './user.controller';
export { UserRepository } from './user.repository';
export type { User } from './user.entity';

// 사용처
import { UserService } from 'src/modules/user';
```

```typescript
// ❌ 잘못된 방식 (순환 참조)
// src/modules/user/user.service.ts
import { OrderService } from '../order/order.service'; // 순환 참조 위험!
import { PaymentService } from '../payment/payment.service'; // 더 많은 로드!
```

### 2. 계층 명확성 (Layer Clarity)

각 파일은 역할이 명확해야 합니다:

| 파일명 | 역할 | 책임 | 크기 |
|--------|------|------|------|
| `.entity.ts` | 데이터 모델 | 스키마 정의 | 50-100줄 |
| `.repository.ts` | DB 접근 | CRUD 쿼리 | 150-250줄 |
| `.service.ts` | 비즈니스 로직 | 도메인 로직 | 200-350줄 |
| `.controller.ts` | HTTP 엔드포인트 | 요청 처리 | 100-200줄 |
| `.dto.ts` | 전송 객체 | 스키마 검증 | 50-100줄 |
| `.validation.ts` | 유효성 검사 | 입력 검증 | 80-150줄 |

### 3. 파일 크기 제약 (Size Constraints)

```typescript
// ✅ 좋은 예: 각 파일이 명확한 책임을 가짐
// user.service.ts (250줄)
export class UserService {
  // 사용자 관련 비즈니스 로직만
  async createUser(dto: CreateUserDto) { ... }
  async updateUser(id: string, dto: UpdateUserDto) { ... }
  async deleteUser(id: string) { ... }
  async findUserById(id: string) { ... }
}

// ❌ 나쁜 예: 모든 것을 한 파일에
// user.service.ts (1,500줄)
export class UserService {
  // 사용자 관리
  async createUser(dto: CreateUserDto) { ... }
  // 주문 처리
  async createOrder(dto: CreateOrderDto) { ... }
  // 결제 처리
  async processPayment(dto: PaymentDto) { ... }
  // 메일 발송
  async sendEmail(to: string, body: string) { ... }
  // ... 수백 줄 더 ...
}
```

---

## Dead Code 제거의 중요성

### Dead Code의 숨은 비용

**Dead Code(사용되지 않는 코드)는 토큰을 낭비합니다.**

```typescript
// ❌ Dead Code 예제
export class UserService {
  async createUser(dto: CreateUserDto) { ... }
  async updateUser(id: string, dto: UpdateUserDto) { ... }
  async deleteUser(id: string) { ... }

  // 더 이상 사용하지 않는 이전 메서드들
  async legacyCreateUser(name: string, email: string) { ... }
  async legacyUpdateUser(id: string, name: string) { ... }
  async oldPasswordReset(userId: string) { ... }
  async deprecatedEmailVerification(email: string) { ... }
  async unusedReportGeneration() { ... }
  // ... 수십 줄 ...
}
```

**문제점:**
- 파일을 읽을 때마다 이 코드들도 context에 로드됨
- 1,000줄 → 800줄 실제 코드 + 200줄 dead code
- 20% 토큰 낭비
- 개발자 혼란 (어떤 메서드를 써야 하나?)

### Dead Code 식별 및 제거

#### 1. 자동 식별 도구

```bash
# TypeScript - 사용하지 않는 코드 찾기
npm install --save-dev ts-unused-exports

# ESLint - 미사용 변수
npm install --save-dev eslint-plugin-unused-imports
```

#### 2. 수동 검사 체크리스트

```
함수/메서드:
  [ ] grep으로 함수명 검색했나? (1개 이상 사용처 확인)
  [ ] 테스트에서 참조되나?
  [ ] 문서에 언급되나?
  [ ] 외부 API 노출되나?

변수:
  [ ] 할당된 후 사용되나?
  [ ] 타입스크립트 strict mode에서 경고되나?

클래스/모듈:
  [ ] import되나?
  [ ] 다른 파일에서 참조되나?
  [ ] 테스트에서 사용되나?
```

#### 3. 제거 전 안전성

**반드시 버전 관리 사용:**

```bash
# 1. 모든 변경사항 커밋
git add .
git commit -m "chore: commit before cleanup"

# 2. Dead code 제거
# (파일 수정)

# 3. 테스트 실행
npm test

# 4. 이슈 발생 시 롤백 가능
git revert HEAD
```

### Dead Code 제거 효과

```
Before:
user.service.ts: 500줄 (실제 코드 350줄 + dead code 150줄)
로드 토큰: 2,000토큰

After:
user.service.ts: 350줄 (모두 사용 중인 코드)
로드 토큰: 1,400토큰

절감: 600토큰 (30% 감소) per 파일 로드
```

---

## 리팩토링 Skill 활용

### Refactor Skill이란?

Claude Automate의 `refactor` skill은 **대규모 코드 구조 변경을 자동화합니다.**

```bash
/refactor "split monolithic user.service.ts into smaller modules"
```

### 리팩토링 전략

#### 1. 기획 단계

```
목표: src/services/user.service.ts (1,200줄)를 모듈화
      → src/modules/user/ 로 재구조화

Plan:
  1. user.entity.ts 추출 (현재 100줄)
  2. user.repository.ts 추출 (현재 250줄)
  3. user.validation.ts 추출 (현재 120줄)
  4. user.service.ts 재정의 (현재 500줄 → 250줄)
  5. index.ts 작성 (20줄)
  6. imports 모두 업데이트
  7. 테스트 실행
```

#### 2. Skill 실행

```bash
/refactor "
  목표: user service 모듈화

  현재 구조:
  src/services/user.service.ts (1,200줄)

  목표 구조:
  src/modules/user/
  ├── user.entity.ts
  ├── user.repository.ts
  ├── user.service.ts
  ├── user.validation.ts
  └── index.ts

  요구사항:
  1. 데이터 모델 분리
  2. DB 로직 분리
  3. 검증 로직 분리
  4. 비즈니스 로직은 service에 유지
  5. 모든 imports 자동 업데이트
  6. 테스트 실행 후 확인
"
```

#### 3. 수동 검증

```typescript
// 1. 파일 분리 확인
ls -la src/modules/user/

// 2. Imports 확인
grep -r "from.*user" src/ | grep -v node_modules

// 3. 테스트 실행
npm test -- user

// 4. 빌드 확인
npm run build

// 5. 타입 검사
tsc --noEmit
```

### Refactor Skill의 장점

| 측면 | 수동 리팩토링 | Skill 사용 |
|------|------------|---------|
| **속도** | 수시간 | 분 단위 |
| **정확성** | 수동 실수 위험 | 자동화됨 |
| **테스트** | 수동 테스트 | 자동 검증 |
| **문서화** | 별도 작성 | 자동 생성 |
| **Imports** | 모두 수동 수정 | 자동 업데이트 |
| **타입 안정성** | 검사 필요 | TypeScript 검사 |

---

## 실제 적용 사례

### 사례 1: 소규모 프로젝트 (Express + TypeScript)

```
Before (비효율적):
src/
├── server.js (2,000줄) ← 모든 코드가 여기!
└── database.js (800줄)

토큰 비용: 기능 하나 수정 시 2,000줄 읽어야 함 = 8,000토큰

After (모듈화):
src/modules/
├── user/ (200줄)
├── product/ (250줄)
├── order/ (200줄)
└── auth/ (150줄)

토큰 비용: 한 모듈만 수정하면 200줄만 읽음 = 800토큰

절감: 90% (8,000 → 800토큰)
```

### 사례 2: 중규모 프로젝트 (NestJS)

```
Before:
src/services/
├── auth.service.ts (600줄)
├── user.service.ts (800줄)
├── product.service.ts (700줄)
└── order.service.ts (900줄)

한 파일 수정 시: 600-900줄 = 3,000-4,500토큰

After:
src/modules/
├── auth/ (8개 파일, 각 50-150줄)
├── user/ (7개 파일, 각 50-200줄)
├── product/ (7개 파일, 각 50-200줄)
└── order/ (8개 파일, 각 50-200줄)

한 모듈의 한 부분 수정 시: 100-200줄 = 400-800토큰

절감: 75-85%
```

---

## 체크리스트: 모듈화 준비

### 현재 상태 평가

```
코드베이스 구조:

1. 파일 크기 분석
   [ ] 500줄 이상인 파일이 몇 개인가?
   [ ] 1,000줄 이상인 파일이 있는가?
   [ ] 평균 파일 크기는?

2. 책임 분리
   [ ] 한 파일에 여러 개념이 섞여있나?
   [ ] Entity와 Service가 혼재되어있나?
   [ ] DB 접근과 비즈니스 로직이 함께 있나?

3. Dead Code 현황
   [ ] 사용하지 않는 함수가 몇 개인가?
   [ ] 이전 버전 코드가 남아있나?
   [ ] 테스트되지 않는 코드가 있나?

4. 모듈 의존성
   [ ] 순환 참조가 있나?
   [ ] 모든 모듈이 다른 모듈에 의존하나?
   [ ] 공통 의존성이 명확한가?
```

### 리팩토링 우선순위

```
1순위 - 가장 큰 파일부터:
   [ ] 1,000줄 이상 파일 분할

2순위 - Dead code 제거:
   [ ] 미사용 함수/변수 제거

3순위 - 계층 정리:
   [ ] 각 파일의 책임 명확화

4순위 - 모듈 구조:
   [ ] 디렉토리 구조 최적화

5순위 - 인덱스 파일:
   [ ] 공개 인터페이스 정의 (index.ts)
```

---

## 측정 및 모니터링

### 토큰 비용 측정

```bash
# 1. 파일 크기 분포 확인
find src -type f -name "*.ts" -o -name "*.js" | \
  xargs wc -l | sort -rn | head -20

# 2. Dead code 감지
npm install --save-dev ts-unused-exports
ts-unused-exports src/

# 3. 모듈 복잡도
npm install --save-dev complexity-report
complexity-report --path src/

# 4. 의존성 분석
npm install --save-dev depcheck
depcheck
```

### 개선 지표

```
메트릭: 평균 파일 크기

목표: 파일당 평균 250줄 이하

추적:
  Week 1: 평균 450줄 (리팩토링 전)
  Week 2: 평균 350줄 (첫 번째 리팩토링)
  Week 3: 평균 280줄 (Dead code 제거)
  Week 4: 평균 240줄 (최종 최적화)

토큰 비용 개선:
  Before: 파일당 평균 1,800토큰
  After: 파일당 평균 960토큰
  절감: 46% (약 840토큰/파일)
```

---

## FAQ

### Q1: 너무 작은 파일들이 많으면 관리가 어렵지 않나?

**A:** 맞습니다. 그래서 `index.ts`가 있습니다.

```typescript
// src/modules/user/index.ts
export { UserService } from './user.service';
export { UserController } from './user.controller';
export { UserRepository } from './user.repository';
export type { User, CreateUserDto, UpdateUserDto } from './user.entity';

// 사용처: 한 줄로 모든 것을 임포트
import { UserService, UserController, User } from 'src/modules/user';
```

### Q2: 작은 프로젝트에도 이 구조가 필요한가?

**A:** 프로젝트 규모에 따라 조정하세요.

```
규모별 권장:

소규모 (< 5개 모듈):
  src/
  ├── modules/user/
  ├── modules/auth/
  ├── shared/
  └── app.ts

중규모 (5-20개 모듈):
  위의 구조 유지

대규모 (> 20개 모듈):
  기본 구조 + feature별 폴더 추가
  src/
  ├── modules/
  │   └── feature-A/
  │       ├── user/
  │       ├── order/
  │       └── shared/
  └── core/
      └── shared/
```

### Q3: 기존 프로젝트를 리팩토링하려면?

**A:** 단계적으로 진행하세요.

```
Phase 1: 가장 큰 파일 분할
Phase 2: Dead code 제거
Phase 3: 나머지 파일 최적화
Phase 4: 테스트와 검증
Phase 5: 배포 및 모니터링

각 Phase는 독립적으로 테스트 가능
```

---

## 요약

### 핵심 포인트

1. **파일 크기가 토큰 비용을 결정합니다**
   - 200-400줄이 최적
   - 500줄 이상은 분할 검토

2. **모듈화의 이점**
   - 토큰 효율성: 최대 90% 절감 가능
   - 유지보수성: 코드 이해 및 수정 용이
   - 재사용성: 모듈 독립 실행 가능

3. **디렉토리 구조가 중요합니다**
   - `src/modules/[feature]/` 패턴 추천
   - 계층별 책임 분리 (entity, repository, service 등)
   - `index.ts`로 공개 인터페이스 정의

4. **Dead code 제거는 필수**
   - 자동 감지 도구 사용
   - 정기적인 정리
   - 버전 관리로 안전성 보장

5. **리팩토링은 점진적으로**
   - Refactor skill 활용
   - 큰 파일부터 시작
   - 각 단계 후 테스트

### 다음 단계

- [Token Optimization README](./README.md)로 돌아가기
- [Context Management](../01-context-memory/) 학습
- 자신의 프로젝트에 적용 시작

---

**작성**: Claude Automate 문서팀
**마지막 수정**: 2026년 1월
**상태**: 완성
