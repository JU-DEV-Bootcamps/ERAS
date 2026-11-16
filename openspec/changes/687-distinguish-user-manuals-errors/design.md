# Design

## Context

The motivation is in `proposal.md`; the behavior is in `specs/user-manuals/spec.md`. This change builds on the manuals feature of #640 (ADR-0004).

- **Where a manuals failure is born today.** `FileSystemUserManualCatalog` (`ERAS-BE/src/Eras.Infrastructure/UserManuals/`) reads `manifest.json` through `UserManualsManifest.Read`. A missing manifest throws `FileNotFoundException` or `DirectoryNotFoundException`, bad JSON throws `JsonException`, an invalid entry throws `InvalidDataException`, and a declared file that is not in the folder throws `FileNotFoundException` from `File.OpenRead`. `Declared()` is a lazy iterator, so whether a bad entry fails a download depends on the order of the entries.
- **Where it becomes a response.** `ErrorFilter` (`ERAS-BE/src/Eras.Api/Filters/ErrorFilter.cs`) wraps any exception raised inside an action: an `IErasException` keeps its status code, anything else becomes a `CriticalException` (500). In both cases the body is only `FriendlyMessage`, a plain string, and the detail goes to the log through `LogException()`. So today these responses carry no path and no stack trace but also no code. `ExceptionHandlerMiddleware` does return `StackTrace`, but only for exceptions that escape the filters, which these do not.
- **Undeclared manual.** `DownloadUserManualQueryHandler` throws `NotFoundException` (404, plain string body).
- **Folder validator.** `UserManualsFolderValidator` reports every file of `manuals/` that is not declared, except `manifest.json`. A `README.md` would fail it, and the real-folder test and the `manuals-validation.yml` workflow with it.
- **FE.** `UserManualsComponent` sets one message, `USER_MANUALS_MESSAGES.LOAD_ERROR`, for any error of the list or the download. `UserManualsApiService.download` uses `responseType: 'blob'`, so an error body arrives as a `Blob`. The component never clears its error signal.
- **Deployment.** `docker-compose.yml`, `docker-compose.local.yml` and `deploy/compose.prod.yml` already mount `manuals/` read-only at `/app/manuals`; nothing changes there.

## Goals / Non-Goals

**Goals:**
- Error codes, no leaks and logs: AC-1 to AC-7, AC-22, AC-24 (BE).
- Specific messages and the cleared message: AC-8 to AC-12, AC-23 (FE).
- README and its validation exemption: AC-13, AC-14, AC-25, and the re-keyed AC-17, AC-18, AC-19, AC-21 (BE).

**Non-Goals:**
- Changing the `{ message }` shape of any other endpoint: only exceptions that declare a code get the new body.
- Touching `ExceptionHandlerMiddleware` (see Follow-ups).
- Any change to the manifest format, the compose mounts, the CODEOWNERS rule or the workflow.

## Decisions

### D1. An exception that declares an error code gets a `{ code, message }` body
**Choice:** add `IErrorCodeException` (property `ErrorCode`) in `Eras.Error`. `ErrorFilter` returns the new record `ErrorCodeResponse(Code, Message)` as the body when the exception implements it, and keeps returning the plain `FriendlyMessage` for every other exception, so no other endpoint changes. The JSON is camelCase (`code`, `message`), as the API already serializes.
**Alternative:** a response header such as `X-Error-Code` → the FE could read it from the blob download without parsing, but a custom header has to be exposed through CORS and a body is what a client would normally read. Changing the body of all errors → breaks every other endpoint and its callers.

### D2. One exception type carries the four causes, the friendly text and the log text
**Choice:** `UserManualsException` (new, `Eras.Error/Bussiness/`) extends `ErasException` and implements `IErrorCodeException`. It has four named constructors, one per cause: `ManifestMissing(folder)`, `ManifestInvalid(problem)`, `FileMissing(id, fileName, folder)` and `NotFound(id)`. Each one sets the status (500, 500, 500, 404), the code (`manuals_manifest_missing`, `manuals_manifest_invalid`, `manuals_file_missing`, `manuals_not_found`), a **fixed** friendly message without any path, and a separate log message with the detail (the manual or the manifest, the file, the folder and the problem). `LogException()` writes the log message; the severity is `ERROR` for the three server-side causes and `WARNING` for `NotFound`. The code values live in a `UserManualsErrorCodes` constants class next to it. The pattern copies `ExistingEvaluationNameException`, which also keeps its log message apart from the friendly one.
**Alternative:** add an `ErrorCode` to `BussinessException` → touches a shared type for one feature. Throw four exception classes → four files with the same shape.

### D3. The catalog translates the file-system failures and validates every entry up front
**Choice:** in `FileSystemUserManualCatalog`, `Declared()` becomes an eager method: it reads the manifest, turns `FileNotFoundException` and `DirectoryNotFoundException` into `ManifestMissing`, `JsonException` into `ManifestInvalid`, and checks **every** entry before returning, throwing `ManifestInvalid` with the manual id and the reason (empty id, file name with a path, unknown format) for the first bad one. So one bad entry fails the list and every download (AC-22), whatever the order. `OpenAsync` turns a `FileNotFoundException` or `DirectoryNotFoundException` from `File.OpenRead` into `FileMissing`. An undeclared id still returns null; the handler turns that into `NotFound` (D4). `UserManualsManifest.Read` stays as it is, because the validator relies on its exceptions.
**Alternative:** translate in the handlers → the Application layer would need to know about files. Keep the lazy iterator → AC-22 would depend on the order of the entries.

### D4. The handler throws `NotFound` with the requested identifier
**Choice:** `DownloadUserManualQueryHandler` throws `UserManualsException.NotFound(Request.Id)` instead of `NotFoundException`. It keeps the 404, so AC-12 of #640 still holds; its test changes only the expected exception type. The identifier comes from the route, so the log message removes line breaks from it before writing it.
**Alternative:** keep `NotFoundException` → it cannot carry a code.

### D5. The page reads the code in the service and maps it to a message in the component
**Choice:** `UserManualsApiService` turns an `HttpErrorResponse` into `UserManualsApiError` (new, with the `code`), for the list and for the download. For the download the body is a `Blob`, so the service reads it as text and parses `{ code }`; a body that is not JSON, or a code that is not one of the four, leaves the code empty. The component keeps a map code → message in `USER_MANUALS_MESSAGES` and falls back to `LOAD_ERROR` when the code is empty or unknown (AC-12). Its error signal is cleared when a download succeeds (AC-23).
**Alternative:** parse the blob in the component → mixes transport and presentation, and the list would need another path.

### D6. The README is exempt from the folder validation by name
**Choice:** `UserManualsFolderValidator` skips `README.md` (and `manifest.json`, as today) when it looks for undeclared files (AC-14). The name is a constant next to `UserManualsManifest.FileName`. The README is written for the ACs and checked by two tests that read the real file, found the way `UserManualsCodeownersTests` finds `CODEOWNERS`: they do nothing when only ERAS-BE is checked out. The tests look for the topics of the ACs, not for exact wording (A7).
**Alternative:** declare the README in the manifest → it would be listed as a manual. Move the guide outside `manuals/` → the issue asks for `manuals/README.md`.

## Changes by layer

### Backend (`ERAS-BE/`)

| Layer | Change | Files | ACs |
|---|---|---|---|
| Errors | `IErrorCodeException` (new), `UserManualsException` and `UserManualsErrorCodes` (new) | `Eras.Error/IErrorCodeException.cs`, `Eras.Error/Bussiness/UserManualsException.cs` | AC-1 to AC-7, AC-22, AC-24 |
| Application | `DownloadUserManualQueryHandler` throws `UserManualsException.NotFound`; `GetUserManualsQueryHandler` unchanged | `src/Eras.Application/Features/UserManuals/Handlers/DownloadUserManualQueryHandler.cs` | AC-4, AC-24 |
| Infrastructure | Catalog: eager `Declared()`, exception translation, `FileMissing` in `OpenAsync`. Validator: skip `README.md`; constant for the name | `src/Eras.Infrastructure/UserManuals/FileSystemUserManualCatalog.cs`, `UserManualsFolderValidator.cs`, `UserManualsManifest.cs` | AC-1, AC-2, AC-3, AC-6, AC-7, AC-14, AC-22 |
| Api | `ErrorFilter` returns `ErrorCodeResponse` for code exceptions; `ErrorCodeResponse` (new); `UserManualsController` declares 404 and 500 with `ErrorCodeResponse` for Swagger | `src/Eras.Api/Filters/ErrorFilter.cs`, `src/Eras.Api/Filters/ErrorCodeResponse.cs`, `src/Eras.Api/Controllers/UserManualsController.cs` | AC-5 |

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Model | `UserManualErrorCode` (string union of the four codes) and `UserManualsApiError` (new) | `src/app/core/models/user-manual-error.model.ts` | AC-8 to AC-12 |
| Service | List and download map an `HttpErrorResponse` to `UserManualsApiError`; the blob body is read as text | `src/app/core/services/api/user-manuals.service.ts` | AC-8 to AC-11 |
| Component | Message by code with the generic fallback; the error is cleared when a download succeeds | `src/app/modules/user-manuals/user-manuals.component.ts` | AC-8 to AC-12, AC-23 |
| Messages | The four messages in `USER_MANUALS_MESSAGES` (the wording of the ACs) | `src/app/core/constants/messages.ts` | AC-8 to AC-11 |

### Infra / CI (parent repository)

| Item | Change | Files | ACs |
|---|---|---|---|
| README | New guide: numbered steps for the Docker stack and for the backend outside Docker, manifest fields, types and 10 MB, read-only mount, when `docker compose up` is needed (once after pulling the mount), `UserManuals__Path` in the environment and no personal path in shared settings, the validation command, and a table of the four error codes with cause and fix | `manuals/README.md` | AC-13, AC-25 |

The compose files, CODEOWNERS and `manuals-validation.yml` do not change; the workflow already runs on `manuals/**` and filters on `FullyQualifiedName~UserManuals`, so the new tests run in it.

## API contract

| Endpoint | Policy | Request DTO | Response DTO | Status codes |
|---|---|---|---|---|
| `GET api/v1/manuals` | `[Authorize]` (unchanged) | none | `UserManualDto[]` (unchanged); on failure `ErrorCodeResponse` { code: string, message: string } | 200, 401, 500 |
| `GET api/v1/manuals/{id}/download` | `[Authorize]` (unchanged) | none | file stream (unchanged); on failure `ErrorCodeResponse` | 200, 401, 404, 500 |

- **Codes:** `manuals_manifest_missing` (500), `manuals_manifest_invalid` (500), `manuals_file_missing` (500), `manuals_not_found` (404).
- **FE model:** `src/app/core/models/user-manual-error.model.ts` mirrors `ErrorCodeResponse` for the code; `UserManualModel` is unchanged.
- **FE service:** `src/app/core/services/api/user-manuals.service.ts`, methods `list` and `download` (no leading slash for `list`; `download` keeps its URL).
- **Ownership / scope rules:** none; every signed-in user may call both endpoints, as today.

## Data and migration
No schema change.

## Test strategy

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/UserManuals/` | `FileSystemUserManualCatalogTests.cs` › `ListAsync_NoManifest_ThrowsManifestMissingAsync` |
| AC-2 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/UserManuals/` | `FileSystemUserManualCatalogTests.cs` › `ListAsync_UnknownFormat_ThrowsManifestInvalidAsync` |
| AC-3 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/UserManuals/` | `FileSystemUserManualCatalogTests.cs` › `OpenAsync_DeclaredFileMissing_ThrowsFileMissingAsync` |
| AC-4 | BE | Application: `test/Eras.Application.Tests/Features/UserManuals/` | `DownloadUserManualQueryHandlerTests.cs` › `HandleAsync_UndeclaredId_ThrowsNotFoundWithCodeAsync` |
| AC-5 | BE | Api: `test/Eras.Api.Tests/Filters/` | `ErrorFilterTests.cs` › `OnActionExecuted_ErrorCodeException_ReturnsCodeAndMessageWithoutDetails` |
| AC-6 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/UserManuals/` | `FileSystemUserManualCatalogTests.cs` › `OpenAsync_DeclaredFileMissing_LogsTheManualAndTheFileAsync` |
| AC-7 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/UserManuals/` | `FileSystemUserManualCatalogTests.cs` › `ListAsync_UnknownFormat_LogsTheManualAndTheProblemAsync` |
| AC-22 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/UserManuals/` | `FileSystemUserManualCatalogTests.cs` › `OpenAsync_OneInvalidEntry_FailsEvenForAValidManualAsync` |
| AC-24 | BE | Application: `test/Eras.Application.Tests/Features/UserManuals/` | `DownloadUserManualQueryHandlerTests.cs` › `HandleAsync_UndeclaredId_LogsTheRequestedIdentifierAsync` |
| AC-13 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/UserManuals/` (new file) | `UserManualsReadmeTests.cs` › `Readme_GuidesTheLocalWorkflowStepByStep` |
| AC-25 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/UserManuals/` (new file) | `UserManualsReadmeTests.cs` › `Readme_ExplainsEachErrorCode` |
| AC-14 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/UserManuals/` | `UserManualsFolderValidatorTests.cs` › `Validate_ReadmeNotDeclared_HasNoProblems` |
| AC-17 | BE | Infrastructure: same file | `UserManualsFolderValidatorTests.cs` › `Validate_DeclaredFileMissing_FailsNamingTheFile` (re-tagged) |
| AC-21 | BE | Infrastructure: same file | `UserManualsFolderValidatorTests.cs` › `Validate_FileNotDeclared_FailsNamingTheFile` (re-tagged) |
| AC-18 | BE | Infrastructure: same file | `UserManualsFolderValidatorTests.cs` › `Validate_PdfWithWrongContent_FailsNamingTheFile` (re-tagged) |
| AC-19 | BE | Infrastructure: same file | `UserManualsFolderValidatorTests.cs` › `Validate_FileOverMaxSize_FailsNamingTheFile` (re-tagged) |
| AC-8 | FE | `src/app/modules/user-manuals/user-manuals.component.spec.ts` | `[687-distinguish-user-manuals-errors/AC-8] shows the manifest-missing message when the list fails with that code` |
| AC-9 | FE | same file | `[687-distinguish-user-manuals-errors/AC-9] shows the manifest-invalid message when the list fails with that code` |
| AC-10 | FE | same file | `[687-distinguish-user-manuals-errors/AC-10] shows the file-missing message and downloads nothing when the download fails with that code` |
| AC-11 | FE | same file | `[687-distinguish-user-manuals-errors/AC-11] shows the not-found message and downloads nothing when the download fails with that code` |
| AC-12 | FE | same file | `[687-distinguish-user-manuals-errors/AC-12] shows the generic message when the list fails without a known code` |
| AC-23 | FE | same file | `[687-distinguish-user-manuals-errors/AC-23] clears the error message when a later download succeeds` |

The BE tests of AC-1 to AC-3 and AC-22 prove the code and the status at the layer that decides them (the exception the catalog throws); AC-5 proves in the filter that the body is only the code and a fixed message, and that the log message with the paths never reaches it. The logging ACs (AC-6, AC-7, AC-24) read the log message from the exception: they subscribe to `OnLoggingException` and call `LogException()`, the way `ErrorFilter` does.

Extra tests with no AC tag: the filter keeps the plain-string body for a non-code exception; a manifest that is not valid JSON gives `manuals_manifest_invalid`; a manifest problem found on a download gives the manifest codes; the catalog test `ListAsync_FileNameWithPath_IsRejectedAsync` now expects `UserManualsException`; the handler test of AC-12 of #640 now expects `UserManualsException` (404); a spec for `UserManualsApiService` that turns a JSON error and a `Blob` error body into the right code, and an unknown or non-JSON body into an empty code. The two README tests, like AC-20 of #640, do nothing when only ERAS-BE is checked out. Coverage gates: BE >= 25%, FE >= 15% (AGENTS.md section 8.7).

## Risks / Trade-offs

- [`ErrorFilter` is shared by every controller] → the new body applies only to exceptions that implement `IErrorCodeException`; an extra test pins that a plain `ErasException` still returns its string.
- [The requested identifier comes from the URL and goes to the log] → the log message removes line breaks from it; it is not put in the response.
- [The README tests do nothing in a backend-only checkout] → the parent workflow `manuals-validation.yml` runs them on every pull request that touches `manuals/`.
- [One bad entry now fails every download, where before it depended on the order] → decided in `/sdd-clarify` (AC-22); the validator and the pipeline already block a bad manifest before merge.
- [Re-tagging the four validator tests and changing two expected exception types touch #640 tests] → only the tags and the expected type change, not what they prove.

## Migration Plan
No deployment steps. Merge the BE and FE pull requests and the parent change (README, spec), then bump the submodule pointers. A developer who already runs the stack runs `docker compose up --build` once to get the new backend and the mount, as the README says.

## Follow-ups
- `ExceptionHandlerMiddleware` returns `StackTrace` in its response for exceptions that escape the action filters; it is outside this change and worth its own security review.
- An admin-only endpoint that returns the folder validator's problems (named out of scope in the issue).
