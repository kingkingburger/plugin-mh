# live-verify 스킬 설계 문서

**일시**: 2026-03-09
**상태**: 승인됨

---

## 개요

live-verify는 작업 계획 시 검증 기준을 설정하고(Phase 1), 구현 후 실제 제품을 유저와 동일하게 조작하여 E2E 검증을 실행하는(Phase 2) Claude Code 플러그인 스킬이다.

### 핵심 원칙
- 코드 리뷰/린트가 아닌 **실제 제품 조작** 기반 검증
- 검증 실패 시 **자동 수정 + 재검증 사이클** (max 100회)
- 범용 대상: 웹(Playwright), CLI(Bash), API(curl)

---

## 아키텍처

```
live-verify/
├── SKILL.md                    # 메인 스킬 정의
└── references/
    ├── scenario-template.md    # 검증 시나리오 작성 템플릿
    └── report-template.md      # Markdown 보고서 템플릿
```

### 출력 형식
- **Markdown 보고서만** (`docs/verify/{date}-{topic}.md`)
- HTML 대시보드 없음 (8인 Arena 토론 결과 만장일치 제거)
- 보고서 상단에 요약 섹션 강제: `총 N건 / PASS X / FAIL Y`
- JSON-ready 내부 설계: 향후 `--format json` 전환 가능

### 호출 방식
- `/live-verify` — 자동 감지 (기존 시나리오 있으면 Phase 2, 없으면 Phase 1부터)
- `/live-verify plan` — Phase 1만 실행
- `/live-verify run` — Phase 2만 실행 (기존 시나리오 필요)

---

## Phase 1: Plan (검증 기준 설정)

### 입력
- 작업 계획, PRD, 코드 경로
- ralph-prep PRD 자동 감지 (`docs/prd/` 스캔)

### 프로세스
1. 입력 분석 → 대상 타입 자동 감지 (웹/CLI/API)
2. 대상 타입별 검증 도구 매핑:
   - 웹 → Playwright (click, fill, snapshot, screenshot)
   - API → Bash (curl)
   - CLI → Bash (명령어 실행 + 출력 비교)
3. 각 기능/페이즈별 검증 시나리오 자동 생성
4. 사용자에게 시나리오 목록 제시 → AskUserQuestion으로 확인/수정
5. `docs/verify/{date}-{topic}-scenarios.md`에 저장

### 시나리오 구조
```markdown
### S01: 로그인 성공
- 대상: 웹
- 도구: Playwright
- 사전조건: 서버 localhost:3000 실행 중
- 단계:
  1. /login 페이지 이동
  2. email 필드에 "test@test.com" 입력
  3. password 필드에 "password123" 입력
  4. "로그인" 버튼 클릭
- 기대결과: /dashboard로 리다이렉트, "환영합니다" 텍스트 존재
```

---

## Phase 2: Execute (검증 실행)

### 입력
- Phase 1에서 생성된 시나리오 파일

### 프로세스
1. 시나리오 파일 로드
2. 사전 조건 확인 (서버 실행 여부, 포트 확인 등)
3. 시나리오 순차 실행:
   - 각 단계를 해당 도구(Playwright/Bash/curl)로 실행
   - 기대 결과와 실제 결과 비교
   - 스크린샷/출력 캡처
4. **실패 시 자동 수정 사이클** (max 100회):
   - 실패 원인 분석 (에러 메시지, 스크린샷, 로그)
   - 관련 코드 수정
   - 해당 시나리오만 재실행
   - 통과 시 다음 시나리오로 진행
5. 전체 완료 후 Markdown 보고서 생성

### 보고서 구조
```markdown
## 요약: 총 10건 검증 / PASS 8건 / FAIL 2건

| # | 시나리오 | 결과 | 수정횟수 | 비고 |
|---|---------|------|---------|------|
| S01 | 로그인 성공 | PASS | 0 | - |
| S02 | 비밀번호 오류 | FAIL | 3 | 에러 메시지 불일치 |

## 상세 결과
### S01: 로그인 성공 — PASS
- 실행 시간: 2.3s
- 수정 횟수: 0

### S02: 비밀번호 오류 — FAIL
- 실행 시간: 45.2s
- 수정 횟수: 3
- 실패 원인: 에러 메시지 텍스트 불일치
- 기대: "비밀번호가 틀렸습니다"
- 실제: "Invalid credentials"
```

---

## 스킬 연계

| 연계 대상 | 방식 |
|-----------|------|
| ralph-prep | `docs/prd/` PRD 자동 감지 → 시나리오 생성 |
| clarify | 검증 실패 원인이 요구사항 모호함일 때 추천 |
| tech-decision | 기술 의사결정 필요 시 추천 |

---

## Arena 토론 결과 (출력 형식 결정)

- **8인 만장일치**: HTML 대시보드 제거
- **4:3 다수결**: JSON 즉시 도입 반대 (YAGNI)
- **절충안 채택**: JSON-ready 내부 설계 (출력은 MD만, 내부 데이터는 구조화)
- 상세: `decisions/2026-03-09-live-verify-output-format.md` 참조

---

## 설계 결정 근거

| 결정 | 근거 |
|------|------|
| MD 단일 출력 | 듀얼 출력 유지보수 부채 회피, 기존 스킬 일관성 |
| max 100회 재시도 | 사용자 요구. 컨텍스트 윈도우 한계에서 자연 종료 |
| 범용 대상 (웹/CLI/API) | 사용자 요구. 대상별 도구 자동 선택 |
| 에이전트 자동 시나리오 생성 | 사용자 확인 단계 포함하여 안전성 확보 |
| Phase 독립 호출 | ralph-prep 패턴 재사용. 유연성 확보 |
