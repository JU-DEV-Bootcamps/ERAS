# Tasks

## 1. Baseline

- [x] 1.1 In `ERAS-BE/`, on a branch cut from the latest `develop`, run `dotnet format Eras.sln --verify-no-changes` and record the error count (1444 on 2026-10-27), and verify the count matches `develop`
- [x] 1.2 Run `dotnet build Eras.sln -warnaserror` and `dotnet test Eras.sln` before formatting, and record the number of passing tests

## 2. Format

- [x] 2.1 Run `dotnet format Eras.sln`, and verify `dotnet format Eras.sln --verify-no-changes` exits 0
- [x] 2.2 Review the diff and verify it holds only formatter changes (whitespace, charset, `using` order, initializer commas): `git diff --ignore-all-space --ignore-blank-lines` shows no other kind of line, and no `appsettings*.json` or model snapshot changed
- [x] 2.3 Handle the 25 applied migration files as the reviewer decided (whitespace-only changes accepted, or `Migrations/` excluded in `.editorconfig`), and verify `git diff --ignore-all-space --ignore-blank-lines -- '*/Migrations/*'` is empty and `dotnet format Eras.sln --verify-no-changes` still exits 0

## 3. Verification

- [x] 3.1 Run `dotnet build Eras.sln -warnaserror` and verify 0 warnings and 0 errors
- [x] 3.2 Run `dotnet test Eras.sln --collect:"XPlat Code Coverage" --results-directory ./TestResults --settings coverlet.runsettings` and verify the same number of passing tests as task 1.2 and coverage of at least 25%
- [x] 3.3 Run `openspec validate "578-fix-dotnet-format-baseline" --strict` and verify it passes

## 4. Ship

- [ ] 4.1 Open the `ERAS-BE` PR linking `openspec/changes/578-fix-dotnet-format-baseline`, announce the merge window to the team, and after it merges bump the parent pointer
