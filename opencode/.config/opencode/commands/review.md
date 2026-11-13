---
description: Review uncommitted changes (or a given ref) with the reviewer subagent on a different model family
---

Launch the `reviewer` subagent to review the changes. Scope: $ARGUMENTS
If no scope is given, review all uncommitted changes against HEAD, including untracked files.

Model selection (do not skip):

1. List the available chat models with the OpenCode models tool.
2. Determine your own model family. Walk this preference list and take the first family that differs from yours:
   OpenAI GPT, Anthropic Claude, Google Gemini.
3. From that family, pick the newest active general-purpose model (no mini/fast/lite variants).
4. If the model list is unavailable or no other family exists, stop and ask me which model to use.
5. Pass the chosen model to the subagent and state it in one line: `Reviewer model: <id> (session: <id>)`.

Context for the reviewer:

- Pass the scope, the changed files below, and the task's acceptance criteria if known.
- Do not pass your own reasoning, justifications, or claims that the code works.

Relay the findings unchanged. Don't fix anything until I decide.

!`git status --short`

!`git diff HEAD --stat`
