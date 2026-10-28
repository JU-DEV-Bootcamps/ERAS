# Proposal

**Status:** Approved
**Plan:** Approved

## Why

Internal users have to page through the whole Students list to find one student, which is slow once the list grows past a few pages. They need to search by name directly in the Students view. Issue: ERAS#642 ("[Feature] Add Search by Student Name in Students View")

## What Changes

- The Students list request accepts an optional name search; the server filters the full set of students, not only the loaded page, keeping the name ordering and the paging.
- Matching is a "contains" match, case-insensitive and ignoring accents and diacritics ("jose" finds "José"), and treats characters such as `%` and `_` as plain text.
- The Students view shows a search input at the top, with a clear button. Results update about 300 ms after the user stops typing, without a page reload.
- When nothing matches, the list shows "No students found."
- The search text survives paging and opening and closing the student modals, and clearing it restores the full list.
- Exporting to CSV or PDF with a search active exports only the matching students; without a search it exports all students, as today.

**Out of scope:** searching by email, cohort or any other field; changes to the Student model, its relationships or the behavior of the student modals; new sorting or filtering controls; searching in other screens that list students (heat map, reports, assessments).

## Capabilities

### New Capabilities
- `student-management`: how the Students list is searched and presented. It is the first spec under this path (`openspec/specs/` is empty today), so it declares a Purpose.

### Modified Capabilities

## Impact

- **Submodules:** BE + FE
- **Roles / who can do what:** no change; the Students list stays available to `ERAS Administrator` and `ERAS Student Services Officer` only (`ERAS Professional` and Guest remain denied).
- **API contract:** the Students list endpoint gains an optional search parameter; the response shape is unchanged (details go to design.md, so BE DTO/query, FE model and FE service move together).
- **Data / migration:** to be decided in design.md. Accent-insensitive matching in PostgreSQL may need the `unaccent` extension (none is used in the code today) and therefore a migration.

## Assumptions

- A1: The Student entity has a single `Name` field (no separate first and last name). "First or last name contains the text" is implemented as "the full name contains the text", which also matches multi-word searches such as "maria lo".
- A2: Today the Students list has no filters. It is paginated on the server, ordered by name, and the page size is chosen in the paginator. "Together with existing filters and sorting" therefore means the search keeps the name ordering and the current page size.
- A3: A new search or a cleared search returns to the first page, because the number of results changes; changing the page while a search is active keeps the search text.
- A4: Leading and trailing spaces in the search text are ignored; a search of only spaces behaves like an empty search. There is no minimum length.
- A5: The empty-state text is "No students found." (the ticket gives it as an example) and is only shown when a search is active; with no search and no students, the existing empty message stays.
- A6: Students that were deleted (hidden today by the global filter) never appear in search results.

## Clarifications

### Session 2026-10-27

- Q: Which students are exported to CSV/PDF while a search is active? → A: only the matching students (AC-13: changed, marker removed)
- Status after this session: Clarified

## Validation log

### 2026-10-27 – Round 1

Preconditions: the stack is up (`docker compose up --build`, or BE + `ng serve` against the local Keycloak), the database has at least 25 students, among them names such as "José Pérez", "María López", "Ana_100% Gil" and several "García". Sign in as `ERAS Student Services Officer` and open the Students view.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1 | Type "ANA" in the search input | Only students whose name contains "ana" in any case are listed; the paginator total matches | | |
| AC-2 | Type "jose", then "maria" | "José Pérez" and "María López" appear; typing with the accent ("José") gives the same result | | |
| AC-3 | Type "_100%" | Only "Ana_100% Gil" is listed and nothing breaks (no error toast, no full list) | | |
| AC-4 | Type only spaces, then empty the field | The full list of the first page is shown, as without a search | | |
| AC-5 | Type "garcia" with a page size of 10 and go to page 2 and 3 | The total counts every García in the database, not only the loaded page; pages are ordered by name | | |
| AC-6 | Open the Students view | A search input with the placeholder "Search by name" is above the list; the clear (x) button is not shown while it is empty | | |
| AC-7 | Type "jos" letter by letter at normal speed and watch the Network tab | One `GET /api/v1/students?...&Search=jos` about 300 ms after the last key; the list updates without a page reload | | |
| AC-8 | Search "jos", then click the clear (x) button | Input is emptied, the button disappears and the first page of all students is shown | | |
| AC-9 | Type "zzzz" | The list shows "No students found."; the input keeps "zzzz" and its clear button | | |
| AC-10 | Search "garcia" and go to page 2 | The request carries `Search=garcia`, `Page=1`; the input still shows "garcia" | | |
| AC-11 | Go to page 3 with a page size of 25, then type "ana" | The first page is requested with the same page size (25) | | |
| AC-12 | Search "jose", open a student profile (person icon), close it; repeat saving a change in the profile | The input still shows "jose" and the same results; after saving, the list reloads keeping the search | | |
| AC-13 | Search "jose", then Export > To CSV (and To PDF) | The file contains only the matching students; with no search it contains all students | | |
| Side effects | Delete a student while a search is active; import a CSV; "New Student" while searching | The list reloads keeping the search; import and creation still work | | |
| Side effects | Other screens using the students list (imported students list, students by poll) | They load and page as before (no search input, no `Search` param) | | |
| Side effects | Sign in as `ERAS Professional` and as a Guest, call the Students view / `GET /api/v1/students?Search=ana` | Still denied (403 / no menu entry), as before | | |
| Errors | Stop the backend and type a search; expire the session and type a search | No unhandled error in the console; the app behaves as it does for other failed list loads | | |
| Different views | Narrow the window to a phone width; try Spanish accents with a keyboard layout that uses dead keys | The search input stays usable and does not overflow the buttons row; accented input matches | | |

Automated check by Claude on 2026-10-27 (Edge, `ERAS Administrator`, API and UI, informational only; the Result column above is left for the developer): AC-1, AC-2, AC-3, AC-4, AC-5 confirmed through the API (16 cases, 1111 students); AC-6, AC-7, AC-8, AC-9, AC-10, AC-11, AC-12 (profile modal cancelled, no save) confirmed in the UI; the network showed one request per typed text with `Search`, `Page` and `PageSize`. AC-13 confirmed: with the search "jose" active, Export > To CSV requested every page with `Search=jose` and the file held the 5 matching students only. Layout: with a content width of about 520 px the search field was pushed 183 px past the left edge; fixed by letting the row wrap and the field shrink (240 to 320 px), then re-measured at 520 and 360 px with no clipping. With the search "Zzprueba" active, a test student was created through New Student: the list reloaded keeping the search and showed it (1 of 1); deleting it reloaded the list keeping the search ("No students found.", success toast). The PDF export with the search "jose" requested every page with `Search=jose` and downloaded a 2-page file whose text could not be read here (no PDF tools). Not exercised: import, roles other than administrator (the endpoint policy is unchanged in the diff), backend down and expired session.

Approved by Lucia Becerra (stated in chat: goal achieved, no side effects, no open errors), 2026-10-27. The Result column of Round 1 was still empty in this file when the approval was logged.

Verify 2026-10-27 (sdd-verify): 13 of 13 ACs have exactly 1 passing test per side; ADR-0002 is Accepted; no drift from the spec or design.md; FE lint, tests (2463) and build pass; BE build with -warnaserror is clean and 1907 tests pass (86.37% lines). Open gap: task 3.1, because `dotnet format --verify-no-changes` reports 1444 errors on `develop` too (none in this change). It is fixed by ERAS-BE#578 (`578-fix-dotnet-format-baseline`). No `Verified` line yet: tick 3.1 and add it once that change has merged and the gate is green.
