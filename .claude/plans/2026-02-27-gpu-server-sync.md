---
status: in_progress
created: 2026-02-27
slug: gpu-server-sync
test-command:
---

# Plan: gpu-server-sync

## 요구사항

### Context (배경)
- 맥북의 Claude Code 환경을 24시간 가동 GPU 서버(Ubuntu, RTX 5080)에 동기화
- 서버에 Claude Code v2.0.50 설치됨, flovy/flovy-image-gen 클론 완료
- 글로벌 rules 중 일부가 플러그인과 동기화 안 됨 (agent-delegation 정책 차이)
- design-system.md가 Flovy 전용인데 글로벌에 위치

### What (무엇을)
- 플러그인 rules 최신화 (agent-delegation, skill-writing 추가)
- design-system.md를 Flovy 프로젝트로 이동
- GPU 서버에 글로벌 설정 + 플러그인 동기화

### Why (왜)
- 서버에서 Remote Control/SSH로 Claude Code 사용 가능하게
- 플러그인 install만으로 환경 통일 가능하게
- Flovy 전용 룰이 글로벌에서 다른 프로젝트에 영향 주지 않게

### Scope
- ✅ In: 플러그인 rules 업데이트, Flovy design-system 이동, 서버 설정 동기화
- ❌ Out: 세션 히스토리 마이그레이션, 다른 프로젝트 동기화, Remote Control 설정

## Brain 업데이트

- decisions: GPU 서버 동기화 전략 - rsync + plugin install 방식 채택
- code-map: rules/ 폴더에 skill-writing.md 추가

## AC 목록

### Phase A: 플러그인 업데이트

- [ ] AC-1: rules/agent-delegation.md를 글로벌 최신 버전으로 덮어쓴다
  - TC: `diff ~/.claude/rules/agent-delegation.md ~/workspace/claude-automate/rules/agent-delegation.md` 출력 0줄

- [ ] AC-2: rules/skill-writing.md를 플러그인에 추가한다
  - TC: rules/skill-writing.md 파일 존재
  - TC: `diff ~/.claude/rules/skill-writing.md ~/workspace/claude-automate/rules/skill-writing.md` 출력 0줄

- [ ] AC-3: 버전 v0.31.0 업 + 커밋/태그
  - TC: plugin.json version = "0.31.0"
  - TC: marketplace.json version = "0.31.0"
  - TC: CHANGELOG.md에 v0.31.0 항목 존재
  - TC: git tag v0.31.0 존재

### Phase B: Flovy 프로젝트

- [ ] AC-4: design-system.md를 글로벌에서 Flovy .claude/rules/로 이동
  - TC: ~/workspace/flovy/.claude/rules/design-system.md 존재
  - TC: ~/.claude/rules/design-system.md 삭제됨
  - TC: 다른 rules 파일에서 design-system.md 참조 없음
  - TC: flovy에서 커밋/푸시 완료

### Phase C: GPU 서버 동기화

- [ ] AC-5: 글로벌 .claude/ 설정을 서버에 rsync (선행: 서버 ~/.claude/ 백업)
  - TC: 서버에 CLAUDE.md, rules/, commands/, memory/ 존재
  - TC: settings.json의 statusLine 경로가 /home/yhyuntak/.claude/statusline-command.sh

- [ ] AC-6: claude-automate 플러그인을 서버에 clone + install
  - TC: 서버에서 plugin list 출력에 claude-automate 표시

- [ ] AC-7: 서버 flovy에서 design-system.md 반영
  - TC: 서버 ~/workspace/flovy에서 git pull 후 .claude/rules/design-system.md 존재

## 구현 순서

1. [병렬] AC-1 → rules/agent-delegation.md / AC-2 → rules/skill-writing.md
2. [순차] AC-3 → plugin.json, marketplace.json, CHANGELOG.md (AC-1,2 완료 후)
3. [순차] AC-4 → ~/.claude/rules/design-system.md → ~/workspace/flovy/.claude/rules/
4. [순차] AC-5 → rsync ~/.claude/ → gpu-server:~/.claude/ (AC-3 태그 push 후)
5. [순차] AC-6 → 서버에서 plugin clone + install (AC-5 후)
6. [순차] AC-7 → 서버 flovy git pull (AC-4 push 후)
