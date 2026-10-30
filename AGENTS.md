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
| `AGENTS.md` (this file) | The shared rules: principles, conventions, workflow, limits. Backend and frontend rules are in `ERAS-BE/AGENTS.md` and `ERAS-FE/AGENTS.md` (ADR-0005) |
| `CLAUDE.md` | Claude Code specifics only; it imports this file |
| `README.md` | Onboarding: what ERAS is, how to set up and run it |
| `openspec/config.yaml` | The rules OpenSpec injects into its artifacts (AC format, traceability table, design triggers) |
| `openspec/specs/` | Current behavior of the system (principle 2) |
| `openspec/changes/<change-id>/` | What a change adds or modifies, and its plan and tasks (§8.2) |
| `openspec/adr/` | Durable architectural decisions that later changes must respect (§8.4); `SUMMARY.md` lists the rules in force |
| `openspec/sdd-conventions.md` | The conventions shared by the `/sdd-*` skills and the full command and skill table (§8.4, §8.5) |
| `openspec/roadmap.md` | Options and criteria for changing tools (CI/CD, hosting, identity, secrets) and how confidential data is protected; it adopts no tool |
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

The backend commands live in `ERAS-BE/AGENTS.md` §3.2. Read that file before working in `ERAS-BE/`.

### 3.3 Frontend (`ERAS-FE/`)

The frontend commands live in `ERAS-FE/AGENTS.md` §3.3. Read that file before working in `ERAS-FE/`.

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

The backend architecture (Onion layers and their rules) live in `ERAS-BE/AGENTS.md` §4.1. Read that file before working in `ERAS-BE/`.

### 4.2 Frontend — Angular 19 (`ERAS-FE/`)

The frontend architecture (layers and paths) live in `ERAS-FE/AGENTS.md` §4.2. Read that file before working in `ERAS-FE/`.

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

The golden path for a new backend use case live in `ERAS-BE/AGENTS.md` §6.1. Read that file before working in `ERAS-BE/`.

### 6.2 Backend rules

The backend rules live in `ERAS-BE/AGENTS.md` §6.2. Read that file before working in `ERAS-BE/`.

### 6.3 Backend tests — xUnit (`ERAS-BE/test/`)

The backend test conventions live in `ERAS-BE/AGENTS.md` §6.3. Read that file before working in `ERAS-BE/`.

---

## 7. Frontend

### 7.1 Golden path for a new frontend feature

The golden path for a new frontend feature live in `ERAS-FE/AGENTS.md` §7.1. Read that file before working in `ERAS-FE/`.

### 7.2 Frontend rules

The frontend rules live in `ERAS-FE/AGENTS.md` §7.2. Read that file before working in `ERAS-FE/`.

### 7.3 Frontend tests — Jasmine/Karma (`ERAS-FE/src/app/`)

The frontend test conventions live in `ERAS-FE/AGENTS.md` §7.3. Read that file before working in `ERAS-FE/`.

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

**Who is in charge:** 🟦 human · 🟩 AI agent · 🟨 shared (the agent drafts or runs, a human decides). Only a human approves.

| Step | Who | Action | Gate |
|---|---|---|---|
| 1. Propose | 🟨 dev + agent | `openspec new change <id>`, then write the proposal, deltas, design and tasks. Architectural decisions in `design.md` get an ADR in `openspec/adr/` (`/sdd-adr`, status `Proposed`) | `openspec validate <id> --strict` passes |
| 2. Approve | 🟦 human reviewer | Reviews the change and its new ADRs, ideally in a parent-repo PR, and sets the ADRs to `Accepted` | Explicit approval |
| 3. Implement | 🟩 agent (dev reviews) | Work through `tasks.md` in order. AC tests first, then code. Tick tasks as they finish | Tests green |
| 4. Verify | 🟩 agent (🟦 dev for the manual validation) | Run all gates (§8.7) and the traceability check (§8.6) | All green, every AC traced |
| 5. Ship | 🟦 dev | The parent-repo commit/PR carries `openspec/changes/<id>/` **and the change's ADR files**: every ADR it creates or links that is not yet committed, the `openspec/adr/README.md` index, and the Status line of any ADR it supersedes. Submodule PRs (BE and/or FE) link `openspec/changes/<id>`, then bump the parent pointer | CI green, PR approved, `check-adr.sh --change <id>` shows no uncommitted ADR |
| 6. Archive | 🟨 dev + agent | After the ship PR is approved and the submodule PRs are merged, `/sdd-archive <id>` runs `openspec archive <id> --yes` (`--skip-specs` for a `skip_specs` change), which merges the deltas into `openspec/specs/`. The archive is the **last commit of the ship PR, before it merges**; there is no separate archive PR. For a `skip_specs` change with no submodule work, the ship PR is the change's own PR | `check-archive.sh <id>` passes, `openspec validate --all --strict` passes, then the ship PR merges |

**Agent obligations**
- When asked to change code and no matching change exists, **stop**. Draft the OpenSpec change and ask for approval before you touch code.
- If implementation shows the spec is wrong or incomplete, **update the spec first**: edit the delta, re-validate, and flag it to the reviewer. Then continue.
- Never mark a task `[x]` until its tests pass. Never archive a change with open tasks.

### 8.4 SDD skill conventions

The skills `/sdd-spec` → `/sdd-clarify` → `/sdd-plan` → `/sdd-implement` → `/sdd-validate-impl` → `/sdd-verify` → `/sdd-archive` (§8.5), plus `/sdd-adr`, share the conventions in [`openspec/sdd-conventions.md`](openspec/sdd-conventions.md): files, status lines, AC and task formats, logs, definition of done, ADR fields and use, checks and skill model. Read it when you run or change a skill. Three rules apply to everyone:

- **Only a human sets `Approved`** (`**Status:**` of a spec, `**Plan:**` of the plan) **and `Accepted`** (an ADR, after the review and sign-off in `openspec/adr/README.md`). Code waits for `Plan: Approved`.
- **Only `/sdd-implement` writes code, and no skill commits.**
- **Done** means every task ticked, Traceability filled with real tests (exactly 1 per AC per side), §8.7 gates green, `openspec validate --strict`, the change folder and its ADR files in the parent-repo commit (§8.3 step 5), and the change archived as the last commit of the ship PR (§8.3 step 6).

### 8.5 Slash commands and skills

Full table with what each one does: [`openspec/sdd-conventions.md`](openspec/sdd-conventions.md). Markers as in §8.3.

| Command | Who | Step (§8.3) |
|---|---|---|
| `/opsx:explore` | 🟨 | before 1 |
| `/opsx:propose "<idea>"` | 🟨 | 1. Propose |
| `/opsx:update` | 🟨 | 1–3 |
| `/opsx:apply` | 🟩 | 3. Implement |
| `/opsx:sync` | 🟩 | 6 |
| `/opsx:archive` | 🟨 | 6. Archive |
| `/sdd-spec "<idea>"` | 🟨 | 1. Propose |
| `/sdd-clarify <change-id>` | 🟨 | 1. Propose |
| `/sdd-plan <change-id>` | 🟨 | 1. Propose |
| `/sdd-implement <change-id>` | 🟩 | 3. Implement |
| `/sdd-validate-impl <change-id>` | 🟨 | 4. Verify |
| `/sdd-verify <change-id>` | 🟩 | 4. Verify |
| `/sdd-archive <change-id>` | 🟨 | 6. Archive |
| `/sdd-adr ["<decision>"]` | 🟨 | 1. Propose (or any time) |

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
- [ ] Submodule PRs link the change and are merged, and the ship PR bumps the parent pointer to the merged commits
- [ ] The change is archived (`/sdd-archive`) as the last commit of the ship PR, after its approval and before it merges

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
