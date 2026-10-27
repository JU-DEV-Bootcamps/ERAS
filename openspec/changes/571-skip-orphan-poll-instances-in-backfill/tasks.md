# Tasks

## 1. Backend (BE)

- [x] 1.1 Add `Microsoft.Data.Sqlite` 9.0.8 to `ERAS-BE/test/Eras.Infrastructure.Tests/Eras.Infrastructure.Tests.csproj` and verify `dotnet restore` succeeds
- [x] 1.2 Write the AC test `BackfillEvaluationPollsMigrationTests.Up_SkipsInstancesOfEvaluationsThatNoLongerExistInsteadOfFailing` for (AC-1) in `ERAS-BE/test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Migrations/`, tagged `Change` and `AC`, running the migration's `UpOperations` SQL on SQLite in-memory with `PRAGMA foreign_keys = ON`, and verify it fails with a foreign key error against the original SQL
- [x] 1.3 Write the AC test `BackfillEvaluationPollsMigrationTests.Up_LinksEachPollWithInstancesToItsEvaluation` for (AC-2) in the same file, tagged `Change` and `AC`, and verify it passes (behavior kept)
- [x] 1.4 Write the AC test `BackfillEvaluationPollsMigrationTests.Up_IgnoresInstancesWithoutEvaluation` for (AC-3) in the same file, tagged `Change` and `AC`, and verify it passes (behavior kept)
- [x] 1.5 Write the AC test `BackfillEvaluationPollsMigrationTests.Up_KeepsExistingLinksAndCanRunTwice` for (AC-4) in the same file, tagged `Change` and `AC`, and verify it passes (behavior kept)
- [x] 1.6 Add `JOIN evaluation e ON e."Id" = pi."EvaluationId"` to the backfill SQL in `ERAS-BE/src/Eras.Infrastructure/Persistence/PostgreSQL/Migrations/20261009150000_BackfillEvaluationPolls.cs` and update its XML summary for (AC-1), and verify all four tests from 1.2–1.5 pass

## 2. Infra

- [x] 2.1 Replace the `push` trigger of `.github/workflows/workflow.yml` with `workflow_dispatch` so `Automatic deploy process` is manual-only, and verify `on:` contains only `workflow_dispatch`

## 3. Verification

- [x] 3.1 BE gates (AGENTS.md section 5.6) pass in `ERAS-BE/`: `dotnet build Eras.sln -warnaserror`, `dotnet format Eras.sln --verify-no-changes`, `dotnet test Eras.sln`, coverage >= 25%
- [x] 3.2 The AC traceability check (AGENTS.md section 5.4) shows exactly 1 BE test per AC, and `openspec validate 571-skip-orphan-poll-instances-in-backfill --strict` passes

## Traceability
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | Orphan poll instances are skipped instead of failing the migration | BE | test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Migrations/BackfillEvaluationPollsMigrationTests.cs › Up_SkipsInstancesOfEvaluationsThatNoLongerExistInsteadOfFailing |
| AC-2 | Each poll with instances is linked once to its evaluation | BE | test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Migrations/BackfillEvaluationPollsMigrationTests.cs › Up_LinksEachPollWithInstancesToItsEvaluation |
| AC-3 | Poll instances without an evaluation are ignored | BE | test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Migrations/BackfillEvaluationPollsMigrationTests.cs › Up_IgnoresInstancesWithoutEvaluation |
| AC-4 | Existing links are kept and a second run adds nothing | BE | test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Migrations/BackfillEvaluationPollsMigrationTests.cs › Up_KeepsExistingLinksAndCanRunTwice |
