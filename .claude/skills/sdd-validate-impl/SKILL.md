---
name: sdd-validate-impl
description: >
  Spec Driven Development workflow step that runs ONLY after sdd-implement and BEFORE
  sdd-verify (sdd-spec > sdd-clarify > sdd-plan > sdd-implement > sdd-validate-impl >
  sdd-verify). Applies only when the implementation created or changed a backend controller
  (ERAS-BE) or implemented a frontend change (ERAS-FE); otherwise it is skipped and the flow
  goes straight to sdd-verify. Asks the developer to manually validate the feature, then
  routes the workflow: back to sdd-implement if the developer requests changes or reports
  problems, forward to sdd-verify if the developer approves. Never marks a spec "Implemented".
---

# SDD: Validate Implementation (manual gate)

Position in the workflow:

```
sdd-spec > sdd-clarify > sdd-plan > sdd-implement > [sdd-validate-impl] > sdd-verify
                                          ^                  |
                                          └── change request ┘
```

Only invoke this skill as the step after `sdd-implement` and before `sdd-verify`. Do not use
it standalone or at any other point of the workflow.

## Spec layout assumed

```
specs/README.md                  # index: one row per spec with its status
specs/<feature>/spec.md          # goal, scope, AC-n criteria, traceability, definition of done, status
specs/<feature>/plan.md          # approach / task groups
specs/<feature>/tasks.md         # checklist: - [ ] / - [x] T-n ...
```

## Workflow

### 1. Locate the spec
Use the spec being implemented (named by the user or the workflow, else the one for the
current branch). Read `spec.md`, `plan.md`, `tasks.md`.

### 2. Decide: validate or skip
Decide from the spec files (`tasks.md`, `plan.md`, `spec.md`), not from the git diff.
Validation is **required** only if the work includes either:
- a **new or modified controller** in `ERAS-BE`, or
- a **frontend change** in `ERAS-FE` (component, template, service, route, style, etc.).

Otherwise (e.g. docs, config, CI, DB/migration-only, non-controller backend code) **skip**:
1. Tell the user it is skipped and why (no controller/FE change).
2. Append to `spec.md` `## Validation log`: `<date> – Skipped: no BE controller or FE change.`
3. Pass to `sdd-verify`.

### 3. Hand the developer a manual validation checklist
Derive it from the spec; do not invent behavior. Present it to the user and add it to
`spec.md` under `## Validation log`:

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|

Cover, per `AC-n`, only what the changed controllers / FE screens affect:
1. **Goal** – the happy path achieves the stated goal.
2. **Side effects** – neighbouring features, data, permissions/roles, and other screens or
   endpoints that use the changed code still behave as before.
3. **Errors** – invalid input, failing backend, empty/loading states, expired session.
4. **Different views** – other roles, viewport sizes, languages, entry points where relevant.

State how to run the app if useful (the `run` skill / docker-compose). Then **stop and wait**
for the developer's response. Do not proceed on assumptions.

### 4. Route on the developer's response

**A. The developer reports a problem or requests a change** → record it and return to `sdd-implement`:
1. Log the findings in `## Validation log` (date, what was tried, result per row).
2. Update the files so they stay in sync (show the proposed edits and apply once the developer agrees):
   - bug / AC not achieved / regression: add or reopen a task in `tasks.md` (`- [ ] T-n Fix: ...`, linked to its `AC-n`), reopening any wrongly closed `[x]`;
   - requirement changed or dropped: edit the `AC-n` in `spec.md`, then `plan.md` and `tasks.md` to match;
   - task replaced or removed: replace it in `tasks.md` and the matching `plan.md` group; keep IDs stable and mark old ones `~~T-n~~ (replaced by T-m)`.
3. Every `AC-n` must still map to at least one task. Surface any AC wording change explicitly.
4. Keep the spec status **`In progress`**.
5. Hand off: tell the user to continue with `sdd-implement` for the open tasks. After it
   finishes, this skill runs again (repeat from step 2).

**B. The developer approves the manual verification** (ask explicitly if unclear:
"Do you approve this implementation: goal achieved, no side effects, no open errors?") →
1. Add to `## Validation log`: `Approved by <developer>, <date>`.
2. Keep the status `In progress`.
3. Pass to `sdd-verify`.

## Don'ts
- Don't run outside the `sdd-implement` → `sdd-verify` slot, or when validation should be skipped.
- Don't set status to `Implemented` or edit the status in `specs/README.md`; that is `sdd-verify`.
- Don't mark validation rows or approve on the developer's behalf.
- Don't silently change AC-n text.
- Don't implement fixes here; send the work back to `sdd-implement`..
