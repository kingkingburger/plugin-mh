---
name: harness
version: 0.1.0
description: >
  앤트로픽의 3-에이전트 하네스 아키텍처(Planner-Generator-Evaluator)로 앱을 제작한다.
  한 줄 요청 → 플래너(기획) → 제너레이터(구현) → 이밸루에이터(Playwright 테스트) → 피드백 루프.
  Trigger on "harness", "하네스", "하네스로 만들어", "3-agent", "플래너-제너레이터",
  "만들고 평가하고", "하네스 빌드", "harness build".
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

# Harness — 3-Agent Build Skill

앤트로픽의 Planner-Generator-Evaluator 구조로 앱을 제작하는 스킬.

> **핵심 원리**: 같은 AI에게 같은 걸 시켜도, **구조(하네스)**가 다르면 결과가 다르다.
> 만드는 쪽과 평가하는 쪽을 분리하고, 평가자를 깐깐하게 튜닝하는 것이 품질의 핵심 레버.

## 아키텍처

```
사용자 한 줄 요청
  ↓
Phase 0: 설정 (프로젝트 타입, 작업 디렉토리)
  ↓
Phase 1: 플래너 (opus) → 제품 스펙
  ↓ (사용자 승인)
Phase 2: 스프린트 루프
  ┌─────────────────────────────────────┐
  │ 2a. 계약(Contract) 수립            │
  │ 2b. 제너레이터 (sonnet) → 구현     │
  │ 2c. 이밸루에이터 (opus) → 테스트   │
  │ 2d. FAIL → 피드백 → 2b (max 3회)  │
  └─────────────────────────────────────┘
  ↓
Phase 3: 최종 보고
```

---

## Phase 0: 설정

사용자 입력에서 한 줄 요청을 추출한 뒤:

```
AskUserQuestion:
questions:
  - question: "어떤 종류의 프로젝트인가요?"
    header: "Type"
    options:
      - label: "웹 앱 (단일 HTML)"
        description: "HTML/CSS/JS 단일 파일. Playwright로 평가"
      - label: "웹 앱 (dev server)"
        description: "React/Vue/Next 등. npm dev + Playwright 평가"
      - label: "CLI / API"
        description: "커맨드라인 또는 API. Bash로 평가"
```

설정값 결정:
- **프로젝트 타입** → 이밸루에이터 도구 결정 (Playwright vs Bash)
- **작업 디렉토리** → 현재 디렉토리 하위에 프로젝트 폴더 생성
- **기본값**: 최대 스프린트 5개, 스프린트당 평가 반복 최대 3회

`.harness/` 디렉토리 생성:
```
{project}/
├── .harness/
│   ├── spec.md           ← 플래너 출력
│   ├── state.md          ← 스프린트 상태 추적
│   └── screenshots/      ← 이밸루에이터 스크린샷
```

---

## Phase 1: 플래너 (opus)

> **"무엇(WHAT)"만 정의. "어떻게(HOW)"는 절대 정하지 않는다.**
> "React 써라", "Tailwind 써라" 같은 기술 지시 금지.

```
Agent:
  subagent_type: "general-purpose"
  model: "opus"
  description: "플래너 — 제품 스펙 설계"
  prompt: |
    ## 역할
    당신은 제품 플래너입니다. 사용자의 한 줄 요청을 전체 제품 스펙으로 확장합니다.

    ## 요청
    "{사용자의 한 줄 요청}"

    ## 규칙
    1. "무엇을 만들지"만 정의하세요. 기술 스택, 라이브러리, 구현 방식은 정하지 마세요.
    2. 각 스프린트의 Acceptance Criteria는 구체적이고 테스트 가능해야 합니다.
    3. 스프린트는 최대 {max_sprints}개. 앞선 스프린트가 뒤 스프린트의 기반.
    4. AI 슬롭을 피하라는 디자인 요구사항을 비기능 요구사항에 포함하세요.

    ## 출력 형식
    ```markdown
    # 제품 스펙: {제목}

    ## 비전
    {1-2문장}

    ## 핵심 기능 목록
    1. ...
    2. ...

    ## 스프린트 계획

    ### Sprint 1: {이름}
    - 목표: {1-2문장}
    - Acceptance Criteria:
      1. {구체적, 테스트 가능한 기준}
      2. ...

    ### Sprint 2: {이름}
    ...

    ## 비기능 요구사항
    - 디자인: AI 슬롭 회피 (보라색 그라데이션, 기본 컴포넌트 금지)
    - 반응형: 모바일/데스크탑 지원
    - 접근성: 키보드 네비게이션, 적절한 콘트라스트
    ```
```

플래너 출력을 `.harness/spec.md`에 저장한 뒤:

```
AskUserQuestion:
questions:
  - question: "플래너가 설계한 제품 스펙을 승인하시겠습니까?"
    header: "Approve"
    options:
      - label: "승인 — 구현 시작"
        description: "스펙대로 스프린트 루프를 시작합니다"
      - label: "수정 필요"
        description: "스펙에 대한 피드백을 입력해주세요"
```

수정 요청 시 플래너를 다시 호출하여 반영. 2회 이상 수정 시 자유 텍스트 입력.

---

## Phase 2: 스프린트 루프

스펙의 각 스프린트에 대해 순차 실행:

### 2a. 계약(Contract) 수립

스펙에서 해당 스프린트의 목표 + Acceptance Criteria를 추출.
이전 스프린트의 이밸루에이터 피드백이 있으면 포함.

계약 형식: `references/sprint-contract-template.md` 참조.

```markdown
## Sprint {N} Contract: {이름}

### 목표
{스펙에서 추출}

### Acceptance Criteria
{스펙에서 추출}

### 이전 피드백
{이밸루에이터 피드백 또는 "첫 스프린트"}

### 검증 방법
{프로젝트 타입에 따라 Playwright 또는 Bash 시나리오}
```

### 2b. 제너레이터 (sonnet)

```
Agent:
  subagent_type: "general-purpose"
  model: "sonnet"
  description: "제너레이터 — Sprint {N} 구현"
  prompt: |
    ## 역할
    당신은 제너레이터입니다. 스프린트 계약에 따라 코드를 구현합니다.

    ## 스프린트 계약
    {contract 내용}

    ## 현재 프로젝트 상태
    - 작업 디렉토리: {project_dir}
    - 프로젝트 타입: {project_type}
    - 이전 스프린트에서 만든 파일들: {file_list}

    ## 규칙
    1. Acceptance Criteria를 모두 충족하는 코드를 작성하세요.
    2. AI 슬롭을 피하세요: slop-detection-guide.md 참조.
       - 보라색 그라데이션, shadcn 기본값, 3열 카드 그리드 금지
       - 고유한 색상 팔레트, 비대칭 레이아웃, 커스텀 인터랙션 사용
    3. 이전 스프린트의 코드를 깨뜨리지 마세요.
    4. 이전 피드백이 있다면 반드시 반영하세요.

    ## 웹 앱인 경우
    - 구현 완료 후 앱에 접근할 수 있는 경로를 알려주세요.
    - 단일 HTML: file:/// 경로
    - dev server: localhost URL + 서버 시작 명령어

    ## 출력
    1. 생성/수정한 파일 목록
    2. 앱 접근 경로
    3. 각 Acceptance Criteria 구현 상태 (self-check)
```

### 2c. 이밸루에이터 (opus)

> **핵심 레버**. 깐깐하게 튜닝된 평가자.
> "별로 심각하진 않네요. 통과" 같은 관대한 평가 금지.

```
Agent:
  subagent_type: "general-purpose"
  model: "opus"
  description: "이밸루에이터 — Sprint {N} 평가 Round {M}"
  prompt: |
    ## 역할
    당신은 깐깐한 이밸루에이터입니다. 제너레이터가 만든 결과물을 실제 사용자처럼 테스트합니다.

    ## 마인드셋
    - 당신은 까다로운 QA 엔지니어입니다.
    - "별로 심각하진 않다"는 평가를 절대 하지 마세요.
    - 실제 사용자라면 불편할 모든 것을 지적하세요.
    - 문제를 적극적으로 찾으세요. 확인(confirmation)이 아니라 반박(falsification)이 목표입니다.
    - AI 슬롭 징후가 있으면 즉시 감점하세요.

    ## 스프린트 계약
    {contract 내용}

    ## 앱 접근 정보
    - 경로: {app_path}
    - 프로젝트 타입: {project_type}

    ## 테스트 절차 (웹 앱)
    1. browser_navigate → 앱 로드
    2. browser_snapshot → 전체 구조 확인
    3. browser_take_screenshot → 시각적 확인 (스크린샷 저장: {screenshot_path})
    4. 각 Acceptance Criteria별:
       - browser_click, browser_fill_form, browser_type 등으로 직접 조작
       - browser_evaluate로 JavaScript 상태 검증
       - browser_wait_for로 비동기 동작 대기
    5. browser_console_messages → 에러 로그 확인
    6. browser_resize(375px) → 모바일 반응형 확인
    7. browser_take_screenshot → 모바일 스크린샷

    ## 테스트 절차 (CLI/API)
    1. Bash로 명령 실행
    2. 출력 확인
    3. 잘못된 입력으로 에러 처리 확인

    ## 평가 기준 (evaluator-rubric.md 참조)
    | 기준 | 가중치 |
    |------|--------|
    | 기능성 | 30% |
    | 디자인 품질 | 25% |
    | 독창성 | 25% |
    | 완성도 | 20% |

    ## 출력 형식 (반드시 준수)
    ```
    ## Sprint {N} 평가 — Round {M}

    ### 점수
    | 기준 | 점수 | 상세 |
    |------|------|------|
    | 기능성 (30%) | X/10 | ... |
    | 디자인 품질 (25%) | X/10 | ... |
    | 독창성 (25%) | X/10 | ... |
    | 완성도 (20%) | X/10 | ... |
    | **가중 총점** | **XX/100** | |

    ### 판정: PASS / CONDITIONAL / FAIL
    (70+ = PASS, 50-69 = CONDITIONAL, 0-49 = FAIL)

    ### 발견된 이슈
    1. [심각/중간/경미] 이슈 설명 — 테스트: 어떤 액션에서 실패
    2. ...

    ### 수정 요청 (CONDITIONAL/FAIL인 경우)
    1. 구체적 수정 사항
    2. ...
    ```
```

### 2d. 피드백 루프

이밸루에이터 판정에 따라:

| 판정 | 액션 |
|------|------|
| **PASS** (70+) | `.harness/state.md` 업데이트 → 다음 스프린트 |
| **CONDITIONAL** (50-69) | 이슈만 추출 → 제너레이터 재호출 → 재평가 |
| **FAIL** (0-49) | 전체 피드백 → 제너레이터 재호출 → 재평가 |

- **최대 반복**: 스프린트당 3회. 3회 후에도 PASS 안 되면:
  ```
  AskUserQuestion:
  questions:
    - question: "Sprint {N}이 3회 평가 후에도 통과하지 못했습니다. 어떻게 할까요?"
      header: "Action"
      options:
        - label: "계속 시도 (3회 추가)"
          description: "제너레이터에게 더 시도하게 합니다"
        - label: "현재 상태로 진행"
          description: "이 스프린트를 건너뛰고 다음으로"
        - label: "중단"
          description: "하네스 실행을 중단합니다"
  ```

### 상태 추적 (.harness/state.md)

각 스프린트 완료 후 업데이트:

```markdown
# Harness State

## 프로젝트: {제목}
## 프로젝트 타입: {type}
## 시작: {timestamp}

## Sprint 1: {이름}
- 상태: PASS (Round 2)
- 점수: 75/100
- 주요 이슈: {해결된 이슈}

## Sprint 2: {이름}
- 상태: IN_PROGRESS
```

---

## Phase 3: 최종 보고

모든 스프린트 완료 후:

1. 최종 이밸루에이터를 한 번 더 실행 (전체 앱 대상)
2. `.harness/report.md`에 최종 보고서 저장:

```markdown
# Harness 최종 보고서

## 프로젝트: {제목}
## 소요: {총 시간} / {총 에이전트 호출 수}

## 스프린트 요약
| Sprint | 이름 | 점수 | 라운드 | 상태 |
|--------|------|------|--------|------|
| 1 | ... | 75 | 2 | PASS |
| 2 | ... | 82 | 1 | PASS |

## 최종 점수: XX/100

## 남은 이슈
1. ...

## 생성된 파일
- {파일 목록}
```

3. 사용자에게 결과 요약 제공

---

## 리소스

- `references/evaluator-rubric.md` — 평가 기준 상세 (점수 매트릭스)
- `references/sprint-contract-template.md` — 스프린트 계약 형식
- `references/slop-detection-guide.md` — AI 슬롭 감지 체크리스트
- `references/examples.md` — 프로젝트 타입별 실행 예시

## 설계 근거

앤트로픽 블로그 "Harness design for long-running application development" 기반:

1. **GAN 영감**: 만드는 쪽(Generator)과 평가하는 쪽(Evaluator) 분리 → 품질 향상
2. **플래너 분리**: 기획 단계의 기술적 실수가 전체로 확산되는 것 방지
3. **깐깐한 평가자**: 처음에는 관대했으나 튜닝 후 엄격하게 → 핵심 품질 레버
4. **스프린트 계약**: 명확한 완료 기준으로 양쪽 모두 동일 기준 작업/평가
5. **하네스의 필요성은 이동한다**: 모델이 발전해도 더 높은 수준에서 구조가 필요
