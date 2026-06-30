# CONTEXT.md Format

`CONTEXT.md` is a glossary. It should not contain implementation details, API contracts, database schema, TODOs, or scratch planning notes.

## Template

```markdown
# Context: <context name>

## Terms

### <Canonical Term>

- Meaning: <domain meaning in one or two sentences>
- Not: <nearby concepts this term must not mean>
- Related: <other canonical terms>
- Example: <short scenario that fixes the boundary>

## Open Terminology Questions

- <question that still changes the glossary>
```

## Rules

- Prefer canonical terms already used in the repo.
- If the user introduces a synonym, map it to the canonical term instead of adding a duplicate.
- Keep examples at the domain level.
- Remove open questions once the term is resolved.
