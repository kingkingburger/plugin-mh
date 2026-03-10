# plugin-mh

Claude Code plugin with 19 custom skills for thinking, deciding, and building smarter.

## Install

```bash
claude plugin add kingkingburger/plugin-mh
```

## Skills

### Thinking & Strategy

| Skill | Trigger | Description |
|-------|---------|-------------|
| **clarify** | `/clarify`, `명확히` | 3-in-1 clarification — requirements, blind spots, content vs form |
| **vague** | `요구사항 정리`, `spec this out` | Turn ambiguous requirements into actionable specs |
| **unknown** | `blind spots`, `4분면 분석` | Surface hidden assumptions with Known/Unknown quadrant analysis |
| **metamedium** | `content vs form`, `관점 전환` | Reframe problems by distinguishing what from how |
| **moonshot** | `moonshot`, `10x`, `더 높은 목표` | Push goals higher with proven goal-setting frameworks |

### Decision & Research

| Skill | Trigger | Description |
|-------|---------|-------------|
| **tech-decision** | `A vs B`, `기술 선택` | Systematic multi-source analysis for technical decisions |
| **agent-arena** | `에이전트 토론`, `debate this` | Multiple AI agents debate a topic across rounds, then synthesize |
| **agent-council** | `summon the council` | Collect and synthesize opinions from multiple AI agents |
| **dev-scan** | `개발자 반응`, `developer reactions` | Scan Reddit, HN, Dev.to for community opinions on tech topics |

### Productivity

| Skill | Trigger | Description |
|-------|---------|-------------|
| **auto-commit** | `자동 커밋`, `auto commit` | Execute instructions, then auto commit & push |
| **ralph-prep** | `PRD 작성`, `ralph-prep` | Deep interview to turn ideas into crystal-clear PRDs |
| **review** | `검토해줘`, `review this` | Interactive markdown review with web UI |
| **live-verify** | `라이브 검증`, `live-verify` | 2-Phase E2E verification — Plan scenarios, then Execute with Playwright/Bash/curl |
| **google-calendar** | `오늘 일정`, `미팅 추가해줘` | Google Calendar CRUD with multi-account support |

### Session & History

| Skill | Trigger | Description |
|-------|---------|-------------|
| **session-closing** | `/closing`, `/wrap` | Multi-agent session wrap-up with learning extraction |
| **session-analyzer** | `세션 분석`, `analyze session` | Post-hoc validation of skill/agent/hook behavior |
| **history-insight** | `capture session` | Access and reference Claude Code session history |

### Content & Social

| Skill | Trigger | Description |
|-------|---------|-------------|
| **youtube-digest** | `유튜브 정리`, `영상 요약` | Transcript extraction, summary, translation, and quiz generation |
| **linkedin-insight** | `linkedin 분석` | LinkedIn post analytics and trend analysis via browser automation |

## Writing Your Own Skill

```
skills/my-skill/
├── SKILL.md              # Required — defines triggers and workflow
├── references/           # Optional — supporting docs
└── agents/               # Optional — sub-agent definitions
```

See [GUIDE.md](GUIDE.md) for the full authoring guide.

## License

MIT
