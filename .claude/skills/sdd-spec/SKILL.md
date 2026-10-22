---
name: sdd-spec
description: Creates or updates the spec (a delta spec.md plus a lean proposal.md) of an ERAS OpenSpec change from an idea or request. Use when the user asks for a new feature, a behavior change, a bug fix with observable behavior, or says "write the spec for X". Does not write code, design.md or tasks.md.
allowed-tools: Bash(openspec:*)
---

Turn an idea into a **Draft spec** that a human can review: the Acceptance Criteria (ACs) of an
OpenSpec change. The rules for specs live in `AGENTS.md` §3–§4 and `openspec/config.yaml`; this skill
applies them. Read-only on code, write-only inside `openspec/changes/<change-id>/`.

**Boundary.** Produce `proposal.md` and `specs/<capability>/spec.md` only. Do NOT write `design.md`,
`tasks.md` or any code. Do NOT touch `ERAS-BE/`, `ERAS-FE/` or infrastructure files. Do NOT commit.
Never read or print secrets (`.env`, `deploy/.env.prod`, `environment.development.ts`, keys in `appsettings*.json`).

**Templates** (copy the structure, delete every HTML comment from the output):
- `.claude/skills/sdd-spec/templates/proposal.md`
- `.claude/skills/sdd-spec/templates/spec.md`

## Steps

1. **Understand the request.** If it is unclear, ask for it: "What behavior should change, for whom, and
   what is the GitHub issue?" Reply in the user's language; write all artifacts in English.
   Identify: the issue number (ask if missing, never invent one), the roles involved, the affected
   side (BE, FE, both), and what is out of scope.

   **No observable behavior change** (pure refactor, tooling, docs, CI)? Do not invent requirements.
   Tell the user this needs a change with `skip_specs: true` and only `proposal.md` + `tasks.md`
   (AGENTS.md §3) and point to `/opsx:propose`; stop there.

2. **Check the project and find the change.**
   - `openspec list --json` (the `root` must not be null; if it is, stop and tell the user).
   - `openspec list` for active changes. If one already covers this work, **update it** (see "Updating") instead of creating another.
   - `openspec list --specs`, then read every related capability **in full**: `openspec show "<spec-id>" --type spec`.
   - The change id is kebab-case `<issue-number>-<verb>-<object>`, for example `608-reject-duplicate-configuration-name`.

3. **Ground the spec in the code (read-only, proportional).** Look at how the behavior works today in
   `ERAS-BE/` and `ERAS-FE/` (use an Explore agent for broad searches and keep only conclusions).
   Distinguish what exists today from what you are proposing. If an existing spec or the code
   contradicts the request, surface it instead of picking a side.

4. **Choose capabilities.** Name durable behaviors (`assessment-management`, `access-control`), not tasks.
   Reuse an existing path when the behavior belongs to it (then the delta uses `## MODIFIED`/`## ADDED`
   without `## Purpose`). A new capability gets `## Purpose` (50+ characters).

5. **Scaffold and write.**
   - New change: `openspec new change "<change-id>"`.
   - Write `proposal.md` from the proposal template with `**Status:** Draft`. Why links the issue
     (`ERAS-BE#n` / `ERAS-FE#n`); Impact states the submodules and any change to who can do what.
   - Write one `specs/<capability-path>/spec.md` per capability from the spec template.

6. **Write good ACs.** Each `#### Scenario: AC-<n> <title>` is exactly one behavior that one automated
   test per affected side can prove.
   - Numbers start at 1 and are unique across the **whole change**, never renumbered, never reused.
   - GIVEN / WHEN / THEN (/ AND), concrete values, exact role names (`ERAS Administrator`,
     `ERAS Student Services Officer`, `ERAS Professional`, Guest), observable outcomes (status code,
     message, what the user sees, what is or is not persisted).
   - For every new endpoint or route: happy path, each allowed role, each denied role, each validation failure.
     Ownership rules ("a Professional only sees interventions assigned to them") are their own ACs.
   - Requirements: one behavior, SHALL/MUST, 500 characters or fewer, at least one scenario.
   - Keep how out of the spec: no class, method, table or library names; no DTO shapes, policy names or
     file paths (they belong in `design.md`). Status codes and user-visible messages are behavior and stay.
   - If the API contract changes, say in Impact that BE DTO, FE model and FE service move together.

7. **Ambiguity policy.**
   - Resolve minor gaps with a reasonable default and list it under `## Assumptions` (A1, A2, ...).
   - If a gap would change scope, behavior, authorization or data and the code/specs cannot answer it,
     keep the scenario and mark it inline with `[NEEDS CLARIFICATION: <one concrete question>]`.
     At most **3** markers; prefer an assumption over a marker when the risk is low.

8. **Validate.** `openspec validate "<change-id>" --strict`. Fix every error, then validate again.
   `[NEEDS CLARIFICATION]` markers are legal text and pass validation.

9. **Stop and report.** Give: change id and paths, the capabilities and number of ACs, the assumptions,
   the open markers, and whether `design.md` will be required later (it is when the change spans BE and FE,
   adds a migration, touches auth, or changes an API contract; AGENTS.md §3.1). Then the next step:
   - markers or assumptions exist → run `/sdd-clarify <change-id>`;
   - none → a human reviews the spec; afterwards `/opsx:propose` on this same change id
     creates the missing `design.md` and `tasks.md` (it continues the existing change).
   Do not start those steps yourself. Implementation still waits for the human approval of the
   **complete** change (AGENTS.md §3.2); approving the spec early does not replace it.

## Updating an existing change

- Re-read `proposal.md` and every spec file from disk first; the user may have edited them.
- Keep `Status: Draft`. If it says `Approved`, stop and ask: approved specs change through a new
  review, and the user decides whether to reopen it.
- Add new scenarios with the **next free AC number**. Never renumber or reuse a number; to drop an AC,
  delete the scenario and leave the gap.
- When a requirement of an **existing main spec** changes, use `## MODIFIED Requirements` with the entire
  block copied from `openspec/specs/` (header text must match). Its scenarios get this change's AC keys.
- Re-run `openspec validate "<change-id>" --strict`.

## Guardrails

- No spec, no code: this skill never writes code, even if the request says "build" or "fix".
- Smallest thing that satisfies the request: no speculative requirements to look complete; record
  out-of-scope findings under `**Out of scope:**` or `## Assumptions`.
- Never mark the spec `Approved`; only a human reviewer does that.
