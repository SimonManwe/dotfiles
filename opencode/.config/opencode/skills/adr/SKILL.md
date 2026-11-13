---
name: ADR
description: Record Architecture Decision Records (ADR-style) in docs/<TICKET>-decisions.md. Use when a decision is architectural, adds or removes a dependency, or is costly to reverse.
---

# Architecture Decision Records

## When

- Record decisions that are architectural, add/remove a dependency, or are costly to reverse.
- Skip trivial/local choices (naming, small refactors).

## Workflow

1. Check existing `docs/*-decisions.md` for related or conflicting entries. Respect them, or challenge them
   explicitly and propose superseding.
2. Present the options with pros/cons to Simon and ask before writing anything.
3. Write the entry with status `Proposed`.
4. Set the status to `Accepted` only after Simon confirms.

## Location

- `docs/<TICKET>-decisions.md` in the project root (e.g. `docs/SHOP-1234-decisions.md`).
- No ticket (personal projects)? Use a short kebab-case task slug (e.g. `docs/agentic-workflow-decisions.md`).
- Create `docs/` if missing.
- One file per ticket/task; append entries, numbered sequentially within the file.

## Entry format

```md
### <TICKET>-<NN>: <Short title>

- **Date:** YYYY-MM-DD
- **Status:** Proposed | Accepted | Superseded by <ID> | Deprecated
- **Context:** problem and constraints
- **Decision drivers:** criteria that matter (e.g. performance, compliance, maintainability)
- **Options:** considered alternatives with pros/cons
- **Decision:** what was chosen and why
- **Consequences:** trade-offs, follow-ups, risks
```

## Rules

- Never rewrite accepted entries; only the Status line may change.
- To change an accepted decision, add a new entry that supersedes it and link both ways by ID
  (old: `Superseded by <NEW-ID>`, new: reference `<OLD-ID>` in its Context).
