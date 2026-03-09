---
name: live-verify
version: 0.1.0
description: >
  This skill should be used when the user wants to verify that implemented features actually work by testing them like a real user.
  Trigger on "live-verify", "라이브 검증", "E2E 검증", "실제 검증", "검증 실행",
  "검증 계획", "verify plan", "verify run", "검증 시나리오", "동작 검증",
  "실제로 돌려봐", "작동하는지 확인", "브라우저로 테스트", "end to end test",
  "검증 기준 설정", "acceptance test", "인수 테스트".
  Phase 1(plan): 작업 계획/PRD/코드를 분석하여 검증 시나리오를 자동 생성.
  Phase 2(run): 실제 제품을 Playwright/Bash/curl로 조작하여 E2E 검증 실행. 실패 시 자동 수정 + 재검증 사이클 (max 100회).
  `/live-verify` 자동 감지, `/live-verify plan` Phase 1만, `/live-verify run` Phase 2만.
allowed-tools:
  - AskUserQuestion
  - Read
  - Glob
  - Grep
  - Write
  - Edit
  - Bash
  - Agent
  - mcp__plugin_playwright_playwright__browser_navigate
  - mcp__plugin_playwright_playwright__browser_click
  - mcp__plugin_playwright_playwright__browser_fill_form
  - mcp__plugin_playwright_playwright__browser_type
  - mcp__plugin_playwright_playwright__browser_snapshot
  - mcp__plugin_playwright_playwright__browser_take_screenshot
  - mcp__plugin_playwright_playwright__browser_press_key
  - mcp__plugin_playwright_playwright__browser_wait_for
  - mcp__plugin_playwright_playwright__browser_hover
  - mcp__plugin_playwright_playwright__browser_select_option
  - mcp__plugin_playwright_playwright__browser_tabs
  - mcp__plugin_playwright_playwright__browser_console_messages
  - mcp__plugin_playwright_playwright__browser_network_requests
---

# Live Verify: 실제 제품을 유저처럼 조작하여 E2E 검증

작업 계획에서 검증 기준을 설정하고(Phase 1), 구현 후 실제 제품을 브라우저/CLI/API로 조작하여 검증한다(Phase 2). 코드 리뷰나 린트가 아닌, **유저와 완전히 동일한 방식**으로 동작을 확인한다.

> **핵심 철학**: "코드가 맞다"가 아니라 "제품이 동작한다"를 증명한다.

---

## 절대 원칙

1. **실제 제품을 조작한다.** 단위 테스트/코드 리뷰가 아닌, 로컬에서 띄운 제품을 에이전트가 직접 클릭/입력/확인한다.
2. **모든 질문은 AskUserQuestion 도구로.** 일반 텍스트로 질문하지 않는다.
3. **가설 기반 질문.** 열린 질문 대신 구체적 옵션을 제시한다.
4. **실패하면 고친다.** 검증 실패 시 원인을 분석하고 코드를 수정한 뒤 재검증한다. 최대 100회.
5. **중간 저장.** Phase 1 완료 시 시나리오 파일을, Phase 2 완료 시 보고서 파일을 반드시 저장한다.

---

## 호출 방식

| 명령 | 동작 |
|------|------|
| `/live-verify` | 자동 감지 — `docs/verify/` 에 시나리오 파일이 있으면 Phase 2, 없으면 Phase 1부터 |
| `/live-verify plan` | Phase 1만 실행 (검증 시나리오 생성) |
| `/live-verify run` | Phase 2만 실행 (기존 시나리오 파일 필요) |

---

## 진입 판단

스킬 호출 시 자동으로 상태를 판단한다:

1. 사용자가 `plan` 또는 `run`을 명시했으면 해당 Phase로 직행
2. 명시하지 않았으면:
   - `docs/verify/` 에서 최신 시나리오 파일(`*-scenarios.md`)을 Glob으로 검색
   - 있으면 → Phase 2로 진행 (해당 파일 사용)
   - 없으면 → Phase 1부터 시작

입력 소스 판단:

| 입력 상태 | 판단 기준 | 행동 |
|-----------|-----------|------|
| **인자로 경로 제공** | 파일 경로가 함께 전달됨 | 해당 파일을 읽고 분석 |
| **PRD 자동 감지** | `docs/prd/` 에 PRD 파일 존재 | 최신 PRD를 읽어 시나리오 생성 |
| **코드 경로 제공** | src/, app/ 등 코드 디렉토리 | 코드를 분석하여 기능 도출 → 시나리오 생성 |
| **아무것도 없음** | 입력 없음 | AskUserQuestion으로 대상 확인 |

---

## Phase 1: Plan — 검증 기준 설정

### 목적
작업 계획/PRD/코드를 분석하여, 실제 제품에서 검증할 시나리오를 자동 생성한다.

### 프로세스

#### 1-1: 입력 분석 및 대상 타입 감지

입력을 Read/Glob/Grep으로 분석하여 대상 타입을 자동 감지한다:

| 신호 | 대상 타입 |
|------|----------|
| package.json에 react/next/vue/svelte | 웹 |
| HTML/CSS 파일 존재 | 웹 |
| CLI 엔트리포인트 (bin/, cli.ts 등) | CLI |
| API 라우트 (routes/, api/, endpoints/) | API |
| PRD에 "화면", "페이지", "버튼" 언급 | 웹 |
| PRD에 "명령어", "옵션", "플래그" 언급 | CLI |
| PRD에 "엔드포인트", "요청", "응답" 언급 | API |

감지 결과를 AskUserQuestion으로 사용자에게 확인:

```
questions:
  - question: "감지된 대상 타입이 맞나요?"
    header: "대상 타입"
    options:
      - label: "{감지된 타입} (Recommended)"
        description: "{감지 근거 요약}"
      - label: "웹 (Playwright)"
        description: "브라우저에서 클릭/입력으로 검증"
      - label: "CLI (Bash)"
        description: "명령어 실행 + 출력 비교로 검증"
      - label: "API (curl)"
        description: "HTTP 요청 + 응답 비교로 검증"
    multiSelect: false
```

#### 1-2: 검증 시나리오 자동 생성

입력(PRD/코드/작업 계획)을 분석하여 시나리오를 자동 생성한다.

**참조**: `references/scenario-template.md`의 템플릿을 따른다.

생성 기준:
- **정상 시나리오**: 핵심 유저 플로우 각각에 대해 1개 이상
- **엣지케이스**: 빈 입력, 극단적 길이, 특수문자, 권한 없음 등
- **에러 시나리오**: 잘못된 입력, 서버 에러, 타임아웃 등
- **회귀 시나리오**: 기존 기능이 깨지지 않는지 (코드 변경 범위 기반)

각 시나리오의 "단계"는 검증 도구의 실제 동작과 1:1 매핑되어야 한다:
- 웹: "로그인 버튼 클릭" → `browser_click` 호출로 직접 변환 가능해야 함
- CLI: "help 명령어 실행" → `Bash`로 직접 실행 가능해야 함
- API: "POST /api/users 호출" → `curl` 명령어로 직접 변환 가능해야 함

#### 1-3: 사용자 확인

생성된 시나리오 목록을 사용자에게 제시하고 AskUserQuestion으로 확인:

```
questions:
  - question: "생성된 검증 시나리오 {N}건을 확인해주세요. 수정이 필요한가요?"
    header: "시나리오 확인"
    options:
      - label: "좋습니다, 저장해주세요"
        description: "시나리오를 그대로 저장하고 Phase 1을 완료합니다"
      - label: "시나리오 추가 필요"
        description: "빠진 시나리오가 있어서 추가하고 싶습니다"
      - label: "시나리오 수정 필요"
        description: "기존 시나리오의 단계나 기대결과를 수정하고 싶습니다"
      - label: "시나리오 삭제 필요"
        description: "불필요한 시나리오를 제거하고 싶습니다"
    multiSelect: false
```

수정이 필요하면 반복한다.

#### 1-4: 시나리오 파일 저장

`docs/verify/{YYYY-MM-DD}-{주제슬러그}-scenarios.md`에 저장한다.

### Phase 1 완료 시 안내

> **"검증 시나리오가 저장되었습니다: `docs/verify/{파일명}`**
>
> **이제 구현을 진행한 후 `/live-verify run`으로 검증을 실행할 수 있습니다.**
> **또는 `/live-verify`를 실행하면 자동으로 이 시나리오 파일을 감지하여 Phase 2를 시작합니다."**
