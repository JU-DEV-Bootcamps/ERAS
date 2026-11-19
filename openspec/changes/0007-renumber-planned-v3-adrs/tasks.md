# Tasks

Group 1 is one commit in the parent repository and group 2 one commit in `ERAS-FE-React` (local, no remote yet), so each can be reverted on its own. In every file, replace in this order: `ADR-0015` → `ADR-0014`, then `ADR-0016` → `ADR-0015`, then `ADR-0017` → `ADR-0016`.

## 1. References in the parent repository

- [x] 1.1 Run `grep -rn "ADR-001[4-7]" openspec ERAS-FE-React --include=*.md` and exclude `openspec/changes/archive/` and this change folder. Verify that it shows no `ADR-0014` and only the 39 references of the proposal
- [x] 1.2 In `openspec/adr/0012-adopt-react-as-the-second-web-client-and-its-stack.md`, change only the numbers on lines 16 and 32 (the erratum of the proposal). Verify with `git diff` that no other character of the file changed
- [x] 1.3 Renumber the references in `openspec/changes/0004-add-eras-fe-react-foundation/proposal.md`, `openspec/changes/0006-add-eras-fe-react-agent-tooling/proposal.md` and `openspec/changes/0006-add-eras-fe-react-agent-tooling/tasks.md`. Verify with `git diff` that only ADR numbers changed

## 2. References in ERAS-FE-React

- [x] 2.1 Renumber the references in `ERAS-FE-React/AGENTS.md`, `ERAS-FE-React/.claude/skills/eras-fe-react-feature/SKILL.md` and `ERAS-FE-React/.claude/skills/eras-fe-react-review/SKILL.md`. Verify with `git -C ERAS-FE-React diff` that only ADR numbers changed, besides the work of change 0006 that is not committed yet
- [x] 2.2 Run `npx prettier --check AGENTS.md .claude/skills` in `ERAS-FE-React` and verify that it passes

## 3. Verification

- [x] 3.1 Run the search of task 1.1 again. Verify that no `ADR-0017` is left, and that ADR-0014, ADR-0015 and ADR-0016 appear where ADR-0015, ADR-0016 and ADR-0017 were
- [x] 3.2 Run `bash .claude/skills/sdd-adr/scripts/check-adr.sh` and `openspec validate --all --strict`, and verify that both pass
- [x] 3.3 Run `git status --short` in the parent and in every submodule. Verify that only the files of the proposal and this change folder changed, apart from the user's machine-local files and the uncommitted work of change 0006
- [x] 3.4 Run `openspec validate "0007-renumber-planned-v3-adrs" --strict` and verify that it passes
