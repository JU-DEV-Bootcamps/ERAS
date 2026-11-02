# Tasks

## 1. Backend (BE)

- [x] 1.1 Write the AC test `GetUserManualsQueryHandlerTests.HandleAsync_TwoManuals_ReturnsThemOrderedByTitleWithDetailsAsync` for (AC-9) in `ERAS-BE/test/Eras.Application.Tests/Features/UserManuals/`, tagged `Change` and `AC` (`640-add-user-manuals-page/AC-9`), and verify it fails for the right reason (replaced by 1.11)
- [x] 1.2 Add `UserManualConstants` (Domain), `GetByEntityTypeAsync` on `IAttachmentRepository` and `AttachmentRepository`, `UserManualDto`, the `IMapper<Attachment, UserManualDto>` mapper, `GetUserManualsQuery` and its handler under `ERAS-BE/src/` for (AC-9), register the mapper in `ApplicationServiceRegistration`, and verify the test from 1.1 passes (replaced by 1.12)
- [x] 1.3 Write the AC test `DownloadUserManualQueryHandlerTests.HandleAsync_AttachmentOfAnotherEntityType_ThrowsNotFoundAndDoesNotReadStorageAsync` for (AC-12) in `ERAS-BE/test/Eras.Application.Tests/Features/UserManuals/`, tagged `Change` and `AC` (`640-add-user-manuals-page/AC-12`), and verify it fails (replaced by 1.13)
- [x] 1.4 Add `DownloadUserManualQuery`, `UserManualFileDto` and `DownloadUserManualQueryHandler` in `ERAS-BE/src/Eras.Application/Features/UserManuals/` for (AC-12) and verify the test from 1.3 passes (replaced by 1.15)
- [x] 1.5 Write the Api test `UserManualsControllerTests.DownloadUserManualAsync_ExistingManual_ReturnsFileWithOriginalNameAsync` for (AC-10) in `ERAS-BE/test/Eras.Api.Tests/Controllers/`, tagged `Change` and `AC` (`640-add-user-manuals-page/AC-10`), and verify it fails (replaced by 1.16)
- [x] 1.6 Add `UserManualsController` with `GET api/v1/user-manuals` and `GET api/v1/user-manuals/{id}/download` in `ERAS-BE/src/Eras.Api/Controllers/` for (AC-10) and verify the test from 1.5 passes (replaced by 1.17)
- [x] 1.7 Write the Api test `UserManualsControllerTests.GetUserManualsAsync_RequiresAuthenticationAndNoRolePolicy` for (AC-8) in `ERAS-BE/test/Eras.Api.Tests/Controllers/`, tagged `Change` and `AC` (`640-add-user-manuals-page/AC-8`), and verify it fails when `[Authorize]` is removed from the class
- [x] 1.8 Put plain `[Authorize]` (no policy, no roles) on `UserManualsController` for (AC-8) and verify the test from 1.7 passes
- [x] 1.9 Write the Api test `UserManualsControllerTests.DownloadUserManualAsync_RequiresAuthenticationAndNoRolePolicy` for (AC-11) in `ERAS-BE/test/Eras.Api.Tests/Controllers/`, tagged `Change` and `AC` (`640-add-user-manuals-page/AC-11`), and verify it fails when `[AllowAnonymous]` is added to the action
- [x] 1.10 Confirm the download action keeps the class-level `[Authorize]` and has no `[AllowAnonymous]` for (AC-11) and verify the test from 1.9 passes
- [x] 1.11 Rewrite the AC test `GetUserManualsQueryHandlerTests.HandleAsync_TwoDeclaredManuals_ReturnsThemOrderedByTitleWithDetailsAsync` for (AC-9) in `ERAS-BE/test/Eras.Application.Tests/Features/UserManuals/` on a mocked `IUserManualCatalog`, keeping its `Change` and `AC` tags (`640-add-user-manuals-page/AC-9`), and verify it fails for the right reason
- [x] 1.12 Add `UserManual`, `UserManualFormat`, `IUserManualCatalog`, the new `UserManualDto` (id, title, language, version, file name, format), `UserManualMapper` and the rewritten `GetUserManualsQueryHandler` for (AC-9), delete `UserManualConstants`, restore `IAttachmentRepository` and `AttachmentRepository` to their original contract (remove `GetByEntityTypeAsync`) and fix the mapper registration, then verify the test from 1.11 passes and `dotnet build` is clean
- [x] 1.13 Rewrite the AC test `DownloadUserManualQueryHandlerTests.HandleAsync_UndeclaredId_ThrowsNotFoundAsync` for (AC-12) in `ERAS-BE/test/Eras.Application.Tests/Features/UserManuals/`, keeping its tags (`640-add-user-manuals-page/AC-12`), and verify it fails
- [x] 1.14 Write the AC test `DownloadUserManualQueryHandlerTests.HandleAsync_OdtManual_ReturnsOdtContentTypeAndDeclaredNameAsync` for (AC-14) in the same file, tagged `Change` and `AC` (`640-add-user-manuals-page/AC-14`), expecting the content type `application/vnd.oasis.opendocument.text` and the declared file name, and verify it fails
- [x] 1.15 Rewrite `DownloadUserManualQuery` (string id), `UserManualFileDto` (content type) and `DownloadUserManualQueryHandler` on the catalog, with the format to content-type mapping, for (AC-12, AC-14) and verify the tests from 1.13 and 1.14 pass
- [x] 1.16 Rewrite the Api test `UserManualsControllerTests.DownloadUserManualAsync_PdfManual_ReturnsAttachmentWithDeclaredNameAsync` for (AC-10) in `ERAS-BE/test/Eras.Api.Tests/Controllers/` (string id, content type `application/pdf`, declared name), keeping its tags (`640-add-user-manuals-page/AC-10`), and verify it fails
- [x] 1.17 Change `UserManualsController` to the route `api/v1/manuals` with a string id on the download for (AC-10) and verify the test from 1.16 passes and the tests of 1.7 and 1.9 still pass
- [x] 1.18 Write the Api test `UserManualsControllerTests.Controller_ExposesOnlyReadActions` for (AC-15) in `ERAS-BE/test/Eras.Api.Tests/Controllers/`, tagged `Change` and `AC` (`640-add-user-manuals-page/AC-15`), asserting every action of the controller is a GET, and verify it fails when a temporary `[HttpPost]` action is added
- [x] 1.19 Confirm the controller has no POST, PUT, PATCH or DELETE action for (AC-15), remove the temporary action and verify the test from 1.18 passes
- [x] 1.20 Write the AC test `AttachmentServiceTest.UploadAttachmentAsync_ManualsEntityType_ThrowsBadRequestAsync` for (AC-16) in `ERAS-BE/test/Eras.Application.Tests/Services/AttachmentServiceTest.cs`, tagged `Change` and `AC` (`640-add-user-manuals-page/AC-16`), expecting a `BussinessException` with status 400 and nothing stored, and verify it fails when `"Manuals"` is temporarily added to `AttachmentEntityTypeRegistry`
- [x] 1.21 Confirm `"Manuals"` is not in `AttachmentEntityTypeRegistry` and the attachment service is unchanged for (AC-16), remove any temporary registration and verify the test from 1.20 passes
- [x] 1.22 Write the AC test `UserManualsFolderValidatorTests.Validate_DeclaredFileMissing_FailsNamingTheFile` for (AC-17) in `ERAS-BE/test/Eras.Infrastructure.Tests/UserManuals/` on a temporary folder, tagged `Change` and `AC` (`640-add-user-manuals-page/AC-17`), and verify it fails
- [x] 1.23 Write the AC test `UserManualsFolderValidatorTests.Validate_FileNotDeclared_FailsNamingTheFile` for (AC-21) in the same file, tagged `Change` and `AC` (`640-add-user-manuals-page/AC-21`), and verify it fails
- [x] 1.24 Write the AC test `UserManualsFolderValidatorTests.Validate_PdfWithWrongContent_FailsNamingTheFile` for (AC-18) in the same file, tagged `Change` and `AC` (`640-add-user-manuals-page/AC-18`), with a file named `.pdf` whose content is not a PDF, and verify it fails
- [x] 1.25 Write the AC test `UserManualsFolderValidatorTests.Validate_FileOverMaxSize_FailsNamingTheFile` for (AC-19) in the same file, tagged `Change` and `AC` (`640-add-user-manuals-page/AC-19`), with a file above 10 MB, and verify it fails
- [x] 1.26 Add `UserManualsSettings`, `FileSystemUserManualCatalog` (manifest, content types, plain file names only) and `UserManualsFolderValidator` in `ERAS-BE/src/Eras.Infrastructure/UserManuals/`, bind `UserManuals` and register the catalog in `InfrastructureServiceRegistration.cs`, for (AC-17, AC-18, AC-19, AC-21) and verify the tests from 1.22 to 1.25 pass, plus two untagged tests: a manifest file name with a path is rejected, and the catalog lists a valid manifest
- [x] 1.27 Write the untagged gate test `UserManualsFolderValidatorTests.Validate_RealManualsFolder_HasNoProblems` that validates the real `manuals/` folder (found by walking up or by `ERAS_MANUALS_PATH`, and doing nothing when absent) and verify it passes once task 4.3 adds the folder

## 2. Frontend (FE)

- [x] 2.1 Write the spec `[640-add-user-manuals-page/AC-1] highlights the User Manuals item and links to its page for a Professional` for (AC-1) in `ERAS-FE/src/app/core/components/sidebar/sidebar v2/sidebar-v2.component.spec.ts` and verify it fails
- [x] 2.2 Add the "User Manuals" item to `sidebar.model-v2.ts` and the lazy `user-manuals` route plus `ROUTE_METADATA.USER_MANUALS` in `app.routes.ts` and `route-metadata.ts` for (AC-1) and verify the spec from 2.1 passes
- [x] 2.3 Write the spec `[640-add-user-manuals-page/AC-2] shows the User Manuals item to a Guest` for (AC-2) in `ERAS-FE/src/app/core/components/sidebar/sidebar v2/sidebar-v2.component.spec.ts` and verify it fails
- [x] 2.4 Include `ERASRoles.GUEST` in the roles of the new sidebar item for (AC-2) and verify the spec from 2.3 passes
- [x] 2.5 Write the spec `[640-add-user-manuals-page/AC-4] shows title, last updated date, format and size of each manual in the order received` for (AC-4) in `ERAS-FE/src/app/modules/user-manuals/user-manuals.component.spec.ts` and verify it fails (replaced by 2.13)
- [x] 2.6 Add `user-manual.model.ts`, `user-manuals.service.ts` (`list`, `download`) and the standalone OnPush `UserManualsComponent` listing the manuals under `ERAS-FE/src/app/` for (AC-4) and verify the spec from 2.5 passes (replaced by 2.14)
- [x] 2.7 Write the spec `[640-add-user-manuals-page/AC-5] shows the empty state when there are no manuals` for (AC-5) in `ERAS-FE/src/app/modules/user-manuals/user-manuals.component.spec.ts` and verify it fails
- [x] 2.8 Add `USER_MANUALS_MESSAGES` to `core/constants/messages.ts` and the empty state to the component for (AC-5) and verify the spec from 2.7 passes
- [x] 2.9 Write the spec `[640-add-user-manuals-page/AC-6] downloads the PDF manual under its original file name` for (AC-6) in `ERAS-FE/src/app/modules/user-manuals/user-manuals.component.spec.ts` and verify it fails (replaced by 2.17)
- [x] 2.10 Implement the download button, which saves the blob under `fileName`, for (AC-6) and verify the spec from 2.9 passes (replaced by 2.18)
- [x] 2.11 Write the spec `[640-add-user-manuals-page/AC-7] downloads the .odt manual under its original file name` for (AC-7) in `ERAS-FE/src/app/modules/user-manuals/user-manuals.component.spec.ts` and verify it fails (replaced by 2.19)
- [x] 2.12 Confirm the same download path handles an .odt file for (AC-7) and verify the spec from 2.11 passes (replaced by 2.20)
- [x] 2.13 Rewrite the spec `[640-add-user-manuals-page/AC-4] shows title, language, version and format of each manual in the order received` for (AC-4) in `ERAS-FE/src/app/modules/user-manuals/user-manuals.component.spec.ts` and verify it fails
- [x] 2.14 Update `user-manual.model.ts` (id as string, language, version, no size or date), `user-manuals.service.ts` (resource `manuals`, string id) and the component and template for (AC-4) and verify the spec from 2.13 passes
- [x] 2.15 Write the spec `[640-add-user-manuals-page/AC-13] shows an error message when the list fails` for (AC-13) in the same spec file, with the list returning an error, and verify it fails
- [x] 2.16 Show `USER_MANUALS_MESSAGES.LOAD_ERROR` instead of a blank page when the list request fails, without the empty state, for (AC-13) and verify the spec from 2.15 passes
- [x] 2.17 Rewrite the spec `[640-add-user-manuals-page/AC-6] downloads the PDF manual under the file name declared for it` for (AC-6) in the same spec file (string id) and verify it fails or, if it already passes, break the download temporarily to prove it can fail
- [x] 2.18 Make the download button call `download` with the string id and save the blob under the declared file name for (AC-6) and verify the spec from 2.17 passes
- [x] 2.19 Rewrite the spec `[640-add-user-manuals-page/AC-7] downloads the .odt manual under the file name declared for it` for (AC-7) in the same spec file and verify it fails or, if it already passes, break the download temporarily to prove it can fail
- [x] 2.20 Confirm the same download path handles an .odt file for (AC-7) and verify the spec from 2.19 passes

## 3. Verification (superseded by group 5)

- [x] 3.2 FE gates pass in `ERAS-FE/`: `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (>= 15%), `npm run build` (replaced by 5.2)
- [x] 3.3 The AC traceability check (AGENTS.md section 8.6) shows exactly 1 test per AC per affected side, and `openspec validate 640-add-user-manuals-page --strict` passes (replaced by 5.3)

## 4. Infra / CI (parent repository)

- [x] 4.1 Write the AC test `UserManualsCodeownersTests.ManualsFolder_RequiresDevelopersGroupAsOwner` for (AC-20) in `ERAS-BE/test/Eras.Infrastructure.Tests/UserManuals/`, tagged `Change` and `AC` (`640-add-user-manuals-page/AC-20`), finding `.github/CODEOWNERS` by walking up from the test directory, and verify it fails while the entry does not exist (it does nothing when the file is not found)
- [x] 4.2 Add `.github/CODEOWNERS` with `/manuals/` owned by the developers team for (AC-20) (confirm the team handle with the repository owners) and verify the test from 4.1 passes
- [x] 4.3 Add `manuals/manifest.json` and the two manual files (one PDF, one .odt, supplied by the team) for (AC-17, AC-18, AC-19, AC-21) and verify the real-folder test from 1.27 passes

## 5. Verification

- [x] 5.1 BE gates (AGENTS.md section 8.7) pass in `ERAS-BE/`: `dotnet build Eras.sln -warnaserror`, `dotnet format Eras.sln --verify-no-changes`, `dotnet test Eras.sln`, coverage >= 25%
- [x] 5.2 FE gates pass in `ERAS-FE/`: `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (>= 15%), `npm run build`
- [x] 5.3 The AC traceability check (AGENTS.md section 8.6) shows exactly 1 test per AC per affected side, and `openspec validate 640-add-user-manuals-page --strict` passes

## Traceability
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | Sidebar item opens the page | FE | src/app/core/components/sidebar/sidebar v2/sidebar-v2.component.spec.ts › [640-add-user-manuals-page/AC-1] highlights the User Manuals item and links to its page for a Professional |
| AC-2 | Guest sees the sidebar item | FE | src/app/core/components/sidebar/sidebar v2/sidebar-v2.component.spec.ts › [640-add-user-manuals-page/AC-2] shows the User Manuals item to a Guest |
| AC-4 | Manuals are listed with their details | FE | src/app/modules/user-manuals/user-manuals.component.spec.ts › [640-add-user-manuals-page/AC-4] shows title, language, version and format of each manual in the order received |
| AC-5 | Empty state when there are no manuals | FE | src/app/modules/user-manuals/user-manuals.component.spec.ts › [640-add-user-manuals-page/AC-5] shows the empty state when there are no manuals |
| AC-6 | Download the PDF manual | FE | src/app/modules/user-manuals/user-manuals.component.spec.ts › [640-add-user-manuals-page/AC-6] downloads the PDF manual under the file name declared for it |
| AC-7 | Download the .odt manual | FE | src/app/modules/user-manuals/user-manuals.component.spec.ts › [640-add-user-manuals-page/AC-7] downloads the .odt manual under the file name declared for it |
| AC-13 | A failed list shows an error message | FE | src/app/modules/user-manuals/user-manuals.component.spec.ts › [640-add-user-manuals-page/AC-13] shows an error message when the list fails |
| AC-8 | Listing requires a signed-in user | BE | test/Eras.Api.Tests/Controllers/UserManualsControllerTests.cs › GetUserManualsAsync_RequiresAuthenticationAndNoRolePolicy |
| AC-9 | The API lists only the declared manuals in alphabetical order | BE | test/Eras.Application.Tests/Features/UserManuals/GetUserManualsQueryHandlerTests.cs › HandleAsync_TwoDeclaredManuals_ReturnsThemOrderedByTitleWithDetailsAsync |
| AC-10 | The API delivers the PDF manual to any signed-in user | BE | test/Eras.Api.Tests/Controllers/UserManualsControllerTests.cs › DownloadUserManualAsync_PdfManual_ReturnsAttachmentWithDeclaredNameAsync |
| AC-11 | Download requires a signed-in user | BE | test/Eras.Api.Tests/Controllers/UserManualsControllerTests.cs › DownloadUserManualAsync_RequiresAuthenticationAndNoRolePolicy |
| AC-12 | An undeclared manual identifier is not found | BE | test/Eras.Application.Tests/Features/UserManuals/DownloadUserManualQueryHandlerTests.cs › HandleAsync_UndeclaredId_ThrowsNotFoundAsync |
| AC-14 | The API delivers the .odt manual with its content type | BE | test/Eras.Application.Tests/Features/UserManuals/DownloadUserManualQueryHandlerTests.cs › HandleAsync_OdtManual_ReturnsOdtContentTypeAndDeclaredNameAsync |
| AC-15 | No write operation exists for manuals | BE | test/Eras.Api.Tests/Controllers/UserManualsControllerTests.cs › Controller_ExposesOnlyReadActions |
| AC-16 | An attachment upload typed as manuals is rejected | BE | test/Eras.Application.Tests/Services/AttachmentServiceTest.cs › UploadAttachmentAsync_ManualsEntityType_ThrowsBadRequestAsync |
| AC-17 | A declared manual without its file fails the validation | BE | test/Eras.Infrastructure.Tests/UserManuals/UserManualsFolderValidatorTests.cs › Validate_DeclaredFileMissing_FailsNamingTheFile |
| AC-18 | A file whose content does not match its declared type fails the validation | BE | test/Eras.Infrastructure.Tests/UserManuals/UserManualsFolderValidatorTests.cs › Validate_PdfWithWrongContent_FailsNamingTheFile |
| AC-19 | A file over the maximum size fails the validation | BE | test/Eras.Infrastructure.Tests/UserManuals/UserManualsFolderValidatorTests.cs › Validate_FileOverMaxSize_FailsNamingTheFile |
| AC-20 | Changes to the manuals folder require developer review | BE | test/Eras.Infrastructure.Tests/UserManuals/UserManualsCodeownersTests.cs › ManualsFolder_RequiresDevelopersGroupAsOwner |
| AC-21 | A file that is not declared fails the validation | BE | test/Eras.Infrastructure.Tests/UserManuals/UserManualsFolderValidatorTests.cs › Validate_FileNotDeclared_FailsNamingTheFile |
