# plugin-mh 스킬 작성 가이드

이 가이드는 Claude Code 전용 스킬만 만드는 문서가 아니라, **Claude Code와 OpenAI Codex 양쪽에서 같은 작업 흐름을 재사용할 수 있는 범용 스킬 자산**을 작성하기 위한 기준이다. 원본은 `skills/<name>/SKILL.md`에 두되, 워크플로우·프로토콜·출력 형식·안티패턴은 Codex 프롬프트로도 자연스럽게 변환될 수 있게 쓴다.

핵심 목표는 특정 에이전트 런타임에 갇힌 명령을 늘리는 것이 아니라, Claude에서는 플러그인 스킬로, Codex에서는 슬래시 커맨드와 AGENTS.md 라우팅으로 작동하는 **동일한 하네스 언어**를 유지하는 것이다. 따라서 새 스킬을 만들 때는 Claude frontmatter와 도구 제약을 정확히 쓰면서도, 본문은 Codex가 그대로 읽어도 실행 가능한 자연어 절차로 작성한다.

## 새 스킬 만드는 법

### 1. 디렉토리 생성
```
skills/
└── my-new-skill/
    └── SKILL.md
```

### 2. SKILL.md 작성

```yaml
---
name: my-new-skill
description: 트리거 조건 설명. Trigger on "/my-skill", "관련 키워드".
version: 1.0.0
allowed-tools: [Read, Grep, Glob, Bash, WebSearch]  # 선택사항
---

# 스킬 이름

## When to Use
- 트리거 문구 나열

## Workflow
- 단계별 설명

## Output Format
- 출력 형식 정의
```

### 3. 선택적 추가 구조

```
skills/my-new-skill/
├── SKILL.md              ← 필수
├── scripts/              ← 스크립트가 필요한 경우
│   ├── run.sh
│   └── process.py
├── references/           ← 참조 문서
│   └── guide.md
└── assets/               ← 설정 파일, 템플릿
    └── config.yaml
```

## SKILL.md 핵심 포인트

### description 필드가 가장 중요
- Claude Code가 이 필드를 보고 스킬 사용 여부를 결정하고, Codex 쪽 카탈로그/프롬프트도 같은 트리거 의미를 따라간다
- 트리거 조건을 명확히 포함해야 함
- 영어/한국어 트리거 모두 나열 가능

### allowed-tools (선택사항)
- 지정하면 해당 도구만 사용 가능
- 미지정 시 모든 도구 사용 가능
- 외부 도구(Playwright, MCP 등)를 사용하는 스킬은 반드시 명시할 것

### user-invocable (선택사항)
- `true`/`false` — 사용자가 직접 호출 가능한지 여부
- 미지정 시 기본값은 `true` (대부분의 스킬은 직접 호출 가능)
- 다른 스킬에서만 내부적으로 호출되는 스킬은 `false`로 설정

### Workflow 섹션
- Claude Code와 Codex가 모두 따라갈 수 있도록 단계를 명확히 기술
- Claude 전용 도구 호출이 필요하더라도, Codex 변환본에서 자연어 절차로 바꿀 수 있게 의도와 입력/출력 조건을 함께 쓴다
- 멀티 에이전트가 필요하면 Agent 도구 사용 명시

## Claude / Codex 호환 작성 원칙

| 원칙 | 작성 방식 |
|------|-----------|
| 원본은 하나 | `skills/<name>/SKILL.md`를 원본으로 두고 `codex/prompts/<name>.md`는 동기화된 변환본으로 유지 |
| 본문은 범용 자연어 | 특정 런타임 도구 이름만 나열하지 말고 목적, 입력, 출력, 검증 기준을 함께 설명 |
| 트리거는 공유 | Claude description, README 카탈로그, Codex AGENTS 라우팅에서 같은 자연어 트리거를 사용 |
| 도구 차이는 변환 | `AskUserQuestion`, `Agent`, `Skill(...)` 같은 Claude 전용 표현은 Codex 프롬프트에서 번호 옵션, 역할 사고, 슬래시 커맨드로 변환 |
| 검증은 양쪽 기준 | 새 스킬 추가 후 Claude plugin 설치/cache 표면과 Codex prompts+skills 설치 표면이 source와 맞는지 `validate-plugin --installed`로 확인 |

## 플러그인 타입별 추가 파일

### Hook 기반 (이벤트 반응형)
```
hooks/
├── hooks.json            ← 이벤트 + 커맨드 매핑
└── scripts/
    └── handler.sh
```

hooks.json 예시:
```json
{
  "hooks": {
    "UserPromptSubmit": [{
      "matcher": "*",
      "hooks": [{ "type": "command", "command": "bash script.sh" }]
    }]
  }
}
```

### MCP 기반 (커스텀 도구)
```
.mcp.json                 ← MCP 서버 설정
mcp-server/
└── server.py
```

## Marketplace 등록

플러그인을 마켓플레이스에 배포하려면 `.claude-plugin/marketplace.json`을 작성합니다.

```json
{
  "name": "plugin-mh",
  "owner": {
    "name": "MH",
    "url": "https://github.com/kingkingburger"
  },
  "description": "Multi-runtime Claude Code and Codex skills for thinking, deciding, and building smarter by MH",
  "plugins": [
    {
      "name": "plugin-mh",
      "description": "25 custom skills + 2 agents: clarify, skill-manage, deep-goal-council, tech-decision, agent-arena, expert-review, daily-report, live-verify, auto-commit, ouroboros, ouroboros-run, tdd, harness, find-pulp, review-loop, ai-slop-cleaner, closing-lite, youtube-slides, life-plan, code-reviewer + knowledge-curator agents, and more",
      "source": "./"
    }
  ]
}
```

### 필드 설명

| Field | Description |
|-------|-------------|
| `name` | 마켓플레이스 패키지 이름 (`plugin.json`의 `name`과 일치해야 함) |
| `owner.name` | 플러그인 작성자 이름 |
| `owner.url` | GitHub 프로필 URL |
| `description` | 마켓플레이스 리스팅 설명 |
| `plugins[].name` | 플러그인 이름 |
| `plugins[].description` | 플러그인 상세 설명 |
| `plugins[].source` | 플러그인 디렉토리 (레포 루트면 `"./"`) |

### 사용자 설치 명령

```bash
claude plugin marketplace add <owner>/<repo-name>
claude plugin install <plugin-name>
```

> **참고**: `version` 필드는 `plugin.json`에서만 관리합니다. marketplace.json에는 불필요합니다.

## 버전 관리 규칙

| 변경 유형 | Version Bump | 예시 |
|-----------|:---:|------|
| 스킬 코드 변경 (SKILL.md, agents/, scripts/) | O | 로직 수정, 새 에이전트 추가 |
| 새 스킬 추가 | O | `skills/new-skill/` 생성 |
| 스킬 삭제 | O | `skills/old-skill/` 제거 |
| README/GUIDE 문서만 수정 | X | 오타 수정, 설명 보강 |
| marketplace.json 메타데이터만 수정 | X | description 변경 |

- Semver 규칙: `MAJOR.MINOR.PATCH`
  - PATCH: 기존 스킬 버그 수정
  - MINOR: 새 스킬 추가 또는 기존 스킬 기능 확장
  - MAJOR: 호환성 깨지는 변경
- 이유: 사용자 캐시가 plugin.json version 변경 시 갱신됨

## 트러블슈팅

### 스킬이 Claude에서 안 보일 때
1. `plugin.json` 버전이 bump 되었는지 확인
2. SKILL.md frontmatter (`---`)가 유효한 YAML인지 확인
3. `claude plugin list`로 플러그인 설치 확인

### 마켓플레이스 캐시 갱신 순서
새 스킬 추가 후 캐시가 갱신되지 않을 때는 아래 순서를 따른다:
1. `marketplace.json` description 업데이트 (스킬 수 반영)
2. `plugin.json` version bump (이 변경이 캐시 갱신을 트리거함)
3. git commit & push
4. `claude plugin marketplace add <owner>/<repo>` 재실행

### SKILL.md 문법 오류
- frontmatter는 반드시 `---`로 시작하고 끝나야 함
- `name`, `description` 필드는 필수
- `allowed-tools`는 배열 형식: `[Read, Grep, Glob]`
