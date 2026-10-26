# Proposal

**Status:** Draft
**Plan:** Draft

## Why

The data migration `20261009150000_BackfillEvaluationPolls` fails, and the API crashes in a restart
loop on startup, when `poll_instances` holds rows whose `EvaluationId` points to an evaluation that
no longer exists: the insert into `evaluation_poll` violates its foreign key to `evaluation`
(PostgreSQL 23503). The dev database had 129 such rows pointing to two deleted evaluations and had
to be repaired by hand before the release branch could start. Production has not been checked and
may be affected, which would block the release. Issue: ERAS#571 (parent repo).

## What Changes

- The backfill migration skips poll instances whose evaluation no longer exists, so it completes on
  databases with orphan references and creates no link for them. Everything else it does stays the
  same: every poll that has instances is linked to its existing evaluation, existing links are kept,
  and running it twice creates no duplicates.
- Tests run the migration's real SQL against tables with foreign keys enabled, including the failing
  case (fails with the original SQL, passes with the fix).
- The GitHub Actions workflow `Automatic deploy process` (`.github/workflows/workflow.yml`) no longer
  runs on every push to `develop`; it becomes manual-only (`workflow_dispatch`). It ran on a
  GitHub-hosted runner that cannot reach the private dev host, so it always failed at "Setup SSH Key"
  and never deployed anything. The real deploy is `Deploy process on runner`.

**Out of scope:**
- Finding out why orphan `poll_instances` exist (probably deleting an evaluation does not clean up
  its poll instances) and preventing or cleaning them up.
- Checking production for orphan references before the release (manual step, query in the issue).
- Any change to `Deploy process on runner` or `Ad Hoc deploy process into Stage`.

## Capabilities

### New Capabilities
- `evaluation-poll-linking`: every poll that has poll instances is linked to its evaluation in
  `evaluation_poll`, including the one-time backfill of older imports.

### Modified Capabilities
- none

## Impact

- **Submodules:** BE (plus `.github/workflows/workflow.yml` in the parent repo)
- **Roles / who can do what:** no change
- **API contract:** none
- **Data / migration:** yes. The existing data-only migration `20261009150000_BackfillEvaluationPolls`
  is edited in place. This is safe: databases where it already ran never run it again, and the edit
  only affects databases where it has not been applied yet. No new migration, no schema change.

## Assumptions
- A1: Editing an already-shipped migration is acceptable here because it is data-only and insert-only,
  and the fix only narrows the set of rows it inserts (the rows it drops could never have been
  inserted anyway).
- A2: The fix must land in `develop` and be cherry-picked to the active release branch
  (`release/Release-19-10-2026`), since both carry the unfixed migration.
- A3: The workflow part of the ticket has no observable product behavior, so it has tasks but no
  acceptance criteria; it is verified by inspecting the workflow trigger.

## Clarifications

## Validation log

- 2026-10-26 (agent, gates on ERAS-BE `fix/backfill-evaluation-polls-orphan-evaluations` + AC traits): `dotnet build -warnaserror` 0 warnings;
  `dotnet test Eras.sln` 1883 passed, 0 failed (the 4 tagged tests pass; the AC-1 test fails with a foreign key error when the
  `JOIN evaluation` line is removed); AC traceability 1 BE test per AC; `openspec validate --strict` valid.
  `dotnet format --verify-no-changes` fails on 5 files this change does not touch (import ordering in
  `Eras.Infrastructure.Tests/.../Mappers/*MapperTest.cs` and `Eras.Api.Tests/Authorization/ErasPoliciesTests.cs`),
  pre-existing in `develop`; the two files of this change pass `dotnet format --include`.
  `workflow.yml` trigger verified to be `workflow_dispatch` only. Not committed; `Status`/`Plan` approval pending.
