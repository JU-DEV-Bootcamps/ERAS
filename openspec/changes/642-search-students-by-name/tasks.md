## 1. Backend (BE)

- [x] 1.1 Write the AC test `GetPagedAsyncWithJoins_SearchTextInName_ReturnsMatchesIgnoringCaseAsync` for (AC-1) in the new `ERAS-BE/test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Repositories/StudentRepositorySearchTests.cs`, tagged `[Trait("Change", "642-search-students-by-name")]` and `[Trait("AC", "642-search-students-by-name/AC-1")]`, and verify it fails (it does not compile against the missing search argument)
- [x] 1.2 Write the AC test `GetPagedAsyncWithJoins_SearchWithoutAccents_MatchesAccentedNamesAsync` for (AC-2) in the same file, tagged `Change` and `AC` (`.../AC-2`), and verify it fails
- [x] 1.3 Write the AC test `GetPagedAsyncWithJoins_SearchWithWildcardCharacters_MatchesLiterallyAsync` for (AC-3) in the same file, tagged `Change` and `AC` (`.../AC-3`), and verify it fails
- [x] 1.4 Write the AC test `GetPagedAsyncWithJoins_BlankSearch_ReturnsFullListAsync` for (AC-4) in the same file, tagged `Change` and `AC` (`.../AC-4`), and verify it fails
- [x] 1.5 Write the AC test `GetPagedAsyncWithJoins_SearchOverManyPages_PagesMatchesAndCountsAllAsync` for (AC-5) in the same file, tagged `Change` and `AC` (`.../AC-5`), seeding 120 students with 25 matches, and verify it fails
- [x] 1.6 Implement `SearchTextNormalizer` in the new `ERAS-BE/src/Eras.Application/Utils/SearchTextNormalizer.cs` for (AC-1, AC-2, AC-3, AC-4) with untagged unit tests in `ERAS-BE/test/Eras.Application.Tests/` (case, accents, trim, null) and verify they pass
- [x] 1.7 Change `IStudentRepository.GetPagedAsyncWithJoins` to `(int Page, int PageSize, string? Search)` returning the page and the total count, and implement it in `StudentRepository` per design D1 for (AC-1, AC-2, AC-3, AC-4, AC-5); update the existing `GetPagedAsyncWithJoins_*` tests in `StudentRepositoryTest.cs` to the new signature and verify tests 1.1 to 1.5 pass
- [x] 1.8 Add `Search` to `GetAllStudentsQuery`, pass it from `GetAllStudentsQueryHandler` (using the returned total count) and from `StudentsController.GetAllAsync` (`[FromQuery] string? Search`) for (AC-1, AC-2, AC-3, AC-4, AC-5); update the handler tests in `GetAllStudentsQueryHandlerTest.cs`, add untagged pass-through tests in the handler and `StudentsControllerTests.cs`, and verify they pass

## 2. Frontend (FE)

- [x] 2.1 Write the spec `[642-search-students-by-name/AC-6] shows the search input above the list without the clear button` for (AC-6) in `ERAS-FE/src/app/modules/students/students-list/students-list.component.spec.ts` and verify it fails
- [x] 2.2 Write the spec `[642-search-students-by-name/AC-7] sends one request with the typed text after the 300 ms pause` for (AC-7) in the same file using `fakeAsync`, and verify it fails
- [x] 2.3 Write the spec `[642-search-students-by-name/AC-8] clear button empties the input and reloads the full list` for (AC-8) in the same file and verify it fails
- [x] 2.4 Write the spec `[642-search-students-by-name/AC-9] shows "No students found." when the search has no matches` for (AC-9) in the same file and verify it fails
- [x] 2.5 Write the spec `[642-search-students-by-name/AC-10] keeps the search when the user changes page` for (AC-10) in the same file and verify it fails
- [x] 2.6 Write the spec `[642-search-students-by-name/AC-11] a new search goes back to the first page keeping the page size` for (AC-11) in the same file and verify it fails
- [x] 2.7 Write the spec `[642-search-students-by-name/AC-12] keeps the search after opening and closing a student modal` for (AC-12) in the same file, covering the reload after a saved modal, and verify it fails
- [x] 2.8 Write the spec `[642-search-students-by-name/AC-13] exports only the students matching the active search` for (AC-13) in the same file and verify it fails
- [x] 2.9 Add the messages in `ERAS-FE/src/app/core/constants/messages.ts` and the optional `search` argument of `getData` in `ERAS-FE/src/app/core/services/api/student.service.ts` for (AC-6, AC-7, AC-9, AC-13), with an untagged test in `student.service.spec.ts` that `Search` is sent only when the trimmed text is not empty, and verify it passes
- [x] 2.10 Implement the search field, clear button, `[pageIndex]` and `[emptyDescription]` in `students-list.component.html`, `.scss` and `.ts` for (AC-6, AC-8, AC-9) and verify the specs from 2.1, 2.3 and 2.4 pass
- [x] 2.11 Implement the debounced applied search, the page reset keeping the page size, and the search on page changes in `students-list.component.ts` for (AC-7, AC-10, AC-11) and verify the specs from 2.2, 2.5 and 2.6 pass
- [x] 2.12 Keep the search through modals and make `loadAllStudents` and the export cache follow the applied search in `students-list.component.ts` for (AC-12, AC-13) and verify the specs from 2.7 and 2.8 pass

## 3. Verification

- [ ] 3.1 BE gates (AGENTS.md section 5.6) pass in `ERAS-BE/`: `dotnet build Eras.sln -warnaserror`, `dotnet format Eras.sln --verify-no-changes`, `dotnet test Eras.sln`, coverage >= 25%
- [x] 3.2 FE gates pass in `ERAS-FE/`: `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (>= 15%), `npm run build`
- [x] 3.3 The AC traceability check (AGENTS.md section 5.4) shows exactly 1 test per AC per affected side, and `openspec validate 642-search-students-by-name --strict` passes

## Traceability
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | Name containing the text is returned regardless of case | BE | test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Repositories/StudentRepositorySearchTests.cs › GetPagedAsyncWithJoins_SearchTextInName_ReturnsMatchesIgnoringCaseAsync |
| AC-2 | Accents are ignored in the text and in the stored names | BE | test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Repositories/StudentRepositorySearchTests.cs › GetPagedAsyncWithJoins_SearchWithoutAccents_MatchesAccentedNamesAsync |
| AC-3 | Special characters are matched literally | BE | test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Repositories/StudentRepositorySearchTests.cs › GetPagedAsyncWithJoins_SearchWithWildcardCharacters_MatchesLiterallyAsync |
| AC-4 | An empty or blank search returns the full list | BE | test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Repositories/StudentRepositorySearchTests.cs › GetPagedAsyncWithJoins_BlankSearch_ReturnsFullListAsync |
| AC-5 | Matches are searched across all pages and paged | BE | test/Eras.Infrastructure.Tests/Persistence/PostgreSQL/Repositories/StudentRepositorySearchTests.cs › GetPagedAsyncWithJoins_SearchOverManyPages_PagesMatchesAndCountsAllAsync |
| AC-6 | Search input is shown at the top of the view | FE | src/app/modules/students/students-list/students-list.component.spec.ts › [642-search-students-by-name/AC-6] shows the search input above the list without the clear button |
| AC-7 | Typing searches once after a short pause | FE | src/app/modules/students/students-list/students-list.component.spec.ts › [642-search-students-by-name/AC-7] sends one request with the typed text after the 300 ms pause |
| AC-8 | Clear button restores the full list | FE | src/app/modules/students/students-list/students-list.component.spec.ts › [642-search-students-by-name/AC-8] clear button empties the input and reloads the full list |
| AC-9 | No match shows the empty message | FE | src/app/modules/students/students-list/students-list.component.spec.ts › [642-search-students-by-name/AC-9] shows "No students found." when the search has no matches |
| AC-10 | Changing page keeps the search | FE | src/app/modules/students/students-list/students-list.component.spec.ts › [642-search-students-by-name/AC-10] keeps the search when the user changes page |
| AC-11 | A new search returns to the first page | FE | src/app/modules/students/students-list/students-list.component.spec.ts › [642-search-students-by-name/AC-11] a new search goes back to the first page keeping the page size |
| AC-12 | Search survives opening and closing a student modal | FE | src/app/modules/students/students-list/students-list.component.spec.ts › [642-search-students-by-name/AC-12] keeps the search after opening and closing a student modal |
| AC-13 | Export while a search is active | FE | src/app/modules/students/students-list/students-list.component.spec.ts › [642-search-students-by-name/AC-13] exports only the students matching the active search |
