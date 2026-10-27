# AGENTS.md — ERAS Engineering Guide

| # | Section |
|---|---|
| 1 | [What ERAS is](#1-what-eras-is) |
| 2 | [Project documents](#2-project-documents) |
| 3 | [Commands](#3-commands) |
| 4 | [Architecture](#4-architecture) |
| 5 | [Conventions](#5-conventions) |
| 6 | [Backend](#6-backend) |
| 7 | [Frontend](#7-frontend) |
| 8 | [Workflow with agents](#8-workflow-with-agents) |
| 9 | [Limits](#9-limits) |

---

## 1. What ERAS is

ERAS (Early Risk Assistance Solution) is a Jala University platform for detecting
and following up on student risk. This file is the single source of rules for
**every contributor, human or AI agent**. `CLAUDE.md` imports it.

This repository uses **Spec-Driven Development (SDD) with [OpenSpec](https://github.com/Fission-AI/OpenSpec)**.
No code changes without an approved spec (see §8).

### 1.1 Core principles

1. **Spec first.** No spec, no code. Every change starts as an OpenSpec change in `openspec/changes/` (§8).
2. **The spec is the source of truth.** If code and spec disagree, the code is wrong, or the spec must be changed *through a change*. Never let them drift silently.
3. **Every Acceptance Criterion is tested, one to one.** Each AC (OpenSpec scenario) has exactly one tagged test per affected side, and each tagged test proves exactly one AC (§5.2).
4. **Test first.** Write the AC test, watch it fail, then implement.
5. **Respect the layers.** Dependencies point inward (Onion). Components never call `HttpClient` directly (§4, §7).
6. **New code follows the target style, legacy code is left alone.** Use the *golden path* in §6.1 and §7.1 for new code. Do not refactor legacy code outside the change's declared scope. A refactor gets its own change.
7. **Do the smallest thing that satisfies the spec.** No speculative features, no "while I'm here" edits. If you find something out of scope, write it down in the change's `design.md` under *Follow-ups*.
8. **Secure by default.**
   - Every endpoint and every route declares its authorization.
   - No secrets in source or appsettings.
   - Never return stack traces or internals to clients.
   - Validate all input at the boundary.
9. **Backend and frontend stay in sync.** When an API contract changes, the BE DTO, the FE model and the FE service change *in the same OpenSpec change*.
10. **Green gates or not done.** Build with warnings as errors, format, lint, all tests, coverage gates, and `openspec validate --strict` must all pass (§8.7).

---

## 2. Project documents

### 2.1 Repository map

| Path | What it is |
|---|---|
| `ERAS-BE/` | **Git submodule.** Backend: .NET 8, Onion Architecture, EF Core 9 + PostgreSQL 15, MediatR 12, Keycloak JWT. Solution: `ERAS-BE/Eras.sln` |
| `ERAS-FE/` | **Git submodule.** Frontend: Angular 19 (standalone), Angular Material 3, keycloak-js, ApexCharts |
| `openspec/specs/` | Living specs: the current, agreed behavior of the system, grouped by capability |
| `openspec/changes/<change-id>/` | Proposed or in-progress changes (proposal, spec deltas, design, tasks) |
| `openspec/changes/archive/` | Completed changes (history) |
| `openspec/adr/` | Architecture Decision Records: one durable decision per file (`NNNN-<title>.md`), index in `README.md` (§8.4) |
| `Keycloak/realm-export.json` | Local realm `ERAS`: clients, roles, seed users |
| `docker-compose.yml`, `docker-compose.local.yml` | Local stack: backend, frontend, postgres, keycloak |
| `deploy/`, `nginx/`, `.github/workflows/` | Prod compose, nginx configs, deploy pipelines |

### 2.2 Documents and sources of truth

| Document | Source of truth for |
|---|---|
| `AGENTS.md` (this file) | Every rule: principles, architecture, conventions, workflow, limits |
| `CLAUDE.md` | Claude Code specifics only; it imports this file |
| `README.md` | Onboarding: what ERAS is, how to set up and run it |
| `openspec/config.yaml` | The rules OpenSpec injects into its artifacts (AC format, traceability table, design triggers) |
| `openspec/specs/` | Current behavior of the system (principle 2) |
| `openspec/changes/<change-id>/` | What a change adds or modifies, and its plan and tasks (§8.2) |
| `openspec/adr/` | Durable architectural decisions that later changes must respect (§8.4) |
| `.claude/skills/` | The `/sdd-*` and `/opsx:*` workflows (§8.5) |

---

## 3. Commands

Run these from the repository root (`ERAS/`) unless a `cd` is shown. They work in Git Bash. In PowerShell, use the same commands except the `bash` blocks.

### 3.1 OpenSpec

```bash
openspec list                                  # active changes
openspec list --specs                          # existing capabilities
openspec new change <change-id>                # scaffold openspec/changes/<change-id>/
openspec status --change <change-id>           # artifact completion status
openspec show <change-id>                      # render a change (add --json for tooling)
openspec validate <change-id> --strict         # validate ONE change   ← required gate
openspec validate --changes --strict           # validate all active changes
openspec validate --all --strict               # validate all changes and specs
openspec archive <change-id> --yes             # merge deltas into openspec/specs/ and archive
openspec archive <change-id> --yes --skip-specs   # tooling/docs-only change
```

Project rules for OpenSpec artifacts (AC format, traceability table, design triggers) live in
`openspec/config.yaml`. The CLI and the slash commands inject them automatically. The slash commands and
skills are listed in §8.5.

### 3.2 Backend (`ERAS-BE/`)

```bash
cd ERAS-BE
dotnet restore Eras.sln
dotnet build Eras.sln -warnaserror                                  # build gate
dotnet format Eras.sln --verify-no-changes                          # format gate
dotnet test Eras.sln                                                # all tests
dotnet test Eras.sln --filter "Change=<change-id>"                  # every AC test of a change
dotnet test Eras.sln --filter "AC=<change-id>/AC-1"                 # one AC
dotnet test Eras.sln --filter "FullyQualifiedName~CreateRemission"  # by name
dotnet test Eras.sln --collect:"XPlat Code Coverage" --results-directory ./TestResults --settings coverlet.runsettings
                                                                    # coverage (CI gate ≥ 25% lines)
dotnet ef migrations add <Name> -p src/Eras.Infrastructure -s src/Eras.Api -o Persistence/PostgreSQL/Migrations
```

### 3.3 Frontend (`ERAS-FE/`)

```bash
cd ERAS-FE
npm ci
npm run lint                                                        # ESLint + Prettier
npm test -- --watch=false --browsers=ChromeHeadless                 # all specs
npm test -- --watch=false --browsers=ChromeHeadless --code-coverage # coverage (CI gate ≥ 15%)
npm test -- --watch=false --browsers=ChromeHeadless --include="src/app/modules/<feature>/**/*.spec.ts"
npm run build                                                       # production build
```

### 3.4 Local stack

```bash
cp .env.sample .env                      # first time only, then set POSTGRES_PASSWORD
docker compose up --build                # backend :8080 · frontend :4200 · keycloak :18080 · postgres :5432
docker compose -f docker-compose.local.yml up --build   # WSL / host-network variant
git submodule update --init --recursive  # after cloning
```

---

## 4. Architecture

### 4.1 Backend — .NET 8 Onion Architecture (`ERAS-BE/`)

```
            ┌───────────────────────── Eras.Api ─────────────────────────┐
            │   ┌──────────────── Eras.Infrastructure ────────────────┐  │
            │   │   ┌────────────── Eras.Application ─────────────┐   │  │
            │   │   │   ┌─────────── Eras.Domain ────────────┐    │   │  │
            │   │   │   │  Entities, enums, validators,      │    │   │  │
            │   │   │   │  status transitions                │    │   │  │
            │   │   │   └────────────────────────────────────┘    │   │  │
            │   │   │  Features (CQRS), Contracts, DTOs, Mappers   │   │  │
            │   │   └──────────────────────────────────────────────┘   │  │
            │   │  EF Core/PostgreSQL, repositories, Keycloak, jobs    │  │
            │   └──────────────────────────────────────────────────────┘  │
            │  Controllers, middleware, filters, Program.cs              │
            └────────────────────────────────────────────────────────────┘
            Eras.Error: cross-cutting exception types (referenced by Application and Api)
```

| Layer | Project | Owns | May reference |
|---|---|---|---|
| Domain | `src/Eras.Domain` | Entities (`Entities/`, `Entities/AssessmentManagement/`, `UserManagement/`, `FeatureFlagManagement/`), enums, FluentValidation validators, status transitions (`StatusManagement/`) | nothing |
| Application | `src/Eras.Application` | Use cases (`Features/<Feature>/`), repository and service **interfaces** (`Contracts/`), DTOs (`DTOs/<Area>/`), mappers (`Mappers/`), application validation (`Validation/`), events (`Events/`) | Domain, Eras.Error |
| Infrastructure | `src/Eras.Infrastructure` | `AppDbContext`, EF configurations, persistence entities and joins, repositories, migrations, SQL views, Keycloak/Cosmic Latte clients, file storage, background jobs, authorization policies (`Authorization/ErasPolicies.cs`) | Application, Domain |
| Presentation | `src/Eras.Api` | Controllers, middleware, filters, Swagger, composition root (`Program.cs`) | Application, Infrastructure (only for DI and policies), Eras.Error |
| Errors | `Eras.Error` (repo root) | `ErasException`, `BussinessException`, `NotFoundException`, `CriticalException`, `DatabaseCustomException` | nothing |

### 4.2 Frontend — Angular 19 (`ERAS-FE/`)

| Layer | Path | Owns |
|---|---|---|
| Bootstrap | `src/main.ts`, `src/app/app.config.ts`, `src/app/app.routes.ts` | Providers, Keycloak init, feature-flag loading, top-level lazy routes under the `LayoutComponent` shell |
| Core | `src/app/core/` | Singletons: API services (`services/api/`), auth (`services/access/`, `auth/guards/`), permissions (`services/permissions/`), interceptors, models (`models/<entity>.model.ts`), constants, route metadata (`utils/routing/route-metadata.ts`), layout |
| Feature modules | `src/app/modules/<feature>/` | Feature pages and components (assessments, students, reports, lists, imports, profile, settings, home-v2, …), plus feature-local `models/` and `<feature>.routes.ts` |
| Shared | `src/app/shared/` | Reusable presentational components (`eras-button`, `eras-modal`, `eras-select`, list/table, cards), directives (`*appHasERASRoles`), pipes |
| Styles | `src/styles/utils/` | Material 3 theme, tokens (`--primary-*`, `--color-neutral-*`, `--font-size-*`), partials |

Path aliases: `@core/*`, `@shared/*`, `@modules/*`.

### 4.3 Cross-cutting contracts

| Concern | Backend | Frontend |
|---|---|---|
| Roles (Keycloak client roles) | `ErasRole` (`Domain/Entities/UserManagement`), names from config `Keycloak:RoleNames:*` | `ERASRoles` enum (`core/models/profile.model.ts`), names from `environment.roleNames` |
| Role values | `ERAS Administrator`, `ERAS Student Services Officer`, `ERAS Professional` (plus Guest = no ERAS role). Administrator passes every check | Same values. Per-route access is in `ROUTE_METADATA`, per-endpoint access in `ErasPolicies` and the handlers. Any change to who can do what is an AC |
| API base | `api/v1/<resource>` | `environment.apiUrl + '/api/v1'` (`BaseApiService`) |
| Serialization | `JsonStringEnumConverter` (enums as strings) | String-union types or `enum`s with string values |
| Auth | JWT bearer, Keycloak realm `ERAS`, roles from `resource_access[RolesResource]` | `keycloak-js` + `keycloakHttpInterceptor` adds the bearer token |
| Feature flags | `api/v1/feature-flags`, `FeatureFlagService` | `FeatureFlagsService`, `featureFlagGuard`, `?v1` / `?v2` overrides |

---

## 5. Conventions

### 5.1 Branches, commits and submodules

- Code commits happen **inside** `ERAS-BE/` or `ERAS-FE/`, on a branch in that submodule. Specs are committed in this parent repo.
- After the submodule PR merges, bump the submodule pointer in the parent repo. Never commit a pointer to an unpushed submodule commit.
- Branch names: `<prefix>/<storyNumber>/<storyTitle>`, where prefix is `feature|bugfix|refactor|ci|docs|chore|style|release` (for example `feature/BE608/rejectduplicateconfig`).
- Commit messages follow Conventional Commits (`feat:`, `fix:`, `test:`, `refactor:`, `docs:`, `ci:`, `chore:`). commitlint enforces this in ERAS-FE.

### 5.2 Acceptance Criteria ↔ test mapping (1:1)

- **AC = one `#### Scenario:`** in a change's delta spec, numbered `AC-<n>`. Numbers are unique within the change, stable and never reused.
- Global AC key: **`<change-id>/AC-<n>`**.
- For **each side the AC affects** (BE, FE or both), there is **exactly one** test tagged with that AC key. Each tagged test is tagged with **exactly one** AC key.
- Extra helper or edge-case tests are welcome but carry **no** AC tag.
- A test file lives where the project's tests already live (§6.3, §7.3). Tags are what make the mapping traceable, not file names.
- If a later change MODIFIES a requirement, its new scenario gets that change's AC key, and the existing test is updated and **re-tagged** to it.

### 5.3 Traceability table (required in `tasks.md`)

```markdown
## Traceability
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | Duplicate active name is rejected | BE | test/Eras.Application.Tests/Features/Configurations/CreateConfigurationCommandHandlerTests.cs › HandleAsync_DuplicateActiveName_Throws409AndDoesNotPersistAsync |
| AC-1 | Duplicate active name is rejected | FE | src/app/modules/settings/…/configurations.component.spec.ts › [608-…/AC-1] shows the conflict message… |
| AC-2 | … | BE | … |
```

A change is **not done** until every AC row exists, points to a real test, and that test passes.

---

## 6. Backend

### 6.1 Golden path for a new backend use case

The reference implementation is `Features/RemissionManagement/` together with `Controllers/AssessmentManagement/AssessmentsController.cs`.

1. **Domain.** Add or adjust the entity in `Eras.Domain/Entities/<Area>/`. Put invariants in an `AbstractValidator<T>` under `Validators/` and state changes in `StatusManagement/`.
2. **Contract.** Declare the repository interface in `Eras.Application/Contracts/Persistence/<Area>/I<Name>Repository.cs`.
3. **Request.** Add a `sealed record` to `Features/<Feature>/Commands.cs` or `Queries.cs` that implements `IRequest<TResponse>`.
4. **Handler.** One class per request in `Features/<Feature>/Handlers/<Request>Handler.cs`.
   - Inject `IMapper<TSrc,TDst>`, `IValidator<T>` and the repositories.
   - Return DTOs.
   - Report failures by **throwing** `Eras.Error` exceptions (`NotFoundException`, `BussinessException(msg, statusCode)`).
5. **DTO and mapper.** Put the DTO in `DTOs/<Area>/<Name>Dto.cs` and the mapper in `Mappers/<Area>/` implementing `IMapper<,>`. Register mappers in `ApplicationServiceRegistration`.
6. **Persistence.** Write the repository in `Infrastructure/Persistence/PostgreSQL/Repositories/<Area>/` and the EF configuration in `Configurations/`. Register it in `PersistenceServiceRegistration.cs`. Schema changes require a new migration (§3.2).
7. **Controller.** Keep it thin. Route `api/v1/<kebab-case-resource>`. Use `[Authorize(Policy = ErasPolicies.…)]` on the class or the action. Call `_mediator.Send(request, cancellationToken)` and return `Ok`, `CreatedAtAction` or `NoContent`. Put no business logic here.

### 6.2 Backend rules

- `CancellationToken` flows from the controller action to EF calls. Async methods end in `Async`.
- Use file-scoped namespaces, camelCase parameters and `_camelCase` private fields, Allman braces and 4-space indent. Follow `ERAS-BE/.editorconfig`.
- Inject `ILogger<T>` with the **correct** `T`. Never log tokens, API keys or personal data.
- Authorization uses the role policies in `ErasPolicies` (`RequireErasAdmin`, `RequireErasAdminOrOfficer`, `RequireAnyErasRole`). Ownership and scope rules (for example "a Professional only sees interventions assigned to them") belong in the handler and must be spelled out as ACs.
- Never edit a migration that has been applied. Never hand-edit `AppDbContextModelSnapshot.cs`. SQL views go in `Views/Ups` and `Views/Drops`.
- Secrets come from environment variables or user-secrets, never from committed `appsettings*.json`.
- **Do not copy these legacy patterns into new code:**
  - `BaseResponse` / `CreateCommandResponse<T>` / `Success=false` return values.
  - Static `ToDomain()` / `ToDto()` mappers.
  - DataAnnotations-only validation.
  - Folder-per-use-case `Command/<UseCase>/` layout.
  - Controllers calling application services directly instead of going through MediatR.
  - PascalCase parameters.
  - `try/catch` blocks in controllers.

### 6.3 Backend tests — xUnit (`ERAS-BE/test/`)

| Code under test | Test project |
|---|---|
| Domain validators, transitions | `test/Eras.Domain.Tests/` |
| Handlers, mappers, application services | `test/Eras.Application.Tests/Features/<Feature>/…` |
| Repositories, external clients, jobs | `test/Eras.Infrastructure.Tests/…` |
| Controllers, policies, middleware, filters | `test/Eras.Api.Tests/…` |

Write the test at the layer where the AC's behavior is decided. A business rule is tested in a handler or domain test. A status code or authorization rule is tested in an Api test. Stack: xUnit, Moq, FluentAssertions, EF InMemory/MockQueryable.

```csharp
public class CreateConfigurationCommandHandlerTests
{
    [Fact]
    [Trait("Change", "608-reject-duplicate-configuration-name")]
    [Trait("AC", "608-reject-duplicate-configuration-name/AC-1")]
    public async Task HandleAsync_DuplicateActiveName_Throws409AndDoesNotPersistAsync()
    {
        // Arrange (GIVEN) … Act (WHEN) … Assert (THEN / AND)
    }
}
```

The method name is `<Unit>_<Condition>_<Expected>`. Use Arrange/Act/Assert, mirroring GIVEN/WHEN/THEN.

---

## 7. Frontend

### 7.1 Golden path for a new frontend feature

1. **Route.** Add a lazy route (`loadComponent` or `loadChildren` to `<feature>.routes.ts`).
   - Guard it with `canActivateAuthRole`.
   - Add an entry in `ROUTE_METADATA` with `roles`, `breadcrumb` and `headerTitle`.
   - Put `roles` on the **same** route the guard runs on. Use `canActivateChild` when the roles live on child routes.
   - For v1/v2 rollouts, also add `featureFlagGuard(FEATURE_FLAGS.<flag>)`.
2. **Model.** Add `src/app/core/models/<entity>.model.ts`, one entity per file, mirroring the BE DTO exactly, including enums as string unions.
3. **Service.** Add `src/app/core/services/api/<resource>.service.ts` that `extends BaseApiService` with `protected resource = '<api-resource>'`.
   - Use the base `get/post/put/delete`.
   - Endpoints have no leading slash.
   - Use `@Cacheable()` only for read-mostly lookups.
4. **Component.** Build a standalone component with `ChangeDetectionStrategy.OnPush`.
   - Use `inject()`, signal `input()` / `output()` / `computed()`, and the `@if` / `@for` control flow.
   - Tear down subscriptions with `takeUntilDestroyed()` or `toSignal()`.
   - Use Reactive Forms.
5. **Permissions in the UI.** Use `PermissionsService.can(...)` / `permission.policies.ts` or `*appHasERASRoles`. Never compare raw role strings.
6. **UI.** Use Angular Material and the `eras-*` wrappers. Use SCSS with theme tokens; no hard-coded colors. User-facing text goes in `core/constants/messages.ts`.

### 7.2 Frontend rules

- File names are kebab-case with Angular suffixes (`.component.ts`, `.service.ts`, `.model.ts`, `.guard.ts`, `.routes.ts`). Component selectors use the `app-` prefix.
- `strict` TypeScript and `strictTemplates`. No `any` without a written justification.
- Environment values come from `src/environments/*`. Never hard-code URLs, realms or role names.
- **Do not copy these legacy patterns into new code:**
  - `@Input()` / `@Output()` decorators.
  - Constructor injection.
  - `*ngIf` / `*ngFor`.
  - Manual `.subscribe` without teardown.
  - `HttpClientModule` in tests.
  - Building URLs outside `BaseApiService`.
  - New files in `_unused/`.
  - Non-kebab-case file names.

### 7.3 Frontend tests — Jasmine/Karma (`ERAS-FE/src/app/`)

The spec file sits next to the unit as `*.spec.ts`. Use TestBed, `provideHttpClient()` + `provideHttpClientTesting()` / `HttpTestingController`, and `jasmine.createSpyObj`.

```ts
describe('ConfigurationsComponent', () => {
  it('[608-reject-duplicate-configuration-name/AC-1] shows the conflict message when the name already exists', () => {
    // GIVEN … WHEN … THEN
  });
});
```

The AC key goes **first in the `it()` title, in square brackets**. Write one `it()` per AC; never `fit` or `xit` in commits.

---

## 8. Workflow with agents

### 8.1 STRICT RULE — every change requires a defined spec in `openspec/changes/`

> **No code, migration, configuration or pipeline change is made in `ERAS-BE/`,
> `ERAS-FE/` or the infrastructure files unless an OpenSpec change exists for it in
> `openspec/changes/<change-id>/` and passes `openspec validate <change-id> --strict`.**

This applies to features, bug fixes, refactors, CI and infrastructure. Changes with no behavioral impact (pure refactor, tooling, docs) still need a change folder. They set `skip_specs: true` in `.openspec.yaml` and carry only `proposal.md` and `tasks.md`.

### 8.2 Change folder layout

```
openspec/changes/<change-id>/
├── .openspec.yaml          # created by `openspec new change`
├── proposal.md             # Why · What Changes · Capabilities · Impact (link the GitHub issue)
├── specs/<capability>/spec.md   # delta: ## ADDED | MODIFIED | REMOVED | RENAMED Requirements
├── design.md               # required when the change crosses BE+FE, adds a migration,
│                           #   touches auth, or changes an API contract
└── tasks.md                # checklist + AC→test traceability table (§5.3)
```

- **`<change-id>`** is kebab-case: `<issue-number>-<verb>-<object>`, for example `608-reject-duplicate-configuration-name`.
- **Capabilities** are durable behaviors, not tasks: for example `assessment-management`, `student-import`, `access-control`. Check `openspec list --specs` before inventing a new one.
- **Requirements** use `### Requirement: <name>` with a single SHALL/MUST behavior of 500 characters or fewer. Each one has at least one scenario.
- **Scenarios are the Acceptance Criteria.** Format:

```markdown
#### Scenario: AC-1 Duplicate active name is rejected
- **GIVEN** an officer already owns an active configuration named "Main"
- **WHEN** they create another configuration named "Main"
- **THEN** the API responds 409 Conflict with a friendly message
- **AND** no new configuration is persisted
```

  Scenario headings use exactly 4 `#`. `WHEN` and `THEN` are mandatory.

### 8.3 Workflow

| Step | Who | Action | Gate |
|---|---|---|---|
| 1. Propose | dev / agent | `openspec new change <id>`, then write the proposal, deltas, design and tasks. Architectural decisions in `design.md` get an ADR in `openspec/adr/` (`/sdd-adr`, status `Proposed`) | `openspec validate <id> --strict` passes |
| 2. Approve | human reviewer | Reviews the change and its new ADRs, ideally in a parent-repo PR, and sets the ADRs to `Accepted` | Explicit approval |
| 3. Implement | dev / agent | Work through `tasks.md` in order. AC tests first, then code. Tick tasks as they finish | Tests green |
| 4. Verify | dev / agent | Run all gates (§8.7) and the traceability check (§8.6) | All green, every AC traced |
| 5. Ship | dev | The parent-repo commit/PR carries `openspec/changes/<id>/` **and the change's ADR files**: every ADR it creates or links that is not yet committed, the `openspec/adr/README.md` index, and the Status line of any ADR it supersedes. Submodule PRs (BE and/or FE) link `openspec/changes/<id>`, then bump the parent pointer | CI green, PR approved, `check-adr.sh --change <id>` shows no uncommitted ADR |
| 6. Archive | dev | `openspec archive <id> --yes` merges the deltas into `openspec/specs/` | Done after merge |

**Agent obligations**
- When asked to change code and no matching change exists, **stop**. Draft the OpenSpec change and ask for approval before you touch code.
- If implementation shows the spec is wrong or incomplete, **update the spec first**: edit the delta, re-validate, and flag it to the reviewer. Then continue.
- Never mark a task `[x]` until its tests pass. Never archive a change with open tasks.

### 8.4 SDD skill conventions

The skills `/sdd-spec` → `/sdd-clarify` → `/sdd-plan` → `/sdd-implement` → `/sdd-validate-impl` → `/sdd-verify` (§8.5), plus `/sdd-adr` (called from `/sdd-plan` or on its own), share these conventions. This section is their single source. Only `/sdd-implement` writes code; no skill commits.

| Item | Convention |
|---|---|
| Files | `proposal.md` (why, what, status lines, logs), `specs/<capability>/spec.md` (ACs), `design.md` (**the plan**: layers, API contract, test strategy), `tasks.md` (checklist and Traceability) |
| Status lines | In `proposal.md`: `**Status:** Draft \| Clarified \| Approved` for the spec and `**Plan:** Draft \| Approved` for `design.md` + `tasks.md`. **Only a human sets `Approved`.** Code waits for `Plan: Approved` |
| AC | `#### Scenario: AC-<n> <title>` plus a line `**Side:** BE \| FE \| BE + FE`. Key: `<change-id>/AC-<n>` |
| Tasks | `- [ ] <group>.<n> <description>`. A test task starts with "Write" and cites `(AC-<n>)`, and comes before its implementation task. Replaced tasks are struck through, never renumbered |
| Logs | `## Clarifications` and `## Validation log` live in `proposal.md`. **Never in `spec.md`**: it is a delta that is merged into `openspec/specs/` on archive |
| Done | Every task ticked, Traceability filled with real tests (exactly 1 per AC per side), §8.7 gates green, `openspec validate --strict`; then the parent-repo commit carries the change folder and its ADR files (§8.3 step 5), the submodule PRs merge and the change is archived. There is no separate `Implemented` status |
| ADR | One decision per file in `openspec/adr/NNNN-<kebab-title>.md`, numbered from `0001` with no gaps, never reused. Fields `**Status:**` (`Proposed`, `Accepted`, `Rejected`, `Deprecated`, `Superseded by ADR-NNNN`), `**Date:**`, `**Area:**` (`backend`, `frontend`, `auth`, `data`, `infra`, `process`), `**Change:**`, optional `**Supersedes:**`; sections Context, Decision, Alternatives, Consequences. Index: `openspec/adr/README.md`, grouped by Area |
| ADR use | An ADR is for a decision that outlives its change: a dependency or pattern, an auth/role/ownership model, a data or migration approach, a cross-cutting BE ↔ FE contract, a departure from a golden path (§6.1, §7.1). The `design.md` D-block links it as `**ADR:** ADR-NNNN`. **Only a human sets `Accepted`**, usually with `Plan: Approved`. An Accepted ADR is never rewritten: a new ADR supersedes it, and the old one's Status becomes `Superseded by ADR-MMMM` once the new one is Accepted. `/sdd-verify` requires every linked ADR to be Accepted, and the ADR files ship in the change's commit (§8.3 step 5) |
| Checks | `.claude/skills/sdd-spec/scripts/check-spec.sh`, `sdd-plan/scripts/check-plan.sh`, `sdd-implement/scripts/check-impl.sh`, `sdd-adr/scripts/check-adr.sh`, and `sdd-plan/tests/check-skills.sh` for the skills themselves. Self-test: `bash .claude/skills/sdd-plan/tests/run-tests.sh` |

### 8.5 Slash commands and skills

**Claude Code slash commands** (installed in `.claude/` by `openspec init --tools claude --profile core`):

| Command | Step (§8.3) | What it does |
|---|---|---|
| `/opsx:explore` | before 1 | Think through an idea or investigate code, without writing anything |
| `/opsx:propose "<idea>"` | 1. Propose | Creates the change with proposal, specs, design and tasks, then stops for approval |
| `/opsx:update` | 1–3 | Revises the artifacts of an existing change |
| `/opsx:apply` | 3. Implement | Works through `tasks.md` (only after approval) |
| `/opsx:sync` | 6 | Syncs the delta specs into `openspec/specs/` |
| `/opsx:archive` | 6. Archive | Archives a completed change |

**Project skills** (in `.claude/skills/`, optional spec-first path; conventions in §8.4. Only `/sdd-implement` writes code and none of them commits):

| Command | Step (§8.3) | What it does |
|---|---|---|
| `/sdd-spec "<idea>"` | 1. Propose | Creates or updates the Draft spec (AC scenarios) of a change from an idea, with templates |
| `/sdd-clarify <change-id>` | 1. Propose | Finds gaps in a Draft spec, asks at most 5 questions and records the answers. Then a human reviews and sets `Status: Approved` |
| `/sdd-plan <change-id>` | 1. Propose | For an Approved spec, writes `design.md` (the plan: layers, API contract, test strategy) and `tasks.md` with the traceability table. Then a human sets `Plan: Approved` (step 2) |
| `/sdd-implement <change-id>` | 3. Implement | Works through `tasks.md` in order, test first, one tagged test per AC per side, then runs the §8.7 gates and reports. Needs `Plan: Approved`; never commits |
| `/sdd-validate-impl <change-id>` | 4. Verify | Manual validation gate, only when a BE controller or the FE changed: hands you a checklist per AC, logs the result in `proposal.md` and sends problems back to `/sdd-implement` |
| `/sdd-verify <change-id>` | 4. Verify | Audit: tasks ticked, one tagged test per AC per side, §8.7 gates, linked ADRs Accepted, no drift from the spec and `design.md`. Fills the Traceability table, lists the files the parent-repo commit must carry (change folder and ADRs) and recommends archiving; never archives |
| `/sdd-adr ["<decision>"]` | 1. Propose (or any time) | Writes an ADR in `openspec/adr/` (status `Proposed`) or supersedes one, and updates the index. `/sdd-plan` offers it for architectural decisions; a human sets `Accepted` |

### 8.6 AC traceability check (Git Bash)

For each AC in a change, this lists how many BE and FE tests carry its key. Each side the AC affects must show **exactly 1**.

```bash
CHANGE=<change-id>
for ac in $(grep -rhoE '^#### Scenario: AC-[0-9]+' "openspec/changes/$CHANGE/specs" | awk '{print $3}' | sort -uV); do
  key="$CHANGE/$ac"
  be=$(grep -rF "[Trait(\"AC\", \"$key\")]" ERAS-BE/test --include=*.cs | wc -l)
  fe=$(grep -rF "'[$key]" ERAS-FE/src/app --include=*.spec.ts | wc -l)
  echo "$key  BE=$be  FE=$fe"
done
```

### 8.7 Definition of Done (checklist)

- [ ] `openspec validate <change-id> --strict` passes
- [ ] Every task in `tasks.md` is checked, and the traceability table is complete
- [ ] AC traceability check (§8.6) shows exactly 1 test per AC per affected side
- [ ] BE: build with `-warnaserror`, `dotnet format --verify-no-changes` and `dotnet test` all green, coverage ≥ 25%
- [ ] FE: `npm run lint` and the headless `npm test` green, coverage ≥ 15%, `npm run build` OK
- [ ] Every ADR the change links is `Accepted`, and the parent-repo commit carries the change folder and its ADR files (§8.3 step 5)
- [ ] Submodule PRs link the change. After merge, the parent pointer is bumped and the change is archived

---

## 9. Limits

Hard limits for every contributor, human or agent. Each one restates a rule from the sections above.

- **No code without an approved change.** Nothing changes in `ERAS-BE/`, `ERAS-FE/` or the infrastructure files without an OpenSpec change that passes `openspec validate --strict` and is approved (§8.1, §8.3).
- **Only a human approves.** Only a human sets `**Status:** Approved`, `**Plan:** Approved` and an ADR's `Accepted` (§8.4).
- **Never commit or push unless asked.** No skill commits. Never commit a submodule pointer to an unpushed commit (§5.1).
- **Secrets stay out.** Never read, print or commit `.env`, `deploy/.env.prod`, `environment.development.ts` or the encryption keys in `appsettings*.json`. Secrets come from environment variables or user-secrets (§1.1 principle 8, §6.2).
- **Never leak internals.** No stack traces or internals to clients; never log tokens, API keys or personal data (§1.1 principle 8, §6.2).
- **Migrations are append-only.** Never edit an applied migration; never hand-edit `AppDbContextModelSnapshot.cs` (§6.2).
- **Stay in scope.** No speculative features, no "while I'm here" edits, no refactor of legacy code outside the change's scope; out-of-scope findings go under *Follow-ups* in `design.md` (§1.1 principles 6–7).
- **No legacy patterns in new code** (§6.2, §7.2).
- **No green, no done.** Never tick a task before its tests pass, never archive a change with open tasks, never commit `fit` or `xit`, and never claim a gate passed without running it (§7.3, §8.3, §8.7).
- **Accepted ADRs are not rewritten.** A changed decision is a new ADR that supersedes the old one (§8.4).
