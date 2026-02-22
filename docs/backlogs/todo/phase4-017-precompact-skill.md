# PreCompact 스킬

> compact 전 사용자가 수동으로 현재 맥락을 요약 저장하는 스킬

---

## User Story

CA 사용자가 컨텍스트가 차기 전에 /precompact를 실행하면, 현재 대화의 핵심 맥락(결정사항, 진행 상태, 다음 단계)이 파일로 저장되어 compact 후에도 맥락이 유지된다.

## Acceptance Criteria

- [ ] /precompact 스킬 설계: 현재 대화에서 핵심 맥락을 LLM이 요약
- [ ] 저장 포맷 정의 (결정사항, 진행 상태, 다음 단계, 작업 중인 파일 등)
- [ ] 저장 위치 결정 (.claude/context/compact-state.md 등)
- [ ] SessionStart(compact) Hook 설계: 저장된 파일을 컨텍스트에 재주입
- [ ] 타이밍 가이드: 컨텍스트 70~80%에서 실행 권장

## 배경

- compact는 대화 요약 시 "왜" 그런 결정을 했는지 등 맥락이 유실됨
- Hook(PreCompact)은 command 타입만 지원하여 LLM 요약 불가
- ECC도 트랜스크립트 메타데이터만 저장, 의미있는 맥락 복원은 미해결
- 스킬은 대화 안에서 실행되므로 전체 맥락 접근 가능 → LLM 요약 가능

## Dependencies

- phase4-005 (hook-system) 논의에서 도출

---

**Last Updated**: 2026-02-21
