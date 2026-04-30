# ~/.codex/AGENTS.md — 개인 글로벌 가이드 (원민호)

> 이 파일은 `~/.codex/AGENTS.md` 로 복사하면 Codex가 모든 프로젝트에서 본 가이드를 자동 로드한다.
> 프로젝트별 AGENTS.md가 있으면 그것이 우선하고, 본 파일은 보조로 작용한다.
>
> **설치**: `cp codex/user-global-AGENTS.md ~/.codex/AGENTS.md`
> 또는 Windows: `Copy-Item codex/user-global-AGENTS.md $env:USERPROFILE\.codex\AGENTS.md`

---

## 사용자 프로필

- **이름**: 원민호
- **역할**: 소프트웨어 엔지니어
- **환경**: Windows
- **선호 언어**: Python (with `uv`), TypeScript (with `bun`)
- **응답 언어**: 한국어 (기술 용어 / 코드 식별자는 원문 유지)

## 소통 / 업무 스타일

- 간결하고 핵심만 전달 — 단, 필요한 곳엔 상세한 배경 / 이유 함께
- 큰 작업은 단계별로 확인받으며 진행
- 방향이 명확하면 자율적으로 끝까지 진행하고 결과만 보고
- 모호한 부분은 반드시 질문 (자연어 번호 옵션 형식)

## 응답 규칙

- 작업 완료 후 생성 / 변경한 파일은 **전체 경로** 로 출력
- 새 개인 정보 / 선호도 / 프로젝트 패턴 발견 시 메모리 업데이트 제안
- 코드 / 식별자는 원문, 설명은 한국어
- 한국어 정서법 준수 — 특수 문자(ä, ö, ü, ç, ñ 등)를 ASCII로 치환 금지

## 즐겨 쓰는 도구 (있을 때만)

- **AskUserQuestion** (Claude 한정) — 질문할 땐 반드시. Codex에서는 자연어 번호 옵션으로 대체.
- **Tasks / TaskCreate** — 여러 단계 작업 추적
- **Explore agent** — 정보 파악 / 코드베이스 탐색

---

## plugin-mh 슬래시 커맨드 활용

다음 21개 명령어가 `~/.codex/prompts/` 에 설치되어 있다면 사용자 자연어 의도에 맞춰 자동 활용:

### 사고 정리 (Clarification)
- 모호한 요구 → `/vague`
- 전략 사각지대 → `/unknown`
- 관점 전환 → `/metamedium`
- 어떤 것일지 모르겠음 → `/clarify`
- 목표 상향 → `/moonshot`

### 의사결정 / 리뷰
- 기술 선택 (A vs B) → `/tech-decision`
- 다관점 토론 → `/agent-arena`
- 문서 리뷰 → `/expert-review`
- 단독 코드 리뷰 → `/code-review`
- 체이닝 리뷰 → `/review-loop`

### 개발
- 테스트 주도 → `/tdd`
- 프로젝트 문서 체계 → `/harness`
- 자동 커밋 → `/auto-commit`
- E2E 검증 → `/live-verify`

### 스펙 / 실행
- 깊이 있는 스펙 → `/ouroboros`
- 계획 실행 → `/ouroboros-run`

### 세션
- 경량 마무리 → `/closing-lite`
- 풀 마무리 → `/session-closing`

### 콘텐츠
- YouTube 요약 → `/youtube-digest`
- YouTube 슬라이드 캡쳐 → `/youtube-slides`

### 메타
- 스킬 관리 → `/skill-manage` (plugin-mh 저장소 작업 시만)

---

## 자동 라우팅 트리거

사용자 입력 패턴에서 다음이 보이면 해당 명령어를 우선 제안 또는 실행:

| 입력 패턴 | 제안 명령어 |
|----------|-------------|
| "어떻게", "고민", "뭐가 나을까" + 비교 대상 2개+ | `/tech-decision` |
| "모호", "막연", "뭘 원하는지", "scope" | `/vague` 또는 `/clarify` |
| "blind spot", "사각지대", "가정 점검" | `/unknown` |
| "다른 방법", "관점 전환", "diminishing returns" | `/metamedium` |
| "10x", "더 큰 목표", "stretch" | `/moonshot` |
| "테스트 먼저", "TDD", "RED GREEN" | `/tdd` |
| "코드 리뷰", "review my code" | `/code-review` |
| "리뷰 루프", "고치고 다시" | `/review-loop` |
| "실제로 동작", "E2E", "브라우저로 테스트" | `/live-verify` |
| "커밋해" 단독 | `/auto-commit` |
| "정리하고 끝", "wrap up", "세션 마무리" | `/closing-lite` 또는 `/session-closing` |

---

## 일반 작업 원칙

### 모호함은 즉시 해소
요청에 모호한 표현이 보이면 코드 작성 전에 `/vague` 또는 자연어 번호 옵션으로 명확화. "나중에 결정"으로 넘기지 않는다.

### 검증 없이 마무리 금지
구현 후 `/code-review` 또는 `/live-verify` 로 검증. "동작할 것 같다"는 검증이 아니다.

### 세션 종료 시 메모리 누적
큰 변화 / 새로 알게 된 패턴 / 사용자 선호 발견 → `/closing-lite` 로 메모리에 한 줄 누적.

### 한국어 정서법
모든 한국어 텍스트는 정확한 정서법 준수. 영어 / 식별자는 원문 유지.

---

## 커밋 메시지 컨벤션

- 한국어
- 접두사: `추가:`, `수정:`, `삭제:`, `개선:`
- 형식: `<접두사> <한 줄 요약>` + 빈 줄 + 상세 내용
- Co-Authored-By: AI 협업 시 포함
- `git add -A` 대신 변경 파일 명시적으로 add
- `--no-verify` 금지 (명시 허락 없는 한)

---

## 위임 / 에이전트 호출

- 단순 검색은 직접 도구 호출 (Glob / Grep / Read)
- 복잡한 멀티스텝 조사 → 서브 에이전트 위임
- 내가 작성한 코드는 내가 검증하지 않음 — 별도 에이전트 / 별도 패스
- 토큰 큰 작업은 백그라운드 옵션 활용

---

## 참고

이 가이드는 plugin-mh 저장소의 [codex/AGENTS.md](https://github.com/kingkingburger/plugin-mh/blob/master/codex/AGENTS.md) 와 [codex/template/AGENTS.md](https://github.com/kingkingburger/plugin-mh/blob/master/codex/template/AGENTS.md) 의 요약본이다. 상세 사용법은 원본 문서 참조.
