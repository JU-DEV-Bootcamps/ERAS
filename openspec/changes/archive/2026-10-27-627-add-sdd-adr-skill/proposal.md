# Proposal

## Why

Architectural decisions in ERAS are recorded only in each change's `design.md` (`## Decisions`, D1..Dn). Those decisions are archived with the change. Durable choices that outlive one change, such as the Onion layering, Keycloak client roles, OpenSpec as the SDD framework, or a departure from the golden path, have no permanent, citable home and no way to be superseded explicitly. Issue: ERAS#627

## What Changes

- Add `openspec/adr/`: one Architecture Decision Record per decision, in a flat folder, named `NNNN-<kebab-title>.md` and numbered from `0001`. Numbers are never reused.
- Add `openspec/adr/README.md`: the index (number, title, status, area, superseded by), grouped by `Area` (`backend`, `frontend`, `auth`, `data`, `infra`, `process`). Grouping is a view in the index, not a folder or a multi-decision file.
- Add the project skill `/sdd-adr`. It creates an ADR from a template (Status, Date, Area, Change, Context, Decision, Alternatives, Consequences), assigns the next number, updates the index, and supersedes an earlier ADR on request. When it supersedes, the new ADR gets `Supersedes ADR-NNNN` and the old one gets `Status: Superseded by ADR-MMMM`; nothing else in an Accepted ADR is edited. The skill writes `Status: Proposed`; only a human sets `Accepted`. It can be run from `/sdd-plan` or on its own, and it never commits.
- Add `.claude/skills/sdd-adr/scripts/check-adr.sh`. It checks unique, sequential numbers, file names, required sections, valid Status and Area values, that the index matches the files, and that supersede links go both ways. Wire it into `run-tests.sh` with passing and failing cases.
- Update `/sdd-plan`: in `design.md` → Decisions, flag a decision as an ADR candidate when it is architectural (a new dependency or pattern, an auth or role model, a data storage choice, a cross-cutting BE↔FE contract, a departure from the AGENTS.md golden path). Link it as `ADR-NNNN` and offer `/sdd-adr`. Add an optional `**ADR:**` line to the D-block in `templates/design.md`.
- Update `/sdd-verify`: every `ADR-NNNN` that `design.md` links must exist and be `Accepted` before archiving is recommended.
- Docs: add the ADR conventions to `AGENTS.md` §3.3, list `/sdd-adr` in §5.1, add `openspec/adr/` to the §0 repository map and the §3.2 workflow, and mention `/sdd-adr` in `CLAUDE.md`. Add an ADR line to the `design` rules in `openspec/config.yaml`.
- Seed `openspec/adr/0001-use-openspec-for-spec-driven-development.md` (Status: Proposed) to record the decision already taken on 2026-10-21, so the template and checker have a real example.

**Out of scope:** backfilling ADRs for other existing architecture (listed as a follow-up), changes to the `/opsx:*` workflows, and any change in `ERAS-BE/` or `ERAS-FE/`.

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Submodules:** none (parent repo only: `.claude/skills/`, `openspec/adr/`, `openspec/config.yaml`, `AGENTS.md`, `CLAUDE.md`)
- **Roles / who can do what:** no change
- **API contract:** none
- **Data / migration:** none

Builds on the conventions of `623-add-sdd-spec-and-clarify-skills` and `625-add-sdd-plan-and-implement-skills`. No spec-level behavior changes, so this change sets `skip_specs: true` (AGENTS.md section 3, tooling and docs).
