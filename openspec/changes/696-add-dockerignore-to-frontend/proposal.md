# Proposal

## Why

Issue: ERAS#696 (`JU-DEV-Bootcamps/ERAS`). `ERAS-FE/dockerfile` runs `COPY . ./` and the FE has no tracked
`.dockerignore`, so the build context also sends `node_modules`, `dist`, `coverage`, `.angular`, `.git` and
local files (`.claude/`, editor and test output) to the Docker daemon. That slows every build, invalidates the
layer cache on irrelevant changes and can bake local files into the build stage.

## What Changes

- Add `ERAS-FE/.dockerignore`, committed in the FE submodule, excluding what the image build does not need:
  `node_modules`, `dist`, `coverage`, `.angular`, `.git`, `.gitignore`, `.husky`, `.claude`, editor folders
  (`.vscode`, `.idea`), logs and OS files, and local env files: `.env`, `.env.*` and
  `**/environment.development.ts`.
- The environment exclusion is the one with some risk: `environment.development.ts` is only used by the
  `development` configuration (`ng serve`), never by the production image build, so it is safe to exclude.
  `src/environments/environment.production.ts` must **not** be excluded (see Risk).
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
  `package*.json`, `tsconfig*.json` and `src/environments/environment.production.ts` must stay in the
  context). The last one is the critical file: the production build replaces `environment.ts` with it, it is
  not tracked, and CI generates it from the sample before `docker build`. Checked by building the image once
  (task 2.1).

No application behavior changes, so this change sets `skip_specs: true` (AGENTS.md §8.1, tooling).

## Assumptions

- **A1.** No automated test is written for the `.dockerignore`: it is a build-context config with no
  behavior and no ACs (decision by the ticket owner). Verification is one manual `docker build` (task 2.1).

## Follow-ups

Out of scope here (the dockerfile is not changed by this change); each deserves its own change:

- **F1.** `RUN npm run build --configuration=production` does not pass the flag to Angular: without `--`
  (`npm run build -- --configuration=production`) npm takes it as its own config. It works today only because
  `angular.json` sets `defaultConfiguration: "production"` for `build`. If that default changes, the image
  would be built with the development environment (wrong roles and URLs).
- **F2.** `COPY . ./` before `npm install` reinstalls dependencies on any source change. Copying
  `package*.json` first (and using `npm ci`) would keep that layer cached.
- **F3.** Optional hardening: a comment in `.dockerignore` above `**/environment.development.ts` stating that
  `environment.production.ts` must stay in the context, so a broader `**/environment.*.ts` is not added later.

## Validation log
- Skipped: no BE controller or FE behavior change (build-context config only).
- Verified 2026-11-16: `docker build -f ERAS-FE/dockerfile ERAS-FE` succeeded, context 1.29MB, production build OK; no ACs, no tests (A1).
