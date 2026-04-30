# /vague — Vague: Requirement Clarification

모호하거나 불분명한 요구사항을 가설 기반 질문을 통해 구체적이고 실행 가능한 스펙으로 변환한다. 요구사항 명확히, 뭘 원하는 건지, spec this out, scope this 등의 표현에서 트리거된다.

> Codex CLI 슬래시 커맨드로 호출되거나 자연어로 트리거된다. `$ARGUMENTS`에 사용자 입력이 주입된다.

## 사용 시나리오

- Ambiguous feature requests ("add a login feature")
- Incomplete bug reports ("the export is broken")
- Underspecified tasks ("make the app faster")

For strategy/planning blind spot analysis, use `/unknown`. For content-vs-form reframing, use `/metamedium`.

## Core Principle: Hypotheses as Options

Present plausible interpretations as options instead of asking open questions. Each option is a testable hypothesis about what the user actually means.

```
BAD:  "What kind of login do you want?"           ← open question, high cognitive load
GOOD: "OAuth / Email+Password / SSO / Magic link" ← pick one, lower load
```

## Protocol

### Phase 1: Capture and Diagnose

Record the original requirement verbatim. Identify ambiguities:
- What is unclear or underspecified?
- What assumptions would need to be made?
- What decisions are left to interpretation?

### Phase 2: Iterative Clarification

사용자에게 다음과 같은 구조로 질문을 제시하고 번호 또는 라벨로 답하게 하세요. **관련 질문은 최대 4개씩 묶어서 한 번에 제시.** 각 옵션은 사용자가 의미하는 바에 대한 가설이다.

**총 5-8개 질문 상한.** 핵심 모호함이 모두 해소되거나, 사용자가 "충분해"라고 하거나, 상한에 도달하면 중지.

**질문 예시:**

**어떤 인증 방식을 사용해야 하나요?** (Auth method)
1. **Email + Password** — Traditional signup with email verification
2. **OAuth (Google/GitHub)** — Delegated auth, no password management needed
3. **Magic link** — Passwordless email-based login

**가입 후 어떻게 되어야 하나요?** (Post-signup)
1. **Immediate access** — User can use the app right away
2. **Email verification first** — Must confirm email before access

### Phase 3: Before/After Summary

Present the transformation:

```markdown
## Requirement Clarification Summary

### Before (Original)
"{original request verbatim}"

### After (Clarified)
**Goal**: [precise description]
**Scope**: [included and excluded]
**Constraints**: [limitations, preferences]
**Success Criteria**: [how to know when done]

**Decisions Made**:
| Question | Decision |
|----------|----------|
| [ambiguity 1] | [chosen option] |
```

### Phase 4: Save Option

Ask whether to save the clarified requirement to a file. Default location: `requirements/` or project-appropriate directory.

## Ambiguity Categories

| Category | Example Hypotheses |
|----------|-------------------|
| **Scope** | All users / Admins only / Specific roles |
| **Behavior** | Fail silently / Show error / Auto-retry |
| **Interface** | REST API / GraphQL / CLI |
| **Data** | JSON / CSV / Both |
| **Constraints** | <100ms / <1s / No requirement |
| **Priority** | Must-have / Nice-to-have / Future |

## Rules

1. **Hypotheses, not open questions**: Every option is a plausible interpretation
2. **No assumptions**: Ask, don't assume
3. **Preserve intent**: Refine, don't redirect
4. **5-8 questions max**: Beyond this is fatigue
5. **Batch related questions**: Up to 4 per round
6. **Track changes**: Always show before/after
