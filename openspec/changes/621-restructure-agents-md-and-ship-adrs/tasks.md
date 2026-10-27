# Tasks

## 1. Restructure AGENTS.md

- [x] 1.1 Rewrite `AGENTS.md` into sections 1–9 as mapped in `proposal.md`, and verify every old subsection's rules appear in the new file (diff of the rule lines shows moves only, plus the new Limits and ADR shipping text)
- [x] 1.2 Write section 9 Limits from the existing rules, and verify each limit already exists in the old `AGENTS.md` or `CLAUDE.md`

## 2. ADRs ship with the change

- [x] 2.1 Add the ADR shipping rule to §8.3 (Ship) and §8.4 (Done), and verify both name the change folder, linked ADRs, the index and superseded ADRs
- [x] 2.2 Update `.claude/skills/sdd-verify/SKILL.md` to list the files to commit in the ready verdict, and `.claude/skills/sdd-adr/SKILL.md` to name them in its report, and verify `check-skills.sh` passes
- [x] 2.3 Add the git warning (untracked or uncommitted linked ADR or index) to `check-adr.sh --change`, and write its cases in `run-tests.sh`; verify the new cases pass

## 3. References

- [x] 3.1 Update every `AGENTS.md §x.y` / `section x.y` reference in `.claude/skills/` (skills, templates, examples, checkers, tests), `CLAUDE.md`, `README.md`, `openspec/config.yaml` and `openspec/adr/0001-…` to the new numbers, and verify a grep for the old numbers outside `openspec/changes/archive/` finds none that point at a wrong section
- [x] 3.2 Change `check-plan.sh` to require `8.7` in the verification group, update the worked example and the `run-tests.sh` fixture, and verify the plan cases pass
- [x] 3.3 Add the cited-section check to `check-skills.sh` with a passing and a failing case in `run-tests.sh`, and verify the real skills pass it

## 4. Verification

- [x] 4.1 `openspec validate --changes --strict` passes
- [x] 4.2 `bash .claude/skills/sdd-plan/tests/check-skills.sh` and `bash .claude/skills/sdd-adr/scripts/check-adr.sh` report no errors
- [x] 4.3 `bash .claude/skills/sdd-plan/tests/run-tests.sh` passes with every case ok

## 5. Archive inside the ship PR

- [x] 5.1 Add `.claude/skills/sdd-archive/` with `SKILL.md` (gate, archive with or without `--skip-specs`, validate all, list files, never commits) and `scripts/check-archive.sh`, and verify `check-skills.sh` passes on it
- [x] 5.2 Write the `check-archive.sh` cases in `run-tests.sh` (complete change passes; unticked task, missing `Verified` line and a linked ADR not Accepted fail), and verify they pass
- [x] 5.3 Update `AGENTS.md` §8.3 step 6, §8.4 (chain and Done), §8.5 (`/sdd-archive` row) and §8.7, and verify they say "last commit of the ship PR, before it merges"
- [x] 5.4 Update `.claude/skills/sdd-verify/SKILL.md` to recommend `/sdd-archive`, the archive guidance in `openspec/config.yaml` and the chain in `CLAUDE.md`, and verify no doc still says to archive after the merge (outside `openspec/changes/archive/`)

## 6. Verification

- [x] 6.1 `openspec validate --changes --strict` passes
- [x] 6.2 `check-skills.sh` and `check-adr.sh` report no errors
- [x] 6.3 `bash .claude/skills/sdd-plan/tests/run-tests.sh` passes with every case ok

## Follow-ups

- A CI check that fails a parent-repo ship PR when a change with every task ticked is not archived. A CI change with its own spec.
- `check-archive.sh` has no fixture for the submodule-pointer check (it needs nested git repos); it is exercised on real changes.
