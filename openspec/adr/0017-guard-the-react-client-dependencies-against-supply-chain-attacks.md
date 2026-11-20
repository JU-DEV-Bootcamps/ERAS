# ADR-0017: Guard the React client's dependencies against supply-chain attacks

**Status:** Accepted
**Date:** 2026-11-20
**Area:** frontend, infra
**Change:** none
**Reviewed by:** richardecos-dev (2026-11-20)
**Signed by:** richardecos-dev (2026-11-20)

## Context

npm packages have been hijacked and republished with malicious code, sometimes with valid provenance attestations, so checking a signature alone does not catch them. v3 (`ERAS-FE-React`) already pins every dependency to an exact version (`.npmrc` has `save-exact=true`, ADR-0012), commits `package-lock.json`, and its pull request workflow installs with `npm ci` (`.github/workflows/pr_workflow.yaml`), although that workflow has not run yet because the repository has no remote. Nothing yet delays the adoption of a new version, audits the dependencies, pins the GitHub Actions the workflow uses (`actions/checkout@v4`, `actions/setup-node@v4` are movable tags) or keeps install scripts (`postinstall`, a common attack path) out of CI. The project already rejected Orval partly for its supply-chain cost (ADR-0014). This decision applies to every v3 dependency and workflow and changes nothing in `ERAS-FE` or `ERAS-BE`.

## Decision

Every dependency of v3, direct or development, follows these rules:

- **Exact versions and the lockfile** stay as they are: `save-exact=true`, no ranges in `package.json`, `package-lock.json` committed and changed only by an install.
- **A version is adopted only when it has been published for at least 7 days.** A fix for a known vulnerability may be adopted earlier, after a reviewer reads its release notes and diff.
- **CI installs with `npm ci --ignore-scripts`**, so no dependency runs install scripts there; local installs keep scripts so that husky installs the git hooks.
- **`npm audit --audit-level=high` is a blocking gate** of the pull request workflow: a high or critical advisory fails it until it is fixed or explicitly accepted in the pull request.
- **GitHub Actions are pinned to a full commit SHA**, with the version in a comment, never to a movable tag.
- **Dependabot proposes the updates** once the repository has its remote, for npm and for GitHub Actions, configured to keep the noise low:
  - a **weekly** schedule against `develop`, with a `cooldown` of 7 days;
  - **one grouped pull request** per ecosystem for all minor and patch updates; each major update comes in its own pull request, because it may break the API;
  - at most **5 open** update pull requests at a time;
  - commit messages with the Conventional Commits prefix `chore(deps)`, as the rest of the repository.
- **No update is merged automatically.** Every update pull request runs all the gates, and a developer reads its release notes and approves it; a major update also gets a manual check of the screens it touches.
- **The pull request workflow cancels a run that a newer push to the same pull request replaces** (a `concurrency` group with `cancel-in-progress`), so a rebased update pull request does not run twice.

## Alternatives

- Socket instead of, or next to, `npm audit` → it also flags suspicious package behavior, but needs a third-party GitHub app; `npm audit` comes with npm and needs no account.
- Renovate instead of Dependabot → more configurable, but it is an external app; Dependabot is built into GitHub and its `cooldown` covers the waiting rule.
- Manual updates with no bot → updates depend on someone remembering, and fixes arrive late.
- `ignore-scripts=true` for every install, also locally → husky no longer installs the hooks on `npm ci`, every developer must activate them by hand, and any dependency that needs its script breaks silently.
- Adopting a new version as soon as it is published → leaves no time for the community to detect a malicious release.
- Relying on provenance attestations → malicious versions have carried valid attestations.
- Dependabot with its default settings (one pull request per dependency, daily) → many pull requests and many CI runs each week, which teams end up ignoring.
- Merging update pull requests automatically when CI passes → v3's coverage gate is 15% of lines, so a green run does not prove that a screen still works.

## Consequences

- Updates arrive at least a week later, except reviewed security fixes.
- Known vulnerabilities still surface quickly: `npm audit` fails the next pull request that runs, independent of the weekly schedule.
- Noise and CI cost stay bounded: about two grouped update pull requests a week (npm and Actions) plus the occasional major, each one a full run of the gates (about 15 minutes at most, the workflow's timeout).
- The update pull requests are only as safe as the tests: the AC tests with MSW and the gates are what make a green run meaningful, so coverage of `src/core/` and of each ported module matters more than the 15% floor.
- One more blocking gate (`npm audit`); a reported advisory with no fix needs a written decision in the pull request.
- The change that applies this policy (in `ERAS-FE-React`: `pr_workflow.yaml`, `.github/dependabot.yml` and its `AGENTS.md`; branch protection on `develop` that requires the gates and one approval is a GitHub setting outside the repository) must check that lint, typecheck, test and build still pass with `npm ci --ignore-scripts`; the Dependabot file only takes effect once the remote exists.
- Pinning Actions by SHA makes them harder to read; the version comment and Dependabot keep them current.
- The 7-day rule also applies to dependencies added by hand, so whoever installs a library (MUI, Zod, a lint plugin) checks its publication date.
