# Design

<!-- ILLUSTRATIVE EXAMPLE of a filled-in design.md for the fictional change in sdd-spec/examples. Names of handlers, DTOs and tests are invented. Do not copy its content. -->

## Context

The create use case lives under `ERAS-BE/src/Eras.Application/Features/Configurations/Command/CreateConfiguration/` (legacy folder-per-use-case layout) and is exposed by `ConfigurationsController`. The FE has a create form in the settings module. See proposal.md - Why.

## Goals / Non-Goals

**Goals:**
- Reject duplicate active names per officer on create (AC-1, AC-2), enforce who can create (AC-4, AC-5) and blank names (AC-6), and show the messages in the form (AC-3, AC-6).

**Non-Goals:**
- Moving the use case to the `Features/<Feature>/Handlers/` layout: a refactor gets its own change.

## Decisions

### D1. Check uniqueness in the create handler, backed by a repository query
**Choice:** the handler asks the repository whether an active configuration with the normalized name exists for the officer and throws `BussinessException(message, 409)`.
**Alternative:** a unique database index → not used alone: it cannot express "active only, ignoring case and spaces" without a migration and it surfaces as a generic database error.

### D2. Normalize the name once
**Choice:** trim and compare case-insensitively inside the repository query, so the stored name keeps what the officer typed.
**Alternative:** store a normalized copy → needs a migration for no user-visible benefit.

## Changes by layer

### Backend (`ERAS-BE/`)

| Layer | Change | Files | ACs |
|---|---|---|---|
| Application | Duplicate check and blank-name rule in the create handler; message constants | `src/Eras.Application/Features/Configurations/Command/CreateConfiguration/` | AC-1, AC-2, AC-6 |
| Application | `ExistsActiveByNameAsync(officerId, name, cancellationToken)` on the repository interface | `src/Eras.Application/Contracts/Persistence/...` | AC-1, AC-2 |
| Infrastructure | Implement the query (active only, trimmed, case-insensitive) | `src/Eras.Infrastructure/Persistence/PostgreSQL/Repositories/...` | AC-1, AC-2 |
| Api | `[Authorize(Policy = ErasPolicies.RequireErasAdminOrOfficer)]` on the create action | `src/Eras.Api/Controllers/ConfigurationsController.cs` | AC-4 |

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Component | Show the API message next to the name field on 409 and 400; keep the form open | the settings create-configuration component (existing) | AC-3, AC-6 |
| Route | Roles of the create route limited to Administrator and Officer in `ROUTE_METADATA` | `src/app/core/utils/routing/route-metadata.ts` | AC-5 |
| Messages | Conflict and blank-name texts | `src/app/core/constants/messages.ts` | AC-3, AC-6 |

## API contract

| Endpoint | Policy | Request DTO | Response DTO | Status codes |
|---|---|---|---|---|
| `POST api/v1/configurations` | `RequireErasAdminOrOfficer` | unchanged | unchanged | adds 409 and 400 with `{ message }` |

- **FE model:** unchanged. **FE service:** unchanged; the component reads the error message from the response.
- **Ownership / scope rules:** uniqueness is per officer (handler, AC-1).

## Data and migration

No schema change.

## Test strategy

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | BE | Application: `test/Eras.Application.Tests/Features/Configurations/` | `CreateConfigurationCommandHandlerTests.cs` › `HandleAsync_DuplicateActiveName_Throws409AndDoesNotPersistAsync` |
| AC-2 | BE | Application: same folder | `CreateConfigurationCommandHandlerTests.cs` › `HandleAsync_InactiveNameReused_CreatesActiveConfigurationAsync` |
| AC-3 | FE | `src/app/modules/settings/.../configuration-form.component.spec.ts` | `[608-reject-duplicate-configuration-name/AC-3] shows the conflict message next to the name field` |
| AC-4 | BE | Api: `test/Eras.Api.Tests/Controllers/` | `ConfigurationsControllerTests.cs` › `Create_ProfessionalRole_Returns403Async` |
| AC-5 | FE | `src/app/core/utils/routing/route-metadata.spec.ts` | `[608-reject-duplicate-configuration-name/AC-5] redirects a user with no ERAS role to access denied` |
| AC-6 | BE | Application: same folder as AC-1 | `CreateConfigurationCommandHandlerTests.cs` › `HandleAsync_BlankName_Throws400Async` |
| AC-6 | FE | `.../configuration-form.component.spec.ts` | `[608-reject-duplicate-configuration-name/AC-6] shows the blank-name message and keeps the form open` |

Coverage gates: BE >= 25%, FE >= 15%.

## Risks / Trade-offs

- [Case-insensitive comparison hits an unindexed column] → the table is small per officer; revisit with an index if it shows up in profiling.
- [Two simultaneous creates both pass the check] → accepted for now; a unique index is listed under Follow-ups.

## Follow-ups

- Add a partial unique index on (officer, normalized name) where active, in its own change.
- Move `Features/Configurations/Command/CreateConfiguration/` to the target layout, in its own refactor change.
