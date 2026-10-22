---
name: sdd-verify
description: >
  Spec Driven Development closing step. Use when implementation is finished (and
  sdd-validate-impl approved or skipped), when the user says "verify the spec", "close the spec",
  "is this feature done", or wants to audit an existing spec. Verifies every task in
  tasks.md is [x], every AC-n has a test, the tests pass, and the code does no more and no
  less than the spec (no drift). Completes the traceability matrix and, only if there are no
  gaps or drift, sets the status to "Implemented" in the spec's definition of done and in
  specs/README.md.
---

# SDD: Verify and Close a Spec

Proves the feature meets its spec: **every AC-n has a test, the tests pass, and the code does
no more and no less than specified.** Then completes traceability and closes the spec.
This is an audit: it reports gaps; it does not quietly fix or reinterpret the spec.

## Spec layout assumed

```
specs/README.md                  # index with status per spec
specs/<feature>/spec.md          # AC-n, traceability table, definition of done, status
specs/<feature>/plan.md
specs/<feature>/tasks.md
```

## Workflow

### 1. Locate and read
Find the spec (named by the user, else current branch / latest in `specs/`). Read `spec.md`,
`plan.md`, `tasks.md` and the `## Validation log` if present.

### 2. Gate: tasks
Every task in `tasks.md` must be `[x]` (replaced/removed tasks marked as such are ignored).
If any is `[ ]`: **stop**, list them, and send the user back to finish them or to
`sdd-validate-impl`. Don't continue to a verdict.

Also check `## Validation log` has either `Approved by ...` or `Skipped: no BE controller or FE change`.
If neither is present and the work touched a BE controller or the FE, warn and recommend
`sdd-validate-impl` first; continue only if the user says to (e.g. auditing an old spec).

### 3. AC → test mapping
List every `AC-n` from `spec.md`. For each, find the test(s) that exercise it (search tests and
the traceability table; tests should reference the AC id in name or comment).
- Frontend (`ERAS-FE`, Jasmine/Karma): follow `ERAS-FE/.claude/skills/eras-fe-test/SKILL.md`.
- Backend (`ERAS-BE`, .NET): xUnit/NUnit tests under the test projects.
- A test counts only if its assertions actually check the criterion, not merely touch the code.
- An AC with no test is a **gap**. Offer to write the test (don't write it silently), or for a
  criterion that is genuinely manual-only, require it to be recorded as such with the validation
  evidence.

### 4. Run the tests
Run the relevant suites (e.g. `ng test --watch=false --browsers=ChromeHeadless` in `ERAS-FE`,
`dotnet test` in `ERAS-BE`) and capture pass/fail per mapped test. Failing or unrunnable tests
= gap. Report the real output; never claim a pass you didn't observe.

### 5. Drift check (no more, no less)
Compare `git diff <base>...HEAD` (base: `develop`) for the feature's code against the spec:
- **Less**: an AC or in-scope item with no corresponding code.
- **More**: behavior, endpoints, UI, config or dependencies not traceable to an AC/task
  (unrelated refactors, extra features, out-of-scope items implemented).
Each finding cites `file:line` and the AC/task it fails to map to.

### 6. Complete traceability
Fill/refresh the table in `spec.md`:

| AC | Task(s) | Test(s) (file › name) | Result | Code (files) |
|---|---|---|---|---|

Only record results you observed in step 4. Update the table even when the verdict is "gaps".

### 7. Verdict
Present a short report: tasks gate, AC matrix, test run, drift findings, verdict.

- **No gaps and no drift** → set status to `Implemented` in the spec's *Definition of Done*
  section of `spec.md` (tick its items) **and** the row in `specs/README.md`. Tell the user
  what was changed.
- **Any gap or drift** → leave status `In progress`, list each item with a recommended action
  (add test, fix code, remove extra code, or amend the spec via `sdd-validate-impl`). Do not
  edit the status.

## Don'ts
- Don't mark `Implemented` with a failing/missing test, an unchecked task, or unexplained drift.
- Don't edit AC text or tasks to make the verdict pass; changes to scope go through
  `sdd-validate-impl`.
- Don't commit unless asked.
