---
name: sdd-archive
description: Archives a verified ERAS OpenSpec change as the last commit of its parent-repo ship PR, before that PR merges. Checks the gate (every task ticked, a Verified line from /sdd-verify, linked ADRs Accepted, bumped submodule pointers merged), runs openspec archive (with --skip-specs for tooling and docs changes), validates the living specs and lists the files to commit. Use after /sdd-verify recommends archiving and the ship PR is approved, or when the user says "archive the change". Never commits.
allowed-tools: Bash(openspec:*) Bash(bash .claude/skills/sdd-archive/scripts/check-archive.sh:*) Bash(bash .claude/skills/sdd-adr/scripts/check-adr.sh:*)
model: haiku
---

Close a change **inside the PR that ships it**, so nothing is left for after the merge. The archive moves
`openspec/changes/<change-id>/` to `openspec/changes/archive/<date>-<change-id>/` and merges its deltas into
`openspec/specs/`. Rules: `AGENTS.md` §8.3 (step 6), §8.4 (conventions in `openspec/sdd-conventions.md`) and §8.7.

**Boundary.** Run `openspec archive` and nothing else that writes. Do NOT edit tasks, specs, ADRs or code to get
past the gate; send the user back to the skill that owns the problem. Do NOT commit or push. Never read or print
secrets (`.env`, `deploy/.env.prod`, `environment.development.ts`, keys in `appsettings*.json`).

**Checker:** `bash .claude/skills/sdd-archive/scripts/check-archive.sh <change-id>` (from the repo root).

## When

- **BE/FE change:** the submodule PRs are merged and the parent-repo ship PR (spec, ADRs, pointer bump) is
  approved. The archive is its last commit.
- **Tooling or docs change** (`skip_specs: true`, no submodule work): the change's own PR is the ship PR; archive
  once it is approved.
- Archive after the approval, not before: review feedback after an archive would mean editing the archived folder.

## Steps

1. **Find the change.** Use the id the user gave, else `openspec list` (ask if several). Read `.openspec.yaml`,
   `proposal.md` and `tasks.md` from disk.

2. **Refresh the refs.** Run `git fetch` in the parent repo and in each submodule the change touched, so the
   pointer check sees the merged submodule commits.

3. **Check the gate.** Run `bash .claude/skills/sdd-archive/scripts/check-archive.sh "<change-id>"`.
   - Unchecked task → `/sdd-implement`. No `Verified` line → `/sdd-verify`. Linked ADR not Accepted → a human
     accepts it, or `/sdd-plan` and `/sdd-adr`. Pointer not merged or not bumped → merge the submodule PR and bump
     the pointer to the merged commit in the ship PR.
   - Stop on any error. Report warnings (for example an uncommitted ADR) and make sure the files they name end up
     in the commit.

4. **Confirm the approval.** Ask the user whether the ship PR is approved, or check it with
   `gh pr view --json reviewDecision` when `gh` is available. Not approved → stop: archive after approval.

5. **Archive.**
   - `skip_specs: true` → `openspec archive "<change-id>" --yes --skip-specs`.
   - Otherwise → `openspec archive "<change-id>" --yes`.
   Report the real output. If the CLI refuses, stop and report; never move the folder by hand.

6. **Validate.** Run `openspec validate --all --strict`: the living specs and the remaining changes must still be
   valid after the deltas merge. A failure is reported, not fixed here.

7. **Stop and report.** Give: the archive folder, the specs that changed in `openspec/specs/`, the validation
   result, and the files to commit as the **last commit of the ship PR** (`git status --short openspec/`): the
   removed change folder, the new archive folder, the changed specs and any ADR file still uncommitted. Suggested
   message: `docs: archive <change-id>`. Next step: the user commits, pushes and merges the ship PR.

## Guardrails

- Never archive with open tasks, without a `Verified` line, or before the ship PR is approved.
- Never commit, push or merge; the developer does.
- Never move, rename or edit files under `openspec/changes/archive/` by hand.
- `/opsx:archive` is the generic alternative; it skips the ERAS gate, so prefer this skill.
