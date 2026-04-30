# /metamedium — Metamedium: Content vs Form Lens

빌드·계획·전략 시 핵심 질문이 "내용(what)을 최적화"할지 "형식(how/medium)을 바꿀지"일 때 사용한다. Alan Kay의 메타미디엄 개념을 적용해 형식 수준의 대안을 발굴한다. 내용 vs 형식, content vs form, 형식을 바꿔볼까, 관점 전환, diminishing returns 등에서 트리거된다.

> Codex CLI 슬래시 커맨드로 호출되거나 자연어로 트리거된다. `$ARGUMENTS`에 사용자 입력이 주입된다.

## Core Concept

Most people only change **content** — what they say, write, or build. The real leverage comes from changing **form** — the medium, format, or structure itself.

> "A change of perspective is worth 80 IQ points." — Alan Kay

| | Content (what) | Form (how/medium) |
|--|----------------|-------------------|
| Example | Writing a LinkedIn post | Building a tool that generates posts from client work |
| Example | Writing unit tests manually | Building a test generator from type signatures |
| Example | Giving a workshop | Inventing a format where attendees co-create artifacts |
| Leverage | Linear — each piece is one output | Exponential — each new form enables infinite content |

## 사용 시나리오

- Planning a project and unsure whether to optimize the output or the process
- Stuck optimizing content with diminishing returns
- Building something and want to check if form-level change would yield more leverage
- Evaluating whether "more of the same" or "something structurally different" is the right move

For requirement clarification, use `/vague`. For strategy blind spot analysis, use `/unknown`.

## Protocol

Phase 2의 선택 질문은 반드시 번호+라벨 형태로 사용자에게 제시하고 선택하게 하세요 — 자유 텍스트로 묻지 않는다.

### Phase 1: Identify and Label

Read the user's current work, plan, or task. Classify each component as content or form:

```
[CONTENT] Writing a blog post about AI consulting
[FORM]    Building a pipeline that turns consulting retros into blog posts
[CONTENT] Deploying a new API endpoint
[FORM]    Building a codegen that auto-generates endpoints from schemas
[CONTENT] Fixing a flaky test
[FORM]    Building a test infrastructure that prevents flaky tests by design
```

Present the labeling to the user as a brief diagnosis.

### Phase 2: Surface the Fork

사용자에게 다음 질문을 제시하고 번호 또는 라벨로 답하게 하세요:

**This is currently [CONTENT/FORM]-level work. Where should effort go?** (Level)
1. **Proceed with content** — Optimize within the current form — faster, lower risk
2. **Explore form change** — What if the medium/structure itself changed? Higher leverage
3. **Content now, note form** — Do the content work, but flag the form opportunity for later

### Phase 3: Branch

**If "Proceed with content"**: Acknowledge and proceed. Include a `Form Opportunity` note in the output for future reference.

**If "Explore form change"**: Generate 2-3 form alternatives. For each alternative:
- What the new form looks like concretely
- What new properties it would have (automatic, repeatable, scalable, composable)
- Minimum viable version to test the form

**If "Content now, note form"**: Proceed with content work. Append the form opportunity to the output.

### Output

Append to any deliverable or present standalone:

```markdown
## Content/Form Analysis

**Current work**: [description]
**Classification**: [CONTENT / FORM]

### Form Opportunity
| | Detail |
|---|--------|
| **Alternative form** | [what it would look like] |
| **New properties** | [what it enables that current form doesn't] |
| **Minimum test** | [smallest version to validate] |
| **Status** | [exploring / noted for later / not applicable] |
```

## The Metamedium Question

When stuck or when optimizing yields diminishing returns:

> **"What new form/medium could make this problem disappear?"**

Examples:
- Stuck writing more posts? → A format that turns client work into posts automatically
- Test coverage plateauing? → A tool that generates tests from type signatures
- Onboarding too slow? → A self-guided format where the codebase teaches itself

## Tetris Test

> Change the blocks. Then you realize the original blocks were mathematically calculated.

To truly understand a form, try to change it. The constraints discovered ARE the form's intelligence. Perspective shifts happen not by thinking harder, but by touching the form itself.

## Anti-Patterns

- Treating all work as content optimization when form change is available
- Building "better content" when the form is the bottleneck
- Assuming the current medium/format is fixed and only content can vary
- Confusing incremental content improvement with form invention

## Rules

1. **Always label**: Tag work as content or form
2. **Content is fine**: Not everything needs form change — but always note the option
3. **Form yields power**: New form = new medium = exponential leverage
4. **Code is metamedium**: The ability to code means the ability to change form
5. **Touch to understand**: Change the form to discover why it was designed that way

---
## 참조 파일 위치
이 프롬프트가 언급하는 `references/...` 파일은 plugin-mh 저장소의 `skills/metamedium/references/` 에 있다. Codex CLI에서 사용 시 해당 경로를 직접 Read 하면 된다.
