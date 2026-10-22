# Tasks

<!-- ILLUSTRATIVE EXAMPLE of a filled-in tasks.md for the fictional change in sdd-spec/examples. Do not copy its content. -->

## 1. Backend (BE)

- [ ] 1.1 Write the test `HandleAsync_DuplicateActiveName_Throws409AndDoesNotPersistAsync` for (AC-1) in `ERAS-BE/test/Eras.Application.Tests/Features/Configurations/`, tagged `Change` and `AC`, and verify it fails because no duplicate check exists
- [ ] 1.2 Add `ExistsActiveByNameAsync` to the repository interface and its PostgreSQL implementation, and verify the project builds
- [ ] 1.3 Reject the duplicate in the create handler with a 409 `BussinessException` for (AC-1) and verify the test from 1.1 passes
- [ ] 1.4 Write the test `HandleAsync_InactiveNameReused_CreatesActiveConfigurationAsync` for (AC-2) and verify it passes against the handler from 1.3 and fails when the "active only" condition is removed temporarily (a guard test)
- [ ] 1.5 Write the test `HandleAsync_BlankName_Throws400Async` for (AC-6) and verify it fails
- [ ] 1.6 Reject blank names in the create handler for (AC-6) and verify the test from 1.5 passes
- [ ] 1.7 Write the test `Create_ProfessionalRole_Returns403Async` for (AC-4) in `ERAS-BE/test/Eras.Api.Tests/Controllers/` and verify it fails
- [ ] 1.8 Apply `[Authorize(Policy = ErasPolicies.RequireErasAdminOrOfficer)]` to the create action for (AC-4) and verify the test from 1.7 passes

## 2. Frontend (FE)

- [ ] 2.1 Write the spec `[608-reject-duplicate-configuration-name/AC-3] shows the conflict message next to the name field` for (AC-3) and verify it fails
- [ ] 2.2 Show the API message next to the name field on a 409 for (AC-3), with the text in `core/constants/messages.ts`, and verify the spec from 2.1 passes
- [ ] 2.3 Write the spec `[608-reject-duplicate-configuration-name/AC-6] shows the blank-name message and keeps the form open` for (AC-6) and verify it fails
- [ ] 2.4 Show the blank-name message and keep the form open on a 400 for (AC-6) and verify the spec from 2.3 passes
- [ ] 2.5 Write the spec `[608-reject-duplicate-configuration-name/AC-5] redirects a user with no ERAS role to access denied` for (AC-5) and verify it fails
- [ ] 2.6 Limit the roles of the create route in `ROUTE_METADATA` for (AC-5) and verify the spec from 2.5 passes

## 3. Verification

- [ ] 3.1 BE gates pass in `ERAS-BE/`: `dotnet build Eras.sln -warnaserror`, `dotnet format Eras.sln --verify-no-changes`, `dotnet test Eras.sln`, coverage >= 25% (AGENTS.md section 5.6)
- [ ] 3.2 FE gates pass in `ERAS-FE/`: `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (>= 15%), `npm run build` (AGENTS.md section 5.6)
- [ ] 3.3 The AC traceability check (AGENTS.md section 5.4) shows exactly 1 test per AC per affected side, and `openspec validate 608-reject-duplicate-configuration-name --strict` passes

## Traceability
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | Duplicate active name is rejected | BE | test/Eras.Application.Tests/Features/Configurations/CreateConfigurationCommandHandlerTests.cs › HandleAsync_DuplicateActiveName_Throws409AndDoesNotPersistAsync |
| AC-2 | Name of an inactive configuration can be reused | BE | test/Eras.Application.Tests/Features/Configurations/CreateConfigurationCommandHandlerTests.cs › HandleAsync_InactiveNameReused_CreatesActiveConfigurationAsync |
| AC-3 | Conflict message is shown on the form | FE | src/app/modules/settings/.../configuration-form.component.spec.ts › [608-reject-duplicate-configuration-name/AC-3] shows the conflict message next to the name field |
| AC-4 | Professional cannot create a configuration | BE | test/Eras.Api.Tests/Controllers/ConfigurationsControllerTests.cs › Create_ProfessionalRole_Returns403Async |
| AC-5 | Guest cannot reach the create form | FE | src/app/core/utils/routing/route-metadata.spec.ts › [608-reject-duplicate-configuration-name/AC-5] redirects a user with no ERAS role to access denied |
| AC-6 | Blank name is rejected | BE | test/Eras.Application.Tests/Features/Configurations/CreateConfigurationCommandHandlerTests.cs › HandleAsync_BlankName_Throws400Async |
| AC-6 | Blank name is rejected | FE | src/app/modules/settings/.../configuration-form.component.spec.ts › [608-reject-duplicate-configuration-name/AC-6] shows the blank-name message and keeps the form open |
