# Design

## Context

The motivation and behavior are in `proposal.md` and `specs/student-interventions/spec.md` (AC-1 to AC-33). What exists today:

- **Students are an Administrator and Officer area.** `ERAS-BE/src/Eras.Api/Controllers/StudentsController.cs` has a class-level `[Authorize(Policy = ErasPolicies.AdminOrOfficer)]` and no action-level policy; the FE route `STUDENTS` in `ERAS-FE/src/app/core/utils/routing/route-metadata.ts` lists the same two roles. Two `[Authorize]` attributes are ANDed, so an action cannot loosen the class policy.
- **The student record** is `new-student-modal` (`ERAS-FE/src/app/modules/students/students-list/new-student-modal/`, 539 lines, no own `.scss`, opened by `students-list.component.ts` with `GET api/v1/students/{id}/profile`). It has no section for entries, and a student without a profile opens it editable.
- **The profile summary** is `student-profile-summary-modal` (`ERAS-FE/src/app/modules/students/students-list/student-profile-summary-modal/`, read only, opened by `openProfileSummaryModal`, same `GET students/{id}/profile`). It is the "profile modal" of the ticket and today shows two free-text lists, `identifiedRisks` and `supportReceived`, stored on `StudentProfile` (`identified_risks` and `support_received` `text[]` columns, written only through the profile API; the FE does not edit them).
- **Student rows** follow the 1:1 `StudentProfile` pattern (`Eras.Domain/Entities/StudentProfile.cs`, `StudentProfileConfiguration`, `IStudentProfileRepository`) with `IsDeleted` plus a global query filter and `Audit` (`CreatedBy` is the Keycloak sub, max 50). `StudentRepository.SoftDeleteAsync` marks `IsDeleted` and writes `Audit.ModifiedBy`/`ModifiedAt`; there is no `deleted_by` column.
- **"Intervention" already means something else:** `Eras.Domain/Entities/AssessmentManagement/Intervention.cs` (table `interventions`), `InterventionService` and `InterventionModel` in the FE. The new names carry the `StudentIntervention` prefix to avoid the clash.
- **Assignment already exists:** `Assessment.AssignedProfessionals` (Keycloak subs) and `Assessment.StudentIds` (array columns, ADR-0002); `IAssessmentRepository.GetByAssignedProfessionalAsync` limits the assessments a professional sees. No method returns the student ids a professional can see.
- **Handlers read the actor** through `ICurrentUserService` (`Sub`, `Name`, `Email`, `Roles`) and `ErasRole.Resolve(Roles, KeycloakRoleNames)`. Failures are `Eras.Error` exceptions; there is no 403 exception, and `ErrorFilter` turns an `ErasException` into its status code with a plain-string body. Validation errors follow `Features/Students/Commands/StudentProfileGuards.cs` (messages joined, `BussinessException(message, 400)`).
- **Change 642 is not in `develop`** (it lives on `origin/642-feature-add-search-by-student-name-in-students-view`) and touches `students-list.component.*` and the students list query. This plan is written against `develop` and is implemented after 642 merges (see Migration Plan).

## Goals / Non-Goals

**Goals:**
- Store, list, change and delete the risk and support entries of a student with the creator, ownership and role rules of AC-1 to AC-21 and AC-27 to AC-29.
- Let a Professional reach the Students list and a student's profile for their assigned students only, read only (AC-22, AC-23, AC-30 to AC-33).
- Show the entries in the read-only profile summary from the same endpoint that manages them, and stop showing the former free-text lists (AC-24 to AC-26, AC-34).

**Non-Goals:**
- A shared "assigned students" filter for other endpoints (poll risk views, student details); only the list, the profile and the new entries use it now.
- Caching the entries in the FE, paging them, or exporting them.
- Changing the `Student` or `StudentProfile` tables, or removing, migrating or importing the `identified_risks` and `support_received` columns; they stay as they are and the summary stops reading them.

## Decisions

### D1. A new entity `StudentInterventionEntry` linked to `Student` by foreign key
**Choice:** One table `student_intervention_entries` with `student_id` referencing `students`, a `kind` (risk or support) and a `type`, so one table and one set of endpoints serve both lists. It is not a profile entity and does not extend `StudentProfile`, so students without a profile can have entries.
**Alternative:** Two tables, one per kind → duplicated repository, handlers and DTOs for identical columns.

### D2. Kind and type are string-stored enums; the kind-to-type map is domain code
**Choice:** `StudentInterventionKind` (`RiskIdentified`, `SupportReceived`) and a single `StudentInterventionType` (`Academic`, `Financial`, `Attendance`, `Personal`, `Tutoring`, `Advising`, `FinancialAid`, `Referral`), stored with `.HasConversion<string>()` like the other enums, serialized by the existing `JsonStringEnumConverter`. A static map in the domain says which types belong to which kind; the validator uses it (AC-7). The FE shows the label "Financial aid" for `FinancialAid`.
**Alternative:** One enum per kind, or a lookup table → two enums duplicate the validator and a lookup table adds a migration and endpoint for a fixed list the ticket asks to keep fixed.

### D3. Soft delete reuses the student pattern
**Choice:** `IsDeleted` with a global query filter; deleting sets `IsDeleted` and writes `Audit.ModifiedBy` (the deleter's sub) and `ModifiedAt`, exactly as `StudentRepository.SoftDeleteAsync` does. That is "who deleted it and when" (AC-12, AC-28) without new columns.
**Alternative:** `deleted_by` and `deleted_at` columns, or an audit log table → more schema for information the audit fields already carry.

### D4. The creator is the token user; the name is stored as a snapshot
**Choice:** `Audit.CreatedBy` is `ICurrentUserService.Sub`, never read from the request (AC-3). A `created_by_name` column keeps the display name (`Name`, then `Email`, then `Sub`) at creation, so lists show a name without calling Keycloak. Edits keep both.
**Alternative:** Resolve names from Keycloak on every list → an external call per request and a failure mode in a read endpoint.

### D5. A professional's access to students is scoped by assignment, in one Application service
**Choice:** `IStudentAccessService` (new, `Contracts/Services/` and `Services/`) returns the student ids a user may see (`null` for Administrator and Officer, the ids of the assessments whose `AssignedProfessionals` contains their sub for a Professional) and throws `BussinessException(403)` for a student outside that set or for Guest. Handlers check existence first (404), then scope (403). `StudentsController` becomes `AnyErasRole` at class level with an explicit `AdminOrOfficer` on every action except the list and the profile read, guarded by a reflection test.
**Alternative:** Separate professional endpoints, FE-only filtering, a global query filter → see the ADR.
**ADR:** ADR-0005

### D6. Ownership of entries lives in the handlers; write routes use a new policy
**Choice:** New `ErasPolicies.AdminOrProfessional` guards create, update and delete (so an Officer and Guest get 403 from authorization, AC-19). Inside the update and delete handlers, a Professional may change only entries whose `Audit.CreatedBy` equals their sub; an Administrator may change any (AC-11, AC-14, AC-27, AC-28). Reading uses `AnyErasRole`.
**Alternative:** One policy with the check in the controller → business rules in a controller, against §6.2.

### D7. Validation at the boundary reuses the guard pattern, text is stored as written
**Choice:** A FluentValidation `SaveStudentInterventionDtoValidator` (type required and valid for the kind, description required, not blank, at most 1000 characters, date required) run through a `StudentInterventionGuards` that mirrors `StudentProfileGuards` (messages joined, `BussinessException(message, 400)`, each message names its field). The description is stored trimmed and as plain text; the FE renders it with interpolation, so it is never markup (AC-26).
**Alternative:** Strip HTML on the server → it alters what the user wrote and the FE already renders text safely.

### D8. The entries have their own controller on a nested route
**Choice:** `StudentInterventionsController` at `api/v1/students/{studentId:int}/interventions`, thin, one MediatR request per action (golden path, `Features/RemissionManagement/` as reference).
**Alternative:** Add the actions to `StudentsController` → it is already 14 actions long and its policies are being reworked by D5.

### D9. The FE adds a managing component, a shared list and a small dialog instead of growing the modal
**Choice:** `app-student-interventions` (standalone, OnPush, input `studentId`) manages the entries inside `mat-dialog-content` of `new-student-modal`, after the form, and only when the student exists. Both it and the profile summary render the entries through one presentational `app-student-intervention-list` (inputs: entries, an empty-state text, whether an entry can be changed; outputs: edit and delete), so the two places cannot drift. The summary uses it without actions and loads through the same service, replacing its two free-text blocks. Add and edit use `student-intervention-form-modal` (MatDialog with `FormFactory`, same header and buttons as `new-intervention-modal`). Delete confirmation uses `ModalDeleteConfirmationService`. The service is a new `StudentInterventionService` (`resource = 'students'`, endpoints `${studentId}/interventions`), no `@Cacheable`. The section has its own form, so it does not touch the modal's unsaved-changes guard.
**Alternative:** Put the section in the modal itself, or copy the list markup into the summary → the modal would reach about 700 lines, share `this.form` with the student form, and two copies of the list would drift.

### D10. FE permissions are policy entries; a Professional gets a read-only Students section
**Choice:** In `permission.policies.ts`: `CAN_MANAGE_STUDENTS` (Administrator, Officer), `CAN_ADD_STUDENT_INTERVENTIONS` (Administrator, Professional), `CAN_MANAGE_ANY_STUDENT_INTERVENTION` (Administrator). An entry shows edit and delete when the user can manage any, or can add and is the creator (`createdBy` equals `UserDataService.user().id`). Without `CAN_MANAGE_STUDENTS`, the list hides Import, Export, New Student, the delete and details row actions and the selection, and the modal opens view-only without its Edit button. `STUDENTS` route metadata and the v2 sidebar item gain the Professional role, and the Students container shows the list to a Professional even when the `studentList` flag is off.
**Alternative:** Compare raw role strings in the components → against §7.1.

## Changes by layer

### Backend (`ERAS-BE/`)

| Layer | Change | Files | ACs |
|---|---|---|---|
| Domain | New entity, kind and type enums, kind-to-type map | `src/Eras.Domain/Entities/StudentInterventionEntry.cs`, `StudentInterventionKind.cs`, `StudentInterventionType.cs`, `StudentInterventionTypes.cs` (new) | AC-1, AC-2, AC-7 |
| Application | Requests, handlers, DTOs, mapper, validator, guard, access service and repository contract | `src/Eras.Application/Features/StudentInterventions/Commands.cs`, `Queries.cs`, `Handlers/*Handler.cs`, `StudentInterventionGuards.cs`; `DTOs/StudentInterventions/StudentInterventionDto.cs`, `SaveStudentInterventionDto.cs`; `Mappers/StudentInterventions/StudentInterventionToDtoMapper.cs`; `Validation/SaveStudentInterventionDtoValidator.cs`; `Contracts/Persistence/IStudentInterventionEntryRepository.cs`; `Contracts/Services/IStudentAccessService.cs`; `Services/StudentAccessService.cs` (all new); registrations in `ApplicationServiceRegistration.cs` | AC-1 to AC-4, AC-6 to AC-8, AC-10 to AC-12, AC-14, AC-17, AC-21, AC-27, AC-28, AC-32, AC-33 |
| Application | Scope the list and the profile read | `Features/Students/Queries/GetAll/GetAllStudentsQueryHandler.cs`, `Features/Students/Queries/GetStudentProfile/GetStudentProfileQueryHandler.cs`, `Contracts/Persistence/IStudentRepository.cs` (a `GetPagedAsyncWithJoins` overload that takes the allowed student ids; it composes with the name search and counts only the allowed matches), `Contracts/Persistence/AssessmentManagement/IAssessmentRepository.cs` (student ids by professional) | AC-22, AC-31 |
| Infrastructure | EF configuration, `DbSet`, repository, new migration, repository methods for the scope, new policy | `Persistence/PostgreSQL/Configurations/StudentInterventionEntryConfiguration.cs`, `Repositories/StudentInterventionEntryRepository.cs` (new); `AppDbContext.cs`; `PersistenceServiceRegistration.cs`; `Repositories/StudentRepository.cs`; `Repositories/AssessmentManagement/AssessmentRepository.cs`; `Authorization/ErasPolicies.cs` (`AdminOrProfessional`) | AC-9, AC-15, AC-16, AC-19, AC-22 |
| Api | New controller, per-action policies on `StudentsController`, `ProducesResponseType` on every action | `src/Eras.Api/Controllers/StudentInterventionsController.cs` (new), `Controllers/StudentsController.cs` | AC-18, AC-19, AC-23 |

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Route / menu | Add `ERASRoles.PROFESSIONAL` to `STUDENTS`, to the v2 Students sidebar item, and make the container show the list to a Professional | `src/app/core/utils/routing/route-metadata.ts`, `src/app/core/components/sidebar/sidebar v2/sidebar.model-v2.ts`, `src/app/modules/students/students-container.component.ts` | AC-22 |
| Model / service | Model mirroring the BE DTO; service with list, create, update, delete | `src/app/core/models/student-intervention.model.ts`, `src/app/core/services/api/student-intervention.service.ts` (new) | AC-1, AC-10, AC-12 |
| Permissions | Three entries in the three tables | `src/app/core/services/permissions/permission.policies.ts` | AC-20, AC-29, AC-30 |
| Component | Managing section with add, edit and delete; add and edit dialog; shared list | `src/app/modules/students/students-list/student-interventions/student-interventions.component.ts/.html/.scss`, `student-intervention-form-modal/`, `student-intervention-list/` (new) | AC-1, AC-5, AC-10, AC-12, AC-13, AC-20, AC-29 |
| Component | The read-only profile summary shows the two lists from the entries (empty states, plain text) and drops the free-text blocks | `student-profile-summary-modal/student-profile-summary-modal.component.ts/.html` | AC-24, AC-25, AC-26, AC-34 |
| Component | Embed the section; read-only modal for a Professional | `new-student-modal.component.ts/.html` | AC-22, AC-30 |
| Component | Hide student actions without `CAN_MANAGE_STUDENTS` | `students-list.component.ts/.html` | AC-22, AC-30 |
| Messages | Labels, empty states, confirmation and toast texts | `src/app/core/constants/messages.ts` (`STUDENT_INTERVENTION_MESSAGES`) | AC-5, AC-12, AC-25 |

## API contract

| Endpoint | Policy | Request DTO | Response DTO | Status codes |
|---|---|---|---|---|
| `GET api/v1/students/{studentId}/interventions` | `AnyErasRole` | none | `StudentInterventionDto[]` (newest first) | 200, 403, 404 |
| `POST api/v1/students/{studentId}/interventions` | `AdminOrProfessional` | `SaveStudentInterventionDto` { kind, type, description, entryDate } | `StudentInterventionDto` | 201, 400, 403, 404 |
| `PUT api/v1/students/{studentId}/interventions/{entryId}` | `AdminOrProfessional` | `SaveStudentInterventionDto` (the stored kind wins over the body's) | `StudentInterventionDto` | 200, 400, 403, 404 |
| `DELETE api/v1/students/{studentId}/interventions/{entryId}` | `AdminOrProfessional` | none | none | 204, 403, 404 |
| `GET api/v1/students` | `AnyErasRole` (was `AdminOrOfficer`) | existing | existing, limited to assigned students for a Professional | 200, 403 |
| `GET api/v1/students/{id}/profile` | `AnyErasRole` (was `AdminOrOfficer`) | none | existing | 200, 403, 404 |

`StudentInterventionDto` is { id, studentId, kind, type, description, entryDate (`yyyy-MM-dd`), createdBy (sub), createdByName, createdAt }.

- **FE model:** `src/app/core/models/student-intervention.model.ts` mirrors it exactly, with `kind` and `type` as string unions.
- **FE service:** `src/app/core/services/api/student-intervention.service.ts` extends `BaseApiService`, `resource = 'students'`, methods `getByStudent`, `create`, `update`, `remove` (`delete` is taken by `BaseApiService`), endpoints without a leading slash.
- **Ownership / scope rules:** a Professional changes only entries they created (AC-11, AC-14); an Administrator any (AC-27, AC-28); a Professional reads or writes only students of their assigned assessments (AC-22, AC-31 to AC-33). Both live in the handlers and the access service. Every other `StudentsController` action keeps `AdminOrOfficer` (AC-23).
- **Errors:** 400 carries the plain-string body of `ErrorFilter` (each message names its field); 403 and 404 come from `BussinessException` and `NotFoundException`. A kind or type name that is on no list is rejected by model binding with a 400 before the handler.

## Data and migration

New table `student_intervention_entries`: `id` (identity), `student_id` (required, foreign key to `students`, cascade), `kind` (text), `type` (text), `description` (varchar 1000), `entry_date` (date), `created_by_name` (varchar 200), `is_deleted` (default false), and the audit columns of `AuditConfiguration`. Index on `student_id`. Global query filter `!IsDeleted`. Migration `AddStudentInterventionEntries` created with `dotnet ef migrations add` (never hand-editing `AppDbContextModelSnapshot.cs`); no backfill, because no earlier source of this data is known. Rollback is the `Down` of the migration, which drops the table.

## Test strategy

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | BE | Application: `test/Eras.Application.Tests/Features/StudentInterventions/` | `CreateStudentInterventionCommandHandlerTests.cs` › `HandleAsync_ProfessionalAddsRisk_PersistsEntryForStudentAsync` |
| AC-1 | FE | `src/app/modules/students/students-list/student-interventions/student-interventions.component.spec.ts` | `[643-add-student-interventions/AC-1] adds a risk and lists it immediately` |
| AC-2 | BE | Application | `CreateStudentInterventionCommandHandlerTests.cs` › `HandleAsync_ProfessionalAddsSupport_ReturnsSupportEntryAsync` |
| AC-3 | BE | Application | `CreateStudentInterventionCommandHandlerTests.cs` › `HandleAsync_AnyRequest_RecordsAuthenticatedUserAndServerTimeAsync` |
| AC-4 | BE | Application | `CreateStudentInterventionCommandHandlerTests.cs` › `HandleAsync_MissingRequiredField_Throws400NamingFieldAndDoesNotPersistAsync` |
| AC-5 | FE | `.../student-intervention-form-modal/student-intervention-form-modal.component.spec.ts` | `[643-add-student-interventions/AC-5] shows required errors and does not submit an empty form` |
| AC-6 | BE | Application | `CreateStudentInterventionCommandHandlerTests.cs` › `HandleAsync_DescriptionOver1000Chars_Throws400Async` |
| AC-7 | BE | Application | `CreateStudentInterventionCommandHandlerTests.cs` › `HandleAsync_TypeOfOtherKind_Throws400NamingTypeAsync` |
| AC-8 | BE | Application | `CreateStudentInterventionCommandHandlerTests.cs` › `HandleAsync_UnknownStudent_Throws404Async` |
| AC-9 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Repositories/` | `StudentInterventionEntryRepositoryTests.cs` › `AddAsync_DoesNotChangeStudentRowsAsync` |
| AC-10 | BE | Application | `UpdateStudentInterventionCommandHandlerTests.cs` › `HandleAsync_ProfessionalEditsOwnEntry_KeepsCreatorAndCreationTimeAsync` |
| AC-10 | FE | `student-interventions.component.spec.ts` | `[643-add-student-interventions/AC-10] edits an own entry and shows the new description` |
| AC-11 | BE | Application | `UpdateStudentInterventionCommandHandlerTests.cs` › `HandleAsync_EntryOfOtherUser_Throws403Async` |
| AC-12 | BE | Application | `DeleteStudentInterventionCommandHandlerTests.cs` › `HandleAsync_ProfessionalDeletesOwnEntry_SoftDeletesWithActorAsync` |
| AC-12 | FE | `student-interventions.component.spec.ts` | `[643-add-student-interventions/AC-12] deletes an own entry after confirming` |
| AC-13 | FE | `student-interventions.component.spec.ts` | `[643-add-student-interventions/AC-13] keeps the entry when the confirmation is cancelled` |
| AC-14 | BE | Application | `DeleteStudentInterventionCommandHandlerTests.cs` › `HandleAsync_EntryOfOtherUser_Throws403AndKeepsEntryAsync` |
| AC-15 | BE | Infrastructure | `StudentInterventionEntryRepositoryTests.cs` › `GetByStudentIdAsync_ManyEntries_ReturnsNewestFirstAsync` |
| AC-16 | BE | Infrastructure | `StudentInterventionEntryRepositoryTests.cs` › `GetByStudentIdAsync_OtherStudentEntries_AreNotReturnedAsync` |
| AC-17 | BE | Application | `GetStudentInterventionsQueryHandlerTests.cs` › `HandleAsync_OfficerRequestsEntries_ReturnsThemAsync` |
| AC-18 | BE | Api: `test/Eras.Api.Tests/Authorization/` | `StudentInterventionPoliciesTests.cs` › `List_GuestIsDeniedAsync` |
| AC-19 | BE | Api | `StudentInterventionPoliciesTests.cs` › `CreateUpdateDelete_OfficerIsDeniedAsync` |
| AC-20 | FE | `student-interventions.component.spec.ts` | `[643-add-student-interventions/AC-20] lists the entries without actions for an Officer` |
| AC-21 | BE | Application | `CreateStudentInterventionCommandHandlerTests.cs` › `HandleAsync_AdministratorAddsEntry_RecordsAdministratorAsCreatorAsync` |
| AC-22 | BE | Application: `test/Eras.Application.Tests/Features/Students/` | `GetAllStudentsQueryHandlerProfessionalScopeTests.cs` › `HandleAsync_ProfessionalRequestsList_ReturnsOnlyAssignedStudentsAsync` |
| AC-22 | FE | `src/app/modules/students/students-list/students-list.component.spec.ts` | `[643-add-student-interventions/AC-22] a Professional opens the profile of an assigned student with the Interventions section` |
| AC-23 | BE | Api | `StudentsProfessionalAccessTests.cs` › `Professional_IsDeniedImportCreateDeleteAndProfileUpdateAsync` |
| AC-24 | FE | `src/app/modules/students/students-list/student-profile-summary-modal/student-profile-summary-modal.component.spec.ts` | `[643-add-student-interventions/AC-24] shows risks and support as separate lists without actions` |
| AC-25 | FE | `student-profile-summary-modal.component.spec.ts` | `[643-add-student-interventions/AC-25] shows an empty-state message in each empty list` |
| AC-26 | FE | `student-profile-summary-modal.component.spec.ts` | `[643-add-student-interventions/AC-26] displays a description as plain text` |
| AC-34 | FE | `student-profile-summary-modal.component.spec.ts` | `[643-add-student-interventions/AC-34] does not show the former free-text lists` |
| AC-27 | BE | Application | `UpdateStudentInterventionCommandHandlerTests.cs` › `HandleAsync_AdministratorEditsEntryOfProfessional_KeepsOriginalCreatorAsync` |
| AC-28 | BE | Application | `DeleteStudentInterventionCommandHandlerTests.cs` › `HandleAsync_AdministratorDeletesEntryOfProfessional_SoftDeletesWithAdministratorAsync` |
| AC-29 | FE | `student-interventions.component.spec.ts` | `[643-add-student-interventions/AC-29] shows add, edit and delete to an Administrator` |
| AC-30 | FE | `students-list.component.spec.ts` | `[643-add-student-interventions/AC-30] hides every student action from a Professional` |
| AC-31 | BE | Application: `test/Eras.Application.Tests/Features/Students/` | `GetStudentProfileProfessionalScopeTests.cs` › `HandleAsync_UnassignedStudent_Throws403Async` |
| AC-32 | BE | Application | `GetStudentInterventionsQueryHandlerTests.cs` › `HandleAsync_UnassignedStudent_Throws403Async` |
| AC-33 | BE | Application | `CreateStudentInterventionCommandHandlerTests.cs` › `HandleAsync_UnassignedStudent_Throws403AndDoesNotPersistAsync` |

Extra edge-case tests carry no AC tag: the domain kind-to-type map, `StudentAccessServiceTests`, the repository methods for the scope, the controller status codes (201, 200, 204), the reflection test that every `StudentsController` action declares its own policy (ADR-0005), the updated `ErasPoliciesTests`, the permissions spec and the service spec. Coverage gates: BE >= 25%, FE >= 15% (AGENTS.md section 8.7). Because this change adds BE controller actions and FE screens, `/sdd-validate-impl` is the manual gate before `/sdd-verify`.

## Risks / Trade-offs

- [Relaxing the `StudentsController` class policy opens every student action by omission] → each action declares its own policy and a reflection test fails when one does not (ADR-0005); AC-23 proves the denied routes.
- [Change 642 edits the same list component, service and list query] → implement after 642 merges into `develop`; the scope composes with its search because the access service only supplies the allowed ids.
- [`GetAllStudentsQueryHandler` catches every exception and returns an empty page, which would hide a 403] → resolve the allowed ids before its `try`, and cover it with the AC-22 test.
- [InMemory tests do not exercise PostgreSQL array translation of `StudentIds`] → flatten the ids in memory as ADR-0002 allows, and confirm the real query once in the manual validation.
- [A professional removed from an assessment loses the students it gave, and their entries become unreadable to them] → expected under the assignment rule; Administrator and Officer still read them.
- [The `created_by_name` snapshot goes stale if a user is renamed] → accepted; the sub in `createdBy` stays the identity used for ownership.
- [Hiding the details and export actions from a Professional leaves the Students list thinner than the Officer's] → matches AC-30; widening it is a new change.

## Migration Plan

1. Implement after change 642 is merged into `develop`: update the 643 branches of `ERAS-BE` and `ERAS-FE` from `develop` (the BE branch is behind it) before the first task.
2. Deploy order: BE with the migration first (new table, new policies and routes, nothing breaks for existing callers), then FE.
3. Rollback: revert the FE, then the BE; the `Down` of `AddStudentInterventionEntries` drops the table (it holds only data created after this change).

## Follow-ups

- `StudentService.getTopRiskStudents` builds its endpoint with a leading slash, against §7.1.
- `ERAS-FE/src/app/modules/students/students.routes.ts` (`STUDENT_ROUTES`) is dead code and carries no roles.
- `GetAllStudentsQueryHandler` swallowing every exception hides real errors; the failure should surface.
- `UpdateInterventionCommandHandler` and `DeleteInterventionCommandHandler` (assessment interventions) have no ownership check.
- `ErrorFilter` turns FluentValidation's `ValidationException` into a 500; a dedicated 400 mapping would remove the need for guards.
- A `ForbiddenException` in `Eras.Error` would replace `BussinessException(…, 403)`.
- The `identified_risks` and `support_received` columns, their DTO fields and the `identifiedRisks` and `supportReceived` fields of the FE model stay but are unused by the summary; deciding whether to import, migrate or drop them needs stakeholders.
- The "Interventions" naming overlap between assessment interventions and these entries may confuse users; a product decision on labels is pending.
