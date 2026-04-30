# AGENTS.md — plugin-mh

> 이 파일은 Codex / Claude / AI 에이전트가 이 저장소에서 작업할 때 따라야 할 지침이다.
> 살아있는 피드백 루프 문서 — 에이전트가 실수할 때마다 갱신한다.
> Codex CLI는 작업 디렉토리의 AGENTS.md를 자동 로드한다. Claude Code는 여전히 [CLAUDE.md](./CLAUDE.md) 를 우선한다.

## 프로젝트 개요

plugin-mh는 MH의 커스텀 Claude Code 플러그인이다. 20개 스킬 + 1개 에이전트를 제공하며, 변환 어댑터(`codex/`) 를 통해 OpenAI Codex CLI에서도 동일한 기능을 21개 슬래시 커맨드로 사용할 수 있다.

- **한 저장소 = 두 환경 동시 지원** (Claude Code + Codex CLI)
- **정적 마크다운 + JSON 기반** — 빌드 / 번들 / 패키징 없음
- 깊은 컨텍스트는 다음 문서로 분산: [CLAUDE.md](./CLAUDE.md), [GUIDE.md](./GUIDE.md), [README.md](./README.md), [codex/README.md](./codex/README.md)

## 빌드 / 테스트 / 실행

빌드 시스템 없음. 검증은 다음 4가지로 충분:

| 검증 | 명령 / 방법 |
|------|------------|
| SKILL.md frontmatter 유효성 | `head -1 skills/*/SKILL.md` 가 모두 `---` 로 시작하는지 확인 |
| Codex 변환본 무결성 | `grep -rln -E "AskUserQuestion\|subagent_type\|Skill\(skill=" codex/prompts/` 결과가 비어있어야 함 |
| 메타데이터 동기화 | CLAUDE.md / README.md / marketplace.json / GUIDE.md 의 스킬 개수가 일치하는지 |
| 설치 동작 | `claude plugin marketplace add kingkingburger/plugin-mh` (Claude), `bash codex/install.sh` (Codex) |

## 디렉토리 구조 (변경 금지 영역)

```
.claude-plugin/      ← 플러그인 메타데이터 (Claude 전용)
  ├── plugin.json          ← 버전·이름 — 캐시 갱신 트리거
  └── marketplace.json     ← 마켓플레이스 등록
agents/              ← 에이전트 (.md, Claude 전용)
  └── code-reviewer.md
skills/<name>/       ← 스킬 (Claude 전용 원본)
  ├── SKILL.md             ← 필수 — name·description frontmatter
  ├── references/          ← 선택 — 긴 참조 문서
  └── scripts/             ← 선택 — 실행 스크립트 (.sh, .py 등)
codex/               ← Codex 어댑터 (변환본)
  ├── prompts/<name>.md    ← Codex 슬래시 커맨드 (skills/<name>/SKILL.md 변환본)
  ├── AGENTS.md            ← Codex 카탈로그 + 자연어 트리거 매핑
  ├── README.md            ← Codex 사용·설치 가이드
  ├── template/            ← 다른 프로젝트에 배포 가능한 워크플로우 템플릿
  └── install.{ps1,sh}     ← ~/.codex/prompts/ 로 심볼릭 링크
research/            ← 개인 리서치 노트 (youtube-digest 출력 등)
```

## 코드 컨벤션

### SKILL.md frontmatter
필수: `name`, `description`. 선택: `version`, `allowed-tools`, `user-invocable`.
description은 트리거 키워드를 영문/한국어 모두 명시 — Claude가 트리거 판단하는 유일한 필드이므로 정확해야 함.

### 커밋 메시지 (한국어)
- 접두사: `추가:`, `수정:`, `삭제:`, `개선:`
- 형식: `<접두사> <한 줄 요약>` + 빈 줄 + 상세 내용
- Co-Authored-By 포함 (AI 협업 시)
- `git add -A` 대신 변경 파일 명시적으로 add

### 버전 관리 (`.claude-plugin/plugin.json`)
- semver `MAJOR.MINOR.PATCH`
- 스킬 추가/삭제 → MINOR bump
- 스킬 로직 수정 → PATCH bump
- 호환성 깨짐 → MAJOR bump
- 문서만 수정 → bump 안함

### 스킬 개수 표시 동기화 (4파일)
스킬 추가/삭제 시 다음 4곳이 모두 일치해야 함:

| 파일 | 갱신 포인트 |
|------|------------|
| `CLAUDE.md` | "스킬 목록 (N개)" + 테이블 행 |
| `README.md` | 상단 문장 + TOC + 카테고리 테이블 + 상세 섹션 |
| `.claude-plugin/marketplace.json` | `description` 필드 (개수 + 스킬명 나열) |
| `GUIDE.md` | Marketplace 등록 예시의 "N custom skills" |

자동 동기화: `/skill-manage` 슬래시 커맨드 (Claude) 또는 `codex/prompts/skill-manage.md` (Codex).

## Claude / Codex 양방향 동기화 (핵심 규칙)

> **원본은 항상 `skills/<name>/SKILL.md`.** Codex 변환본 `codex/prompts/<name>.md`은 파생물.
> 양쪽이 갈라지면 Codex 사용자가 깨진다.

### 새 스킬 추가 워크플로우

1. `skills/<name>/SKILL.md` 작성 (수동 또는 `/skill-manage`)
2. 메타데이터 4파일 동기화 (CLAUDE.md, README.md, marketplace.json, GUIDE.md)
3. **`codex/prompts/<name>.md` 생성** — 변환 규칙 적용 ([codex/README.md](./codex/README.md) "변환 규칙" 표 참조)
4. **`codex/AGENTS.md` 카탈로그 항목 추가** — 명령어 + 자연어 트리거
5. `.claude-plugin/plugin.json` version bump
6. 커밋 (`추가: <name> 스킬 — <목적>`)

### 변환 규칙 요약

| 원본 (Claude) | 변환 후 (Codex) |
|--------------|----------------|
| YAML frontmatter | 제거 → 한 줄 요약을 마크다운 헤더로 |
| `AskUserQuestion` 도구 | "사용자에게 다음 질문을 자연어로 제시 + 번호 옵션" |
| `Agent(subagent_type=...)` 호출 | "이 단계에서는 {역할}처럼 사고하세요" 자연어 분해 |
| `Skill(skill="plugin-mh:vague")` | `/vague` 슬래시 커맨드 |
| `mcp__plugin_*` MCP 도구 | "Playwright MCP를 통해" 일반 표현 |
| Read/Glob/Grep/Bash/Write/Edit | 그대로 유지 (Codex도 동등 도구 보유) |

워크플로우·프로토콜·출력 형식·안티패턴·예시는 그대로 보존.

## 금지 사항

- **`.omc/` 디렉토리 수정** — oh-my-claudecode 런타임 캐시. `.gitignore` 됨.
- **`docs/plans/YYYY-MM-DD-*.md`** — frozen historical artifacts. 절대 수정 금지.
- **`--no-verify`, `--force-push`** — 검증 우회. 사용자 명시 요청 없는 한 금지.
- **`.env`, `credentials.*`** — 민감 파일 git add 금지.
- **`git add -A`** — 의도치 않은 파일 포함 위험. 명시적 add 사용.
- **변경 없는 amend** — 기존 커밋 amend보다 새 커밋 우선.

## 일반적인 함정 & 해결

| 함정 | 원인 | 해결 |
|------|------|------|
| 새 스킬이 Claude에서 안 보임 | `plugin.json` 버전 미bump | MINOR bump 후 재설치 |
| Codex에서 안 보임 | `~/.codex/prompts/` 미링크 | `codex/install.sh` 또는 `.ps1` 실행 후 Codex 재시작 |
| frontmatter YAML 파싱 오류 | indent 불일치, `---` 누락 | 다른 SKILL.md 복사하여 비교 |
| 스킬 수정했는데 Codex 동작 옛날대로 | 양방향 동기화 누락 | `codex/prompts/<name>.md` 도 갱신 |
| 마켓플레이스 캐시 갱신 안됨 | 버전 bump 누락 또는 순서 오류 | [GUIDE.md](./GUIDE.md) "캐시 갱신 순서" 절차 |
| skill-manage가 docs/plans/ 까지 수정 | frozen 문서 보호 누락 | `--include` / `--exclude` 검증 후 진행 |

## 깊은 컨텍스트 포인터

| 문서 | 용도 |
|------|------|
| [CLAUDE.md](./CLAUDE.md) | 사용자(원민호) 개인 컨벤션 + 프로젝트 구조 + 유지보수 규칙 |
| [GUIDE.md](./GUIDE.md) | 새 스킬 작성 가이드 + Marketplace 등록 + 버전 관리 + 트러블슈팅 |
| [README.md](./README.md) | 플러그인 소개 + 스킬 카탈로그 + 사용 예시 |
| [codex/README.md](./codex/README.md) | Codex 어댑터 사용·설치 가이드 + 변환 규칙 |
| [codex/AGENTS.md](./codex/AGENTS.md) | Codex 21개 슬래시 커맨드 카탈로그 + 자연어 트리거 매핑 |
| [codex/template/AGENTS.md](./codex/template/AGENTS.md) | 다른 프로젝트에 배포 가능한 워크플로우 템플릿 |

## 유지보수 가이드

이 AGENTS.md는 **피드백 루프 문서**이다. 다음 상황에서 갱신:

- 에이전트(Claude/Codex/Cursor 등)가 같은 함정에 두 번 이상 빠짐 → "일반적인 함정" 표에 추가
- 새 디렉토리/구조 컨벤션 결정 → "디렉토리 구조" 갱신
- 새 동기화 규칙 발견 → "Claude / Codex 양방향 동기화" 갱신
- 사용자가 자주 같은 지시 반복 → 영구 규칙으로 등재

갱신 시 커밋 접두사: `개선: AGENTS.md — <함정 설명>` (피드백 루프 변경은 코드 변경이 아니므로 PATCH bump 불필요).
