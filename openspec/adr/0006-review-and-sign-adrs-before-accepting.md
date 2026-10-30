# ADR-0006: Review and sign an ADR before it is accepted

**Status:** Accepted
**Date:** 2026-10-30
**Area:** process
**Change:** 652-improve-sdd
**Reviewed by:** dev team
**Signed by:** Judith Paco

## Context

`openspec/adr/README.md` says only that "a human sets `Accepted`". There is no review step and no record of who looked at a decision, so an ADR can become binding for the whole team on one person's say-so. The review of issue ERAS#652 asked that ADRs be reviewed like a PR and then signed, so that new contributors can trust that an Accepted ADR was checked. The team is small, and anyone with write access to the repository already reviews and merges PRs.

## Decision

An ADR is reviewed like a PR before it is set to `Accepted`: it travels in a pull request, and a reviewer works through the review checklist in `openspec/adr/README.md`. Anyone with write access to the repository may review and sign; one sign-off is enough. The ADR file records the result in two fields, `**Reviewed by:**` and `**Signed by:**`, each `<GitHub handle> (YYYY-MM-DD)`, empty while the ADR is `Proposed`. Only a human sets `Accepted`; a skill never fills these fields.

## Alternatives

- Reviewers limited to leads and managers, sign-off by every developer and QA → slows every decision and depends on named people who may be away.
- A fixed list of named reviewers in the README → goes stale and needs its own maintenance.
- No record, only the PR approval → the approval is outside the repository and is lost when the history is read from the files alone.

## Consequences

- Each Accepted ADR shows who reviewed and signed it and when, inside the file.
- `check-adr.sh` can require a signature on ADRs accepted after this decision; earlier Accepted ADRs get a warning until a human signs them.
- The ADR template and `/sdd-adr` carry the two new fields, and the README carries the checklist.
- One reviewer can both review and sign: the checklist, not the head count, is the safeguard.
