# Architecture Decision Records

Durable decisions about how ERAS is built, which outlive the change that made them. A change's
`design.md` → `## Decisions` holds the choices local to that change and is archived with it; a decision
that later changes must respect goes here and the D-block links it as `**ADR:** ADR-NNNN`.

Create or supersede an ADR with `/sdd-adr`. Check this folder with
`bash .claude/skills/sdd-adr/scripts/check-adr.sh` (from the repository root).

## Rules

- **One decision per file**, in this flat folder: `NNNN-<kebab-title>.md`, numbered from `0001` with no gaps. Numbers are never reused.
- **Fields:** `**Status:**`, `**Date:**` (YYYY-MM-DD), `**Area:**`, `**Change:**` (change id or `none`), and `**Supersedes:**` when it replaces earlier ADRs. **Sections:** Context, Decision, Alternatives, Consequences.
- **Status:** `Proposed` → `Accepted` or `Rejected`; later `Deprecated` or `Superseded by ADR-NNNN`. Only a human sets `Accepted`, usually when approving the plan of the change that links it.
- **Accepted ADRs are not rewritten.** To change a decision, write a new ADR with `**Supersedes:** ADR-NNNN`. Once the new one is Accepted, the old one's Status becomes `Superseded by ADR-MMMM`; nothing else in it changes.
- **Area:** `backend`, `frontend`, `auth`, `data`, `infra`, `process`. Several are comma-separated; the first one decides the group below.
- **Index:** every ADR has exactly one row below, under its first Area, with the same status (`Superseded` plus the ADR in the last column).

## Index

### backend

| ADR | Title | Status | Superseded by |
|---|---|---|---|
| [ADR-0004](0004-read-user-manuals-from-repository-files.md) | Read user manuals from files managed in the repository | Accepted | — |

### data

| ADR | Title | Status | Superseded by |
|---|---|---|---|
| [ADR-0002](0002-store-short-id-lists-in-array-columns.md) | Store short lists of identifiers in PostgreSQL array columns | Accepted | — |
| [ADR-0003](0003-match-text-search-ignoring-accents-in-the-application.md) | Match text searches ignoring case and accents in the application, not in SQL | Accepted | — |

### process

| ADR | Title | Status | Superseded by |
|---|---|---|---|
| [ADR-0001](0001-use-openspec-for-spec-driven-development.md) | Use OpenSpec for spec-driven development | Proposed | — |
