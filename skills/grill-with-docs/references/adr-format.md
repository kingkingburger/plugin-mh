# ADR Format

Create ADRs only for decisions that are hard to reverse, surprising without context, and chosen from real alternatives.

## File Name

```text
docs/adr/NNNN-short-kebab-title.md
```

Use the next available number in the target ADR directory.

## Template

```markdown
# NNNN: <Decision Title>

Date: YYYY-MM-DD
Status: Accepted

## Context

<Why this decision is needed now. Include constraints and forces, not implementation trivia.>

## Decision

<The chosen direction in clear language.>

## Alternatives Considered

- <Alternative A>: <why not chosen>
- <Alternative B>: <why not chosen>

## Consequences

- Positive: <expected benefit>
- Negative: <cost or trade-off>
- Watch: <signal that would make this decision worth revisiting>
```

## Rules

- Do not create an ADR for a preference, naming cleanup, or easily reversible local detail.
- Keep the decision durable enough that a future maintainer can understand why the repo looks this way.
