# /session-closing — Session Closing: 세션 마무리 분석

세션 종료 전 다각도 분석으로 문서 업데이트, 자동화 기회, 배운 점, 후속 작업을 정리한다.

> Codex CLI 슬래시 커맨드로 호출되거나 자연어로 트리거된다. `$ARGUMENTS`에 사용자 입력이 주입된다.

## Execution Flow

```
┌─────────────────────────────────────────────────────┐
│  1. Check Git Status                                │
├─────────────────────────────────────────────────────┤
│  2. Phase 1: 4개 inline 분석 (각 항목별 순차 분석)  │
│     ┌─────────────────┬─────────────────┐           │
│     │  doc-updater    │  automation-    │           │
│     │  분석           │  scout 분석     │           │
│     ├─────────────────┼─────────────────┤           │
│     │  learning-      │  followup-      │           │
│     │  extractor 분석 │  suggester 분석 │           │
│     └─────────────────┴─────────────────┘           │
├─────────────────────────────────────────────────────┤
│  3. Phase 2: duplicate-checker 검증 (순차)          │
│     ┌───────────────────────────────────┐           │
│     │  Phase 1 제안 중복 여부 검증      │           │
│     └───────────────────────────────────┘           │
├─────────────────────────────────────────────────────┤
│  4. 결과 통합 & 액션 선택                           │
├─────────────────────────────────────────────────────┤
│  5. 선택한 액션 실행                                │
└─────────────────────────────────────────────────────┘
```

## Step 1: Check Git Status

```bash
git status --short
git diff --stat HEAD~3 2>/dev/null || git diff --stat
```

## Step 2: Phase 1 — 4개 inline 분석

세션 요약을 먼저 정리한 후, 아래 4개 분석을 각각 inline으로 수행한다.

**에러 처리**: 분석이 불가능한 항목은 "분석 불가"로 표시하고 나머지로 진행한다.

### Session Summary (모든 분석에 활용)

```
Session Summary:
- Work: [세션에서 수행한 주요 작업]
- Files: [생성/수정한 파일]
- Decisions: [내린 주요 결정]
```

### 분석 1: doc-updater 관점

이 단계에서는 **문서 업데이트 담당자**처럼 사고하세요.

[Session Summary]를 바탕으로 분석하세요: CLAUDE.md, README.md, context.md에 업데이트가 필요한지 확인하라.

출력: 추가해야 할 구체적인 내용.

### 분석 2: automation-scout 관점

이 단계에서는 **자동화 탐색 담당자**처럼 사고하세요.

[Session Summary]를 바탕으로 분석하세요: 반복 패턴이나 자동화 기회를 분석하라.

출력: 스킬/커맨드/에이전트 제안.

### 분석 3: learning-extractor 관점

이 단계에서는 **학습 포인트 추출 담당자**처럼 사고하세요.

[Session Summary]를 바탕으로 분석하세요: 배운 점, 실수, 새로운 발견을 추출하라.

출력: TIL(Today I Learned) 형식 요약.

### 분석 4: followup-suggester 관점

이 단계에서는 **후속 작업 제안 담당자**처럼 사고하세요.

[Session Summary]를 바탕으로 분석하세요: 미완료 작업과 다음 세션 우선순위를 제안하라.

출력: 우선순위별 작업 목록.

### 분석 역할 요약

| 분석 관점 | 역할 | 출력 |
|-----------|------|------|
| **doc-updater** | CLAUDE.md/README.md/context.md 업데이트 분석 | 추가할 구체적 내용 |
| **automation-scout** | 자동화 패턴 감지 | 스킬/커맨드/에이전트 제안 |
| **learning-extractor** | 학습 포인트 추출 | TIL 형식 요약 |
| **followup-suggester** | 후속 작업 제안 | 우선순위별 작업 목록 |

## Step 3: Phase 2 — duplicate-checker 검증 (순차)

Phase 1 완료 후 순차 실행한다.

이 단계에서는 **중복 검사 담당자**처럼 사고하세요.

Phase 1 분석 결과를 검증하세요:

```
## doc-updater 제안:
[doc-updater 결과]

## automation-scout 제안:
[automation-scout 결과]

기존 문서/자동화와 중복 여부 확인:
1. 완전 중복: 건너뛰기 권장
2. 부분 중복: 병합 방식 제안
3. 중복 없음: 추가 승인
```

## Step 4: 결과 통합

```markdown
## Wrap Analysis Results

### Documentation Updates
[doc-updater 요약]
- 중복 검사: [duplicate-checker 피드백]

### Automation Suggestions
[automation-scout 요약]
- 중복 검사: [duplicate-checker 피드백]

### Learning Points
[learning-extractor 요약]

### Follow-up Tasks
[followup-suggester 요약]
```

## Step 5: 액션 선택

사용자에게 다음 질문을 제시하고 번호 또는 라벨로 답하게 하세요 (복수 선택 가능):

**어떤 액션을 수행할까요?**
1. **커밋 생성** — 변경사항을 커밋합니다 (추천)
2. **CLAUDE.md 업데이트** — 새 지식/워크플로우를 문서화합니다
3. **README.md 업데이트** — 현재 스킬/기능과 동기화합니다
4. **자동화 생성** — 스킬/커맨드/에이전트를 생성합니다
5. **건너뛰기** — 액션 없이 종료합니다

## Step 6: 선택한 액션 실행

사용자가 선택한 액션만 실행한다.

---

## Quick Reference

### 사용 시나리오

- 중요한 작업 세션 종료 시
- 다른 프로젝트로 전환하기 전
- 기능 완성 또는 버그 수정 완료 후

### 건너뛸 때

- 매우 짧은 세션, 사소한 변경만 있을 때
- 코드 읽기/탐색만 한 경우
- 빠른 일회성 질문만 답변한 경우

### 인자

- 비어있음: 인터랙티브 진행 (전체 워크플로우)
- 메시지 제공: 해당 메시지를 커밋 메시지로 사용하여 바로 커밋

## 추가 리소스

See `references/multi-agent-patterns.md` for detailed orchestration patterns.

---
## 참조 파일 위치
이 프롬프트가 언급하는 `references/...` 파일은 plugin-mh 저장소의 `skills/session-closing/references/` 에 있다.
