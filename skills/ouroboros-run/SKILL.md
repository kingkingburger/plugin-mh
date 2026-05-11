---
name: ouroboros-run
version: 1.0.0
description: >-
  ouroboros 문서(요구사항/설계/검증)를 입력으로 받아 Generator-Evaluator 루프로 구현하는 실행 스킬.
  Planner-Generator-Evaluator 3역할 분리 아키텍처. story별 순차 구현→검증, 전체 완료 후 review-loop 체이닝으로 종료.
  Trigger on "ouroboros-run", "우로보로스 실행", "계획 실행", "문서 기반 구현",
  "ouroboros 실행", "설계 실행", "run the plan", "execute the spec".
  ouroboros로 계획만 세웠으면 ouroboros-run으로 실행.
allowed-tools:
  - Agent
  - AskUserQuestion
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - Bash
---

# Ouroboros Run — 계획을 실행하는 자기참조 루프

ouroboros가 생산한 문서를 입력으로 받아, **Generator-Evaluator 피드백 루프**로 story별 구현→검증을 반복한다. 모든 story가 통과하면 review-loop 체이닝으로 최종 품질을 검증하고 종료한다.

> **핵심 원리**: 만드는 쪽(Generator)과 평가하는 쪽(Evaluator)을 분리하고,
> 평가자를 깐깐하게 튜닝하는 것이 품질의 핵심 레버. — harness 설계 근거

```
ouroboros 문서 (Planner — 이미 완료)
  ↓
Phase 0: 문서 감지 + story 분해 → stories.json
  ↓
Phase 1: Story 루프 (순차)
  ┌──────────────────────────────────────────────┐
  │ Generator → story 구현                        │
  │   ↓                                           │
  │ Evaluator → acceptance criteria 검증          │
  │   ↓                                           │
  │ FAIL → 피드백 → Generator 재호출 (max 3회)    │
  │ PASS → story.status = "PASS" → 다음 story     │
  └──────────────────────────────────────────────┘
  ↓
Phase 2: review-loop 체이닝 (최종 품질 검증) → 종료
```

## 3역할 분리 원칙

| 역할 | 담당 | 핵심 규칙 |
|------|------|-----------|
| **Planner** | ouroboros (외부 입력) | "무엇(WHAT)"만 정의. 이미 완료된 문서 |
| **Generator** | 구현 에이전트 또는 현재 에이전트의 구현 패스 | story 계약에 따라 코드 구현. 스펙 외 판단 금지 |
| **Evaluator** | 분리된 검증 에이전트 또는 현재 에이전트의 별도 검증 패스 | 03-verification.md 기준 깐깐한 검증. 관대한 평가 금지 |

---

## Phase 0: 실행 전 확인 + 문서 감지 + Story 분해

### 0a. 실행 전 확인

문서 실행 전에 아래를 먼저 확인하고 결과를 짧게 보고한다.

1. `git status --short --branch`로 dirty worktree와 현재 브랜치를 확인한다.
2. 저장소 루트의 `AGENTS.md`, `CLAUDE.md`, 영역별 지침을 읽어 commit, 검증, 금지 파일, 도메인 규칙을 반영한다.
3. 계획 문서가 권한, DB, 인증, API 응답, 마이그레이션, 보안 경계를 건드리면 관련 설계/보안/신뢰성 문서를 함께 확인한다.
4. 03-verification.md 또는 프로젝트 지침에서 집중 검증 명령을 추출한다. 없으면 story마다 실행 가능한 최소 검증 명령을 명시한다.
5. 기존 `stories.json`이나 `manifest.json`이 있으면 재개 여부를 확인한다.

### 0b. 입력 문서 감지

**우선순위 1 — 명시 입력 또는 manifest:**

사용자가 경로를 지정했거나 `docs/ouroboros/{date}-{slug}/manifest.json`이 있으면 이를 우선한다. 자동으로 "가장 최근 문서"를 실행하지 않는다.

권장 manifest:

```json
{
  "status": "ready-for-run",
  "source_docs": {
    "requirements": "01-requirements.md",
    "design": "02-design.md",
    "verification": "03-verification.md"
  },
  "stories_path": "stories.json",
  "owner_scope": ["frontend", "backend"],
  "verification_commands": [
    "bun test tests/unit/example.test.ts"
  ],
  "review_gates": ["review-loop"]
}
```

`manifest.json`이 있으면 `source_docs`, `stories_path`, `verification_commands`, `owner_scope`를 신뢰 가능한 실행 계약으로 사용한다. 값이 빠졌거나 파일이 없으면 실행 전에 사용자에게 확인한다.

**우선순위 2 — ouroboros 산출물 후보 감지:**

```
Glob("docs/ouroboros/**/01-requirements.md")
```

ouroboros 디렉토리가 여러 개이면 후보 목록을 보여주고 사용자가 실행할 디렉토리를 고르게 한다. 감지 시 3개 문서를 확인:
- `01-requirements.md` — 요구사항
- `02-design.md` — 설계 (파일별 구현 계획 포함)
- `03-verification.md` — 검증 시나리오

3개 모두 존재하더라도 자동 진행하지 말고, 실행할 문서 디렉토리를 확인한다. 일부만 있으면 먼저 문서를 완성하거나 명시적으로 범용 폴백을 선택하게 한다.

**우선순위 3 — 범용 폴백:**

ouroboros 문서가 없으면:

```
AskUserQuestion:
  question: "실행할 계획 문서를 지정해주세요. 어떤 문서를 입력으로 사용할까요?"
  header: "입력 문서"
  options:
    - label: "경로 직접 입력"
      description: "설계 문서의 경로를 알려주세요 (md 파일)"
    - label: "프로젝트에서 찾기"
      description: "프로젝트 내 md 파일을 탐색하여 후보를 보여드립니다"
```

범용 문서인 경우 "파일별 구현 계획" 또는 유사 섹션을 탐색하여 story로 변환한다.

### 0c. Story 분해

`manifest.json`이 `stories_path`를 제공하고 해당 파일이 있으면 기존 story를 사용한다. 없으면 02-design.md의 **"파일별 구현 계획"** 과 03-verification.md의 검증 기준을 함께 읽어 `stories.json`을 생성한다.

story는 파일 단위가 아니라 **사용자 가치 또는 검증 가능한 행동 단위**로 나눈다. 각 story에는 touched files를 포함한다.
- **id**: `S-001`, `S-002`, ...
- **title**: 사용자 가치 또는 검증 가능한 행동 (예: "유효한 로그인 요청에 JWT를 발급한다")
- **files**: 예상 대상 파일 경로 배열
- **description**: 해당 파일의 구현 내용 (02-design.md에서 추출)
- **acceptanceCriteria**: 03-verification.md에서 해당 파일/기능과 매핑되는 검증 기준
- **verificationCommands**: story 통과를 확인할 명령
- **rollbackNotes**: 실패하거나 되돌릴 때 필요한 주의점
- **status**: `PENDING` | `PASS` | `FAIL` | `SKIPPED`
- **round**: 시도 횟수
- **evaluatorEvidence**: 평가자가 읽은 파일, 실행한 명령, 실패 근거, 남은 리스크

```json
{
  "source": "docs/ouroboros/2026-04-07-my-feature/",
  "stories": [
    {
      "id": "S-001",
      "title": "유효한 로그인 요청에 JWT를 발급한다",
      "files": ["src/auth/login.ts"],
      "description": "이메일+비밀번호 기반 로그인 처리, JWT 토큰 발급",
      "acceptanceCriteria": [
        "POST /api/login에 유효한 credentials → 200 + JWT 반환",
        "잘못된 비밀번호 → 401 반환",
        "존재하지 않는 이메일 → 401 반환 (이메일 존재 여부 노출 금지)"
      ],
      "verificationCommands": ["bun test tests/unit/auth.login.test.ts"],
      "rollbackNotes": "인증 응답 계약이 바뀌면 프론트 로그인 테스트를 함께 확인한다.",
      "status": "PENDING",
      "round": 0,
      "evaluatorEvidence": []
    }
  ],
  "config": {
    "maxRoundsPerStory": 3,
    "currentStoryIndex": 0,
    "startedAt": "2026-04-07T10:00:00Z"
  }
}
```

stories.json 저장 위치: ouroboros 문서와 같은 디렉토리 (`docs/ouroboros/{date}-{slug}/stories.json`).
범용 문서인 경우 프로젝트 루트에 `.ouroboros-run/stories.json`.

### 0d. Story 분해 확인

생성된 stories.json을 사용자에게 보여주고 승인:

```
AskUserQuestion:
  question: "{N}개 story로 분해했습니다. 진행할까요?"
  header: "Story 확인"
  options:
    - label: "승인 — 실행 시작"
      description: "이대로 story별 구현을 시작합니다"
    - label: "수정 필요"
      description: "story 분해에 대한 피드백을 입력해주세요"
```

---

## Phase 1: Story 루프

stories.json의 story를 **순차적으로** 실행한다. 각 story에 대해 Generator → Evaluator → 판정 사이클.

### 1a. Story 계약 수립

현재 story에서 계약을 구성:

```markdown
## Story {id} Contract: {title}

### 구현 대상
{files 목록}

### 구현 내용
{description — 02-design.md에서 추출}

### Acceptance Criteria
{acceptanceCriteria — 03-verification.md에서 매핑}

### 이전 피드백
{Evaluator 피드백 또는 "첫 시도"}

### 프로젝트 컨텍스트
- 작업 디렉토리: {cwd}
- 이전 story에서 생성/수정한 파일: {completed story files}
```

### 1b. Generator 단계

호스트가 별도 sub-agent를 허용하면 Generator에게 이 story의 구현 파일만 맡긴다. 허용되지 않으면 현재 에이전트가 이 섹션의 규칙으로 구현한다. 특정 모델명은 강제하지 않는다.

**역할**: Story 계약에 따라 코드를 구현한다.

**규칙**:
1. Acceptance Criteria를 모두 충족하는 코드를 작성한다.
2. 계약에 명시된 파일만 생성/수정한다. 범위 외 판단 금지.
3. 이전 story의 코드를 깨뜨리지 않는다.
4. 이전 피드백이 있다면 반드시 반영한다.
5. 구현 완료 후 각 Acceptance Criteria의 충족 상태를 self-check한다.

**출력**:
1. 생성/수정한 파일 목록
2. 각 Acceptance Criteria 구현 상태 (self-check)
3. 구현 중 발견한 이슈/의문점

### 1c. Evaluator 단계

> **핵심 레버.** 깐깐하게 튜닝된 평가자.
> "별로 심각하진 않네요. 통과" 같은 관대한 평가 금지.

호스트가 별도 sub-agent를 허용하면 Generator와 다른 에이전트가 검증한다. 허용되지 않으면 현재 에이전트가 구현 직후 별도 검증 패스로 전환한다.

**마인드셋**:
- 까다로운 QA 엔지니어처럼 검증한다.
- "별로 심각하진 않다"는 평가를 절대 하지 않는다.
- 확인(confirmation)이 아니라 반박(falsification)이 목표다.
- Acceptance Criteria를 하나씩 검증하되, 코드를 직접 읽고 실행한다.

**검증 방법**:
1. 각 Acceptance Criteria에 대해:
   - 코드를 읽고 로직 검증
   - 가능하면 테스트, 빌드, curl 등 실행
   - 기대 결과와 실제 결과 비교
2. 03-verification.md의 관련 시나리오도 교차 확인
3. 이전 story에서 통과한 기능이 깨지지 않았는지 회귀 확인
4. LSP 진단 도구가 있으면 사용하고, 없으면 파일 읽기와 검색으로 타입/구문 오류를 확인

**출력 형식 (반드시 준수)**:
```markdown
## Story {id} 평가 — Round {M}

### Criteria 검증
| # | Acceptance Criteria | 결과 | 근거 |
|---|---------------------|------|------|
| 1 | {criteria} | PASS/FAIL | {코드 라인 또는 테스트 결과} |

### 검증 증거
- 읽은 파일: {파일 목록}
- 실행한 명령: {명령과 결과}
- 참조한 시나리오: {03-verification.md 섹션}

### 판정: PASS / FAIL
(모든 criteria PASS → PASS, 하나라도 FAIL → FAIL)

### 발견된 이슈 (FAIL인 경우)
1. {criteria #} 실패 — {구체적 원인과 위치}

### 수정 요청 (FAIL인 경우)
1. {구체적 수정 사항 — 파일, 라인, 변경 내용}

### 남은 리스크
- {통과 후에도 남은 검증 공백 또는 "없음"}
```

### 1d. 판정 및 반복

Evaluator 결과에 따라:

| 판정 | 액션 |
|------|------|
| **PASS** | story.status = "PASS", story.round += 1, evaluatorEvidence 기록, stories.json 업데이트 → 다음 story |
| **FAIL** (round < 3) | Evaluator 피드백을 계약에 추가 → Generator 재호출 → Evaluator 재검증 |
| **FAIL** (round = 3) | 사용자에게 확인 |

3회 실패 시:

```
AskUserQuestion:
  question: "Story {id}가 3회 시도 후에도 통과하지 못했습니다. 현재 실패 기준: {failing criteria}. 어떻게 할까요?"
  header: "Story 실패"
  options:
    - label: "계속 시도 (3회 추가)"
      description: "Generator에게 더 시도하게 합니다"
    - label: "건너뛰고 다음 story"
      description: "이 story를 SKIP 처리하고 다음으로"
    - label: "지금까지 PASS한 것만 Ship"
      description: "통과한 story들을 커밋하고 RELIABILITY.md에 미구현 항목을 기록한 뒤 종료"
    - label: "중단"
      description: "ouroboros-run을 중단합니다"
```

**Ship 옵션 선택 시 동작:**

1. **통과 story 커밋**
   ```bash
   git add {passed story의 변경 파일들}
   git commit -m "구현: Stories {PASS한 story ID 목록} 통과

   SKIP된 stories: {SKIP된 story ID 목록}
   FAIL된 stories: {FAIL된 story ID}
   "
   ```

2. **RELIABILITY.md 갱신** (없으면 생성)
   ```markdown
   ## {오늘 날짜} — Partial Ship

   ### 미구현 / 불완전
   - **{story-id} {story-title}**: FAIL ({실패 사유 요약})
     - 실패 기준: {failing criteria}
     - 재시도 횟수: 3
     - 기록 위치: stories.json > {story-id}
   - **{story-id} {story-title}**: SKIP (사용자 선택)

   ### 통과
   - {passed story ID들 나열}
   ```

3. **stories.json 갱신** — 각 story에 `skip_reason` 필드 추가:
   ```json
   {
     "id": "S-003",
     "status": "FAILED",
     "skip_reason": "Partial ship: 3회 실패 후 사용자가 Ship 선택",
     "last_failing_criteria": "..."
   }
   ```

4. **Phase 2(review-loop) 스킵**하고 종료.

### 1e. 진행 상태 보고

각 story 완료 후:

```
Story {id} — {title}
판정: PASS (Round {M})
진행: {completed}/{total} stories ({percent}%)
```

stories.json을 업데이트하여 진행 상태를 저장한다. 세션 중단 시 재개 가능.

### 1f. 재진입

스킬 실행 시 기존 stories.json이 있고 완료되지 않은 story가 있으면:

```
AskUserQuestion:
  question: "이전 실행이 감지되었습니다. {completed}/{total} story 완료. 이어서 진행할까요?"
  header: "재개"
  options:
    - label: "이어서 진행"
      description: "미완료 story부터 재개합니다"
    - label: "처음부터 다시"
      description: "stories.json을 재생성하고 처음부터 시작합니다"
```

---

## Phase 2: Review-Loop 체이닝

모든 story가 PASS(또는 SKIP)되면, 전체 변경사항에 대해 review-loop 체이닝을 실행한다.

### 실행 방법

review-loop 스킬을 안내한다:

```
모든 story 구현이 완료되었습니다. 최종 품질 검증을 위해 review-loop를 실행합니다.

`/review-loop`을 실행하여 code-reviewer → architect → critic 3단 체이닝 리뷰를 진행합니다.
```

review-loop의 3단 체이닝:
1. **code-reviewer**: 정확성, 로직 결함, 엣지케이스, 코드 품질
2. **architect**: 아키텍처 적합성, 의존성, 패턴 일관성
3. **critic**: 사각지대, 과잉 지적 감시, 최종 판정

CRITICAL/HIGH 이슈 → 수정 후 재체이닝. APPROVE → 종료.

review-loop이 APPROVE를 내면 ouroboros-run을 즉시 종료한다. 별도 보고서 파일(`report.md`)은 생성하지 않는다. 진행 상태는 `stories.json`에 그대로 남아 있어 사후 확인 가능하다.

---

## Anti-Patterns

| 하지 말 것 | 왜 |
|-----------|-----|
| Generator와 Evaluator를 같은 에이전트로 실행 | 자기 코드 자기 검증 = 확증 편향 |
| Evaluator가 관대하게 통과 ("대충 괜찮네요") | 품질 게이트 무력화. falsification이 목표 |
| Acceptance Criteria 없이 PASS 판정 | 근거 없는 통과. 모든 criteria를 하나씩 검증 |
| 이전 story 회귀를 무시 | 새 story가 기존 기능을 깨뜨릴 수 있음 |
| stories.json 업데이트 누락 | 세션 중단 시 진행 상태 유실 |
| review-loop 없이 완료 선언 | story별 검증은 로컬 검증. 전체 품질은 review-loop이 담당 |
| Generator에게 스펙 외 판단 허용 | Planner의 결정을 존중. Generator는 실행만 |
| 완료 후 별도 report 파일 생성 | stories.json에 이미 진행/결과가 기록됨. 추가 파일은 노이즈 |

---

## 다른 스킬 연계

| 상황 | 안내할 스킬 |
|------|-----------|
| 계획 문서가 없음 | `/ouroboros` — 먼저 계획을 세우세요 |
| 구현 중 기술 결정 필요 | `/tech-decision` — 기술 의사결정 분석 |
| 리뷰 루프만 별도로 | `/review-loop` — 코드 리뷰 체이닝 |
