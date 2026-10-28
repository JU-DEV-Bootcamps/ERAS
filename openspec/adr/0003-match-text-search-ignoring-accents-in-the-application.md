# ADR-0003: Match text searches ignoring case and accents in the application, not in SQL

**Status:** Accepted
**Date:** 2026-10-27
**Area:** data, backend
**Change:** 642-search-students-by-name

## Context

The Students search (change 642) must match names ignoring case and accents ("jose" finds "José") and treat `%` and `_` literally. PostgreSQL can do this with the `unaccent` extension, but no code in ERAS uses it, creating it needs a migration, and a migration just broke production (hotfix #638). The repository tests (`ERAS-BE/test/Eras.Infrastructure.Tests/.../Repositories/`) run on InMemory/Sqlite, never on PostgreSQL, so a SQL-only rule could not be proven by an automated test. `Student` has a single `Name` field.

## Decision

We compare names in the application. `SearchTextNormalizer` (`Eras.Application/Utils`) trims, decomposes to Unicode FormD without combining marks and lowercases both the search text and each stored name. `StudentRepository.GetPagedAsyncWithJoins` reads only `Id` and `Name` of the non-deleted students ordered by name, filters them with that helper and a literal `Contains`, pages the matching ids and loads that page with its details. A blank search keeps the pure SQL paging. Any new accent-insensitive text search uses the same helper until a new ADR supersedes this one.

## Alternatives

- PostgreSQL `unaccent` + `ILIKE` → needs a migration that creates the extension, and the repository tests cannot prove the behavior.
- A stored, normalized search column (with a backfill and updates on every write) → a schema change and a migration for a single screen.

## Consequences

- No migration, no extension and no schema change; the matching rules are covered by repository and normalizer tests.
- Each non-blank search reads the `Id` and `Name` of every active student, so its cost grows with the number of students. When that volume becomes a problem, a new ADR should supersede this one (`unaccent` or a normalized indexed column).
- Only accents that decompose into combining marks are removed; letters such as `ß` or `æ` are not expanded.
- The shared helper keeps the behavior identical wherever it is reused.
