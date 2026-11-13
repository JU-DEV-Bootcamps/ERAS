# Proposal

**Status:** Approved
**Plan:** Approved

## Why

Officers, Professionals and Administrators cannot take the Interventions list out of the app as a document to share, print or report on. Today the list only offers a CSV, through an icon button that differs from the Export control of the Assessments list. Issue: ERAS#679

## What Changes

- Replace the "Export CSV" icon button of the Interventions list with the same Export control used on the Assessments list, offering "CSV" and "PDF".
- Add the PDF export: every intervention that matches the active filters, in the order of the table, regardless of the page shown.
- The PDF uses the same columns, labels and order as the table (without Actions), with the full comment and the names of all students.
- The PDF has a header (title, export date and time, exporting user, applied filters) and a table whose column headers repeat on every page.
- The Export control is shown only while the list has interventions; with no assessment selected or no match for the filters, only the empty-state message is shown, as today.
- The user sees progress while the PDF is generated and an error message if it fails.

**Out of scope:** changing the content of the existing CSV file (only its entry point moves, see A2); backend export endpoints, background generation above a row limit and expiring download links (see A1); exporting Assessments, Students or any other list; exporting from the student profile modal; Excel format; choosing columns; email or scheduled exports; new filters, search or sorting on the list; the backend ownership checks of the interventions list endpoints and the sort click on the Risk Level header text (see A8).

## Capabilities

### New Capabilities
- `intervention-export`: exporting the Interventions list as a file from one Export control (CSV and PDF).

### Modified Capabilities

## Impact

- **Submodules:** FE
- **Roles / who can do what:** `ERAS Administrator`, `ERAS Student Services Officer` and `ERAS Professional` may export, each only the interventions the list already shows them. No role rule changes.
- **API contract:** none. The export uses the interventions the screen already loads.
- **Data / migration:** no

## Assumptions

- A1: The PDF is generated in the browser from the data the list already loaded, as in ERAS#678 (ADR-0010). The criteria of the issue that assume a backend export (background generation above a row limit with a notification, an export endpoint with its own authorization and 403, authenticated download links that expire) are therefore not specified: no export endpoint or stored file exists to protect. The issue should be updated to list them as out of scope, as was done for ERAS#678.
- A2: The issue lists CSV as out of scope, and the list already has a CSV export. Using one Export control with "CSV" and "PDF" was requested for consistency with Assessments. The CSV option produces the same file as today's icon button (same rows, columns and values); aligning its content with the PDF (labels, BOM, formula neutralization) is left for a separate change.
- A3: The issue's user story names Officers and Administrators; Professionals are included because they can already open the list and export its CSV, and ERAS#678 made the same choice. Guest cannot reach the page.
- A4: The list has no text search. Its filters are Assessment (required), Type, Status and Risk Level, and its only sorting is by Risk Level. The export honors exactly these.
- A5: Cell values are the ones the table shows (dates as MM/dd/yyyy, the labels of the Type, Mode, Risk Level, End Risk Level and Status badges, "—" for an empty value), except that Comment and Student are exported in full. Badge colors are not reproduced.
- A6: The PDF is named "interventions" followed by the export date and time, following the naming of the Assessments export. The export date and time use the user's local time.
- A7: The worst case is in the order of a few hundred interventions for one assessment. Long text wraps inside its cell and a row taller than the remaining page continues on the next page; no text is cut.
- A8: Found while reading the code and not changed here: the general interventions list endpoint accepts any ERAS role without an ownership check and the by-creator endpoint does not check that the caller is that creator, so role scoping of the list relies on the screen; and clicking the Risk Level header text does not sort (only its icon does). Each needs its own change.

## Clarifications

### Session 2026-11-12
Questions asked: 4/5. Deferred: none.
- Q: What does the CSV option produce? A: the same file as today; only the entry point changes (A2).
- Q: Can Professionals export? A: yes, included (A3).
- Q: Empty result, confirmation for CSV too? A: current behavior; with no match the Export control is not shown, only the empty-state text. The confirmation and empty PDF (old AC-16, AC-17, AC-18) were dropped and AC-21 added.
- Q: No assessment selected? A: chosen "disabled", but the code shows no control at all in that state and the user asked to keep current behavior, so AC-2 now says "not shown".
- Direct fix: removed the empty-result confirmation requirement; renumbered assumptions A5-A8 (old A5 and A6 settled).

## Validation log

### 2026-11-12 – Round 1

Checklist for the manual validation of the Interventions export (FE only). Run it at `/assessments/interventions` with the local stack (`AGENTS.md` §3.4) or the `run` skill. Test as an Administrator, an Officer and a Professional.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1 | Select an assessment with interventions and open the Export control | Menu shows "CSV" and "PDF"; the old "Export CSV" icon button is gone | ✅ | |
| AC-2 | Open the page without selecting an assessment | "Select an assessment" is shown and no Export control is shown | ✅ | |
| AC-21 | Apply filters that match nothing | "No interventions match the current filters" is shown and no Export control is shown | ✅ | |
| AC-3 | Choose "CSV" with filters applied | The same CSV file as before is downloaded (same columns, values and rows) | ✅ | |
| AC-4 | Apply Type "Group" and Risk Level "High", then export PDF | The PDF contains only the matching rows | ✅ | |
| AC-5 | Use an assessment with more than 10 interventions (several pages), then export PDF | The PDF has all matching rows, not only the page shown | ✅ | |
| AC-6 | Sort by Risk Level (icon), then export PDF | The PDF rows follow the table order | ✅ | |
| AC-7 | Log in as a Professional and export PDF | The PDF has only the interventions shown in that Professional's list | ✅ | |
| AC-8 | Export PDF and read the table header | Columns in order: Date, Type, Mode, Activity, Professional, Student, Area, Risk Level, End Risk Level, Status, Comment; no Actions | ✅ | |
| AC-9 | Compare one row of the PDF with the table | Date as MM/dd/yyyy, badge labels, "—" for empty values | ✅ | |
| AC-10 | Use an intervention with a comment longer than 60 characters | The PDF shows the full comment, without "..." | ✅ | |
| AC-11 | Use a group intervention with more than 2 students | The PDF lists every student name separated by commas | ✅ | |
| AC-12 | Export PDF with an assessment and filters | The first page has "Interventions", the export date and time, the user name and the applied filters | ✅ | The headerLines in buildPdf of interventions, should look with "negrita" |
| AC-13 | Export PDF with no Type, Status or Risk Level selected | Only the Assessment filter is listed | ✅ | |
| AC-14 | Export PDF with enough rows for several pages | Column headers repeat at the top of every page | ✅ | |
| AC-15 | Use accented text such as "María Peña", "Sesión" and "año" | The accents appear correctly in the PDF | ✅ | |
| AC-19 | Export a large PDF and watch the export control | Progress is shown; the control is disabled until the download ends, then the progress is removed | ✅ | |
| AC-20 | Make the export fail (for example, block the PDF build in devtools) | Error toast "The file could not be generated. Please try again."; no file is downloaded | ✅ | |

Side effects to check: the other tabs and screens of the assessments module still work; the CSV of the Assessments list still downloads; the interventions table, paging, sorting, filters and the detail panel still behave as before.

Approved by the developer, 2026-11-12. With the approval the developer asked for the labels of the PDF header lines (AC-12) to be bold; it is presentation only (the text of the lines is unchanged), done directly in `TablePdfService` as an opt-in `boldHeaderLabels` used by the Interventions export, so the spec and the Assessments PDF are untouched.

Verified 2026-11-12: no gaps, no drift, gates green
