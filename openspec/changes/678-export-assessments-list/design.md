# Design

## Context

Frontend-only change (see `proposal.md`). What exists today and shapes the approach:

- `ERAS-FE/src/app/modules/assessments/components/assessment-list/assessment-list.component.ts` holds the full list in the `assessments()` signal (`AssessmentRowViewModel[]`: `submitterDisplay`, `professionalDisplay` and `students` are already resolved) and shows a slice through `pagedAssessments()`. The role-based list comes from `AssessmentFetchStrategies` (`modules/assessments/fetch-strategies/assessments-fetch.strategies.ts`), so `assessments()` is already "the user's own list".
- The template shows the "Create Assessment" button in `.page-header` only in the non-empty branch; the empty branch only offers "Create Assessment", so the Export control cannot appear on an empty list.
- The table renders Date (`date: 'MM/dd/yyyy'`), Service (`titlecase`), Status (label map inside `AssessmentStatusBadgeComponent`: `InProgress` → "In Progress") and a 60-character `commentPreview`.
- `ExportStateService` (root) and `<app-export-loading-overlay>` (mounted once in `app.component.html`) already provide the in-progress indication; `ToastNotificationService.showToast` shows errors.
- `CsvService` extends `BaseExportService`, whose public `downloadTextFile(text, fileName)` writes a Blob **without** a byte-order mark, and `CSV_CONFIG` (`core/constants/csv.ts`) has no formula escaping. Both stay unchanged (proposal A6).
- `jspdf` ^4 and `papaparse` ^5.5.1 are installed; `jspdf-autotable` is not. The legacy `PdfService` (html2canvas) is not touched.
- The exporting user comes from `UserDataService.user()` (`firstName`, `lastName`).

## Goals / Non-Goals

**Goals:**
- Cover AC-1..AC-17 with files built in the browser from the already loaded full list.
- Keep one column definition for the table and both files, and give the export engines plain columns and rows so an engine can be replaced later.

**Non-Goals:**
- No change to `CsvService`, `PdfService`, `BaseExportService`, `ExportStateService` or the overlay.
- No generic "export any table" feature or refactor of `list.component`.

## Decisions

### D1. Vector PDF with `jspdf-autotable` on top of the existing `jspdf`
**Choice:** add `jspdf-autotable` (new runtime dependency) and build the PDF as real text with `autoTable` (automatic page breaks, `showHead: 'everyPage'`, wrapped cells), loaded with dynamic `import()` so it stays out of the main bundle.
**Alternative:** keep html2canvas snapshots (slow, image-only, cannot include hidden rows); backend QuestPDF/Chromium (new infrastructure, names are resolved in the FE) → not needed for 100 rows.
**ADR:** ADR-0010

### D2. One column definition drives the table order and both files
**Choice:** a constant `ASSESSMENT_EXPORT_COLUMNS` (`key`, `label`) in a new `modules/assessments/models/assessment-export.columns.ts`: Date, Submitter, Service, Professional, Student, Status, Comment. The list component builds `displayedColumns` from its keys plus `'actions'`; both exports use the labels. The table header text in the template is unchanged.
**Alternative:** repeat the labels in the export → they drift.

### D3. A pure mapper turns rows into plain strings
**Choice:** `buildAssessmentExportRows(rows)` in new `modules/assessments/utils/assessment-export-rows.ts` returns `string[][]` in column order, in the order of `assessments()`: date with `formatDate(…, 'MM/dd/yyyy', 'en-US')`, Submitter/Professional from `submitterDisplay`/`professionalDisplay`, Service with `TitleCasePipe`, Status via a label map, full `comments` (empty → "—", as the table), Student = `students` names joined with ", " (no count, no ids). The status label map is moved out of `AssessmentStatusBadgeComponent` to an exported constant in new `modules/assessments/models/assessment-status-labels.ts`, and the badge reuses it (one source for AC-7).
**Alternative:** read the rendered DOM → slow and loses the full values.

### D4. CSV: same Papa + `CSV_CONFIG` + `downloadTextFile` path, in a new service
**Choice:** new `AssessmentExportService` (`modules/assessments/services/assessment-export.service.ts`) extends `BaseExportService` (extension `csv`), runs `Papa.unparse` with `{ ...CSV_CONFIG, escapeFormulae: true }`, prepends `'﻿'` and calls the inherited `downloadTextFile`. `escapeFormulae` prefixes a single quote to any cell starting with `=`, `+`, `-`, `@` (also tab and carriage return) and quotes fields with commas, quotes and line breaks as Papa does. File name `FileNameUtils.generateFileName('assessments')`.
**Alternative:** call `CsvService.exportToCSV` → cannot add the BOM or escaping without changing the shared service, which the user asked to keep.

### D5. Table PDF service takes plain data
**Choice:** new `TablePdfService` (`core/services/exports/table-pdf.service.ts`) with `buildDocument({ title, exportedAt, exportedBy, filtersText, columns, rows })` returning the `jsPDF` doc (landscape A4; title, "Exported: …", "Exported by: …", "Filters: …", then `autoTable`) and `download(doc, fileName)` calling `doc.save`. `AssessmentExportService.exportPdf` passes `title: 'Assessments'`, local date-time, `UserDataService.user()` full name and `filtersText: 'None'`. Splitting build from save lets tests inspect the document.
**Alternative:** put PDF code in the component → harder to swap the engine.

### D6. Progress, single-flight and errors
**Choice:** the component calls `ExportStateService.startExport(type, count)`, yields one macrotask (`setTimeout(0)`) so the overlay paints, runs the export in `try`, shows an error toast in `catch` (no file saved), and always calls `endExport()` in `finally`. The Export button is `[disabled]="exportState.isExporting()"`.
**Alternative:** web worker → unnecessary at 100 rows.

## Changes by layer

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Dependency | add `jspdf-autotable` | `package.json`, `package-lock.json` | AC-4, AC-13, AC-14 |
| Columns / labels | column definition and status label map; badge reuses the map | `modules/assessments/models/assessment-export.columns.ts` (new), `modules/assessments/models/assessment-status-labels.ts` (new), `assessment-status-badge.component.ts` | AC-6, AC-7 |
| Mapper | rows → strings | `modules/assessments/utils/assessment-export-rows.ts` (new) | AC-6..AC-9, AC-17 |
| PDF engine | build and save | `core/services/exports/table-pdf.service.ts` (new) | AC-4, AC-13, AC-14 |
| Export service | CSV with BOM and escaping, PDF orchestration | `modules/assessments/services/assessment-export.service.ts` (new) | AC-3..AC-5, AC-10..AC-14 |
| Component | Export menu (CSV, PDF) in `.page-header`, progress and error handling | `assessment-list.component.ts/.html/.scss` | AC-1, AC-2, AC-3, AC-5, AC-15, AC-16, AC-17 |
| Messages | button label, error toast text | `core/constants/messages.ts` (`ASSESSMENT_EXPORT_MESSAGES`) | AC-1, AC-16 |

## API contract

No API change.

## Data and migration

No schema change.

## Test strategy

All ACs are `**Side:** FE`. Component specs use the existing `assessment-list.component.spec.ts`; the new service has its own spec. PDF tests inspect the `jsPDF` document returned by `buildDocument` (`doc.lastAutoTable`: body rows, `settings.showHead`; `doc.getNumberOfPages()`).

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | FE | `modules/assessments/components/assessment-list/assessment-list.component.spec.ts` | `[678-export-assessments-list/AC-1] shows an Export control offering CSV and PDF` |
| AC-2 | FE | same spec | `[678-export-assessments-list/AC-2] shows no Export control for an empty list` |
| AC-3 | FE | same spec | `[678-export-assessments-list/AC-3] CSV has all 25 rows while the table shows page 1 of 3` |
| AC-4 | FE | `modules/assessments/services/assessment-export.service.spec.ts` | `[678-export-assessments-list/AC-4] PDF table has all 100 rows` |
| AC-5 | FE | `assessment-list.component.spec.ts` | `[678-export-assessments-list/AC-5] exports only the 3 assessments of the professional's list` |
| AC-6 | FE | `assessment-export.service.spec.ts` | `[678-export-assessments-list/AC-6] CSV and PDF headers match the table columns without Actions` |
| AC-7 | FE | same spec | `[678-export-assessments-list/AC-7] cell values match what the table shows` |
| AC-8 | FE | same spec | `[678-export-assessments-list/AC-8] comment is exported in full` |
| AC-9 | FE | same spec | `[678-export-assessments-list/AC-9] student cell lists all names` |
| AC-10 | FE | same spec | `[678-export-assessments-list/AC-10] CSV starts with a UTF-8 BOM and keeps accents` |
| AC-11 | FE | same spec | `[678-export-assessments-list/AC-11] commas, quotes and line breaks are escaped` |
| AC-12 | FE | same spec | `[678-export-assessments-list/AC-12] formula-like cells get a leading single quote` |
| AC-13 | FE | same spec | `[678-export-assessments-list/AC-13] PDF shows title, date and time, user and filters` |
| AC-14 | FE | same spec | `[678-export-assessments-list/AC-14] PDF has several pages and repeats headers` |
| AC-15 | FE | `assessment-list.component.spec.ts` | `[678-export-assessments-list/AC-15] shows progress and blocks the control until the file is downloaded` |
| AC-16 | FE | same spec | `[678-export-assessments-list/AC-16] a failed export shows an error and no file` |
| AC-17 | FE | same spec | `[678-export-assessments-list/AC-17] rows keep the order of the table` |

Extra edge-case tests carry no AC tag. Coverage gate: FE >= 15% (AGENTS.md section 8.7).

## Risks / Trade-offs

- [Moving the status label map touches the badge] → the badge keeps the same labels; its existing spec must stay green.
- [`escapeFormulae` also prefixes cells starting with tab or carriage return] → harmless, stricter than AC-12; noted in the service.
- [A comment of 4000 characters makes a very tall PDF row] → `autoTable` wraps cell text and splits rows across pages (A10).
- [`jspdf-autotable` must match the installed `jspdf` 4.x] → pin a version compatible with jsPDF 4 and check it in the build (task 2.1).
- [The overlay shows "Generating PDF (estimated …)" text] → acceptable; the shared state service is not changed.

## Follow-ups

- `by-creator/{creatorSub}` and `by-professional/{professionalSub}` in `AssessmentsController` do not check that the route value is the authenticated user (related to #545). Not changed here.
- Other lists (Interventions, Students) reuse `TablePdfService` in separate tickets.
- If volume grows, move PDF generation to the backend; `AssessmentExportService` receives plain columns and rows so the engine can change.
