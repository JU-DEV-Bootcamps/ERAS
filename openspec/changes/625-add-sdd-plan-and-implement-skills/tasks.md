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

## 4. Verification

- [x] 4.1 `openspec validate 625-add-sdd-plan-and-implement-skills --strict` passes
- [x] 4.2 The plan example passes `openspec validate --strict` and `check-plan.sh` in a scratch change

## Follow-ups

- The skills are set up but not used yet. When the first real issue arrives, run `/sdd-spec` → `/sdd-clarify` → `/sdd-plan` → `/sdd-implement` on it and adjust the skills from what is observed, in its own change.
- `/sdd-validate-impl` and `/sdd-verify` (merged in #636) assume `specs/<feature>/plan.md`, `T-n` task ids and an `Implemented` status. Align them with the OpenSpec layout (`design.md`, numbered tasks, Traceability table, `Plan` line) in their own change.
