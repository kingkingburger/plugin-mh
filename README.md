# plugin-mh

Claude Code plugin with 19 custom skills for thinking, deciding, and building smarter.

## Table of Contents

- [Quick Start](#quick-start)
- [Available Skills](#available-skills)
- [Skill Details](#skill-details)
  - [clarify](#clarify) - 명확화 라우터 (vague/unknown/metamedium 위임)
  - [skill-manage](#skill-manage) - 스킬 추가/삭제/이름변경 + 메타데이터 동기화
  - [vague](#vague) - 모호한 요구사항을 스펙으로
  - [unknown](#unknown) - 전략 사각지대 분석
  - [metamedium](#metamedium) - Content vs Form 관점 전환
  - [moonshot](#moonshot) - 목표 상향 프레임워크
  - [tech-decision](#tech-decision) - 기술 의사결정 심층 분석
  - [agent-arena](#agent-arena) - 다관점 에이전트 토론
  - [expert-review](#expert-review) - 전문가 페르소나 병렬 리뷰
  - [auto-commit](#auto-commit) - 작업 후 자동 커밋 & 푸시
  - [live-verify](#live-verify) - E2E 라이브 검증
  - [session-closing](#session-closing) - 세션 마무리 분석
  - [youtube-digest](#youtube-digest) - 유튜브 요약 & 퀴즈
  - [youtube-slides](#youtube-slides) - 유튜브 자막별 프레임 캡쳐
  - [ouroboros](#ouroboros) - 3단계 심층 문서 생산
  - [tdd](#tdd) - 테스트 주도 개발
  - [harness](#harness) - 하네스 엔지니어링 문서 체계 구축
  - [review-loop](#review-loop) - 코드 리뷰 루프
  - [ouroboros-run](#ouroboros-run) - ouroboros 계획 실행
- [Writing Your Own Skill](#writing-your-own-skill)
- [License](#license)

---

## Quick Start

```bash
# 마켓플레이스에서 플러그인 추가 / Add plugin from marketplace
claude plugin marketplace add kingkingburger/plugin-mh

# 플러그인 설치 / Install the plugin
claude plugin install plugin-mh
```

설치 확인 / Verify installation:

```bash
claude plugin list
```

스킬 목록에 `plugin-mh`가 표시되면 설치 완료입니다.
If `plugin-mh` appears in the list, installation is complete.

---

## Available Skills

### Thinking & Strategy

| Skill | Trigger | Description |
|-------|---------|-------------|
| [clarify](#clarify) | `/clarify`, `명확히` | Mode router — delegates to vague/unknown/metamedium specialist skills |
| [vague](#vague) | `요구사항 정리`, `spec this out` | Turn ambiguous requirements into actionable specs |
| [unknown](#unknown) | `blind spots`, `4분면 분석` | Surface hidden assumptions with Known/Unknown quadrant analysis |
| [metamedium](#metamedium) | `content vs form`, `관점 전환` | Reframe problems by distinguishing what from how |
| [moonshot](#moonshot) | `moonshot`, `10x`, `더 높은 목표` | Push goals higher with proven goal-setting frameworks |
| [ouroboros](#ouroboros) | `ouroboros`, `심층 문서`, `deep spec` | 3-phase deep document production (Requirements→Design→Verification) with quality gates |

### Decision & Research

| Skill | Trigger | Description |
|-------|---------|-------------|
| [tech-decision](#tech-decision) | `A vs B`, `기술 선택` | Systematic multi-source analysis for technical decisions |
| [agent-arena](#agent-arena) | `에이전트 토론`, `debate this` | Multiple AI agents debate a topic across rounds, then synthesize |
| [expert-review](#expert-review) | `전문가 리뷰`, `expert review` | Auto-recommend expert personas, parallel review, unified proposal |

### Productivity

| Skill | Trigger | Description |
|-------|---------|-------------|
| [auto-commit](#auto-commit) | `자동 커밋`, `auto commit` | Execute instructions, then auto commit & push |
| [live-verify](#live-verify) | `라이브 검증`, `live-verify` | 2-Phase E2E verification — Plan scenarios, then Execute with Playwright/Bash/curl |
| [skill-manage](#skill-manage) | `스킬 관리`, `skill-delete`, `skill-add` | Add/delete/rename skills with atomic metadata sync across 4 manifest files |

### Development Quality

| Skill | Trigger | Description |
|-------|---------|-------------|
| [tdd](#tdd) | `tdd`, `테스트 먼저`, `test first` | RED-GREEN-REFACTOR cycle enforcement — no production code without a failing test |
| [harness](#harness) | `harness`, `하네스`, `하네스 엔지니어링` | OpenAI 하네스 엔지니어링 기반 프로젝트 문서 체계 구축 |
| [review-loop](#review-loop) | `리뷰 루프`, `review-loop` | 3-chain review: code-reviewer → architect → critic |
| [ouroboros-run](#ouroboros-run) | `ouroboros-run`, `계획 실행` | Execute ouroboros plans with Generator-Evaluator loop |

### Session & History

| Skill | Trigger | Description |
|-------|---------|-------------|
| [session-closing](#session-closing) | `/closing`, `/wrap` | Multi-agent session wrap-up with learning extraction |

### Content & Social

| Skill | Trigger | Description |
|-------|---------|-------------|
| [youtube-digest](#youtube-digest) | `유튜브 정리`, `영상 요약` | Transcript extraction, summary, translation, and quiz generation |
| [youtube-slides](#youtube-slides) | `youtube-slides`, `자막 캡쳐` | Frame capture per subtitle segment from YouTube videos |

---

## Skill Details

### clarify

**명확화 라우터 — vague/unknown/metamedium specialist 스킬로 위임.**

v2부터 라우터 전용으로 재설계되었습니다. 모드-neutral 키워드(`/clarify`, `명확히`)로 진입하면 AskUserQuestion으로 모드를 확인한 뒤 해당 스킬에 위임합니다.

| Mode | 대상 스킬 | When to Use |
|------|-----------|-------------|
| vague | `/vague` | 요구사항이 모호하고 구체화 필요 |
| unknown | `/unknown` | 전략/계획의 숨겨진 가정과 사각지대 분석 |
| metamedium | `/metamedium` | Content(내용) vs Form(형식) 관점 전환 |

**Trigger:** `/clarify`, `명확히` (모드-specific 키워드는 각 specialist 스킬이 직접 소유)

```bash
# 예시
User: "/clarify - 뭘 원하는지 잘 모르겠어"   → AskUserQuestion → 모드 선택 → 위임
User: "blind spots 점검"                      → /unknown 직접 호출 (router 우회)
```

---

### vague

**모호한 요구사항을 가설 기반 질문으로 구체적 스펙으로 변환.**

열린 질문 대신 선택 가능한 가설을 제시하여 인지 부하를 줄입니다.

**The process:**
1. **Capture** - 원래 요구사항을 그대로 기록
2. **Question** - 가설 옵션이 포함된 5-8개 질문으로 모호성 해소
3. **Compare** - Before/After 비교 제시
4. **Save** - 명확화된 스펙을 파일로 저장 (선택)

| Before | After |
|--------|-------|
| "로그인 기능 추가해줘" | Goal: Email+Password 로그인. Scope: 로그인, 로그아웃, 회원가입, 비밀번호 재설정. Constraints: 24h 세션, bcrypt, 5회 시도 제한. |

---

### unknown

**Known/Unknown 4분면 프레임워크로 전략의 사각지대를 발견.**

3라운드 심화 질문으로 숨겨진 가정을 체계적으로 드러냅니다.

**3-Round Depth Pattern:**

| Round | Purpose | Questions |
|-------|---------|-----------|
| R1 | 초안 검증 | 3-4개 (모든 분면 커버) |
| R2 | 약점 심화 | 2-3개 (R1 답변 기반 타겟팅) |
| R3 | 실행 세부 (선택) | 2-3개 |

**Output:** 4분면 매트릭스 + 실험 설계 + 실행 로드맵

```bash
# 예시
User: "이 분기 사업 계획 blind spots 점검해줘"
User: "마이크로서비스 전환 전략에서 뭘 놓치고 있지?"
```

---

### metamedium

**Content(무엇)와 Form(어떻게)을 구분하여 진짜 레버리지 포인트를 발견.**

> "A change of perspective is worth 80 IQ points." — Alan Kay

| | Content (what) | Form (how/medium) |
|--|----------------|-------------------|
| 예시 | LinkedIn 포스트 작성 | 컨설팅 회고를 포스트로 변환하는 도구 구축 |
| 예시 | 유닛 테스트 수동 작성 | 타입 시그니처에서 테스트 생성기 구축 |
| Leverage | Linear | Exponential |

---

### moonshot

**목표 성격에 맞는 프레임워크를 적용하여 최고 수준의 상향 목표를 제안.**

하나의 상향 목표만 제안하며, 왜 이 수준이 가능한지 논리적 근거를 함께 제시합니다.

**Trigger:** `moonshot`, `10x`, `더 높은 목표`, `stretch goal`, `BHAG`, `think bigger`

```bash
# 예시
User: "이번 분기 매출 목표 1000만원인데 더 높게 잡고 싶어"
User: "moonshot - DAU 목표를 상향해줘"
```

---

### tech-decision

**기술 의사결정을 4개 병렬 에이전트로 체계적으로 분석.**

**두괄식 결과물** — 결론을 먼저 제시하고 근거를 뒤에 배치합니다.

```
Phase 1: Parallel Information Gathering
┌─────────────────┬─────────────────┬─────────────────┬─────────────────┐
│ codebase-       │ docs-           │ WebSearch       │ agent-arena     │
│ explorer        │ researcher      │ (community)     │ (multi-view)    │
└────────┬────────┴────────┬────────┴────────┬────────┴────────┬────────┘
         └─────────────────┴─────────────────┴─────────────────┘
                                    │
Phase 2: Analysis & Synthesis       ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                     decision-synthesizer                                │
│                   (Executive Summary First)                             │
└─────────────────────────────────────────────────────────────────────────┘
```

```bash
# 예시
User: "React vs Vue for my new project?"
User: "Prisma vs TypeORM 비교 분석해줘"
User: "Monolith vs Microservices for our scale?"
```

---

### agent-arena

**역할별 에이전트들이 다라운드 토론을 벌이고 종합자가 결론을 도출.**

| Preset | Agents | Use Case |
|--------|--------|----------|
| 3인 (기본) | 3 | 간단한 비교 |
| 5인 | 5 | 기능/방향성 검토 |
| 8인 (`--preset 8`) | 8 | 전략적 심층 분석 |

```bash
# 예시
User: "agent-arena - 모놀리스 vs 마이크로서비스?"
User: "에이전트 토론 --preset 8 - MVP 스코프를 어디까지?"
```

---

### expert-review

**파일을 입력하면 전문가 페르소나를 자동 추천하고 병렬 리뷰 후 통합 제안서를 출력.**

```
Step 1: 파일 읽기 → 문서 유형/도메인 분석
Step 2: 최적 전문가 N명 자동 추천 → 사용자 확인/수정
Step 3: N명 병렬 서브에이전트 리뷰 (등급 + 강점 + 개선 제안)
Step 4: 통합 제안서 (공통 평가 + 충돌 해소 + 우선순위 액션 아이템)
```

| Option | Default | Description |
|--------|---------|-------------|
| `--count` | `3` | 리뷰어 수 (2~5) |
| `--auto` | `false` | 페르소나 확인 단계 생략 |
| `--save` | `true` | 결과 파일 저장 |

**Trigger:** `전문가 리뷰`, `expert review`, `페르소나 리뷰`, `다관점 리뷰`

```bash
# 예시
User: "/expert-review docs/plan.md"
User: "/expert-review src/main.ts --count 5"
User: "전문가 리뷰 부탁 - README.md"
```

---

### auto-commit

**지시한 작업을 수행한 후 자동으로 git commit & push.**

작업 → 커밋 → 푸시를 하나의 흐름으로 자동화합니다.

```bash
# 예시
User: "자동 커밋 - README 오타 수정해줘"
User: "auto commit - fix the login bug"
```

---

### skill-manage

**plugin-mh의 스킬 추가/삭제/이름변경을 수행하면서 4개 메타데이터 파일과 다른 SKILL.md의 교차참조를 원자적으로 동기화.**

스킬 하나를 삭제할 때 수정해야 하는 파일:
- `CLAUDE.md` — "스킬 목록 (N개)" + 테이블 행
- `README.md` — 상단 문장 + TOC + 카테고리 테이블 + 상세 섹션 (3 위치)
- `.claude-plugin/marketplace.json` — 설명 개수 + 스킬명 리스트
- `GUIDE.md` — Marketplace 예시
- 다른 `skills/*/SKILL.md` — description 트리거 + 본문 교차참조

수동으로 하면 10+ edit. 이 스킬이 워크플로우를 가이드해서 누락을 방지합니다.

**Trigger:** `skill-manage`, `스킬 관리`, `스킬 추가`, `스킬 삭제`, `skill-add`, `skill-delete`, `skill-rename`

```bash
# 예시
User: "스킬 삭제 - foo 스킬 제거해줘"
User: "skill-add - 새 스킬 bar 만들자"
User: "skill-rename - baz를 qux로 바꿔줘"
```

**예외**: `docs/plans/YYYY-MM-DD-*.md`는 frozen historical artifact이므로 건드리지 않습니다.

---

### live-verify

**구현된 기능을 실제 사용자처럼 테스트하는 2-Phase E2E 검증.**

```
Phase 1 (Plan): 작업 계획/PRD/코드 분석 → 검증 시나리오 자동 생성
Phase 2 (Run):  Playwright/Bash/curl로 실제 제품 조작 → 실패 시 자동 수정 + 재검증
```

```bash
# 예시
User: "/live-verify"          # Phase 자동 감지
User: "/live-verify plan"     # Phase 1만 실행
User: "/live-verify run"      # Phase 2만 실행
```

---

### session-closing

**다중 에이전트 기반 세션 마무리 분석.**

```
Phase 1: Analysis (Parallel)
┌──────────────┬──────────────┬──────────────┬──────────────┐
│ doc-updater  │ automation-  │ learning-    │ followup-    │
│              │ scout        │ extractor    │ suggester    │
└──────┬───────┴──────┬───────┴──────┬───────┴──────┬───────┘
       └──────────────┴──────────────┴──────────────┘
                            │
Phase 2: Validation         ▼
┌─────────────────────────────────────────────────────────────┐
│                    duplicate-checker                         │
└─────────────────────────────────────────────────────────────┘
```

**Trigger:** `/closing`, `/wrap`, `session closing`

---

### youtube-digest

**YouTube URL을 넣으면 요약, 인사이트, 한국어 번역, 9문항 퀴즈를 생성.**

**What you get:**
1. **Summary** - 3-5문장 핵심 요약
2. **Insights** - 실행 가능한 인사이트
3. **Full transcript** - 한국어 번역 + 타임스탬프
4. **3-stage quiz** - Basic, Intermediate, Advanced (총 9문항)
5. **Deep Research** (선택) - 웹 검색 기반 후속 탐구

**Output:** `research/readings/youtube/YYYY-MM-DD-title.md`

```bash
# 예시
User: "이 영상 정리해줘 https://youtube.com/watch?v=..."
User: "유튜브 정리 - [URL]"
```

---

### youtube-slides

**YouTube 영상의 자막 구간별로 프레임을 캡쳐하여 슬라이드형 문서를 생성.**

yt-dlp로 영상을 다운받고, 자막 타임스탬프 기준으로 ffmpeg가 프레임을 캡쳐합니다.

**What you get:**
1. **Markdown 문서** - 각 자막과 캡쳐 이미지가 매핑된 슬라이드
2. **HTML 문서** - 브라우저에서 바로 볼 수 있는 슬라이드 뷰
3. **Images 폴더** - 자막 구간별 캡쳐 이미지

**Dependencies:** `yt-dlp`, `ffmpeg`, `Python 3`

**Trigger:** `youtube-slides`, `자막 캡쳐`, `영상 슬라이드`

```bash
# 예시
User: "youtube-slides https://youtube.com/watch?v=..."
User: "자막 캡쳐 - [URL]"
```

---

### ouroboros

**모호한 아이디어를 3단계 파이프라인으로 심화하여 깊이 있는 문서 세트를 생산.**

> 핵심 철학: 모호성을 수치로 추적하고, 문턱값(20%) 이하가 될 때까지 반복한다.

```
Phase 1: 요구사항 심화 → Phase 2: 설계 심화 → Phase 3: 검증 심화
         (품질 게이트)          (품질 게이트)          (품질 게이트)
```

각 Phase에서:
- 차원별 점수(0-1) × 가중치로 모호성 계산
- 모호성 ≤ 20%이면 다음 Phase로 진행
- 초과 시 가장 약한 차원에 타겟 질문 → 반복

**Output:** 3개 문서 세트 (`docs/ouroboros/{date}-{slug}/`)
1. `01-requirements.md` — 목표, 제약, 비목표, 수용기준
2. `02-design.md` — ADR, 기술스펙, 다이어그램, 파일별 계획
3. `03-verification.md` — E2E 시나리오, 엣지케이스, 성공/실패 기준

**Trigger:** `ouroboros`, `우로보로스`, `심층 문서`, `deep spec`, `요구사항부터 검증까지`

```bash
# 예시
User: "ouroboros - 사내 피드백 수집 도구 기획부터 검증까지"
User: "심층 문서 - 구독 결제 시스템 설계해줘"
```

---

### tdd

**RED-GREEN-REFACTOR 사이클을 강제하는 테스트 주도 개발.**

> 핵심 원칙: 테스트가 실패하는 걸 보지 않았다면, 그 테스트가 올바른 것을 검증하는지 알 수 없다.

**The cycle:**
1. **RED** — 실패하는 테스트 하나를 작성한다
2. **RED 검증** — 실행해서 실패를 확인한다 (필수, 절대 건너뛰지 않음)
3. **GREEN** — 테스트를 통과시키는 최소한의 코드를 작성한다
4. **GREEN 검증** — 실행해서 통과를 확인한다 (필수)
5. **REFACTOR** — 테스트를 GREEN으로 유지하면서 정리한다

테스트 전에 코드를 썼다면? **삭제하고 다시 시작.** 합리화 방지 테이블과 Red Flags 목록 내장.

**Trigger:** `tdd`, `TDD`, `테스트 먼저`, `test first`, `테스트 주도`, `RED GREEN REFACTOR`

```bash
# 예시
User: "tdd - 이메일 검증 기능 구현해줘"
User: "테스트 먼저 - 결제 모듈 버그 수정"
```

---

### harness

**OpenAI 하네스 엔지니어링 기반 프로젝트 문서 체계를 한번에 구축.**

> 핵심 원리: 에이전트가 접근할 수 없는 것은 존재하지 않는 것.
> 구조화된 문서 체계가 에이전트의 생산성을 결정한다. — OpenAI

**Three Pillars:**
1. **Context Engineering** — AGENTS.md, design-docs/, product-specs/로 에이전트에게 프로젝트 맥락 제공
2. **Architectural Constraints** — ARCHITECTURE.md, DESIGN.md, SECURITY.md로 의존성/설계 규칙 정의
3. **Entropy Management** — exec-plans/, tech-debt-tracker.md, RELIABILITY.md로 코드베이스 건강성 유지

인터뷰 → 코드 분석 → 에이전트 병렬 생성(opus + sonnet 3그룹)으로 AGENTS.md, ARCHITECTURE.md, docs/ 전체 구조를 생성. 새 프로젝트 부트스트랩, 기존 코드 분석 기반 생성, 기존 문서 보완 모두 지원.

**Trigger:** `harness`, `하네스`, `하네스 엔지니어링`, `문서 체계`, `harness engineering`

```bash
# 예시
User: "하네스 엔지니어링 세팅해줘"
User: "harness - 이 프로젝트에 문서 체계 구축"
```

---

### review-loop

**3단계 체이닝 리뷰로 코드 품질을 검증.**

```
code-reviewer → architect → critic
     ↓ 결과 전달     ↓ 결과 전달     ↓ 최종 판정
  정확성/품질     설계/구조 검증   사각지대/과잉지적 감시
```

각 리뷰어가 이전 리뷰어의 결과를 받아 검증/반박/보완. CRITICAL/HIGH 이슈 시 수정 후 재체이닝. 최소 5회 체이닝 필수.

**Trigger:** `review-loop`, `리뷰 루프`, `리뷰 돌려`, `코드 리뷰 루프`, `리뷰하고 고쳐`

```bash
# 예시
User: "리뷰 루프 돌려"
User: "review-loop - 방금 작성한 코드 검증해줘"
```

---

### ouroboros-run

**ouroboros 계획 문서를 Generator-Evaluator 루프로 실행.**

ouroboros가 생산한 3개 문서(요구사항/설계/검증)를 입력으로 받아, 설계의 파일별 구현 계획을 story로 분해하고 순차 구현한다. Planner-Generator-Evaluator 3역할 분리 원칙 적용.

**Flow:**
1. **Phase 0** — ouroboros 문서 자동 감지 + story 분해 → stories.json
2. **Phase 1** — Story 루프: Generator(sonnet) 구현 → Evaluator(opus) 검증 → FAIL 시 재시도 (max 3회)
3. **Phase 2** — 전체 완료 후 review-loop 체이닝
4. **Phase 3** — 최종 보고

ouroboros 문서가 없으면 범용 계획 문서도 입력 가능 (폴백).

**Partial Ship 옵션:** 일부 story가 max 재시도(3회) 후에도 FAIL이면 "지금까지 PASS한 것만 Ship" 선택 가능. 통과한 story들을 커밋하고 `RELIABILITY.md`에 미구현 항목을 기록한 뒤 종료한다.

**Trigger:** `ouroboros-run`, `우로보로스 실행`, `계획 실행`, `문서 기반 구현`, `run the plan`

```bash
# 예시
User: "ouroboros-run - docs/ouroboros/2026-04-07-auth/ 실행해줘"
User: "계획 실행 - 아까 만든 설계 문서대로 구현해줘"
```

---

## Writing Your Own Skill

```
skills/my-skill/
├── SKILL.md              # Required — defines triggers and workflow
├── references/           # Optional — supporting docs
└── agents/               # Optional — sub-agent definitions
```

See [GUIDE.md](GUIDE.md) for the full authoring guide.

## License

MIT
