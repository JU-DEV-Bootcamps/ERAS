# Tasks

## 1. Scripts for sdd-verify

- [x] 1.1 Add `.claude/skills/sdd-verify/scripts/verify-gate.sh`, add it to `allowed-tools` and step 2 of `.claude/skills/sdd-verify/SKILL.md`, and verify it passes on a complete change and fails on an unchecked task (checked by hand on 2026-10-28 against changes 635, 571, 628, a missing id and a temporary change with an open task)
- [x] 1.2 Add test cases for `verify-gate.sh` to `.claude/skills/sdd-plan/tests/run-tests.sh` (clean change passes; unchecked task fails; struck-through task is ignored; unapproved `Status` or `Plan` warns; missing validation log warns), and verify they pass
- [x] 1.3 Add a gates runner script under `.claude/skills/sdd-verify/scripts/` that runs the §8.7 gates of the touched sides and prints one pass or fail line per gate plus the first error lines of a failing one, and verify it reports a passing gate, a failing gate and an unrunnable gate distinctly
- [x] 1.4 Wire the gates runner into step 4 of `.claude/skills/sdd-verify/SKILL.md` and its `allowed-tools`, and verify `check-skills.sh` finds no dangling path

## 2. Model per skill

- [x] 2.1 Add `model: haiku` to the frontmatter of `.claude/skills/sdd-validate-impl/SKILL.md`, and verify `check-skills.sh` still passes
- [x] 2.2 Run the trial: invoke `/sdd-validate-impl` headless from a session on another model and read `modelUsage` from the JSON output, and record in `proposal.md` whether the skill ran on Haiku
- [x] 2.3 If 2.2 shows the field applies, add `model` to the other `sdd-*` skills by the approved *Model criteria*, and verify every pinned value is accepted (`check-skills.sh` and one headless call per changed skill)

## 3. Docs

- [x] 3.1 Add the new scripts to the Checks row of `AGENTS.md` §8.4 and note that a `model` pin overrides the session model for the skill's turn, and verify `check-skills.sh` finds every skill and script documented

## 4. Verification

- [x] 4.1 `openspec validate 653-adjust-skills-for-token-usage --strict` passes
- [x] 4.2 `bash .claude/skills/sdd-plan/tests/check-skills.sh` reports no errors
- [x] 4.3 `bash .claude/skills/sdd-plan/tests/run-tests.sh` passes with every case ok, run from a checkout path without spaces (see Follow-ups)

## Follow-ups

- `run-tests.sh` builds its commands in unquoted variables (`plan="bash $skills/..."`), so it fails on a repository path with spaces such as `ERAS application`: 55 of 70 cases fail with exit 127 before running the script. Quote the commands in its own change.
- A script that suggests validate or skip for `sdd-validate-impl` (grep `design.md` "Changes by layer" for controller and FE mentions) is a heuristic and was left out; revisit after the model trial.
- An org `availableModels` allowlist makes a pinned `model` fall back to the session model silently; check it before relying on a pin.
