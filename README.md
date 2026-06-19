# plugin-mh

Multi-runtime skill and harness collection for Claude Code and OpenAI Codex, with 25 custom skills + 2 agents for thinking, deciding, and building smarter.
생각하고, 결정하고, 더 나은 결과로 빌드하기 위한 Claude Code / OpenAI Codex 호환 스킬 하네스 — 25개 스킬 + 2개 에이전트.

목표는 특정 런타임 하나에 갇힌 명령 모음이 아니라, 같은 스킬 원본과 작업 철학을 Claude Code와 Codex 양쪽에서 범용적으로 재사용하는 것이다. Claude Code에서는 플러그인 스킬/에이전트로, Codex에서는 27개 슬래시 커맨드와 AGENTS.md 라우팅 하네스로 동작한다 ([codex/](codex/) 참고).

## Table of Contents

- [Quick Start](#quick-start)
- [Guardrails](#guardrails)
- [Available Skills](#available-skills)
- [Skill Details](#skill-details)
- [Agents](#agents)
- [Writing Your Own Skill](#writing-your-own-skill)
- [License](#license)

---

## Quick Start

Claude Code 사용자는 플러그인으로 설치하고, Codex 사용자는 `codex/` 어댑터를 `~/.codex/prompts/`에 연결한다. 두 경로는 같은 스킬 카탈로그를 바라보며, 스킬 로직을 바꿀 때는 원본과 Codex 변환본을 함께 동기화한다.

### Claude Code

```bash
# 마켓플레이스에서 플러그인 추가
claude plugin marketplace add kingkingburger/plugin-mh

# 플러그인 설치
claude plugin install plugin-mh
```

설치 확인:

```bash
claude plugin list
```

목록에 `plugin-mh`가 보이면 완료.

### OpenAI Codex

Codex CLI에서도 같은 스킬 흐름을 쓰려면 [codex/README.md](codex/README.md)를 따라 어댑터를 설치한다.

---

## Guardrails

`guardrails/`는 MH의 개인 엔지니어링 하네스 규칙이다 — 언어별 기본값, TDD/리뷰 절차, 소프트웨어 공학 법칙 기반 행동 규칙.

| 영역 | 파일 |
|------|------|
| 공통 작업 원칙 | [`guardrails/core.md`](guardrails/core.md) |
| 소프트웨어 공학 법칙 | [`guardrails/laws.md`](guardrails/laws.md) |
| TypeScript 선호 | [`guardrails/languages/typescript.md`](guardrails/languages/typescript.md) |
| Rust 선호 | [`guardrails/languages/rust.md`](guardrails/languages/rust.md) |
| Python 선호 | [`guardrails/languages/python.md`](guardrails/languages/python.md) |
| TDD 절차 | [`guardrails/workflows/tdd.md`](guardrails/workflows/tdd.md) |
| 리뷰 절차 | [`guardrails/workflows/review.md`](guardrails/workflows/review.md) |

검증:

```bash
# Windows PowerShell
.\scripts\validate-plugin.ps1

# macOS / Linux / Git Bash
bash scripts/validate-plugin.sh
```

---

## Available Skills

### Thinking & Strategy

| Skill | Trigger | Description |
|-------|---------|-------------|
| [clarify](#clarify) | `/clarify`, `명확히` | 명확화 라우터 — vague/unknown/metamedium 중 적절한 스킬로 위임 |
| [vague](#vague) | `요구사항 정리`, `spec this out` | 모호한 요구사항을 가설 기반 질문으로 구체적 스펙으로 변환 |
| [unknown](#unknown) | `blind spots`, `4분면 분석` | Known/Unknown 4분면으로 전략 사각지대 발견 |
| [metamedium](#metamedium) | `content vs form`, `관점 전환` | Content(무엇)과 Form(어떻게)을 구분해 레버리지 포인트 발견 |
| [moonshot](#moonshot) | `moonshot`, `10x`, `더 높은 목표` | 목표 성격에 맞는 프레임워크로 상향 목표 제안 |
| [deep-goal-council](#deep-goal-council) | `$deep-goal-council`, `목표가 작다`, `여러 경쟁 팀` | 경쟁형 장기 목표 하네스 — 1년/12주/7일 목표와 Judge Packet 생성 |
| [ouroboros](#ouroboros) | `ouroboros`, `심층 문서`, `deep spec` | 요구사항→설계→검증 3단계 심층 문서 생산 (모호성 메트릭 게이트) |

### Decision & Research

| Skill | Trigger | Description |
|-------|---------|-------------|
| [tech-decision](#tech-decision) | `A vs B`, `기술 선택` | 기술 의사결정을 4개 병렬 에이전트로 체계적 분석 |
| [agent-arena](#agent-arena) | `에이전트 토론`, `debate this` | 역할별 에이전트가 다라운드 토론 후 종합자가 결론 |
| [expert-review](#expert-review) | `전문가 리뷰`, `expert review` | 전문가 페르소나 자동 추천 → 병렬 리뷰 → 통합 제안 |

### Productivity

| Skill | Trigger | Description |
|-------|---------|-------------|
| [auto-commit](#auto-commit) | `자동 커밋`, `auto commit` | 작업 실행 후 자동 git commit & push |
| [live-verify](#live-verify) | `라이브 검증`, `live-verify` | Plan/Run 2단계 E2E 검증 (Playwright/Bash/curl) |
| [skill-manage](#skill-manage) | `스킬 관리`, `skill-add`, `skill-delete` | 스킬 추가/삭제/이름변경 + 메타데이터 4파일 원자적 동기화 |
| [life-plan](#life-plan) | `인생 계획`, `1년 방향`, `삶의 가치` | 6계층 인생 계획 코칭 — 평생 가치→1년 방향→3개월 챕터→월→주→일. 산출물 응축 (폴더 0 + 파일 2) |

### Development Quality

| Skill | Trigger | Description |
|-------|---------|-------------|
| [tdd](#tdd) | `tdd`, `테스트 먼저` | RED-GREEN-REFACTOR 강제 — 실패하는 테스트 없이 프로덕션 코드 금지 |
| [harness](#harness) | `harness`, `하네스`, `기획`, `문서작업`, `디자인`, `에이전트 팀` | 기획·문서작업·디자인·리서치·운영·개발 작업 표면별 하네스 + 에이전트 팀/오케스트레이터 부트스트랩 |
| [find-pulp](#find-pulp) | `find-pulp`, `하네스 꼬임`, `규칙 충돌`, `과도한 탐색` | 스킬·하네스·AGENTS·Codex 프롬프트·메모리의 충돌, 과도한 탐색, 원본/파생본 drift 감사 및 저위험 개선 |
| [review-loop](#review-loop) | `리뷰 루프`, `review-loop` | Tiered 리뷰 — code-reviewer 단독 → 필요 시 architect+critic 병렬 |
| [ai-slop-cleaner](#ai-slop-cleaner) | `deslop`, `AI 슬롭`, `슬롭 정리` | AI 슬롭 코드 정리 — 회귀 안전, 삭제 우선, 한 종류씩. `--review` 지원 |
| [ouroboros-run](#ouroboros-run) | `ouroboros-run`, `계획 실행` | ouroboros 계획을 Generator-Evaluator 루프로 실행 |

### Session & History

| Skill | Trigger | Description |
|-------|---------|-------------|
| [session-closing](#session-closing) | `/closing`, `/wrap` | 다중 에이전트 세션 마무리 — 분석/통합/액션 |
| [closing-lite](#closing-lite) | `/closing-lite`, `라이트 클로징` | 30초 경량 마무리 — 메모리 누적 전용 |
| [daily-report](#daily-report) | `daily-report`, `작업 보고서` | 로그·git·노트 등 여러 증거 소스를 읽어 감사 가능한 일일 작업 보고서 작성 |

### Content

| Skill | Trigger | Description |
|-------|---------|-------------|
| [youtube-digest](#youtube-digest) | `유튜브 정리`, `영상 요약` | 자막 추출 → 요약/번역/9문항 퀴즈 생성 |
| [youtube-slides](#youtube-slides) | `youtube-slides`, `자막 캡쳐` | 자막 구간별 프레임을 캡쳐해 슬라이드형 문서 생성 |

---

## Skill Details

### clarify

**명확화 라우터 — vague/unknown/metamedium 스킬로 위임.**

모드-neutral 키워드(`/clarify`, `명확히`)로 진입하면 AskUserQuestion으로 모드를 확인한 뒤 해당 스킬에 위임한다. 모드-specific 키워드는 각 specialist가 직접 소유하므로 라우터를 우회한다.

| Mode | 대상 스킬 | When to Use |
|------|-----------|-------------|
| vague | `/vague` | 요구사항이 모호하고 구체화 필요 |
| unknown | `/unknown` | 전략/계획의 숨겨진 가정과 사각지대 분석 |
| metamedium | `/metamedium` | Content(내용) vs Form(형식) 관점 전환 |

```bash
User: "/clarify - 뭘 원하는지 잘 모르겠어"   → AskUserQuestion → 모드 선택 → 위임
User: "blind spots 점검"                      → /unknown 직접 호출 (router 우회)
```

---

### vague

**모호한 요구사항을 가설 기반 질문으로 구체적 스펙으로 변환.**

열린 질문 대신 선택 가능한 가설을 제시해 인지 부하를 줄인다.

1. **Capture** — 원래 요구사항을 그대로 기록
2. **Question** — 가설 옵션이 포함된 5–8개 질문으로 모호성 해소
3. **Compare** — Before/After 비교 제시
4. **Save** — 명확화된 스펙을 파일로 저장 (선택)

| Before | After |
|--------|-------|
| "로그인 기능 추가해줘" | Goal: Email+Password 로그인. Scope: 로그인, 로그아웃, 회원가입, 비밀번호 재설정. Constraints: 24h 세션, bcrypt, 5회 시도 제한. |

---

### unknown

**Known/Unknown 4분면으로 전략 사각지대를 발견.**

3라운드 심화 질문으로 숨겨진 가정을 체계적으로 드러낸다.

| Round | 목적 | 질문 수 |
|-------|------|---------|
| R1 | 초안 검증 | 3–4개 (모든 분면 커버) |
| R2 | 약점 심화 | 2–3개 (R1 답변 기반 타겟팅) |
| R3 | 실행 세부 (선택) | 2–3개 |

**Output:** 4분면 매트릭스 + 실험 설계 + 실행 로드맵

```bash
User: "이 분기 사업 계획 blind spots 점검해줘"
User: "마이크로서비스 전환 전략에서 뭘 놓치고 있지?"
```

---

### metamedium

**Content(무엇)와 Form(어떻게)을 구분해 진짜 레버리지 포인트를 발견.**

> "A change of perspective is worth 80 IQ points." — Alan Kay

| | Content (what) | Form (how/medium) |
|--|----------------|-------------------|
| 예시 | LinkedIn 포스트 작성 | 컨설팅 회고를 포스트로 변환하는 도구 구축 |
| 예시 | 유닛 테스트 수동 작성 | 타입 시그니처에서 테스트 생성기 구축 |
| Leverage | Linear | Exponential |

---

### moonshot

**목표 성격에 맞는 프레임워크를 적용해 최고 수준의 상향 목표를 제안.**

하나의 상향 목표만 제안하며, 왜 이 수준이 가능한지 논리적 근거를 함께 제시한다.

**Trigger:** `moonshot`, `10x`, `더 높은 목표`, `stretch goal`, `BHAG`, `think bigger`

```bash
User: "이번 분기 매출 목표 1000만원인데 더 높게 잡고 싶어"
User: "moonshot - DAU 목표를 상향해줘"
```

---

### deep-goal-council

**여러 경쟁 팀이 장기 목표를 제안하고 사용자가 심사할 Judge Packet을 만든다.**

작고 단기적인 목표로 수렴하는 패턴을 보정하기 위해 `moonshot-team`, `compound-team`, `constraint-breaker-team`, `craft-team`, `operator-team`이 같은 입력을 서로 다른 철학으로 해석한다. 각 팀은 1년 북극성 목표, 12주 캠페인, 7일 첫 증거, Sentinel 비판, 실패 시 회수 전략을 제안한다.

**Trigger:** `$deep-goal-council`, `/deep-goal-council`, `목표가 작다`, `단기 목표로 축소된다`, `깊은 목표`, `여러 경쟁 팀`, `Judge Packet`

```bash
User: "$deep-goal-council AI 하네스 운영 역량을 1년 대표작으로 만들고 싶어"
User: "소설가가 되기 위한 1년짜리 장기 계획을 여러 팀이 경쟁해서 제안해줘"
```

---

### tech-decision

**기술 의사결정을 4개 병렬 에이전트로 체계적으로 분석.**

두괄식 결과물 — 결론을 먼저 제시하고 근거를 뒤에 배치한다.

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
User: "/expert-review docs/plan.md"
User: "/expert-review src/main.ts --count 5"
User: "전문가 리뷰 부탁 - README.md"
```

---

### auto-commit

**지시한 작업을 수행한 후 근거 있는 커밋 메시지로 git commit & push.**

작업 → 검증 → 커밋 메시지 작성 → 커밋 → 푸시를 하나의 흐름으로 자동화한다.
커밋 본문에 무엇을 바꿨는지, 왜 바꿨는지, 어떻게 검증했는지, 남은 위험을 남긴다.

```bash
User: "자동 커밋 - README 오타 수정해줘"
User: "auto commit - fix the login bug"
```

---

### live-verify

**구현된 기능을 실제 사용자처럼 테스트하는 2-Phase E2E 검증.**

```
Phase 1 (Plan): 작업 계획/PRD/코드 분석 → 검증 시나리오 자동 생성
Phase 2 (Run):  Playwright/Bash/curl로 실제 제품 조작 → 실패 시 자동 수정 + 재검증
```

```bash
User: "/live-verify"          # Phase 자동 감지
User: "/live-verify plan"     # Phase 1만 실행
User: "/live-verify run"      # Phase 2만 실행
```

---

### skill-manage

**스킬 추가/삭제/이름변경을 수행하면서 4개 메타데이터 파일과 다른 SKILL.md의 교차참조를 원자적으로 동기화.**

스킬 하나를 삭제할 때 수정해야 하는 파일:

- `CLAUDE.md` — "스킬 목록 (N개)" + 테이블 행
- `README.md` — 첫 줄 카운트 + TOC + 카테고리 테이블 + 상세 섹션 (4 위치)
- `.claude-plugin/marketplace.json` — 설명 개수 + 스킬명 리스트
- `GUIDE.md` — Marketplace 등록 예시
- 다른 `skills/*/SKILL.md` — description 트리거 + 본문 교차참조

수동으로 하면 10+ edit. 이 스킬이 워크플로우를 가이드해 누락을 방지한다.

**Trigger:** `skill-manage`, `스킬 관리`, `스킬 추가`, `스킬 삭제`, `skill-add`, `skill-delete`, `skill-rename`

```bash
User: "스킬 삭제 - foo 스킬 제거해줘"
User: "skill-add - 새 스킬 bar 만들자"
User: "skill-rename - baz를 qux로 바꿔줘"
```

> **예외:** `docs/plans/YYYY-MM-DD-*.md`는 frozen historical artifact이므로 건드리지 않는다.

---

### life-plan

**6계층 인생 계획 코칭 — 평생 가치 → 1년 방향 → 3개월 챕터 → 이번 달 시즌 → 이번 주 작전 → 오늘의 미션.**

mycraft 프로젝트에서 도출한 다층 계획 방법론을 어떤 세션에서도 호출 가능하게 만든 코칭 스킬. 인터뷰 + 자질 검사 + 70-20-10 분배 + 4문항 회고 + 전날 밤 5단 자가 체크리스트로 시스템적 발전 루프를 설계한다.

| 레이어 | 기간 | 핵심 |
|--------|------|------|
| 평생 가치 (Life Values) | 평생 | 죽기 전까지 잃기 싫은 것 1~3개. 다른 레이어가 깎으면 즉시 멈춤 |
| 1년 방향 (North Star) | 6~12mo | pillars 1~3, north_metric, anti_goal |
| 3개월 챕터 (Quarter Arc) | 3mo | theme(회복/정착/돌파/안정화), 70-20-10 |
| 이번 달 시즌 | 1mo | win_condition (Almost Daily 원칙) |
| 이번 주 작전 | 1wk | 핵심 1 + 보조 1 + 버릴 1 + 위험 신호 1 |
| 오늘의 미션 | 1d | 2~3개, What+When+Where, 1탭 완료 |

**자질 5종 (레이어별 적용):** 눈에 보이는가 / 내 손에 있는가 / 한 문장이 되는가 / 실패가 말이 되는가 / 내가 원해서 나왔는가. 평생 가치·1년 방향은 마지막 1개만 강함, 시즌 이하는 5개 모두.

**회고 4문항:** 사실 / 놀람 / 패턴 / 다음 (단 한 가지 강제).

**전날 밤 5단 (사용자 직접 운용):** 가치 점검 → 회고 4문항 → 이번 주 핵심 다시 보기 → 내일 미션 골격 → 핵심 미션 자질 5체크. 10~15분.

**저장 위치 (응축):** 기본값 `secondBrain/12_ai_zone/mycraft/` — 메인 `방향.md` + 월별 폴더 `YYYY-MM/`에 사람-친화 파일명 `M월 N주차.md`. 호출 시 다른 경로 원하면 사용자에게 묻기. 외부 폴더 read·write 금지.

**Trigger:** `life-plan`, `인생 계획`, `1년 방향`, `삶의 가치`, `시즌 계획`, `오늘 미션`, `전날 밤`, `회고 코칭`, `계획 짜자`

```bash
# 예시
User: "/life-plan 처음부터"
User: "이번 분기 다시 짜줘 — 1년 방향은 그대로"
User: "회고 코칭 이번 주만"
User: "전날 밤 체크리스트 안내"
```

---

### tdd

**RED-GREEN-REFACTOR 사이클을 강제하는 테스트 주도 개발.**

> 핵심 원칙: 테스트가 실패하는 걸 보지 않았다면, 그 테스트가 올바른 것을 검증하는지 알 수 없다.

1. **RED** — 실패하는 테스트 하나를 작성한다
2. **RED 검증** — 실행해서 실패를 확인한다 (필수, 절대 건너뛰지 않음)
3. **GREEN** — 테스트를 통과시키는 최소한의 코드를 작성한다
4. **GREEN 검증** — 실행해서 통과를 확인한다 (필수)
5. **REFACTOR** — 테스트를 GREEN으로 유지하면서 정리한다

테스트 전에 코드를 썼다면 — 삭제하고 다시 시작. 합리화 방지 테이블과 Red Flags 목록 내장.

**Trigger:** `tdd`, `TDD`, `테스트 먼저`, `test first`, `테스트 주도`, `RED GREEN REFACTOR`

```bash
User: "tdd - 이메일 검증 기능 구현해줘"
User: "테스트 먼저 - 결제 모듈 버그 수정"
```

---

### harness

**OpenAI 하네스 엔지니어링 기반으로 기획·문서작업·디자인·리서치·운영·개발 작업 표면별 하네스와 에이전트 팀/오케스트레이터를 한번에 구축.**

> 에이전트가 접근할 수 없는 것은 존재하지 않는 것. 구조화된 문서 체계가 에이전트 생산성을 결정한다. — OpenAI

**Three Pillars:**

1. **Context Engineering** — AGENTS.md, design-docs/, product-specs/로 에이전트에게 프로젝트 맥락 제공
2. **Architectural Constraints** — ARCHITECTURE.md, DESIGN.md, SECURITY.md로 의존성/설계 규칙 정의
3. **Entropy Management** — exec-plans/, tech-debt-tracker.md, RELIABILITY.md로 코드베이스 건강성 유지

인터뷰 → 작업 표면 분석 → 팀 아키텍처 설계 → 문서/에이전트/스킬/오케스트레이터 생성으로 목적, 입력, 산출물, 역할, 검증 기준, 운영 리듬을 구성한다. 기획, 문서작업, 디자인, 리서치, 운영, 개발 모두 지원하며 새 작업 부트스트랩, 기존 자료 보완, 에이전트 팀 신규 구축, 기존 하네스 점검/확장을 처리한다.

revfactory/harness의 팀 아키텍처 구성을 반영해 파이프라인, 팬아웃/팬인, 전문가 풀, 생성-검증, 감독자, 계층적 위임 패턴을 선택하고, 필요 시 오케스트레이터에 데이터 흐름·에러 핸들링·검증 시나리오를 포함한다. 코드가 없는 작업도 `work surface` 기준으로 기획/문서/디자인/리서치/운영 산출물을 만든다.

**Trigger:** `harness`, `하네스`, `하네스 엔지니어링`, `문서 체계`, `기획`, `문서작업`, `디자인`, `리서치`, `운영`, `에이전트 팀`, `오케스트레이터`, `하네스 구성`, `하네스 점검`, `에이전트/스킬 동기화`

```bash
User: "하네스 엔지니어링 세팅해줘"
User: "harness - 이 프로젝트에 문서 체계 구축"
User: "기획 하네스 만들어줘"
User: "디자인 작업용 오케스트레이터 구성해줘"
User: "에이전트 팀 하네스 구성해줘"
User: "오케스트레이터랑 스킬 동기화 점검해줘"
```

---

### find-pulp

**스킬, 하네스, AGENTS.md, CLAUDE.md, Codex 프롬프트, 메모리, 프로젝트 문서가 너무 많이 쌓여 서로 충돌하거나 과도한 탐색을 유발하는지 감사하고, 근거 기반으로 개선점을 제안하거나 안전한 범위에서 직접 정리.**

하네스를 더 키우기 전에 먼저 펄프를 찾는다. 같은 상황에서 반대 행동을 요구하는 규칙, 원본과 파생본의 카운트/트리거 drift, 여러 스킬이 동시에 강하게 반응하는 라우팅 충돌, 작업 전 필수 읽기 문서가 과도한 over-read loop, 실제 셸/OS와 맞지 않는 검증 명령, 개인 메모리와 팀 문서의 경계 누수를 증거 기반으로 분류한다.

핵심 원칙은 더하기 전에 빼기, 원본 우선, 가장 좁은 권위 문서 우선, 탐색 예산 명시, 저위험 수정만 즉시 적용이다. 분석만 요청하면 보고서로 멈추고, 개선까지 요청하면 카운트·링크·카탈로그·프롬프트 수·stale 문구처럼 검증 가능한 drift를 좁게 고친다.

**Trigger:** `find-pulp`, `하네스 꼬임`, `스킬 꼬임`, `규칙 충돌`, `지시사항 충돌`, `과도한 탐색`, `탐색 과잉`, `컨텍스트 과잉`, `하네스 감사`, `스킬 감사`, `source-of-truth drift`, `원본/배포본 드리프트`, `메모리/AGENTS/스킬 동기화`, `규칙이 너무 많아`, `에이전트가 헤매`

```bash
User: "find-pulp - 내 전역 AGENTS, 메모리, plugin-mh 스킬이 서로 꼬이는지 봐줘"
User: "하네스 꼬임 검사하고 명백한 카운트/프롬프트 drift는 고쳐줘"
User: "스킬들이 너무 많이 트리거되는 것 같은데 과도한 탐색 줄이는 방향으로 개선해줘"
```

---

### review-loop

**Tiered 리뷰로 코드 품질을 빠르게 검증.**

```
[Fast Path]
code-reviewer ──┐
                ├─ APPROVE/LOW만 → 종료
                └─ MEDIUM↑ 발견 → [Deep Path]
                                      ├─ architect ─┐
                                      └─ critic ────┴─ 최종 판정
                                          (병렬)
```

1차는 code-reviewer 단독으로 빠르게. MEDIUM 이상이 발견될 때만 architect+critic을 병렬 소환해 깊이 본다. 재체이닝은 변경 파일 + 영향 호출처만, 최대 3 cycle.

**Trigger:** `review-loop`, `리뷰 루프`, `리뷰 돌려`, `코드 리뷰 루프`, `리뷰하고 고쳐`

```bash
User: "리뷰 루프 돌려"
User: "review-loop - 방금 작성한 코드 검증해줘"
```

---

### ai-slop-cleaner

**AI가 생성한 슬롭 코드를 회귀 안전 + 삭제 우선 + 한 종류씩 정리하는 워크플로우.**

> 핵심 철학: **삭제 우선, 추가 신중**. 새 기능을 만드는 게 아니라 이미 있는 노이즈를 정리한다.

```
[1] 동작 보호 (테스트 우선) → [2] 정리 계획 → [3] 슬롭 분류
   → [4] 한 종류씩 단일 패스 → [5] 품질 게이트 → [6] 증거 밀도 보고
```

**슬롭 6분류**:

| 종류 | 정의 |
|------|------|
| Duplication | 반복 로직, 복붙 분기, 중복 헬퍼 |
| Dead code | 미사용 코드, 도달 불가 분기, 디버그 잔재 |
| Needless abstraction | 패스스루 래퍼, 사변적 간접 호출, 1회용 헬퍼 |
| Boundary violations | 숨겨진 결합, 잘못된 레이어 import/사이드 이펙트 |
| Missing tests | 락되지 않은 동작, 약한 회귀 커버리지 |
| UI/design defaults | 제너릭 비주얼 패턴 (AI 블루/퍼플, 균등 그리드 등) |

**단일 패스 편집**: Pass 1 Dead code → Pass 2 중복 → Pass 3 네이밍/에러 → Pass 4 테스트. 무관한 리팩토링 번들링 금지.

**Review Mode (`--review`)**: 편집 금지. 리뷰어 판정 + 후속 조치 항목만 작성. Writer ↔ Reviewer 분리 강제.

**Trigger:** `ai-slop-cleaner`, `deslop`, `anti-slop`, `AI slop`, `AI 슬롭`, `슬롭 정리`, `쓰레기 코드 청소`, `코드 슬롭`

```bash
User: "deslop this module: 너무 많은 래퍼, 중복 헬퍼, 죽은 코드"
User: "/ai-slop-cleaner src/auth --review"
User: "AI 슬롭 정리 — 동작은 그대로 두고 경계만 조이기"
```

---

### ouroboros

**모호한 아이디어를 3단계 파이프라인으로 심화해 깊이 있는 문서 세트를 생산.**

> 핵심 철학: 모호성을 수치로 추적하고, 문턱값(20%) 이하가 될 때까지 반복한다.

```
Phase 1: 요구사항 심화 → Phase 2: 설계 심화 → Phase 3: 검증 심화
         (품질 게이트)          (품질 게이트)          (품질 게이트)
```

각 Phase에서:

- 차원별 점수(0–1) × 가중치로 모호성 계산
- 모호성 ≤ 20%이면 다음 Phase로 진행
- 초과 시 가장 약한 차원에 타겟 질문 → 반복

**Output:** 3개 문서 세트 (`docs/ouroboros/{date}-{slug}/`)

1. `01-requirements.md` — 목표, 제약, 비목표, 수용기준
2. `02-design.md` — ADR, 기술스펙, 다이어그램, 파일별 계획
3. `03-verification.md` — E2E 시나리오, 엣지케이스, 성공/실패 기준

**Trigger:** `ouroboros`, `우로보로스`, `심층 문서`, `deep spec`, `요구사항부터 검증까지`

```bash
User: "ouroboros - 사내 피드백 수집 도구 기획부터 검증까지"
User: "심층 문서 - 구독 결제 시스템 설계해줘"
```

---

### ouroboros-run

**ouroboros 계획 문서를 Generator-Evaluator 루프로 실행.**

ouroboros가 생산한 3개 문서(요구사항/설계/검증)를 입력으로 받아, 설계의 파일별 구현 계획을 story로 분해하고 순차 구현한다. Planner-Generator-Evaluator 3역할 분리 원칙 적용.

**Flow:**

1. **Phase 0** — ouroboros 문서 자동 감지 + story 분해 → `stories.json`
2. **Phase 1** — Story 루프: Generator(sonnet) 구현 → Evaluator(opus) 검증 → FAIL 시 재시도 (max 3회)
3. **Phase 2** — 전체 완료 후 review-loop 체이닝
4. **Phase 3** — 최종 보고

ouroboros 문서가 없으면 범용 계획 문서도 입력 가능 (폴백).

**Partial Ship 옵션:** 일부 story가 max 재시도(3회) 후에도 FAIL이면 "지금까지 PASS한 것만 Ship" 선택 가능. 통과한 story들을 커밋하고 `RELIABILITY.md`에 미구현 항목을 기록한 뒤 종료한다.

**Trigger:** `ouroboros-run`, `우로보로스 실행`, `계획 실행`, `문서 기반 구현`, `run the plan`

```bash
User: "ouroboros-run - docs/ouroboros/2026-04-07-auth/ 실행해줘"
User: "계획 실행 - 아까 만든 설계 문서대로 구현해줘"
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

### closing-lite

**session-closing의 경량 버전 — 30초 안에 끝내는 메모리 누적 전용.**

session-closing이 5개 에이전트 + 2 phase로 무겁다고 느낄 때 사용. 본질만 남겼다 — 이번 세션에서 기억할 만한 것만 골라 auto-memory에 누적. 에이전트 호출/문서 갱신/자동화 제안 모두 없음.

```
1. git status (한 줄)
2. 인라인 추출 (이슈 / 배운 점 / 기억할 것)
3. AskUserQuestion 1회 — 어느 항목을 메모리에 남길지
4. 선택 항목을 memory/{type}_{slug}.md + MEMORY.md에 기록
```

| 상황 | 적합 |
|------|------|
| 짧은 세션이지만 기억할 인사이트가 있음 | closing-lite |
| 큰 기능 완성 + 문서/자동화/커밋 종합 검토 | `/closing` |

**Trigger:** `/closing-lite`, `/clite`, `라이트 클로징`, `간단 마무리`, `메모만`, `세션 메모`

```bash
User: "/closing-lite"
User: "라이트 클로징 - 오늘 작업한 거 기억할 것만"
```

---

### daily-report

**도구 비종속 일일 작업 보고서 생성기.**

Codex, Claude, git, 로컬 노트, 터미널 히스토리, 사용자가 지정한 파일을 증거 소스로 읽고 하루 또는 지정 기간의 작업 흐름을 Markdown 보고서로 정리한다. memory/harness에는 기본으로 쓰지 않고, 보고서 끝에 읽은 소스와 읽지 못한 소스를 남긴다.

**Output:** `reports/YYYY-MM-DD-daily-report.md` 또는 사용자가 지정한 Markdown 경로.

**기본 섹션:** Executive Summary, Timeline, Work By Project, Decisions, Problems And Resolutions, Files And Artifacts, Follow-Ups, Evidence Sources.

**Trigger:** `daily-report`, `daily report`, `작업 보고서`, `일일 보고서`, `오늘 대화 요약`, `오늘 작업 정리`, `로그 기반 보고서`, `하루종일 한 일 정리`

```bash
User: "daily-report - 오늘 00:00부터 지금까지 작업 보고서 작성"
User: "오늘 Codex랑 Claude 로그 전부 읽고 작업 보고서로 남겨줘. memory에는 쓰지 마"
```

---

### youtube-digest

**YouTube URL을 넣으면 요약, 인사이트, 한국어 번역, 9문항 퀴즈를 생성.**

1. **Summary** — 3–5문장 핵심 요약
2. **Insights** — 실행 가능한 인사이트
3. **Full transcript** — 한국어 번역 + 타임스탬프
4. **3-stage quiz** — Basic, Intermediate, Advanced (총 9문항)
5. **Deep Research** (선택) — 웹 검색 기반 후속 탐구

**Output:** `research/readings/youtube/YYYY-MM-DD-title.md`

```bash
User: "이 영상 정리해줘 https://youtube.com/watch?v=..."
User: "유튜브 정리 - [URL]"
```

---

### youtube-slides

**YouTube 영상의 자막 구간별로 프레임을 캡쳐해 슬라이드형 문서를 생성.**

yt-dlp로 영상을 다운받고, 자막 타임스탬프 기준으로 ffmpeg가 프레임을 캡쳐한다.

1. **Markdown 문서** — 자막과 캡쳐 이미지가 매핑된 슬라이드
2. **HTML 문서** — 브라우저에서 바로 볼 수 있는 슬라이드 뷰
3. **Images 폴더** — 자막 구간별 캡쳐 이미지

**Dependencies:** `yt-dlp`, `ffmpeg`, `Python 3`

**Trigger:** `youtube-slides`, `자막 캡쳐`, `영상 슬라이드`

```bash
User: "youtube-slides https://youtube.com/watch?v=..."
User: "자막 캡쳐 - [URL]"
```

---

## Agents

### code-reviewer

**Severity 기반 코드 리뷰 에이전트.** CRITICAL / HIGH / MEDIUM / LOW 등급으로 결과를 분류하며 로직 결함, 보안, SOLID 원칙, 성능을 점검한다.

`review-loop` 스킬의 1차 리뷰어로도 사용된다.

```bash
User: "code-reviewer로 방금 작성한 모듈 검토해줘"
```

### knowledge-curator

**지식 큐레이션 에이전트.** 세션에서 재사용 가능한 학습·패턴·선호도·후속작업만 추출해 auto-memory에 누적한다. 노이즈를 걸러 영속 가치만 남기며(KEEP/DROP 게이트), 보고서 경로가 주어지면 마크다운 다이제스트도 남긴다.

호출 시 **세션 맥락 + 메모리 디렉토리 경로**를 인자로 전달한다(서브에이전트는 부모 대화를 보지 못하므로 필수). `session-closing`·`closing-lite`가 위임할 워커로 설계됐다.

```bash
User: "knowledge-curator로 이번 세션에서 배운 것 메모리에 정리해줘"
```

---

## Writing Your Own Skill

```
skills/my-skill/
├── SKILL.md              # Required — defines triggers and workflow
├── references/           # Optional — supporting docs
└── agents/               # Optional — sub-agent definitions
```

상세 가이드는 [GUIDE.md](GUIDE.md) 참고.

## License

MIT
