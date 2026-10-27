# Proposal

**Status:** Draft

## Why

The Definition of Done requires `dotnet format Eras.sln --verify-no-changes` to pass (AGENTS.md, BE gates). On a clean export of `develop` it reports 1444 errors, so the gate is red for every backend change before anyone edits a file. It went unnoticed because no active workflow runs it: `ERAS-BE/.github/workflows/format-warning-check.sample` is a sample, and `pr_workflow.yaml` and `push_workflow.yaml` do not call `dotnet format`. It was found while verifying change `642-search-students-by-name`, whose own code adds no error (the same 1444 appear on `develop` and on the branch). Issue: ERAS-BE#578.

## What Changes

- Run `dotnet format Eras.sln` once in `ERAS-BE/`, on a branch cut from the latest `develop`, so that `dotnet format Eras.sln --verify-no-changes` exits 0.
- The diff must be mechanical only (whitespace, charset and `using` order as reported by the formatter): no renames, no logic, no migration, no change to `appsettings*.json`.
- Prove it is behavior-neutral: `dotnet build Eras.sln -warnaserror` and `dotnet test Eras.sln` give the same results as before the format.

**Dry run (2026-10-27, scratch copy of a `develop` export, nothing committed):** `dotnet format Eras.sln` fixed the 1444 errors (`--verify-no-changes` then exits 0), touching 484 files (+1541/-946). Ignoring whitespace, 86 files still change, all `using` order and object-initializer commas. `dotnet build -warnaserror` gave 0 warnings and 0 errors and all 1897 tests passed. **25 of those files are applied migrations**, changed by whitespace only (no snapshot, no non-whitespace line). AGENTS.md says never to edit an applied migration; EF identifies a migration by its file name and `[Migration]` id, not its text, so the reviewer must accept this exception explicitly, or the formatter must be told to skip the `Migrations/` folder (an `.editorconfig` change).

**Out of scope:** making CI enforce the format gate (a follow-up, possibly an ADR), frontend formatting and lint, and any fix that is not a formatter fix. Edited legacy files keep their code as is.

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Submodules:** `ERAS-BE` only (one PR with a large mechanical diff), plus the parent pointer bump
- **Roles / who can do what:** no change
- **API contract:** none
- **Data / migration:** none
- **Risk:** the diff touches many files, so open backend branches will conflict on those lines. Merge it at a quiet moment and announce it, and have open branches take `develop` after it lands.

No behavior changes, so this change sets `skip_specs: true` (AGENTS.md section 3, tooling and refactors).
