# Proposal

**Status:** Approved

## Why

ADR-0017 (Accepted 2026-11-20) sets the dependency policy of ERAS v3 against supply-chain attacks, but nothing in `ERAS-FE-React` applies it yet:
- its pull request workflow installs with scripts enabled and has no audit;
- it uses movable tags for its GitHub Actions;
- it has no Dependabot configuration;
- its `AGENTS.md` does not state the 7-day rule.

This must be in place before the first module port (change `0008`) installs new libraries such as MUI and Zod. Issue: none (placeholder `0009`; rename the folder when an issue exists, before approval).

## What Changes

- **`ERAS-FE-React/.github/workflows/pr_workflow.yaml`:**
  - A `concurrency` group with `cancel-in-progress: true`, so a newer push to the same pull request cancels the older run.
  - `npm ci --ignore-scripts` instead of `npm ci`.
  - A new blocking step `npm audit --audit-level=high`, after the install.
  - `actions/checkout` and `actions/setup-node` pinned to the full commit SHA of the release they use today (`v4`), with the version in a comment.
- **`ERAS-FE-React/.github/dependabot.yml` (new):**
  - Two ecosystems, `npm` and `github-actions`.
  - A weekly schedule against `develop`, with a `cooldown` of 7 days.
  - One grouped pull request for minor and patch updates; each major update in its own pull request.
  - At most 5 open update pull requests for npm.
  - Commit prefix `chore(deps)` and the label `dependencies`.
  - It takes effect only once the repository has its GitHub remote.
- **`ERAS-FE-React/AGENTS.md`:**
  - §7.2 states the rules a contributor follows by hand: a version is adopted only after 7 days, except a reviewed security fix, and no update is merged without review. It points to ADR-0017.
  - §3.3 lists `npm audit --audit-level=high` among the commands.

**Out of scope:**
- Branch protection on `develop`, which is a GitHub setting once the remote exists.
- Creating the remote.
- Any dependency update or new dependency.
- Any change to `ERAS-FE`, `ERAS-BE` or the parent's workflows.

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Sides / submodules:**
  - `ERAS-FE-React`, on its own branch `ci/0009/dependency-policy` from `develop`. The work is kept apart from the Home branch `feature/0008/home`, and the hook maps the branch to this change.
  - The parent repository: only this change folder.
  - `ERAS-BE` and `ERAS-FE` are not touched.
- **Roles / who can do what:** no change for ERAS users. For contributors, a pull request with a high or critical advisory no longer passes CI.
- **API contract:** none.
- **Data / migration:** none.
- **Risk (low):**
  - *A dependency needs its install script in CI:* task 1 runs the four gates after `npm ci --ignore-scripts` before anything else changes.
  - *An existing advisory makes the new audit gate fail:* task 1 runs `npm audit --audit-level=high` first. If it reports anything, the work stops and the user decides, because fixing it means updating a dependency, which is outside this change.
  - *The workflow is not run here:* it has no remote yet, so it is checked by reading it and by running its commands locally.
- **Rollback:** one commit in `ERAS-FE-React`, revertible on its own.

No behavior of ERAS changes, so this change sets `skip_specs: true` (AGENTS.md section 8.1, CI and tooling).

## Decisions

**Task 1, baseline (2026-11-20, `ERAS-FE-React` on `ci/0009/dependency-policy` from `develop` at `3f1d65e`):**
- `npm audit --audit-level=high`: 0 vulnerabilities, so the new gate starts green.
- `npm ci --ignore-scripts` then `npm run lint`, `typecheck`, `test:ci` (7 files, 37 tests) and `build`: all exit 0, so no dependency needs its install script for the gates. `npm ci` was then run again, and husky's `core.hooksPath` (`.husky/_`) is in place.
- The first attempt failed with `EPERM` on `@rolldown/binding-win32-x64-msvc`, because the user's `npm run dev` held that binary; it passed once the dev server was stopped.

**Task 2, workflow:** `actions/checkout@11d5960a326750d5838078e36cf38b85af677262` (v4.4.0, published 2026-07-20) and `actions/setup-node@49933ea5288caeca8642d1e84afbd3f7d6820020` (v4.4.0, published 2025-04-14), read with `gh api repos/<action>/commits/v4`. Both are older than 7 days. The `concurrency` group is `pr-<pull request number>`, with `github.ref` as the fallback for `workflow_dispatch`.

**Task 3, Dependabot (checked against GitHub's Dependabot options reference, 2026-11-20):**
- `cooldown` applies only to version updates, never to security updates. That matches ADR-0017's exception for security fixes.
- `npm` supports `default-days` and the semver keys; `github-actions` supports only `default-days`, which is all this file uses.
- Groups apply to version updates unless `applies-to: security-updates` is set, so security updates come one per pull request. They are not limited by `open-pull-requests-limit` (GitHub keeps a fixed limit of 10).
- `prefix: chore` with `include: scope` gives `chore(deps): …`, or `chore(deps-dev): …` for development dependencies.
- With `target-branch` set, the options of the ecosystem do not apply to security updates, which always target the default branch. When the remote is created, `develop` should be the default branch so that security updates also land there.

## Validation log

- Skipped: no BE controller or FE change (CI workflow, Dependabot configuration and AGENTS.md only; no screen or behavior of a web client changed).
- Verified 2026-11-20: no gaps, no drift, gates green
