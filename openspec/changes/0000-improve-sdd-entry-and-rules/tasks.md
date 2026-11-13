# Tasks

Each group below is one commit, so one group can be reverted without touching the others.

## 1. Baseline (Docs)

- [x] 1.1 Run `bash .claude/skills/sdd-plan/tests/check-skills.sh` and record the result, and verify it reports 8 skills and 0 errors before any edit
- [x] 1.2 Run `bash .claude/skills/sdd-plan/tests/check-skills.sh` from a copy of the repo without `ERAS-BE/` and `ERAS-FE/`, and record the result, and verify the only errors (if any) are the ones that exist before this change

## 2. F1: rule for a bare `#<n>` (Docs)

- [x] 2.1 Add the `#<n>` rule to `CLAUDE.md`, in "Claude Code specifics", with the four steps of the proposal, and verify `CLAUDE.md` still imports `@AGENTS.md`
- [x] 2.2 Run `check-skills.sh` and verify 0 errors

## 3. F2 and T8: `/sdd-*` as the main path (Docs)

- [x] 3.1 Reword the first bullets of `CLAUDE.md` so features use `/sdd-spec` to `/sdd-archive`, `/opsx:explore` is for thinking, and `/opsx:propose` and `/opsx:apply` are only for `skip_specs` changes, keeping the "stop for human approval" and "do not edit `ERAS-BE/` or `ERAS-FE/` until approved" sentences, and verify both sentences are still present
- [x] 3.2 Add one note and the three-row "Which command when" table (T8) under the table of `AGENTS.md` section 8.5, without removing or renumbering any row or heading, and verify `git diff --numstat AGENTS.md` shows 0 deleted lines
- [x] 3.3 Add one sentence to `AGENTS.md` section 8.5 that points to the `#<n>` rule of `CLAUDE.md`, and verify the pointed-to rule exists in `CLAUDE.md`
- [x] 3.4 Run `check-skills.sh` and verify 0 errors

## 4. T4: `/sdd-implement` reads the submodule rules (Docs)

- [x] 4.1 In `.claude/skills/sdd-implement/SKILL.md` step 2, add one sentence on a single line that starts with "If" and contains "exists", naming `ERAS-BE/AGENTS.md` and `ERAS-FE/AGENTS.md`, to read them for the sides the tasks touch before the first code task, and verify the line matches the optional-path rule of `check-skills.sh`
- [x] 4.2 Run `check-skills.sh` with the submodules present and from a copy without them, and verify 0 errors in both runs

## 5. F3 and the deferred-improvements document (Docs)

- [x] 5.1 Add one row to the table of `openspec/sdd-conventions.md` that says the first run of digits in a branch name or in `#<n>` is matched against `openspec/changes/<n>-*`, and that zero or several matches mean ask the user, and verify the table still renders (same number of columns in every row)
- [x] 5.2 Add `docs/sdd-improvement-proposals.md` in English and link it from the "Deferred improvements" section of `proposal.md`, and verify the file exists, that `grep` finds no reference to a `SDD-*` file outside the repository in the repo's Markdown files, and that `openspec validate` passes

## 6. Verification

- [x] 6.1 Run `bash .claude/skills/sdd-plan/tests/run-tests.sh skills` and verify every case passes
- [x] 6.2 Run `bash .claude/skills/sdd-plan/tests/check-skills.sh` and verify 0 errors
- [x] 6.3 Run `git status --short` and verify no file under `ERAS-BE/`, `ERAS-FE/` or `.github/` changed, and that no `/opsx` command file under `.claude/commands/` changed (AGENTS.md section 8.7 gates do not apply: no BE or FE code)
- [x] 6.4 Run `openspec validate "0000-improve-sdd-entry-and-rules" --strict` and verify it passes
