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
