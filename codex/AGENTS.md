# plugin-mh — Codex Skills Catalog

이 디렉토리는 [plugin-mh](../) 의 Claude Code 스킬을 OpenAI Codex CLI에서도 쓸 수 있도록 변환한 슬래시 커맨드 프롬프트 모음이다. 원본 `skills/` 와 `agents/` 는 그대로 유지되며 Claude Code 플러그인은 영향을 받지 않는다.

## 동작 방식

- `codex/prompts/<name>.md` 는 Codex CLI에 의해 `/<name>` 슬래시 커맨드로 등록된다.
- `$ARGUMENTS` 위치에 사용자 입력이 주입된다.
- 자연어로도 호출 가능 — Codex가 본 AGENTS.md의 트리거 키워드 매핑을 보고 적절한 프롬프트를 추천/실행한다.

## 카탈로그 (21개 명령어 = 20 스킬 + 1 에이전트)

### Clarification (생각 정리)

| 명령어 | 용도 | 자연어 트리거 |
|--------|------|--------------|
| `/clarify` | 명확화 라우터 — vague/unknown/metamedium 중 분기 | "/clarify", "명확히", "어떤 clarify가 필요할지 모르겠어" |
| `/vague` | 모호한 요구사항 → 구체적 스펙 | "요구사항 정리", "뭘 원하는 건지", "spec this out", "scope this" |
| `/unknown` | 전략 사각지대 (Known/Unknown 4분면) | "blind spots", "4분면 분석", "가정 점검", "전략 점검", "what am I missing" |
| `/metamedium` | Content vs Form 관점 전환 (Alan Kay) | "내용 vs 형식", "관점 전환", "형식을 바꿔볼까", "다른 방법 없을까" |
| `/moonshot` | 목표 상향 프레임워크 (10x, BHAG, Backcasting 등) | "목표 상향", "더 높은 목표", "stretch goal", "10x", "야심찬 목표" |

### Decision & Review (의사결정·리뷰)

| 명령어 | 용도 | 자연어 트리거 |
|--------|------|--------------|
| `/tech-decision` | 기술 의사결정 심층 분석 (A vs B, 라이브러리 선택) | "기술 의사결정", "뭐 쓸지 고민", "A vs B", "트레이드오프" |
| `/agent-arena` | 다관점 페르소나 토론 (3/5/8인) | "에이전트 토론", "여러 관점에서 분석", "찬반 토론", "agent debate" |
| `/expert-review` | 전문가 페르소나 N명 병렬 리뷰 | "expert-review", "전문가 리뷰", "다관점 리뷰", "리뷰어 추천" |
| `/review-loop` | code-reviewer → architect → critic 체이닝 리뷰 | "review-loop", "리뷰 루프", "리뷰하고 고쳐", "review and fix" |
| `/code-review` | Severity 기반 단독 코드 리뷰 (CRITICAL/HIGH/MEDIUM/LOW) | "코드 리뷰", "code review", "리뷰해줘" |

### Development (개발 워크플로우)

| 명령어 | 용도 | 자연어 트리거 |
|--------|------|--------------|
| `/tdd` | RED-GREEN-REFACTOR 강제 | "tdd", "테스트 주도", "테스트 먼저", "test first" |
| `/harness` | 프로젝트 문서 체계 한번에 구축 (AGENTS.md 등) | "harness", "하네스", "문서 체계", "엔지니어링 문서" |
| `/auto-commit` | 작업 후 자동 git commit & push | "자동 커밋", "auto commit", "실행하고 커밋" |
| `/live-verify` | E2E 라이브 검증 (Playwright/Bash/curl) | "라이브 검증", "E2E 검증", "실제 검증", "검증 시나리오" |

### Spec / Run (스펙·실행)

| 명령어 | 용도 | 자연어 트리거 |
|--------|------|--------------|
| `/ouroboros` | 3단계 심층 문서 (요구사항 → 설계 → 검증) | "우로보로스", "심층 문서", "deep spec", "품질 게이트 문서" |
| `/ouroboros-run` | ouroboros 문서를 Generator-Evaluator 루프로 실행 | "ouroboros 실행", "계획 실행", "run the plan" |

### Session & History

| 명령어 | 용도 | 자연어 트리거 |
|--------|------|--------------|
| `/session-closing` | 세션 마무리 (5 분석 + 통합 + 액션) | "close session", "session closing", "/closing", "wrap up" |
| `/closing-lite` | 세션 마무리 경량 (메모리 누적만) | "/closing-lite", "lite closing", "간단 마무리", "기억만 남겨" |

### Utility

| 명령어 | 용도 | 자연어 트리거 |
|--------|------|--------------|
| `/skill-manage` | plugin-mh 스킬 추가/삭제/이름변경 + 메타데이터 동기화 | "스킬 관리", "스킬 추가", "스킬 삭제", "스킬 이름 변경" |
| `/youtube-digest` | YouTube 영상 → 요약/번역/퀴즈 | "유튜브 정리", "영상 요약", "YouTube digest" |
| `/youtube-slides` | YouTube 영상 → 자막별 프레임 캡쳐 | "유튜브 슬라이드", "영상 캡쳐", "스크린샷 추출" |

## 라우팅 가이드 (Codex 자연어 매칭 시)

사용자 자연어 입력에 트리거 키워드가 포함되면 해당 명령어를 우선 실행한다.

- 명확화 라우터(`/clarify`) 와 specialist (`/vague`, `/unknown`, `/metamedium`) 사이에서 모드-specific 키워드가 있으면 specialist 직접 호출.
- 리뷰 관련: 단독 빠른 리뷰는 `/code-review`, 체이닝 리뷰는 `/review-loop`, 다관점 페르소나 리뷰는 `/expert-review`.
- 의사결정: 기술 선택은 `/tech-decision`, 다관점 토론은 `/agent-arena`.
- 문서 생산 깊이: 요구사항만 → `/vague`, 요구사항+설계+검증 메트릭 기반 → `/ouroboros`, 프로젝트 문서 체계 → `/harness`.
- 실행: 계획만 → `/ouroboros`, 계획 + 구현까지 → `/ouroboros-run`.
- 세션 종료: 풀 버전 → `/session-closing`, 경량 → `/closing-lite`.

## Claude Code 플러그인과의 관계

- 본 `codex/` 디렉토리는 Codex 사용자를 위한 **별도 채널**이다.
- Claude Code 플러그인 자산(`skills/`, `agents/`, `.claude-plugin/`) 은 일체 변경되지 않았으므로 plugin-mh의 Claude Code 동작은 그대로다.
- 한 저장소 = 두 환경 지원. 스킬 로직 업데이트 시 원본(`skills/<name>/SKILL.md`) 을 수정하고 codex 변환본(`codex/prompts/<name>.md`) 을 동기화하면 된다.

## 설치

자세한 설치 방법은 [README.md](./README.md) 를 참조.
