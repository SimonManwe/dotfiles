# Agentic Development Workflow

How I work with coding agents (OpenCode) without lowering the quality bar. This document is for me, not for the
agent: it is not loaded into agent context. Agent behavior lives in
[`AGENTS.md`](../opencode/.config/opencode/AGENTS.md).

## 1. Mental model

- I am the tech lead. The agent is a fast mid-level developer with **no memory, no accountability, and a bias toward
  "looks done"**.
- Quality = context I give × task size × verification loop × my review.
- The bottleneck is **my review bandwidth**, not generation speed. Optimize for reviewable output, not for maximum
  output.
- I own every line I commit. "The agent wrote it" is never an excuse.

## 2. The toolkit

| Layer | Location | Loaded | Purpose |
| --- | --- | --- | --- |
| Global `AGENTS.md` | `~/.config/opencode/AGENTS.md` | Every session | Who I am, universal working agreement |
| Project `AGENTS.md` | Repo root / subdirectories | Sessions in that project | Commands, architecture, project conventions |
| Skills | `~/.config/opencode/skills/` | On demand | Workflows for specific situations (`adr`) |
| Agents | `~/.config/opencode/agents/` | When selected/launched | Roles with their own prompt + permissions |
| Commands | `~/.config/opencode/commands/` | When I type `/name` | Repeatable entry points into the workflow |
| Scripts | `~/.config/opencode/scripts/` | Called by commands | Shared shell helpers (review report paths) |
| Permissions | `opencode.jsonc` | Always enforced | Hard guardrails (no commit/push, ask before destructive git) |
| This document | `docs/agentic-workflow.md` | Never (for me) | The process |

Rule of thumb: always-on context costs tokens and attention in every session, so keep it small. Anything situational
belongs in a skill, a command, or a project `AGENTS.md`.

## 3. The loop (per ticket)

```text
Frame → /plan-task → slice → tests first → implement + checks → /review → triage → /fix-review → my review → I commit → /retro
```

1. **Frame** (me, 2–5 min): goal, acceptance criteria, constraints, non-goals, entry points (`@file`). See
   [section 4](#4-framing-a-task).
2. **Plan** — `/plan-task <task>` switches to the Plan agent. It explores, checks ADRs, asks if something is
   unclear, and returns a sliced plan. **Challenge the plan.** It is the cheapest point to catch a wrong approach.
3. **Slice**: each slice is one diff I can review in ~10–15 minutes, ends green, and maps to ideally one commit. If a
   diff is too big to review properly, the slice was too big.
4. **Tests first**: a failing test that reproduces the bug or specifies the behavior. **Review tests harder than the
   implementation** — they are the spec. A wrong test makes wrong code look correct.
5. **Implement** (Build agent, `Shift+Tab` to cycle agents or `<leader>a` to pick one): one slice at a time.
6. **Checks** — part of the Definition of Done in `AGENTS.md`: the agent runs lint, static analysis, and tests and
   shows the commands and results. No evidence, no "done"; if it is missing, ask for it.
   - This is still the agent checking itself. The real gate is what runs regardless of who wrote the code:
     pre-commit hooks and CI.
7. **Review** — `/review` launches the read-only reviewer on a **different model family** with fresh context and saves a
   report. For risky changes and before an MR, use `/review-deep` instead (see [Review commands](#review-commands)).
8. **Triage & fix** — I decide which findings matter. `/fix-review <IDs> [notes]` fixes only those (test first), then
   the reviewer verifies them once. Anything unresolved comes back to me. Then I review the diff myself in lazygit /
   Neovim.
   - **Rule: never commit code I could not explain to a colleague.**
9. **Commit** — I write the Conventional Commit message myself and commit via lazygit. Agents are not allowed to
   commit. Putting the _why_ into my own words is practice in explaining decisions.
10. **Retro** — `/retro` (1 min): if the agent made a mistake twice, turn it into a rule in the relevant `AGENTS.md`.

### Why the reviewer uses a different model

A model reviewing its own output shares its own blind spots. `/review` therefore picks the newest general-purpose
model from a different family at runtime (preference: OpenAI GPT → Anthropic Claude → Google Gemini, first one that
differs from the coding model). That is a _policy_, not a pinned model ID — like a version range instead of a pinned
version, it stays current without edits. The `Reviewer model: …` line it prints is the "lockfile" for traceability.

The coding agent must not pass its own reasoning to the reviewer. Telling the reviewer "this works because…" anchors
it and defeats the fresh-eyes review.

### Review commands

```text
/review or /review-deep ──► report with IDs ──► I triage ──► /fix-review <IDs> ──► 1 verification round ──► me
```

| Command | Reviewers | Use for | Cost |
| --- | --- | --- | --- |
| `/review` | 1 generalist, IDs `R1…` | Every slice | 1 reviewer run |
| `/review-deep` | 1 per lens: `C` correctness, `S` security, `P` performance, `D` design, `F` frontend (only if frontend files changed) | Risky changes (auth, money, PII, data model, hot paths), before an MR | ~5× `/review` |
| `/fix-review` | Resumes or relaunches the reviewer per ID prefix | Findings I picked | 1 fix round + 1 verification |

`/review-deep` assigns the lenses round-robin to the newest models of the families I am not coding with, so their blind
spots are less correlated. On a test project with one planted issue per lens, it found all 5 but reported 15 findings;
`/review` on almost the same code reported 4. More coverage means more triage, so `/review-deep` is not the default.

Triage:

- **Disputed findings:** `/fix-review` must show evidence (a test it could not make fail, `file:line`); the reviewer
  answers `Withdrawn` or `Upheld`. I make the final call.
- **Severity is noisy:** the same duplicated helper was Major in one run and Minor in another. Judge by the scenario,
  not the label.
- **Tags:** findings marked `speculative` or `out-of-lens` get lower priority unless the scenario convinces me.
- **Track outcomes** (fixed / disputed / rejected, per reviewer model) in `/retro` to see whether cross-family review
  pays off.

### Review reports

- `/review` and `/review-deep` write `/tmp/opencode/reviews/<checkout>-<hash>-<timestamp>.md`. The key is the directory
  name plus a hash of the full checkout path, so worktrees (workmux, OpenCode) never share reports.
- `/fix-review` reads the newest report for the current checkout, so it works in a new session or after compaction. It
  stops if the branch or HEAD changed since the review.
- Finding IDs never change and are never reused: `R` for `/review`, the lens letter for `/review-deep`. Duplicates
  across lenses are joined (`C1 = S2`) and resolved together.
- Every fix round and verification is appended to the report, with the reviewer session ID.
- A session can only resume reviewers it started itself. In a new session, `/fix-review` starts a new reviewer with the
  same model and lens and adds it to the Reviewers table.
- `/tmp` is cleared on reboot. That is fine: a review is cheap to repeat. Anything worth keeping goes into an ADR or
  `/retro`.

## 4. Framing a task

Template:

```text
Goal: <what and why, one or two sentences>
Acceptance criteria:
- <observable behavior 1>
- <observable behavior 2>
Constraints: <performance, compliance, compatibility, deadlines>
Non-goals: <what must not change>
Entry points: @path/to/file, follow the pattern in @path/to/similar/Thing
```

Bad:

```text
Add caching to the product page.
```

Good:

```text
Goal: Reduce product detail page load by caching the availability lookup, which is called per request.
Acceptance criteria:
- Availability is cached per SKU + store for 5 minutes.
- Cache is invalidated when the availability changes (publish event).
- Unit tests cover hit, miss, and invalidation.
Constraints: no new dependency; use the existing Redis storage client.
Non-goals: no changes to the Glue API response format.
Entry points: @src/Pyz/Client/Availability, follow the caching pattern in @src/Pyz/Client/PriceProduct
```

"Follow the pattern in X" beats describing the pattern: the agent reads real code instead of guessing.

## 5. Context hygiene

- **One task = one session.** Start a new session when switching topics or when quality drops after compaction.
- **State lives in files**, not chat: plans, ADRs (`docs/*-decisions.md`), TODOs. A new session can pick them up.
- **Use the `explore` subagent** for broad searches so the main context stays focused.
- **Correction loop rule:** if I corrected the same thing 2–3 times, stop. Revert, improve the prompt, start fresh.
  Arguing with a polluted context rarely converges.

## 6. Review checklist (typical agent failure modes)

- [ ] **Invented or outdated APIs** — verify against `vendor/` / `node_modules/` (Spryker facades, plugins, versions).
- [ ] **Test tampering** — weakened assertions, mocking the unit under test, skipped tests, special-cased inputs.
- [ ] **Silent failures** — catch-and-log, `?? []`, `@phpstan-ignore`, baseline additions, `eslint-disable`,
      `as unknown as`.
- [ ] **Scope creep** — unrelated changes, drive-by refactors, reformatting.
- [ ] **Over-engineering** — interfaces/factories with one implementation (YAGNI).
- [ ] **Bloat** — code or tests out of proportion to what they do: forwarding wrappers, redundant checks, unused
      parameters, comments that restate the code.
- [ ] **Duplication** — new helper instead of reusing an existing one.
- [ ] **Outdated patterns** — old framework idioms (Next.js Pages Router, old Spryker APIs).
- [ ] **Unproven "done"** — no commands and results shown.
- [ ] **Security & compliance** — injection, authorization, secrets, PII in logs or fixtures.
- [ ] **Performance** — N+1 queries, missing indexes/caching, unbounded collections.

## 7. Delegation matrix

| Task | Mode |
| --- | --- |
| Boilerplate (transfer XML, schema, config, test scaffolding) | Agent drives, I review |
| Bugfix in a known area | Agent drives, starting from a failing test |
| Unfamiliar code | Agent explains, I verify by reading the code |
| Architecture, DDD, caching, performance (my growth areas) | **I draft first**, agent argues against my design |
| Rust learning projects | **I write the code**; `mentor` agent reviews and gives hints only |

Why: delegating the thinking I want to learn atrophies exactly that skill. Senior judgment is built by making
decisions and living with their consequences. The `mentor` agent (`<leader>a` to select it) cannot edit files and
gives escalating hints instead of solutions.

## 8. Safety & permissions

Enforced in `opencode.jsonc` (defense in depth on top of the `AGENTS.md` rules):

| Rule | Effect | Why |
| --- | --- | --- |
| `git commit`, `git push` | deny | I commit manually; no exceptions |
| `git reset/restore/checkout/clean/stash/rebase` | ask | Can destroy uncommitted work or history |
| `rm` | ask | Irreversible |
| `sudo` | deny | Agents never need root |
| Paths outside the project | ask | Keep agents scoped to the current project |

Limits to keep in mind:

- Prose rules in `AGENTS.md` are probabilistic; permissions are enforced but pattern-based (e.g. an unusual command
  form can slip past a pattern). Use both.
- Keep the `ask` list short. Too many prompts lead to approval fatigue and rubber-stamping, which is worse than no
  prompt.
- Never put real customer data, PII, secrets, or production data into prompts or fixtures.
- Review "Allow always" approvals now and then; they are saved per project.

## 9. Parallel work

- Use git worktrees (one agent per worktree) for independent tasks.
- Cap parallelism at what I can actually review (2–3). Unreviewed output is not progress.
- Parallel reviewers (`/review-deep`) are safe without worktrees because they are read-only.

## 10. Maintaining `AGENTS.md`

- **Grow it from failures**, not from wishlists: a rule earns its place when it would have prevented a real mistake
  (`/retro`).
- **Global vs. project:** universal behavior goes global; build commands, architecture, and conventions go into the
  project `AGENTS.md` (committed, so the team benefits too).
- **Prune regularly:** remove rules the models now follow by default, and merge duplicates. Every line costs
  attention in every session.
- Write rules as specific, checkable instructions ("run X before reporting done"), not descriptions ("we use X").
- The "Begin every response with Simon" rule is a canary: if it disappears, instructions were not loaded or got lost.

## 11. Open experiments

Things I am watching before turning them into rules (detect before prevent):

- **Show only the fix's diff:** stage everything in lazygit before `/fix-review`, so `git diff` shows only the fix. Not
  adopted yet; first check that the reviewer's `git diff *` permission also allows a plain `git diff`.
- **Heavy tests from `/fix-review`:** once wrote a 40-line test that re-runs the test binary to prove a removed
  `eprintln!` stays removed. Rule candidate if it recurs: "write a test only if it is worth keeping; for removals the
  diff is the evidence."
- **Bloat check:** the reviewer checklist item caught all 4 planted cases (and stayed quiet on the debatable test
  above). Lens `D` and the proportionality note in verification mode are still unproven.
- **Out-of-lens severity:** Gemini once raised out-of-lens findings to Blocker, the only severity allowed across lenses.
  The merged severity now comes from the lens that owns the finding; check this on the next real `/review-deep`.
- **Coordinator drift:** the main agent checked cited lines before merging `/review-deep` results. Harmless so far, but
  it must not filter or reword findings.

## Setup

The OpenCode config is a stow package. After adding new directories (agents, commands, skills, scripts), re-stow from
the dotfiles root:

```sh
stow -n -v --adopt --restow -t ~ opencode   # dry run
stow    -v --adopt --restow -t ~ opencode
git status                                   # adopted files must not differ
```

Edits to the repo files do not reach the running OpenCode service through the stow symlinks. Run `/reload` in the TUI
after every change to agents or commands, then check that the new text is loaded (the command endpoint only returns
names and descriptions, so only agent prompts can be checked this way):

```sh
opencode api get '/api/agent?location[directory]=<project>' \
  | jq -r '.data[] | select((.id // .name) == "reviewer") | .. | strings' | rg '<new text>'
```

Neovim formats Markdown on save with `prettier --prose-wrap=always --print-width=120`, which joins lines within a
paragraph. In command files, put `$ARGUMENTS` and shell lines (`` !`…` ``) in their own paragraph or bullet so they stay
separate.
