# ADR-0012: Adopt React as the second web client and its stack

**Status:** Accepted
**Date:** 2026-11-18
**Area:** frontend
**Change:** 0004-add-eras-fe-react-foundation
**Reviewed by:** richardecos-dev (2026-11-18) 
**Signed by:** richardecos-dev (2026-11-18) 

## Context

ERAS v2 is an Angular 19 client in `ERAS-FE/`, kept in production by another team. A second web client, ERAS v3, is wanted in React, with the same backend (`api/v1`) and first the same 15 screens as v2, without new features. It is not a migration: both clients live on permanently, and v2 is not changed for it. ADR-0011 already declares the side `FE-React` (`ERAS-FE-React/`, tests `src/**/*.test.ts(x)`, gates `lint`, `test:ci`, `typecheck`, `build`). v2 has no internationalization (English only, `lang="en"`). Login goes through Keycloak (ADR-0013). Nothing in v3 needs server-side rendering: it is a static app served by its own web server.

## Decision

ERAS v3 is a React client in its own repository `ERAS-FE-React`, side `FE-React` of `openspec/sides.conf`. Its stack is React 19 with TypeScript `strict` and Vite; React Router for routes; TanStack Query for server state; TanStack Table and Virtual for tables and long lists; React Hook Form with Zod for forms and validation; react-i18next for texts, in English, neutral Spanish and Brazilian Portuguese with English as the initial language (v2 stays English only); keycloak-js for login (ADR-0013); Axios for HTTP; Vitest, React Testing Library and MSW for unit and AC tests; Playwright for end-to-end tests. A library is installed by the first change that uses it, not before. The API client generated from OpenAPI (ADR-0015) and the UI library (ADR-0017) are separate decisions. The gates `lint`, `test:ci` (coverage at least 15%), `typecheck` and `build` block every pull request from the first commit.

## Alternatives

- Migrate v2 to React → v2 stays in production with its own team; a migration is not the goal.
- A second Angular client → the decision for v3 is React; a second Angular codebase would add a client without a new stack to justify it.
- Next.js or another server-rendered framework → no SSR need, it adds a Node server to host, and the Keycloak redirect flow works the same in a static app.
- Create React App → deprecated, no longer maintained.
- Install the whole stack up front → dependencies no code uses yet, to update and audit for nothing.

## Consequences

- Two frontend codebases share the specs and AC keys: an AC can be declared `FE`, `FE-React` or both, and `check-parity.sh` lists the gaps (ADR-0011).
- Every v3 text exists in three languages, so each module change brings its texts in `en`, `es` and `pt-BR`, and someone must review the Spanish and Portuguese ones. This is a deliberate difference from v2, to be covered by the v2/v3 relationship ADR.
- v3 rules live in `ERAS-FE-React/AGENTS.md` (ADR-0007); the root `AGENTS.md` keeps only what both clients share.
- v3 starts with blocking gates; it does not inherit v2's non-blocking ones.
- The API client (ADR-0015), state and layers (ADR-0016) and the UI library (ADR-0017) must be decided before the first v3 module.
- The v3 team owns dependency updates for this stack.
