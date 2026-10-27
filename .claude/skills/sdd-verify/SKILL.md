---
name: sdd-verify
description: >
  Spec Driven Development closing step. Use when implementation is finished (and
  sdd-validate-impl approved or skipped), when the user says "verify the change", "is this
  feature done", or wants to audit an existing change. Verifies every task in tasks.md is
  [x], every AC has exactly one tagged test per affected side, the tests and the AGENTS.md
  section 8.7 gates pass, and the code does no more and no less than the spec and design.md
  (no drift). Completes the Traceability table and, only if there are no gaps or drift,
  recommends archiving. It never archives or commits.
allowed-tools: Bash(openspec:*) Bash(bash .claude/skills/sdd-implement/scripts/check-impl.sh:*) Bash(bash .claude/skills/sdd-adr/scripts/check-adr.sh:*)
---

# SDD: Verify and Close a Change

Proves the feature meets its spec: **every AC has a tagged test, the tests pass, and the code does
no more and no less than specified.** Then completes traceability and tells the user whether the
change is ready to archive. This is an audit: it reports gaps; it does not quietly fix or reinterpret
the spec. The conventions it relies on are in `AGENTS.md` §8.4.

## Change layout assumed

```
openspec/changes/<change-id>/proposal.md   # **Status:** / **Plan:** lines, ## Validation log
openspec/changes/<change-id>/specs/<capability>/spec.md   # ACs with "**Side:** BE|FE|BE + FE"
openspec/changes/<change-id>/design.md     # the plan
openspec/changes/<change-id>/tasks.md      # numbered tasks and ## Traceability
```

AC key: `<change-id>/AC-n`. BE tests carry `[Trait("AC", "<change-id>/AC-n")]`; FE tests start their
`it()` title with `[<change-id>/AC-n]`.

## Workflow

### 1. Locate and read
Find the change (named by the user, else current branch, else `openspec list`; ask if several). Read
`proposal.md` (including `## Validation log` if present), the specs, `design.md` and `tasks.md`.

### 2. Gate: tasks
Every task in `tasks.md` must be `[x]` (struck-through replaced tasks are ignored). If any is `[ ]`:
**stop**, list them, and send the user back to finish them with `sdd-implement` or to `sdd-validate-impl`.
Don't continue to a verdict.

Also check `## Validation log` in `proposal.md` has either `Approved by …` or
`Skipped: no BE controller or FE change`. If neither is present and the work touched a BE controller or
the FE, warn and recommend `sdd-validate-impl` first; continue only if the user says to (e.g. auditing an
old change).

### 3. AC → test mapping
Run `bash .claude/skills/sdd-implement/scripts/check-impl.sh "<change-id>" --final`: it counts the tagged
tests per AC per side declared by the `**Side:**` lines (exactly 1 each) and flags focused or skipped tests.
Then read each test: it counts only if its assertions actually check the criterion, not merely touch the code.
- Frontend (`ERAS-FE`, Jasmine/Karma): `AGENTS.md` §7.3.
- Backend (`ERAS-BE`, xUnit): `AGENTS.md` §6.3, written at the layer where the behavior is decided.
- An AC with no test is a **gap**. Offer to write the test (don't write it silently), or for a criterion that is
  genuinely manual-only, require it to be recorded as such in the validation log.

### 4. Run the tests and the gates
Run the gates of `AGENTS.md` §8.7 and capture pass/fail per mapped test:
- BE (`ERAS-BE/`): `dotnet build Eras.sln -warnaserror`, `dotnet format Eras.sln --verify-no-changes`,
  `dotnet test Eras.sln`, coverage ≥ 25%.
- FE (`ERAS-FE/`): `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage`
  (≥ 15%), `npm run build`.
- `openspec validate "<change-id>" --strict`.
Run only the sides the change touches. A failing or unrunnable gate or test = gap. Report the real
output; never claim a pass you didn't observe. If a build is blocked by file locks (running `Eras.Api` or
Visual Studio), ask the user to stop it.

### 5. Linked ADRs
Run `bash .claude/skills/sdd-adr/scripts/check-adr.sh --change "<change-id>"`: every `ADR-NNNN` that
`design.md` links must exist in `openspec/adr/` and be `Accepted`, and the ADR folder must be consistent.
A linked ADR that is still `Proposed`, or was `Rejected` or superseded, is a **gap**: a human accepts it, or
the design is amended through `/sdd-plan` (and `/sdd-adr` for a replacement). Also check that the code
follows each linked ADR's Decision; a departure is drift. Note every `WARN` about an untracked or uncommitted
ADR or index: those files must ship with the change (step 8).

### 6. Drift check (no more, no less)
Compare the feature's code against the spec and `design.md`. The code lives in the submodules, so diff
each touched one: `git -C ERAS-BE diff develop...HEAD`, `git -C ERAS-FE diff develop...HEAD`.
- **Less**: an AC or in-scope item with no corresponding code.
- **More**: behavior, endpoints, UI, config or dependencies not traceable to an AC or task (unrelated
  refactors, extra features, out-of-scope items implemented).
Each finding cites `file:line` and the AC/task it fails to map to.

### 7. Complete traceability
Fill or refresh `## Traceability` in `tasks.md`, one row per AC per affected side, with the **real** test:

| AC | Scenario | Side | Test |
|----|----------|------|------|

Test = `file › name` as found in step 3. Only record what you observed. Task numbers, results and code
files go in the report, not in the table (the table format is fixed by `AGENTS.md` §5.3). Update the table
even when the verdict is "gaps".

### 8. Verdict
Present a short report: tasks gate, AC matrix, gates and test run, linked ADRs, drift findings, verdict.

- **No gaps and no drift** → add to `## Validation log`: `Verified <date>: no gaps, no drift, gates green`.
  Tell the user the change is ready and list the **files the parent-repo commit must carry** (`AGENTS.md`
  §8.3 step 5): `openspec/changes/<change-id>/`, every linked or created ADR in `openspec/adr/` that is
  untracked or modified, `openspec/adr/README.md` when it changed, and any ADR whose Status this change
  superseded (`git status --short openspec/` shows them). The submodule PRs link
  `openspec/changes/<change-id>`, and after they merge the pointers are bumped and the change is archived
  (`/opsx:archive`, or `openspec archive <change-id> --yes`).
- **Any gap or drift** → list each item with a recommended action (add test, fix code, remove extra code,
  or amend the spec through `/sdd-spec` and `/sdd-plan`). Do not add the `Verified` line.

## Don'ts
- Don't declare the change ready with a failing/missing test, an unchecked task, a red gate, a linked ADR that is
  not Accepted, or unexplained drift.
- Don't edit AC text or tasks to make the verdict pass; scope changes go through `sdd-validate-impl`,
  `/sdd-spec` and `/sdd-plan`.
- Don't archive: archiving is the developer's step after the submodule PRs merge.
- There is no `Implemented` status to set: the change is done when it is verified and archived.
- Don't edit `**Status:**` or `**Plan:**`.
- Don't commit unless asked.
