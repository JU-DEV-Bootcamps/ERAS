---
name: sdd-validate-impl
description: >
  Spec Driven Development workflow step that runs ONLY after sdd-implement and BEFORE
  sdd-verify (sdd-spec > sdd-clarify > sdd-plan > sdd-implement > sdd-validate-impl >
  sdd-verify). Applies only when the implementation created or changed a backend controller
  (ERAS-BE) or implemented a frontend change (ERAS-FE); otherwise it is skipped and the flow
  goes straight to sdd-verify. Asks the developer to manually validate the feature, logs the
  result in the change's proposal.md, then routes the workflow: back to sdd-implement if the
  developer requests changes or reports problems, forward to sdd-verify if the developer
  approves. Never closes or archives the change.
allowed-tools: Bash(openspec:*) Bash(bash .claude/skills/sdd-implement/scripts/check-impl.sh:*)
---

# SDD: Validate Implementation (manual gate)

Position in the workflow:

```
sdd-spec > sdd-clarify > sdd-plan > sdd-implement > [sdd-validate-impl] > sdd-verify
                                          ^                  |
                                          └── change request ┘
```

Only invoke this skill as the step after `sdd-implement` and before `sdd-verify`. Do not use
it standalone or at any other point of the workflow. The conventions it relies on are in
`AGENTS.md` §8.4.

## Change layout assumed

```
openspec/changes/<change-id>/proposal.md   # **Status:** / **Plan:** lines, ## Validation log
openspec/changes/<change-id>/specs/<capability>/spec.md   # ACs: "#### Scenario: AC-n", "**Side:** BE|FE|BE + FE"
openspec/changes/<change-id>/design.md     # the plan: changes by layer
openspec/changes/<change-id>/tasks.md      # numbered tasks (1.1, 2.3 ...) and ## Traceability
```

AC key: `<change-id>/AC-n`. Never write the validation log in `spec.md`: it is a delta that is
merged into `openspec/specs/` on archive.

## Workflow

### 1. Locate the change
Use the change named by the user or the workflow, else the one for the current branch
(`openspec list`; ask if several). Read `proposal.md`, the specs, `design.md` and `tasks.md`
from disk. Run `bash .claude/skills/sdd-implement/scripts/check-impl.sh "<change-id>"`: it reports unchecked
tasks as a warning. If the implementation tasks are not all ticked (`[x]`), stop and send the user back to
`sdd-implement`.

### 2. Decide: validate or skip
Decide from the change files (`tasks.md`, `design.md` "Changes by layer", `spec.md`), not from
the git diff. Validation is **required** only if the work includes either:
- a **new or modified controller** in `ERAS-BE`, or
- a **frontend change** in `ERAS-FE` (component, template, service, route, style, etc.).

Otherwise (e.g. docs, config, CI, DB/migration-only, non-controller backend code) **skip**:
1. Tell the user it is skipped and why (no controller/FE change).
2. Append to `proposal.md` under `## Validation log` (create the section if missing):
   `<date> – Skipped: no BE controller or FE change.`
3. Pass to `sdd-verify`.

### 3. Hand the developer a manual validation checklist
Derive it from the ACs of the spec; do not invent behavior. Present it to the user and add it
to `proposal.md` under `## Validation log`, in a block `### <date> – Round <n>`:

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|

`Ref` is the AC number (`AC-n`). Cover, per AC, only what the changed controllers / FE screens affect:
1. **Goal** – the happy path achieves the stated goal.
2. **Side effects** – neighbouring features, data, permissions/roles (`ERAS Administrator`,
   `ERAS Student Services Officer`, `ERAS Professional`, Guest), and other screens or endpoints that
   use the changed code still behave as before.
3. **Errors** – invalid input, failing backend, empty/loading states, expired session.
4. **Different views** – other roles, viewport sizes, languages, entry points where relevant.

State how to run the app if useful (the `run` skill, or the local stack of `AGENTS.md` §3.4). Then
**stop and wait** for the developer's response. Do not proceed on assumptions.

### 4. Route on the developer's response

**A. The developer reports a problem or requests a change** → record it and return to `sdd-implement`:
1. Log the findings in the round's table (what was tried, result per row).
2. Update the change so it stays in sync (show the proposed edits and apply once the developer agrees):
   - bug / AC not achieved / regression: add or reopen a task in `tasks.md` as a test-first pair in the
     matching side group, before the verification group: `- [ ] n.m Write the regression test for (AC-n) …`
     then `- [ ] n.m Fix: … (AC-n)`. Reopen any wrongly closed `[x]`;
   - requirement changed or dropped: do **not** edit the AC here. Send it through `/sdd-spec` (update mode,
     then `/sdd-clarify` if it needs a decision) and then `/sdd-plan` (update mode) so `design.md`, `tasks.md`
     and the Traceability rows follow; the human gates (`Status`, `Plan`) apply again;
   - task replaced or removed: strike it through and point to the new one, `~~1.2~~ (replaced by 1.5)`;
     never renumber.
3. Every AC must still map to at least one task and one Traceability row. Surface any AC wording change explicitly.
4. Do not touch the `**Status:**` or `**Plan:**` lines.
5. Hand off: tell the user to continue with `sdd-implement` for the open tasks. After it finishes, this
   skill runs again (repeat from step 2).

**B. The developer approves the manual verification** (ask explicitly if unclear:
"Do you approve this implementation: goal achieved, no side effects, no open errors?") →
1. Add to the round: `Approved by <developer>, <date>`.
2. Pass to `sdd-verify`.

## Don'ts
- Don't run outside the `sdd-implement` → `sdd-verify` slot, or when validation should be skipped.
- Don't close, archive or declare the change done; that is `sdd-verify` and the developer.
- Don't mark validation rows or approve on the developer's behalf.
- Don't silently change AC text, and don't edit `**Status:**` or `**Plan:**`.
- Don't write the log in `spec.md`.
- Don't implement fixes here; send the work back to `sdd-implement`.
- Don't commit.
