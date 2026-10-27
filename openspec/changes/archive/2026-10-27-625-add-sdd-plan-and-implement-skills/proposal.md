# Proposal

## Why

After a spec is approved there is no guided way to turn it into a plan and then into code that respects the ERAS rules (golden paths, one tagged test per AC per side, test first, §5.6 gates). `/opsx:propose` and `/opsx:apply` do it generically. Issue: ERAS#625

## What Changes

- Add the project skill `/sdd-plan`: for an Approved spec, writes `design.md` (the plan: changes by layer, API contract, authorization, test strategy) and `tasks.md` (test before implementation, Traceability table), with templates, a worked example and `check-plan.sh`.
- Add the project skill `/sdd-implement`: works through `tasks.md` in order, test first, ticks each task when its tests pass, then runs the AGENTS.md §5.6 gates and reports real results, with test and report templates and `check-impl.sh`.
- Add `tests/run-tests.sh`, a self-test of the check scripts (`check-spec`, `check-plan`, `check-impl`, `check-skills`).
- Document both skills in `AGENTS.md` §5.1 and `CLAUDE.md`, and point `/sdd-spec` and `/sdd-clarify` to `/sdd-plan` as the next step.
- Align `/sdd-validate-impl` and `/sdd-verify` (merged in #636) with the OpenSpec layout so the chain `sdd-spec → sdd-clarify → sdd-plan → sdd-implement → sdd-validate-impl → sdd-verify` works end to end. They assumed `specs/<feature>/plan.md`, `T-n` task ids, `specs/README.md` and an `Implemented` status, none of which exist in ERAS. Names, flow and audit philosophy are kept; the validation log moves from `spec.md` (a delta merged into the main specs on archive) to `proposal.md`, and "done" becomes tasks ticked, Traceability filled, §5.6 gates green and archive.
- Add `AGENTS.md` §3.3 "SDD skill conventions" as the single source for the artifact layout, Status/Plan lines, Side, AC keys, task ids, validation log and definition of done, and list the six skills in §5.1.
- Add `check-skills.sh`: a fast consistency check of the `sdd-*` skills (name equals folder, cited paths exist, no legacy layout, every skill documented in `AGENTS.md`), wired into `run-tests.sh`.

The plan lives in `design.md`, not a separate `plan.md`: the spec-driven schema requires `design.md` before it unlocks `tasks.md`, so a `plan.md` would be invisible to `openspec status` and `/opsx:apply`.

**Out of scope:** changes to `openspec/config.yaml` and to the `/opsx:*` workflows, and any change in `ERAS-BE/` or `ERAS-FE/`.

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Submodules:** none (parent repo only: `.claude/skills/`, `AGENTS.md`, `CLAUDE.md`)
- **Roles / who can do what:** no change
- **API contract:** none
- **Data / migration:** none

Depends on the conventions of change `623-add-sdd-spec-and-clarify-skills` (Status line, Side per AC, `check-spec.sh`). No spec-level behavior changes, so this change sets `skip_specs: true` (AGENTS.md section 3, tooling and docs).

## Validation log

- Skipped: no BE controller or FE change (`/sdd-validate-impl` not applicable; parent repo docs and tooling only).
- Note: verified after the fact on 2026-10-27, before archiving. The work merged to `develop` earlier; later changes (627, 621) renumbered the `AGENTS.md` sections cited above, which this change keeps as history.
- Verified 2026-10-27: no gaps, no drift, gates green (`openspec validate --strict`, `check-skills.sh`, `run-tests.sh` 70/70 on 2026-10-27).
