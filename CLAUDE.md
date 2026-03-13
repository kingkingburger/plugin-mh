# plugin-mh

MH의 커스텀 Claude Code 스킬 플러그인. 15개 생산성 스킬 모음.

## 프로젝트 구조

```
.claude-plugin/     ← 플러그인 메타데이터 (plugin.json, marketplace.json)
skills/             ← 스킬 디렉토리 (각 스킬 = 하위 폴더)
research/           ← 개인 리서치 노트 (youtube-digest 출력 등)
GUIDE.md            ← 새 스킬 작성 가이드
```

## 스킬 목록 (15개)

| 스킬 | 용도 |
|------|------|
| agent-council | 다중 AI 에이전트 의견 수집 |
| auto-commit | 작업 후 자동 커밋 & 푸시 |
| dev-scan | 개발 커뮤니티 기술 의견 수집 |
| google-calendar | Google 캘린더 일정 관리 |
| history-insight | 세션 히스토리 접근/캡처 |
| linkedin-insight | LinkedIn 브라우저 자동화 분석 |
| metamedium | 콘텐츠 vs 형식 리프레이밍 |
| moonshot | 목표 상향 프레임워크 |
| review | 마크다운 리뷰 웹 UI |
| session-analyzer | 세션 로그 사후 분석 |
| session-closing | 세션 종료 멀티에이전트 워크플로우 |
| tech-decision | 기술 의사결정 멀티소스 분석 |
| unknown | Known/Unknown 4분면 전략 분석 |
| vague | 모호한 요구사항 명확화 |
| youtube-digest | YouTube 영상 요약/퀴즈 |

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
