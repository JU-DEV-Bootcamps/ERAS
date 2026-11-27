# Proposal

**Status:** Approved

## Why

`ERAS-FE-React` (ERAS v3, ADR-0012) was built as a local repository inside the parent, ignored through `.git/info/exclude`, because `git submodule add` needs a remote URL that goes into `.gitmodules` for everyone (change `0004`). That remote now exists: `https://github.com/JU-DEV-Bootcamps/ERAS-FE-React` (public, like `ERAS-FE`), with `develop` as its default branch at `111e66a`. Until the parent records it as a submodule, nobody else can clone v3, and the ship PRs of changes `0008` and `0010` cannot bump its pointer (AGENTS.md section 5.1). Issue: none (placeholder `0011`).

## What Changes

- **`.gitmodules`:** a third entry, `ERAS-FE-React`, with the URL above, added by `git submodule add`. Git reuses the existing folder.
- **Submodule pointer:** `ERAS-FE-React` at `111e66a`, the head of its `develop`, which is already pushed. The feature branches (`feature/0008/home`, `feature/0010/shell`) are not part of this pointer; each ship PR bumps it later.
- **Root `AGENTS.md` §2.1:** the `ERAS-FE-React/` row says it is a git submodule, no longer a local repository.
- **`README.md`:** the repository map gets an `ERAS-FE-React/` row, and the intro says the parent pulls in v3 as a submodule too.
- **Local only, not committed:** each developer who already has the local folder removes the `ERAS-FE-React/` line from `.git/info/exclude`.

**Out of scope:**
- Any code change in `ERAS-FE-React`, `ERAS-FE` or `ERAS-BE`.
- The Dependabot pull requests already opened in `ERAS-FE-React` (#1 to #6): they are reviewed one by one under ADR-0017, outside this change.
- Branch protection on `develop` of `ERAS-FE-React` (a GitHub setting).
- Docker, nginx and deploy files for v3 (its own CI and infrastructure change).

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Sides / submodules:** the parent only (`.gitmodules`, the new gitlink, `AGENTS.md`, `README.md`, this change folder). `ERAS-FE-React` gets no commit; `ERAS-BE` and `ERAS-FE` are not touched.
- **Roles / who can do what:** no change for ERAS users.
- **API contract:** none. **Data / migration:** none.
- **CI of the parent:**
  - `sdd-checks.yml` and `manuals-validation.yml` check out with `submodules: recursive`, so they now also clone `ERAS-FE-React`; it is public, so no extra token is needed.
  - The ship-PR step of `sdd-checks.yml` already reads the sides from `openspec/sides.conf`, where `FE-React` has `submodule = ERAS-FE-React`.
  - `stage_deploy.yml` lists one more submodule SHA in its log; it deploys from its `versions` input, so nothing else changes.
- **Contributors:** after pulling, run `git submodule update --init --recursive` (README already says so).
- **Risk (low):** a pointer to a commit that is not on the remote would break every clone; task 1.1 checks that `111e66a` is on `origin/develop` before the submodule is added.
- **Rollback:** revert the commit (`.gitmodules`, gitlink and docs together).

No behavior of ERAS changes, so this change sets `skip_specs: true` (AGENTS.md section 8.1, tooling and docs).

## Validation log

- 2026-11-27 – Skipped: no BE controller or FE change (`.gitmodules`, the submodule pointer and docs only; no screen or behavior of a web client changed).
- Verified 2026-11-27: no gaps, no drift, gates green
