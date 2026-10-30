# Infrastructure and data-protection roadmap

**Status:** Draft. This document records options and evaluation criteria. It adopts no tool, changes no
pipeline and moves no secret; a decision to adopt a tool is an ADR (`/sdd-adr`) and a change under
`openspec/changes/` (AGENTS.md §8.1). Origin: issue ERAS#652, change `652-improve-sdd`.

Facts below come from the repository files, by name only. They contain no secret value, private host or key, and
neither may any edit of this file (AGENTS.md §9, "Secrets stay out").

## 1. Tools by concern

| Concern | Today (from the repo) | Options to evaluate if we move | Notes |
|---|---|---|---|
| Source hosting and review | GitHub: parent repo plus the `ERAS-BE` and `ERAS-FE` submodule repos, PR review | Azure DevOps Repos, GitLab | Submodules point at separate repositories: any move must move all three and keep the pointer rules (AGENTS.md §5.1) |
| CI/CD | GitHub Actions: `.github/workflows/` (stage deploy, automatic deploy, runner deploy) and `.github/workflows/` inside `ERAS-BE/` and `ERAS-FE/` (PR, push, test and package); one workflow uses a self-hosted runner | Azure Pipelines, GitLab CI | Pipelines are YAML; the actions used (`checkout`, `setup-dotnet`, `setup-node`, `upload-artifact`, Docker build/push and login) need equivalents |
| Build and runtime | Docker images, `docker-compose.yml`, `docker-compose.local.yml`, `deploy/compose.prod.yml`, nginx configs in `nginx/` and `deploy/` | Container registry and orchestrator of the target platform | `deploy/*.sh` drive the deploy and dispatch workflows; they depend on the CI tool's API |
| Identity | Keycloak realm `ERAS`, seeded from `Keycloak/realm-export.json` | Keep Keycloak, or an enterprise identity provider | Role names are a contract (AGENTS.md §4.3); any move keeps them |
| Secrets | Environment variables and user-secrets; `.env.sample` documents the names (AGENTS.md §6.2) | CI-native secret store, a managed vault | See section 3 |
| Quality gates | `dotnet` build, format and test, `npm` lint, test and build, `openspec validate`; commit hooks (husky, commitlint) in `ERAS-FE` | Same commands on any CI | The gates are tool-neutral by design; keep them that way |
| Observability | Not described in the repo | Decide when needed | Out of scope until a requirement exists |

## 2. Evaluating a replacement

Score each candidate against these criteria and record the result in an ADR before any migration starts.

1. **Gates and workflow parity:** can it run every gate of AGENTS.md §8.7 and the `/sdd-*` checks unchanged?
2. **Submodule and monorepo support:** checkout with submodules, one PR across parent and submodules, pointer bumps.
3. **Review and branch policy:** required reviewers, status checks and protected branches equal to today's.
4. **Secrets and access:** where secrets live, who can read them, audit trail, rotation (see section 3).
5. **Data location and third parties:** where code, specs and logs are stored and processed, and whether any agent or
   service sends them outside the organization.
6. **Cost, licensing and runner model:** hosted versus self-hosted runners, limits on minutes and storage.
7. **Migration effort and rollback:** how long both systems run in parallel and how to go back.
8. **Team skills and support:** who maintains it.

### Worked example: GitHub to Azure DevOps (for CI/CD and source hosting)

Checklist, in order; each item is its own change when it touches files:

- [ ] Inventory every workflow, action, runner and secret used today (section 1) and map each to a pipeline task or step.
- [ ] Recreate the quality gates as pipelines and prove they give the same results on the same commit.
- [ ] Move or mirror the three repositories, keeping the submodule URLs and the parent pointers consistent.
- [ ] Recreate branch policies: required reviews, required checks, no direct pushes to the protected branches.
- [ ] Recreate the secret store, rotate every secret at the cutover (never copy a value through a chat, a ticket or a file in the repo), and remove the old store.
- [ ] Re-point the deploy scripts in `deploy/` that call the CI tool, and the commit hooks and PR templates that mention it.
- [ ] Update AGENTS.md (§3, §5.1, §8.3, §9), the ADR for the decision and the skills that name GitHub or `gh`, in the same change.
- [ ] Run both systems in parallel for a release, then archive the old pipelines read-only.

## 3. Confidential data

| Class | Examples in ERAS | Where it may live | Where it must never be |
|---|---|---|---|
| Secrets | Database password, Keycloak client secrets, encryption keys, API keys, tokens | Environment variables, user-secrets, the CI secret store | Source files, `appsettings*.json`, `.env` files in git, chat, tickets, logs, test fixtures |
| Personal data | Student and assessment records, names, results, imported files | The application database and its backups, access-controlled | Source files, specs, ADRs, logs, screenshots shared outside the team, AI prompts |
| Intellectual property | Source code, specs, ADRs, designs | The organization's repositories and its approved tools | Personal accounts, public gists, unapproved third-party services |

Rules (they restate AGENTS.md §1.1 principle 8, §6.2 and §9; this table adds nothing new to them):

1. **No secret in the repository.** Secrets come from environment variables or user-secrets; `.env.sample` lists names only. A secret that reaches git is treated as leaked and rotated.
2. **Least privilege.** Each secret is readable only by the process and the people that need it; CI secrets are scoped to the pipelines that use them.
3. **Rotation.** Rotate on a leak, when someone with access leaves, and at any tool migration (section 2).
4. **Scan before it ships.** Prefer push protection and secret scanning on every repository; evaluate the options in section 1 on this criterion.
5. **AI agents.** Agents never read or print `.env`, `deploy/.env.prod`, `environment.development.ts` or the keys in `appsettings*.json` (CLAUDE.md, AGENTS.md §9), and never put tokens or personal data in logs or tests. Before adopting a tool that sends repository content to a third party, check section 2 criterion 5.
6. **Backups and exports** (database dumps, uploads archives) are personal data: keep them out of the working tree and out of git.

Open items to decide when this roadmap is promoted from Draft: who owns the secret store, the rotation calendar, and which scanning tool the team adopts.
