# ADR summary

The rules in force, one entry per **Accepted** ADR, grouped by Area (first Area of the ADR). Read this first when
you are new to ERAS or when you review a change; open the ADR for the reasons and the alternatives. The index with
every status is in [README.md](README.md). `/sdd-adr` keeps this file in sync and `check-adr.sh` checks it.

## backend

### [ADR-0004](0004-read-user-manuals-from-repository-files.md): Read user manuals from files managed in the repository
Rule: keep manuals as files in `manuals/` at the root of the parent repository, declared in `manifest.json`; the backend only reads them (folder from `UserManuals:Path`) through its own read-only endpoints, never as attachments or static frontend files. Changes go through a reviewed PR and the pipeline validates the folder; the same approach applies to other read-only, developer-maintained reference files.

## frontend

### [ADR-0010](0010-use-jspdf-autotable-for-vector-pdf-tables.md): Use jspdf-autotable to build vector PDF tables in the frontend
Rule: build PDF tables in the frontend from plain columns and rows with `jspdf-autotable` on top of `jspdf` (real text, headers repeated on every page), loaded with a dynamic `import()`; new table exports do not use DOM snapshots.

## auth

### [ADR-0005](0005-limit-professional-access-to-students-of-assigned-assessments.md): Limit a professional's access to students of their assigned assessments
Rule: a professional only reaches students of assessments whose `AssignedProfessionals` holds their Keycloak sub; Administrator and Officer are not limited and Guest is denied. One Application-layer resolver enforces it (a violation is a `BussinessException` 403), and `StudentsController` declares a policy on every action, checked by a reflection test.

### [ADR-0009](0009-limit-professional-profile-to-professionals.md): Limit the professional profile endpoints to the ERAS Professional role
Rule: the endpoints `GET` and `PUT api/v1/users/me/professional-profile` declare the policy `ProfessionalOnly`, which requires only the `ERAS Professional` role; Administrator, Officer and Guest get 403. This is an exception to "Administrator passes every check" (AGENTS.md §4.3) and applies only to endpoints that declare `ProfessionalOnly`.

## data

### [ADR-0002](0002-store-short-id-lists-in-array-columns.md): Store short lists of identifiers in PostgreSQL array columns
Rule: store a short list of ids that has no attributes of its own in an array column of the owning row (`text[]` or `integer[]`, filtered with `.Contains`). Use a join table only when the relation carries its own data, needs referential integrity or is queried from the other side at scale.

### [ADR-0003](0003-match-text-search-ignoring-accents-in-the-application.md): Match text searches ignoring case and accents in the application, not in SQL
Rule: compare names in the application with `SearchTextNormalizer` (trim, remove accents, lowercase) on both sides; a blank search keeps the plain SQL paging. Any new accent-insensitive text search uses the same helper.

### [ADR-0006](0006-show-the-imported-identifier-as-the-student-sis-id.md): Show the imported identifier as the student's SIS ID
Rule: a student's SIS ID is `Student.Uuid` when the student is imported and `StudentProfile.SisId` when registered by hand, otherwise there is none; the identifier ERAS generates is never returned as a SIS ID. The rule lives in the mapper that builds the profile response, and no new identifier column is added.

## process

### [ADR-0007](0007-split-agent-rules-per-sub-project.md): Split agent rules per sub-project, one rule one home
Rule: backend and frontend rules live only in `ERAS-BE/AGENTS.md` and `ERAS-FE/AGENTS.md`; the root `AGENTS.md` keeps every heading as a pointer, the submodule files keep the same section numbers and never link to the parent by relative path.

### [ADR-0008](0008-review-and-sign-adrs-before-accepting.md): Review and sign an ADR before it is accepted
Rule: an ADR is reviewed like a PR with the checklist in `README.md`; anyone with write access reviews and signs, one sign-off is enough, and the result is recorded in `Reviewed by` and `Signed by`. Only a human accepts; skills never fill those fields.
