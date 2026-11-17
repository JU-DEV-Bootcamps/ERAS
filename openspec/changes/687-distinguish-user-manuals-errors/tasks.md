# Tasks

## 1. Backend (BE)

- [x] 1.1 Add the error contract in `ERAS-BE/Eras.Error/`: `IErrorCodeException`, and `UserManualsException` with `UserManualsErrorCodes` and the four named constructors of design D2 (fixed friendly text, separate log message, status 500/500/500/404); verify `dotnet build Eras.sln -warnaserror` succeeds
- [x] 1.2 Write the AC test `FileSystemUserManualCatalogTests.ListAsync_NoManifest_ThrowsManifestMissingAsync` for (AC-1) in `ERAS-BE/test/Eras.Infrastructure.Tests/UserManuals/`, tagged `Change` and `AC` (`687-distinguish-user-manuals-errors/AC-1`), asserting code `manuals_manifest_missing` and status 500, and verify it fails for the right reason
- [x] 1.3 Write the AC test `ListAsync_UnknownFormat_ThrowsManifestInvalidAsync` for (AC-2) in the same file, asserting code `manuals_manifest_invalid` and status 500, and verify it fails
- [x] 1.4 Write the AC test `OpenAsync_DeclaredFileMissing_ThrowsFileMissingAsync` for (AC-3) in the same file, asserting code `manuals_file_missing` and status 500, and verify it fails
- [x] 1.5 Write the AC test `OpenAsync_OneInvalidEntry_FailsEvenForAValidManualAsync` for (AC-22) in the same file, with a valid manual "manual-de-usuario-eras-v2-pdf" and an invalid "student-guide" (format "docx"), and verify it fails
- [x] 1.6 Write the AC test `OpenAsync_DeclaredFileMissing_LogsTheManualAndTheFileAsync` for (AC-6) in the same file: subscribe to `OnLoggingException`, call `LogException()` and assert the entry names the manual id and the file name and says the file is missing; verify it fails
- [x] 1.7 Write the AC test `ListAsync_UnknownFormat_LogsTheManualAndTheProblemAsync` for (AC-7) in the same file, asserting the entry names "student-guide" and says the format "docx" is not supported; verify it fails
- [x] 1.8 Implement the catalog in `ERAS-BE/src/Eras.Infrastructure/UserManuals/FileSystemUserManualCatalog.cs` for (AC-1, AC-2, AC-3, AC-6, AC-7, AC-22): eager `Declared()` that translates the file-system and JSON failures and checks every entry, and `FileMissing` in `OpenAsync`; verify the tests from 1.2 to 1.7 pass
- [x] 1.9 Update the untagged test `ListAsync_FileNameWithPath_IsRejectedAsync` to expect `UserManualsException` (`manuals_manifest_invalid`), and add untagged tests for a manifest that is not valid JSON and for a manifest problem found on a download; verify they pass
- [x] 1.10 Write the AC test `DownloadUserManualQueryHandlerTests.HandleAsync_UndeclaredId_ThrowsNotFoundWithCodeAsync` for (AC-4) in `ERAS-BE/test/Eras.Application.Tests/Features/UserManuals/`, asserting status 404 and code `manuals_not_found`, and verify it fails
- [x] 1.11 Write the AC test `HandleAsync_UndeclaredId_LogsTheRequestedIdentifierAsync` for (AC-24) in the same file, asserting the log message names "does-not-exist" and says no manual is declared with it, and verify it fails
- [x] 1.12 Implement `DownloadUserManualQueryHandler` in `ERAS-BE/src/Eras.Application/Features/UserManuals/Handlers/` for (AC-4, AC-24): throw `UserManualsException.NotFound(Request.Id)`, with line breaks removed from the logged id; update the #640 AC-12 test to expect `UserManualsException` (404); verify 1.10, 1.11 and that test pass
- [x] 1.13 Write the AC test `ErrorFilterTests.OnActionExecuted_ErrorCodeException_ReturnsCodeAndMessageWithoutDetails` for (AC-5) in `ERAS-BE/test/Eras.Api.Tests/Filters/`, using a `UserManualsException` whose log message holds a folder path, asserting the body holds the code and the fixed message and no path and no stack trace, and verify it fails
- [x] 1.14 Implement `ErrorFilter` and `ErrorCodeResponse` in `ERAS-BE/src/Eras.Api/Filters/` for (AC-5): return `ErrorCodeResponse` for an `IErrorCodeException`, the plain string for any other; add `[ProducesResponseType(typeof(ErrorCodeResponse), ...)]` for 404 and 500 to `UserManualsController`; add an untagged test that a plain `ErasException` keeps its string body; verify 1.13 passes and the existing `ErrorFilterTests` still pass

## 2. Frontend (FE)

- [x] 2.1 Add `ERAS-FE/src/app/core/models/user-manual-error.model.ts` with `UserManualErrorCode` and `UserManualsApiError` (design D5); verify `npm run build` compiles
- [x] 2.2 Write an untagged spec `ERAS-FE/src/app/core/services/api/user-manuals.service.spec.ts` that turns a JSON error body and a `Blob` error body into the right code, and an unknown or non-JSON body into an empty code, for `list` and `download`; verify it fails
- [x] 2.3 Implement the error mapping in `ERAS-FE/src/app/core/services/api/user-manuals.service.ts` and verify the spec from 2.2 passes
- [x] 2.4 Write the spec `[687-distinguish-user-manuals-errors/AC-8] shows the manifest-missing message when the list fails with that code` for (AC-8) in `ERAS-FE/src/app/modules/user-manuals/user-manuals.component.spec.ts`, and verify it fails
- [x] 2.5 Write the spec `[687-distinguish-user-manuals-errors/AC-9] shows the manifest-invalid message when the list fails with that code` for (AC-9) in the same file, and verify it fails
- [x] 2.6 Write the spec `[687-distinguish-user-manuals-errors/AC-10] shows the file-missing message and downloads nothing when the download fails with that code` for (AC-10) in the same file, and verify it fails
- [x] 2.7 Write the spec `[687-distinguish-user-manuals-errors/AC-11] shows the not-found message and downloads nothing when the download fails with that code` for (AC-11) in the same file, and verify it fails
- [x] 2.8 Write the spec `[687-distinguish-user-manuals-errors/AC-12] shows the generic message when the list fails without a known code` for (AC-12) in the same file, and verify it passes with the current behavior and keeps passing after 2.10
- [x] 2.9 Write the spec `[687-distinguish-user-manuals-errors/AC-23] clears the error message when a later download succeeds` for (AC-23) in the same file, and verify it fails
- [x] 2.10 Implement the messages in `ERAS-FE/src/app/core/constants/messages.ts` and the component in `ERAS-FE/src/app/modules/user-manuals/user-manuals.component.ts` for (AC-8, AC-9, AC-10, AC-11, AC-12, AC-23): message by code with the `LOAD_ERROR` fallback, error cleared when a download succeeds; verify the specs from 2.4 to 2.9 pass

## 3. Manuals folder and README (BE tests, parent repository)

- [x] 3.1 Write the AC test `UserManualsFolderValidatorTests.Validate_ReadmeNotDeclared_HasNoProblems` for (AC-14) in `ERAS-BE/test/Eras.Infrastructure.Tests/UserManuals/`, and verify it fails
- [x] 3.2 Implement the exemption in `ERAS-BE/src/Eras.Infrastructure/UserManuals/UserManualsFolderValidator.cs` for (AC-14), with the README name as a constant in `UserManualsManifest.cs`, and verify the test from 3.1 passes
- [x] 3.3 Write the new tags of the four existing validator tests, re-tagging `Validate_DeclaredFileMissing_FailsNamingTheFile` (AC-17), `Validate_FileNotDeclared_FailsNamingTheFile` (AC-21), `Validate_PdfWithWrongContent_FailsNamingTheFile` (AC-18) and `Validate_FileOverMaxSize_FailsNamingTheFile` (AC-19) to `687-distinguish-user-manuals-errors/AC-<n>` and verify they pass
- [x] 3.4 Write the AC test `UserManualsReadmeTests.Readme_GuidesTheLocalWorkflowStepByStep` for (AC-13) in `ERAS-BE/test/Eras.Infrastructure.Tests/UserManuals/UserManualsReadmeTests.cs` (new file), using `ParentRepository.ManualsFolder()` and doing nothing when it is not found, and verify it fails for the right reason in a full checkout
- [x] 3.5 Write the AC test `Readme_ExplainsEachErrorCode` for (AC-25) in the same file, and verify it fails in a full checkout
- [x] 3.6 Write `manuals/README.md` in the parent repository for (AC-13, AC-25) as in design D6 and the Infra table, and verify the tests from 3.4 and 3.5 pass and `Validate_RealManualsFolder_HasNoProblems` still passes
- [x] 3.7 Follow the README on a clean checkout to check that its steps work: run the backend outside Docker with `UserManuals__Path` set and open `GET api/v1/manuals`; then stop the stack and check that the page shows the manifest-missing message
- [x] 3.8 Write the regression test for (AC-13) by extending `UserManualsReadmeTests.Readme_GuidesTheLocalWorkflowStepByStep` in `ERAS-BE/test/Eras.Infrastructure.Tests/UserManuals/UserManualsReadmeTests.cs` (same single AC tag): the README must mention Visual Studio, say that a variable set in a terminal does not reach the debugger, and give the `dotnet user-secrets set "UserManuals:Path"` step; verify it fails
- [x] 3.9 Fix `manuals/README.md` for (AC-13): in "With the backend outside Docker" make user-secrets the main numbered step (not versioned, survives restarts), add the Visual Studio note, keep the environment variable as an alternative for a shell run, and say that the Docker stack is optional when it is only used for Keycloak and the database; verify the test from 3.8 passes and `Validate_RealManualsFolder_HasNoProblems` still passes

- [x] 3.10 Fix the wording of `manuals/README.md` for (AC-13): the manuals mount already exists since #640, so say that `docker compose up --build` is needed once only if the stack was started before the mount existed; verify the README tests (AC-13, AC-25) still pass (they check topics, not wording)

## 4. Verification

- [x] 4.1 BE gates of AGENTS.md section 8.7 pass in `ERAS-BE/`: `dotnet build Eras.sln -warnaserror`, `dotnet format Eras.sln --verify-no-changes`, `dotnet test Eras.sln`, coverage >= 25%, and `dotnet test Eras.sln --filter "FullyQualifiedName~UserManuals"` passes
- [x] 4.2 FE gates of AGENTS.md section 8.7 pass in `ERAS-FE/`: `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (>= 15%), `npm run build`
- [x] 4.3 The AC traceability check (AGENTS.md section 8.6) shows exactly 1 test per AC per affected side, and `openspec validate 687-distinguish-user-manuals-errors --strict` passes

## Traceability
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | A missing manifest is reported on the list | BE | test/Eras.Infrastructure.Tests/UserManuals/FileSystemUserManualCatalogTests.cs › ListAsync_NoManifest_ThrowsManifestMissingAsync |
| AC-2 | An invalid manifest is reported on the list | BE | test/Eras.Infrastructure.Tests/UserManuals/FileSystemUserManualCatalogTests.cs › ListAsync_UnknownFormat_ThrowsManifestInvalidAsync |
| AC-3 | A declared file missing from the folder is reported on the download | BE | test/Eras.Infrastructure.Tests/UserManuals/FileSystemUserManualCatalogTests.cs › OpenAsync_DeclaredFileMissing_ThrowsFileMissingAsync |
| AC-4 | An undeclared manual is reported with its own code | BE | test/Eras.Application.Tests/Features/UserManuals/DownloadUserManualQueryHandlerTests.cs › HandleAsync_UndeclaredId_ThrowsNotFoundWithCodeAsync |
| AC-5 | The response does not expose internal details | BE | test/Eras.Api.Tests/Filters/ErrorFilterTests.cs › OnActionExecuted_ErrorCodeException_ReturnsCodeAndMessageWithoutDetails |
| AC-6 | A missing file is logged with the manual and the file | BE | test/Eras.Infrastructure.Tests/UserManuals/FileSystemUserManualCatalogTests.cs › OpenAsync_DeclaredFileMissing_LogsTheManualAndTheFileAsync |
| AC-7 | An invalid manifest entry is logged with the manual and the problem | BE | test/Eras.Infrastructure.Tests/UserManuals/FileSystemUserManualCatalogTests.cs › ListAsync_UnknownFormat_LogsTheManualAndTheProblemAsync |
| AC-8 | A missing manifest shows its message on the list | FE | src/app/modules/user-manuals/user-manuals.component.spec.ts › [687-distinguish-user-manuals-errors/AC-8] shows the manifest-missing message when the list fails with that code |
| AC-9 | An invalid manifest shows its message on the list | FE | src/app/modules/user-manuals/user-manuals.component.spec.ts › [687-distinguish-user-manuals-errors/AC-9] shows the manifest-invalid message when the list fails with that code |
| AC-10 | A missing file shows its message on the download | FE | src/app/modules/user-manuals/user-manuals.component.spec.ts › [687-distinguish-user-manuals-errors/AC-10] shows the file-missing message and downloads nothing when the download fails with that code |
| AC-11 | A manual that no longer exists shows its message on the download | FE | src/app/modules/user-manuals/user-manuals.component.spec.ts › [687-distinguish-user-manuals-errors/AC-11] shows the not-found message and downloads nothing when the download fails with that code |
| AC-12 | A failure without a known code shows the generic message | FE | src/app/modules/user-manuals/user-manuals.component.spec.ts › [687-distinguish-user-manuals-errors/AC-12] shows the generic message when the list fails without a known code |
| AC-13 | The README guides the local workflow step by step | BE | test/Eras.Infrastructure.Tests/UserManuals/UserManualsReadmeTests.cs › Readme_GuidesTheLocalWorkflowStepByStep |
| AC-14 | The README is not reported as an undeclared file | BE | test/Eras.Infrastructure.Tests/UserManuals/UserManualsFolderValidatorTests.cs › Validate_ReadmeNotDeclared_HasNoProblems |
| AC-17 | A declared manual without its file fails the validation | BE | test/Eras.Infrastructure.Tests/UserManuals/UserManualsFolderValidatorTests.cs › Validate_DeclaredFileMissing_FailsNamingTheFile |
| AC-18 | A file whose content does not match its declared type fails the validation | BE | test/Eras.Infrastructure.Tests/UserManuals/UserManualsFolderValidatorTests.cs › Validate_PdfWithWrongContent_FailsNamingTheFile |
| AC-19 | A file over the maximum size fails the validation | BE | test/Eras.Infrastructure.Tests/UserManuals/UserManualsFolderValidatorTests.cs › Validate_FileOverMaxSize_FailsNamingTheFile |
| AC-21 | A file that is not declared fails the validation | BE | test/Eras.Infrastructure.Tests/UserManuals/UserManualsFolderValidatorTests.cs › Validate_FileNotDeclared_FailsNamingTheFile |
| AC-22 | One invalid manifest entry fails the download of every manual | BE | test/Eras.Infrastructure.Tests/UserManuals/FileSystemUserManualCatalogTests.cs › OpenAsync_OneInvalidEntry_FailsEvenForAValidManualAsync |
| AC-23 | A later successful download clears the error message | FE | src/app/modules/user-manuals/user-manuals.component.spec.ts › [687-distinguish-user-manuals-errors/AC-23] clears the error message when a later download succeeds |
| AC-24 | A manual that is not declared is logged with its identifier | BE | test/Eras.Application.Tests/Features/UserManuals/DownloadUserManualQueryHandlerTests.cs › HandleAsync_UndeclaredId_LogsTheRequestedIdentifierAsync |
| AC-25 | The README explains each error code of the page | BE | test/Eras.Infrastructure.Tests/UserManuals/UserManualsReadmeTests.cs › Readme_ExplainsEachErrorCode |
