# Tasks

## 1. ADR store

- [x] 1.1 Add `openspec/adr/README.md` with the index table grouped by Area and the naming, status and supersede rules, and verify it lists every ADR file
- [x] 1.2 Add `openspec/adr/0001-use-openspec-for-spec-driven-development.md` from the template with `Status: Proposed`, and verify it has every required section

## 2. Skill

- [x] 2.1 Add `.claude/skills/sdd-adr/` with `SKILL.md` (create, supersede, index update, Proposed only, never commits) and `templates/adr.md`, and verify `SKILL.md` references the template and the checker
- [x] 2.2 Add `.claude/skills/sdd-adr/scripts/check-adr.sh` and verify it passes on `openspec/adr/` and fails on each broken case (duplicate or skipped number, bad file name, missing section, bad Status or Area, index out of sync, one-way supersede)

## 3. Workflow integration

- [x] 3.1 Update `.claude/skills/sdd-plan/SKILL.md` and `templates/design.md` with the ADR-candidate rule and the optional `**ADR:**` line, and verify `check-plan.sh` still passes on the worked example
- [x] 3.2 Update `.claude/skills/sdd-verify/SKILL.md` to check that every linked `ADR-NNNN` exists and is Accepted before recommending archive, and verify `check-skills.sh` finds no dangling path in it

## 4. Tests

- [x] 4.1 Add the `check-adr.sh` cases to `.claude/skills/sdd-plan/tests/run-tests.sh`, and verify all cases pass

## 5. Docs

- [x] 5.1 Update `AGENTS.md`: §0 map row for `openspec/adr/`, the ADR step in §3.2, the ADR conventions in §3.3 and `/sdd-adr` in the §5.1 skills table, and verify `check-skills.sh` finds `/sdd-adr` documented
- [x] 5.2 Update `CLAUDE.md` to mention `/sdd-adr` in the spec-first path, and add the ADR rule to the `design` rules in `openspec/config.yaml`; verify `openspec validate --changes --strict` still passes

## 6. Verification

- [x] 6.1 `openspec validate --changes --strict` passes
- [x] 6.2 `bash .claude/skills/sdd-plan/tests/check-skills.sh` reports no errors
- [x] 6.3 `bash .claude/skills/sdd-plan/tests/run-tests.sh` passes with every case ok

## Follow-ups

- Backfill ADRs for decisions already in place (Onion architecture in ERAS-BE, Keycloak client roles and `ErasPolicies`, Angular standalone + signals golden path, PostgreSQL + EF Core), each one through `/sdd-adr`.
