# Proposal

**Status:** Draft

## Why

The SDD rules that were turned into scripts (`openspec validate`, `check-skills.sh`, `check-spec.sh`, `check-plan.sh`, `check-adr.sh`) only run when someone remembers to run them: no workflow in `.github/workflows/` calls them, although ADR-0001 expects "a check that can run in CI". Issue: placeholder `0001` (no issue yet; rename the folder when it exists, before approval).

## What Changes

- Add one workflow, `.github/workflows/sdd-checks.yml`, that runs on `pull_request` when `openspec/**`, `.claude/skills/**`, `AGENTS.md` or `CLAUDE.md` change.
- The job checks out with `submodules: recursive` (as `manuals-validation.yml` already does on pull requests), installs `gawk` (the scripts were only tested with GNU awk on Windows Git Bash; the runner's default awk is not verified) and installs the OpenSpec CLI at a pinned version.
- Steps: `openspec validate --all --strict`, `bash .claude/skills/sdd-plan/tests/check-skills.sh`, and, **only for the changes the PR touches** (not archived ones), `check-plan.sh`, `check-adr.sh`, and `check-spec.sh` when the change is not `skip_specs`.
- It starts **non-blocking** (`continue-on-error: true`). A human flips it to blocking, and marks the check as required in the repository settings, after it has been green on real pull requests.
- It does **not** run `check-impl.sh`, `check-archive.sh`, `run-gates.sh` or `verify-gate.sh`: they depend on branch and submodule state and would give false errors on spec-only pull requests. The BE and FE gates stay in the submodules' own workflows.

**Out of scope:** making the check required, running `run-tests.sh` in CI, normalizing changes `571`, `578`, `642` and `660` (see Risk), any change to existing workflows, and any edit under `ERAS-BE/` or `ERAS-FE/`.

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Submodules:** none (parent repo only)
- **Files:** `.github/workflows/sdd-checks.yml` (new)
- **Roles / who can do what:** no change
- **API contract:** none
- **Data / migration:** none
- **Risk:** medium, contained by the non-blocking start. Checked locally on 2026-11-13: `check-plan.sh` already fails for the four active changes (`571` and `642`: the verification group does not cite section 8.7; `578` and `660`: the last task group is not the verification group), and `check-spec.sh` fails for `578` and `660` because they have no spec. Scoping the checks to the changes a PR touches, and skipping `check-spec.sh` for `skip_specs` changes, avoids a red check on unrelated pull requests, but a PR that touches one of those four changes will show its errors. `openspec validate --all --strict` has not been run on this repo (the CLI is not installed on the machine used for this proposal), so its baseline is unknown.
- **Rollback:** the workflow is a single new file; `git revert` of its commit removes it. Existing workflows are not touched.
- **Depends on:** change `0000-improve-sdd-entry-and-rules` only through the wording of its T4 sentence ("if the file exists"), which keeps `check-skills.sh` green when submodules are not checked out.

No behavior changes, so this change sets `skip_specs: true` (AGENTS.md section 3, tooling and CI).
