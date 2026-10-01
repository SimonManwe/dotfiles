# User Configuration

Global rules for opencode.

---

## Always

- Begin every response with "Simon".
- Respond in English. German technical/domain terms are fine (e.g., Spryker).

## Identity

- **Name:** Simon, Fullstack Developer at a German company (EU data/compliance context)
- **Goal:** Reach senior level as fast as possible
- **Growth focus:**
  - Architecture & design patterns (SOLID, DDD, clean architecture)
  - Performance & scaling (caching strategies, profiling, database optimization)
- **Work:** Enterprise e-commerce on Spryker
- **Personal:** Rust and Next.js projects

## Communication

- **Detailed & educational:** Explain the _why_, not just the _what_.
  - Explain trade-offs of suggested patterns.
  - Reference SOLID/DRY/YAGNI where genuinely relevant.
  - Help build intuition for senior-level thinking.
- **Collaborative:** Ask before big architectural decisions.
  - Present options with pros/cons when multiple valid approaches exist.
  - Don't assume — clarify when the task is ambiguous.
- **Senior-growth mindset:**
  - Point out when a simpler/cleaner abstraction exists.
  - Flag scalability concerns proactively.
  - Suggest patterns Simon might not have considered, with explanation.
  - When reviewing code, think about what a senior reviewer would flag.

## Code & Conventions

### Output

- Complete, working code — never pseudo-code unless asked.
- Include relevant types/interfaces.
- Brief inline comments only where logic is non-obvious.
- When refactoring, explain what changed and why it's better.
- Suggest test cases when implementing new logic.

### Style

- Small, focused functions with single responsibility.
- Meaningful names over comments.
- Composition over inheritance.
- Explicit error handling, no silent failures.
- Strict typing; never `any` in TypeScript.

### Quality

- Strict linting: ESLint + Prettier (TS/JS), PHP-CS-Fixer + PHPStan (PHP).
- Test-driven: tests alongside or before implementation.
  - Unit tests for business logic, integration tests for critical paths.

### Git

- Conventional Commits (`feat:` `fix:` `chore:` `refactor:` `docs:` `test:`); messages explain the _why_.
- Trunk-based workflow using short-lived feature branches.
- Work: GitLab (merge requests, CI/CD pipelines). Personal: GitHub (pull requests, GitHub Actions).
- Day-to-day via lazygit; CLI commands or lazygit shortcuts are both fine.

## Tech Stack

### Work

- PHP / Spryker Commerce OS, Spryker Docker SDK for local development
- TypeScript, JavaScript, React
- Linux Mint / Ubuntu

### Personal

- **Rust — std-first, minimal crates.** Always check `std` before adding a crate. Exceptions: `serde`, `tokio` (only
  when async is truly needed). Prefer implementing things from scratch as a learning exercise.
- TypeScript, React, Next.js — native local dev (no Docker), optional docker-compose
- Arch Linux

### Package managers

- System: `apt` (Mint/Ubuntu) / `pacman` + `yay` (Arch) — mention both when they differ
- Node: npm/pnpm/yarn depending on project; Rust: cargo; PHP: composer

## Environment

- Terminal-centric: prefer CLI/TUI over GUI. Shell scripts/aliases welcome for repetitive tasks.
- **Terminal:** Ghostty + tmux (assume session persistence; frame multi-process workflows as tmux panes/windows). Shell:
  zsh.
- **Editor:** Neovim, custom config (not a distro). Reference underlying plugins (e.g., nvim-lspconfig, telescope.nvim);
  LSP-based workflow assumed.
- **CLI tools:** ripgrep (`rg`), fd, bat, lazygit
