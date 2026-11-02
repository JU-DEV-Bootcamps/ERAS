# ADR summary

The rules in force, one entry per **Accepted** ADR, grouped by Area (first Area of the ADR). Read this first when
you are new to ERAS or when you review a change; open the ADR for the reasons and the alternatives. The index with
every status is in [README.md](README.md). `/sdd-adr` keeps this file in sync and `check-adr.sh` checks it.

## backend

### [ADR-0004](0004-read-user-manuals-from-repository-files.md): Read user manuals from files managed in the repository
Rule: keep manuals as files in `manuals/` at the root of the parent repository, declared in `manifest.json`; the backend only reads them (folder from `UserManuals:Path`) through its own read-only endpoints, never as attachments or static frontend files. Changes go through a reviewed PR and the pipeline validates the folder; the same approach applies to other read-only, developer-maintained reference files.

## data

### [ADR-0002](0002-store-short-id-lists-in-array-columns.md): Store short lists of identifiers in PostgreSQL array columns
Rule: store a short list of ids that has no attributes of its own in an array column of the owning row (`text[]` or `integer[]`, filtered with `.Contains`). Use a join table only when the relation carries its own data, needs referential integrity or is queried from the other side at scale.

### [ADR-0003](0003-match-text-search-ignoring-accents-in-the-application.md): Match text searches ignoring case and accents in the application, not in SQL
Rule: compare names in the application with `SearchTextNormalizer` (trim, remove accents, lowercase) on both sides; a blank search keeps the plain SQL paging. Any new accent-insensitive text search uses the same helper.

## process

### [ADR-0006](0006-split-agent-rules-per-sub-project.md): Split agent rules per sub-project, one rule one home
Rule: backend and frontend rules live only in `ERAS-BE/AGENTS.md` and `ERAS-FE/AGENTS.md`; the root `AGENTS.md` keeps every heading as a pointer, the submodule files keep the same section numbers and never link to the parent by relative path.

### [ADR-0007](0007-review-and-sign-adrs-before-accepting.md): Review and sign an ADR before it is accepted
Rule: an ADR is reviewed like a PR with the checklist in `README.md`; anyone with write access reviews and signs, one sign-off is enough, and the result is recorded in `Reviewed by` and `Signed by`. Only a human accepts; skills never fill those fields.
