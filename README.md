# ERAS — Early Risk Assistance Solution

ERAS is a Jala University platform for detecting and following up on student risk.
This repository is the **parent repo**: it holds the specs, the local stack and the deploy files, and it
pulls in the backend and frontend as git submodules.

> **Rule number one:** this project uses Spec-Driven Development (SDD). No code change is made without
> an approved spec. Read [Spec-Driven Development](#spec-driven-development-sdd) before your first change.

## Contents

- [Repository map](#repository-map)
- [Tech stack](#tech-stack)
- [Architecture](#architecture)
- [ERAS roles](#eras-roles)
- [Getting started](#getting-started)
- [Working with submodules](#working-with-submodules)
- [Spec Driven Development (SDD)](#spec-driven-development-sdd)
- [Working with AI agents (Claude Code)](#working-with-ai-agents-claude-code)
- [New QA members](#new-qa-members)
- [Testing](#testing)
- [Branches and commits](#branches-and-commits)
- [More documentation](#more-documentation)

## Repository map

| Path | What it is |
|---|---|
| `ERAS-BE/` | **Git submodule.** Backend: .NET 8, Onion Architecture, EF Core + PostgreSQL, MediatR, Keycloak JWT. Solution: `ERAS-BE/Eras.sln` |
| `ERAS-FE/` | **Git submodule.** Frontend: Angular 19 (standalone components), Angular Material |
| `openspec/specs/` | Living specs: the current, agreed behavior of the system, grouped by capability |
| `openspec/changes/` | Proposed or in-progress changes (proposal, spec deltas, design, tasks). Finished ones go to `archive/` |
| `Keycloak/` | Local realm `ERAS` export: clients, roles, seed users |
| `docker-compose.yml`, `docker-compose.local.yml` | Local stack: backend, frontend, PostgreSQL, Keycloak |
| `deploy/`, `nginx/`, `.github/workflows/` | Production compose, nginx configs and deploy pipelines |
| `docs/` | Extra documentation |
| `AGENTS.md` | **The engineering guide.** Architecture, rules, spec workflow and commands for every contributor, human or AI |
| `CLAUDE.md`, `.claude/` | Claude Code instructions, slash commands and skills (see [AI agents](#working-with-ai-agents-claude-code)) |

## Tech stack

For the reasoning behind these choices, see [Tool researchs and proposals](https://github.com/JU-DEV-Bootcamps/ERAS/wiki/Researchs).
Designs live in [Figma](https://www.figma.com/).

| Area | Technology |
|---|---|
| Backend | [ASP.NET 8](https://dotnet.microsoft.com/apps/aspnet), Onion Architecture, [EF Core](https://learn.microsoft.com/ef/core/) with PostgreSQL, MediatR (CQRS) |
| Frontend | [Angular 19](https://angular.dev/), [Angular Material](https://material.angular.io/), ApexCharts |
| Auth | [Keycloak](https://www.keycloak.org/) (realm `ERAS`), JWT bearer |
| Testing | Backend: xUnit, Moq, FluentAssertions. Frontend: Karma + Jasmine. API: [Postman](https://www.postman.com/) |
| DevOps | Docker and Docker Compose, GitHub Actions (`.github/workflows/`) |
| Frontend tooling | ESLint, Prettier, Husky git hooks, commitlint |

## Architecture

The backend follows an Onion Architecture with dependencies pointing inward: `Eras.Domain` (entities, validators,
status transitions) is at the core, then `Eras.Application` (CQRS use cases with MediatR, DTOs, repository interfaces),
`Eras.Infrastructure` (EF Core and PostgreSQL, Keycloak clients, background jobs) and `Eras.Api` (thin controllers
and composition root). The Angular frontend talks to the API under `api/v1/` and signs users in through Keycloak.
The layer rules and the "golden path" for new code are in [AGENTS.md §4, §6 and §7](AGENTS.md), and the diagrams are in the wiki:
[C4 Model](https://github.com/JU-DEV-Bootcamps/ERAS/wiki/C4-Model).

## ERAS roles

Access is controlled by Keycloak client roles in the `ERAS` realm. The backend enforces them with the policies in
`ErasPolicies` and in the handlers, and the frontend with `ROUTE_METADATA` and the permissions service.

| Role | Notes |
|---|---|
| `ERAS Administrator` | Passes every access check |
| `ERAS Student Services Officer` | Staff role; access is defined per endpoint and route |
| `ERAS Professional` | Scoped access, for example only the interventions assigned to them |
| Guest | A signed-in user with no ERAS role |

Any change to who can do what must be written as an Acceptance Criterion in a spec.

## Getting started

### Prerequisites

- Git
- Docker with Docker Compose in WSL
- To work on the backend outside Docker: the .NET 8 SDK
- To work on the frontend outside Docker: Node.js and npm
- To follow the spec workflow: the [OpenSpec CLI](https://github.com/Fission-AI/OpenSpec) (`openspec`)

### 1. Clone the repository with its submodules

```bash
git clone --recurse-submodules https://github.com/JU-DEV-Bootcamps/ERAS.git
cd ERAS
```

You can also clone over SSH. If you already cloned without submodules, run:

```bash
git submodule update --init --recursive
```

### 2. Set up environment variables

```bash
cp .env.sample .env
```

Edit `.env` if needed: ports and the `POSTGRES_*` database settings (set `POSTGRES_PASSWORD`).

> **Never commit `.env`.** Use `.env.sample` as the reference for the variables the stack needs.

### 3. Run the stack

```bash
docker compose up --build
```

If you use WSL or need host networking, use the local variant instead:

```bash
docker compose -f docker-compose.local.yml up --build
```

### 4. Open the application

| Service | URL |
|---|---|
| Frontend | http://localhost:4200 |
| Backend | http://localhost/swagger/index.html |
| Keycloak | http://localhost:18080 |
| PostgreSQL | - |

Ports come from your `.env`, so they may differ if you changed them.

### 5. Keep your submodules in sync

After you pull the parent repo, move the submodules to the commits it points to:

```bash
git pull
git submodule update --init --recursive
```

Only maintainers who are bumping a submodule pointer should use `git submodule update --remote`.

## Working with submodules

`ERAS-BE` and `ERAS-FE` are independent repositories, so **code and specs are committed in different places**:

- **Code** is committed inside `ERAS-BE/` or `ERAS-FE/`, on a branch of that submodule, and merged through that submodule's pull request.
- **Specs** (`openspec/`) and infrastructure files are committed in this parent repo.
- After a submodule PR merges, bump the submodule pointer in the parent repo.
  **Never commit a pointer to a submodule commit that is not pushed.**

A quick manual is in the wiki: [Submodules Git manual](https://github.com/JU-DEV-Bootcamps/ERAS/wiki/Submodules-Git-manual).

## Spec Driven Development SDD

You can see the full documentation here: [Spec Driven Development in ERAS](https://github.com/JU-DEV-Bootcamps/ERAS/wiki/Spec-Driven-Development-In-ERAS)

## Working with AI agents (Claude Code)

AI agents follow the same rules as everyone else: [AGENTS.md](AGENTS.md) is the single rulebook and
[CLAUDE.md](CLAUDE.md) adds Claude Code specifics. The `/sdd-*` skills in `.claude/skills/` guide the spec-first
pipeline (spec, clarify, plan, implement, validate, verify) while OpenSpec stores the change and validates it, so skills
do not replace OpenSpec. An agent never edits `ERAS-BE/` or `ERAS-FE/` until a human has approved the spec and the plan,
and it never commits or pushes unless you ask.

## New QA members

If you are joining the team as a QA engineer, start here: [QE Onboarding – Home](https://github.com/JU-DEV-Bootcamps/ERAS/wiki/QE-Onboarding-%E2%80%93-Home)

## Testing

Backend (xUnit), from `ERAS-BE/`:

```bash
dotnet test
```

Frontend (Karma + Jasmine), from `ERAS-FE/`:

```bash
ng test --code-coverage --watch=false --browsers=ChromeHeadless
```

CI requires at least 25% line coverage on the backend and 15% on the frontend. Each Acceptance Criterion has exactly one
tagged test per affected side; see [AGENTS.md §5.2, §6.3 and §7.3](AGENTS.md) for the tags, and §3 for how to run a single AC.

## Branches and commits

We use feature branching inside each submodule, plus release branches on demand.

```text
<prefix>/<storyNumber>/<storyTitle>

prefix      = feature | bugfix | refactor | ci | docs | chore | style | release
storyNumber = the issue, shortened: "ERAS-BE #13" becomes BE13
storyTitle  = verb + object, no separators: importcosmic

example: feature/BE608/rejectduplicateconfig
```

Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `test:`,
`refactor:`, `docs:`, `ci:`, `chore:`. In `ERAS-FE`, commitlint and Husky hooks enforce this.

## More documentation

- [AGENTS.md](AGENTS.md): engineering guide and rules
- [Wiki](https://github.com/JU-DEV-Bootcamps/ERAS/wiki): research, C4 diagrams, submodule manual
- [User manual (Spanish)](docs/manual-usuario-eras.md)
- `openspec/specs/`: the current behavior of the system
