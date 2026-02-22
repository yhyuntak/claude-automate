# Test Hook

> Hook에서 스킬 트리거 테스트용 스킬

## 실행

이 스킬이 호출되면:

1. `/tmp/hook-test-result.txt`에 현재 시각과 "Hook triggered skill successfully!"를 기록
2. 사용자에게 "Hook 테스트 스킬이 성공적으로 실행되었습니다!" 메시지를 출력

## 기록 방법

Bash 도구를 사용하여:
```bash
echo "$(date): Hook triggered skill successfully!" >> /tmp/hook-test-result.txt
```

## 완료 후

사용자에게 결과를 보고하고, 정상적으로 종료합니다.
