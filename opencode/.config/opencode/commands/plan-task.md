---
description: Frame a task and produce a sliced implementation plan (no edits)
agent: plan
---

Task: $ARGUMENTS

Before planning:

1. Explore the relevant code and check `docs/*-decisions.md` for related decisions.
2. If the requirements are ambiguous, ask clarifying questions first and stop until they are answered.

Then produce:

- **Understanding:** goal, acceptance criteria, non-goals, assumptions.
- **Context:** relevant files and the existing patterns to follow (with paths).
- **Plan:** small, independently verifiable slices. For each slice: files touched, the test that proves it, and the
  checks to run.
- **Risks:** one-way-door decisions (flag ADR candidates), performance/scalability concerns, compliance concerns.
