# Proposal

**Status:** Approved
**Plan:** Approved

## Why

Officers, Professionals and Administrators cannot take the Assessments list out of the app to share, print or report on it. The only export available elsewhere in the app is a PDF made from a screenshot of the page, which is slow and cannot include rows that the paginator hides. Issue: ERAS#678

## What Changes

- Add an Export control with CSV and PDF options to the Assessments list.
- Both files contain every assessment of the user's own list, not only the page shown on screen.
- Both files use the same columns, labels and order as the table (without Actions), with the full comment and the names of all students.
- The CSV opens correctly in spreadsheets: UTF-8 with accents preserved, escaped fields and neutralized formulas.
- The PDF has a header (title, export date and time, exporting user, applied filters) and a table whose column headers repeat on every page.
- The user sees progress while the file is generated and an error message if it fails.

**Out of scope:** exporting Interventions, Students or any other list (separate tickets); charts; backend export endpoints, background generation and expiring download links (see Assumptions A5); filters, search or sorting on the list; choosing columns; Excel format; email or scheduled exports; changing how the shared CSV export works for other screens.

## Capabilities

### New Capabilities
- `assessment-export`: exporting the Assessments list as CSV and PDF files.

### Modified Capabilities

## Impact

- **Submodules:** FE
- **Roles / who can do what:** `ERAS Administrator`, `ERAS Student Services Officer` and `ERAS Professional` may export, each only the list they already see. No other role rule changes.
- **API contract:** none. The export uses the lists the screen already loads.
- **Data / migration:** no

## Assumptions

- A1: The list has no filters, search or sorting today, so the export is the full list as displayed and the PDF "applied filters" line reads "None". This satisfies the issue's filter criteria vacuously; if filters are added later, the export must honor them.
- A2: The issue's user story names Officers and Administrators; Professionals are included as agreed in the analysis. Each role exports only the list it already sees (Administrator: all; Officer: the ones they created; Professional: the ones assigned to them). Guest cannot reach the page.
- A3: The Export control sits in the list header and is shown only when the list has rows, as the empty state offers only "Create Assessment". The issue's zero-row export behavior therefore cannot occur and is not specified.
- A4: The worst case agreed for now is 100 assessments. Files are generated in the browser from the data already loaded, so no new request is made and the app stays usable.
- A5: The criteria of the original issue that assumed backend export endpoints (background generation above a row limit, 403 from export endpoints, authenticated expiring download links) are not specified here. The issue was updated on 2026-11-11 and now lists them as out of scope. Unauthorized users cannot reach the list, and no export endpoint exists to protect.
- A6: The shared CSV export is kept as is. Excel needs a byte-order mark to read accents in UTF-8, which the shared path does not add today, and formula neutralization is not applied by it either; the design must achieve both for this export without changing how other screens export.
- A7: A submitter or professional that cannot be resolved to a name is shown by its identifier, and an empty value is shown as "—", exactly as the table does. An assessment with no students has an empty Student cell.
- A8: Dates use the table's format (MM/dd/yyyy). The PDF export date and time use the user's local time.
- A9: The downloaded file is named "assessments" followed by the export date and time, with the extension of the chosen format, following the naming of the other exports.
- A10: A comment can be up to 4000 characters. In the PDF, long text wraps inside its cell and a row taller than the remaining page continues on the next page; no text is cut.

## Clarifications

### Session 2026-11-11

- Q: Confirm that the issue's background generation, 403 and expiring-link criteria are out of #678 (frontend-only, 100 rows). → A: Confirmed by the updated issue published on 2026-11-11, which lists them as out of scope (AC-15: changed, marker removed; A5 updated)
- Fix: AC-6 now says both the CSV header and the PDF table header show the columns (AC-6: changed)
- Fix: AC-10 is now provable by a test, as the file starting with a UTF-8 byte-order mark instead of "opens in a spreadsheet" (AC-10: changed)
- Fix: AC-12 neutralizes every cell that starts with "=", "+", "-" or "@", not only comments, as the issue says (AC-12: changed)
- Fix: rows follow the order of the table (AC-17: added)
- Fix: the Export control cannot be used again while a file is being generated (AC-15: changed)
- Evidence: the Assessments route allows exactly Administrator, Officer and Professional, so no extra role AC is needed; comments are limited to 4000 characters in the backend (A10); file names follow the existing export naming (A9)
- Status after this session: Clarified

## Validation log

### 2026-11-11 – Round 1

Required: the change modifies an FE screen (Assessments list). Run the app with the local stack (AGENTS.md §3.4) or `npm start` in `ERAS-FE/`, and open the Assessments page.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1 | As Officer with 3+ assessments, open Assessments and click Export | Export button next to "Create Assessment"; menu shows CSV and PDF | ✅ | |
| AC-2 | As a user with no assessments, open Assessments | Empty state, no Export button | ✅ | |
| AC-3 | With 11+ assessments (more than one page), export CSV | File has 1 header row and one row per assessment, not only the 10 of the page | ✅ | |
| AC-4 | With 11+ assessments, on page 2, export PDF | PDF table lists every assessment | ✅ | |
| AC-5 | Export as Administrator, Officer and Professional | Each file has only that role's list (Admin all, Officer created by them, Professional assigned to them) | ✅ | |
| AC-6 | Open the CSV and the PDF | Columns Date, Submitter, Service, Professional, Student, Status, Comment, in that order, no Actions | ✅ | |
| AC-7 | Compare a row with the table | Date MM/dd/yyyy, names resolved, service capitalized, "In Progress" label | ✅ | |
| AC-8 | Export an assessment whose comment is longer than 60 characters | Full comment, no "..." | ✅ | |
| AC-9 | Export an assessment with several students | Student cell lists all names separated by commas | ✅ | |
| AC-10 | Open the CSV in Excel with names/comments that have accents (á, ñ, é) | Accents show correctly | ✅ | |
| AC-11 | Export an assessment whose comment has commas, quotes and a line break | One row, field intact in Excel | ✅ | |
| AC-12 | Create an assessment with comment `=1+1`, export CSV, open in Excel | Cell shows the text `=1+1`, not a result | ✅ | |
| AC-13 | Export PDF | First page shows "Assessments", export date/time, your name, "Filters: None" | | |
| AC-14 | Export PDF with enough rows for 2+ pages | Column headers repeat on every page | ✅ | |
| AC-15 | Click CSV or PDF | Progress indication while generating; Export button disabled until the download ends, then enabled | ✅ | |
| AC-16 | Simulate a failure (for example block `jspdf-autotable` chunk in DevTools network and export PDF) | Error toast, no file, no stuck progress indication | ✅ | |
| AC-17 | Compare file order with the table (page 1, 2, 3) | Rows follow the table order | ✅ | |
| Side effects | Use Create, Edit, View, Delete and paging on the list; open the status badge; use another screen with CSV/PDF export (for example Students list) | Everything behaves as before | ✅ | |
| Views | Narrow viewport (mobile width) | Header buttons still usable | ✅ | |

Approved by judithmarg-dev, 2026-11-11 (goal achieved, no side effects, no open errors; per-row results are in the table above; the AC-13 row has no result recorded and needs the developer's confirmation).

Verified 2026-11-11: no gaps, no drift, gates green
