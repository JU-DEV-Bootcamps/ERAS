# Design

<!--
TEMPLATE for openspec/changes/<change-id>/design.md, created by /sdd-plan. This is the PLAN of the change.
How, never why or what: point to proposal.md and the specs instead of restating them.
Delete every HTML comment and every section that truly does not apply to this change
(keep Follow-ups last, always). Use real paths and names found in the code, not guesses.
-->

## Context

<!-- Current state and constraints that shape the approach, from the code you read. Reference
     proposal.md for the motivation. Name the existing files this change builds on. -->

## Goals / Non-Goals

**Goals:**
- <what this design achieves, in terms of the ACs it covers: AC-1..AC-n>

**Non-Goals:**
- <design-level boundaries; do not repeat the proposal's Out of scope>

## Decisions

<!-- One block per key technical choice, each with the alternative considered.
     Add the **ADR:** line only when the decision is architectural (see /sdd-adr "Is it an ADR?") or
     follows an existing ADR; otherwise delete it. -->

### D1. <decision>
**Choice:** <what and why, in 1-3 lines>
**Alternative:** <what else was possible> → <why not>
**ADR:** ADR-NNNN

## Changes by layer

<!-- Only the sides and layers this change touches. Cite ACs per item. Follow the golden paths of
     AGENTS.md section 2; do not copy the legacy patterns listed there. -->

### Backend (`ERAS-BE/`)

| Layer | Change | Files | ACs |
|---|---|---|---|
| Domain | <entity / validator / status transition> | `src/Eras.Domain/...` | AC-n |
| Application | <request, handler, DTO, mapper, repository interface> | `src/Eras.Application/Features/<Feature>/...` | AC-n |
| Infrastructure | <repository, EF configuration, migration, policy> | `src/Eras.Infrastructure/...` | AC-n |
| Api | <controller action, route, `[Authorize(Policy = ...)]`> | `src/Eras.Api/Controllers/...` | AC-n |

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Route | <lazy route, `canActivateAuthRole`, `ROUTE_METADATA` roles, feature flag> | `src/app/...` | AC-n |
| Model / service | <model mirroring the BE DTO, service extending `BaseApiService`> | `src/app/core/...` | AC-n |
| Component | <standalone OnPush component, Reactive Form, permissions via `PermissionsService`> | `src/app/modules/...` | AC-n |
| Messages | <user-facing text in `core/constants/messages.ts`> | `src/app/core/constants/messages.ts` | AC-n |

### Infra / CI
<!-- Only if touched: compose, nginx, workflows, Keycloak realm. Otherwise delete. -->

## API contract
<!-- REQUIRED when the change adds or changes an endpoint. Otherwise write "No API change." -->

| Endpoint | Policy | Request DTO | Response DTO | Status codes |
|---|---|---|---|---|
| `POST api/v1/<resource>` | `ErasPolicies.<Policy>` | `<Name>Dto` { field: type } | `<Name>Dto` { field: type } | 201, 400, 403, 409 |

- **FE model:** `src/app/core/models/<entity>.model.ts` mirrors the response DTO exactly (enums as string unions).
- **FE service:** `src/app/core/services/api/<resource>.service.ts`, method `<name>`, no leading slash.
- **Ownership / scope rules:** <rule enforced in the handler, tied to its AC>

## Data and migration
<!-- Entity or column changes, migration name, SQL views, backfill, rollback. Or "No schema change." -->

## Test strategy

<!-- One row per AC per affected side (the Side line of the AC). Layer = where the behavior is decided
     (AGENTS.md section 4.2): business rule -> handler/domain test; status code or authorization -> Api test;
     FE -> Jasmine spec next to the unit. The test names here are the ones tasks.md will carry. -->

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | BE | Application: `test/Eras.Application.Tests/Features/<Feature>/` | `<Handler>Tests.cs` › `HandleAsync_<Condition>_<Expected>Async` |
| AC-1 | FE | `src/app/modules/<feature>/.../<unit>.spec.ts` | `[<change-id>/AC-1] <behavior the user sees>` |

Extra edge-case tests carry no AC tag. Coverage gates: BE >= 25%, FE >= 15% (AGENTS.md section 5.6).

## Risks / Trade-offs

<!-- Format: [Risk] → Mitigation. Include blast radius when a shared thing changes
     (global query filter, shared model, shared component). -->
- [<risk>] → <mitigation>

## Migration Plan
<!-- Deploy and rollback steps, only when the change needs them (migration, flag rollout). Otherwise delete. -->

## Open Questions
<!-- Only unknowns that cannot change the specs, the approach or the task breakdown. If one could, ask the user
     now. Delete the section if there are none. -->

## Follow-ups
<!-- Out-of-scope findings noticed while planning (AGENTS.md principle 7). Always the LAST section. -->
- <finding, or "None.">
