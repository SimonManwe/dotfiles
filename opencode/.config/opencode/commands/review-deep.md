---
description: Thorough review with one focused reviewer per lens (correctness, security, performance, design, frontend)
agent: build
---

Run a thorough review with one `reviewer` subagent per lens. Scope: $ARGUMENTS

Resolve the scope first:

- None: all uncommitted changes against HEAD, including untracked files. Changed files: the uncommitted changes below.
- `branch [<base>]`: everything the branch would contain if committed now. Base: `<base>` if given, otherwise the
  default base below; if it is `none`, stop and ask me. Diff against `git merge-base <base> HEAD`, plus untracked
  files. Changed files: `git diff --stat <merge base>` plus untracked files.
- A ref or range (e.g. `main...HEAD`): as given. Changed files: `git diff --stat <scope>`.
- A path: its uncommitted changes against HEAD, including its untracked files. Changed files:
  `git diff HEAD --stat -- <path>` plus its untracked files.

Default base: !`base=; for r in origin/HEAD origin/main origin/master origin/develop; do git rev-parse --verify --quiet "$r" >/dev/null && { base=$(git rev-parse --abbrev-ref "$r"); break; }; done; echo "${base:-none}"`

## 1. Choose the lenses

- Always run `C` (correctness & tests), `S` (security & compliance), `P` (performance & scaling), and `D` (design &
  conventions).
- Run `F` (frontend & accessibility) only if frontend files changed. Otherwise state `F skipped: no frontend changes`.
- Frontend files among the uncommitted changes:
  !`{ git diff HEAD --name-only; git ls-files --others --exclude-standard; } | grep -E '\.(tsx?|jsx?|css|scss|twig)$|(^|/)(app|components)/' || echo none`
- With a scope, apply the same pattern to its changed files instead.

## 2. Choose a model per lens

1. List the available chat models with the OpenCode models tool.
2. Take the families OpenAI GPT, Anthropic Claude, Google Gemini in that order, without your own family.
3. From each, pick the newest active general-purpose model (no mini/fast/lite variants).
4. Assign the lenses in the order C, S, P, D, F round-robin to those models. With one family left, use it for all
   lenses. With none, stop and ask me.

## 3. Launch the reviewers

- Launch all lens reviewers at once. Start each prompt with `Lens: <letter>`, then pass the resolved scope, its changed
  files, and the task's acceptance criteria if known.
- Do not pass your own reasoning, justifications, or claims that the code works.
- Print one line per lens: `Lens <letter>: <model> (session: <id>)`.
- Wait until every reviewer has finished before you merge. If one fails, say which and why, and merge the others.

## 4. Merge the findings

- Duplicates are findings at the same location with the same cause. Show them as one entry and name every ID
  (`C2 = S1`). Use the severity of a copy not tagged `out-of-lens`; only if every copy is `out-of-lens`, use the
  highest. Show the other severities next to it.
- Never drop, downgrade, or reword a finding. Every ID stays usable with `/fix-review`.
- Show a table sorted by severity (Blocker, Major, Minor, Nit; findings from several lenses first): IDs, severity,
  `file:line`, the issue line verbatim, lenses.
- Below it, the full text of every Blocker and Major finding, verbatim. Minor and Nit details are in the report.
- Then each lens's "could not verify" list and verdict, verbatim. Overall verdict: `changes needed` if any lens says so.

Don't fix anything until I decide.

## 5. Save the report

- Report path: !`sh ~/.config/opencode/scripts/review-report.sh new`
- Checkout: !`git rev-parse --show-toplevel`
- Branch: !`git rev-parse --abbrev-ref HEAD`
- HEAD: !`git rev-parse --short HEAD`

```text
# Deep review: <checkout directory name>

- Date: <YYYY-MM-DD HH:MM>
- Checkout: <path>
- Branch: <branch> @ <HEAD>
- Scope: <resolved scope, or "all uncommitted changes"; for a branch, include the base and merge base>
- Lenses: <letters that ran, plus "F skipped" if applicable>

## Reviewers

| Prefix | Model | Session |
| --- | --- | --- |
| C | <model id> | <session id> |

## Summary

<the merged table>

## Findings

### Lens C

<reviewer output, verbatim>
```

If you cannot write the file, say so; the findings stay in this conversation. End with:
`Next: /fix-review <IDs> [notes]`.

Uncommitted changes:

!`git status --short`

!`git diff HEAD --stat`
