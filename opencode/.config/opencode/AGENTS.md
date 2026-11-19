# User Configuration

Global rules for opencode.

---

## Always

- Begin every response with "Simon".
- Respond in English. German technical/domain terms are fine (e.g., Spryker).
- Where this file conflicts with an agent's system prompt or a project `AGENTS.md`, those win.

## Identity

- **Name:** Simon, Fullstack Developer at a German company (EU data/compliance context)
- **Goal:** Reach senior level as fast as possible
- **Growth focus:**
  - Architecture & design patterns (SOLID, DDD, clean architecture)
  - Performance & scaling (caching strategies, profiling, database optimization)

## Working Agreement

### Definition of Done

- Done means the relevant checks pass: linters, static analysis/type checks, and tests covering the changed code.
- Discover check commands from the project (project `AGENTS.md`, `package.json`/`composer.json` scripts, Makefile, CI
  config). Don't guess commands. Typical tools: ESLint + Prettier (TS/JS), PHP-CS-Fixer + PHPStan (PHP), rustfmt +
  clippy (Rust).
- Prove it: list the exact commands you ran and their results. If a check could not run, say so and why. Never imply it
  passed.

### Scope

- Change only what the task requires. No drive-by refactors, renames, or reformatting.
- List unrelated issues you noticed in the summary instead of fixing them.
- For multi-step work, propose a plan of small, independently verifiable slices before editing.

### Correctness

- Never invent APIs. Verify classes, methods, and signatures in the actual source (`vendor/`, `node_modules/`, official
  docs) before using them — especially for Spryker.
- Search for existing helpers and patterns before writing new code; follow the codebase's conventions.
- Say when you are unsure and how it can be verified, instead of guessing.
- Bugs: write a failing test that reproduces the bug first, then fix it.
- Never weaken assertions, skip, or delete tests to make them pass.
- Never silence errors to get green (`@phpstan-ignore`, baseline additions, `eslint-disable`, `@ts-expect-error`,
  `as unknown as`, empty catch blocks) without asking first.

### Decisions

- Ask before one-way-door decisions: architecture, public APIs/contracts, DB schema, adding/removing dependencies,
  anything costly to reverse. Check `docs/*-decisions.md` first and respect prior decisions or challenge them
  explicitly; record new ones with the `adr` skill.
- Decide two-way-door choices yourself (local naming, internal structure); state the assumption and continue.
- Clarify ambiguous requirements before implementing — unclear requirements are never a two-way door.

### Safety

- Never commit or push. Simon commits manually via lazygit. Draft commit messages only when asked.
- Never discard uncommitted work or rewrite history (`git restore`, `git checkout -- <path>`, `git reset`, `git clean`,
  `git stash`, `git rebase`) without asking.
- Never edit generated or vendored code: `vendor/`, `node_modules/`, `src/Generated/`, `target/`, build output.
- No real customer data, PII, secrets, or production data in code, fixtures, logs, or prompts; use anonymized fixtures.

## Communication

- **Depth by complexity:** terse progress updates on simple tasks, with the educational part (why, trade-offs) in the
  final summary; detailed and educational throughout on complex ones (architecture, multi-step, cross-module,
  performance).
- **Final summary** after changes: what changed (files), why, verification evidence, open risks, important cases not
  covered, out-of-scope findings.
- Explain the _why_ and the trade-offs; reference SOLID/DRY/YAGNI only where they genuinely apply.
- Present options with pros/cons when several approaches are valid.
- Proactively flag simpler abstractions, scalability risks, and patterns Simon may not know — in the summary, not as
  unrequested changes.

## Code & Conventions

- Complete, working code with relevant types/interfaces — no pseudo-code unless asked.
- Strict typing; never `any` in TypeScript.
- Handle errors explicitly; no silent failures.
- Prefer composition in new code; where a framework extends via inheritance (e.g., Spryker project-level overrides and
  kernel base classes), follow the framework.
- Write tests alongside or before the implementation: unit tests for business logic, integration tests for critical
  paths.

### Git

- Conventional Commits (`feat:` `fix:` `chore:` `refactor:` `docs:` `test:`); messages explain the _why_.
- Work: GitLab (merge requests, CI/CD pipelines). Personal: GitHub (pull requests, GitHub Actions).

## Tech Stack

- **Work:** Enterprise e-commerce on PHP / Spryker Commerce OS (Docker SDK for local development) with a
  TypeScript/React/Next.js frontend. Linux Mint / Ubuntu.
- **Personal:** Mainly Rust and C, plus TypeScript and React. Arch Linux.
- **Rust — std-first, minimal crates.** Always check `std` before adding a crate. Exceptions: `serde`, `tokio` (only
  when async is truly needed). Prefer implementing things from scratch as a learning exercise.
- **System packages:** `apt` (Mint/Ubuntu) / `pacman` + `yay` (Arch) — mention both when they differ.

## Environment

- Terminal-centric: prefer CLI/TUI over GUI. Shell scripts/aliases welcome for repetitive tasks.
- **Terminal:** Ghostty + tmux (assume session persistence; frame multi-process workflows as tmux panes/windows). Shell:
  zsh.
- **Editor:** Neovim, custom config (not a distro). Reference underlying plugins (e.g., nvim-lspconfig, telescope.nvim);
  LSP-based workflow assumed.
- **CLI tools:** ripgrep (`rg`), fd, bat, lazygit
