# Design

## Context

FE only. The Interventions list (`ERAS-FE/src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.*`) already holds everything the export needs in memory: `filteredInterventions()` (after the filters), `sortedInterventions()` (after the Risk Level sort, before paging), the `assessment()` signal and the `appliedFilters` input. Its page header today has an "Export CSV" icon button (`exportToCSV()`, through `CsvService`), shown only in the branch of the template where the list has rows, so no control exists with no assessment or no match (AC-2 and AC-21 keep that).

ERAS#678 (archived `2026-11-12-678-export-assessments-list`) already built what this change reuses: `core/services/exports/table-pdf.service.ts` (`buildDocument` / `download`, A4 landscape, `showHead: 'everyPage'`), `export-state.service.ts` (progress overlay), `core/utils/file/file-name.ts`, `ASSESSMENT_EXPORT_MESSAGES` in `core/constants/messages.ts`, and the inline Export `mat-menu` of `assessment-list.component.html`. The PDF is built in the browser with `jspdf-autotable` (ADR-0010). No BE, API or schema change.

## Goals / Non-Goals

**Goals:**
- Replace the icon button by the Assessments-style Export menu with CSV and PDF (AC-1, AC-2, AC-3, AC-21).
- Export to PDF the sorted, filtered, unpaged rows with the table's columns and values, comment and students in full (AC-4 to AC-11).
- PDF header with title, local date and time, user and applied filters; headers on every page; accents intact (AC-12 to AC-15).
- Progress and error handling as in Assessments (AC-19, AC-20).

**Non-Goals:**
- Changing the CSV content, the existing `exportToCSV()` or `CsvService`.
- Extracting a shared Export menu component: the Assessments control is inline markup, and a refactor of that list is outside this change.

## Decisions

### D1. Build the PDF in the browser with the shared `TablePdfService`
**Choice:** a new `InterventionExportService` (`modules/assessments/services/`) builds the title, header lines, columns and rows and delegates to `TablePdfService.buildDocument`/`download`, like `AssessmentExportService` does. File name `interventions_<yyyyMMdd>_<HHmmss>` via `FileNameUtils.generateFileName('interventions')`.
**Alternative:** a BE export endpoint → no stored file or large volume to justify it (proposal A1, A7), and #678 chose the same.
**ADR:** ADR-0010

### D2. One source for columns and cell values
**Choice:** `intervention-export.columns.ts` (key and label, in table order, no Actions) and `utils/intervention-export-rows.ts` (`buildInterventionExportRows(rows)` → `string[][]`). Values mirror the table: date `MM/dd/yyyy` via `formatDate`, Type, Mode, Status and Risk labels as the pill badge shows them, activity and area through `getOptionLabel`, "—" for empty, full `comments`, every student name joined with ", " (names missing from the lookup are skipped).
**Alternative:** reuse the CSV mapping (`ExportableIntervention`) → it has ids, emails and raw values, not the table's labels.

### D3. Export the table's order and filters, not the page
**Choice:** the component passes `sortedInterventions()` to the PDF, so the active filters and the Risk Level sort apply and paging does not. Role scoping stays where it is today (`interventions-fetch.strategies.ts` decides what the list loads), so the export never widens it (AC-7).
**Alternative:** refetch from the API → would bypass the screen's filters and sort.

### D4. Applied filters worded by the export service
**Choice:** `buildFilterLines(appliedFilters, assessment)` returns one line per filter with a selection: Assessment from `assessment()` as `MM/dd/yyyy – <service> (<status label>)` (same wording as the filter options), Type and Risk Level as their values joined with ", ", Status through `ASSESSMENT_STATUS_LABELS`. Empty or null filters are not listed (AC-13).
**Alternative:** pass the option labels down from `interventions.component.ts` → adds an input only for the PDF; the values already carry their labels.

### D5. Same progress and error handling as Assessments
**Choice:** the PDF option calls `ExportStateService.startExport('pdf', rows.length, { indeterminate: true, background: true })`, yields one tick so the overlay paints, builds and downloads, shows an error toast on failure and calls `endExport()` in `finally`. The menu button is `[disabled]="exportState.isExporting()"`. The CSV option keeps calling the existing `exportToCSV()` unchanged (AC-3). Messages go in a new `INTERVENTION_EXPORT_MESSAGES` (`core/constants/messages.ts`) that reuses the error wording of `ASSESSMENT_EXPORT_MESSAGES`.
**Alternative:** keep the `isGenerating` signal only → it gives no progress indication.

## Changes by layer

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Columns | New: column keys and labels in table order, without Actions | `src/app/modules/assessments/models/intervention-export.columns.ts` | AC-8 |
| Rows | New: `buildInterventionExportRows` (values as in the table, full comment, all students, "—") | `src/app/modules/assessments/utils/intervention-export-rows.ts` | AC-9, AC-10, AC-11, AC-15 |
| Service | New: `InterventionExportService` (`buildPdf`, `exportPdf`, filter lines, header with title, local date-time and `UserDataService` full name) over `TablePdfService` | `src/app/modules/assessments/services/intervention-export.service.ts` | AC-12, AC-13, AC-14 |
| Component | Replace the icon button by the Export menu (CSV, PDF) in `.page-header`; add `exportInterventions(type)`; PDF uses `sortedInterventions()`, progress and error toast | `.../interventions-list/intervention-list.component.{ts,html}` | AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, AC-7, AC-19, AC-20, AC-21 |
| Messages | New `INTERVENTION_EXPORT_MESSAGES` (button, CSV, PDF, title, header labels, error) | `src/app/core/constants/messages.ts` | AC-1, AC-12, AC-20 |

## API contract
No API change.

## Data and migration
No schema change.

## Test strategy

Jasmine specs next to the unit. The component specs go in the existing `intervention-list.component.spec.ts`; the content specs go in a new `intervention-export.service.spec.ts` that spies on `TablePdfService.buildDocument` (rows, columns, header lines) and uses a real `jsPDF` only for AC-14.

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | FE | `src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts` | `[679-export-interventions-list/AC-1] Export menu offers CSV and PDF and the icon button is gone` |
| AC-2 | FE | same spec | `[679-export-interventions-list/AC-2] shows no Export control until an assessment is selected` |
| AC-3 | FE | same spec | `[679-export-interventions-list/AC-3] CSV option runs the existing CSV export with the matching rows` |
| AC-4 | FE | same spec | `[679-export-interventions-list/AC-4] PDF receives only the 12 rows matching the filters` |
| AC-5 | FE | same spec | `[679-export-interventions-list/AC-5] PDF receives all 25 rows while the table shows page 1 of 3` |
| AC-6 | FE | same spec | `[679-export-interventions-list/AC-6] PDF rows keep the Risk Level order of the table` |
| AC-7 | FE | same spec | `[679-export-interventions-list/AC-7] PDF has only the 3 interventions of the professional's list` |
| AC-8 | FE | `src/app/modules/assessments/services/intervention-export.service.spec.ts` | `[679-export-interventions-list/AC-8] PDF columns match the table without Actions` |
| AC-9 | FE | same spec | `[679-export-interventions-list/AC-9] cell values match what the table shows` |
| AC-10 | FE | same spec | `[679-export-interventions-list/AC-10] comment is exported in full` |
| AC-11 | FE | same spec | `[679-export-interventions-list/AC-11] student cell lists all names` |
| AC-12 | FE | same spec | `[679-export-interventions-list/AC-12] PDF shows title, date and time, user and applied filters` |
| AC-13 | FE | same spec | `[679-export-interventions-list/AC-13] filters without a selection are not listed` |
| AC-14 | FE | same spec | `[679-export-interventions-list/AC-14] PDF has several pages and repeats headers` |
| AC-15 | FE | same spec | `[679-export-interventions-list/AC-15] accented characters reach the PDF unchanged` |
| AC-19 | FE | `intervention-list.component.spec.ts` | `[679-export-interventions-list/AC-19] shows progress and blocks the control until the file is downloaded` |
| AC-20 | FE | same spec | `[679-export-interventions-list/AC-20] a failed export shows an error and no file` |
| AC-21 | FE | same spec | `[679-export-interventions-list/AC-21] shows no Export control when no intervention matches` |

Extra edge-case tests carry no AC tag. Coverage gates: FE >= 15% (AGENTS.md section 8.7).

## Risks / Trade-offs

- [Existing specs of the "Export CSV" icon button in `intervention-list.component.spec.ts` break when the button is replaced] → update them in the same task as AC-1; they carry no AC tag and the CSV logic is untouched.
- [Standard jsPDF fonts cover Latin-1, not every Unicode character] → same limit as #678; AC-15 checks the accented characters of the spec, other scripts are not promised.
- [Page-count and header-per-page checks (AC-14) are fragile with the real jsPDF] → check `getNumberOfPages()` and the column label in each page's content, as the #678 spec does; spy only on `buildDocument` for the rest.
- [The "—" and badge labels are duplicated from the template and the badge] → the rows util is the single export source; the table keeps its own template (changing it is out of scope).

## Follow-ups
- The general interventions endpoint (any ERAS role) and the by-creator endpoint (no check that the caller is that creator) have no ownership check, so scoping relies on the screen (proposal A8). Needs its own BE change.
- Clicking the Risk Level header text does not sort, only its icon does (`(click)="('risk')"` in `intervention-list.component.html`) (proposal A8).
- Align the CSV content with the PDF and the Assessments CSV (labels, UTF-8 BOM, formula neutralization) (proposal A2).
- Extract the Export menu used by Assessments and Interventions into a shared component.
