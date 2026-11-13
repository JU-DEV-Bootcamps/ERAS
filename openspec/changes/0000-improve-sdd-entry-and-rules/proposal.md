# Proposal

**Status:** Approved

## Why

The SDD flow has two gaps that only need text, not tooling. First, no document says what to do when someone writes only `#675`, so the agent infers it differently each time. Second, `CLAUDE.md` still tells the agent to create changes with `/opsx:propose` and implement with `/opsx:apply`, which skip the ERAS gates (`Status`/`Plan: Approved`, AC tags, test-first evidence, section 8.7 gates), while the `/sdd-*` path is only "preferred". Also `/sdd-implement` writes code in `ERAS-BE/` and `ERAS-FE/` but never tells the agent to read those submodules' `AGENTS.md`. Issue: placeholder `0000` (no issue yet; rename the folder when it exists, before approval).

## What Changes

- **F1.** `CLAUDE.md`: add a rule for a bare `#<n>`: look for `openspec/changes/<n>-*`, then `gh issue view <n>` in `ERAS-BE`, `ERAS-FE` and the parent repo, then the current branch of each submodule; if there is more than one match, ask which.
- **F2.** `CLAUDE.md` and `AGENTS.md` section 8.5: the `/sdd-*` skills become the main path for any feature or behavior change. `/opsx:explore` is for thinking. `/opsx:propose` and `/opsx:apply` are kept only for `skip_specs` changes. The line "stop for human approval" and "do not edit `ERAS-BE/` or `ERAS-FE/` until the change is approved" stay as they are.
- **T4.** `.claude/skills/sdd-implement/SKILL.md` step 2: read `ERAS-BE/AGENTS.md` and/or `ERAS-FE/AGENTS.md` for the sides the tasks touch before the first code task. The sentence is written as "if the file exists" so `check-skills.sh` passes with or without the submodules checked out.
- **F3.** `openspec/sdd-conventions.md`: one row that says how a branch or `#<n>` maps to a change (first run of digits in the branch name, matched against `openspec/changes/<n>-*`).
- **T8.** `AGENTS.md` section 8.5: a three-row "Which command when" table (feature or behavior change: `/sdd-spec` to `/sdd-archive`; no behavior change: `/opsx:propose` with `skip_specs`; thinking only: `/opsx:explore`) and one sentence that points to the `#<n>` rule of `CLAUDE.md`. Only lines are added; no row or heading is removed or renumbered.

**Prepares change `0001-add-sdd-checks-ci`:** nothing here depends on CI, and nothing here may stop `check-skills.sh` from passing on a runner without submodules (T4 wording). Both changes ship in one PR but are implemented in separate commits (one per task group) so any group can be reverted on its own.

**Out of scope:** everything in "Deferred improvements" below, and any edit under `ERAS-BE/`, `ERAS-FE/` or `.github/`. This change only edits text (`CLAUDE.md`, `AGENTS.md`, one `SKILL.md`, `sdd-conventions.md`); it adds no skill, script, agent, hook or workflow.

## Deferred improvements (not lost)

These came out of the review of the SDD flow (`SDD-PROPUESTAS-MEJORA.md`, ids kept). They are not part of this change; each is meant for a later change. The change ids are placeholders, to be renamed when their issues exist.

| Later change | Improvements | Why it is not here |
|---|---|---|
| `0001-add-sdd-checks-ci` | **F5** CI workflow for the SDD checks | A pipeline change, with its own risk (see its proposal). Already drafted |
| `0002-add-sdd-entry-skills` | **N1** `/sdd-start`, **N2** `/sdd-status`, **F4 / N3** `/sdd-chore`, **S1** `resolve-change.sh`, **S6** `check-all.sh` | New skills and scripts; each needs its own tests and an entry in `AGENTS.md` section 8.5 (`check-skills.sh` requires it) |
| `0003-add-sdd-pr-skills` | **N4** `/sdd-pr`, **N5** `/sdd-review-feedback` | New skills |
| `0004-add-tech-skills` | **T1** `eras-fe-test` and `eras-be-test`, **T2** golden-path scaffolding skills, **T3** `eras-migration`, **T5** extend `check-skills.sh` to the submodules' skills | They live in `ERAS-BE/` and `ERAS-FE/`, so they need submodule branches and PRs |
| `0005-improve-sdd-scripts` | **S2** `check-impl.sh --run`, **S3** two AC keys in one test, **S4** `check-spec.sh` improvements, **S5** parallel `run-gates.sh`, **S7** split `run-tests.sh` for CI | Script changes; each needs a case in `run-tests.sh` |
| `0006-add-sdd-agents-hooks-loops` | **T6** read-only reviewer subagents, **T7** approval hook, **L1-L4** loops with stop conditions | Change how the agent runs, so they need their own review |
| Housekeeping (human) | **F6** normalize the state of changes `571`, `578`, `642` and `660` | Edits other changes' files; needed before `0001` makes any check blocking |

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Submodules:** none (parent repo only)
- **Files:** `CLAUDE.md`, `AGENTS.md` (section 8.5), `.claude/skills/sdd-implement/SKILL.md`, `openspec/sdd-conventions.md`
- **Roles / who can do what:** no change
- **API contract:** none
- **Data / migration:** none
- **Risk:** low. Checked on a scratch copy: with the T4 line and a reworded `CLAUDE.md`, `check-skills.sh` still reports 0 errors. `check-skills.sh` requires that every `/sdd-*` skill stays listed in `AGENTS.md` and that every cited `§` section stays a heading, so those must not be removed. The `/opsx:*` commands stay installed (`openspec update` regenerates them), so nothing is deleted.
- **Rollback:** one commit per task group, so `git revert <commit>` undoes one group without touching the others.

No behavior changes, so this change sets `skip_specs: true` (AGENTS.md section 3, tooling and docs).
