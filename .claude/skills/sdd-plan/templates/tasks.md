# Tasks

<!--
TEMPLATE for openspec/changes/<change-id>/tasks.md, created by /sdd-plan.
The apply phase parses checkboxes: every task is exactly `- [ ] <group>.<n> <description>`; nothing else is tracked.
Rules (openspec/config.yaml and AGENTS.md):
- Groups by side: BE, FE, Infra (only those the change touches), in dependency order.
- For every AC the TEST task comes BEFORE its implementation task, inside the same group.
  A test task starts with "Write" (the checker relies on it). Each group lands its own tests;
  do not pile tests into a final group.
- Each task says how to verify it (a test that passes, a command, an observable result).
- Mention the AC as (AC-n) in the tasks that serve it, so the checker can follow it.
- Small tasks: one session each. Cite real paths from design.md.
- Last group = verification (AGENTS.md section 8.7); last section = Traceability.
Delete every HTML comment from the output file.
-->

## 1. Backend (BE)

- [ ] 1.1 Write the AC test `<Handler>Tests.<Method>` for (AC-1) in `ERAS-BE/test/Eras.Application.Tests/Features/<Feature>/`, tagged `Change` and `AC`, and verify it fails for the right reason
- [ ] 1.2 Implement <what> in `ERAS-BE/src/Eras.Application/Features/<Feature>/...` for (AC-1) and verify the test from 1.1 passes
- [ ] 1.3 Write the Api test for (AC-2) in `ERAS-BE/test/Eras.Api.Tests/...` and verify it fails
- [ ] 1.4 Add `[Authorize(Policy = ErasPolicies.<Policy>)]` to <controller action> for (AC-2) and verify the test from 1.3 passes

## 2. Frontend (FE)

- [ ] 2.1 Write the spec `[<change-id>/AC-1] <title>` for (AC-1) in `ERAS-FE/src/app/<path>/<unit>.spec.ts` and verify it fails
- [ ] 2.2 Implement <what> in `ERAS-FE/src/app/<path>` for (AC-1) and verify the spec from 2.1 passes

## 3. Verification

- [ ] 3.1 BE gates pass in `ERAS-BE/`: `dotnet build Eras.sln -warnaserror`, `dotnet format Eras.sln --verify-no-changes`, `dotnet test Eras.sln`, coverage >= 25%
- [ ] 3.2 FE gates pass in `ERAS-FE/`: `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (>= 15%), `npm run build`
- [ ] 3.3 The AC traceability check (AGENTS.md section 8.6) shows exactly 1 test per AC per affected side, and `openspec validate <change-id> --strict` passes

## Traceability
<!-- One row per AC per affected side (the Side line of the AC; "BE + FE" = two rows). The Test column carries the
     planned test from design.md; /sdd-implement confirms it with the real names. -->
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | <scenario title> | BE | test/Eras.Application.Tests/Features/<Feature>/<Handler>Tests.cs › <Method> |
| AC-1 | <scenario title> | FE | src/app/<path>/<unit>.spec.ts › [<change-id>/AC-1] <title> |
| AC-2 | <scenario title> | BE | test/Eras.Api.Tests/<...>Tests.cs › <Method> |
