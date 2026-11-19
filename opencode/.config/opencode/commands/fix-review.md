---
description: Fix selected review findings by ID, then have the reviewer verify the fixes (one round)
agent: build
---

Fix these review findings: $ARGUMENTS

- The arguments are finding IDs (e.g. `R1 S2`), optionally followed by notes from me on how to fix them.

Review report for this checkout:

!`sh ~/.config/opencode/scripts/review-report.sh show`

Current state:

- Branch: !`git rev-parse --abbrev-ref HEAD`
- HEAD: !`git rev-parse --short HEAD`

## 1. Load the findings

- The report above is the source of truth. If there is none, use the findings from this conversation. If neither exists,
  stop and tell me to run `/review` first.
- If a requested ID does not exist, stop and list the available IDs.
- If the report's branch or HEAD differs from the current state, stop and ask me: the reviewed code has changed.
- Quote the selected findings verbatim before changing anything.

## 2. Fix each finding

- If you think a finding is wrong, mark it `Disputed`, show the evidence (`file:line`, docs, a test), and change no code
  for it.
- If it describes testable behavior, first write a test that reproduces it and run it. It must fail; keep the output. If
  you cannot make it fail, mark it `Disputed` with what you tried, and change no code for it. If it is not testable
  (design, naming, scope), say why.
- Make the smallest change that removes the cause, then rerun the test; it must pass. Keep the output.
- Change nothing that no selected finding requires. List anything else you notice instead.

## 3. Run the checks

Run the project's checks from the Definition of Done and show the exact commands and results.

## 4. Record the fix round

Append to the report file:

```text
## Fix round <n>

| ID | Status | Evidence | Files |
| --- | --- | --- | --- |
| R1 | Fixed / Disputed | test name + failing and passing output excerpt, or the reason | changed files |
```

## 5. Verify with the reviewer

- Group the IDs by prefix. For each prefix, continue the most recent reviewer session in the report's Reviewers table
  for that prefix (subagent tool with that session ID) and ask it to verify in verification mode. Verify all prefixes at
  once.
- Resuming only works for reviewers started from this session. If it fails, launch a new `reviewer` with the model from
  that row, starting its prompt with `Lens: <prefix>` unless the prefix is `R`, add a row for it to the Reviewers table
  (same prefix, model, new session ID), and tell me you did.
- Pass only the IDs, the report file path, and the changed files. No reasoning or claims that the fixes work: the
  evidence is in the report.
- Append its answer verbatim to the report under `### Verification (<reviewer session ID>)`.

## 6. Stop

Show a table of ID, fix status, and reviewer verdict, then any new findings. Then list the IDs in the report (including
new ones from verifications) that no verification has marked `Resolved` or `Withdrawn` yet, as `Still open: …` (or
`Still open: none`). IDs that the report's Summary joins with `=` are one finding: if one of them is `Resolved` or
`Withdrawn`, list the others as resolved too, shown as `S2 (= C1)`. Do not start another round; I decide what happens
next.
