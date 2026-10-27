# Design

## Context

Today an assessment (`remissions` table) stores one professional: `Assessment.AssignedProfessional` (a Keycloak sub, column `assigned_professional`). It drives which assessments a Professional sees (`AssessmentRepository.GetByAssignedProfessionalAsync`, `CountActiveAssessmentsForUserAsync`). An intervention stores `Intervention.Professional`, a free-text display name (not a sub); the FE edit modal sends `data.professional.label` and ignores the form control (`edit-intervention-modal.component.ts:500`, `:597`) and the field is disabled with one option.

The API side of reassigning already works for every ERAS role: `PUT api/v1/assessments/{assessmentId}/interventions/{interventionId}` and `.../replace-type` use `ErasPolicies.AnyErasRole`. The assessment `PUT api/v1/assessments/{id}` is `AdminOrOfficer`. The spec turns the single professional into a list (AC-10 to AC-19), so this change crosses BE and FE, adds a migration and changes the API contract.

References: [proposal.md](proposal.md), [spec](specs/intervention-management/spec.md).

## Goals / Non-Goals

**Goals:**
- An assessment holds a list of professionals, carried over from the single value (AC-14).
- Reassigning an intervention sets its professional and adds that person to the assessment list without duplicates, leaving everything else unchanged (AC-1 to AC-3, AC-7, AC-8, AC-10 to AC-12).
- Every role with an ERAS role can do it, Guest cannot (AC-1 to AC-4); the edit modal offers a selectable, required professional (AC-5, AC-6).
- Role-scoped queries use the list (AC-13); the assessment list shows all of them (AC-15).
- The assessment form edits the full list; a professional with interventions in that assessment cannot be removed (AC-16 to AC-19).

**Non-Goals:**
- Making the professional of a new intervention selectable (the create modals keep their disabled field).
- Converting `Intervention.Professional` from a display name to a sub.
- Any audit log (separate ticket).

## Decisions

### D1. Store the list in a `text[]` column
**Choice:** `remissions.assigned_professionals text[] NOT NULL DEFAULT '{}'`, mapped with `HasColumnType("text[]")` exactly like `StudentIds` (`integer[]`) in `AssessmentConfiguration.cs`. Queries use `.Contains(sub)`. No persistence twin or join table is needed because `Assessment` is mapped directly.
**Alternative:** a join table `assessment_professionals` (pattern of `StudentCohortJoin`) → more files, a repository rewrite and cascade handling for a list of short strings with no extra attributes.
**ADR:** ADR-0002

### D2. The reassign request carries the professional's sub
**Choice:** add optional `string? ProfessionalSub` to `UpdateInterventionDto`. `Professional` (display name) keeps being stored on the intervention. The update and replace handlers add `ProfessionalSub` to the assessment list when present, inside the existing transaction, through a new repository method. This runs for every ERAS role, because the intervention endpoints allow `AnyErasRole` (assumption A5).
**Alternative:** resolve the sub from the name in the BE → names are not unique and not guaranteed to match.

### D3. "Has interventions" is decided by display name
**Choice:** to reject a removal (AC-18) the update-assessment handler resolves each removed sub with `IErasUsersRepository.GetErasUserBySubAsync`, builds the display name with one shared formatter (`first last` trimmed, else email, the same rule as the FE `mapProfessionalsToLookups`), and checks whether any intervention of the assessment has `Professional` equal to it. It throws `OperationCanceledException` with a friendly message, which `AssessmentsController.Update` already maps to 409 `{ message }`.
**Alternative:** match `CreatedBy == sub` as well → that is the creator, not the assigned professional, so it would block removals the spec allows.

### D4. Assessment form uses a multi-select and a 409 branch
**Choice:** the professional field in `edit-assessment-modal` and `new-assessment-modal` becomes `searchableSelect` + `multipleSelect: true` (the Students pattern). The edit modal gets a 409 branch that shows `error.error.message`.
**Alternative:** keep `creatableSelect` → single value only.

### D5. At least one professional is required only in the frontend
**Choice:** the create and edit assessment forms keep the professional field required. The backend validator accepts an empty `AssignedProfessionals` list (A8), because the migration leaves assessments that had no professional with `{}` and they must stay editable.
**Alternative:** require a non-empty list in the backend too → every edit of a legacy assessment without a professional would fail until someone assigns one.

## Changes by layer

### Backend (`ERAS-BE/`)

| Layer | Change | Files | ACs |
|---|---|---|---|
| Domain | `AssignedProfessional` → `string[] AssignedProfessionals`; validator: each item not blank and ≤ 200 chars, no duplicates; the list itself may be empty (A8) | `src/Eras.Domain/Entities/AssessmentManagement/Assessment.cs`, `Validators/AssessementValidator.cs` | AC-14, AC-16 |
| Application | DTO `AssignedProfessionals`; `UpdateInterventionDto.ProfessionalSub`; mappers copy both; update and replace handlers add the sub to the assessment; update-assessment handler rejects removals (D3); shared display-name formatter (new file) | `DTOs/AssessmentManagement/AssessmentDto.cs`, `UpdateInterventionDto.cs`, `Mappers/AssessmentManagement/AssessmentMapper.cs`, `AssessmentToDtoMapper.cs`, `UpdateInterventionMapper.cs`, `Features/RemissionManagement/Handlers/UpdateInterventionCommandHandler.cs`, `ReplaceInterventionCommandHandler.cs`, `UpdateRemissionCommandHandler.cs` | AC-1 to AC-3, AC-7, AC-10 to AC-12, AC-16 to AC-18 |
| Application contract | `IAssessmentRepository.AddAssignedProfessionalAsync(int AssessmentId, string Sub)` (no-op if already present); `GetByAssignedProfessionalAsync` keeps its signature | `Contracts/Persistence/AssessmentManagement/IAssessmentRepository.cs` | AC-10, AC-11, AC-13 |
| Infrastructure | EF mapping `assigned_professionals`; repository filters with `.Contains(sub)` in `GetByAssignedProfessionalAsync` and `CountActiveAssessmentsForUserAsync`; new method; migration | `Persistence/PostgreSQL/Configurations/AssessmentManagement/AssessmentConfiguration.cs`, `Repositories/AssessmentManagement/AssessmentRepository.cs`, `Migrations/<timestamp>_AssessmentAssignedProfessionalsList.cs` (new) | AC-10, AC-13, AC-14 |
| Api | No controller change: intervention endpoints stay `AnyErasRole`, assessment update stays `AdminOrOfficer` | `Controllers/AssessmentManagement/AssessmentsController.cs` (unchanged) | AC-4 |

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Model / service | `assignedProfessional?: string \| null` → `assignedProfessionals: string[]`; `UpdateInterventionPayload.professionalSub?: string` | `src/app/core/models/assessment.model.ts`; `EditAssessmentModel` in `modules/assessments/models/assessments.interfaces.ts` | AC-1 to AC-3, AC-16 |
| Permissions | `PermissionContext.assignedProfessional` becomes a list; checks use `includes` | `core/services/permissions/permission.policies.ts` (+ spec) | AC-13 (consistency) |
| Intervention edit modal | enabled select from `professionals: Lookup[]` (users with `ERASRoles.PROFESSIONAL`), current professional preselected by label, required; payload sends the selected label as `professional` and its value as `professionalSub` | `modules/assessments/components/interventions/edit-intervention-modal/edit-intervention-modal.component.ts`; dialog data built in `interventions/interventions.component.ts` (`openEditModal`) | AC-1 to AC-3, AC-5, AC-6 |
| Assessment list | `professionalDisplay` joins every name | `modules/assessments/components/assessment-list/assessment-list.component.ts` | AC-15 |
| Assessment forms | multi-select (D4); edit modal 409 branch; message text in a new constant | `edit-assessment-modal`, `new-assessment-modal`, `core/constants/messages.ts` | AC-16, AC-19 |
| Create-intervention modals | pass the first professional of the list unchanged in behavior | `assessment-list.component.ts` (`onCreateIntervention`), `interventions.component.ts` (`openCreateModal`) | — |

## API contract

| Endpoint | Policy | Request DTO | Response DTO | Status codes |
|---|---|---|---|---|
| `PUT api/v1/assessments/{assessmentId}/interventions/{interventionId}` | `AnyErasRole` (unchanged) | `UpdateInterventionRequestDto` with `UpdateInterventionDto` + `ProfessionalSub?: string` | `UpdateInterventionDto` | 200, 404, 409, 403 |
| `PUT api/v1/assessments/{assessmentId}/interventions/{interventionId}/replace-type` | `AnyErasRole` (unchanged) | same | same | 200, 404, 409, 403 |
| `PUT api/v1/assessments/{id}` | `AdminOrOfficer` (unchanged) | `AssessmentDto` with `AssignedProfessionals: string[]` | `AssessmentDto` | 200, 400, 409, 403 |
| `GET api/v1/assessments/...` (all reads) | unchanged | — | `AssessmentDto` with `AssignedProfessionals: string[]` | unchanged |

- **BREAKING:** `AssignedProfessional` (string) is removed from `AssessmentDto`; the FE is its only consumer and moves in this change.
- **FE model:** `assessment.model.ts` mirrors the DTO (`assignedProfessionals: string[]`).
- **FE services:** `assessement.service.ts` and `intervention.service.ts` need no new method.
- **Ownership / scope rules:** none added; any ERAS role may reassign (A3). The removal rule (D3) lives in the update-assessment handler.

## Data and migration

New migration `<timestamp>_AssessmentAssignedProfessionalsList` created with `dotnet ef migrations add` (never edit the snapshot by hand), then its `Up` completed by hand, following `20260923160703_UseSubInsteadOfNameRefInAssessments.cs`:
1. add `assigned_professionals text[] NOT NULL DEFAULT '{}'`;
2. `UPDATE remissions SET assigned_professionals = ARRAY[assigned_professional] WHERE assigned_professional IS NOT NULL AND assigned_professional <> ''`;
3. drop `assigned_professional`.

`Down` re-adds the column with the first element of the array and drops the new one. No SQL view references these columns.

## Test strategy

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | BE | Api: `test/Eras.Api.Tests/Authorization/` | `InterventionProfessionalPolicyTests.cs` › `UpdateIntervention_ErasAdministrator_IsAuthorized` |
| AC-1 | FE | `.../edit-intervention-modal.component.spec.ts` | `[635-allow-reassign-intervention-professional/AC-1] administrator saves the newly selected professional and the list refreshes` |
| AC-2 | BE | same file | `UpdateIntervention_StudentServicesOfficer_IsAuthorized` |
| AC-2 | FE | same spec | `[635-allow-reassign-intervention-professional/AC-2] officer saves the newly selected professional and the list refreshes` |
| AC-3 | BE | same file | `UpdateIntervention_ErasProfessional_IsAuthorized` |
| AC-3 | FE | same spec | `[635-allow-reassign-intervention-professional/AC-3] professional saves the newly selected professional and the list refreshes` |
| AC-4 | BE | same file | `UpdateIntervention_Guest_IsForbidden` |
| AC-5 | FE | edit-intervention-modal spec | `[635-.../AC-5] enables the professional field, lists the assignable professionals and preselects the current one` |
| AC-6 | FE | edit-intervention-modal spec | `[635-.../AC-6] does not submit when the professional is cleared` |
| AC-7 | BE | Application: `test/Eras.Application.Tests/Features/Assessments/Commands/` | `UpdateInterventionCommandHandlerTests.cs` › `HandleAsync_ChangeOnlyProfessional_KeepsOtherFieldsAsync` |
| AC-8 | BE | same folder | `UpdateRemissionCommandHandlerTests.cs` › `HandleAsync_NoProfessionalChange_LeavesInterventionProfessionalsAsync` |
| AC-10 | BE | same folder | `UpdateInterventionCommandHandlerTests.cs` › `HandleAsync_NewProfessional_IsAddedToAssessmentAsync` |
| AC-11 | BE | same folder | `UpdateInterventionCommandHandlerTests.cs` › `HandleAsync_ProfessionalAlreadyInAssessment_IsNotDuplicatedAsync` |
| AC-12 | BE | same folder | `UpdateInterventionCommandHandlerTests.cs` › `HandleAsync_ReassignOneIntervention_LeavesOthersAndAssessmentUnchangedAsync` |
| AC-13 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Repositories/` | `AssessmentRepositoryTest.cs` › `GetByAssignedProfessionalAsync_ProfessionalInList_ReturnsAssessmentForEveryMemberAsync` |
| AC-14 | BE | Infrastructure, same file | `GetByAssignedProfessionalAsync_SingleLegacyProfessional_ReturnsAssessmentWithThatOneProfessionalAsync` |
| AC-15 | FE | `.../assessment-list.component.spec.ts` | `[635-.../AC-15] shows every professional of the assessment in the row` |
| AC-16 | BE | Application: `UpdateRemissionCommandHandlerTests.cs` | `HandleAsync_ProfessionalAdded_PersistsFullListAsync` |
| AC-16 | FE | `.../edit-assessment-modal.component.spec.ts` | `[635-.../AC-16] submits the full list of selected professionals` |
| AC-17 | BE | same BE file | `HandleAsync_RemoveProfessionalWithoutInterventions_SucceedsAsync` |
| AC-18 | BE | same BE file | `HandleAsync_RemoveProfessionalWithInterventions_Throws409AndKeepsListAsync` |
| AC-19 | FE | edit-assessment-modal spec | `[635-.../AC-19] shows the 409 message and keeps the form open` |

The three role-specific FE tests (AC-1 to AC-3) run the same flow with the session role stubbed to each role: the modal has no role gate, so the point is that none is introduced. Extra untagged tests: replace-type handler adds the sub, formatter rules, validator (empty list, max length, duplicates), repository `AddAssignedProfessionalAsync`.

Coverage gates: BE >= 25%, FE >= 15%.

## Risks / Trade-offs

- [Display names differ between FE and BE, so D3 misses a match and wrongly allows a removal] → one shared formatter with a test, and the BE rule mirrors the FE lookup (`first last` trimmed, else email).
- [Old interventions hold a sub or a stale name in `Professional`] → D3 compares names only; interventions that never matched stay unmatched, as with today's by-professional query.
- [Breaking DTO rename] → FE and BE ship together in this change; no other consumer exists.
- [The migration cannot be exercised by the InMemory tests behind AC-14] → AC-14 is tested at the repository; the SQL is checked manually against a local database during validation.
- [Blast radius of `PermissionContext` change] → only `permission.policies.ts` and its specs use it.

## Migration Plan

Deploy BE with the migration, then FE in the same release. Rollback: run `Down` (keeps the first professional of each assessment).

## Follow-ups

- Let the create-intervention modals choose the professional (today they stay disabled and show the first professional of the assessment).
- Store an intervention's professional as a sub instead of a display name; this would remove the name matching in D3.
- Map `KeyNotFoundException` to 404 in `AssessmentsController.Update`.
