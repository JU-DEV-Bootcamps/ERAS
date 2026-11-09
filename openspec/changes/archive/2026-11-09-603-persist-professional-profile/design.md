# Design

## Context

- Professional fields are mock data in `ERAS-FE/src/app/core/store/professional-profile.store.ts` (`MOCK_PROFESSIONAL_PROFILE`). There is no backend endpoint for them.
- `Position` already lives on the user record: column `position` (max 100) on `eras_users`, mapped by `ERAS-BE/src/Eras.Infrastructure/Persistence/PostgreSQL/Configurations/ErasUserConfiguration.cs` from `ERAS-BE/src/Eras.Domain/Entities/UserManagement/ErasUser.cs`. The general profile update (`UpdateUserProfileCommandHandler.cs`) writes it for every role. See proposal A1.
- The general profile is served by `GET/PUT api/v1/users/me/profile` in `ERAS-BE/src/Eras.Api/Controllers/UsersController.cs`. `GetMyProfileQueryHandler.cs` already returns `ActiveInterventionsCount` (interventions the user created that are not finalized, `IAssessmentRepository.CountActiveInterventionsForUserAsync`). The count is read-only and needs no change (AC-18, AC-19).
- `ProfessionalsController` (`api/v1/professionals`) carries class-level `AdminOrOfficer`, so it cannot host professional-only endpoints (AC-5 denies Officers).
- `ErasPolicies.AdminOrProfessional` already exists in `ERAS-BE/src/Eras.Infrastructure/Authorization/ErasPolicies.cs`, but it also allows the Administrator. The spec now allows only the Professional (AC-5, AC-6, AC-20), so a professional-only policy is needed (D3).
- Frontend: the account page is `ERAS-FE/src/app/modules/profile/components/account-information/`. It always renders the summary and, for professionals, the professional section below it (a full-width row from the earlier merge). The professional role is compared directly against `ERASRoles.PROFESSIONAL`. `PermissionsService` lives in `core/services/permissions/` with policies in `permission.policies.ts`.
- Existing test layout: `ERAS-BE/test/Eras.Application.Tests/Features/ErasUsers/{Commands,Queries}`, `ERAS-BE/test/Eras.Api.Tests/Authorization/` (`ControllerPolicyEvaluator` evaluates real `ErasPolicies` against a principal), and the FE specs next to each component.

## Goals / Non-Goals

**Goals:**
- Store and serve the professional profile (AC-1 to AC-4, AC-7) and deny it to every role except the professional, including Administrator (AC-5, AC-6, AC-20).
- Keep one owner for Position for professionals (AC-7, AC-8) and leave other roles unchanged (AC-9).
- Replace the mock with the API and show active interventions read-only (AC-12, AC-13, AC-14, AC-18, AC-19).
- Replace the summary panel with the professional section for the professional role (AC-10, AC-11) and hide Position in the edit form for professionals (AC-15, AC-16).

**Non-Goals:**
- No new definition, storage or endpoint for active interventions (reuse only).
- No change to `ProfessionalsController` or to who manages professionals.
- No editing of the existing general profile fields for professionals beyond Position.

## Decisions

### D1. Professional profile in its own table, Position stays on the user
**Choice:** a new table `professional_profiles` with one row per ERAS user (`eras_user_id`, unique foreign key to `eras_users.id`) holding `faculty` and `office_hours` (both `varchar(200)`, required by the application). `position` stays on `eras_users` (proposal A1), so the summary and the card keep reading it unchanged.
**Alternative:** add faculty and office hours as columns on `eras_users` → mixes professional-only data into every user row and into the general profile DTO. Rejected.
**ADR:** ADR-0002

### D2. Subjects as an array column, courses as a child table
**Choice:** `subjects_taught` is a `text[]` column on `professional_profiles` (`HasColumnType("text[]")`), a short list with no attributes, as ADR-0002 prescribes. Its values are names, not identifiers, so this applies the same rule to a list of values; no contradiction. `professional_courses` is a child table (`professional_profile_id`, `code`, `name`) because a course has two attributes, as ADR-0002 requires for relations with their own data. The spec asks for no course order, so no order column is stored; the list is read in insertion order (by `id`).
**Alternative:** `jsonb` for courses → nothing in the code base uses it and ADR-0002 rejects it. A `text[]` of "CODE - Name" strings → cannot be validated per field. Rejected.
**ADR:** ADR-0002

### D3. Endpoints on the users controller, policy `ProfessionalOnly`
**Choice:** `GET api/v1/users/me/professional-profile` and `PUT api/v1/users/me/professional-profile` in `UsersController`, each with `[Authorize(Policy = ErasPolicies.ProfessionalOnly)]`. The new policy allows only the `ERAS Professional` role, so the Administrator and Officer and Guest are denied (AC-5, AC-6, AC-20). Each `PUT` saves the whole professional profile (position, faculty, office hours, subjects, courses), not only position; position is one of its fields (D4). The handler resolves the caller by sub, then email, the same way `GetMyProfileQueryHandler` does.
**Why not `AdminOrProfessional`:** it also allows the Administrator, which the spec now forbids.
**Open point:** the rule that the Administrator passes every check (AGENTS.md §4.3) does not hold for this endpoint. The exception is recorded in ADR-0009 (Accepted).
**ADR:** ADR-0009
**Alternative:** a new `ProfessionalProfilesController` → adds a controller for two actions that belong with `me/profile`. Using `ProfessionalsController` → its class-level `AdminOrOfficer` would deny Professionals. Rejected.

### D4. Position written by one endpoint, ignored by the other for professionals
**Choice:** `PUT me/professional-profile` writes `Position` onto the user. `UpdateUserProfileCommandHandler` keeps the stored position when the user's role is `ERAS Professional` (the role is read from the existing entity) and still writes it for every other role (AC-8, AC-9). The general request keeps its `Position` field, so the handler does not need a new request shape.
**Alternative:** remove `Position` from the general request for everyone → breaks AC-9 (Officers keep updating position). Rejected.

### D5. Active interventions reused from the existing profile
**Choice:** the professional section reads `activeInterventionsCount` from the `me/profile` response that `AccountInformationComponent` already loads for the summary. The professional endpoint does not return the count.
**Alternative:** return the count from the professional endpoint → duplicates the count and adds a second source for the same number. Rejected.

### D6. Role gate through permissions, not raw role comparison
**Choice:** add `CAN_SEE_PROFESSIONAL_PROFILE: [ERASRoles.PROFESSIONAL]` to `permission.policies.ts`. The account page and the profile edit form use `PermissionsService` for this gate (AGENTS.md §7.1 step 5), replacing the direct `ERASRoles.PROFESSIONAL` comparison.
**Alternative:** keep the direct comparison → violates §7.1 and the page is being rewritten anyway. Rejected.

### D7. Field rules as approved in the spec
**Choice:** faculty is required (AC-4); position and office hours may be empty (AC-21). Length limits are those of AC-22: position 100; faculty, office hours, each subject and each course name 200; course code 20. The validator enforces them and returns 400 naming the field. Subjects and courses may be empty lists (AC-2, A5). Course code and course name must be non-empty (AC-23).
**Alternative:** no limits on course or subject values → unbounded text in a row. Rejected.

### D8. Save replaces the whole profile
**Choice:** a valid `PUT` replaces `faculty`, `office_hours`, `subjects_taught`, and the course rows as one unit, and rejects the update as a whole when any field is invalid (AC-3, AC-4). Persisted values stay unchanged on rejection.
**Alternative:** patch semantics per field → the spec describes a whole-profile save. Rejected.

### D9. Layout: professional section takes the summary's grid slot
**Choice:** in `account-information.component.html`, `@if (isProfessional())` renders `section-professional` in place of `section-summary`; otherwise the summary renders. Both use the same slot of the existing two-column grid. The full-width rule for the professional section from the earlier merge is removed (AC-10, AC-11).
**Alternative:** keep the full-width row below the summary → the summary would still render for professionals, against AC-10. Rejected.

## Changes by layer

### Backend (`ERAS-BE/`)

| Layer | Change | Files | ACs |
|---|---|---|---|
| Domain | New entity `ProfessionalProfile` (faculty, office hours, subjects, courses) and `ProfessionalCourse`; `AbstractValidator` for the update rules of D7 | `src/Eras.Domain/Entities/UserManagement/ProfessionalProfile.cs` (new), `.../ProfessionalProfileValidator.cs` (new) | AC-3, AC-4, AC-22 |
| Application | Contract `IProfessionalProfileRepository`; queries `GetMyProfessionalProfileQuery`, command `UpdateMyProfessionalProfileCommand`, DTOs `ProfessionalProfileDTO`/`ProfessionalCourseDTO`, request `UpdateProfessionalProfileRequest`, mapper; handlers below | `src/Eras.Application/Contracts/Persistence/UserManagement/IProfessionalProfileRepository.cs` (new), `Features/ErasUsers/Queries.cs`, `Commands.cs`, `DTOs/UsersManagement/ProfessionalProfileDTO.cs` (new), `Mappers/ProfessionalProfileMapper.cs` (new) | AC-1, AC-2, AC-3, AC-4, AC-7 |
| Application | `GetMyProfessionalProfileQueryHandler`: returns the caller's profile, or empty values when none is saved | `src/Eras.Application/Features/ErasUsers/Handlers/QueryHandlers/GetMyProfessionalProfileQueryHandler.cs` (new) | AC-1, AC-2 |
| Application | `UpdateMyProfessionalProfileCommandHandler`: validates (D7), replaces the profile (D8), writes Position onto the user (D4) | `src/Eras.Application/Features/ErasUsers/Handlers/CommandHandlers/UpdateMyProfessionalProfileCommandHandler.cs` (new) | AC-3, AC-4, AC-7, AC-21 |
| Application | `UpdateUserProfileCommandHandler`: keeps stored Position for professionals | `src/Eras.Application/Features/ErasUsers/Handlers/CommandHandlers/UpdateUserProfileCommandHandler.cs` | AC-8, AC-9 |
| Infrastructure | Policy `ProfessionalOnly` (Professional role only), EF configuration of both tables (`text[]` for subjects), repository, DbSets, DI registration, migration `AddProfessionalProfiles` | `src/Eras.Infrastructure/Persistence/PostgreSQL/Configurations/ProfessionalProfileConfiguration.cs` (new), `Repositories/UserManagement/ProfessionalProfileRepository.cs` (new), `AppDbContext.cs`, `PersistenceServiceRegistration.cs`, `Migrations/<timestamp>_AddProfessionalProfiles.cs` (new) | AC-1, AC-3 |
| Api | `GET` and `PUT me/professional-profile` on the users controller, `ProfessionalOnly` | `src/Eras.Api/Controllers/UsersController.cs` | AC-5, AC-6, AC-20 |

Existing tests for `GetMyProfileQueryHandler` cover AC-18 (the count is still returned after a professional update).

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Permissions | Add `CAN_SEE_PROFESSIONAL_PROFILE` for the professional role | `src/app/core/services/permissions/permission.policies.ts` | AC-10, AC-11, AC-15, AC-16 |
| Model | Mirror the response DTO: `position`, `faculty`, `officeHours`, `subjectsTaught`, `courses: { code, name }[]`; remove `activeEvaluations`; make `position` optional on the general update request | `src/app/core/models/professional-profile.model.ts`, `src/app/core/models/user-profile.model.ts` | AC-12, AC-13, AC-15 |
| Service | `ProfessionalProfileService` extends `BaseApiService`, resource `users`, methods `getMyProfessionalProfile` (`me/professional-profile`) and `updateMyProfessionalProfile` | `src/app/core/services/api/professional-profile.service.ts` (new) | AC-12, AC-13, AC-14 |
| Store | Remove `MOCK_PROFESSIONAL_PROFILE`; the store starts empty and is filled from the service | `src/app/core/store/professional-profile.store.ts` | AC-12, AC-13 |
| Page | `isProfessional` through `CAN_SEE_PROFESSIONAL_PROFILE`; `section-professional` replaces `section-summary`; the full-width rule is removed | `src/app/modules/profile/components/account-information/account-information.component.{html,scss,ts}` | AC-10, AC-11 |
| Component | Professional info: loads from the service, reads the active interventions count as an input, shows it read-only | `.../professional-info/professional-info.component.{html,ts}` | AC-12, AC-19 |
| Component | Professional edit form: saves through the service, updates the store on success, shows an error and keeps the form open on failure | `.../professional-info-edit-form/professional-info-edit-form.component.ts` | AC-13, AC-14 |
| Component | Profile edit form: no Position field for professionals (permission gate), position omitted from the payload for them | `.../profile-edit-form/profile-edit-form.component.ts` | AC-15, AC-16 |
| Messages | Error text for a failed professional save | `src/app/core/constants/messages.ts` | AC-14 |

## API contract

| Endpoint | Policy | Request DTO | Response DTO | Status codes |
|---|---|---|---|---|
| `GET api/v1/users/me/professional-profile` | `ErasPolicies.ProfessionalOnly` | — | `ProfessionalProfileDTO` { position: string, faculty: string, officeHours: string, subjectsTaught: string[], courses: `ProfessionalCourseDTO`[] { code: string, name: string } } | 200, 401, 403, 404 |
| `PUT api/v1/users/me/professional-profile` | `ErasPolicies.ProfessionalOnly` | `UpdateProfessionalProfileRequest` { position, faculty, officeHours, subjectsTaught, courses } | `ProfessionalProfileDTO` | 200, 400, 401, 403, 404 |

- **FE model:** `core/models/professional-profile.model.ts` mirrors `ProfessionalProfileDTO` exactly. `UpdateUserProfileRequest.position` becomes optional.
- **FE service:** `core/services/api/professional-profile.service.ts`, methods `getMyProfessionalProfile` and `updateMyProfessionalProfile`, no leading slash.
- **Ownership / scope rules:** the caller's own profile only, resolved from the authenticated identity in the handler, never from a route id (AC-1, AC-3).
- **Contract change:** `PUT api/v1/users/me/profile` no longer changes position for professionals (AC-8). Its request shape is unchanged.

## Data and migration

- New table `professional_profiles`: `id` (identity), `eras_user_id` (unique, foreign key to `eras_users.id`), `faculty` `varchar(200)` not null, `office_hours` `varchar(200)` not null, `subjects_taught` `text[]` not null with default empty array, audit columns as on the other tables.
- New table `professional_courses`: `id`, `professional_profile_id` (foreign key with cascade delete), `code` `varchar(20)` not null, `name` `varchar(200)` not null. No order column (see D2).
- Migration `AddProfessionalProfiles` created with `dotnet ef migrations add`. Schema changes only in the migration; `AppDbContextModelSnapshot.cs` is updated by the tool, never by hand.
- No backfill: existing professionals have no row until they save (AC-2 returns empty values).

## Test strategy

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | BE | Application: `test/Eras.Application.Tests/Features/ErasUsers/Queries/` | `GetMyProfessionalProfileQueryHandlerTests.cs` › `HandleAsync_SavedProfile_ReturnsAllFieldsAsync` |
| AC-2 | BE | Application | `GetMyProfessionalProfileQueryHandlerTests.cs` › `HandleAsync_NeverSaved_ReturnsEmptyValuesAsync` |
| AC-3 | BE | Application: `test/Eras.Application.Tests/Features/ErasUsers/Commands/` | `UpdateMyProfessionalProfileCommandHandlerTests.cs` › `HandleAsync_ValidProfile_ReplacesSavedValuesAsync` |
| AC-4 | BE | Application | `UpdateMyProfessionalProfileCommandHandlerTests.cs` › `HandleAsync_EmptyFaculty_ThrowsValidationAndKeepsValuesAsync` |
| AC-5 | BE | Api: `test/Eras.Api.Tests/Authorization/` | `ProfessionalProfilePolicyTests.cs` › `ProfessionalProfile_OfficerIsDenied_OnReadAndUpdate` (via `ControllerPolicyEvaluator`) |
| AC-6 | BE | Api | `ProfessionalProfilePolicyTests.cs` › `ProfessionalProfile_GuestIsDenied` |
| AC-20 | BE | Api | `ProfessionalProfilePolicyTests.cs` › `ProfessionalProfile_AdministratorIsDenied` |
| AC-21 | BE | Application: `test/Eras.Application.Tests/Features/ErasUsers/Commands/` | `UpdateMyProfessionalProfileCommandHandlerTests.cs` › `HandleAsync_EmptyPositionAndOfficeHours_SavesAsync` |
| AC-22 | BE | Domain: `test/Eras.Domain.Tests/` | `ProfessionalProfileValidatorTests.cs` › `Validate_OfficeHoursOver200Chars_FailsOnOfficeHours` |
| AC-23 | BE | Application: `test/Eras.Application.Tests/Features/ErasUsers/Commands/` | `UpdateMyProfessionalProfileCommandHandlerTests.cs` › `HandleAsync_CourseWithEmptyName_ThrowsValidationAndKeepsValuesAsync` |
| AC-7 | BE | Application | `UpdateMyProfessionalProfileCommandHandlerTests.cs` › `HandleAsync_Position_UpdatesUserPositionAsync` |
| AC-8 | BE | Application: `test/Eras.Application.Tests/Features/ErasUsers/Commands/` | `UpdateUserProfileCommandHandlerTests.cs` › `HandleAsync_ProfessionalPosition_KeepsStoredPositionAsync` |
| AC-9 | BE | Application | `UpdateUserProfileCommandHandlerTests.cs` › `HandleAsync_OfficerPosition_UpdatesPositionAsync` |
| AC-18 | BE | Application: `test/Eras.Application.Tests/Features/ErasUsers/Queries/` | `GetMyProfileQueryHandlerTests.cs` › `HandleAsync_AfterProfessionalUpdate_ReportsSameActiveInterventionsAsync` |
| AC-10 | FE | `src/app/modules/profile/components/account-information/account-information.component.spec.ts` | `[603-persist-professional-profile/AC-10] shows the professional info in place of the summary` |
| AC-11 | FE | same spec | `[603-persist-professional-profile/AC-11] shows the summary and no professional info for an officer` |
| AC-12 | FE | `.../professional-info/professional-info.component.spec.ts` | `[603-persist-professional-profile/AC-12] shows faculty and office hours returned by the backend` |
| AC-13 | FE | `.../professional-info-edit-form/professional-info-edit-form.component.spec.ts` | `[603-persist-professional-profile/AC-13] returns to view mode showing the saved faculty` |
| AC-14 | FE | same spec | `[603-persist-professional-profile/AC-14] shows an error and keeps the form open when the save fails` |
| AC-15 | FE | `.../profile-edit-form/profile-edit-form.component.spec.ts` | `[603-persist-professional-profile/AC-15] has no Position field and sends no position for a professional` |
| AC-16 | FE | same spec | `[603-persist-professional-profile/AC-16] keeps the Position field for an officer` |
| AC-19 | FE | `.../professional-info/professional-info.component.spec.ts` | `[603-persist-professional-profile/AC-19] shows active interventions read-only` |

Status codes: AC-1 to AC-4, AC-21, AC-22 and AC-23 state a 200 or 400 response. Their rule is decided in the handler or the domain validator, so the test sits there (AGENTS.md §6.3, where the behavior is decided). For a 400 the handler turns the validation failure into a `BussinessException` with status 400 and the messages that name the fields (AC-4, AC-22, AC-23), and `ErrorFilter` returns that status; the handler tests assert the status and the message. The Api tests cover only what the Api layer decides: the policy of each endpoint (AC-5, AC-6, AC-20).

Extra edge-case tests (validation details of D7, empty courses, ordering) carry no AC tag. Coverage gates: BE >= 25%, FE >= 15% (AGENTS.md section 8.7).

## Risks / Trade-offs

- [Position written by two paths (D4) could diverge] → only the professional endpoint writes Position for professionals, and the general handler is guarded by the role check; covered by AC-7 and AC-8 tests.
- [Two tables saved in one update could be partly written] → save the profile and the user's position in one unit of work through the shared `AppDbContext`; the task list checks this in the repository before merging.
- [Mock data still referenced by old specs] → the store spec and the component specs are updated in the same change; no mock remains (AC-12).
- [Shared general profile endpoint changes behavior for professionals] → Position is the only changed field and only for professionals; AC-9 keeps other roles unchanged.
- [Migration on a live table] → only new tables, no change to `eras_users`; no locking risk on existing rows.

## Migration Plan

- Deploy the migration `AddProfessionalProfiles` with the backend. It only creates two tables; rollback is dropping them (the migration's `Down`).
- Deploy the frontend after the backend. Until then the page would call an endpoint that does not exist, so the two deploy together.

## Open Questions

None.

## Follow-ups

- `ProfessionalsController` has class-level `AdminOrOfficer` and a legacy `BaseResponse` return; out of scope, not changed here.
- The old `activeEvaluations` naming may remain in archived specs of other changes; not touched here.
