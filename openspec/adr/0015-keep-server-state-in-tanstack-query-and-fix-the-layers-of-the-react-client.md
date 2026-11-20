# ADR-0015: Keep server state in TanStack Query and fix the layers of the React client

**Status:** Accepted
**Date:** 2026-11-20
**Area:** frontend
**Change:** none
**Reviewed by:** richardecos-dev (2026-11-20)
**Signed by:** richardecos-dev (2026-11-20)

## Context

ADR-0012 adopts TanStack Query for v3 (`ERAS-FE-React`) and leaves state and layers as a separate decision, required before the first v3 module. `ERAS-FE-React/AGENTS.md` §4.2 already describes the folders (`src/app`, `src/core`, `src/features/<feature>`, `src/shared`) and says this ADR makes them final. `src/app/AppProviders.tsx` creates the `QueryClient`, and `createHttpClient` exists in `src/core/http/http.ts` (ADR-0014), but `src/main.tsx` creates no client instance, so no screen can call the backend yet. Lint already stops `src/core` from importing `src/app` or `src/features` (ESLint core rules, change `0006`), but core rules cannot express "a feature never imports another feature". This decision applies to every v3 module and changes nothing in `ERAS-BE` or `ERAS-FE`.

## Decision

- **Server state lives only in TanStack Query.** Each feature reads and changes server data with `useQuery` / `useMutation` in its own hooks (`src/features/<feature>/use-<resource>.ts`), which call the functions of its `api.ts` (ADR-0014) and pass on the query's `signal`. Components use only these hooks and never copy server data into `useState`. UI state that belongs to one screen stays in `useState` / `useReducer`. No global store (Redux, Zustand or similar) is added.
- **The HTTP client reaches the screens through a React context.** `src/main.tsx` creates the one client with `createHttpClient(auth)`; `HttpClientProvider` and the hook `useHttpClient()` live in `src/core/http/`, `AppProviders` mounts the provider, and feature hooks read the client with `useHttpClient()`. Tests give their own client through the same provider.
- **The layers of `ERAS-FE-React/AGENTS.md` §4.2 are final:** `app` (bootstrap, providers, routes, session), `core` (configuration, auth, HTTP, texts), `features/<feature>` (one folder per ERAS module) and `shared` (pieces used by two or more features). A feature may import `shared`, `core` and `app/session` only; `core` imports nothing from `app` or `features`; a feature never imports another feature.
- **Lint enforces the boundaries** with a boundaries plugin for ESLint (for example `eslint-plugin-boundaries`), installed with an exact version by the first change that needs it, as an error of `npm run lint`.

## Alternatives

- A global store (Redux Toolkit, Zustand) for server data → duplicates the cache that TanStack Query already keeps, and needs manual invalidation and loading states.
- A module singleton for the HTTP client → must be initialized before any import uses it, and tests must patch a module instead of giving a client through a provider.
- Passing the client down as a prop → every screen and component between the root and the hook must carry it.
- Keeping the boundaries as text only → "a feature never imports another feature" holds only while every contributor remembers it.
- Folders by type (`components/`, `hooks/`, `services/`) instead of by feature → one module's code spreads over many folders, and the porting of a v2 module no longer maps to one folder.

## Consequences

- Every module follows the same shape: `types.ts`, `api.ts`, `use-<resource>.ts`, components; a skill can guide it.
- Caching, refetching, loading and error states come from TanStack Query; the "Last Updated" style of v2's cached services maps to the query's `dataUpdatedAt`.
- One more development dependency (the boundaries plugin), pinned and audited by the v3 team.
- Code shared by two features must move to `src/shared` before the second feature uses it.
- The first module that calls the API (planned: the Home port) adds `HttpClientProvider`, `useHttpClient()`, the client in `src/main.tsx` and the boundaries rule.
- `ERAS-FE-React/AGENTS.md` §4.2, and the "Stop and ask" list of `eras-fe-react-feature`, must point to this ADR once it is Accepted.
