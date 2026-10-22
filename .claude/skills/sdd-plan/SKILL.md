---
name: sdd-plan
description: Generates the plan (design.md) and tasks.md for an approved ERAS OpenSpec spec, with changes by layer (Domain, Application, Infrastructure, Api for BE; route, model, service, component for FE), API contracts, authorization and a test strategy that maps every AC to one test per side. Use when a spec is in Approved status and you need to decide how to implement it. Does not write code.
allowed-tools: Bash(openspec:*) Bash(bash .claude/skills/sdd-plan/scripts/check-plan.sh:*) Bash(bash .claude/skills/sdd-spec/scripts/check-spec.sh:*)
---

Turn an **Approved spec** into a plan a developer (or `/sdd-implement`) can follow without guessing.
In this repo the OpenSpec artifacts of the plan are **`design.md`** (the plan: how) and **`tasks.md`**
(the ordered checklist). `openspec status` needs `design.md` before it unlocks `tasks.md`, which is why the
plan is not a separate `plan.md`. Rules: `AGENTS.md` §2–§5 and `openspec/config.yaml`.

**Boundary.** Write only `design.md` and `tasks.md` of the change, and the `**Plan:**` line of `proposal.md`.
Do NOT write code or tests, do NOT touch `ERAS-BE/` or `ERAS-FE/`, do NOT edit the spec (a problem in the
spec goes back to `/sdd-spec` or `/sdd-clarify`), do NOT commit. Never read or print secrets (`.env`,
`deploy/.env.prod`, `environment.development.ts`, keys in `appsettings*.json`).

**Templates** (copy the structure, delete every HTML comment and every section that does not apply; keep Follow-ups last):
- `.claude/skills/sdd-plan/templates/design.md`
- `.claude/skills/sdd-plan/templates/tasks.md`

**Worked example** (fictional, for shape only): `.claude/skills/sdd-plan/examples/608-reject-duplicate-configuration-name/`

**Checker:** `bash .claude/skills/sdd-plan/scripts/check-plan.sh <change-id>` (from the repo root).

## Steps

1. **Find the change and check the gate.** Use the id the user gave, else `openspec list` (ask if several).
   Re-read `proposal.md` and every `specs/**/spec.md` from disk.
   - `**Status:** Approved` → continue.
   - `Draft` or `Clarified` → stop: the spec is not approved. `Draft` → `/sdd-clarify`; `Clarified` → a human
     reviews and sets `Approved`. Never set it yourself. Proceed on a non-Approved spec only if the user
     explicitly says so in chat, and say so in the report.
   - `skip_specs: true` (no spec) → plan from `proposal.md` only; tasks have no ACs and no Traceability rows.
   - Run `bash .claude/skills/sdd-spec/scripts/check-spec.sh "<change-id>"`; fix nothing in the spec, report errors.
   - Existing `design.md` / `tasks.md` → update mode (see below), never overwrite blindly.

2. **Load the rules.** `openspec status --change "<change-id>" --json`, then
   `openspec instructions design --change "<change-id>" --json` and `... tasks ...`: treat `context` and
   `rules` as constraints for you (do not copy them into the files).

3. **Read the code (read-only).** For each capability, find what exists today in `ERAS-BE/` and `ERAS-FE/`:
   the feature folder, the closest golden-path reference (`Features/RemissionManagement/`,
   `AssessmentsController`), existing policies in `ErasPolicies`, FE route metadata, models and services.
   Use an Explore agent for broad searches and keep only conclusions. Cite real paths; if a path does not exist,
   it is a *new file* and the design says so.

4. **Decide the approach.** For each AC, decide where its behavior is decided and which side proves it:
   - BE follows the golden path (AGENTS.md §2.1): Domain → contract → request → handler → DTO/mapper →
     persistence (migration if the schema changes) → thin controller with `[Authorize(Policy = ...)]`.
   - FE follows the golden path (§2.2): lazy route with `canActivateAuthRole` + `ROUTE_METADATA` roles, model
     mirroring the BE DTO, service extending `BaseApiService`, standalone OnPush component, `PermissionsService`.
   - Use only target-style patterns; never plan the legacy ones listed in §2.1/§2.2. Do not plan refactors
     outside the change's scope: write them under Follow-ups.
   - If the API contract changes, BE DTO, FE model and FE service move in the **same** change (principle 9).
   - Ownership and scope rules live in the handler and must already be ACs; if one is missing, that is a
     spec gap, not a task.

5. **Resolve open questions before tasks.** If an unknown would change the specs, the approach or the task
   breakdown, ask the user now (concrete question, recommended option first). Only truly deferrable
   unknowns go to `## Open Questions`.

6. **Write `design.md`** from the template: Context, Goals/Non-Goals, Decisions (with the alternative),
   Changes by layer, API contract (when it changes), Data and migration, **Test strategy** (one row per AC per
   affected side, using the AC's `**Side:**` line), Risks, Migration Plan, Open Questions, and **Follow-ups last**.
   It is required here for every change that has specs, because the schema blocks `tasks.md` without it.

7. **Write `tasks.md`** from the template.
   - Groups by side (BE, FE, Infra), in dependency order, then a final **Verification** group (§5.6 gates).
   - For every AC the **test task comes before its implementation task** in the same group. Every group lands
     its own tests; never collect tests into the last group.
   - Every task is `- [ ] <group>.<n> <description>` and states how to verify it. One session of work each.
   - Cite the AC as `(AC-n)` in both its test task and its implementation task. A test task starts with
     "Write" (the checker uses both conventions to verify test-first order).
   - Test tasks name the tag to use: BE `[Trait("Change", ...)]` + `[Trait("AC", "<change-id>/AC-n")]`,
     FE `it()` title starting `[<change-id>/AC-n]`. One tagged test per AC per side, never two ACs in one test.
   - Include the migration task (new migration, never edit an applied one) when the schema changes, and the
     docs a task owes (for example Swagger-visible changes), inside that task's group.
   - End with `## Traceability`: `| AC | Scenario | Side | Test |`, one row per AC per side, with the planned test
     (file › name) from the design's Test strategy.

8. **Mark the plan as Draft.** In `proposal.md`, right under `**Status:**`, add `**Plan:** Draft` (or keep it if it
   exists). Only a human sets `**Plan:** Approved`; `/sdd-implement` waits for it.

9. **Validate.** Run both and fix every error, then run them again:
   - `openspec validate "<change-id>" --strict`
   - `bash .claude/skills/sdd-plan/scripts/check-plan.sh "<change-id>"` (every AC on every declared side has a
     Traceability row, tasks are well-formed checkboxes, the test task precedes the implementation task, the
     verification group cites §5.6, `design.md` ends with Follow-ups).
   Warnings are for you to judge, not to silence.

10. **Stop and report.** Give: change id, the layers touched, number of tasks per group, the decisions, the
    open questions, and anything you found out of scope. Next step: a human reviews `design.md` and
    `tasks.md` and sets `**Plan:** Approved`; then `/sdd-implement <change-id>`. Do not start implementing.

## Updating an existing plan

- Re-read `design.md`, `tasks.md` and the spec from disk first; the user may have edited them.
- Keep every `[x]` as it is. Add tasks with the next number in the group; to drop a task, delete it only if it
  is unchecked, otherwise strike it through `~~1.2~~ (replaced by 1.5)` so progress stays traceable.
- A spec change (new or edited AC) adds the matching test task, implementation task and Traceability rows.
- Reset `**Plan:**` to `Draft` when the approach or the task list changes materially, and tell the user why.

## Guardrails

- No code, no tests, no spec edits: this skill plans only.
- Smallest plan that satisfies the ACs: no speculative layers, abstractions or "while I'm here" tasks.
- Cite real paths and names; do not invent files or policies. A new file is marked as new.
- Never set `**Status:**` or `**Plan:** Approved`; only a human reviewer does.
- Never plan a migration that edits an applied one, hand-edits `AppDbContextModelSnapshot.cs`, or logs tokens or personal data.
