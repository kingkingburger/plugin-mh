# plugin-mh

MH의 커스텀 Claude Code 스킬 + 에이전트 플러그인. 23개 스킬 + 1개 에이전트.

## 프로젝트 구조

```
.claude-plugin/     ← 플러그인 메타데이터 (plugin.json, marketplace.json)
agents/             ← 에이전트 디렉토리 (각 에이전트 = .md 파일)
skills/             ← 스킬 디렉토리 (각 스킬 = 하위 폴더)
codex/              ← Codex CLI 어댑터 (변환본 슬래시 커맨드 + AGENTS.md 템플릿)
guardrails/         ← 개인 엔지니어링 하네스 규칙 (언어별 선호, TDD, 리뷰, 법칙)
scripts/            ← 정적 검증 스크립트
research/           ← 개인 리서치 노트 (youtube-digest 출력 등)
AGENTS.md           ← Codex/AI 에이전트 작업 지침 (피드백 루프 문서)
GUIDE.md            ← 새 스킬 작성 가이드
README.md           ← 플러그인 소개 및 스킬 상세 설명
```

## 에이전트 목록 (1개)

| 에이전트 | 용도 |
|---------|------|
| code-reviewer | Severity 기반 코드 리뷰 (CRITICAL/HIGH/MEDIUM/LOW), 로직 결함·보안·SOLID·성능 검사 |

## 스킬 목록 (23개)

| 스킬 | 용도 |
|------|------|
| clarify | 명확화 라우터 — vague/unknown/metamedium 중 적절한 스킬로 위임 |
| skill-manage | 스킬 추가/삭제/이름변경 + 메타데이터 4파일 + 교차참조 원자적 동기화 |
| vague | 모호한 요구사항을 스펙으로 |
| unknown | 전략 사각지대 분석 (Known/Unknown 4분면) |
| metamedium | Content vs Form 관점 전환 |
| moonshot | 목표 상향 프레임워크 |
| tech-decision | 기술 의사결정 심층 분석 |
| agent-arena | 다관점 에이전트 토론 |
| expert-review | 전문가 페르소나 병렬 리뷰 |
| auto-commit | 작업 후 자동 커밋 & 푸시 |
| live-verify | E2E 라이브 검증 |
| session-closing | 세션 마무리 분석 |
| closing-lite | 세션 마무리 경량 버전 (이슈·배운 점·선호도만 메모리에 누적) |
| daily-report | 로그·git·노트 등 여러 증거 소스를 읽어 감사 가능한 일일 작업 보고서 작성 |
| youtube-digest | 유튜브 요약 & 퀴즈 |
| youtube-slides | 유튜브 자막별 프레임 캡쳐 |
| ouroboros | 3단계 심층 문서 생산 (요구사항→설계→검증) |
| tdd | 테스트 주도 개발 (RED-GREEN-REFACTOR 강제) |
| harness | 하네스 엔지니어링 — 프로젝트 문서 체계 한번에 구축 (인터뷰→분석→병렬 생성) |
| review-loop | Tiered 리뷰 루프 (code-reviewer 단독 → 필요 시 architect+critic 병렬, 부분 재리뷰) |
| ai-slop-cleaner | AI 슬롭 코드 정리 — 회귀 안전, 삭제 우선, 한 종류씩 정리. `--review` 모드 지원 |
| ouroboros-run | ouroboros 계획을 Generator-Evaluator 루프로 실행 (부분 Ship 옵션 지원) |
| life-plan | 6계층 인생 계획 코칭 — 평생 가치→1년 방향→3개월 챕터→월→주→일 + 인터뷰·자질 검사·70-20-10·회고. 산출물 응축 (`방향.md` 메인 + `YYYY-MM/M월 N주차.md`) |

## 유지보수 규칙

### 스킬 추가/삭제 시
- `marketplace.json`의 스킬 수 설명을 실제 수와 동기화할 것
- `codex/prompts/<name>.md` 변환본도 함께 추가/삭제 (Codex 사용자가 깨짐)
- GUIDE.md의 구조 패턴을 따를 것
- 완료 전 `.\scripts\validate-plugin.ps1` 또는 `bash scripts/validate-plugin.sh` 실행

### 하네스 / 가드레일 수정 시
- 공통 원칙은 `guardrails/core.md`, 법칙 기반 판단은 `guardrails/laws.md`에 둔다
- TypeScript / Rust / Python 선호는 `guardrails/languages/`에 둔다
- TDD와 리뷰 절차는 `guardrails/workflows/`에 둔다

### .omc/ 디렉토리
- oh-my-claudecode 플러그인의 런타임 상태 — 프로젝트에서 관리하지 않음
- `.gitignore`에 이미 포함, git 추적 안 됨
- 캐시 정리 시 `project-memory.json`은 유지

### 커밋 메시지 컨벤션
- 한국어 사용
- 접두사: `추가:`, `수정:`, `삭제:`, `개선:`
