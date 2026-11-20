# ADR-0014: Call the backend from the React client through hand-written axios services, without code generators

**Status:** Accepted
**Date:** 2026-11-20
**Area:** frontend
**Change:** none
**Reviewed by:** richardecos-dev (2026-11-20)
**Signed by:** richardecos-dev (2026-11-20)

## Context

ADR-0012 adopts Axios for v3 (`ERAS-FE-React`) and leaves the API client as a separate decision, required before the first v3 module; change `0004` planned an Orval client generated from the backend's OpenAPI document. The team rejects Orval for its security record, and any generator runs third-party code at build time and adds its dependency tree to v3's supply chain. v3 already has one HTTP client, `createHttpClient` in `ERAS-FE-React/src/core/http/http.ts`: base `/api/v1` on the app's own origin, a bearer token from `auth.getToken()` (keycloak-js refreshes it before expiry, ADR-0013) and `auth.login()` on a 401. The backend publishes Swagger only when `EnableSwagger` is `true` (`ERAS-BE/src/Eras.Api/Program.cs`), so the reliable contract is its controllers and DTOs. Its errors are `{ statusCode, message, detailed }`, where `detailed` is a stack trace (`ERAS-BE/src/Eras.Api/Middleware/ExceptionHandlingMiddleware.cs`), and some responses still use the `BaseResponse` envelope `{ success, message, validationErrors, body }`. This decision applies to every v3 module and changes nothing in `ERAS-BE` or `ERAS-FE`.

## Decision

v3 calls the backend only through TypeScript source on the existing client of `src/core/http/`, committed and reviewed like any other code; no code generator (Orval, openapi-generator or similar) is added and no tool writes this code at build time. The code is written from the backend's controllers and DTOs, usually by the agent within the SDD flow (`/sdd-implement`, and later a skill such as `eras-fe-react-api`), and a developer reviews it in the pull request. The rules for every module:

- One axios instance, from `createHttpClient`, with a default timeout; no other instance, no absolute URL, no environment variable (runtime settings come from `public/config.json`). No custom token refresh or request queue.
- `src/core/http/` normalizes every failure to `ApiError { status, message, validationErrors }`, from both error shapes of the backend. The `detailed` field is never copied, shown or logged, and neither are tokens, personal data or error bodies.
- Each feature writes the request and response types in `src/features/<feature>/types.ts` as `interface`s that mirror the backend DTOs (enums as string unions, no `any`), and typed functions in `src/features/<feature>/api.ts` that take the client and an `AbortSignal`. Path parameters go through `encodeURIComponent`, query parameters through axios `params`.
- Critical responses are validated at runtime with Zod (ADR-0012), installed with an exact version by the first change that needs it.
- Tests use MSW (`msw/node`) and never mock axios (`ERAS-FE-React/AGENTS.md` §7.3).

## Alternatives

- Orval → rejected by the team for its security record; it would also run at build time and add its dependencies to the supply chain.
- openapi-generator or another OpenAPI generator → same supply-chain cost, and it needs the backend's Swagger, which is off unless `EnableSwagger` is `true`.
- `fetch` without axios → ADR-0012 already adopts Axios, and the client with its interceptors exists; a second HTTP mechanism would split the rules.
- A shared `src/api/` folder with one service per resource → breaks the layers of `ERAS-FE-React/AGENTS.md` §4.2, where each module owns its API calls inside its feature folder.
- No runtime validation → a backend change that breaks a DTO would show wrong data instead of failing visibly.

## Consequences

- No generator dependency and no build step; every call is code that a reviewer reads in the pull request.
- The repetitive part (types, `api.ts`, hooks, MSW handlers) is written by the agent from the backend source, so the effort stays low without a generator; the developer's job is to review it.
- Types are kept in sync with the backend through a change, not automatically: a changed DTO needs a change in `types.ts`, which the Zod schemas and the MSW tests help catch. Principle 9 of the root `AGENTS.md` (BE and FE change in the same change) still applies when v3 is a side of that change.
- How the client reaches the screens and the TanStack Query hooks around `api.ts` are decided by ADR-0015 (state and layers).
- The first module that calls the API (planned: the Home port) builds `ApiError` and the timeout in `src/core/http/`; a later skill (`eras-fe-react-api`) can then guide each module's `types.ts`, `api.ts` and MSW handlers.
- `ERAS-FE-React/AGENTS.md` §4.3 and §7.1 step 2, and the "Stop and ask" list of `eras-fe-react-feature`, still describe a generated client and must point to this ADR once it is Accepted.
- The backend still sends stack traces in `detailed`; v3 ignores them, and fixing the backend is outside v3's scope.
