## Context

See proposal.md (Why) and `specs/student-management/spec.md` (AC-1..AC-13).

Today the Students view (`ERAS-FE/src/app/modules/students/students-list/students-list.component.ts`) calls `StudentService.getData` (`core/services/api/student.service.ts`), which hits `GET api/v1/students?Page&PageSize`. On the server, `StudentsController.GetAllAsync` sends `GetAllStudentsQuery(Pagination)`; `GetAllStudentsQueryHandler` calls `IStudentRepository.GetPagedAsyncWithJoins(Page, PageSize)` (ordered by `Name`, Skip/Take, global filter hides soft-deleted students) plus `CountAsync()`. The list is paginated on the server, there are no filters, and the FE re-sorts each page by name. `Student` has a single `Name` field.

The list is rendered by the shared `app-list` component, which hides the table and the paginator when `items` is empty and shows `emptyDescription` instead, and keeps its own `pageSize`. Export (`externalExport`) loads every student through `loadAllStudents()` once and caches it behind `allStudentsLoaded`.

The repository tests (`ERAS-BE/test/Eras.Infrastructure.Tests/.../Repositories/`) run on InMemory/Sqlite, never on PostgreSQL. No `unaccent` extension is used anywhere in the code.

## Goals / Non-Goals

**Goals:**
- Server-side name search over all students, case- and accent-insensitive, literal for special characters (AC-1..AC-5).
- Search input, debounce, clear button, empty state, and context kept across paging, new searches, modals and export (AC-6..AC-13).

**Non-Goals:**
- No new column, derived field, index, PostgreSQL extension or migration.
- No change to `GET api/v1/students/light`, the heat map, reports or any other endpoint that lists students.
- No change to `app-list` internals; the FE adapts through its existing inputs.

## Decisions

### D1. Accent-insensitive matching is done in the application, not in SQL
**Choice:** The repository normalizes both the search text and each stored name with one helper (trim, Unicode decomposition without combining marks, lowercase) and filters in .NET. It first reads only `Id` and `Name` of all non-deleted students ordered by `Name` (so the order is the one the list already has), filters, pages the ids, then loads the page with `StudentDetail`. A blank search keeps the current pure-SQL paging. Decided with the user.
**Alternative:** PostgreSQL `unaccent` + `ILIKE` → needs a migration to create the extension (risky after hotfix #638), and the repository tests do not run on PostgreSQL, so AC-1..AC-5 could not be proven by an automated test.
**ADR:** ADR-0003

### D2. One extra optional query parameter on the existing endpoint
**Choice:** `GET api/v1/students` gains an optional `Search` query parameter that travels as `GetAllStudentsQuery.Search`. `GetPagedAsyncWithJoins` takes `string? Search` and returns the page together with the total count of matches, so the handler no longer calls `CountAsync()` for this query. The existing repository and handler tests that call it are updated to the new signature (not re-tagged, they carry no AC).
**Alternative:** a new `GET students/search` endpoint → a second code path for paging and ordering, against the ticket's "single code path" note.

### D3. FE debounce with a Reactive Form control
**Choice:** A non-nullable `FormControl` for the input; `valueChanges` goes through `debounceTime(300)`, trim and `distinctUntilChanged`, with `takeUntilDestroyed()`. The applied (debounced) text is stored in the component and is what `loadStudents()` and the export read, so reloads after a modal save keep the search.
**Alternative:** `(input)` handler with `setTimeout` → manual teardown, harder to test with `fakeAsync`.

### D4. Search resets the page, keeps the page size
**Choice:** On a new applied search the component sets `pagination.page = 0`, keeps `pagination.pageSize`, and binds `[pageIndex]="pagination.page"` on `app-list` so the paginator follows. Page changes keep sending the applied search. `[emptyDescription]` switches to "No students found." only while a search is applied.
**Alternative:** also resetting the page size → the ticket asks not to reset existing controls.

### D5. Export follows the applied search
**Choice:** `loadAllStudents()` sends the applied search on every batch, and a change of the applied search clears `allStudents` and `allStudentsLoaded`, so the next export fetches again with the new search.
**Alternative:** filtering `allStudents` on the client → would need the same normalization in the FE and a full load that ignores the search.

## Changes by layer

### Backend (`ERAS-BE/`)

| Layer | Change | Files | ACs |
|---|---|---|---|
| Application | `GetAllStudentsQuery` gets `string? Search`; the handler passes it and uses the returned total count | `src/Eras.Application/Features/Students/Queries/GetAll/GetAllStudentsQuery.cs`, `.../GetAllStudentsQueryHandler.cs` | AC-1..AC-5 |
| Application | New static helper that normalizes search text and names (new file) | `src/Eras.Application/Utils/SearchTextNormalizer.cs` | AC-1, AC-2, AC-3, AC-4 |
| Application | `GetPagedAsyncWithJoins(int Page, int PageSize, string? Search)` returning the page and the total count | `src/Eras.Application/Contracts/Persistence/IStudentRepository.cs` | AC-1..AC-5 |
| Infrastructure | Implement the search per D1; same global filter and name ordering | `src/Eras.Infrastructure/Persistence/PostgreSQL/Repositories/StudentRepository.cs` | AC-1..AC-5 |
| Api | `GetAllAsync` accepts `[FromQuery] string? Search` and builds the query; class policy unchanged | `src/Eras.Api/Controllers/StudentsController.cs` | AC-1..AC-5 |

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Model / service | `getData(pagination, search?)` adds the `Search` param only when the trimmed text is not empty; response model unchanged | `src/app/core/services/api/student.service.ts` | AC-7, AC-8, AC-10, AC-11, AC-13 |
| Component | Search control, debounce, applied search, page reset, `pageIndex` binding, export reload | `src/app/modules/students/students-list/students-list.component.ts` | AC-6..AC-13 |
| Template | Search field with clear button above the list; `[pageIndex]`, `[emptyDescription]` | `src/app/modules/students/students-list/students-list.component.html`, `.scss` | AC-6, AC-8, AC-9, AC-10, AC-11 |
| Messages | New constants: placeholder "Search by name", empty state "No students found." | `src/app/core/constants/messages.ts` | AC-6, AC-9 |

No route, guard or `ROUTE_METADATA` change: the route and its roles already exist.

## API contract

| Endpoint | Policy | Request | Response DTO | Status codes |
|---|---|---|---|---|
| `GET api/v1/students` | `ErasPolicies.AdminOrOfficer` (class level, unchanged) | query: `Page`, `PageSize`, new optional `Search` (string) | `PagedResult<GetAllStudentsQueryResponse>` (unchanged) | 200, 401, 403 |

- **FE model:** `src/app/core/models/student.model.ts` is unchanged, the response shape does not move.
- **FE service:** `student.service.ts`, `getData(pagination, search?)`, endpoint `''` with no leading slash.
- **Scope rules:** the `Search` text is never concatenated into SQL (the filter runs in .NET), and the soft-delete global filter still applies.

## Data and migration

None. No schema change, no migration, no extension.

## Test strategy

Matching is decided in the repository, so AC-1..AC-5 are repository tests on the existing InMemory/Sqlite setup (new file, same `RepositoryTestBase` as `StudentRepositoryManualStudentTests`). The FE tests extend `students-list.component.spec.ts`.

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | BE | Infrastructure: `test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Repositories/` | `StudentRepositorySearchTests.cs` › `GetPagedAsyncWithJoins_SearchTextInName_ReturnsMatchesIgnoringCaseAsync` |
| AC-2 | BE | same | `StudentRepositorySearchTests.cs` › `GetPagedAsyncWithJoins_SearchWithoutAccents_MatchesAccentedNamesAsync` |
| AC-3 | BE | same | `StudentRepositorySearchTests.cs` › `GetPagedAsyncWithJoins_SearchWithWildcardCharacters_MatchesLiterallyAsync` |
| AC-4 | BE | same | `StudentRepositorySearchTests.cs` › `GetPagedAsyncWithJoins_BlankSearch_ReturnsFullListAsync` |
| AC-5 | BE | same | `StudentRepositorySearchTests.cs` › `GetPagedAsyncWithJoins_SearchOverManyPages_PagesMatchesAndCountsAllAsync` |
| AC-6 | FE | `src/app/modules/students/students-list/students-list.component.spec.ts` | `[642-search-students-by-name/AC-6] shows the search input above the list without the clear button` |
| AC-7 | FE | same | `[642-search-students-by-name/AC-7] sends one request with the typed text after the 300 ms pause` |
| AC-8 | FE | same | `[642-search-students-by-name/AC-8] clear button empties the input and reloads the full list` |
| AC-9 | FE | same | `[642-search-students-by-name/AC-9] shows "No students found." when the search has no matches` |
| AC-10 | FE | same | `[642-search-students-by-name/AC-10] keeps the search when the user changes page` |
| AC-11 | FE | same | `[642-search-students-by-name/AC-11] a new search goes back to the first page keeping the page size` |
| AC-12 | FE | same | `[642-search-students-by-name/AC-12] keeps the search after opening and closing a student modal` |
| AC-13 | FE | same | `[642-search-students-by-name/AC-13] exports only the students matching the active search` |

Extra untagged tests: `SearchTextNormalizer` unit tests, handler and controller pass-through of `Search`, and the service sending `Search` only when non-blank.

Coverage gates: BE >= 25%, FE >= 15% (AGENTS.md section 5.6).

## Risks / Trade-offs

- [Every search reads all student names] → only `Id` and `Name` are read, with no joins; fine for the current data size. A follow-up can move the filter to SQL if the dataset grows into tens of thousands.
- [Changing the signature of `GetPagedAsyncWithJoins` touches existing tests] → update them mechanically in the same task and keep their assertions.
- [Name ordering differs between SQL collation and .NET] → the ordering stays in SQL and the in-memory step only filters, so the order is unchanged.
- [`app-list` keeps an internal current page index] → the paginator is driven by `[pageIndex]` and only emits page events, so a stale internal value is overwritten on the next page event; AC-11 covers the reset.
- [Characters that do not decompose, such as "ø" or "ß"] → treated as different letters; accepted, the spec only requires accents and diacritics that decompose.

## Migration Plan

No data migration. Deploy BE first: an old FE keeps working against the new BE, while a new FE against an old BE would send `Search` and see it ignored.

## Follow-ups
- Moving the search to SQL (`unaccent` + index) if the student table grows large; needs a migration and a PostgreSQL-backed test setup, which does not exist today. It would supersede ADR-0003.
- `dotnet format Eras.sln --verify-no-changes` reports 1444 errors on `develop` itself (none in this change's lines), so task 3.1 cannot go green here. Fixed in its own change, `578-fix-dotnet-format-baseline` (ERAS-BE#578).
- Other screens that list students (heat map, reports, assessments) have no name search.
- `GetAllStudentsQueryHandler` swallows exceptions and returns an empty page (legacy pattern); left unchanged.
