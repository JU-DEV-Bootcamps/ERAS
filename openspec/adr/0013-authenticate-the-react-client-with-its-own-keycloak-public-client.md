# ADR-0013: Authenticate the React client with its own Keycloak public client, PKCE and in-memory tokens

**Status:** Accepted
**Date:** 2026-11-18
**Area:** auth, frontend
**Change:** 0004-add-eras-fe-react-foundation
**Reviewed by:** richardecos-dev (2026-11-18) 
**Signed by:** richardecos-dev (2026-11-18) 

## Context

The backend accepts Keycloak JWT bearer tokens and reads the roles from `resource_access[RolesResource]` (`AGENTS.md` §4.3). v2 logs in with keycloak-js through the client `public-client` (local realm `ERAS`, `Keycloak/realm-export.json`) and keeps the token and refresh token in `sessionStorage` (`ERAS-FE/src/app/core/services/access/access.service.ts`). In production, the v2 client's web origin has a trailing slash, so Keycloak sends no CORS header and v2's nginx proxies `/auth/` to work around it (`deploy/nginx.prod.conf`). v3 (ADR-0012) has its own host, so its origin and redirect URIs differ from v2's. Browsers increasingly block third-party cookies, which breaks the silent check-sso iframe.

## Decision

v3 is its own public client in the same realm of each environment: `eras-fe-react` in the local realm, and a client registered by DevOps for Stage and production. It uses the authorization code flow with PKCE `S256` and logs in by redirect, without the silent check-sso iframe. Tokens are kept only in memory, never in `localStorage` or `sessionStorage`; a page reload runs the redirect again, which Keycloak's own session completes without asking for the password. The token is refreshed before it expires. Roles are read from `resource_access[<rolesResource>].roles`, the same resource as v2, so the backend's authorization does not change. The client's web origins are exact (no trailing slash), so the browser calls Keycloak directly and v3 needs no `/auth/` proxy.

## Alternatives

- Reuse v2's client → ties the redirect URIs, web origins and lifecycle of both clients together; a change for one can break the other.
- Keep tokens in `sessionStorage` as v2 does → any injected script can read them.
- A backend-for-frontend with a cookie session → needs a server component and a backend change, outside "same backend, same API".
- The silent check-sso iframe → fails where third-party cookies are blocked.

## Consequences

- Each environment needs one more Keycloak client with the right redirect URIs and web origins; DevOps registers Stage and production.
- The v3 client must carry the same roles resource as v2 in its tokens (full scope or a scope mapping), or the backend sees no role, and the same audience mapper as v2's client, or the backend rejects its tokens.
- A reload costs one redirect round trip to Keycloak.
- v3 needs no CORS or `/auth/` workaround in its web server, as long as the web origins stay exact.
