# /ouroboros-run — 계획을 실행하는 자기참조 루프

ouroboros 문서(요구사항/설계/검증)를 입력으로 받아 Generator-Evaluator 루프로 구현하는 실행 스킬. Planner-Generator-Evaluator 3역할 분리 아키텍처.

> Codex CLI 슬래시 커맨드로 호출되거나 자연어로 트리거된다. `$ARGUMENTS`에 사용자 입력이 주입된다.

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
  │ Generator 관점 → story 구현                   │
  │   ↓                                           │
  │ Evaluator 관점 → acceptance criteria 검증     │
  │   ↓                                           │
  │ FAIL → 피드백 → Generator 재시도 (max 3회)    │
  │ PASS → story.passes = true → 다음 story       │
  └──────────────────────────────────────────────┘
  ↓
Phase 2: review-loop 체이닝 (최종 품질 검증) → 종료
```

## 3역할 분리 원칙

| 역할 | 담당 | 핵심 규칙 |
|------|------|-----------|
| **Planner** | ouroboros (외부 입력) | "무엇(WHAT)"만 정의. 이미 완료된 문서 |
| **Generator** | 이 단계에서는 Generator 관점으로 코드 작성 | story 계약에 따라 코드 구현. 스펙 외 판단 금지 |
| **Evaluator** | 이 단계에서는 Evaluator 관점으로 깐깐한 검증 | 03-verification.md 기준 깐깐한 검증. 관대한 평가 금지 |

---

## Phase 0: 문서 감지 + Story 분해

### 0a. 입력 문서 감지

**우선순위 1 — ouroboros 산출물 자동 감지:**

```
Glob("docs/ouroboros/**/01-requirements.md")
```

ouroboros 디렉토리가 여러 개이면 가장 최근(날짜순) 선택. 감지 시 3개 문서를 확인:
- `01-requirements.md` — 요구사항
- `02-design.md` — 설계 (파일별 구현 계획 포함)
- `03-verification.md` — 검증 시나리오

3개 모두 존재하면 자동 진행. 일부만 있으면 사용자에게 확인:
1. **계속 진행** — 있는 문서로 진행
2. **중단** — 문서를 먼저 완성 후 재시도

**우선순위 2 — 범용 폴백:**

ouroboros 문서가 없으면 사용자에게 다음 옵션을 제시하세요:

**실행할 계획 문서를 지정해주세요. 어떤 문서를 입력으로 사용할까요?**
1. **경로 직접 입력** — 설계 문서의 경로를 알려주세요 (md 파일)
2. **프로젝트에서 찾기** — 프로젝트 내 md 파일을 탐색하여 후보를 보여드립니다

범용 문서인 경우 "파일별 구현 계획" 또는 유사 섹션을 탐색하여 story로 변환한다.

### 0b. Story 분해

02-design.md의 **"파일별 구현 계획"** 섹션을 파싱하여 stories.json을 생성한다.

각 파일(생성/수정 대상)을 하나의 story로 변환:
- **id**: `S-001`, `S-002`, ...
- **title**: 파일 경로 + 역할 (예: "src/auth/login.ts — 로그인 API 엔드포인트")
- **files**: 대상 파일 경로 배열
- **description**: 해당 파일의 구현 내용 (02-design.md에서 추출)
- **acceptanceCriteria**: 03-verification.md에서 해당 파일/기능과 매핑되는 검증 기준
- **passes**: false (초기값)
- **round**: 0 (시도 횟수)

```json
{
  "source": "docs/ouroboros/2026-04-07-my-feature/",
  "stories": [
    {
      "id": "S-001",
      "title": "src/auth/login.ts — 로그인 API 엔드포인트",
      "files": ["src/auth/login.ts"],
      "description": "이메일+비밀번호 기반 로그인 처리, JWT 토큰 발급",
      "acceptanceCriteria": [
        "POST /api/login에 유효한 credentials → 200 + JWT 반환",
        "잘못된 비밀번호 → 401 반환",
        "존재하지 않는 이메일 → 401 반환 (이메일 존재 여부 노출 금지)"
      ],
      "passes": false,
      "round": 0
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

### 0c. Story 분해 확인

생성된 stories.json을 사용자에게 보여주고 승인. 사용자에게 다음 옵션을 제시하세요:

**{N}개 story로 분해했습니다. 진행할까요?**
1. **승인 — 실행 시작** — 이대로 story별 구현을 시작합니다
2. **수정 필요** — story 분해에 대한 피드백을 입력해주세요

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

이 단계에서는 Generator 관점으로 코드를 작성하세요.

**역할**: Story 계약에 따라 코드를 구현합니다.

**규칙**:
1. Acceptance Criteria를 모두 충족하는 코드를 작성하세요.
2. 계약에 명시된 파일만 생성/수정하세요. 범위 외 판단 금지.
3. 이전 story의 코드를 깨뜨리지 마세요.
4. 이전 피드백이 있다면 반드시 반영하세요.
5. 구현 완료 후 각 Acceptance Criteria의 충족 상태를 self-check하세요.

**출력**:
1. 생성/수정한 파일 목록
2. 각 Acceptance Criteria 구현 상태 (self-check)
3. 구현 중 발견한 이슈/의문점

### 1c. Evaluator 단계

이 단계에서는 Evaluator 관점으로 깐깐한 검증을 수행하세요.

> **핵심 레버.** 깐깐하게 튜닝된 평가자.
> "별로 심각하진 않네요. 통과" 같은 관대한 평가 금지.

**마인드셋**:
- 까다로운 QA 엔지니어처럼 사고하세요.
- "별로 심각하진 않다"는 평가를 절대 하지 마세요.
- 확인(confirmation)이 아니라 반박(falsification)이 목표입니다.
- Acceptance Criteria를 하나씩 검증하되, 코드를 직접 읽고 실행하세요.

**검증 방법**:
1. 각 Acceptance Criteria에 대해:
   - 코드를 Read로 읽고 로직 검증
   - 가능하면 Bash로 테스트 실행 (빌드, 유닛테스트, curl 등)
   - 기대 결과와 실제 결과 비교
2. 03-verification.md의 관련 시나리오도 교차 확인
3. 이전 story에서 통과한 기능이 깨지지 않았는지 회귀 확인
4. LSP 진단 도구가 있으면 사용, 없으면 Read+Grep으로 타입/구문 오류 검출

**출력 형식 (반드시 준수)**:
```
## Story {id} 평가 — Round {M}

### Criteria 검증
| # | Acceptance Criteria | 결과 | 근거 |
|---|---------------------|------|------|
| 1 | {criteria} | PASS/FAIL | {코드 라인 또는 테스트 결과} |

### 판정: PASS / FAIL
(모든 criteria PASS → PASS, 하나라도 FAIL → FAIL)

### 발견된 이슈 (FAIL인 경우)
1. {criteria #} 실패 — {구체적 원인과 위치}

### 수정 요청 (FAIL인 경우)
1. {구체적 수정 사항 — 파일, 라인, 변경 내용}
```

### 1d. 판정 및 반복

Evaluator 결과에 따라:

| 판정 | 액션 |
|------|------|
| **PASS** | story.passes = true, story.round += 1, stories.json 업데이트 → 다음 story |
| **FAIL** (round < 3) | Evaluator 피드백을 계약에 추가 → Generator 재수행 → Evaluator 재검증 |
| **FAIL** (round = 3) | 사용자에게 확인 |

3회 실패 시 사용자에게 다음 옵션을 제시하세요:

**Story {id}가 3회 시도 후에도 통과하지 못했습니다. 현재 실패 기준: {failing criteria}. 어떻게 할까요?**
1. **계속 시도 (3회 추가)** — Generator에게 더 시도하게 합니다
2. **건너뛰고 다음 story** — 이 story를 SKIP 처리하고 다음으로
3. **지금까지 PASS한 것만 Ship** — 통과한 story들을 커밋하고 RELIABILITY.md에 미구현 항목을 기록한 뒤 종료
4. **중단** — ouroboros-run을 중단합니다

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

스킬 실행 시 기존 stories.json이 있고 완료되지 않은 story가 있으면 사용자에게 다음 옵션을 제시하세요:

**이전 실행이 감지되었습니다. {completed}/{total} story 완료. 이어서 진행할까요?**
1. **이어서 진행** — 미완료 story부터 재개합니다
2. **처음부터 다시** — stories.json을 재생성하고 처음부터 시작합니다

---

## Phase 2: Review-Loop 체이닝

모든 story가 PASS(또는 SKIP)되면, 전체 변경사항에 대해 review-loop 체이닝을 실행한다.

### 실행 방법

`/review-loop`을 안내한다:

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
| Generator와 Evaluator를 같은 패스로 실행 | 자기 코드 자기 검증 = 확증 편향 |
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
