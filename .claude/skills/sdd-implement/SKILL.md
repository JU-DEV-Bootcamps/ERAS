---
name: sdd-implement
description: Implements the tasks in an ERAS OpenSpec change's tasks.md in order, following its design.md (the plan), test first, checking off each task when its tests pass, then runs the AGENTS.md gates and reports real results. Use when a change's plan is approved (Plan - Approved) and the code needs to be written in ERAS-BE and/or ERAS-FE.
allowed-tools: Bash(openspec:*) Bash(bash .claude/skills/sdd-implement/scripts/check-impl.sh:*) Bash(bash .claude/skills/sdd-plan/scripts/check-plan.sh:*)
---

Write the code of an approved change by following `tasks.md` in order and `design.md` as the plan, one tagged
test per Acceptance Criterion (AC) per side, **test first**. This skill is the ERAS-specific version of
`/opsx:apply`: same task loop, plus the approval gates, the AC test tags and the §5.6 gates.
Rules: `AGENTS.md` (§1 principles, §2 golden paths, §4 AC↔test, §5 commands) and `openspec/config.yaml`.

**Boundary.** Edit code and tests in `ERAS-BE/` and `ERAS-FE/`, tick `tasks.md`, and fill its Traceability table.
Do NOT change the spec (`proposal.md`, `specs/`) or the plan's approach on your own, do NOT set `**Status:**` or
`**Plan:**`, do NOT commit or push, do NOT archive. Never read or print secrets (`.env`, `deploy/.env.prod`,
`environment.development.ts`, keys in `appsettings*.json`) and never put tokens or personal data in logs or tests.

**Templates:**
- `.claude/skills/sdd-implement/templates/ac-test-be.md`: tagged xUnit test skeleton
- `.claude/skills/sdd-implement/templates/ac-test-fe.md`: tagged Jasmine test skeleton
- `.claude/skills/sdd-implement/templates/implementation-report.md`: the report you give the user

**Checkers:**
- `bash .claude/skills/sdd-plan/scripts/check-plan.sh <change-id>`: the plan is well-formed (run at the start)
- `bash .claude/skills/sdd-implement/scripts/check-impl.sh <change-id> [--final]`: tasks ticked and exactly one tagged test per AC per side (`--final` turns pending items into errors)

## Steps

1. **Select the change and check the gates.** Use the id the user gave, else `openspec list` (ask if several).
   Announce `Using change: <id>` and how to override. Re-read `proposal.md`, the specs, `design.md` and `tasks.md` from disk.
   - `**Status:** Approved` and `**Plan:** Approved` in `proposal.md` → continue.
   - Anything else → stop and say which gate is open: no `design.md`/`tasks.md` → `/sdd-plan`; `Status` not Approved →
     `/sdd-clarify` or human review; `Plan` not Approved or missing → a human reviews `design.md` and `tasks.md` and sets it.
     Continue without the line only if the user explicitly says in chat that the change is approved, and say so in the report.
   - `openspec validate "<change-id>" --strict` and `bash .claude/skills/sdd-plan/scripts/check-plan.sh "<change-id>"` must pass.
   - `openspec instructions apply --change "<change-id>" --json`: if `state` is `blocked`, show the message and stop;
     if `all_done`, go to step 8.

2. **Prepare the workspace.** Code changes live **inside** the submodules, on a branch there; the parent repo only
   gets `tasks.md`.
   - For each side the tasks touch, `git -C ERAS-BE branch --show-current` (same for `ERAS-FE`). If it is `develop` or
     `main`, stop and ask the user for the branch name (`<prefix>/<storyNumber>/<storyTitle>`, prefix one of
     `feature|bugfix|refactor|ci|docs|chore|style|release`). Do not create it with a name you invented.
   - Note `git status` of each submodule so you can tell your changes from earlier ones, and never revert work you did not write.
   - If `dotnet build/test` is blocked by file locks (a running `Eras.Api` or Visual Studio), ask the user to stop it; do not fight it.

3. **Show progress.** `N/M tasks complete`, the remaining tasks overview, and the next task.

4. **Loop through the tasks in order.** For each pending task:
   - Say which task you are on (`Working on task 3/12: …`). Keep changes minimal and scoped to the task.
   - **Test tasks** (they start with "Write"): write the tagged test from the template, run it **alone**, and confirm it fails
     **for the right reason** (the behavior is missing: an assertion or a missing member, not a typo, wrong setup or selector).
     Keep the failure message for the report. Then tick the task.
   - **Implementation tasks:** implement following the golden path of `AGENTS.md` §2 and the plan in `design.md`; run the test
     from the previous task until it passes, then run the neighbouring tests of the area you touched.
   - **Guard tests:** an AC test that passes before any implementation (it protects behavior the code could break) is allowed
     only when the task says so. Prove it can fail by temporarily breaking the code, restore it, and note this in the report.
   - **Tick `- [ ]` → `- [x]` immediately**, only when the task's specified behavior is fully done and its tests pass, never
     partially. Re-run `openspec instructions apply --change "<change-id>" --json` and confirm the progress changed.
   - Tests: one tagged test per AC per side, tagged with exactly one AC key (BE `[Trait("Change", …)]` + `[Trait("AC", "<id>/AC-n")]`;
     FE `it('[<id>/AC-n] …')`). Edge-case or helper tests are welcome and carry no AC tag. Never `fit`, `xit`, `fdescribe`,
     `xdescribe` or a skipped `[Fact(Skip=…)]`. If `ERAS-FE/.claude/skills/eras-fe-test/SKILL.md` exists, follow it for FE tests.

5. **Code rules while writing** (AGENTS.md; do not relax them to make a task fit):
   - Target style only; never copy the legacy patterns listed in §2.1/§2.2. Do not refactor legacy code outside the change's scope.
   - BE: `CancellationToken` from controller to EF, `Async` suffix, handlers throw `Eras.Error` exceptions, thin controllers with
     `[Authorize(Policy = ErasPolicies.…)]`, ownership rules in the handler, correct `ILogger<T>`, no secrets, no stack traces to clients.
     Schema changes get a **new** migration (`dotnet ef migrations add …`); never edit an applied one or hand-edit the model snapshot.
   - FE: standalone OnPush component, `inject()`, signal `input()/output()`, `@if/@for`, Reactive Forms, teardown with
     `takeUntilDestroyed()`/`toSignal()`, services extend `BaseApiService`, permissions via `PermissionsService` or
     `*appHasERASRoles`, text in `core/constants/messages.ts`, theme tokens instead of colors, no `any` without a written reason.
   - When the API contract changes, BE DTO, FE model and FE service change in this same change.
   - Comments only where they add meaning (XML/JSDoc on public contracts); never restate the code.

6. **Pause instead of guessing.** Stop, explain, offer options and wait when:
   - A task is unclear, or needs work the spec and tasks do not describe (never absorb added scope silently; never drop,
     narrow or defer specified behavior to make it fit).
   - **The spec is wrong or incomplete** → update the spec first (`/sdd-spec` update mode, `/sdd-clarify` if it needs a decision),
     re-validate, and flag it to the reviewer; the plan follows (`/sdd-plan` update mode). Then continue.
   - **The plan is wrong** (a layer, file, policy or DTO differs from what the code allows) → propose the `design.md` / `tasks.md`
     edit, apply it only with the user's agreement, and say that `**Plan:**` needs the reviewer again if the approach changed.
   - A test cannot be made to fail for the right reason, an unrelated test breaks, or a shared thing (global query filter,
     shared model or component) is affected: report the blast radius and ask.
   - You find something out of scope: do not do it; add it under `## Follow-ups` in `design.md`.

7. **Pause or finish a session** with the report template: tasks done, test-first evidence, what is left and why you stopped.

8. **When every task is ticked, close the change** (this is the verification group of `tasks.md`):
   - Fill the Traceability table with the **real** test names and paths (file › name), one row per AC per side.
   - Run the full gates of `AGENTS.md` §5.6 and keep the real output: BE `dotnet build Eras.sln -warnaserror`,
     `dotnet format Eras.sln --verify-no-changes`, `dotnet test Eras.sln`, coverage (`--collect:"XPlat Code Coverage" … --settings coverlet.runsettings`, ≥ 25%);
     FE `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (≥ 15%), `npm run build`.
   - `bash .claude/skills/sdd-implement/scripts/check-impl.sh "<change-id>" --final` and the §5.4 traceability check: exactly 1 test per AC per affected side.
   - `openspec validate "<change-id>" --strict`.
   - A gate that fails or cannot run stays failed in the report with its output; never claim a pass you did not observe,
     and never tick a verification task whose gate is red.

9. **Report and hand off** using the report template: results of every gate, what was not verified, the follow-ups, and the
   proposed commits per repo (submodule branches and messages in Conventional Commits, `git add` lists, parent commit for `tasks.md`).
   Do not commit. Next: `/sdd-validate-impl` when a BE controller or the FE changed, then `/sdd-verify`; archive only after the
   submodule PRs merge (`/opsx:archive`).

## Guardrails

- No spec, no code; no approved plan, no code. Test first, always: a test you never saw fail proves nothing.
- Smallest thing that satisfies the spec: no speculative features, no "while I'm here" edits.
- Never mark a task done on a red test, never edit the spec or tasks to make the work pass, never silence a failing gate.
- Do not commit, push, archive or bump submodule pointers. Never commit `ERAS-BE/src/Eras.Api/appsettings.json` or `ERAS-FE/.husky/*`.
