# plugin-mh

MH의 커스텀 Claude Code 스킬 + 에이전트 플러그인. 18개 스킬 + 1개 에이전트.

## 프로젝트 구조

```
.claude-plugin/     ← 플러그인 메타데이터 (plugin.json, marketplace.json)
agents/             ← 에이전트 디렉토리 (각 에이전트 = .md 파일)
skills/             ← 스킬 디렉토리 (각 스킬 = 하위 폴더)
research/           ← 개인 리서치 노트 (youtube-digest 출력 등)
GUIDE.md            ← 새 스킬 작성 가이드
README.md           ← 플러그인 소개 및 스킬 상세 설명
```

## 에이전트 목록 (1개)

| 에이전트 | 용도 |
|---------|------|
| code-reviewer | Severity 기반 코드 리뷰 (CRITICAL/HIGH/MEDIUM/LOW), 로직 결함·보안·SOLID·성능 검사 |

## 스킬 목록 (18개)

| 스킬 | 용도 |
|------|------|
| clarify | 3-in-1 요구사항 명확화 (vague + unknown + metamedium 통합) |
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
| youtube-digest | 유튜브 요약 & 퀴즈 |
| youtube-slides | 유튜브 자막별 프레임 캡쳐 |
| ouroboros | 3단계 심층 문서 생산 (요구사항→설계→검증) |
| tdd | 테스트 주도 개발 (RED-GREEN-REFACTOR 강제) |
| harness | 하네스 엔지니어링 — 프로젝트 문서 체계 한번에 구축 (인터뷰→분석→병렬 생성) |
| review-loop | 코드 작성 후 자동 리뷰 루프 (code-reviewer → 수정 → 재리뷰 반복) |
| ouroboros-run | ouroboros 계획을 Generator-Evaluator 루프로 실행 (부분 Ship 옵션 지원) |

## 유지보수 규칙

### 스킬 추가/삭제 시
- `marketplace.json`의 스킬 수 설명을 실제 수와 동기화할 것
- GUIDE.md의 구조 패턴을 따를 것

### .omc/ 디렉토리
- oh-my-claudecode 플러그인의 런타임 상태 — 프로젝트에서 관리하지 않음
- `.gitignore`에 이미 포함, git 추적 안 됨
- 캐시 정리 시 `project-memory.json`은 유지

### 커밋 메시지 컨벤션
- 한국어 사용
- 접두사: `추가:`, `수정:`, `삭제:`, `개선:`
