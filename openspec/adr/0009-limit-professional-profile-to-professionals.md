# ADR-0009: Limit the professional profile endpoints to the ERAS Professional role

**Status:** Accepted
**Date:** 2026-11-03
**Area:** auth
**Change:** 603-persist-professional-profile
**Reviewed by:** judithmarg-dev (2026-11-04)
**Signed by:** judithmarg-dev (2026-11-04)

## Context

The account information page of ERAS Professionals stores a professional profile (position, faculty, office hours,
subjects taught, courses) through new endpoints `GET` and `PUT api/v1/users/me/professional-profile` (design D3 of
`603-persist-professional-profile`). The approved spec (`openspec/changes/603-persist-professional-profile/specs/professional-profile/spec.md`)
allows reading and updating it only to the ERAS Professional, and denies the Student Services Officer, the Guest and,
after a user decision, the ERAS Administrator (AC-5, AC-6, AC-20).

AGENTS.md §4.3 states that the Administrator passes every check. The existing policies in
`ERAS-BE/src/Eras.Infrastructure/Authorization/ErasPolicies.cs` (`AdminOnly`, `AdminOrOfficer`, `AdminOrProfessional`,
`AnyErasRole`) all include the Administrator, so none of them can express "Professional only". Using
`AdminOrProfessional` would let the Administrator in, against the spec.

## Decision

The professional profile endpoints are protected by a policy `ProfessionalOnly` that requires only the
`ERAS Professional` role. The ERAS Administrator is denied on these endpoints. This is an exception to the rule in
AGENTS.md §4.3 that applies only to endpoints that declare `ProfessionalOnly`; no other endpoint changes.

## Alternatives

- `AdminOrProfessional` (the existing policy) → also admits the Administrator, which the spec forbids.
- Keep the Administrator allowed and document it → contradicts the approved spec (AC-20) and the user's decision.
- A handler-level check for the Professional role, with the endpoint on an existing policy → the authorization
  rule would live in the handler instead of `ErasPolicies`, which AGENTS.md §6.2 reserves for role rules, and
  it would be easy to forget on a new action.

## Consequences

- A new policy in `ErasPolicies` is the single place where the professional-only rule is defined; the
  reflection-based tests (`ControllerPolicyEvaluator`) can verify each new action declares it.
- The Administrator cannot read or change any professional profile, including their own. If the team later
  needs administrators to manage professional profiles, that is a new decision that supersedes this ADR.
- The exception to AGENTS.md §4.3 is recorded here. Other new endpoints that must exclude the Administrator
  need their own decision; this ADR does not set a general pattern.
- The check `check-adr.sh` and `/sdd-verify` require this ADR to be `Accepted` before the change is archived.
