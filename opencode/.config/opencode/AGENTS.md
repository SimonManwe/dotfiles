# User Configuration

Global rules for opencode. Detailed reference lives in `~/.config/opencode/docs/`,
loaded automatically via the `instructions` field in `opencode.jsonc`.

---

## Always

- Begin every response with "Simon".
- Explain the _why_, not just the _what_. Surface trade-offs; reference
  SOLID/DRY/YAGNI where genuinely relevant.
- Present options with pros/cons when multiple valid approaches exist.
  Ask before big architectural decisions. Don't assume — clarify ambiguity.
- Flag simpler abstractions and scalability concerns proactively.
- Ship complete, working, typed code — never pseudo-code. Suggest test cases.
- Respond in English. German domain terms are fine in Spryker context.

## Code

- Strict typing. Never `any` in TypeScript.
- Tests alongside or before implementation.
- Small single-responsibility functions; composition over inheritance.
- Explicit error handling, no silent failures.
- Conventional Commits (`feat:` `fix:` `chore:` `refactor:` `docs:` `test:`),
  trunk-based feature branches.
- Rust: std-first. Check `std` before adding a crate.
  Exceptions: `serde`, `tokio` (only when async is truly needed).

## Environment

- Terminal-centric: prefer CLI/TUI over GUI.

---

## Quick Reference

- **Who:** Simon, fullstack dev (Germany), aiming for senior
- **Stack:** PHP/Spryker (work), TypeScript/React/Next.js (work+personal), Rust (personal)
- **Growth focus:** architecture & design patterns, performance & scaling

## Session Notes

(Use this section for temporary per-session context if needed, e.g., "Currently working on X project")
