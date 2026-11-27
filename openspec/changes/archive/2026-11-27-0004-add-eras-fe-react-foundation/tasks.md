# Tasks

Each group below is one commit (groups 1 to 5 in `ERAS-FE-React/`, group 6 in the parent), so one group can be
reverted without touching the others. Nothing is committed by the agent; the developer commits when asked. Inside a
group, every unit gets its test first and the test must fail before the unit is written.

## 1. Repository (Infra)

- [x] 1.1 Create `ERAS-FE-React/` with `git init -b develop` and a `.gitignore` (node_modules, dist, coverage, `.env*` except samples), and add `ERAS-FE-React/` to the parent's `.git/info/exclude`, and verify `git status` in the parent does not list the folder and `git -C ERAS-FE-React status` works
- [x] 1.2 Write `.nvmrc` with the Node LTS version used locally and in the workflow, and verify `node --version` matches its major version

## 2. Scaffold and tooling (FE-React)

- [x] 2.1 Create the Vite + React 19 + TypeScript project (`strict`, `base: '/'`, dev server on port 5173 with `/api` proxied to `http://localhost:8080`) with exact dependency versions and a committed-ready `package-lock.json`, and verify `npm run dev` serves the default page
- [x] 2.2 Add ESLint (flat config, typescript-eslint, react-hooks, jsx-a11y) and the scripts `lint`, `typecheck` (`tsc --noEmit`), `build` (`vite build`), `test` and `test:ci` (`vitest run --coverage`), and verify `npm run lint`, `npm run typecheck` and `npm run build` pass
- [x] 2.3 Add Vitest + React Testing Library + MSW with `jsdom`, a coverage threshold of 15% lines in the Vitest configuration and one sample test of the root component, and verify `npm run test:ci` passes and fails when the threshold is raised above the measured coverage
- [x] 2.4 Add husky + commitlint (`@commitlint/config-conventional`) + lint-staged with `commit-msg`, `pre-commit` (as `ERAS-FE`) and `pre-push` (`npm run test:ci`), and verify a commit message `bad message` is rejected by `npx commitlint` and `feat: x` passes
- [x] 2.5 Add `.github/workflows/pr_workflow.yaml` (pull request to `develop`: Node from `.nvmrc`, `npm ci`, `lint`, `typecheck`, `test:ci`, `build`, every step blocking, no `continue-on-error`), and verify the file parses as YAML and runs the four scripts of `openspec/sides.conf` for `FE-React`

## 3. Core: configuration, authentication, HTTP (FE-React)

- [x] 3.1 Write the tests of the runtime configuration loader (reads `/config.json`; rejects a missing or malformed key with a clear error) and verify they fail
- [x] 3.2 Implement `src/core/config` and `public/config.json` (Keycloak URL, realm, client id, roles resource, role names; no API URL) and load it before the app renders, and verify the tests of 3.1 pass
- [x] 3.3 Write the tests of the auth module (init with PKCE `S256` and redirect login, no check-sso iframe; token kept only in memory, nothing written to `localStorage` or `sessionStorage`; refresh before expiry; roles read from `resource_access[<rolesResource>].roles`) with keycloak-js mocked, and verify they fail
- [x] 3.4 Implement `src/core/auth` with keycloak-js as tested, and verify the tests of 3.3 pass
- [x] 3.5 Write the tests of the Axios instance (base URL `/api/v1`; bearer token from the auth module; a 401 asks the auth module to log in again) with MSW, and verify they fail
- [x] 3.6 Implement `src/core/http`, and verify the tests of 3.5 pass
- [x] 3.7 Add react-i18next with English resources only and TanStack Query's client provider, and verify `npm run typecheck` and `npm run test:ci` pass

- [x] 3.8 Write the test that every language resource (`en`, `es`, `pt-BR`) has exactly the same keys as English and no empty text, and that the initial language is English, and verify it fails
- [x] 3.9 Add the neutral Spanish and Brazilian Portuguese resources of the shell texts and register them with English as the fixed initial language and the fallback, and verify the test of 3.8, `npm run typecheck` and `npm run test:ci` pass

## 4. App shell and routing (FE-React)

- [x] 4.1 Write the tests of the route table and role guard (a route without roles is open to any authenticated user; a user without a required role is sent to "access denied"; an unknown path shows "not found"; Administrator passes every role check, as `AGENTS.md` section 4.3), and verify they fail
- [x] 4.2 Implement `src/app` (providers, React Router route table with per-route roles, role guard) and the placeholder home, "access denied" and "not found" pages, and verify the tests of 4.1 pass
- [x] 4.3 Run the app against the local stack (`docker compose up` for backend and Keycloak, with the client of 6.1) and log in as each seed user, and verify the shell shows the home after the Keycloak redirect and the token never appears in browser storage (DevTools, Application tab)

## 5. Rules and skills of ERAS-FE-React (FE-React)

- [x] 5.1 Write `ERAS-FE-React/AGENTS.md` with the section numbers of `ERAS-FE/AGENTS.md` (§3.3 commands, §4.2 architecture, §7.1 golden path, §7.2 rules, §7.3 tests with the AC key first in the `it()` title, `*.test.ts(x)` under `src/`, never `.only` or `.skip`) naming the parent file in plain text and never by relative path (ADR-0007), and verify no rule of the root `AGENTS.md` is repeated in it
- [x] 5.2 Write `ERAS-FE-React/CLAUDE.md` with only `@AGENTS.md`, and verify it is the same as `ERAS-FE/CLAUDE.md`
- [x] 5.3 Write `ERAS-FE-React/.claude/skills/eras-fe-react-test/SKILL.md` (one tagged AC test with Vitest, React Testing Library and MSW, run alone, see it fail first), and verify its frontmatter has `name` and `description` and every path it cites exists

## 6. Parent repository (Infra)

- [x] 6.1 Add the public client `eras-fe-react` to `Keycloak/realm-export.json` (standard flow only, PKCE `S256`, redirect `http://localhost:5173/*`, web origin `http://localhost:5173`, full scope, and an audience mapper that adds `api-client`, the audience the backend validates, as `public-client` has), and verify the file is valid JSON and the client `public-client` is unchanged
- [x] 6.2 Update the `ERAS-FE-React/` row of `AGENTS.md` §2.1 (local repository, not yet a submodule) and add to `.claude/skills/sdd-implement/SKILL.md` the generic sentence about `<submodule>/.claude/skills/<name>-test/SKILL.md`, and verify `bash .claude/skills/sdd-plan/tests/check-skills.sh` passes
- [x] 6.3 Review ADR-0012 and ADR-0013 (written with `/sdd-adr` when this change was proposed) against what groups 2 to 5 built, and verify `bash .claude/skills/sdd-adr/scripts/check-adr.sh --change 0004-add-eras-fe-react-foundation` reports no error

## 7. Verification

- [x] 7.1 Run `bash .claude/skills/sdd-verify/scripts/run-gates.sh 0004-add-eras-fe-react-foundation --side FE-React`, and verify the four FE-React gates of AGENTS.md section 8.7 pass (lint, test:ci with coverage of at least 15%, typecheck, build)
- [x] 7.2 Run `bash .claude/skills/sdd-plan/tests/run-tests.sh`, and verify every section passes
- [x] 7.3 Run `git status --short` in the parent and `git -C ERAS-FE status --short`, `git -C ERAS-BE status --short`, and verify no file under `ERAS-FE/`, `ERAS-BE/` or `.github/` of the parent was changed by this change and `ERAS-FE-React/` is not listed by the parent
- [x] 7.4 Run `openspec validate 0004-add-eras-fe-react-foundation --strict` and `openspec validate --all --strict`, and verify both pass
