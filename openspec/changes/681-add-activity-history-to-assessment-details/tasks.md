# Tasks

## 1. Backend (BE)

- [x] 1.1 Add the building blocks the tests compile against: `AssessmentActivity` and `AssessmentActivityType` in `ERAS-BE/src/Eras.Domain/Entities/AssessmentManagement/`, `IAssessmentActivityRepository`, `AssessmentActivityDto`, `GetAssessmentActivityQuery` in `Queries.cs`; verify with `dotnet build Eras.sln -warnaserror`
- [x] 1.2 Write the pure test of `AssessmentActivityFactory` (no AC tag: comment empty→text, text→different text, clearing, status change, no change) in `ERAS-BE/test/Eras.Application.Tests/Features/Assessments/` and verify it fails
- [x] 1.3 Implement `AssessmentActivityFactory` in `ERAS-BE/src/Eras.Application/Features/RemissionManagement/AssessmentActivityFactory.cs` and verify the test from 1.2 passes
- [x] 1.4 Write the AC test `CreateRemissionCommandHandlerTests.HandleAsync_NewAssessmentWithComments_RecordsOnlyCreatedEventAsync` for (AC-1) in `ERAS-BE/test/Eras.Application.Tests/Features/Assessments/Commands/`, tagged `Change` and `AC` (`681-add-activity-history-to-assessment-details/AC-1`), update the handler's test constructor, and verify it fails for the right reason
- [x] 1.5 Make `CreateRemissionCommandHandler` save and record "Assessment created" in one `ExecuteInTransactionAsync` with `ICurrentUserService` and `IAssessmentActivityRepository` for (AC-1) and verify the test from 1.4 passes
- [x] 1.6 Write the AC test `UpdateRemissionCommandHandlerTests.HandleAsync_CommentAdded_RecordsCommentAddedEventAsync` for (AC-2), tagged, and verify it fails
- [x] 1.7 Write the AC test `HandleAsync_CommentChangedThenCleared_RecordsOnlyTheChangeAsync` for (AC-3), tagged, and verify it fails
- [x] 1.8 Write the AC test `HandleAsync_StatusChanged_RecordsPreviousAndNewStatusAsync` for (AC-4), tagged, and verify it fails
- [x] 1.9 Write the AC test `HandleAsync_NoTrackedChange_RecordsNoEventAsync` for (AC-5), tagged, and verify it fails
- [x] 1.10 Write the AC test `HandleAsync_RejectedStatusTransition_RecordsNoEventAsync` for (AC-6), tagged, and verify it fails or already passes for the right reason
- [x] 1.11 Make `UpdateRemissionCommandHandler` run `UpdateAsync` and the events from the factory (previous values from `existing`) inside `ExecuteInTransactionAsync` for (AC-2, AC-3, AC-4, AC-5, AC-6) and verify the tests from 1.6 to 1.10 pass and the existing update tests still pass
- [x] 1.12 Write the AC tests in `ERAS-BE/test/Eras.Application.Tests/Features/Assessments/Queries/GetAssessmentActivityQueryHandlerTests.cs`: `HandleAsync_UnorderedEvents_ReturnsOldestFirstAsync` (AC-7), `HandleAsync_OtherAssessmentHasEvents_ReturnsOnlyItsOwnAsync` (AC-11), `HandleAsync_UnknownAssessment_ThrowsKeyNotFoundAsync` (AC-12), `HandleAsync_NoEvents_ReturnsEmptyListAsync` (AC-13), one tag each, and verify they fail
- [x] 1.13 Implement `AssessmentActivityToDtoMapper` (register in `ApplicationServiceRegistration`) and `GetAssessmentActivityQueryHandler` for (AC-7, AC-11, AC-12, AC-13) and verify the tests from 1.12 pass
- [x] 1.14 Add `AssessmentActivityConfiguration`, the `DbSet` in `AppDbContext`, `AssessmentActivityRepository` and its line in `PersistenceServiceRegistration` in `ERAS-BE/src/Eras.Infrastructure/Persistence/PostgreSQL/`, and verify `dotnet build Eras.sln -warnaserror` passes
- [x] 1.15 Create the migration `AddAssessmentActivities` with the command in `ERAS-BE/AGENTS.md` §3.2 (never edit an applied migration or the snapshot by hand) and verify the generated file only creates `assessment_activities`, its index and the cascade FK
- [x] 1.16 Write the AC test `AssessmentRepositoryTest.DeleteAssessmentAsync_AssessmentWithEvents_RemovesOnlyItsEventsAsync` for (AC-19) in `ERAS-BE/test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Repositories/`, tagged, and verify it fails
- [x] 1.17 Remove the assessment's events in `AssessmentRepository.DeleteAssessmentAsync` for (AC-19) and verify the test from 1.16 passes
- [x] 1.18 Write the AC tests in `ERAS-BE/test/Eras.Api.Tests/Authorization/AssessmentActivityPolicyTests.cs`: `GetAssessmentActivity_StudentServicesOfficer_IsAuthorizedAsync` (AC-8), `GetAssessmentActivity_Professional_IsAuthorizedAsync` (AC-9), `GetAssessmentActivity_Guest_IsForbiddenAsync` (AC-10), and verify they fail
- [x] 1.19 Add the action `GET {id}/history` with `[Authorize(Policy = ErasPolicies.AnyErasRole)]` and its `ProducesResponseType` entries (200, 403, 404) to `AssessmentsController` for (AC-8, AC-9, AC-10) and verify the tests from 1.18 pass and the action shows in Swagger (reopened: manual validation Round 1 found AC-12 answers 500 instead of 404, see 1.20 and 1.21)
- [x] 1.20 Write the regression test for (AC-12): requesting the history of an unknown assessment id through the Api pipeline (controller and `ExceptionHandlerMiddleware`) must answer 404 Not Found, not 500; verify it fails and reproduces the reported 500. Tag it `681-add-activity-history-to-assessment-details/AC-12` in `ERAS-BE/test/Eras.Api.Tests/` (where status codes are decided, §6.3) and remove the tag from the handler test `HandleAsync_UnknownAssessment_ThrowsKeyNotFoundAsync` so the AC keeps exactly one BE test; update the AC-12 Traceability row
- [x] 1.21 Fix: the unknown-assessment history request answers 404 with no event data (AC-12); find the cause the 1.20 test shows (the handler throws `KeyNotFoundException` and the middleware maps it to 404, so check what is different at runtime), do not add `try/catch` to the controller (§6.2), and verify the 1.20 test and the existing 1.12 and 1.18 tests pass

## 2. Frontend (FE)

- [x] 2.1 Add `AssessmentActivityModel` in `ERAS-FE/src/app/core/models/assessment-activity.model.ts`, `AssessmentService.getActivity(assessmentId)` and `ASSESSMENT_ACTIVITY_MESSAGES` in `core/constants/messages.ts`; verify with `npm run build`
- [x] 2.2 Write the specs `[681-add-activity-history-to-assessment-details/AC-14]` to `AC-18`, one `it()` per AC: (AC-14), (AC-15), (AC-16), (AC-17), (AC-18), in `ERAS-FE/src/app/modules/assessments/components/assessment-detail/assessment-activity-history/assessment-activity-history.component.spec.ts` and verify they fail
- [x] 2.3 Implement the standalone OnPush `assessment-activity-history` component (ts, html, scss) for (AC-14), (AC-15), (AC-16), (AC-17), (AC-18) and verify the specs from 2.2 pass
- [x] 2.4 Write an untagged spec in `assessment-detail-dialog.component.spec.ts` proving the dialog renders the history section for an assessment with an id and not without one, and verify it fails
- [x] 2.5 Embed `<app-assessment-activity-history [assessmentId]="data.id">` guarded by `@if (data.id !== undefined)` at the end of `assessment-detail-dialog.component.html` and add the component to its `imports`, for (AC-14, AC-17), and verify the spec from 2.4 passes

## 3. Verification

- [x] 3.1 BE gates (AGENTS.md §8.7) pass in `ERAS-BE/`: `dotnet build Eras.sln -warnaserror`, `dotnet format Eras.sln --verify-no-changes`, `dotnet test Eras.sln`, coverage >= 25%
- [x] 3.2 FE gates pass in `ERAS-FE/`: `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (>= 15%), `npm run build`
- [x] 3.3 The AC traceability check (AGENTS.md section 8.6) shows exactly 1 test per AC per affected side, and `openspec validate 681-add-activity-history-to-assessment-details --strict` passes

## Traceability
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | Creating an assessment records "Assessment created" | BE | test/Eras.Application.Tests/Features/Assessments/Commands/CreateRemissionCommandHandlerTests.cs › HandleAsync_NewAssessmentWithComments_RecordsOnlyCreatedEventAsync |
| AC-2 | Adding a comment records "Comment added" | BE | test/Eras.Application.Tests/Features/Assessments/Commands/UpdateRemissionCommandHandlerTests.cs › HandleAsync_CommentAdded_RecordsCommentAddedEventAsync |
| AC-3 | Changing a comment records an event and clearing it does not | BE | test/Eras.Application.Tests/Features/Assessments/Commands/UpdateRemissionCommandHandlerTests.cs › HandleAsync_CommentChangedThenCleared_RecordsOnlyTheChangeAsync |
| AC-4 | Changing the status records the previous and the new value | BE | test/Eras.Application.Tests/Features/Assessments/Commands/UpdateRemissionCommandHandlerTests.cs › HandleAsync_StatusChanged_RecordsPreviousAndNewStatusAsync |
| AC-5 | Saving without a tracked change records no event | BE | test/Eras.Application.Tests/Features/Assessments/Commands/UpdateRemissionCommandHandlerTests.cs › HandleAsync_NoTrackedChange_RecordsNoEventAsync |
| AC-6 | A rejected status change records no event | BE | test/Eras.Application.Tests/Features/Assessments/Commands/UpdateRemissionCommandHandlerTests.cs › HandleAsync_RejectedStatusTransition_RecordsNoEventAsync |
| AC-7 | Events are listed oldest first | BE | test/Eras.Application.Tests/Features/Assessments/Queries/GetAssessmentActivityQueryHandlerTests.cs › HandleAsync_UnorderedEvents_ReturnsOldestFirstAsync |
| AC-8 | Student Services Officer can read the history | BE | test/Eras.Api.Tests/Authorization/AssessmentActivityPolicyTests.cs › GetAssessmentActivity_StudentServicesOfficer_IsAuthorizedAsync |
| AC-9 | Professional can read the history | BE | test/Eras.Api.Tests/Authorization/AssessmentActivityPolicyTests.cs › GetAssessmentActivity_Professional_IsAuthorizedAsync |
| AC-10 | Guest cannot read the history | BE | test/Eras.Api.Tests/Authorization/AssessmentActivityPolicyTests.cs › GetAssessmentActivity_Guest_IsForbiddenAsync |
| AC-11 | Events of one assessment never appear for another | BE | test/Eras.Application.Tests/Features/Assessments/Queries/GetAssessmentActivityQueryHandlerTests.cs › HandleAsync_OtherAssessmentHasEvents_ReturnsOnlyItsOwnAsync |
| AC-12 | An unknown assessment is not found | BE | test/Eras.Api.Tests/Controllers/AssessmentActivityNotFoundTests.cs › GetAssessmentActivity_UnknownAssessment_RespondsNotFoundAsync |
| AC-13 | An assessment without events returns an empty list | BE | test/Eras.Application.Tests/Features/Assessments/Queries/GetAssessmentActivityQueryHandlerTests.cs › HandleAsync_NoEvents_ReturnsEmptyListAsync |
| AC-14 | The section lists the events with description, time and user | FE | src/app/modules/assessments/components/assessment-detail/assessment-activity-history/assessment-activity-history.component.spec.ts › [681-add-activity-history-to-assessment-details/AC-14] lists description, YYYY-MM-DD HH:mm time and user name in the order received |
| AC-15 | The section is read only | FE | src/app/modules/assessments/components/assessment-detail/assessment-activity-history/assessment-activity-history.component.spec.ts › [681-add-activity-history-to-assessment-details/AC-15] is read only, no edit or delete action |
| AC-16 | An assessment with only its creation shows that single entry | FE | src/app/modules/assessments/components/assessment-detail/assessment-activity-history/assessment-activity-history.component.spec.ts › [681-add-activity-history-to-assessment-details/AC-16] shows only the creation entry without empty rows |
| AC-17 | An assessment with no events shows a message | FE | src/app/modules/assessments/components/assessment-detail/assessment-activity-history/assessment-activity-history.component.spec.ts › [681-add-activity-history-to-assessment-details/AC-17] shows "No activity recorded yet." when there are no events |
| AC-18 | Event text is displayed as plain text | FE | src/app/modules/assessments/components/assessment-detail/assessment-activity-history/assessment-activity-history.component.spec.ts › [681-add-activity-history-to-assessment-details/AC-18] shows the user name as plain text |
| AC-19 | Deleting an assessment removes its events | BE | test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Repositories/AssessmentRepositoryTest.cs › DeleteAssessmentAsync_AssessmentWithEvents_RemovesOnlyItsEventsAsync |
