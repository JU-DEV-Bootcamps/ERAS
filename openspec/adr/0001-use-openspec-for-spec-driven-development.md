# ADR-0001: Use OpenSpec for spec-driven development

**Status:** Proposed
**Date:** 2026-10-21
**Area:** process
**Change:** none

## Context

ERAS is an existing product: most work is changes and bug fixes to behavior that already exists, not new
greenfield features. Code lives in two git submodules (`ERAS-BE/`, `ERAS-FE/`) while specs must be shared by
both, so the specs live in the parent repo. The team wanted a spec-first rule with Acceptance Criteria that
map one to one to tagged tests (AGENTS.md §4), and a check that can run in CI.

## Decision

We use OpenSpec for spec-driven development. Every change starts as `openspec/changes/<change-id>/` with
delta specs whose scenarios are the ACs, passes `openspec validate --strict`, and is archived into the living
specs in `openspec/specs/` after its submodule PRs merge. The rules live in `AGENTS.md` and
`openspec/config.yaml`; the `/sdd-*` skills apply them.

## Alternatives

- GitHub Spec Kit → its per-feature branch automation conflicts with the submodule layout, and its
  feature-oriented specs fit an existing product with mostly deltas worse than OpenSpec's merge-on-archive.
- No framework (free-form specs in issues or docs) → no validation, no living specs, and no fixed scenario
  format to grep for the AC ↔ test tags.

## Consequences

- Specs stay current: each archived change merges its deltas into `openspec/specs/`.
- The fixed `#### Scenario: AC-<n>` format makes the AC ↔ test traceability check (AGENTS.md §5.4) a grep.
- Spec Kit ideas (a clarify step, contracts in the design) are layered onto OpenSpec through the `/sdd-*`
  skills and `openspec/config.yaml`, not by switching tools.
- Every change, including tooling and docs, needs a change folder (`skip_specs: true` when it has no behavior).
