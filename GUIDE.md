# plugin-mh 스킬 작성 가이드

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
- Claude가 이 필드를 보고 스킬 사용 여부를 결정
- 트리거 조건을 명확히 포함해야 함
- 영어/한국어 트리거 모두 나열 가능

### allowed-tools (선택사항)
- 지정하면 해당 도구만 사용 가능
- 미지정 시 모든 도구 사용 가능

### Workflow 섹션
- Claude가 따라야 할 단계를 명확히 기술
- 멀티 에이전트가 필요하면 Agent 도구 사용 명시

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
  "description": "Claude Code plugins for thinking, deciding, and building smarter by MH",
  "plugins": [
    {
      "name": "plugin-mh",
      "description": "19 custom skills: clarify, tech-decision, agent-arena, live-verify, and more",
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
