# Hook Script Pattern

> Claude Code hook 스크립트 작성 시 따르는 구조와 규칙

---

## 언제 사용

- 새 hook 스크립트 생성 시
- 기존 hook 스크립트 수정 시
- PreToolUse, PreCompact, Stop 등 hook 종류 구현 시

---

## 파일 위치

```
hooks/{hook-name}.sh
hooks/hooks.json  # hook 등록
```

---

## 필수 패턴

### 1. 안전한 스크립트 시작

```bash
#!/bin/bash
set -euo pipefail
```

- `set -e`: 오류 발생 시 즉시 종료
- `set -u`: 미정의 변수 사용 시 오류
- `set -o pipefail`: 파이프 중간 오류도 감지

---

### 2. stdin에서 JSON 파싱 (jq 사용)

Claude Code hook은 stdin으로 JSON 이벤트를 전달받는다.

```bash
# stdin 전체 읽기
INPUT=$(cat)

# jq로 필드 추출
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')
```

- `// ""`: 필드 없을 때 빈 문자열 (graceful fallback)
- `-r`: raw 출력 (따옴표 제거)

---

### 3. stdout으로 JSON 출력

hook 결과는 stdout으로 JSON을 출력한다.

```bash
# 통과 (아무것도 출력하지 않거나 빈 JSON)
echo '{}'

# 차단 (PreToolUse에서 도구 실행 막기)
echo '{"decision": "block", "reason": "이유 설명"}'
```

---

### 4. 디렉토리 보장 (mkdir -p)

파일을 쓰기 전에 디렉토리가 존재하는지 보장한다.

```bash
STATE_DIR=".claude/state"
mkdir -p "$STATE_DIR"

echo "idle" > "$STATE_DIR/mode"
```

- `mkdir -p`: 중간 디렉토리도 모두 생성, 이미 있어도 오류 없음

---

### 5. Graceful Fallback (파일 없으면 기본값)

파일이 없을 때 기본값을 사용한다.

```bash
MODE_FILE=".claude/state/mode"

if [ -f "$MODE_FILE" ]; then
  CURRENT_MODE=$(cat "$MODE_FILE")
else
  CURRENT_MODE="idle"
fi
```

또는 한 줄로:

```bash
CURRENT_MODE=$(cat "$MODE_FILE" 2>/dev/null || echo "idle")
```

---

### 6. exit 0 = 통과

hook 스크립트에서 `exit 0`은 "정상 처리, 진행 허용"을 의미한다.

```bash
# 처리 완료, 도구 실행 허용
exit 0
```

- `exit 0`: 통과 (hook이 정상 완료됨)
- `exit 1`: 오류 (예외 상황, 로그 남김)
- JSON `{"decision": "block"}`: 도구 실행 차단

---

## 전체 예시

```bash
#!/bin/bash
set -euo pipefail

# stdin에서 이벤트 읽기
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""')

# 상태 디렉토리 보장
STATE_DIR=".claude/state"
mkdir -p "$STATE_DIR"

# 현재 mode 읽기 (없으면 기본값)
MODE_FILE="$STATE_DIR/mode"
CURRENT_MODE=$(cat "$MODE_FILE" 2>/dev/null || echo "idle")

# 조건 처리
if [ "$TOOL_NAME" = "Write" ] && [ "$CURRENT_MODE" = "planning" ]; then
  echo '{"decision": "block", "reason": "planning 모드에서는 파일 쓰기 불가"}'
  exit 0
fi

# 통과
exit 0
```

---

## 따라야 할 것

1. **`set -euo pipefail` 필수**: 예상치 못한 오류 방지
2. **`jq`로 JSON 파싱**: 수동 파싱 금지
3. **`// ""`로 기본값**: 필드 없을 때 빈 문자열 fallback
4. **`mkdir -p`**: 파일 쓰기 전 디렉토리 생성 보장
5. **`exit 0`으로 종료**: 통과 시 명시적 exit 0
6. **`2>/dev/null || echo "default"`**: 파일 없을 때 기본값

---

## 피해야 할 것

- stdin 읽지 않고 바로 처리 (이벤트 정보 손실)
- jq 없이 직접 문자열 파싱 (`grep`, `sed` 등)
- 디렉토리 존재 확인 없이 파일 쓰기
- exit 없이 스크립트 종료 (exit 코드 불명확)

---

## Hook 종류별 참고

| Hook | 트리거 | 용도 |
|------|--------|------|
| `PreToolUse` | 도구 실행 전 | 검증, 차단, 상태 업데이트 |
| `PostToolUse` | 도구 실행 후 | 결과 기록, 후처리 |
| `PreCompact` | compact 전 | 컨텍스트 저장 |
| `Stop` | 세션 종료 | 정리 작업 |

---

## 실제 구현 참고

- `hooks/session-stop.sh` - Stop Hook (기존)
- `hooks/session-start.sh` - PreToolUse Hook (신규)
- `hooks/pre-compact.sh` - PreCompact Hook (신규)

---

**Last Updated**: 2026-02-27
