# Design

## Context

See `proposal.md` (Why) and `specs/intervention-management/spec.md` (AC-1..AC-23, AC-2 is a deliberate gap).

- Interventions live inside the `Assessment` aggregate and are persisted through `IAssessmentRepository` (`ERAS-BE/src/Eras.Application/Contracts/Persistence/AssessmentManagement/IAssessmentRepository.cs`, implementation `.../Repositories/AssessmentManagement/AssessmentRepository.cs`). There is no history, audit or event store for them.
- `AddInterventionCommandHandler` and `UpdateInterventionCommandHandler` (`Eras.Application/Features/RemissionManagement/Handlers/`) save inside `IUnitOfWork.ExecuteInTransactionAsync`. They only know the Keycloak `sub` (`IUserIdentityProvider`), not the user name.
- `UpdateInterventionAsync` mutates the tracked entity, so the previous status, comments, risk level (`RiskLevelName`) and end risk level (`EndRiskLevelName`) must be read into locals first. Both risk levels are accepted by `UpdateInterventionMapper` and by the Replace handler (A10); the FE only sends an end risk level when the status is Finalized, but the BE does not enforce it.
- `ReplaceInterventionCommandHandler` (type change, used by the edit modal) deletes the intervention and adds a new one with a new id inside one transaction.
- Precedent for storing a display name: `StudentInterventionEntry.CreatedByName` and `CreateStudentInterventionCommandHandler` (`ICurrentUserService`, `Name ?? Email ?? sub`, truncated to 200).
- FE: the details are a side panel (`intervention-detail.component`, legacy `@Input` style) rendered by `intervention-list.component.html`; `InterventionService` extends `BaseApiService` with resource `assessments`.

## Goals / Non-Goals

**Goals:**
- Record events for create, comment, status change, risk level and end risk level change inside the existing transactions (AC-1, AC-3..AC-6, AC-19..AC-23).
- Read endpoint ordered oldest first, role-protected (AC-7..AC-13).
- Read-only FE section (AC-14..AC-18) that loads in parallel with the rest of the details.

**Non-Goals:**
- No change to the bulk replace (`UpsertInterventionsCommandHandler`) or to deleting an intervention beyond cascading its events.
- No event for professional, attachments or other fields.

## Decisions

### D1. Store structured events in a new table, build the text when reading
**Choice:** new entity `InterventionActivity` (`Id`, `InterventionId`, `Type` = `Created | CommentAdded | StatusChanged | RiskLevelChanged | EndRiskLevelChanged`, `PreviousStatus?`, `NewStatus?`, `PreviousRiskLevel?`, `NewRiskLevel?` (`InterventionLevel?`, shared by both risk level types), `OccurredAtUtc`, `ActorSub`, `ActorName`), table `intervention_activities`, FK to the intervention with cascade delete and an index on `intervention_id`. The mapper builds `Description` ("Intervention created", "Comment added", "Status changed: Remitted → In Progress", "Risk level changed: Medium → High", "End risk level changed: None → Low", a null value is "None"). The comment text is never stored (AC-3).
**Alternative:** store the description text → labels could not change and statuses could not be queried; rejected.

### D2. Record events in the handlers, in the same transaction
**Choice:** a small pure Application helper (`InterventionActivityFactory`) compares previous and new status, comments, risk level and end risk level and returns the events to add (comment: empty→non-empty or non-empty→different non-empty; status, risk level and end risk level: any change, one event per field, in the order comment, status, risk level, end risk level, all with the same time and actor, AC-23). Add, Update and Replace handlers call it inside their `ExecuteInTransactionAsync`, so a rejected or failed save records nothing (AC-5, AC-6).
**Alternative:** an EF `SaveChanges` interceptor → hides the rule, cannot know the actor name; rejected.

### D3. Actor name from `ICurrentUserService`
**Choice:** the three handlers add `ICurrentUserService` and use `Name ?? Email ?? Sub`, truncated to 200, like the StudentInterventions precedent. Name is a snapshot (A4).
**Alternative:** look the name up from the `sub` when reading → breaks for removed users and changes past entries; rejected.

### D4. Keep the history when the type changes (AC-20)
**Choice:** `ReplaceInterventionCommandHandler` reads the events of the old id (no tracking) before deleting, then, after adding the new intervention, re-adds copies with the new `InterventionId`, then records comment, status and risk level events of that save like an edit, comparing with the old intervention (A11). The old rows are removed by the cascade.
**Alternative:** `UPDATE intervention_id` before delete → the FK cascade and the delete order make it fragile; rejected.

### D6. Two risk level types in the same table (AC-21, AC-22, AC-23)
**Choice:** the two risk levels are two event types (`RiskLevelChanged`, `EndRiskLevelChanged`) that share the columns `previous_risk_level` and `new_risk_level` (strings, nullable like the statuses), added by a **new** migration `AddRiskLevelToInterventionActivities`; the migration of D1 is never edited. The mapper writes "Risk level changed" or "End risk level changed" and shows null as "None" (A10, A12).
**Alternative:** one type with a column saying which field changed → the type already says it; four columns (two per field) → duplicates the same data; rejected. The FE model only gains two values in the type union: the section shows the description as is.

### D5. Separate endpoint, child component for the UI
**Choice:** `GET api/v1/assessments/{id}/interventions/{interventionId}/history`; FE gets a new standalone OnPush component `intervention-activity-history` that fetches by its inputs and is embedded at the end of `intervention-detail.component.html`. The BE `InterventionDto` does not return the assessment id, so the list component (which knows the assessment it shows) passes it to the details panel as a new `assessmentId` input, and the intervention id comes from `data.id`. The request starts when the panel opens, in parallel with the attachments (A8).
**Alternative:** add the events to `InterventionDto` → loads them for every list row; rejected. Adding `AssessmentId` to `InterventionDto` instead of the new input → changes the API contract of every intervention for something the list already knows; rejected.

## Changes by layer

### Backend (`ERAS-BE/`)

| Layer | Change | Files | ACs |
|---|---|---|---|
| Domain | New entity and type enum (D6 adds the two risk level types and the two nullable columns) | `src/Eras.Domain/Entities/AssessmentManagement/InterventionActivity.cs` (new), `InterventionActivityType.cs` (new) | AC-1, AC-3, AC-4, AC-21, AC-22 |
| Application | Repository contract `IInterventionActivityRepository` (`AddRangeAsync`, `GetByInterventionIdAsync`) | `src/Eras.Application/Contracts/Persistence/AssessmentManagement/IInterventionActivityRepository.cs` (new) | AC-1, AC-7 |
| Application | `InterventionActivityFactory` (pure comparison of status, comments, risk level and end risk level) | `src/Eras.Application/Features/RemissionManagement/InterventionActivityFactory.cs` (new) | AC-3, AC-4, AC-5, AC-19, AC-21, AC-22, AC-23 |
| Application | Add: record "Intervention created" after the id exists | `.../Handlers/AddInterventionCommandHandler.cs` | AC-1 |
| Application | Update: capture previous values, record events in the transaction | `.../Handlers/UpdateInterventionCommandHandler.cs` | AC-3, AC-4, AC-5, AC-6, AC-19, AC-21, AC-22, AC-23 |
| Application | Replace: keep and re-add events, record changes | `.../Handlers/ReplaceInterventionCommandHandler.cs` | AC-20 |
| Application | Query `GetInterventionActivityQuery(AssessmentId, InterventionId)` and handler (order oldest first, `NotFoundException` (`Eras.Error.Bussiness`, status 404) when the assessment does not exist or the intervention is not in it; a plain `KeyNotFoundException` is turned into a 500 by the global `ErrorFilter`, found in manual validation 1) | `.../Queries.cs`, `.../Handlers/GetInterventionActivityQueryHandler.cs` (new) | AC-7, AC-11, AC-12, AC-13 |
| Application | `InterventionActivityDto` + mapper (description, status labels and risk level labels) registered in `ApplicationServiceRegistration` | `src/Eras.Application/DTOs/AssessmentManagement/InterventionActivityDto.cs`, `Mappers/AssessmentManagement/InterventionActivityToDtoMapper.cs` (new) | AC-7 |
| Infrastructure | EF configuration, `DbSet`, repository, DI line, new migration `AddInterventionActivities` and `AddRiskLevelToInterventionActivities` (D6) | `.../PostgreSQL/Configurations/AssessmentManagement/InterventionActivityConfiguration.cs`, `AppDbContext.cs`, `Repositories/AssessmentManagement/InterventionActivityRepository.cs`, `PersistenceServiceRegistration.cs`, `Migrations/` (new) | AC-1..AC-20 |
| Api | `GetInterventionActivity` action with `[Authorize(Policy = ErasPolicies.AnyErasRole)]` | `src/Eras.Api/Controllers/AssessmentManagement/AssessmentsController.cs` | AC-8, AC-9, AC-10 |

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Model / service | `InterventionActivityModel` mirrors the DTO; `getActivity(assessmentId, interventionId)` | `src/app/core/models/intervention-activity.model.ts` (new), `src/app/core/services/api/intervention.service.ts` | AC-14 |
| Component | New standalone OnPush `intervention-activity-history` (signal inputs, `@for`, plain interpolation, `DatePipe` `yyyy-MM-dd HH:mm`, no actions) embedded in the details, which gets a new `assessmentId` input passed from `intervention-list.component.html` | `src/app/modules/assessments/components/interventions/interventions-detail/intervention-activity-history/` (new), `intervention-detail.component.{ts,html}` | AC-14..AC-18 |
| Messages | Title and empty text | `src/app/core/constants/messages.ts` (`INTERVENTION_ACTIVITY_MESSAGES`) | AC-17 |

## API contract

| Endpoint | Policy | Request | Response | Status codes |
|---|---|---|---|---|
| `GET api/v1/assessments/{id}/interventions/{interventionId}/history` | `ErasPolicies.AnyErasRole` | none | `InterventionActivityDto[]` { id: int, type: `Created`/`CommentAdded`/`StatusChanged`/`RiskLevelChanged`/`EndRiskLevelChanged`, description: string, occurredAtUtc: UTC datetime, userName: string } | 200, 403, 404 |

- **FE model:** `intervention-activity.model.ts` mirrors the response (type as string union, two values added by D6).
- **FE service:** `InterventionService.getActivity`, path `${assessmentId}/interventions/${interventionId}/history`, no leading slash.
- **Scope rule:** the intervention must belong to the assessment in the route (404 otherwise); events of other interventions are never returned.
- `occurredAtUtc` is stored and serialized as UTC (`DateTimeKind.Utc`), so the FE shows local time.

## Data and migration

New table `intervention_activities` (first migration) (FK `intervention_id` cascade, index `ix_intervention_activities_intervention_id`, `actor_name` max 200, `actor_sub` max 200, statuses as strings like `InterventionConfiguration`). New migration generated with the command in `ERAS-BE/AGENTS.md` §3.2; no applied migration and no snapshot is edited by hand. The second migration only adds the nullable columns `previous_risk_level` and `new_risk_level` (strings, max 20 like the statuses) and does not touch existing rows. Existing interventions get no rows (A2, no backfill).

## Test strategy

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | BE | Application, `test/Eras.Application.Tests/Features/Assessments/Commands/` | `AddInterventionCommandHandlerTests.cs` › `HandleAsync_NewIntervention_RecordsCreatedEventAsync` |
| AC-3 | BE | same folder | `UpdateInterventionCommandHandlerTests.cs` › `HandleAsync_CommentAdded_RecordsCommentAddedEventAsync` |
| AC-4 | BE | same folder | `UpdateInterventionCommandHandlerTests.cs` › `HandleAsync_StatusChanged_RecordsPreviousAndNewStatusAsync` |
| AC-5 | BE | same folder | `UpdateInterventionCommandHandlerTests.cs` › `HandleAsync_NoTrackedChange_RecordsNoEventAsync` |
| AC-6 | BE | same folder | `UpdateInterventionCommandHandlerTests.cs` › `HandleAsync_RejectedStatusTransition_RecordsNoEventAsync` |
| AC-19 | BE | same folder | `UpdateInterventionCommandHandlerTests.cs` › `HandleAsync_CommentChangedThenCleared_RecordsOnlyTheChangeAsync` |
| AC-20 | BE | same folder | `ReplaceInterventionCommandHandlerTests.cs` › `HandleAsync_TypeChanged_KeepsTheEventsAsync` |
| AC-21 | BE | same folder | `UpdateInterventionCommandHandlerTests.cs` › `HandleAsync_RiskLevelChanged_RecordsPreviousAndNewRiskLevelAsync` |
| AC-22 | BE | same folder | `UpdateInterventionCommandHandlerTests.cs` › `HandleAsync_EndRiskLevelChanged_RecordsPreviousAndNewEndRiskLevelAsync` |
| AC-23 | BE | same folder | `UpdateInterventionCommandHandlerTests.cs` › `HandleAsync_BothRiskLevelsChanged_RecordsTwoEventsAsync` |
| AC-7 | BE | Application, `.../Features/Assessments/Queries/` | `GetInterventionActivityQueryHandlerTests.cs` › `HandleAsync_UnorderedEvents_ReturnsOldestFirstAsync` |
| AC-11 | BE | same file | `HandleAsync_OtherInterventionHasEvents_ReturnsOnlyItsOwnAsync` |
| AC-12 | BE | Api, `test/Eras.Api.Tests/Controllers/` | `InterventionActivityNotFoundTests.cs` › `GetInterventionActivity_UnknownIntervention_RespondsNotFoundAsync` |
| AC-13 | BE | same file | `HandleAsync_NoEvents_ReturnsEmptyListAsync` |
| AC-8 | BE | Api, `test/Eras.Api.Tests/Authorization/` | `InterventionActivityPolicyTests.cs` › `GetInterventionActivity_StudentServicesOfficer_IsAuthorizedAsync` |
| AC-9 | BE | same file | `GetInterventionActivity_Professional_IsAuthorizedAsync` |
| AC-10 | BE | same file | `GetInterventionActivity_Guest_IsForbiddenAsync` |
| AC-14 | FE | `.../intervention-activity-history/intervention-activity-history.component.spec.ts` | `[680-add-activity-history-to-intervention-details/AC-14] lists description, YYYY-MM-DD HH:mm time and user name in the order received` |
| AC-15 | FE | same file | `[…/AC-15] is read only, no edit or delete action` |
| AC-16 | FE | same file | `[…/AC-16] shows only the creation entry without empty rows` |
| AC-17 | FE | same file | `[…/AC-17] shows "No activity recorded yet." when there are no events` |
| AC-18 | FE | same file | `[…/AC-18] shows the user name as plain text` |

Extra edge tests carry no AC tag (planned: the Replace handler records risk level events (A11); the mapper words both risk level descriptions and shows null as "None"). Gates: BE coverage >= 25%, FE >= 15% (AGENTS.md §8.7). Existing handler tests need their constructors updated for the new dependencies.

## Risks / Trade-offs

- [Handlers get new dependencies] → update the constructors of all Add, Update and Replace tests in the same task.
- [A repository call that saves on its own would escape the transaction] → `InterventionActivityRepository` only adds to the context; the handler's `ExecuteInTransactionAsync` commits.
- [Bulk replace (`UpsertInterventionsCommandHandler`) removes and re-adds every intervention, losing events through the cascade] → not used by the FE today; recorded under Follow-ups.
- [Time zone] → UTC in the API, local time in the FE (A6).

## Follow-ups

- Bulk replace of interventions (`PUT api/v1/assessments/{id}/interventions`) deletes the events of all interventions of the assessment; decide whether to keep them if the frontend starts using it.
- Priority events need a separate change that first adds a priority field to interventions.
- Backfilling history for existing interventions (out of scope in the issue).
- New FE specs use `provideHttpClient()`; the older `intervention.service.spec.ts` still uses the legacy testing module (left alone).
- `GetInterventionActivityQueryHandler` loads the whole assessment with all its interventions (`GetByIdWithInterventionsAsync`) only to check that the intervention belongs to it; a small existence query (assessment id + intervention id) would avoid it (review nit of ERAS-BE#588, not blocking).
- `intervention-activity-history` and `assessment-activity-history` duplicate markup and styles, and `INTERVENTION_ACTIVITY_MESSAGES` and `ASSESSMENT_ACTIVITY_MESSAGES` are identical; a shared presentational component and one message object can replace both in a refactor change (review nit of ERAS-FE#1123; also listed in change 681).
