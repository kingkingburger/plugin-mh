# plugin-mh — Codex Adapter

plugin-mh의 20개 스킬 + 1개 에이전트를 OpenAI Codex CLI 슬래시 커맨드로 변환해둔 어댑터.

## 호환성

| 환경 | 진입점 | 영향 |
|------|--------|------|
| Claude Code | `skills/`, `agents/`, `.claude-plugin/` | **변경 없음** — 기존처럼 동작 |
| Codex CLI | `codex/prompts/` 를 `~/.codex/prompts/` 에 링크 | 슬래시 커맨드 21개 추가 |

한 저장소가 두 환경을 동시에 지원한다.

## 빠른 시작

### 1. 설치

#### Windows (PowerShell)

```powershell
.\codex\install.ps1
```

#### macOS / Linux

```bash
bash codex/install.sh
```

기본 동작은 **심볼릭 링크** 생성. 저장소를 업데이트하면 Codex 측 프롬프트도 자동 반영된다.

복사 모드를 원하면 `--copy` 옵션:

```powershell
.\codex\install.ps1 -Copy
```
```bash
bash codex/install.sh --copy
```

### 2. Codex CLI 재시작 후 확인

Codex CLI에서 `/` 입력 시 21개의 plugin-mh 명령어가 보여야 한다.

```
/vague
/unknown
/metamedium
/clarify
/moonshot
/tech-decision
/agent-arena
/expert-review
/review-loop
/code-review
/tdd
/harness
/auto-commit
/live-verify
/ouroboros
/ouroboros-run
/session-closing
/closing-lite
/skill-manage
/youtube-digest
/youtube-slides
```

### 3. 사용 예시

```
/vague 사용자 인증 기능 추가하고 싶어
/tech-decision React Query vs SWR
/tdd 빈 이메일을 거부하는 로직 추가
/ouroboros 멀티테넌트 결제 시스템
/code-review
```

자연어로도 호출 가능하다 — Codex가 [AGENTS.md](./AGENTS.md) 의 트리거 키워드 매핑을 보고 적절한 명령어를 선택한다.

## 디렉토리 구조

```
codex/
├── AGENTS.md                ← 21개 명령어 카탈로그 + 자연어 트리거 매핑
├── README.md                ← 본 파일
├── install.ps1              ← Windows 설치 스크립트
├── install.sh               ← macOS/Linux 설치 스크립트
├── user-global-AGENTS.md    ← 개인 글로벌 가이드 (~/.codex/AGENTS.md 용)
├── template/
│   └── AGENTS.md            ← 다른 프로젝트에 배포 가능한 워크플로우 템플릿
└── prompts/                 ← 21개 슬래시 커맨드 프롬프트
    ├── agent-arena.md
    ├── auto-commit.md
    ├── clarify.md
    ├── closing-lite.md
    ├── code-review.md
    ├── expert-review.md
    ├── harness.md
    ├── live-verify.md
    ├── metamedium.md
    ├── moonshot.md
    ├── ouroboros.md
    ├── ouroboros-run.md
    ├── review-loop.md
    ├── session-closing.md
    ├── skill-manage.md
    ├── tdd.md
    ├── tech-decision.md
    ├── unknown.md
    ├── vague.md
    ├── youtube-digest.md
    └── youtube-slides.md
```

## 하네스 (AGENTS.md) 활용

plugin-mh는 세 계층의 AGENTS.md를 제공한다 — Codex가 자연어 요청을 해석하고 적절한 슬래시 커맨드로 라우팅하도록 돕는다.

| 파일 | 위치 | 용도 |
|------|------|------|
| **저장소 루트** | [`../AGENTS.md`](../AGENTS.md) | plugin-mh 자체를 Codex로 개발할 때의 컨벤션·동기화 규칙·금지 사항 |
| **카탈로그** | [`./AGENTS.md`](./AGENTS.md) | 21개 슬래시 커맨드 카탈로그 + 자연어 트리거 매핑 |
| **배포 템플릿** | [`./template/AGENTS.md`](./template/AGENTS.md) | 다른 프로젝트에 가져갈 워크플로우 템플릿 (Spec→Build→Verify→Ship 패턴) |
| **개인 글로벌** | [`./user-global-AGENTS.md`](./user-global-AGENTS.md) | `~/.codex/AGENTS.md` 로 복사하면 모든 프로젝트에서 자동 활성 |

### 적용 방법

```bash
# 1. 저장소 루트 AGENTS.md — Codex가 plugin-mh 작업 디렉토리에서 자동 로드 (별도 작업 불필요)

# 2. 다른 프로젝트에 워크플로우 적용
cp codex/template/AGENTS.md ~/my-project/AGENTS.md
# 또는 자기 AGENTS.md에 흡수

# 3. 개인 글로벌 가이드 (모든 프로젝트에서 활성화)
cp codex/user-global-AGENTS.md ~/.codex/AGENTS.md     # macOS / Linux
Copy-Item codex/user-global-AGENTS.md $env:USERPROFILE\.codex\AGENTS.md   # Windows PowerShell
```

## 변환 규칙 (원본 SKILL.md → Codex 프롬프트)

| 원본 (Claude) | 변환 후 (Codex) |
|--------------|----------------|
| YAML frontmatter (`name`, `description`, `version` 등) | 제거하고 헤더 형식 한 줄 요약으로 |
| `AskUserQuestion` 도구 | "사용자에게 다음 질문을 제시하고 번호로 답하게 하세요" + 번호 옵션 |
| `Agent(subagent_type=...)` | "이 단계에서는 {역할}처럼 사고하세요" + 자연어 작업 분해 |
| `Skill(skill="plugin-mh:vague")` | `/vague` 슬래시 커맨드 |
| `mcp__plugin_playwright_*` | "Playwright MCP를 통해" 일반 표현 |
| Read/Glob/Grep/Bash/Write/Edit | 그대로 유지 (Codex도 동등 도구 보유) |

워크플로우 / 프로토콜 / 출력 형식 / 안티패턴 / 예시는 그대로 보존된다.

## references/ 파일

일부 프롬프트는 `references/...` 파일을 언급한다. 이 파일들은 plugin-mh 저장소의 `skills/<skill-name>/references/` 에 위치한다. Codex가 필요할 때 직접 Read 하면 된다.

## 제거 (Uninstall)

```powershell
# Windows
Get-ChildItem $env:USERPROFILE\.codex\prompts\ | Where-Object { $_.Name -in (Get-ChildItem .\codex\prompts\ -Filter *.md | Select-Object -ExpandProperty Name) } | Remove-Item
```

```bash
# macOS / Linux
for f in codex/prompts/*.md; do
  rm -f "$HOME/.codex/prompts/$(basename "$f")"
done
```

## 동기화 (원본 변경 시)

`skills/<name>/SKILL.md` 를 수정한 뒤 `codex/prompts/<name>.md` 도 같은 변환 규칙으로 갱신하면 된다. 원본과 변환본이 갈라지지 않도록 주의.

## 라이선스

원본 plugin-mh와 동일 (MIT).
