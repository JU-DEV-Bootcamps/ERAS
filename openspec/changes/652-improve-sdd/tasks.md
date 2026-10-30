# Tasks

## 1. Agent definition per sub-project

- [x] 1.1 Write `ERAS-BE/AGENTS.md` and `ERAS-BE/CLAUDE.md` (`@AGENTS.md` only) with the text of root §3.2, §4.1, §6.1–6.3 under the same section numbers and no relative link to the parent (D1, D2); verify the headings match the root ones
- [x] 1.2 Write `ERAS-FE/AGENTS.md` and `ERAS-FE/CLAUDE.md` (`@AGENTS.md` only) with the text of root §3.3, §4.2, §7.1–7.3 under the same section numbers (D1, D2); verify the headings match the root ones
- [x] 1.3 Replace the bodies of root `AGENTS.md` §3.2, §3.3, §4.1, §4.2, §6 and §7 with a pointer to the submodule file, keeping every heading, and update root `CLAUDE.md` (D1); verify `bash .claude/skills/sdd-plan/tests/check-skills.sh` still reports 0 errors
- [x] 1.4 Verify no paragraph of the moved sections exists in two files (diff root against the submodule files) and that no `AGENTS.md` heading was removed or renumbered (`git diff` of the heading lines is empty)

## 2. Slim §8 and responsibility markers

- [x] 2.1 Write `openspec/sdd-conventions.md` with the current bodies of §8.4 and §8.5 verbatim (D3); verify every row of both sections appears in it
- [x] 2.2 Cut the bodies of root §8.4 and §8.5 to the status-line rule, the "only a human approves" sentence and one line per skill (`/name`, step, pointer), list in the commit notes each removed row and where it lives, and record the new `AGENTS.md` size (34,431 characters before); verify `check-skills.sh` reports 0 errors
- [x] 2.3 Add the legend and the 🟦/🟩/🟨 markers to every §8.3 step and §8.5 row and to `openspec/sdd-conventions.md` (D4); verify each marker agrees with "only a human sets Approved/Accepted" (§8.4, §9)
- [x] 2.4 Point the skills that cite §8.4 detail to `openspec/sdd-conventions.md` where the root no longer holds it; verify `check-skills.sh` reports 0 errors

## 3. ADR review, sign-off and summary

- [x] 3.1 Write the self-test cases in the `adr` section of `.claude/skills/sdd-plan/tests/run-tests.sh` (D5, D6): `SUMMARY.md` is not parsed as an ADR; an Accepted ADR missing from the summary fails; a summary entry for a non-Accepted ADR fails; an Accepted ADR dated 2026-10-30 or later without `Signed by` fails; an older one only warns; verify they fail on the current script
- [x] 3.2 Update `.claude/skills/sdd-adr/scripts/check-adr.sh` (skip `SUMMARY.md`, summary check, sign-off check) and verify `bash .claude/skills/sdd-plan/tests/run-tests.sh adr` and `... archive` pass
- [x] 3.3 Add `**Reviewed by:**` and `**Signed by:**` to `.claude/skills/sdd-adr/templates/adr.md` and the "Review and sign-off" section with the checklist to `openspec/adr/README.md` (D5); update the ADR rows of `openspec/sdd-conventions.md` and root §8.4; verify a new ADR made from the template passes `check-adr.sh`
- [x] 3.4 Write `openspec/adr/SUMMARY.md` from the Accepted ADRs (ADR-0002, ADR-0003 today) (D6), update `/sdd-adr` (`SKILL.md`) to maintain it and `/sdd-plan` (`SKILL.md`) to read it first; verify `bash .claude/skills/sdd-adr/scripts/check-adr.sh` reports 0 errors (warnings for the unsigned ADR-0002/0003 expected)

## 4. Roadmap

- [x] 4.1 Write `openspec/roadmap.md` (D7) from the facts in `.github/workflows/`, `docker-compose*.yml`, `nginx/`, `Keycloak/`, `deploy/` (names only, never values); verify the sections: concerns table, evaluation criteria, GitHub → Azure DevOps checklist, confidential data
- [x] 4.2 Link the roadmap from root §2.2 and verify the document holds no secret value, key, private host or personal data (read it against AGENTS.md §9 "Secrets stay out")

## 5. Verification

- [ ] 5.1 Run `bash .claude/skills/sdd-plan/tests/run-tests.sh` (all sections) and `bash .claude/skills/sdd-plan/tests/check-skills.sh` and verify 0 failures
- [ ] 5.2 Run `bash .claude/skills/sdd-adr/scripts/check-adr.sh --change 652-improve-sdd` and `openspec validate "652-improve-sdd" --strict` and verify both pass
- [x] 5.3 Verify the pre-existing gates are unaffected (AGENTS.md section 8.7): the submodule PRs add only the four new files; run `npm run lint` in `ERAS-FE/` and `dotnet build Eras.sln -warnaserror` in `ERAS-BE/` as a sanity check and report the results
- [ ] 5.4 Open the `ERAS-BE` and `ERAS-FE` PRs with only the new files, linking `openspec/changes/652-improve-sdd`; after they merge, bump the parent pointers; the parent PR carries the change folder, `openspec/` files and skill edits; archive as the last commit of the ship PR (`/sdd-archive`, `--skip-specs`); verify both PRs list only the new files and the parent diff holds the change folder

## Traceability
No ACs: this change sets `skip_specs: true`. The self-test cases of task 3.1 and the checks of 5.1–5.2 are the evidence.
