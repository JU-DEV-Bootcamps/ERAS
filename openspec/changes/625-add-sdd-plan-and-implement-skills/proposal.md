# Proposal

## Why

After a spec is approved there is no guided way to turn it into a plan and then into code that respects the ERAS rules (golden paths, one tagged test per AC per side, test first, §5.6 gates). `/opsx:propose` and `/opsx:apply` do it generically. Issue: ERAS#625

## What Changes

- Add the project skill `/sdd-plan`: for an Approved spec, writes `design.md` (the plan: changes by layer, API contract, authorization, test strategy) and `tasks.md` (test before implementation, Traceability table), with templates, a worked example and `check-plan.sh`.
- Add the project skill `/sdd-implement`: works through `tasks.md` in order, test first, ticks each task when its tests pass, then runs the AGENTS.md §5.6 gates and reports real results, with test and report templates and `check-impl.sh`.
- Add `tests/run-tests.sh`, a self-test of the three check scripts (`check-spec`, `check-plan`, `check-impl`).
- Document both skills in `AGENTS.md` §5.1 and `CLAUDE.md`, and point `/sdd-spec` and `/sdd-clarify` to `/sdd-plan` as the next step.

The plan lives in `design.md`, not a separate `plan.md`: the spec-driven schema requires `design.md` before it unlocks `tasks.md`, so a `plan.md` would be invisible to `openspec status` and `/opsx:apply`.

**Out of scope:** changes to `openspec/config.yaml`, to the `/opsx:*` workflows, to `/sdd-validate-impl` and `/sdd-verify` (they assume another layout and need their own change), and any change in `ERAS-BE/` or `ERAS-FE/`.

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Submodules:** none (parent repo only: `.claude/skills/`, `AGENTS.md`, `CLAUDE.md`)
- **Roles / who can do what:** no change
- **API contract:** none
- **Data / migration:** none

Depends on the conventions of change `623-add-sdd-spec-and-clarify-skills` (Status line, Side per AC, `check-spec.sh`). No spec-level behavior changes, so this change sets `skip_specs: true` (AGENTS.md section 3, tooling and docs).
