# Tasks

Each group below is one commit, so one group can be reverted without touching the others. For every script, the
`run-tests.sh` case comes first and must fail before the script is changed.

## 1. Baseline (Infra)

- [x] 1.1 Record the submodule pointers (`git submodule status`) and keep them unchanged until group 6, and verify they are `ERAS-BE 8bddb0c9` and `ERAS-FE 01552be5` or note the new ones
- [x] 1.2 Run `check-spec.sh` (non-`skip_specs` changes only), `check-plan.sh`, `check-impl.sh` and `check-adr.sh --change` on every active change, `check-adr.sh`, `check-skills.sh` and `openspec validate --all --strict`, and save each output to a baseline file outside the repository, and verify every command ran (exit code recorded)
- [x] 1.3 For every AC of every active change and living spec, record the number of tagged BE and FE tests with today's §8.6 logic, and verify the totals are 127 FE and 109 BE at the pointers of 1.1
- [x] 1.4 Run `bash .claude/skills/sdd-plan/tests/run-tests.sh` and record the result, and verify it passes before any edit

## 2. Registry and reader (Infra)

- [x] 2.1 Add the `run-tests.sh` cases for the reader (a registry with `BE`, `FE`, `FE-React`; `**Side:** FE + FE-React` gives two sides; `FE-React` never matches `FE`; an unknown or repeated name is reported; a comment or blank line in the registry is ignored), and verify they fail because the reader does not exist
- [x] 2.2 Create `openspec/sides.conf` with the three entries of the proposal and a header comment that explains each column, and verify the `BE` and `FE` gate commands are byte for byte the ones in `run-gates.sh` today
- [x] 2.3 Create `.claude/skills/sdd-shared/sides.sh` (list sides, read one field of a side, split a `**Side:**` value, check that a value uses only registered sides), and verify the cases of 2.1 pass

## 3. Check scripts (Infra)

- [x] 3.1 Add the `run-tests.sh` cases for `check-spec.sh` (accepts `FE-React` and `FE + FE-React`; rejects `FE-Angular`, `FE + FE`), and verify they fail
- [x] 3.2 Change `check-spec.sh` to validate `**Side:**` with the reader, and verify the cases of 3.1 and the existing `spec` section of `run-tests.sh` pass
- [x] 3.3 Add the `run-tests.sh` cases for `check-plan.sh` (a Traceability row `FE-React` is expected only when the spec declares it; a spec `FE-React` does not ask for an `FE` row), and verify they fail
- [x] 3.4 Change `check-plan.sh` to read sides with the reader and to accept a task group named by any registered side, and verify the cases of 3.3 and the existing `plan` section pass
- [x] 3.5 Add the `run-tests.sh` cases for `check-impl.sh` (AC `FE-React` only: no Angular test asked for; Angular test tagged with that AC: error; `FE + FE-React`: one test per side; two React tests for one AC: error; `.only(` or `.skip(` in a tagged React file: error; `ERAS-FE-React/` missing: the AC is reported as having no test, no crash), and verify they fail
- [x] 3.6 Change `check-impl.sh` to count, list undeclared tags and find focused or skipped tests per registered side from the registry, and verify the cases of 3.5 and the existing `impl` section pass
- [x] 3.7 Add the `run-tests.sh` cases for `run-gates.sh` (`--fe` runs only the 3 FE gates; `--side FE-React` runs only the 4 FE-React gates; a spec `FE-React` does not run FE gates; a missing submodule is `UNRUNNABLE`), and verify they fail
- [x] 3.8 Change `run-gates.sh` to take its gates from the registry, with `--side <name>` repeatable and `--be` / `--fe` as aliases, and verify the cases of 3.7 and the existing `gates` section pass
- [x] 3.9 Add the `run-tests.sh` cases for `check-archive.sh` (a spec `FE-React` asks for the `ERAS-FE-React` pointer and not for `ERAS-FE`), and verify they fail
- [x] 3.10 Change `check-archive.sh` to take the submodule of each declared side from the registry, and verify the cases of 3.9 and the existing `archive` section pass
- [x] 3.11 Add the `run-tests.sh` case for `check-skills.sh` (a skill that cites an existing `ERAS-FE-React/...md` path passes), and verify it fails
- [x] 3.12 Change `check-skills.sh` to allow the submodule folders of the registry, and verify the case of 3.11 and the existing `skills` section pass

## 4. Parity report (Infra)

- [x] 4.1 Add the `run-tests.sh` cases for `check-parity.sh` (an AC `FE` only is listed as missing `FE-React`, and the other way round; `FE + FE-React` and `BE` only are not listed; the exit code is always 0), and verify they fail
- [x] 4.2 Create `.claude/skills/sdd-shared/check-parity.sh` for every parity group of the registry, over living specs and active changes, and verify the cases of 4.1 pass

## 5. Rules (Infra)

- [x] 5.1 Update `AGENTS.md` §2.1, §2.2, §4.3, §5.1, §5.2, §5.3, §8.6, §8.7 and §9 as listed in the proposal, without renaming or removing any heading, and verify `check-skills.sh` still passes (it requires every cited section to be a heading)
- [x] 5.2 Update `openspec/config.yaml` (`context`, `rules.proposal`), `openspec/sdd-conventions.md` (AC row) and `CLAUDE.md` (submodule list, `#<n>` lookup) to point to the registry, and verify `openspec instructions proposal --change 0003-support-multiple-frontend-clients` shows the new context
- [x] 5.3 Update the `/sdd-*` `SKILL.md` files and their templates and examples so sides come from the registry and Angular-only guidance is labelled `FE`, and verify `check-skills.sh` passes and a search for `ERAS-FE/src/app` and `\*\.spec\.ts` outside `ERAS-FE/` only finds lines labelled `FE` or the registry
- [x] 5.4 Review ADR-0011 "Declare the SDD sides in one registry" (written with `/sdd-adr` when this change was proposed) against what groups 2 to 4 built (Status `Proposed`, Change `0003-support-multiple-frontend-clients`), and verify `check-adr.sh --change 0003-support-multiple-frontend-clients` passes

## 6. Verification

- [x] 6.1 Rerun every command of 1.2 and 1.3 on the same pointers and compare with the baseline, and verify the `BE` and `FE` results are identical (any difference is explained and approved by the reviewer, or fixed)
- [x] 6.2 Run `bash .claude/skills/sdd-plan/tests/run-tests.sh` and verify every section passes
- [x] 6.3 Run `bash .claude/skills/sdd-shared/check-parity.sh` on the current specs and verify it exits 0 and lists every `FE` AC as missing `FE-React`
- [x] 6.4 Run `git status --short` and `git -C ERAS-FE status --short` / `git -C ERAS-BE status --short`, and verify no file under `ERAS-FE/`, `ERAS-BE/` or `.github/` was changed by this change (AGENTS.md section 8.7 gates do not apply: no BE or FE code)
- [x] 6.5 Run `openspec validate 0003-support-multiple-frontend-clients --strict` and `openspec validate --all --strict`, and verify both pass
