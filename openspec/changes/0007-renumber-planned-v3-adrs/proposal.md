# Proposal

**Status:** Approved

## Why

ADR-0012 and later documents cite three ADRs that are not written yet as ADR-0015, ADR-0016 and ADR-0017. ADR-0014 was never written or cited: there is no file, and no mention in any branch or in the git history of the parent repository, `ERAS-BE`, `ERAS-FE` or `ERAS-FE-React`. `check-adr.sh` fails on a numbering gap, and `/sdd-adr` numbers a new ADR as the highest number plus one. So the first of the three ADRs will be ADR-0014, and the current references point to the wrong numbers. This must be fixed now, before the first port of an Angular module to v3 (Home) writes them. Issue: none (placeholder `0007`; rename the folder when an issue exists, before approval).

## What Changes

- **Renumber the three planned ADRs**, keeping their order:

  | Today | After | Decision |
  |---|---|---|
  | ADR-0015 | ADR-0014 | API client generated from the backend OpenAPI document (Orval) and its adapters |
  | ADR-0016 | ADR-0015 | State and layers of v3 |
  | ADR-0017 | ADR-0016 | UI library of v3 |

  The replacement runs from low to high (0015 → 0014, then 0016 → 0015, then 0017 → 0016), so no reference is renamed twice.
- **Files with references (39 in all):**
  - parent repository:
    - `openspec/adr/0012-adopt-react-as-the-second-web-client-and-its-stack.md` (lines 16 and 32);
    - `openspec/changes/0004-add-eras-fe-react-foundation/proposal.md`;
    - `openspec/changes/0006-add-eras-fe-react-agent-tooling/proposal.md` and `tasks.md`;
  - `ERAS-FE-React`:
    - `AGENTS.md`;
    - `.claude/skills/eras-fe-react-feature/SKILL.md`;
    - `.claude/skills/eras-fe-react-review/SKILL.md`.
- **Erratum in ADR-0012 (Accepted).** An Accepted ADR is never rewritten. Here only the number of a cross-reference to an ADR that does not exist changes, on lines 16 and 32; the decision, its alternatives and its consequences stay the same. The user approved this erratum on 2026-11-19. No new ADR supersedes ADR-0012 for it, because that ADR would itself take number 0014.

**Out of scope:**
- Writing ADR-0014, ADR-0015 or ADR-0016 (each comes later with `/sdd-adr`).
- The unnumbered "v2/v3 relationship ADR" that ADR-0012 line 29 mentions, which stays as it is.
- Archived changes, which cite none of these numbers.
- `openspec/adr/README.md` and `SUMMARY.md`, which have no row for these ADRs yet.
- Any change to `ERAS-BE/` or `ERAS-FE/`.

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Sides / submodules:**
  - `ERAS-FE-React`: three documentation files. It is a local repository with no remote yet, so its commit stays local.
  - The parent repository: ADR-0012 and the proposals and tasks of changes 0004 and 0006.
  - `ERAS-BE` and `ERAS-FE`: not touched.
- **Roles / who can do what:** no change.
- **API contract:** none.
- **Data / migration:** none.
- **Risk (low):** text-only edits. One check before and after: no `ADR-0017` is left outside the archive, and `check-adr.sh` and `openspec validate --all --strict` pass.
- **Rollback:** one commit in the parent repository and one in `ERAS-FE-React`, each revertible on its own.

No behavior of ERAS changes, so this change sets `skip_specs: true` (AGENTS.md section 8.1, docs).

## Validation log

- Skipped: no BE controller or FE change (ADR numbers in documentation only; no screen or behavior of a web client changed).
- Verified 2026-11-19: no gaps, no drift, gates green
