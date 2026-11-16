# Proposal

## Why

Issue: ERAS#696 (`JU-DEV-Bootcamps/ERAS`). `ERAS-FE/dockerfile` runs `COPY . ./` and the FE has no tracked
`.dockerignore`, so the build context also sends `node_modules`, `dist`, `coverage`, `.angular`, `.git` and
local files (`.claude/`, editor and test output) to the Docker daemon. That slows every build, invalidates the
layer cache on irrelevant changes and can bake local files into the build stage.

## What Changes

- Add `ERAS-FE/.dockerignore`, committed in the FE submodule, excluding what the image build does not need:
  `node_modules`, `dist`, `coverage`, `.angular`, `.git`, `.husky`, `.claude`, editor folders and local logs.
- No change to `ERAS-FE/dockerfile` or to how the image is built and served.

**Out of scope:** changing the dockerfile (base image, multi-stage layout, `npm ci`), the BE, compose files,
CI pipelines and any application code.

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Submodules:** FE only (one new config file). BE: none.
- **Roles / who can do what:** no change. **API contract / data / migration:** none.
- **Risk:** low. An over-broad pattern could exclude a file the build needs (`src`, `public`, `angular.json`,
  `package*.json`, `tsconfig*.json` must stay in the context). Checked by building the image once (task 2.1).

No application behavior changes, so this change sets `skip_specs: true` (AGENTS.md §8.1, tooling).

## Assumptions

- **A1.** No automated test is written for the `.dockerignore`: it is a build-context config with no
  behavior and no ACs (decision by the ticket owner). Verification is one manual `docker build` (task 2.1).
- **A2.** The untracked `ERAS-FE/.dockerignore` already in the working tree is a draft; it is kept as the base
  and extended, not discarded.

## Validation log
- Skipped: no BE controller or FE behavior change (build-context config only).
- Verified 2026-11-16: `docker build -f ERAS-FE/dockerfile ERAS-FE` succeeded, context 1.29MB, production build OK; no ACs, no tests (A1).
