# Proposal

## Why

The `sdd-*` skills spend tokens on work that does not need the model: re-deriving mechanical rules ("is every task ticked?", "is the plan approved?") and reading the full output of builds and test runs (`dotnet test`, Karma) just to learn pass or fail. Every skill also runs on the session model, whether the step is mechanical (`sdd-archive`) or design-heavy (`sdd-plan`). Issue: ERAS#653

## What Changes

- Move mechanical checks of `sdd-verify` into bash scripts that print a short result, as `check-plan.sh` and `check-impl.sh` already do:
  - `verify-gate.sh`: tasks ticked, `Status` and `Plan` approved, `## Validation log` has an approval or a skip.
  - A gates runner: runs the AGENTS.md §8.7 gates of the sides the change touches and reports only pass or fail per gate, with the first error lines of a failing one.
- Judgment stays with the model and the developer: whether a test really proves its AC, drift against the spec and `design.md`, the verdict. The scripts only gate and summarize.
- Pin a model per skill with the documented `model` frontmatter field (alias or full ID; it applies to the turn of the skill and the session model resumes afterwards):
  - First trial on `sdd-validate-impl` with the `haiku` alias, which follows the current Haiku instead of pinning an ID. The trial runs the skill from a session on another model and reads `modelUsage` from the headless JSON output (`claude -p ... --output-format json`), the only documented way to see which model ran.
  - If the trial shows the field applies, extend it to the other `sdd-*` skills by the criteria in *Model criteria* below.
- Document the new scripts and the model convention in `AGENTS.md` §8.4 (Checks row) and keep `check-skills.sh` green.

### Model criteria (to approve)

| Kind of step | Skills | Model |
|---|---|---|
| Mechanical or checklist driven | `sdd-archive`, `sdd-validate-impl` | `haiku` (pinned) |
| Everything else | `sdd-spec`, `sdd-clarify`, `sdd-plan`, `sdd-implement`, `sdd-verify`, `sdd-adr` | no pin: the session model |

Outcome (2026-10-28): after the trial, only the two mechanical skills are pinned. The design-heavy and judgment skills stay on the session model, so the developer keeps choosing it with `/model`.

The exact values are for the reviewer to confirm. A pinned `model` overrides the user's `/model` choice for that skill's turn, so each pin is a deliberate trade of flexibility for cost.

**Out of scope:** fixing `run-tests.sh` for repository paths with spaces (see Follow-ups), a script for the validate-or-skip decision of `sdd-validate-impl`, and any change in `ERAS-BE/` or `ERAS-FE/`.

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Submodules:** none (parent repo only: `.claude/skills/`, `AGENTS.md`)
- **Roles / who can do what:** no change
- **API contract:** none
- **Data / migration:** none

No spec-level behavior changes, so this change sets `skip_specs: true` (AGENTS.md §8.1, tooling and docs).

## Validation log

- Trial of task 2.2, 2026-10-28: an attempt launched from the agent session (`claude -p "/sdd-validate-impl ..." --model sonnet --output-format json`) failed before running anything (`Credit balance is too low`, empty `modelUsage`). The developer repeated it from their own terminal and reported that `sdd-validate-impl` ran on Haiku, so the `model` frontmatter field applies. The JSON output was not attached to this change.
- Decision after the trial: `model: haiku` is also set on `sdd-archive`; the other `sdd-*` skills stay without a pin (task 2.3).
- 2026-10-28 – Skipped: no BE controller or FE change (`/sdd-validate-impl` not applicable; parent repo skills, scripts and docs only).
- Verified 2026-10-28: no gaps, no drift, gates green (`openspec validate --strict`, `verify-gate.sh`, `check-impl.sh --final`, `check-adr.sh --change`, `check-skills.sh`; `run-tests.sh` 90/90 from a path without spaces, then the skills, verify and gates sections again on the final files: 15, 12 and 8 ok). Caveats: `run-gates.sh` was tested with stubbed `dotnet`, `npm`, `openspec` and `reportgenerator`, not against the real builds; the `modelUsage` output of the trial was reported by the developer and not attached; the changes shown in `ERAS-BE` and `ERAS-FE` belong to change `635-allow-reassign-intervention-professional`, not to this one.

Note: `verify-gate.sh` and its wiring in `.claude/skills/sdd-verify/SKILL.md` were written on 2026-10-28 before this change existed. They are brought under it as task 1.1, and the change is the review point for them.
