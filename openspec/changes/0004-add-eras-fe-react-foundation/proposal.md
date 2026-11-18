# Proposal

**Status:** Approved

## Why

ERAS v3 is a second, permanent web client in React, in its own repository `ERAS-FE-React`, next to ERAS v2 (Angular, `ERAS-FE`), which another team keeps in production. Change `0003-support-multiple-frontend-clients` already declares the side `FE-React` in `openspec/sides.conf`, but the repository, its rules and its gates do not exist yet, so no v3 screen can be specified, tested or built. The remote repository does not exist on GitHub yet, so the project starts as a local repository. Issue: placeholder `0004` (no issue yet; rename the folder when it exists, before approval).

## What Changes

- **Local repository `ERAS-FE-React/`** inside the parent folder, with its own `git init` and a `develop` branch. It is **not** a submodule yet: `git submodule add` needs the remote URL, which goes into `.gitmodules` for everyone. The parent ignores the folder through `.git/info/exclude` (local to each clone, never committed). Nothing is committed in it by this change (AGENTS.md section 9).
- **Project scaffold:** Vite + React 19 + TypeScript (`strict`), `base: '/'` (v3 has its own host, no path prefix), `npm` with a committed `package-lock.json` and exact dependency versions, and the Node version in `.nvmrc`.
- **Libraries wired in the foundation, each used by the shell:** React Router, TanStack Query, react-i18next, keycloak-js, Axios.
- **Languages:** the texts exist in English (`en`), neutral Spanish (`es`) and Brazilian Portuguese (`pt-BR`), one resource file each, with the same keys. English is always the initial language (no detection from the browser). A test fails when a language lacks a key the others have. Choosing the language in the UI and remembering the choice is behavior the user sees, so it is a later change with its own spec. v2 stays English only; this is a deliberate difference of v3 (ADR-0012).
- **Runtime configuration:** `public/config.json`, read before the app starts, holds the Keycloak URL, realm, client id, the roles resource and the three role names of `AGENTS.md` section 4.3. It holds no API URL: the app calls `/api/v1` on its own origin; in development the Vite server proxies `/api` to the backend (`http://localhost:8080`), and in Stage and production the v3 web server does the same (the v3 CI and infrastructure change).
- **Authentication** (ADR-0013): keycloak-js with the authorization code flow and PKCE `S256`, login by redirect (no silent check-sso iframe), tokens only in memory (never `localStorage` or `sessionStorage`), refresh before expiry, roles read from `resource_access[<rolesResource>].roles`. An Axios interceptor adds the bearer token.
- **App shell, no ERAS screen:** a route table with per-route roles (the v3 equivalent of v2's `ROUTE_METADATA`), a role guard, an authenticated placeholder home, an "access denied" page and a "not found" page. The 15 ERAS screens are later changes, one per module, through the full `/sdd-*` flow.
- **Initial folder structure:** `src/app` (bootstrap, router, providers), `src/core` (config, auth, http, i18n), `src/shared` (generic pieces) and `src/features/<feature>` (one folder per module). ADR-0016 (state and layers) formalizes it before the first module.
- **Tests:** Vitest + React Testing Library + MSW, `jsdom`, coverage with a 15% line threshold enforced in the Vitest configuration. Tests cover the configuration loader, token handling, the role guard and the Axios interceptor. No AC tags: this change has no AC.
- **Scripts that `openspec/sides.conf` calls:** `lint` (ESLint flat config with typescript-eslint, react-hooks and jsx-a11y), `test:ci` (`vitest run --coverage`), `typecheck` (`tsc --noEmit`), `build` (`vite build`); plus `dev` and `test`.
- **Hooks:** husky + commitlint (`@commitlint/config-conventional`) + lint-staged, copied from `ERAS-FE` (`commit-msg`, `pre-commit`); `pre-push` runs `npm run test:ci`.
- **Workflow of `ERAS-FE-React`:** `.github/workflows/pr_workflow.yaml` runs `lint`, `typecheck`, `test:ci` and `build` on every pull request to `develop`, all **blocking** from day one. It ships with the repository and runs once the remote exists. Building and publishing the Docker image is the v3 CI and infrastructure change.
- **Rules of `ERAS-FE-React`** (ADR-0007): `ERAS-FE-React/AGENTS.md` with the same section numbers as `ERAS-FE/AGENTS.md` (§3.3 commands, §4.2 architecture, §7.1 golden path, §7.2 rules, §7.3 tests: the AC key first in the `it()` title, `*.test.ts` / `*.test.tsx` under `src/`, never `.only` or `.skip`), and `ERAS-FE-React/CLAUDE.md` with only `@AGENTS.md`. They state no rule of the root `AGENTS.md` again.
- **React skill:** `ERAS-FE-React/.claude/skills/eras-fe-react-test/SKILL.md`, how to write one tagged AC test in v3 (the counterpart of the `eras-fe-test` skill that `/sdd-implement` already looks for in `ERAS-FE`). In the parent, the `/sdd-implement` line that names `ERAS-FE/.claude/skills/eras-fe-test/SKILL.md` gets a generic sentence: follow `<submodule>/.claude/skills/<name>-test/SKILL.md` when it exists for the side.
- **Local Keycloak client:** `Keycloak/realm-export.json` gets one new public client `eras-fe-react` (standard flow only, PKCE `S256`, redirect `http://localhost:5173/*`, web origin `http://localhost:5173`, full scope so the token carries the roles resource, and an audience mapper that adds `api-client`, the audience the backend validates, exactly as `public-client` does). It changes nothing for v2's `public-client`. Stage and production clients are registered by DevOps (the v3 CI and infrastructure change).
- **Root `AGENTS.md` §2.1:** the `ERAS-FE-React/` row says it is a local repository, not yet a submodule.
- **ADRs (new, Proposed), via `/sdd-adr`:** ADR-0012 "Adopt React as the second web client and its stack" and ADR-0013 "Authenticate the React client with its own Keycloak public client, PKCE and in-memory tokens". Numbers are tentative until the PR merges.

**Out of scope:**
- Any ERAS screen or behavior (later changes, one per module, with specs).
- The Orval client generated from the backend OpenAPI document (ADR-0015, before the first module that calls the API); TanStack Table and Virtual, React Hook Form and Zod (installed by the first module that needs them; adopted by ADR-0012).
- Storybook (depends on the UI library, ADR-0017, not decided) and the UI library itself.
- Playwright end-to-end tests (they need the running stack; a later change).
- The `Dockerfile`, the v3 nginx, the image workflow, Stage, production, CORS and the Stage/production Keycloak clients (the v3 CI and infrastructure change).
- Registering `ERAS-FE-React` as a submodule (needs the remote URL).
- Any edit under `ERAS-FE/` or `ERAS-BE/`.

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Submodules:** none changed. `ERAS-FE-React/` is a new local repository, not yet a submodule.
- **Files (parent):** `Keycloak/realm-export.json` (one new client), `AGENTS.md` §2.1 (one row), `.claude/skills/sdd-implement/SKILL.md` (one sentence), two new ADRs and the `openspec/adr/README.md` index.
- **Files (`ERAS-FE-React/`):** the whole new project.
- **Roles / who can do what:** no change. The v3 shell reads the same roles as v2 and shows no ERAS feature.
- **API contract:** none (`api/v1` is used as it is).
- **Data / migration:** none.
- **Risk:** low for v2: only one client is added to the local realm. For v3, the stack and the auth model are set here; both are ADRs reviewed before the plan is approved.
- **Depends on:** change `0003-support-multiple-frontend-clients` (the `FE-React` side and its gates in `openspec/sides.conf`). This branch is stacked on it; its PR opens after `0003` merges.
- **Rollback:** delete `ERAS-FE-React/` and revert the parent commit.

No behavior changes in ERAS, so this change sets `skip_specs: true` (AGENTS.md section 3, tooling).

## Pending

- **Remote repository:** create `ERAS-FE-React` on GitHub (owner and name to confirm), then `git remote add origin <url>`, push, and `git submodule add <url> ERAS-FE-React` in the parent. Git reuses the existing folder.
- **Roles resource and audience for v3 tokens:** confirm with DevOps that the Stage and production client of v3 gets the same roles resource as v2 (so the backend reads its roles, `resource_access[RolesResource]`) and the same audience mapper as v2's client (so the backend accepts the token).

## Decisions

- 2026-11-18, task 6.1: v2's local client `public-client` has an audience mapper that adds `api-client` to the token, and the backend validates that audience. Without the same mapper, every v3 call would get 401, so `eras-fe-react` gets it too, and the Pending item for DevOps now names it. Added during implementation; the reviewer may revert it.

- 2026-11-18, scope amended at the request of the change author (stated in chat), after the first approval: v3 supports three languages (`en`, `es` neutral, `pt-BR`) instead of English only, with English as the fixed initial language; the language selector is left to a later change with a spec. New tasks 3.8 and 3.9; `ERAS-FE-React/AGENTS.md` §7.1 and §7.2 and ADR-0012 updated. The Status went back to Draft for a new approval.

- 2026-11-18, recorded after `/sdd-verify` found implementation choices the proposal did not name (approved by the change author in chat):
  - **Vitest launcher.** `npm test` and `npm run test:ci` start Vitest through `ERAS-FE-React/scripts/vitest.mjs`. On Windows, Git Bash passes the working directory with a lower-case drive letter (`c:\...`), which makes Vitest load itself twice and fail with "failed to find the current suite"; the launcher starts it from the same folder with an upper-case drive letter. Without it the `test:ci` gate fails on Windows. Documented in `ERAS-FE-React/AGENTS.md` §3.3.
  - **Prettier, as in ERAS-FE.** `.prettierrc.json` with the options of `ERAS-FE` (without its Angular overrides), `.editorconfig`, and Prettier as an ESLint rule through `eslint-plugin-prettier` and `eslint-config-prettier`. In v3 the rule `prettier/prettier` is an **error**, not a warning as in `ERAS-FE`, because the v3 lint gate blocks (ADR-0012). `lint-staged` runs `eslint --fix` on code and `prettier --write` on JSON, Markdown, YAML, HTML and CSS; `npm run format` rewrites every file.
  - **Local Keycloak client values** in `ERAS-FE-React/AGENTS.md` §3.3, after the manual validation found a hand-made client without the web origin (see the Validation log).
  - **npm settings.** `.npmrc` sets `save-exact=true` (the exact versions of "Project scaffold") and `engine-strict=true` with `engines.node >=26` (the version of `.nvmrc`); the `preview` script of Vite serves the production build locally.
  - **Folders.** `src/shared/` and `src/features/` are not created: git does not keep empty folders. `ERAS-FE-React/AGENTS.md` §4.2 says the first module that needs one creates it.
  - **Versions.** TypeScript 6.0.3 instead of 7 and ESLint 9 instead of 10, because `typescript-eslint` supports TypeScript below 6.1 and `eslint-plugin-jsx-a11y` supports ESLint up to 9.

## Follow-ups

- A change with a spec for the language selector (choose `en`, `es` or `pt-BR` in the UI and remember the choice).

- ADR-0015 (Orval and adapters) and ADR-0016 (state and layers) before the first module change.
- ADR-0017 (UI library), then Storybook.
- Playwright end-to-end tests against the local stack.

## Validation log

- 2026-11-18 – Approved by the developer (stated in chat), manual validation of task 4.3 against the local stack: the Keycloak redirect login works for the four seed users (`admin@eras.local`, `officer@eras.local`, `professional@eras.local`, `guest@eras.local`) and lands on the shell home; no token appears in `localStorage` or `sessionStorage`; Log out returns to the Keycloak login page. Found and fixed during the validation: the client created by hand in the local Keycloak had no web origin `http://localhost:5173`, so the login ended in "ERAS could not start: Failed to fetch" (Keycloak answered `403 Invalid origin`); the exact client values are now in `ERAS-FE-React/AGENTS.md` §3.3.

Verified 2026-11-18: no gaps, no drift, gates green
