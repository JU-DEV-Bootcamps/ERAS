# Proposal

## Why

`AGENTS.md` grew section by section and no longer has the shape the team expects of an agent guide: what ERAS is, the project documents, commands, architecture, conventions, backend, frontend, the workflow with agents and the limits. Rules for one topic are spread over several sections (backend rules in §2.1, backend tests in §4.2, backend commands in §5.2). Separately, ADRs created or linked by a change (change 627) are not required in the change's commit, so an ADR can be left out of the push. Issue: ERAS#621

## What Changes

- **Restructure `AGENTS.md`** into nine numbered sections, keeping every rule (moved, not reworded, except where a sentence must name its new section):

  | New section | Content taken from (old numbering) |
  |---|---|
  | 1. What ERAS is (1.1 Core principles) | intro, §1 |
  | 2. Project documents (2.1 Repository map, 2.2 Documents and sources of truth) | §0 table; `openspec/specs`, `openspec/adr`, README, CLAUDE.md, `openspec/config.yaml` |
  | 3. Commands (3.1 OpenSpec, 3.2 Backend, 3.3 Frontend, 3.4 Local stack) | §5.1 CLI block, §5.2, §5.3, §5.5 |
  | 4. Architecture (4.1 Backend layers, 4.2 Frontend layers, 4.3 Cross-cutting contracts) | §2.1 diagram and table, §2.2 table, §2.3 |
  | 5. Conventions (5.1 Branches, commits and submodules, 5.2 AC ↔ test mapping, 5.3 Traceability table) | §0 submodule rules, §4.1, §4.4 |
  | 6. Backend (6.1 Golden path, 6.2 Rules, 6.3 Tests — xUnit) | §2.1 golden path and rules, §4.2 |
  | 7. Frontend (7.1 Golden path, 7.2 Rules, 7.3 Tests — Jasmine/Karma) | §2.2 golden path and rules, §4.3 |
  | 8. Workflow with agents (8.1 Spec-first rule, 8.2 Change folder layout, 8.3 Workflow, 8.4 SDD skill conventions, 8.5 Slash commands and skills, 8.6 AC traceability check, 8.7 Definition of Done) | §3, §3.1, §3.2, §3.3, §5.1 command tables, §5.4, §5.6 |
  | 9. Limits | secrets, never commit or push unless asked, applied migrations and the model snapshot, out-of-scope work, what only a human does (approve, accept ADRs, archive), collected from §1, §2.1, §3 and CLAUDE.md |

- **Fix every reference** to the old numbers: the `sdd-*` skills, their templates, examples and checkers, `CLAUDE.md`, `README.md`, `openspec/config.yaml` and `openspec/adr/0001-…`. `check-plan.sh` requires the verification group to cite the Definition of Done as `8.7` instead of `5.6`. Archived changes keep their old references (history).
- **Guard the references:** `check-skills.sh` fails when a skill cites an `AGENTS.md §x` / `§x.y` (or `section x.y`) that is not a heading in `AGENTS.md`.
- **Ship ADRs with the change:**
  - §8.3 step 5 Ship and §8.4 Done: the parent-repo commit/PR of the change includes `openspec/changes/<id>/`, every ADR the change creates or links in `openspec/adr/` that is not yet committed, the `openspec/adr/README.md` index, and the Status line of any ADR it supersedes.
  - `/sdd-verify` lists those exact files in its ready-to-ship verdict, and `/sdd-adr` names them in its report.
  - `check-adr.sh --change <id>` warns when a linked ADR file, or the index, is untracked or has uncommitted changes in git.
- **Archive inside the ship PR** (folded in on 2026-10-27, at the user's request, before this change was pushed):
  - §8.3 step 6, §8.4 Done and §8.7: a change is archived as the **last commit of its parent-repo ship PR**, after that PR is approved and the submodule PRs are merged, and before the ship PR merges. No separate archive PR. For a `skip_specs` change with no submodule work, the ship PR is the change's own PR.
  - Add the project skill `/sdd-archive`. It checks the gate with `check-archive.sh`: every task ticked, a `Verified` line in `## Validation log`, linked ADRs Accepted (`check-adr.sh --change`), and each bumped submodule pointer reachable from that submodule's `origin/develop`. Then it runs `openspec archive <id> --yes` (with `--skip-specs` when `skip_specs: true`), runs `openspec validate --all --strict`, and lists the files to commit. It never commits.
  - `/sdd-verify` ends by recommending `/sdd-archive` instead of a manual archive after the merge. `openspec/config.yaml` archive guidance and `CLAUDE.md` follow. `/opsx:archive` stays as the generic alternative.
  - Once its PR is approved, this change archives itself with `/sdd-archive` as the first use of the flow.

**Out of scope:** rewording or changing any rule beyond the ADR shipping and archive timing rules, a CI job that archives or enforces archiving (follow-up), changes to the `/opsx:*` workflows, archived changes, and any change in `ERAS-BE/` or `ERAS-FE/`.

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Submodules:** none (parent repo only: `AGENTS.md`, `CLAUDE.md`, `README.md`, `.claude/skills/`, `openspec/config.yaml`, `openspec/adr/`)
- **Roles / who can do what:** no change
- **API contract:** none
- **Data / migration:** none

Builds on `623`, `625` and `627` (archived). No spec-level behavior changes, so this change sets `skip_specs: true` (AGENTS.md, spec-first rule for tooling and docs).

## Validation log

- Skipped: no BE controller or FE change (`/sdd-validate-impl` not applicable; parent repo docs and tooling only).
- Note: this branch also moves `627-add-sdd-adr-skill` into `openspec/changes/archive/`; that is change 627's own archive step (merged in #647), not 621 scope.
- Verified 2026-10-27: no gaps, no drift, gates green (`openspec validate --strict`, `check-skills.sh`, `check-adr.sh --change`, `check-impl.sh --final`, `run-tests.sh` 70/70).
