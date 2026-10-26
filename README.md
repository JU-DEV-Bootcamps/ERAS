# ERAS — Early Risk Assistance Solution

ERAS is a Jala University platform for detecting and following up on student risk.
This repository is the **parent repo**: it holds the specs, the local stack and the deploy files, and it
pulls in the backend and frontend as git submodules.

> **Rule number one:** this project uses Spec-Driven Development (SDD). No code change is made without
> an approved spec. Read [Spec-Driven Development](#spec-driven-development-sdd-with-openspec) before your first change.

## Contents

- [Repository map](#repository-map)
- [Tech stack](#tech-stack)
- [Getting started](#getting-started)
- [Working with submodules](#working-with-submodules)
- [Working with Spec-Driven Development (SDD)](#spec-driven-development-sdd)
- [Branches and commits](#branches-and-commits)
- [Quality gates](#quality-gates)
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

For the layer rules and the "golden path" for new backend and frontend code, see [AGENTS.md §2](AGENTS.md).
The system design diagrams are in the wiki: [C4 Model](https://github.com/JU-DEV-Bootcamps/ERAS/wiki/C4-Model).

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

Also required: every task in `tasks.md` is checked, the traceability table is complete with exactly one tagged
test per AC per affected side (the check script is in [AGENTS.md §5.4](AGENTS.md)), and the CI coverage gates
hold (backend 25% lines, frontend 15%). The skills ship their own checks, for example
`bash .claude/skills/sdd-plan/tests/run-tests.sh` to self-test them.

## More documentation

- [AGENTS.md](AGENTS.md): engineering guide and rules
- [Wiki](https://github.com/JU-DEV-Bootcamps/ERAS/wiki): research, C4 diagrams, submodule manual
- [User manual (Spanish)](docs/manual-usuario-eras.md)
- `openspec/specs/`: the current behavior of the system
