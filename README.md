# plugin-mh

Claude Code plugin with 18 custom skills for thinking, deciding, and building smarter.

## Table of Contents

- [Quick Start](#quick-start)
- [Available Skills](#available-skills)
- [Skill Details](#skill-details)
  - [clarify](#clarify) - 3-in-1 요구사항 명확화
  - [vague](#vague) - 모호한 요구사항을 스펙으로
  - [unknown](#unknown) - 전략 사각지대 분석
  - [metamedium](#metamedium) - Content vs Form 관점 전환
  - [moonshot](#moonshot) - 목표 상향 프레임워크
  - [tech-decision](#tech-decision) - 기술 의사결정 심층 분석
  - [agent-arena](#agent-arena) - 다관점 에이전트 토론
  - [agent-council](#agent-council) - 멀티 AI 의견 종합
  - [dev-scan](#dev-scan) - 개발 커뮤니티 여론 스캔
  - [auto-commit](#auto-commit) - 작업 후 자동 커밋 & 푸시
  - [ralph-prep](#ralph-prep) - PRD 작성 심층 인터뷰
  - [review](#review) - 웹 UI 인터랙티브 리뷰
  - [live-verify](#live-verify) - E2E 라이브 검증
  - [google-calendar](#google-calendar) - 멀티 계정 캘린더
  - [session-closing](#session-closing) - 세션 마무리 분석
  - [session-analyzer](#session-analyzer) - 세션 행동 검증
  - [history-insight](#history-insight) - 세션 히스토리 분석
  - [youtube-digest](#youtube-digest) - 유튜브 요약 & 퀴즈
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
| [clarify](#clarify) | `/clarify`, `명확히` | 3-in-1 clarification — requirements, blind spots, content vs form |
| [vague](#vague) | `요구사항 정리`, `spec this out` | Turn ambiguous requirements into actionable specs |
| [unknown](#unknown) | `blind spots`, `4분면 분석` | Surface hidden assumptions with Known/Unknown quadrant analysis |
| [metamedium](#metamedium) | `content vs form`, `관점 전환` | Reframe problems by distinguishing what from how |
| [moonshot](#moonshot) | `moonshot`, `10x`, `더 높은 목표` | Push goals higher with proven goal-setting frameworks |

### Decision & Research

| Skill | Trigger | Description |
|-------|---------|-------------|
| [tech-decision](#tech-decision) | `A vs B`, `기술 선택` | Systematic multi-source analysis for technical decisions |
| [agent-arena](#agent-arena) | `에이전트 토론`, `debate this` | Multiple AI agents debate a topic across rounds, then synthesize |
| [agent-council](#agent-council) | `summon the council` | Collect and synthesize opinions from multiple AI agents |
| [dev-scan](#dev-scan) | `개발자 반응`, `developer reactions` | Scan Reddit, HN, Dev.to for community opinions on tech topics |

### Productivity

| Skill | Trigger | Description |
|-------|---------|-------------|
| [auto-commit](#auto-commit) | `자동 커밋`, `auto commit` | Execute instructions, then auto commit & push |
| [ralph-prep](#ralph-prep) | `PRD 작성`, `ralph-prep` | Deep interview to turn ideas into crystal-clear PRDs |
| [review](#review) | `검토해줘`, `review this` | Interactive markdown review with web UI |
| [live-verify](#live-verify) | `라이브 검증`, `live-verify` | 2-Phase E2E verification — Plan scenarios, then Execute with Playwright/Bash/curl |
| [google-calendar](#google-calendar) | `오늘 일정`, `미팅 추가해줘` | Google Calendar CRUD with multi-account support |

### Session & History

| Skill | Trigger | Description |
|-------|---------|-------------|
| [session-closing](#session-closing) | `/closing`, `/wrap` | Multi-agent session wrap-up with learning extraction |
| [session-analyzer](#session-analyzer) | `세션 분석`, `analyze session` | Post-hoc validation of skill/agent/hook behavior |
| [history-insight](#history-insight) | `capture session` | Access and reference Claude Code session history |

### Content & Social

| Skill | Trigger | Description |
|-------|---------|-------------|
| [youtube-digest](#youtube-digest) | `유튜브 정리`, `영상 요약` | Transcript extraction, summary, translation, and quiz generation |

---

## Skill Details

### clarify

**모호함을 제거하는 3-in-1 명확화 도구.**

하나의 스킬로 3가지 모드를 제공합니다. 상황에 맞는 모드가 자동 선택됩니다.

| Mode | When to Use |
|------|-------------|
| **vague** | 요구사항이 모호하고 구체화 필요 |
| **unknown** | 전략/계획의 숨겨진 가정과 사각지대 분석 |
| **metamedium** | Content(내용) vs Form(형식) 관점 전환 |

**Trigger:** `/clarify`, `명확히`, `요구사항 정리`, `blind spots`, `content vs form`

```bash
# 예시
User: "/clarify vague - 로그인 기능 추가해줘"
User: "/clarify unknown - 이 마이그레이션 계획 점검해줘"
User: "/clarify metamedium - 블로그 글 쓰고 있는데 더 효과적인 방법 없을까"
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
│ codebase-       │ docs-           │ dev-scan        │ agent-council   │
│ explorer        │ researcher      │ (community)     │ (AI experts)    │
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

### agent-council

**여러 AI 모델(Gemini, GPT, Codex)에게 동시에 질문하고 의견을 종합.**

1. 질문을 여러 AI 에이전트에 동시 전달
2. 각 에이전트가 관점을 제시
3. Claude가 합의점과 이견을 종합

**Trigger:** `summon the council`, `ask other AIs`

```bash
# 예시
User: "summon the council - TypeScript strict mode 도입 어떻게 생각해?"
```

---

### dev-scan

**Reddit, HN, Dev.to, Lobsters에서 기술 주제에 대한 커뮤니티 의견을 병렬 수집.**

- 찬반 의견 분포
- 실무자들의 경험담
- 숨겨진 우려사항이나 장점
- 독특하거나 주목할 만한 시각

```bash
# 예시
User: "Bun에 대한 개발자 반응 알려줘"
User: "developer reactions to Tailwind v4"
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

### ralph-prep

**머릿속 아이디어를 유저 시나리오가 선명한 PRD로 변환하는 심층 인터뷰.**

> 핵심 철학: "애매모호함이라는 그림자가 거의 아예 남지 않을 정도로" 대화한다. 질문 수 제한 없음.

**Output:** 유저 시나리오, 의사결정 기록, 검증 계획이 포함된 PRD 문서

```bash
# 예시
User: "ralph-prep - 사내 피드백 수집 도구 기획해줘"
User: "PRD 작성 - 구독 결제 시스템"
```

---

### review

**마크다운 문서를 브라우저 기반 웹 UI에서 인터랙티브하게 리뷰.**

1. 리뷰할 콘텐츠를 선택하면 브라우저가 자동 열림
2. 각 항목에 체크박스와 코멘트로 피드백
3. Submit하면 구조화된 피드백이 Claude에게 전달

**Trigger:** `/review`, `검토해줘`, `review this`

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

### google-calendar

**여러 Google 계정(회사, 개인 등)의 캘린더를 한 번에 조회하고 관리.**

- 사전 인증된 refresh token (매번 로그인 불필요)
- Subagent 병렬 실행으로 빠른 조회
- 계정 간 일정 충돌 감지
- Full CRUD (조회, 생성, 수정, 삭제)

```bash
# 예시
User: "오늘 일정 알려줘"
User: "내일 2시에 미팅 추가해줘"
User: "이번 주 스케줄 충돌 확인해줘"
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

### session-analyzer

**완료된 세션의 스킬/에이전트/훅 실행을 SKILL.md 사양 대비 검증.**

- Expected vs Actual 행동 비교
- SubAgent, Hook, Tool 호출 정확성 점검
- 예상 파일 생성/삭제 확인
- 버그 및 이탈 감지

```bash
# 예시
User: "세션 분석 - clarify 스킬이 제대로 실행됐는지 확인해줘"
```

---

### history-insight

**Claude Code 세션 히스토리를 분석하고 인사이트를 추출.**

- 현재 프로젝트 또는 전체 세션 검색
- 테마, 의사결정, 반복 패턴 추출

**Trigger:** `capture session`, `save session history`, `what we discussed`

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
