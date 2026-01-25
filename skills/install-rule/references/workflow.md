# 개발 워크플로우

> Git 브랜치 전략 + 태그 기반 릴리즈 + 백로그 관리

---

## Git 브랜치 전략

프로젝트 시작 시 두 가지 옵션 중 선택:

### 옵션 A: 단순 (main only)

**추천 대상**: 개인 프로젝트, 소규모 프로젝트

```
feature/xxx ──→ main ──→ 태그 (v0.1.0)
```

**작업 플로우**:
```bash
# 1. 작업 브랜치 생성 (선택)
git checkout -b feature/new-feature

# 2. 작업 + 커밋
git add .
git commit -m "feat: 새 기능 구현"

# 3. main에 머지
git checkout main
git merge feature/new-feature
git push origin main

# 4. 브랜치 정리
git branch -d feature/new-feature
```

---

### 옵션 B: 표준 (develop/main/태그)

**추천 대상**: 팀 프로젝트, 배포 환경 분리 필요

```
v0.1.0 (태그) ──→ Production
    │
main (릴리즈 준비 완료)
    ↑
develop (개발 중)
    ↑
feature/xxx (작업 브랜치)
```

**브랜치 타입**:
| 타입 | 용도 | 머지 대상 | 예시 |
|------|------|----------|------|
| `feature/*` | 새 기능 | `develop` | `feature/user-auth` |
| `fix/*` | 버그 수정 | `develop` | `fix/login-error` |
| `hotfix/*` | 긴급 수정 | `main` + `develop` | `hotfix/security-patch` |

**작업 플로우**:
```bash
# 1. develop에서 브랜치 생성
git checkout develop
git pull origin develop
git checkout -b feature/new-feature

# 2. 작업 + 커밋
git add .
git commit -m "feat: 새 기능 구현"

# 3. develop에 머지
git checkout develop
git merge feature/new-feature
git push origin develop

# 4. 브랜치 정리
git branch -d feature/new-feature
```

---

## 버전 관리 (Semantic Versioning)

```
v{MAJOR}.{MINOR}.{PATCH}

MAJOR: 호환성 깨지는 변경 (v1.0.0 → v2.0.0)
MINOR: 새 기능 추가 (v0.1.0 → v0.2.0)
PATCH: 버그 수정 (v0.1.0 → v0.1.1)
```

### 릴리즈 절차

**옵션 A (단순):**
```bash
# main에서 태그 생성
git tag -a v0.1.0 -m "첫 번째 릴리즈"
git push origin v0.1.0
```

**옵션 B (표준):**
```bash
# 1. develop을 main에 머지
git checkout main
git pull origin main
git merge develop
git push origin main

# 2. 태그 생성
git tag -a v0.1.0 -m "첫 번째 릴리즈"
git push origin v0.1.0

# 3. (선택) GitHub Release 생성
gh release create v0.1.0 --title "v0.1.0" --notes "릴리즈 노트..."
```

---

## 백로그 관리

> 상세: [backlog-rules.md](backlog-rules.md)

백로그는 `docs/backlogs/` 폴더에서 todo/doing/done 구조로 관리됩니다.

### 통합 워크플로우

**1. 작업 선택 및 시작**
```bash
# README.md에서 todo/ 폴더의 작업 선택
mv docs/backlogs/todo/phase1-001-feature.md \
   docs/backlogs/doing/
```

**2. 구현 + 커밋**
```bash
git add .
git commit -m "feat: phase1-001 구현"
git push origin main  # 또는 develop
```

**3. 작업 완료**
```bash
mv docs/backlogs/doing/phase1-001-feature.md \
   docs/backlogs/done/

# README.md 업데이트 (상태, 링크 경로, 현황 개수)
```

---

## 커밋 메시지 규칙

```
<type>: <description>

# 타입
feat:     새 기능
fix:      버그 수정
refactor: 리팩토링
docs:     문서 변경
chore:    기타 (의존성, 설정 등)
style:    코드 스타일
test:     테스트 추가/수정
```

---

**Last Updated**: {LAST_UPDATE_DATE}
