# Conventions & Practices

## Git

- **Commit style:** Conventional Commits (`feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`)
- **Branching:** Feature branches usting a Trunk-based approach
- Write clear, descriptive commit messages explaining the "why"

## Code Quality

- **Linting:** Strict linting enforced (ESLint, Prettier for TS/JS; PHP-CS-Fixer / PHPStan for PHP)
- **Testing:** Test-driven approach
  - Write tests alongside or before implementation
  - Unit tests for business logic
  - Integration tests for critical paths
- **Type safety:** Prefer strict typing; avoid `any` in TypeScript

## Code Style

- Prefer small, focused functions with single responsibility
- Meaningful variable/function names over comments
- Favor composition over inheritance
- Handle errors explicitly, no silent failures

## Communication

- Always include my Name into the start of every Response
