# Design

## Context

The two modals are built on different code today. `student-profile-summary-modal` (FE, `src/app/modules/students/students-list/student-profile-summary-modal/`) loads the profile through `StudentService.getStudentProfileSummary` plus the cohort list and the intervention entries, and renders a personal aside, academic tiles, courses and the two intervention lists, with a "STU ID" label. `new-student-modal` (same folder) is one form (`app-form-factory`) with three groups of fields that serves three modes: create ("New Student"), view ("Student Profile", the form disabled) and edit ("Edit Student"); `students-list.component.ts` opens it with the profile loaded through `getStudentProfile` and `cohorts: []` for an existing student. Change 643 (stacked on this branch, not merged into `develop`) added `app-student-interventions` (manages the entries, with its own "Interventions" heading) and `app-student-intervention-list` (shared list).

Both modals read the same endpoint, `GET api/v1/students/{id}/profile` (`StudentsController.GetStudentProfileAsync` → `GetStudentProfileQueryHandler` → `StudentRegistrationMapper.ToDto`). Its `SisId` is `StudentProfile.SisId`, which is empty for imported students; the import stores the SIS ID in `Student.Uuid` (`StudentMapper`). `PUT api/v1/students/{id}/profile` (`UpdateStudentProfileCommandHandler`) calls `StudentRegistrationMapper.ApplyTo`, which overwrites every profile column with the DTO value, so a field the form does not send (SIS ID, CGPA, SAP status, courses, the free-text lists) is set to null on every save. Accepted ADRs read: 0002 and 0003 (not relevant here), 0005 (access; unchanged), ADR-0004 (not relevant).

## Goals / Non-Goals

**Goals:**
- One shared view of the three sections, used by the summary and by the record in view mode (AC-1, AC-2, AC-3, AC-4, AC-5, AC-7 to AC-13, AC-18).
- The SIS ID comes from the existing Student data (AC-5, AC-6, AC-19).
- Saving from the record leaves every stored value that is not shown as it was (AC-15), and the create and edit forms keep their fields (AC-14).
- Each modal still loads the selected student only (AC-16, AC-17).

**Non-Goals:**
- No schema change, no new endpoint, no change to roles or to the student-to-profile relationship.
- No redesign of the Edit and New Student forms.

## Decisions

### D1. The SIS ID is resolved in the BE mapper, from the existing Student data
**Choice:** `StudentRegistrationMapper` gets one helper that returns `Student.Uuid` when `Student.IsImported`, else `StudentProfile.SisId` (null when absent). `ToDto` and the no-profile branch of `GetStudentProfileQueryHandler` both use it, so the existing `SisId` field of the response carries the value and no field is added.
**Alternative:** resolve it in the FE from two fields → the FE would need `Uuid`, which the profile response does not carry, and the rule would be duplicated.
**ADR:** ADR-0006

### D2. One shared presentational component with one shared field definition
**Choice:** new standalone OnPush component `app-student-profile-view` that takes the profile and renders the three sections from a typed definition (`student-profile-sections.ts`: section titles, field labels, order, value getters and a `visible` predicate for the third-attempt field). Both modals render it, so order and labels cannot drift. Its Interventions section has two modes: `read` (the shared view loads the entries with `StudentInterventionService` and shows the two `app-student-intervention-list` read-only, logic moved out of the summary modal) and `manage` (it renders `app-student-interventions`, 643's own heading is the section title). The definition marks the data source of the third-attempt flag (`profile.isCurrentCourseThirdAttempt`) and of the interventions (`student_intervention_entries` through `StudentInterventionService`) so the migration work can plug in without touching the layout.
**Alternative:** keep two templates and copy the layout → exactly the drift the ticket complains about.

### D3. A save keeps the stored profile-view values the request does not carry
**Choice:** a new mapper method `ApplyUpdateTo` is used by `UpdateStudentProfileCommandHandler` for an existing profile: it applies the registration columns exactly like `ApplyTo` and, for the profile-view columns (SIS ID, CGPA, SAP status, third attempt, passed and failed counts, current courses, the two free-text lists), applies a value only when the request carries one (null keeps the stored value). `ApplyTo` stays as it is for the create paths. The FE does not echo hidden values.
**Alternative:** the FE sends back what it loaded → it would copy the imported SIS ID (`Uuid`, D1) into the profile column on every save.
**ADR:** ADR-0006 (it protects the rule: the update never writes the imported value into the profile)

### D4. The record switches between the shared view and the form
**Choice:** in `new-student-modal`, `isViewing` renders `app-student-profile-view` (mode `manage`, the Interventions section it already shows) and the Edit/New forms render the existing `app-form-factory` and, below it, `app-student-interventions` for an existing student, exactly as today. `startEditing()` and `cancelEditing()` only flip `isViewing`; `setFormGroup` applies the locked fields, the state options and the pristine form each time the form is created, and the form reference is dropped when it is destroyed. The record gets the cohort name from the cohort list that `students-list` loads (it passes `cohorts` for an existing student too), resolved by the same helper the summary uses.
**Alternative:** keep the disabled form and hide fields with CSS → the hidden values would stay in the DOM and the view would still be a different layout.

## Changes by layer

### Backend (`ERAS-BE/`)

| Layer | Change | Files | ACs |
|---|---|---|---|
| Application | Helper that resolves the SIS ID; `ToDto` uses it; `ApplyUpdateTo` that keeps unsent profile-view values | `src/Eras.Application/Mappers/StudentRegistrationMapper.cs` | AC-6, AC-19, AC-15 |
| Application | The no-profile response of the query uses the helper | `src/Eras.Application/Features/Students/Queries/GetStudentProfile/GetStudentProfileQueryHandler.cs` | AC-6 |
| Application | The update of an existing profile calls `ApplyUpdateTo` | `src/Eras.Application/Features/Students/Commands/UpdateStudentProfile/UpdateStudentProfileCommandHandler.cs` | AC-15 |
| Application | XML comment of `SisId` says where the value comes from | `src/Eras.Application/DTOs/Student/StudentRegistrationDto.cs` | AC-6, AC-19 |

No Domain, Infrastructure or Api change.

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Shared view | New `app-student-profile-view` (ts, html, scss, spec) and `student-profile-sections.ts` with the shared field definition, the display helper and the cohort-name helper | `src/app/modules/students/students-list/student-profile-view/` (new) | AC-3, AC-4, AC-5, AC-7 to AC-11, AC-18 |
| Summary modal | Renders the shared view in `read` mode; keeps loading the profile and cohorts; drops the aside, tiles, the entries logic and the "STU ID" label | `.../student-profile-summary-modal/*` | AC-1, AC-12, AC-16 |
| Record modal | `isViewing` renders the shared view in `manage` mode; Edit and New keep the form; `student` is typed `StudentProfileSummaryModel`; form lifecycle per D4 | `.../new-student-modal/new-student-modal.component.{ts,html}` | AC-2, AC-13, AC-14, AC-15 |
| Students list | `openStudentProfileModal` loads the profile with `getStudentProfileSummary` and the cohorts (`loadCohortLookups`) and passes both | `.../students-list/students-list.component.ts` | AC-17 |
| Model / service | None: `student-profile-summary.model.ts` and `StudentService` already mirror the response; `sisId` now carries the resolved SIS ID | `src/app/core/models/student-profile-summary.model.ts` (comment only) | AC-5 |
| Messages | Section titles, field labels and the "Yes" value of the third-attempt field, replacing the "STU ID" label and the unused tile labels | `src/app/core/constants/messages.ts` (`STUDENT_PROFILE_MESSAGES`) | AC-1 to AC-5, AC-7 to AC-10 |

## API contract

No API change. `GET api/v1/students/{id}/profile` keeps its shape (policies unchanged, status codes unchanged). Two behaviors change, both without touching the DTO: `SisId` now carries the resolved SIS ID (D1), and `PUT api/v1/students/{id}/profile` no longer clears the profile-view values it does not receive (D3). Swagger needs no update beyond the DTO comment.

- **FE model:** `student-profile-summary.model.ts` mirrors the response already.
- **FE service:** `StudentService.getStudentProfileSummary` (existing).
- **Ownership / scope rules:** unchanged (`StudentAccessService`, ADR-0005).

## Data and migration

No schema change and no migration. `Student.Uuid` and `StudentProfile.SisId` are read as they are; nothing is copied or dropped (ADR-0006).

## Test strategy

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | FE | `.../student-profile-summary-modal/student-profile-summary-modal.component.spec.ts` | `[641-align-student-modal-fields/AC-1] shows the three sections in order and no other` |
| AC-2 | FE | `.../new-student-modal/new-student-modal.component.spec.ts` | `[641-align-student-modal-fields/AC-2] shows the three sections in order when opened for viewing` |
| AC-3 | FE | `.../student-profile-view/student-profile-view.component.spec.ts` | `[641-align-student-modal-fields/AC-3] lists the personal fields in order with the full name as first names` |
| AC-4 | FE | same | `[641-align-student-modal-fields/AC-4] shows a dash for a missing personal value` |
| AC-5 | FE | same | `[641-align-student-modal-fields/AC-5] shows SIS ID and never STU ID` |
| AC-6 | BE | `test/Eras.Application.Tests/Features/Students/ManualRegistration/GetStudentProfileSisIdTests.cs` (new) | `Handle_ImportedStudent_ReturnsTheImportedIdentifierAsSisIdAsync` |
| AC-7 | FE | `student-profile-view.component.spec.ts` | `[641-align-student-modal-fields/AC-7] lists the academic fields in order` |
| AC-8 | FE | same | `[641-align-student-modal-fields/AC-8] shows the third-attempt field when it applies` |
| AC-9 | FE | same | `[641-align-student-modal-fields/AC-9] hides the third-attempt field when it does not apply or is unknown` |
| AC-10 | FE | same | `[641-align-student-modal-fields/AC-10] lists each current course with group and section` |
| AC-11 | FE | same | `[641-align-student-modal-fields/AC-11] shows risks and support as two lists with empty-state messages` |
| AC-12 | FE | `student-profile-summary-modal.component.spec.ts` | `[641-align-student-modal-fields/AC-12] does not show the fields outside the agreed list` |
| AC-13 | FE | `new-student-modal.component.spec.ts` | `[641-align-student-modal-fields/AC-13] does not show the fields outside the agreed list when viewing` |
| AC-14 | FE | same | `[641-align-student-modal-fields/AC-14] keeps the fields of the edit and new student forms` |
| AC-15 | BE | `test/Eras.Application.Tests/Features/Students/ManualRegistration/UpdateStudentProfileCommandHandlerTests.cs` | `Handle_RequestWithoutProfileViewValues_KeepsTheStoredOnesAsync` |
| AC-15 | FE | `new-student-modal.component.spec.ts` | `[641-align-student-modal-fields/AC-15] saves the edited value and sends the unchanged form values` |
| AC-16 | FE | `student-profile-summary-modal.component.spec.ts` | `[641-align-student-modal-fields/AC-16] requests the profile of the selected student only` |
| AC-17 | FE | `.../students-list/students-list.component.spec.ts` | `[641-align-student-modal-fields/AC-17] opens the record with the profile of the selected student only` |
| AC-18 | FE | `.../students-list/student-profile-modals.consistency.spec.ts` (new) | `[641-align-student-modal-fields/AC-18] both modals show the same labels, values and order for the same student` |
| AC-19 | BE | `GetStudentProfileSisIdTests.cs` | `Handle_ManualStudent_ReturnsTheProfileSisIdOrNoneAsync` |

BE tests carry `[Trait("Change", "641-align-student-modal-fields")]` and `[Trait("AC", "641-align-student-modal-fields/AC-n")]`. Extra edge-case tests carry no AC tag. Coverage gates: BE >= 25%, FE >= 15% (AGENTS.md section 8.7).

## Risks / Trade-offs

- [The record modal switches between the shared view and the form; the form is created and destroyed per edit session, so locked fields, state options and the pristine check must be re-applied] → D4 puts that in `setFormGroup`; the existing editing tests (view, edit, cancel, locked fields, cannot-manage user) are adapted and keep passing.
- [The "Interventions" heading comes from `app-student-interventions` in `manage` mode and from the shared view in `read` mode] → both use `STUDENT_INTERVENTION_MESSAGES.SECTION_TITLE`; AC-2 and AC-1 assert the heading order.
- [`ApplyUpdateTo` means a client can no longer clear a profile-view value through the API by sending null] → no screen or caller does that today (nothing in the FE sends those fields); clearing is a future change.
- [The imported SIS ID is returned in `SisId`; a client that echoes the response into an update would write it into the profile column] → the FE builds its payload from the form only; ADR-0006 records the rule.
- [Change 643 is not merged into `develop` yet] → this branch contains the 643 branches; the PRs for 641 wait for 643 to merge and are rebased if 643 changes.

## Follow-ups

- `StudentService.getStudentProfile` has no caller after this change (the list uses `getStudentProfileSummary`); remove it in a refactor change.
- The unused tile and aside styles of the profile summary go with this change; nothing else is refactored.
- Confirm with stakeholders whether the removed fields (date of birth, gender, ID/passport, secondary email, address, level of study, faculty, modality, previous institution) are needed on any other screen (ticket developer note); they are only hidden here.
