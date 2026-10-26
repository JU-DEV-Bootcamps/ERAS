# Design

## Context

`ERAS-BE/src/Eras.Infrastructure/Persistence/PostgreSQL/Migrations/20261009150000_BackfillEvaluationPolls.cs`
is a data-only, insert-only EF Core migration. Its `Up` runs one SQL statement that inserts into
`evaluation_poll (evaluation_id, poll_id)` every distinct pair found by joining `poll_instances` to
`polls` on `uuid`, filtered by `EvaluationId IS NOT NULL` and a `NOT EXISTS` against `evaluation_poll`.
`Down` is intentionally empty. `evaluation_poll.evaluation_id` has a foreign key to `evaluation."Id"`,
so a `poll_instances` row whose `EvaluationId` no longer exists aborts the whole statement, and since
migrations run on API startup the API never comes up.

The unfixed migration is in `develop`, `release/Release-19-10-2026` and `main`. The fix was written
on the ERAS-BE branch `fix/backfill-evaluation-polls-orphan-evaluations` (commit `b68346dc`) before
this change existed; this plan documents it and adds what AGENTS.md requires (AC tags, gates).

Migrations are not covered by any existing test. `ERAS-BE/test/Eras.Infrastructure.Tests/` uses
xUnit with EF InMemory, which cannot execute raw SQL nor enforce foreign keys.

Motivation and scope: see `proposal.md`.

## Goals / Non-Goals

**Goals:**
- The backfill completes on a database with orphan `poll_instances` and creates no link for them (AC-1).
- It still links every poll with instances to its existing evaluation (AC-2), ignores instances with
  no evaluation (AC-3) and keeps existing links while staying idempotent (AC-4).
- The migration's real SQL is exercised by tests with foreign keys enabled.
- `.github/workflows/workflow.yml` runs only on manual dispatch.

**Non-Goals:**
- No new migration, no schema change, no cleanup of orphan rows.
- No change to how the backfill treats polls, `uuid` matching or `NOT EXISTS` deduplication.

## Decisions

### D1. Edit the shipped migration in place instead of adding a new one
**Choice:** add `JOIN evaluation e ON e."Id" = pi."EvaluationId"` to the existing `INSERT ... SELECT`.
Databases where the migration already ran keep their rows and never run it again; databases where it
failed have no partial state because the single statement was rolled back.
**Alternative:** a new migration that first nulls orphan `EvaluationId` values → rejected: it deletes
data outside the ticket's scope, and the original migration would still fail before it runs.

### D2. Test the migration's real SQL on SQLite in-memory with foreign keys on
**Choice:** the test opens a `Microsoft.Data.Sqlite` in-memory connection, sets `PRAGMA foreign_keys = ON`,
creates minimal `evaluation`, `polls`, `poll_instances` and `evaluation_poll` tables with the same
column names and foreign keys as PostgreSQL, then executes every `SqlOperation` of
`new BackfillEvaluationPolls().UpOperations`. The SQL uses only standard constructs (`INSERT ... SELECT
DISTINCT`, `JOIN`, `NOT EXISTS`, quoted identifiers), so it runs unchanged on both engines. This makes
the original SQL fail in the orphan case with a foreign key error, as it does on PostgreSQL.
**Alternative:** a PostgreSQL container (Testcontainers) → rejected: new CI dependency and Docker
requirement for a one-statement migration; EF InMemory → rejected: cannot run raw SQL or enforce
foreign keys.

### D3. Keep the orphan-skipping in the SQL, not in a repair step
**Choice:** skipping is a filter inside the same statement, so behavior is identical whether the
database has zero or many orphans.
**Alternative:** a pre-step that nulls orphan references → rejected, see D1.

### D4. Make `Automatic deploy process` manual-only rather than deleting it
**Choice:** replace the `push` trigger with `workflow_dispatch`, keeping the jobs untouched, as the
ticket asks. It stops the red X on every merge to `develop` without removing a workflow someone may
still want to run by hand.
**Alternative:** delete the file → rejected: wider than the ticket; a separate decision.

## Changes by layer

### Backend (`ERAS-BE/`)

| Layer | Change | Files | ACs |
|---|---|---|---|
| Infrastructure | Add `JOIN evaluation e ON e."Id" = pi."EvaluationId"` to the backfill SQL; update the XML summary | `src/Eras.Infrastructure/Persistence/PostgreSQL/Migrations/20261009150000_BackfillEvaluationPolls.cs` | AC-1 |
| Infrastructure tests | New test class running the migration SQL on SQLite with foreign keys on; add `Microsoft.Data.Sqlite` 9.0.8 (same version as the EF packages) | `test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Migrations/BackfillEvaluationPollsMigrationTests.cs`, `test/Eras.Infrastructure.Tests/Eras.Infrastructure.Tests.csproj` | AC-1..AC-4 |

### Infra / CI

| Piece | Change | Files |
|---|---|---|
| GitHub Actions | `on:` becomes `workflow_dispatch` only (remove `push` to `develop`); jobs unchanged | `.github/workflows/workflow.yml` (parent repo) |

## API contract

No API change.

## Data and migration

No schema change. The existing migration `20261009150000_BackfillEvaluationPolls` is edited in place
(D1). Rollback: none needed; `Down` stays empty and the inserted rows are valid data.

## Test strategy

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Migrations/` | `BackfillEvaluationPollsMigrationTests.cs` › `Up_SkipsInstancesOfEvaluationsThatNoLongerExistInsteadOfFailing` |
| AC-2 | BE | Infrastructure: same file | `BackfillEvaluationPollsMigrationTests.cs` › `Up_LinksEachPollWithInstancesToItsEvaluation` |
| AC-3 | BE | Infrastructure: same file | `BackfillEvaluationPollsMigrationTests.cs` › `Up_IgnoresInstancesWithoutEvaluation` |
| AC-4 | BE | Infrastructure: same file | `BackfillEvaluationPollsMigrationTests.cs` › `Up_KeepsExistingLinksAndCanRunTwice` |

Each test is tagged `[Trait("Change", "571-skip-orphan-poll-instances-in-backfill")]` and
`[Trait("AC", "571-skip-orphan-poll-instances-in-backfill/AC-<n>")]`. The AC-1 test must fail with a
foreign key error when the `JOIN evaluation` line is removed, which proves it exercises the original
failure. Coverage gate: BE >= 25% (the migration class is `ExcludeFromCodeCoverage`, as all migrations are).

## Risks / Trade-offs

- [SQLite and PostgreSQL could diverge on SQL semantics] → the statement uses only portable SQL; the
  tests assert exact row sets, so any engine-specific difference in the statement would show up as a
  failing assertion when the SQL is next edited.
- [A database where the migration already ran keeps links that point to orphan evaluations] →
  impossible: the foreign key would have rejected them, so such databases only hold valid links.
- [Release branch drift] → the fix is one commit on top of the migration file; cherry-pick to
  `release/Release-19-10-2026` applies cleanly as long as that file is untouched there (it is).

## Migration Plan

1. Merge the ERAS-BE PR into `develop`; open a second PR (cherry-pick) into `release/Release-19-10-2026`.
2. Before releasing, run the orphan-count query from the issue against production. The fix makes the
   migration survive orphans either way; the query only tells whether the follow-up cleanup matters now.
3. Bump the submodule pointer in the parent repo together with the `workflow.yml` change.

## Follow-ups

- Find out why `poll_instances` end up pointing to deleted evaluations (likely deleting an evaluation
  does not remove its poll instances) and decide whether to add a cascade, a guard, or a cleanup.
- Decide whether `Automatic deploy process` should be deleted outright once nobody runs it by hand.
- No other BE test carries `Change`/`AC` traits yet; this change introduces the convention in the test suite.
- `dotnet format --verify-no-changes` already fails on `develop` for import ordering in 5 test files this change does not touch; fix them in their own tooling change.
