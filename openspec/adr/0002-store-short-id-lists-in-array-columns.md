# ADR-0002: Store short lists of identifiers in PostgreSQL array columns

**Status:** Accepted
**Date:** 2026-10-27
**Area:** data
**Change:** 635-allow-reassign-intervention-professional

## Context

An assessment must hold several professionals (Keycloak subs) instead of one. The same entity already stores
its students as an array: `StudentIds` is mapped with `HasColumnType("integer[]")` in
`ERAS-BE/src/Eras.Infrastructure/Persistence/PostgreSQL/Configurations/AssessmentManagement/AssessmentConfiguration.cs`,
and `Intervention.StudentIds` does the same. `Assessment` is mapped directly by EF, with no persistence twin.
Many-to-many joins such as `StudentCohortJoin` exist, but they link two persistence entities that have their own
attributes. The professionals list is a handful of short strings with no attributes, filtered by "contains this sub".

## Decision

We store a short list of identifiers that has no attributes of its own in an array column of the owning row, mapped
with `HasColumnType("text[]")` (or `integer[]`) and filtered with `.Contains(value)`. The first use is
`remissions.assigned_professionals`. A join table is used only when the relation carries its own data, needs
referential integrity or is queried from the other side at scale.

## Alternatives

- Join table `assessment_professionals` (the `StudentCohortJoin` pattern) → more files, a repository rewrite and cascade handling for a list of short strings with no extra attributes.
- A comma-separated string column → no typed queries and no safe `Contains`.
- A `jsonb` column → heavier to query and nothing in the code base uses it for lists.

## Consequences

- Schema, mapping and queries stay as simple as for `StudentIds`; migrations are a column change plus a backfill.
- No foreign key: nothing in the database prevents a sub that no longer exists, so the application validates values.
- Querying by element is a scan unless an index is added; add a GIN index if a table grows large and the filter becomes hot.
- A relation that later needs its own attributes must move to a join table through a new ADR.
