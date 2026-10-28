# Tasks

## 1. Backend (BE)

- [x] 1.1 Write the test `GetByAssignedProfessionalAsync_SingleLegacyProfessional_ReturnsAssessmentWithThatOneProfessionalAsync` for (AC-14) in `ERAS-BE/test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Repositories/AssessmentRepositoryTest.cs`, tagged `Change` and `AC`, and verify it fails
- [x] 1.2 Replace `AssignedProfessional` with `string[] AssignedProfessionals` in `Assessment.cs`, `AssessementValidator.cs` (not empty, each item max 200), `AssessmentDto.cs`, both assessment mappers, `AssessmentConfiguration.cs` (`text[]`) and the repository filters (`.Contains(sub)`) for (AC-14), fix the tests that referenced the old property, and verify the test from 1.1 passes
- [x] 1.3 Create the migration with `dotnet ef migrations add AssessmentAssignedProfessionalsList` and complete its `Up`/`Down` with the backfill described in design.md; verify it applies and rolls back on a local PostgreSQL and that an existing single value ends up as a one-item list
- [x] 1.4 Write the test `GetByAssignedProfessionalAsync_ProfessionalInList_ReturnsAssessmentForEveryMemberAsync` for (AC-13) in `AssessmentRepositoryTest.cs`, tagged, and verify it fails or is covered by 1.2 changes (record which)
- [x] 1.5 Make `GetByAssignedProfessionalAsync` and `CountActiveAssessmentsForUserAsync` match any professional in the list for (AC-13) and verify the test from 1.4 passes
- [x] 1.6 Write the test `HandleAsync_NewProfessional_IsAddedToAssessmentAsync` for (AC-10) in `test/Eras.Application.Tests/Features/Assessments/Commands/UpdateInterventionCommandHandlerTests.cs`, tagged, and verify it fails
- [x] 1.7 Add `ProfessionalSub` to `UpdateInterventionDto` and `UpdateInterventionMapper`, add `IAssessmentRepository.AddAssignedProfessionalAsync` and its implementation (no-op when present), and call it from `UpdateInterventionCommandHandler` and `ReplaceInterventionCommandHandler` inside the transaction for (AC-10); verify the test from 1.6 passes and add an untagged replace-type test and an untagged repository test
- [x] 1.8 Write the test `HandleAsync_ProfessionalAlreadyInAssessment_IsNotDuplicatedAsync` for (AC-11) in `UpdateInterventionCommandHandlerTests.cs`, tagged, and verify it fails or already passes because of 1.7 (record which)
- [x] 1.9 Make the no-duplicate rule explicit in the repository method and handler for (AC-11) and verify the test from 1.8 passes
- [x] 1.10 Write the test `HandleAsync_ReassignOneIntervention_LeavesOthersAndAssessmentUnchangedAsync` for (AC-12) in `UpdateInterventionCommandHandlerTests.cs`, tagged, and verify it fails or already passes (record which)
- [x] 1.11 Ensure only the target intervention and the professional list change for (AC-12) and verify the test from 1.10 passes
- [x] 1.12 Write the test `HandleAsync_ChangeOnlyProfessional_KeepsOtherFieldsAsync` for (AC-7) in `UpdateInterventionCommandHandlerTests.cs`, tagged, and verify it fails or already passes (record which)
- [x] 1.13 Fix any field the handler or repository overwrites when only the professional changes for (AC-7) and verify the test from 1.12 passes
- [x] 1.14 Write the test `HandleAsync_NoProfessionalChange_LeavesInterventionProfessionalsAsync` for (AC-8) in `UpdateRemissionCommandHandlerTests.cs`, tagged, and verify it fails or already passes (record which)
- [x] 1.15 Ensure the update-assessment handler never touches intervention professionals for (AC-8) and verify the test from 1.14 passes
- [x] 1.16 Write the test `HandleAsync_ProfessionalAdded_PersistsFullListAsync` for (AC-16) in `UpdateRemissionCommandHandlerTests.cs`, tagged, and verify it fails
- [x] 1.17 Persist the full submitted list in `UpdateRemissionCommandHandler` for (AC-16) and verify the test from 1.16 passes
- [x] 1.18 Write the test `HandleAsync_RemoveProfessionalWithoutInterventions_SucceedsAsync` for (AC-17) in `UpdateRemissionCommandHandlerTests.cs`, tagged, and verify it fails or already passes (record which)
- [x] 1.19 Write the test `HandleAsync_RemoveProfessionalWithInterventions_Throws409AndKeepsListAsync` for (AC-18) in `UpdateRemissionCommandHandlerTests.cs`, tagged, and verify it fails
- [x] 1.20 Add the shared display-name formatter (new file in `src/Eras.Application/`) with an untagged unit test, and add the removal check from D3 to `UpdateRemissionCommandHandler` (throws `OperationCanceledException` naming the professional) for (AC-17) and (AC-18); verify the tests from 1.18 and 1.19 pass
- [x] 1.21 Write the policy tests `UpdateIntervention_ErasAdministrator_IsAuthorized` (AC-1), `UpdateIntervention_StudentServicesOfficer_IsAuthorized` (AC-2), `UpdateIntervention_ErasProfessional_IsAuthorized` (AC-3) and `UpdateIntervention_Guest_IsForbidden` (AC-4) in `test/Eras.Api.Tests/Authorization/InterventionProfessionalPolicyTests.cs` (new), one tag each, reusing the helpers of `ErasPoliciesTests.cs`, and verify they fail only if the action's policy is not `AnyErasRole`
- [x] 1.22 If any test from 1.21 fails, fix the `[Authorize(Policy = ...)]` of `UpdateInterventionAsync` for (AC-1 to AC-4); otherwise leave the controller unchanged; verify all four pass
- [x] 1.23 Write the validator tests (untagged) for the new list rules in `test/Eras.Domain.Tests/Entities/Validators/AssessmentValidatorTest.cs` and verify they pass
- [x] 1.24 Write the regression tests (untagged, the tagged test of (AC-18) stays unchanged) in `ERAS-BE/test/Eras.Application.Tests/Features/Assessments/Commands/UpdateRemissionCommandHandlerTests.cs`: removing a professional is rejected with 409 when an intervention stores that professional as the sub, the email or the display name with different case or spacing, and also when the user cannot be resolved but an intervention stores the sub; verify they fail
- [x] 1.25 Fix the removal check in `UpdateRemissionCommandHandler` for (AC-18) so it matches the removed professional by sub, email and display name (trimmed, case-insensitive) and no longer skips the check when the user is not found; verify the tests from 1.24 and the tagged AC-18 test pass

## 2. Frontend (FE)

- [x] 2.1 Rename `assignedProfessional` to `assignedProfessionals: string[]` in `core/models/assessment.model.ts`, `EditAssessmentModel`, `permission.policies.ts` (use `includes`) and every non-spec user listed in design.md, add `professionalSub` to `UpdateInterventionPayload`, update the existing specs, and verify `npm run build` compiles
- [x] 2.2 Write the spec `[635-allow-reassign-intervention-professional/AC-15] shows every professional of the assessment in the row` for (AC-15) in `ERAS-FE/src/app/modules/assessments/components/assessment-list/assessment-list.component.spec.ts` and verify it fails
- [x] 2.3 Join all professional names in `professionalDisplay` of `assessment-list.component.ts` for (AC-15) and verify the spec from 2.2 passes
- [x] 2.4 Write the specs `[.../AC-5]` and `[.../AC-6]` for (AC-5) and (AC-6) in `edit-intervention-modal.component.spec.ts` and verify they fail
- [x] 2.5 Pass `professionals: Lookup[]` (users with `ERASRoles.PROFESSIONAL`) from `interventions.component.ts` `openEditModal`, enable the select, preselect the current professional and keep it required in `edit-intervention-modal.component.ts` for (AC-5) and (AC-6); verify the specs from 2.4 pass and the old test at spec line ~355 is updated
- [x] 2.6 Write the specs `[.../AC-1]`, `[.../AC-2]` and `[.../AC-3]` in `edit-intervention-modal.component.spec.ts`, one per role with the session role stubbed, and verify they fail
- [x] 2.7 Send the selected label as `professional` and its value as `professionalSub` in `submitIntervention` and `buildPayload`, and close with `true` so the list reloads, for (AC-1 to AC-3); verify the specs from 2.6 pass
- [x] 2.8 Write the specs `[.../AC-16]` for (AC-16) and `[.../AC-19]` for (AC-19) in `edit-assessment-modal.component.spec.ts` and verify they fail
- [x] 2.9 Switch the professional field of `edit-assessment-modal.component.ts` and `new-assessment-modal.component.ts` to `searchableSelect` with `multipleSelect`, submit the array, add the 409 branch showing `error.error.message` (text in `core/constants/messages.ts`) for (AC-16) and (AC-19); verify the specs from 2.8 pass
- [x] 2.10 Pass the first professional of the list in `onCreateIntervention` and `openCreateModal`, and update the existing specs of those components; verify `npm test` for the assessments folder passes

## 3. Verification

- [x] 3.1 BE gates (AGENTS.md section 5.6) pass in `ERAS-BE/`: `dotnet build Eras.sln -warnaserror`, `dotnet format Eras.sln --verify-no-changes`, `dotnet test Eras.sln`, coverage >= 25%
- [x] 3.2 FE gates (AGENTS.md section 5.6) pass in `ERAS-FE/`: `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (>= 15%), `npm run build`
- [x] 3.3 The AC traceability check (AGENTS.md section 5.4) shows exactly 1 test per AC per affected side, and `openspec validate 635-allow-reassign-intervention-professional --strict` passes

## Traceability
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | Administrator reassigns the professional | BE | test/Eras.Api.Tests/Authorization/InterventionProfessionalPolicyTests.cs › UpdateIntervention_ErasAdministrator_IsAuthorized |
| AC-1 | Administrator reassigns the professional | FE | src/app/modules/assessments/components/interventions/edit-intervention-modal/edit-intervention-modal.component.spec.ts › [635-allow-reassign-intervention-professional/AC-1] administrator saves the newly selected professional and the list refreshes |
| AC-2 | Student Services Officer reassigns the professional | BE | test/Eras.Api.Tests/Authorization/InterventionProfessionalPolicyTests.cs › UpdateIntervention_StudentServicesOfficer_IsAuthorized |
| AC-2 | Student Services Officer reassigns the professional | FE | src/app/modules/assessments/components/interventions/edit-intervention-modal/edit-intervention-modal.component.spec.ts › [635-allow-reassign-intervention-professional/AC-2] officer saves the newly selected professional and the list refreshes |
| AC-3 | Professional reassigns the professional | BE | test/Eras.Api.Tests/Authorization/InterventionProfessionalPolicyTests.cs › UpdateIntervention_ErasProfessional_IsAuthorized |
| AC-3 | Professional reassigns the professional | FE | src/app/modules/assessments/components/interventions/edit-intervention-modal/edit-intervention-modal.component.spec.ts › [635-allow-reassign-intervention-professional/AC-3] professional saves the newly selected professional and the list refreshes |
| AC-4 | Guest cannot reassign the professional through the API | BE | test/Eras.Api.Tests/Authorization/InterventionProfessionalPolicyTests.cs › UpdateIntervention_Guest_IsForbidden |
| AC-5 | Edit modal offers a selectable professional | FE | src/app/modules/assessments/components/interventions/edit-intervention-modal/edit-intervention-modal.component.spec.ts › [635-allow-reassign-intervention-professional/AC-5] enables the professional field, lists the assignable professionals and preselects the current one |
| AC-6 | Professional is required | FE | src/app/modules/assessments/components/interventions/edit-intervention-modal/edit-intervention-modal.component.spec.ts › [635-allow-reassign-intervention-professional/AC-6] does not submit when the professional is cleared |
| AC-7 | Reassigning does not alter other fields | BE | test/Eras.Application.Tests/Features/Assessments/Commands/UpdateInterventionCommandHandlerTests.cs › HandleAsync_ChangeOnlyProfessional_KeepsOtherFieldsAsync |
| AC-8 | Existing interventions are not affected | BE | test/Eras.Application.Tests/Features/Assessments/Commands/UpdateRemissionCommandHandlerTests.cs › HandleAsync_NoProfessionalChange_LeavesInterventionProfessionalsAsync |
| AC-10 | New professional is added to the assessment | BE | test/Eras.Application.Tests/Features/Assessments/Commands/UpdateInterventionCommandHandlerTests.cs › HandleAsync_NewProfessional_IsAddedToAssessmentAsync |
| AC-11 | A professional already in the assessment is not duplicated | BE | test/Eras.Application.Tests/Features/Assessments/Commands/UpdateInterventionCommandHandlerTests.cs › HandleAsync_ProfessionalAlreadyInAssessment_IsNotDuplicatedAsync |
| AC-12 | Other interventions and the assessment keep their data | BE | test/Eras.Application.Tests/Features/Assessments/Commands/UpdateInterventionCommandHandlerTests.cs › HandleAsync_ReassignOneIntervention_LeavesOthersAndAssessmentUnchangedAsync |
| AC-13 | The added professional can see the assessment | BE | test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Repositories/AssessmentRepositoryTest.cs › GetByAssignedProfessionalAsync_ProfessionalInList_ReturnsAssessmentForEveryMemberAsync |
| AC-14 | Existing assessments keep their professional | BE | test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Repositories/AssessmentRepositoryTest.cs › GetByAssignedProfessionalAsync_SingleLegacyProfessional_ReturnsAssessmentWithThatOneProfessionalAsync |
| AC-15 | The assessment list shows every professional | FE | src/app/modules/assessments/components/assessment-list/assessment-list.component.spec.ts › [635-allow-reassign-intervention-professional/AC-15] shows every professional of the assessment in the row |
| AC-16 | Edit the full list of professionals of an assessment | BE | test/Eras.Application.Tests/Features/Assessments/Commands/UpdateRemissionCommandHandlerTests.cs › HandleAsync_ProfessionalAdded_PersistsFullListAsync |
| AC-16 | Edit the full list of professionals of an assessment | FE | src/app/modules/assessments/components/edit-assessment-modal/edit-assessment-modal.component.spec.ts › [635-allow-reassign-intervention-professional/AC-16] submits the full list of selected professionals |
| AC-17 | Remove a professional who has no interventions in the assessment | BE | test/Eras.Application.Tests/Features/Assessments/Commands/UpdateRemissionCommandHandlerTests.cs › HandleAsync_RemoveProfessionalWithoutInterventions_SucceedsAsync |
| AC-18 | Cannot remove a professional who has interventions in the assessment | BE | test/Eras.Application.Tests/Features/Assessments/Commands/UpdateRemissionCommandHandlerTests.cs › HandleAsync_RemoveProfessionalWithInterventions_Throws409AndKeepsListAsync |
| AC-19 | The form shows why a professional cannot be removed | FE | src/app/modules/assessments/components/edit-assessment-modal/edit-assessment-modal.component.spec.ts › [635-allow-reassign-intervention-professional/AC-19] shows the 409 message and keeps the form open |
