# Design

## Context

Today `NewStudentModalComponent` (`ERAS-FE/src/app/modules/students/students-list/new-student-modal/`) serves three jobs: create (no `data.student`), edit (`data.student` + `hasProfile`) and a read-only mode (`isViewing`, `opensEditable`, `startEditing`, `cancelEditing`, the "Edit" button and `canEditStudent`) that renders `app-student-profile-view` with `interventionsMode="manage"`. `StudentsListComponent` opens it from the `viewProfile` action (`openStudentProfileModal`, which also loads the cohorts only to show the cohort name in view mode) and from the "New Student" button (`openNewStudentModal`). `StudentProfileSummaryModalComponent` is already the read-only modal and uses `app-student-profile-view` with `interventionsMode="read"`. Users without `CAN_MANAGE_STUDENTS` keep the `viewProfile` and `profileSummary` actions (`actionDatas` filter in the list constructor).

Motivation and ACs: `proposal.md` and `specs/student-profile-modals/spec.md`. No ADR in `openspec/adr/` applies (FE-only, no API, no auth model change: the existing `CAN_MANAGE_STUDENTS` permission is reused).

## Goals / Non-Goals

**Goals:**
- Two modals with one job each: `NewStudentModalComponent` creates (AC-10), a new `EditStudentModalComponent` edits (AC-3, AC-4, AC-6 to AC-9, AC-13, AC-14, AC-16); the profile summary stays read-only (AC-1, AC-2, AC-11, AC-12, AC-15).
- The list action is "Edit Student Profile" and open for every user of the list, with the profile fields disabled for those who cannot manage students (AC-5, AC-17).

**Non-Goals:**
- Changing any field, validator, label or payload of the forms; changing `StudentProfileViewComponent` or the summary layout.

## Decisions

### D1. Add `EditStudentModalComponent` and strip the other modes from `NewStudentModalComponent`
**Choice:** new standalone component in `students-list/edit-student-modal/` (data: `{ student: StudentProfileSummaryModel }`, always editable, title from messages); `NewStudentModalComponent` keeps only creation (data: `{ cohorts }`). Removed from the new modal: `student`, `hasProfile`, `isEditing`, `isViewing`, `opensEditable`, `canEditStudent`, `startEditing`, `cancelEditing`, `lockedFieldNames`, the interventions block and the view branch of its template.
**Alternative:** keep one component and only drop the viewing mode → it would still mix create and edit, which the issue wants separated.

### D2. Share the form definition through a plain helper file, not inheritance
**Choice:** move what both modals need to `students-list/student-form/student-form.ts` (new): the pattern and option constants, the validators (`notBlank`, `differentFromPrimaryEmail`), a field builder that takes `{ student?, cohorts?, lockedFields }`, the state/province sync and the payload builder (trim, date format). Both components call it; fields, validators and payload stay identical (non-goal).
**Alternative:** duplicate the ~300 lines in each modal → drift between create and edit; an abstract base component → legacy-style coupling.

### D3. The list reaches the edit modal without cohorts; non-managers get it read-only
**Choice:** in `StudentsListComponent`, rename the action id `viewProfile` to `editProfile` (label "Edit profile", tooltip "Edit Student Profile", icon `edit`), rename `openStudentProfileModal` to `openEditStudentModal`, and load only `getStudentProfileSummary(student.id)` (the edit form has no cohort field, so the `forkJoin` with `getCohorts` and `withCohortName` are dropped). The constructor filter for users without `CAN_MANAGE_STUDENTS` keeps `editProfile` and `profileSummary` (the Professional still reaches the interventions management, student-interventions AC-22 and AC-30); `EditStudentModalComponent` reads `PermissionsService.can(CAN_MANAGE_STUDENTS)` and, without it, disables the form after creation, hides Save and shows only Close. User-facing text goes to `STUDENT_PROFILE_MESSAGES` in `core/constants/messages.ts`.
**Alternative:** keep the id `viewProfile` → a misleading name; no other code or analytics reference it (checked with a search of `src/app` outside specs).

## Changes by layer

### Backend (`ERAS-BE/`)

| Layer | Change | Files | ACs |
|---|---|---|---|
| Test only | Re-tag the existing handler test to this change's AC (no production change) | `test/Eras.Application.Tests/Features/Students/ManualRegistration/UpdateStudentProfileCommandHandlerTests.cs` | AC-14 |

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Component (new) | `EditStudentModalComponent`: always editable, form + `app-student-interventions` below, locked fields for imported students, `unsavedChangesGuard`, Cancel and close both call `requestClose()`, title "Edit Student Profile" | `students-list/edit-student-modal/edit-student-modal.component.{ts,html,spec.ts}` (new; styles reuse `assessments-modal-styles.scss`) | AC-3, AC-4, AC-6, AC-7, AC-8, AC-9, AC-14, AC-16, AC-17 |
| Shared helper (new) | Field builder, validators, state sync, payload builder (D2) | `students-list/student-form/student-form.ts` (new) | AC-10, AC-13 |
| Component | `NewStudentModalComponent` create-only; remove edit/view code and its tests | `new-student-modal/new-student-modal.component.{ts,html,spec.ts}` | AC-10, AC-13 |
| Component | Students list: action rename, permission filter (keeps `editProfile` for Professionals), `openEditStudentModal`, `openStudentModal` per modal | `students-list/students-list.component.ts` and `.spec.ts` | AC-5, AC-16 |
| Messages | `EDIT_STUDENT_PROFILE` title and action texts | `src/app/core/constants/messages.ts` | AC-3, AC-5 |
| Tests only | Summary: add "no editable fields" test and re-tag; profile view icon test re-tagged; consistency spec rewritten | `student-profile-summary-modal/*.spec.ts`, `student-profile-view/*.spec.ts`, `student-profile-modals.consistency.spec.ts` | AC-1, AC-2, AC-11, AC-12, AC-13, AC-15 |
| Styles | The edit modal gets the same 3-column form grid as the new student modal; the list action button and the table card actions are vertically aligned (`align-items: center`, `height: fit-content`) so the actions row keeps its look next to the new icons | `src/styles/utils/_forms.scss`, `students-list/students-list.component.scss`, `src/app/shared/components/table-with-actions/table-with-actions.component.scss` | none (visual only) |
| Tests only | Mobile spec: use the renamed action id (tag of change 659 unchanged) | `students-list/students-list-mobile.component.spec.ts` | none |

## API contract

No API change.

## Data and migration

No schema change.

## Test strategy

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | FE | `student-profile-summary-modal/student-profile-summary-modal.component.spec.ts` | `[686-edit-focused-student-profile-modal/AC-1] shows the three sections in order and no other` (re-tag of the 641 test) |
| AC-2 | FE | same spec | `[686-edit-focused-student-profile-modal/AC-2] shows no editable field and only a way to close` |
| AC-3 | FE | `edit-student-modal/edit-student-modal.component.spec.ts` | `[686-…/AC-3] opens editable with the stored values, titled Edit Student Profile and without an Edit button` |
| AC-4 | FE | same spec | `[686-…/AC-4] opens editable and prefilled with name and email for a student without a profile` |
| AC-5 | FE | `students-list/students-list.component.spec.ts` | `[686-…/AC-5] shows Edit Student Profile and Profile summary to a Professional but no delete` |
| AC-6 | FE | edit modal spec | `[686-…/AC-6] shows the interventions list with its add control below the form` |
| AC-7 | FE | edit modal spec | `[686-…/AC-7] sends the update, closes with true and shows a success message` |
| AC-8 | FE | edit modal spec | `[686-…/AC-8] discards unsaved changes after confirming and sends no request` |
| AC-9 | FE | edit modal spec | `[686-…/AC-9] closes on Cancel without asking when nothing changed` |
| AC-10 | FE | `new-student-modal/new-student-modal.component.spec.ts` | `[686-…/AC-10] creates a student from the New Student modal` |
| AC-11 | FE | `student-profile-view/student-profile-view.component.spec.ts` | `[686-…/AC-11] shows an icon with a colour on each academic field and keeps the agreed order` (re-tag) |
| AC-12 | FE | summary spec | `[686-…/AC-12] does not show the fields outside the agreed list` (re-tag) |
| AC-13 | FE | `student-profile-modals.consistency.spec.ts` | `[686-…/AC-13] edit and new student forms keep their fields` |
| AC-14 | BE | `test/Eras.Application.Tests/Features/Students/ManualRegistration/UpdateStudentProfileCommandHandlerTests.cs` | `Handle_RequestWithoutProfileViewValues_KeepsTheStoredOnesAsync` (re-tagged, `Change` + `AC` traits) |
| AC-14 | FE | edit modal spec | `[686-…/AC-14] sends the edited value with the unchanged form values` |
| AC-15 | FE | summary spec | `[686-…/AC-15] requests the profile of the selected student only` (re-tag) |
| AC-17 | FE | edit modal spec | `[686-…/AC-17] opens with disabled fields and only Close for a user who cannot manage students, keeping the interventions add control` |
| AC-16 | FE | `students-list.component.spec.ts` | `[686-…/AC-16] opens the edit modal with the profile of the selected student only` |

Existing tests that exercised the removed view mode (`should open read-only as the student profile`, `should unlock the form when Edit is pressed`, `should go back to read-only on cancel…`, the "cannot manage students" block, the 641 AC-2 and AC-13 tests, the consistency AC-18 test) are deleted or moved to the edit modal spec without a tag. Extra tests carry no AC tag. Gates: FE >= 15%, BE >= 25% (AGENTS.md §8.7).

## Risks / Trade-offs

- [The alignment tweak touches the shared `table-with-actions` component] → it is one declaration (`align-items: center` on the card actions); glance at the other tables that use it during the manual check.
- [Re-tagging misses a 641 tag or leaves two tests on one AC] → the §8.6 traceability check in task 3.3 must show exactly 1 per AC per side.
- [Moving the form logic to the helper changes behavior] → the existing creation tests stay green unchanged and the moved edit tests keep their assertions.
- [Existing 643 tests (AC-22, AC-30) use the old action id and modal] → they are updated to `editProfile` and `EditStudentModalComponent` keeping their tags and meaning.

## Open Questions

- None. The final name "Edit Student Profile" needs product confirmation before release (proposal A1); only the texts in `messages.ts` would change.

## Follow-ups

- `StudentProfileViewComponent` keeps its `interventionsMode` input with a `'manage'` branch that no modal uses after this change; remove it in a separate refactor change.
- The main spec `student-profile-modals` keeps the 641 wording until this change is archived.
