# Architecture Decision Records

Durable decisions about how ERAS is built, which outlive the change that made them. A change's
`design.md` → `## Decisions` holds the choices local to that change and is archived with it; a decision
that later changes must respect goes here and the D-block links it as `**ADR:** ADR-NNNN`.

Create or supersede an ADR with `/sdd-adr`. Check this folder with
`bash .claude/skills/sdd-adr/scripts/check-adr.sh` (from the repository root).

## Rules

- **One decision per file**, in this flat folder: `NNNN-<kebab-title>.md`, numbered from `0001` with no gaps. Numbers are never reused.
- **Fields:** `**Status:**`, `**Date:**` (YYYY-MM-DD), `**Area:**`, `**Change:**` (change id or `none`), `**Reviewed by:**` and `**Signed by:**` (empty until a human fills them, see below), and `**Supersedes:**` when it replaces earlier ADRs. **Sections:** Context, Decision, Alternatives, Consequences.
- **Status:** `Proposed` → `Accepted` or `Rejected`; later `Deprecated` or `Superseded by ADR-NNNN`. Only a human sets `Accepted`, usually when approving the plan of the change that links it.
- **Accepted ADRs are not rewritten.** To change a decision, write a new ADR with `**Supersedes:** ADR-NNNN`. Once the new one is Accepted, the old one's Status becomes `Superseded by ADR-MMMM`; nothing else in it changes.
- **Area:** `backend`, `frontend`, `auth`, `data`, `infra`, `process`. Several are comma-separated; the first one decides the group below.
- **Index:** every ADR has exactly one row below, under its first Area, with the same status (`Superseded` plus the ADR in the last column).
- **Summary:** [`SUMMARY.md`](SUMMARY.md) has one short entry per **Accepted** ADR, under its first Area: the rule to follow, for new contributors and reviewers. `/sdd-adr` updates it with the index; `check-adr.sh` fails when it drifts.

## Review and sign-off

An ADR is reviewed like a PR before it becomes `Accepted` ([ADR-0006](0006-review-and-sign-adrs-before-accepting.md)):

1. The ADR travels in a pull request (normally the parent-repo PR of the change that links it).
2. Anyone with write access to the repository reviews it with the checklist below.
3. One person signs: they add `**Reviewed by:** <GitHub handle> (YYYY-MM-DD)` and `**Signed by:** <GitHub handle> (YYYY-MM-DD)` to the ADR (one sign-off is enough; the same person may review and sign) and set `**Status:** Accepted`. Adding these fields is not a rewrite of an Accepted ADR.
4. The index row and the `SUMMARY.md` entry are updated in the same PR.

Skills never fill these fields or set `Accepted`. `check-adr.sh` fails for an Accepted ADR dated 2026-10-30 or later without them, and only warns for older ones until a human signs.

**Review checklist**

- [ ] One decision per file, stated as a rule a contributor can follow.
- [ ] Context states facts and constraints, not the answer.
- [ ] Alternatives are real options, each with why not.
- [ ] Consequences name the new rule or follow-up work.
- [ ] Consistent with the Accepted ADRs (or supersedes them explicitly).
- [ ] Area is correct and the file name, index row and `SUMMARY.md` entry match.
- [ ] No secret, private host or personal data in the text.

## Index

### data

| ADR | Title | Status | Superseded by |
|---|---|---|---|
| [ADR-0002](0002-store-short-id-lists-in-array-columns.md) | Store short lists of identifiers in PostgreSQL array columns | Accepted | — |
| [ADR-0003](0003-match-text-search-ignoring-accents-in-the-application.md) | Match text searches ignoring case and accents in the application, not in SQL | Accepted | — |

### process

| ADR | Title | Status | Superseded by |
|---|---|---|---|
| [ADR-0001](0001-use-openspec-for-spec-driven-development.md) | Use OpenSpec for spec-driven development | Proposed | — |
| [ADR-0005](0005-split-agent-rules-per-sub-project.md) | Split agent rules per sub-project, one rule one home | Accepted | — |
| [ADR-0006](0006-review-and-sign-adrs-before-accepting.md) | Review and sign an ADR before it is accepted | Accepted | — |
