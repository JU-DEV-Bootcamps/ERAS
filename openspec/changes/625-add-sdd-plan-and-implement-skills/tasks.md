# Tasks

## 1. Skills

- [x] 1.1 Add `.claude/skills/sdd-plan/` with `SKILL.md`, `templates/design.md`, `templates/tasks.md` and a worked example, and verify the example passes `openspec validate --strict`
- [x] 1.2 Add `.claude/skills/sdd-plan/scripts/check-plan.sh` and verify it passes on the example and fails on each broken case
- [x] 1.3 Add `.claude/skills/sdd-implement/` with `SKILL.md`, `templates/ac-test-be.md`, `templates/ac-test-fe.md` and `templates/implementation-report.md`, and verify `SKILL.md` references each template
- [x] 1.4 Add `.claude/skills/sdd-implement/scripts/check-impl.sh` and verify it passes on a complete fixture and fails on each broken case

## 2. Tests

- [x] 2.1 Add `.claude/skills/sdd-plan/tests/run-tests.sh` covering `check-spec.sh`, `check-plan.sh` and `check-impl.sh`, and verify all cases pass

## 3. Docs

- [x] 3.1 Document both skills in `AGENTS.md` section 5.1 and in `CLAUDE.md`, and verify both files name the commands
- [x] 3.2 Point `/sdd-spec` and `/sdd-clarify` to `/sdd-plan` as the next step and verify `/opsx:propose` appears there only as the generic alternative

## 4. Align the chain with OpenSpec

- [x] 4.1 Add `AGENTS.md` section 3.3 "SDD skill conventions" and list `/sdd-validate-impl` and `/sdd-verify` in section 5.1, and verify the section names the files, Status/Plan lines, Side, AC key, task ids, validation log and definition of done
- [x] 4.2 Rewrite `.claude/skills/sdd-validate-impl/SKILL.md` to read the change folder, use numbered tasks and keep the validation log in `proposal.md`, and verify `check-skills.sh` finds no legacy layout in it
- [x] 4.3 Rewrite `.claude/skills/sdd-verify/SKILL.md` to use `check-impl.sh --final`, fill the Traceability table of `tasks.md` and end with an archive recommendation instead of `Implemented`, and verify `check-skills.sh` finds no legacy layout or dangling path in it
- [x] 4.4 Add `.claude/skills/sdd-plan/tests/check-skills.sh` and write its test cases in `run-tests.sh` (aligned skills pass; legacy layout, name mismatch, dangling path and undocumented skill fail), and verify the new cases pass
- [x] 4.5 Run `check-skills.sh` on the real skills and verify it reports no errors

## 5. Verification

- [x] 5.1 `openspec validate --changes --strict` passes
- [x] 5.2 `bash .claude/skills/sdd-plan/tests/run-tests.sh` passes with every case ok

## Follow-ups

- The skills are set up but not used yet. When the first real issue arrives, run `/sdd-spec` → `/sdd-clarify` → `/sdd-plan` → `/sdd-implement` → `/sdd-validate-impl` → `/sdd-verify` on it and adjust the skills from what is observed, in its own change.
- The self-test takes about 5 minutes on Windows (many child processes) and does not run in CI. Wiring it into a workflow is a CI change with its own spec.
- No `eras-fe-test` skill exists in `ERAS-FE` or `ERAS-BE`. If the frontend team adds one, `/sdd-implement` already follows it when present.
