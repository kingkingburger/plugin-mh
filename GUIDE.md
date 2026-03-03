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
