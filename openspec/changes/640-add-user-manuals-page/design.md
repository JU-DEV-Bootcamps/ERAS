# Design

## Context

The spec (`specs/user-manuals/spec.md`) now makes the manuals repository-managed files: a `manuals/` folder at the root of the parent repository, with a `manifest.json` that declares each manual. The backend only reads them. This replaces the first design of the change, which read attachment rows of an entity type `"Manuals"`.

- **What already exists from the first design** (uncommitted in `ERAS-BE/`): `UserManualsController` with plain `[Authorize]` and two reflection tests for it (AC-8, AC-11), `GetUserManualsQuery` / `DownloadUserManualQuery` and their handlers, `UserManualDto`, `UserManualFileDto`, `UserManualMapper`, `UserManualConstants`, and a method `GetByEntityTypeAsync` added to `IAttachmentRepository` and `AttachmentRepository`. The controller, the two queries and the DTO shape stay; the attachment-specific parts go.
- **FE already built** (uncommitted in `ERAS-FE/`): sidebar item with Guest (AC-1, AC-2), lazy route `user-manuals`, `UserManualsComponent`, `UserManualsApiService`, messages and specs. They stay and are adjusted to the new fields.
- **Configuration pattern to copy:** `FileStorageSettings` bound with `Services.Configure<...>(Configuration.GetSection("FileStorage"))` in `src/Eras.Infrastructure/InfrastructureServiceRegistration.cs`. Secrets stay out of `appsettings*.json`; the new setting is a plain path.
- **Deployment today:** `docker-compose.yml`, `docker-compose.local.yml` and `deploy/compose.prod.yml` run the backend from an image; prod mounts host folders such as `/home/ubuntu/eras-uploads:/app/uploads`. The parent repository has no pull-request workflow; the backend has its own (`ERAS-BE/.github/workflows/pr_workflow.yaml`), which cannot see the parent's `manuals/`.
- **Generic attachments:** `AttachmentEntityTypeRegistry` has no `"Manuals"` and must stay that way (AC-16).

## Goals / Non-Goals

**Goals:**
- AC-1, AC-2, AC-4 to AC-7, AC-13 (FE); AC-8 to AC-12, AC-14 to AC-21 (BE).

**Non-Goals:**
- Any write path, upload flow or attachment change for manuals.
- Active-content scanning of PDF and ODT, and an `ETag` from the file hash (follow-ups).
- Moving the manuals folder into a submodule.

## Decisions

### D1. Manuals are files in the parent repository, declared by a manifest, read by the backend from a configurable folder
**Choice:** the backend reads `manifest.json` and the files from the folder in the setting `UserManuals:Path` (default `/app/manuals`) through a catalog behind `IUserManualCatalog`. The folder is mounted read-only into the backend container; the deployment copies it to the host. Format values are `pdf` and `odt`; the catalog maps them to `application/pdf` and `application/vnd.oasis.opendocument.text`.
**Alternative:** store manuals as attachments (first design) → needs an upload ticket and registry change, and the manuals are not reviewed as code. Serve them as frontend static files → public by URL without sign-in.
**ADR:** ADR-0004

### D2. The controller keeps plain `[Authorize]` and only GET actions
**Choice:** `UserManualsController` is renamed to the route `api/v1/manuals` and keeps the class-level `[Authorize]` with no policy, so every signed-in user, Guest included, can list and download. It has no write action, so POST, PUT, PATCH and DELETE are answered 405 by the framework (AC-15).
**Alternative:** a role policy → excludes Guest, against the spec.

### D3. The handlers decide order, content type and not-found
**Choice:** `GetUserManualsQueryHandler` orders by title, case-insensitive. `DownloadUserManualQueryHandler` asks the catalog for the id and throws `NotFoundException` when it is not declared (AC-12); otherwise it returns the stream, the content type of the format and the declared file name. The controller returns `File(stream, contentType, fileName)`, which sends `Content-Disposition: attachment`.
**Alternative:** let the controller map content types → splits one rule across two layers.

### D4. A declared file name is a plain name inside the folder
**Choice:** the catalog rejects a manifest entry whose file name contains a path separator or `..`, and only opens files inside the configured folder. The validator reports such an entry as a failure.
**Alternative:** trust the manifest → a typo or a hostile PR could read any file the backend user can read.

### D5. Folder validation is a validator class with tests that the pull-request pipeline runs
**Choice:** `UserManualsFolderValidator` (Infrastructure) checks a folder and returns the problems it finds: declared file missing (AC-17), file in the folder not declared (AC-21), content not matching the declared type, with the PDF signature and the ODT zip `mimetype` entry as the check (AC-18), and a file above `UserManualsSettings.MaxFileSizeBytes` = 10 MB (AC-19). Each AC test builds a temporary folder with one defect and asserts the problem names the file. A further test with no AC tag validates the real `manuals/` folder; a new parent workflow runs these tests on every pull request that touches `manuals/` or the review rules, with the submodules checked out. The tests find the folder by walking up from the test directory (or `ERAS_MANUALS_PATH`) and do nothing when it is not there, as in the backend-only pipeline.
**Alternative:** a standalone script in the parent pipeline → outside the AC-to-test mapping of AGENTS.md section 5.2.

### D6. The review rule is a CODEOWNERS entry, checked by a test
**Choice:** `.github/CODEOWNERS` in the parent repository lists `/manuals/` with the `eras` team of the organization (more owners can be added to the same line). A backend test parses the file (found by walking up from the test directory) and checks the entry (AC-20). It does nothing when the file is not found.
**Alternative:** rely on branch protection settings alone → not versioned, not testable.

## Changes by layer

### Backend (`ERAS-BE/`)

| Layer | Change | Files | ACs |
|---|---|---|---|
| Domain | `UserManual` record (id, title, language, version, file name, format) and `UserManualFormat` enum (new); delete `UserManualConstants` | `src/Eras.Domain/Entities/UserManual.cs`, `src/Eras.Domain/Entities/UserManualConstants.cs` (removed) | AC-9, AC-14 |
| Application | `IUserManualCatalog` (list, open by id), `UserManualsSettings` (path, max size) (new) | `src/Eras.Application/Contracts/Infrastructure/IUserManualCatalog.cs`, `src/Eras.Application/Models/UserManualsSettings.cs` | AC-9, AC-12, AC-19 |
| Application | `DownloadUserManualQuery(string Id)`; handlers rewritten on the catalog; `UserManualDto` with id, title, language, version, file name, format (no size, no date); `UserManualFileDto` with content type; `UserManualMapper` maps `UserManual` | `src/Eras.Application/Features/UserManuals/`, `src/Eras.Application/DTOs/UserManuals/`, `src/Eras.Application/Mappers/UserManuals/` | AC-9, AC-10, AC-12, AC-14 |
| Application | Remove `GetByEntityTypeAsync` and its attachment-repository implementation (back to the original contract) | `src/Eras.Application/Contracts/Persistence/IAttachmentRepository.cs`, `src/Eras.Infrastructure/Persistence/PostgreSQL/Repositories/AttachmentRepository.cs` | AC-16 |
| Infrastructure | `FileSystemUserManualCatalog`, `UserManualsFolderValidator`; bind `UserManuals` settings and register the catalog | `src/Eras.Infrastructure/UserManuals/`, `src/Eras.Infrastructure/InfrastructureServiceRegistration.cs` | AC-9, AC-12, AC-17, AC-18, AC-19, AC-21 |
| Api | `UserManualsController`: route `api/v1/manuals`, `GET` list and `GET {Id}/download` (string id), class-level `[Authorize]`, no write action | `src/Eras.Api/Controllers/UserManualsController.cs` | AC-8, AC-10, AC-11, AC-15 |

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Model / service | `UserManualModel` with id (string), title, language, version, file name, file format; service resource `manuals`, `download(id: string)` | `src/app/core/models/user-manual.model.ts`, `src/app/core/services/api/user-manuals.service.ts` | AC-4, AC-6, AC-7 |
| Component | List shows title, language, version and format (no size, no date); a failed list shows the error message; download saves the blob under the file name | `src/app/modules/user-manuals/user-manuals.component.{ts,html,scss}` | AC-4, AC-5, AC-6, AC-7, AC-13 |
| Messages | Reuse `USER_MANUALS_MESSAGES.LOAD_ERROR` and `EMPTY` | `src/app/core/constants/messages.ts` | AC-5, AC-13 |

Sidebar item, route and route metadata (AC-1, AC-2) are unchanged.

### Infra / CI (parent repository)

| Item | Change | Files | ACs |
|---|---|---|---|
| Manuals | `manuals/manifest.json` and the two manual files (one PDF, one .odt) | `manuals/` | AC-17 to AC-21 |
| Review rule | `/manuals/` owned by the developers team | `.github/CODEOWNERS` | AC-20 |
| Pipeline | New workflow on pull requests that touch `manuals/` or `.github/CODEOWNERS`: check out with submodules, set up .NET 8, run the backend tests filtered on the user manuals | `.github/workflows/manuals-validation.yml` | AC-17 to AC-21 |
| Deployment | Mount `manuals/` read-only at `/app/manuals` in the backend of both local compose files and in prod from a host folder, and copy the folder to the host in the deploy workflow | `docker-compose.yml`, `docker-compose.local.yml`, `deploy/compose.prod.yml`, `.github/workflows/stage_deploy_runner.yml` | AC-9, AC-10, AC-14 |

## API contract

| Endpoint | Policy | Request DTO | Response DTO | Status codes |
|---|---|---|---|---|
| `GET api/v1/manuals` | `[Authorize]` (any signed-in user) | none | `UserManualDto[]` { id: string, title: string, language: string, version: string, fileName: string, fileFormat: string } | 200, 401 |
| `GET api/v1/manuals/{id}/download` | `[Authorize]` (any signed-in user) | none | file stream, `Content-Disposition: attachment; filename="<fileName>"`, `Content-Type` of the format | 200, 401, 404 |

- **FE model:** `src/app/core/models/user-manual.model.ts` mirrors `UserManualDto` exactly.
- **FE service:** `src/app/core/services/api/user-manuals.service.ts`, methods `list` and `download`, no leading slash.
- **Ownership / scope rules:** none per user. POST, PUT, PATCH and DELETE are not mapped, so the framework answers 405 (AC-15). 403 does not exist for these endpoints.

## Data and migration
No schema change. Manuals are files, not rows.

## Test strategy

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-8 | BE | Api: `test/Eras.Api.Tests/Controllers/` | `UserManualsControllerTests.cs` › `GetUserManualsAsync_RequiresAuthenticationAndNoRolePolicy` |
| AC-9 | BE | Application: `test/Eras.Application.Tests/Features/UserManuals/` | `GetUserManualsQueryHandlerTests.cs` › `HandleAsync_TwoDeclaredManuals_ReturnsThemOrderedByTitleWithDetailsAsync` |
| AC-10 | BE | Api: `test/Eras.Api.Tests/Controllers/` | `UserManualsControllerTests.cs` › `DownloadUserManualAsync_PdfManual_ReturnsAttachmentWithDeclaredNameAsync` |
| AC-11 | BE | Api: `test/Eras.Api.Tests/Controllers/` | `UserManualsControllerTests.cs` › `DownloadUserManualAsync_RequiresAuthenticationAndNoRolePolicy` |
| AC-12 | BE | Application: `test/Eras.Application.Tests/Features/UserManuals/` | `DownloadUserManualQueryHandlerTests.cs` › `HandleAsync_UndeclaredId_ThrowsNotFoundAsync` |
| AC-14 | BE | Application: `test/Eras.Application.Tests/Features/UserManuals/` | `DownloadUserManualQueryHandlerTests.cs` › `HandleAsync_OdtManual_ReturnsOdtContentTypeAndDeclaredNameAsync` |
| AC-15 | BE | Api: `test/Eras.Api.Tests/Controllers/` | `UserManualsControllerTests.cs` › `Controller_ExposesOnlyReadActions` |
| AC-16 | BE | Application: `test/Eras.Application.Tests/Services/` | `AttachmentServiceTest.cs` › `UploadAttachmentAsync_ManualsEntityType_ThrowsBadRequestAsync` |
| AC-17 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/UserManuals/` | `UserManualsFolderValidatorTests.cs` › `Validate_DeclaredFileMissing_FailsNamingTheFile` |
| AC-18 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/UserManuals/` | `UserManualsFolderValidatorTests.cs` › `Validate_PdfWithWrongContent_FailsNamingTheFile` |
| AC-19 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/UserManuals/` | `UserManualsFolderValidatorTests.cs` › `Validate_FileOverMaxSize_FailsNamingTheFile` |
| AC-20 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/UserManuals/` | `UserManualsCodeownersTests.cs` › `ManualsFolder_RequiresDevelopersGroupAsOwner` |
| AC-21 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/UserManuals/` | `UserManualsFolderValidatorTests.cs` › `Validate_FileNotDeclared_FailsNamingTheFile` |
| AC-1 | FE | `src/app/core/components/sidebar/sidebar v2/sidebar-v2.component.spec.ts` | `[640-add-user-manuals-page/AC-1] highlights the User Manuals item and links to its page for a Professional` |
| AC-2 | FE | `src/app/core/components/sidebar/sidebar v2/sidebar-v2.component.spec.ts` | `[640-add-user-manuals-page/AC-2] shows the User Manuals item to a Guest` |
| AC-4 | FE | `src/app/modules/user-manuals/user-manuals.component.spec.ts` | `[640-add-user-manuals-page/AC-4] shows title, language, version and format of each manual in the order received` |
| AC-5 | FE | `src/app/modules/user-manuals/user-manuals.component.spec.ts` | `[640-add-user-manuals-page/AC-5] shows the empty state when there are no manuals` |
| AC-6 | FE | `src/app/modules/user-manuals/user-manuals.component.spec.ts` | `[640-add-user-manuals-page/AC-6] downloads the PDF manual under the file name declared for it` |
| AC-7 | FE | `src/app/modules/user-manuals/user-manuals.component.spec.ts` | `[640-add-user-manuals-page/AC-7] downloads the .odt manual under the file name declared for it` |
| AC-13 | FE | `src/app/modules/user-manuals/user-manuals.component.spec.ts` | `[640-add-user-manuals-page/AC-13] shows an error message when the list fails` |

AC-8, AC-11 and AC-15 read the controller's attributes by reflection. AC-16 and AC-15 are guard tests that pass from the start: each is proven by temporarily breaking the code (registering `"Manuals"`, adding a POST action). AC-20 and the real-folder test do nothing outside a full checkout. Extra tests carry no AC tag: the real `manuals/` folder passes the validator, and a manifest file name with a path is rejected. Coverage gates: BE >= 25%, FE >= 15% (AGENTS.md section 8.7).

## Risks / Trade-offs

- [The backend-only pipeline skips the folder tests] → the new parent workflow runs them on every pull request that touches `manuals/` or the review rule; a change that bypasses it is blocked by the review rule.
- [Manuals reach production only through the deploy workflow] → a step in `stage_deploy_runner.yml` copies the folder; until it runs, the list is empty and the page shows the empty state.
- [A malformed `manifest.json` breaks the list] → the catalog fails the request with a server error and the page shows the load error (AC-13); the validator test run catches it before merge.
- [Replacing the first design touches uncommitted code] → nothing is committed yet; the attachment repository goes back to its original contract.

## Migration Plan
- Add `manuals/`, CODEOWNERS and the workflow in the parent repository; merge the BE and FE pull requests; bump the submodule pointers.
- Deployment: create the host folder and let the deploy workflow copy `manuals/` into it before the backend restarts. Rollback: remove the mount; the page shows the empty state.

## Open Questions
- Which host folder does production use for the manuals? It does not change the spec; it is confirmed with the deploy owners before merge. The CODEOWNERS entry names the `eras` team of the organization, and more owners can be appended to the same line later.
- Titles, languages and versions of the two manuals come with the files.

## Follow-ups
- Active-content scanning of PDF (scripts, actions) and ODT (macros, scripts) as a separate task.
- `ETag` from the file hash for caching.
