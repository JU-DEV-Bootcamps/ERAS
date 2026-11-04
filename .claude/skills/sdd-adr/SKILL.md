---
name: sdd-adr
description: Creates or supersedes an Architecture Decision Record (ADR) for ERAS in openspec/adr/, one decision per file, numbered NNNN, with Context, Decision, Alternatives and Consequences, and keeps the index (openspec/adr/README.md) in sync. Use when /sdd-plan flags a design.md decision as an ADR candidate, when the user says "write an ADR", "record this decision" or "supersede ADR-NNNN", or for an architectural decision taken outside a change. Writes Proposed only; never sets Accepted, never writes code, never commits.
allowed-tools: Bash(openspec:*) Bash(bash .claude/skills/sdd-adr/scripts/check-adr.sh:*)
---

Record a **durable architectural decision** so later changes can cite and respect it. A change's
`design.md` → `## Decisions` holds choices local to that change and is archived with it; an ADR holds a
decision that outlives the change. Conventions: `openspec/sdd-conventions.md`, `AGENTS.md` §8.4 and `openspec/adr/README.md`.

**Boundary.** Write only in `openspec/adr/`: the new ADR, the index `README.md`, the summary `SUMMARY.md`, and the
Status line of an ADR being superseded. When the ADR comes from a change, also add or fix the `**ADR:** ADR-NNNN` line of that
D-block in the change's `design.md`. Do NOT write code, do NOT touch `ERAS-BE/` or `ERAS-FE/`, do NOT edit
specs, do NOT commit. Never read or print secrets (`.env`, `deploy/.env.prod`, `environment.development.ts`,
keys in `appsettings*.json`).

**Template** (copy the structure, delete every HTML comment): `.claude/skills/sdd-adr/templates/adr.md`

**Example:** `openspec/adr/0001-use-openspec-for-spec-driven-development.md`

**Checker:** `bash .claude/skills/sdd-adr/scripts/check-adr.sh [--change <change-id>]` (from the repo root).

## Is it an ADR?

Write an ADR when the decision constrains future changes, not just this one:
- a new dependency, framework, library or pattern, or dropping one;
- an authentication, authorization, role or ownership model;
- a data storage, schema strategy or migration approach;
- a cross-cutting BE ↔ FE contract (serialization, errors, pagination, API versioning, feature flags);
- a deliberate departure from the golden paths of `AGENTS.md` §6.1 and §7.1, or a new one.

A choice that only matters inside one change (which handler, which component split) stays a D-block in
`design.md`. If in doubt, ask the user (recommended option first).

## Steps

1. **Find the source.** From a change: the change id and the D-block in its `design.md` (re-read it from disk).
   On its own: ask what was decided, why, and what else was considered. One ADR = one decision; if the request
   holds several, write one ADR each and say so.

2. **Check for overlap.** Read `openspec/adr/SUMMARY.md` (the rule of every Accepted ADR) and `openspec/adr/README.md`,
   then open the ADRs of the same Area. If an existing ADR
   already covers the decision, link it instead of writing a new one. If the new decision contradicts an
   `Accepted` ADR, this is a supersede (step 5), never an edit of the old ADR.

3. **Number and name.** Next number = highest `NNNN` in `openspec/adr/` + 1 (`0001` if empty), never reused.
   File: `openspec/adr/NNNN-<kebab-title>.md`, the title an imperative phrase ("Use OpenSpec for ...").

4. **Write the ADR** from the template.
   - `**Status:** Proposed`, `**Date:**` today, `**Area:**` from `backend | frontend | auth | data | infra | process`
     (several comma-separated, the first decides the index group), `**Change:**` the change id or `none`. Leave `**Reviewed by:**` and `**Signed by:**` empty: only a human fills them
     (`openspec/adr/README.md`, "Review and sign-off").
   - Context: forces and constraints, with real paths. Decision: the rule a contributor must follow, stated
     actively. Alternatives: each option not chosen, with why not. Consequences: what gets easier, harder,
     and any follow-up.
   - Smallest text that a reader a year from now needs; no restating the spec or the design.

5. **Supersede** (only when the decision replaces earlier ADRs).
   - The new ADR gets `**Supersedes:** ADR-NNNN` (comma-separated for several) and stays `Proposed`.
   - Leave the old ADR untouched while the new one is `Proposed`.
   - Once a human has set the new ADR to `Accepted` and asks you to finish the supersede, change only the old
     ADR's Status line to `Superseded by ADR-MMMM`, and its index row (`Superseded`, `ADR-MMMM`).

6. **Update the index.** In `openspec/adr/README.md` → `## Index`, add one row under `### <first Area>` (create
   the heading and table if missing, headings in the Area order above):
   `| [ADR-NNNN](NNNN-<kebab-title>.md) | <title> | Proposed | — |`.
   `openspec/adr/SUMMARY.md` lists **Accepted** ADRs only: do not add a Proposed one. When the user tells you an ADR is
   now Accepted (a human set it, reviewed and signed it), add its entry under `## <first Area>`:
   `### [ADR-NNNN](NNNN-<kebab-title>.md): <title>` and a line `Rule: <the rule to follow, 1-2 lines>`; when one becomes
   Superseded, remove its entry.

7. **Link it from the change.** When the ADR comes from a change, the D-block in `design.md` carries
   `**ADR:** ADR-NNNN` right after its `**Alternative:**` line.

8. **Validate.** Run `bash .claude/skills/sdd-adr/scripts/check-adr.sh` and fix every error, then run it again.
   From a change, also run `openspec validate "<change-id>" --strict`.

9. **Stop and report.** Give: the ADR number, title, Area, the change it links to, any ADR it supersedes, and
   the files to commit together with that change (`AGENTS.md` §8.3 step 5): the new ADR, `openspec/adr/README.md`
   and any superseded ADR.
   Next step: a human reviews it with the checklist of `openspec/adr/README.md`, signs it (`Reviewed by`, `Signed by`)
   and sets `**Status:** Accepted` (or `Rejected`), usually together with
   `**Plan:** Approved` of the change. `/sdd-verify` refuses to recommend archiving while a linked ADR is not
   Accepted.

## Guardrails

- One decision per file; never group decisions in one ADR.
- Never edit the body of an `Accepted` ADR. Typos aside, a changed decision is a new ADR that supersedes it.
- Never set `Accepted` or `Rejected`; only a human does. `Deprecated` (no replacement) is set only when the user asks.
- Never renumber, delete or reuse a number; a wrong ADR becomes `Rejected` or is superseded.
- Do not invent decisions: an ADR records what the team decided, not what you would prefer.
