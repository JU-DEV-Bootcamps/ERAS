# Design

## Context

See `proposal.md` (Why) and `specs/assessment-management/spec.md` (AC-1..AC-19). Change 680 already built the same feature for interventions, so this plan mirrors it and reuses its pieces.

- Assessments are `Assessment` entities (table `remissions`) persisted through `IAssessmentRepository` (`ERAS-BE/src/Eras.Application/Contracts/Persistence/AssessmentManagement/IAssessmentRepository.cs`, implementation `.../Repositories/AssessmentManagement/AssessmentRepository.cs`). `AddAsync` and `UpdateAsync` come from `BaseRepository` and each saves on its own.
- `CreateRemissionCommandHandler` only maps, validates and calls `AddAsync`. `UpdateRemissionCommandHandler` already reads `existing` (no tracking) before it validates the status transition and calls `UpdateAsync`, so the previous status and comments are available; a rejected transition throws before the save.
- `DeleteAssessmentCommandHandler` calls `AssessmentRepository.DeleteAssessmentAsync`, which removes the interventions explicitly and then the assessment (only a `Remitted` one, existing rule).
- Reusable from 680: `ActivityActor.From(ICurrentUserService)` and the pattern of `InterventionActivityFactory` (`Features/RemissionManagement/InterventionActivityFactory.cs`), `IUnitOfWork.ExecuteInTransactionAsync`, the `IInterventionActivityRepository` / `InterventionActivityRepository` / `InterventionActivityConfiguration` shape, `InterventionActivityDto`, `GetInterventionActivityQueryHandler`.
- FE: the details are `assessment-detail-dialog.component` (`@Input data: AssessmentRowViewModel`, `data.id?: number`), a sibling of the intervention panel that already embeds `intervention-activity-history` (`modules/assessments/components/interventions/interventions-detail/intervention-activity-history/`). `AssessmentService` extends `BaseApiService` with resource `assessments`.
- Authorization precedent: `GET api/v1/assessments/{id}` uses `ErasPolicies.AnyErasRole` and has no per-professional filter (A8). No Accepted ADR in `openspec/adr/SUMMARY.md` constrains this change (ADR-0005 limits students, not assessments' own data).

## Goals / Non-Goals

**Goals:**
- Record events for create, comment and status change in the same transaction as the save (AC-1..AC-6).
- Read endpoint, oldest first, role-protected, scoped to one assessment (AC-7..AC-13).
- Events removed with the assessment (AC-19).
- Read-only FE section in the assessment details (AC-14..AC-18).

**Non-Goals:**
- No change to the interventions history, to `UpsertInterventionsCommandHandler` or to any other assessment field.
- No generalisation of `InterventionActivity` into a shared event table (see D1).

## Decisions

### D1. A separate table and entity for assessment events
**Choice:** new entity `AssessmentActivity` (`Id`, `AssessmentId`, `Type` = `Created | CommentAdded | StatusChanged`, `PreviousStatus?`, `NewStatus?` as `AssessmentStatus`, `OccurredAtUtc`, `ActorSub`, `ActorName`), enum `AssessmentActivityType`, table `assessment_activities`, FK to `remissions` with cascade delete, index on `assessment_id`. The comment text is never stored (AC-2). Structured data, text built when reading, like D1 of change 680.
**Alternative:** one polymorphic `activities` table shared with interventions → would rewrite the table and code of change 680 and its migration; out of scope, rejected.

### D2. Record events in the handlers, in one transaction
**Choice:** `AssessmentActivityFactory` (pure, new, beside `InterventionActivityFactory`) returns the events of a save with the same rule as 680 (comment: empty→text or text→different text; status: any change). `CreateRemissionCommandHandler` wraps `AddAsync` and the "Assessment created" event in `ExecuteInTransactionAsync`; initial comments produce no "Comment added" (AC-1). `UpdateRemissionCommandHandler` wraps `UpdateAsync` and the events in the transaction, after the existing validations, using `existing.Status` and `existing.Comments` as previous values (AC-2..AC-6).
**Alternative:** an EF `SaveChanges` interceptor → hides the rule and cannot know the actor name; rejected (same as 680).

### D3. Actor name from `ICurrentUserService`
**Choice:** both handlers receive `ICurrentUserService` and use `ActivityActor.From` (`Name ?? Email ?? Sub`, truncated to 200). The name is a snapshot (A3).
**Alternative:** look the name up from the `sub` when reading → breaks for removed users; rejected.

### D4. Deleting removes the events explicitly and by FK cascade
**Choice:** `DeleteAssessmentAsync` removes the events of the assessment next to the interventions it already removes, and the FK is `ON DELETE CASCADE` as a safety net. The explicit removal makes AC-19 provable with the in-memory provider used by `AssessmentRepositoryTest`, which does not apply the database cascade to rows that are not tracked.
**Alternative:** rely on the cascade only → the in-memory test cannot prove it; rejected.

### D5. Separate endpoint and a new FE child component
**Choice:** `GET api/v1/assessments/{id}/history`. FE gets a new standalone OnPush component `assessment-activity-history` (signal input `assessmentId`, same markup and look as the intervention one) embedded at the end of `assessment-detail-dialog.component.html`, rendered only when `data.id` is defined. The request starts when the dialog opens, independent of the rest of the details (A9). The existing FE model `InterventionActivityModel` has the same shape; the new `AssessmentActivityModel` mirrors the new DTO on its own so the two contracts can evolve apart.
**Alternative:** make the intervention component generic → edits a component that passed validation in 680; rejected for this change (duplication noted in Follow-ups).

## Changes by layer

### Backend (`ERAS-BE/`)

| Layer | Change | Files | ACs |
|---|---|---|---|
| Domain | New entity and type enum | `src/Eras.Domain/Entities/AssessmentManagement/AssessmentActivity.cs` (new), `AssessmentActivityType.cs` (new) | AC-1, AC-2, AC-4 |
| Application | Contract `IAssessmentActivityRepository` (`AddRangeAsync`, `GetByAssessmentIdAsync`) | `src/Eras.Application/Contracts/Persistence/AssessmentManagement/IAssessmentActivityRepository.cs` (new) | AC-1, AC-7 |
| Application | `AssessmentActivityFactory` (pure comparison of status and comments) | `src/Eras.Application/Features/RemissionManagement/AssessmentActivityFactory.cs` (new) | AC-1..AC-5 |
| Application | Create: transaction, record "Assessment created" | `.../Handlers/CreateRemissionCommandHandler.cs` | AC-1 |
| Application | Update: capture previous values from `existing`, record events in the transaction | `.../Handlers/UpdateRemissionCommandHandler.cs` | AC-2..AC-6 |
| Application | Query `GetAssessmentActivityQuery(AssessmentId)` and handler (oldest first; `NotFoundException` (`Eras.Error.Bussiness`, status 404) when the assessment does not exist, using `IAssessmentRepository.GetByIdAsync`; a plain `KeyNotFoundException` would be turned into a 500 by the global `ErrorFilter`, found in manual validation Round 1) | `.../Queries.cs`, `.../Handlers/GetAssessmentActivityQueryHandler.cs` (new) | AC-7, AC-11, AC-12, AC-13 |
| Application | `AssessmentActivityDto` + mapper (description, status labels) registered in `ApplicationServiceRegistration` | `src/Eras.Application/DTOs/AssessmentManagement/AssessmentActivityDto.cs`, `Mappers/AssessmentManagement/AssessmentActivityToDtoMapper.cs` (new) | AC-7 |
| Infrastructure | EF configuration, `DbSet`, repository, DI line, migration `AddAssessmentActivities` | `.../PostgreSQL/Configurations/AssessmentManagement/AssessmentActivityConfiguration.cs`, `AppDbContext.cs`, `Repositories/AssessmentManagement/AssessmentActivityRepository.cs`, `PersistenceServiceRegistration.cs`, `Migrations/` (new) | AC-1..AC-19 |
| Infrastructure | `DeleteAssessmentAsync` also removes the assessment's events | `Repositories/AssessmentManagement/AssessmentRepository.cs` | AC-19 |
| Api | `GetAssessmentActivity` action with `[Authorize(Policy = ErasPolicies.AnyErasRole)]` | `src/Eras.Api/Controllers/AssessmentManagement/AssessmentsController.cs` | AC-8, AC-9, AC-10 |

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Model / service | `AssessmentActivityModel` mirrors the DTO; `AssessmentService.getActivity(assessmentId)` | `src/app/core/models/assessment-activity.model.ts` (new), `src/app/core/services/api/assessement.service.ts` | AC-14 |
| Component | New standalone OnPush `assessment-activity-history` (signal input, `@for`, plain interpolation, `DatePipe` `yyyy-MM-dd HH:mm`, no actions), embedded in the details dialog and added to its `imports` | `src/app/modules/assessments/components/assessment-detail/assessment-activity-history/` (new), `assessment-detail-dialog.component.{ts,html}` | AC-14..AC-18 |
| Messages | New `ASSESSMENT_ACTIVITY_MESSAGES` (title, empty text), separate from the intervention one | `src/app/core/constants/messages.ts` | AC-17 |

## API contract

| Endpoint | Policy | Request | Response | Status codes |
|---|---|---|---|---|
| `GET api/v1/assessments/{id}/history` | `ErasPolicies.AnyErasRole` | none | `AssessmentActivityDto[]` { id: int, type: `Created`/`CommentAdded`/`StatusChanged`, description: string, occurredAtUtc: UTC datetime, userName: string } | 200, 403, 404 |

- **FE model:** `assessment-activity.model.ts` mirrors the response (type as string union).
- **FE service:** `AssessmentService.getActivity`, path `${assessmentId}/history`, no leading slash. Not cached (`getAll` caching does not apply).
- **Scope rule:** only the events of the assessment in the route are returned; an unknown assessment is 404.
- `occurredAtUtc` is stored and serialized as UTC (`DateTimeKind.Utc`), the FE shows local time (A5).

## Data and migration

New table `assessment_activities` (FK `assessment_id` to `remissions.id` cascade, index `ix_assessment_activities_assessment_id`, `actor_name` and `actor_sub` max 200, type and statuses stored as strings like `InterventionActivityConfiguration`). New migration generated with the command in `ERAS-BE/AGENTS.md` §3.2; no applied migration and no snapshot is edited by hand. Existing assessments get no rows (A2, no backfill). Rollback: the migration's `Down` drops the table.

## Test strategy

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | BE | Application, `test/Eras.Application.Tests/Features/Assessments/Commands/` | `CreateRemissionCommandHandlerTests.cs` › `HandleAsync_NewAssessmentWithComments_RecordsOnlyCreatedEventAsync` |
| AC-2 | BE | same folder | `UpdateRemissionCommandHandlerTests.cs` › `HandleAsync_CommentAdded_RecordsCommentAddedEventAsync` |
| AC-3 | BE | same folder | `UpdateRemissionCommandHandlerTests.cs` › `HandleAsync_CommentChangedThenCleared_RecordsOnlyTheChangeAsync` |
| AC-4 | BE | same folder | `UpdateRemissionCommandHandlerTests.cs` › `HandleAsync_StatusChanged_RecordsPreviousAndNewStatusAsync` |
| AC-5 | BE | same folder | `UpdateRemissionCommandHandlerTests.cs` › `HandleAsync_NoTrackedChange_RecordsNoEventAsync` |
| AC-6 | BE | same folder | `UpdateRemissionCommandHandlerTests.cs` › `HandleAsync_RejectedStatusTransition_RecordsNoEventAsync` |
| AC-7 | BE | Application, `.../Features/Assessments/Queries/` | `GetAssessmentActivityQueryHandlerTests.cs` › `HandleAsync_UnorderedEvents_ReturnsOldestFirstAsync` |
| AC-11 | BE | same file | `HandleAsync_OtherAssessmentHasEvents_ReturnsOnlyItsOwnAsync` |
| AC-12 | BE | Api, `test/Eras.Api.Tests/Controllers/` | `AssessmentActivityNotFoundTests.cs` › `GetAssessmentActivity_UnknownAssessment_RespondsNotFoundAsync` (real handler and controller behind the global `ErrorFilter`, where the status code is decided; the handler test `HandleAsync_UnknownAssessment_ThrowsNotFoundAsync` carries no AC tag) |
| AC-13 | BE | same file | `HandleAsync_NoEvents_ReturnsEmptyListAsync` |
| AC-8 | BE | Api, `test/Eras.Api.Tests/Authorization/` | `AssessmentActivityPolicyTests.cs` › `GetAssessmentActivity_StudentServicesOfficer_IsAuthorizedAsync` |
| AC-9 | BE | same file | `GetAssessmentActivity_Professional_IsAuthorizedAsync` |
| AC-10 | BE | same file | `GetAssessmentActivity_Guest_IsForbiddenAsync` |
| AC-19 | BE | Infrastructure, `test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Repositories/` | `AssessmentRepositoryTest.cs` › `DeleteAssessmentAsync_AssessmentWithEvents_RemovesOnlyItsEventsAsync` |
| AC-14 | FE | `.../assessment-detail/assessment-activity-history/assessment-activity-history.component.spec.ts` | `[681-add-activity-history-to-assessment-details/AC-14] lists description, YYYY-MM-DD HH:mm time and user name in the order received` |
| AC-15 | FE | same file | `[…/AC-15] is read only, no edit or delete action` |
| AC-16 | FE | same file | `[…/AC-16] shows only the creation entry without empty rows` |
| AC-17 | FE | same file | `[…/AC-17] shows "No activity recorded yet." when there are no events` |
| AC-18 | FE | same file | `[…/AC-18] shows the user name as plain text` |

Extra edge tests carry no AC tag. One of them is required here: a spec of `assessment-detail-dialog.component` proving the dialog renders the history section for an assessment with an id (change 680 shipped with no test of the section inside its panel). Gates: BE coverage >= 25%, FE >= 15% (AGENTS.md §8.7). Existing Create and Update handler tests need their constructors updated for the new dependencies.

## Risks / Trade-offs

- [Handlers get new dependencies] → update the constructors of the Create and Update tests in the same task.
- [`AddAsync` and `UpdateAsync` save on their own, so a failure of the event insert after them would leave the assessment saved] → both calls and the event insert run inside `ExecuteInTransactionAsync`; `AssessmentActivityRepository` only adds to the context and the transaction commits.
- [`BaseRepository.AddAsync` wraps errors in `DatabaseCustomException` and clears the tracker] → the transaction rolls back and the exception propagates unchanged.
- [The FE dialog gets `data.id` undefined, the failure found in change 680] → render only when `data.id` is defined, covered by the dialog spec in task 2.5.
- [Time zone] → UTC in the API, local time in the FE (A5).

## Migration Plan

Apply `AddAssessmentActivities` with the normal migration step of the deploy; no flag. Roll back by reverting the migration (drops the table; history is lost, nothing else depends on it).

## Follow-ups

- `intervention-activity-history` and `assessment-activity-history` duplicate markup and styles; a shared presentational component can replace both in a refactor change.
- `InterventionActivity` and `AssessmentActivity` are parallel tables; unify only if a third entity needs history.
- `GetInterventionActivityQueryHandler` (change 680) throws `KeyNotFoundException` for an unknown assessment or intervention, which the global `ErrorFilter` turns into a 500 instead of a 404; switch it to `NotFoundException` in its own change.
- Backfilling history for existing assessments (out of scope in the issue).
- The issue text says "four" event types but lists three; confirm with the author whether a fourth exists.
