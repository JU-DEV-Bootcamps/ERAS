# Tasks

## 1. Frontend (FE)

- [x] 1.1 Write the spec `[679-export-interventions-list/AC-8] PDF columns match the table without Actions` for (AC-8) in `ERAS-FE/src/app/modules/assessments/services/intervention-export.service.spec.ts` and verify it fails
- [x] 1.2 Create `ERAS-FE/src/app/modules/assessments/models/intervention-export.columns.ts` (Date, Type, Mode, Activity, Professional, Student, Area, Risk Level, End Risk Level, Status, Comment) and the `InterventionExportService` with `buildPdf` in `ERAS-FE/src/app/modules/assessments/services/intervention-export.service.ts`, delegating to `TablePdfService` for (AC-8) and verify the spec from 1.1 passes
- [x] 1.3 Write the spec `[679-export-interventions-list/AC-9] cell values match what the table shows` for (AC-9) in `ERAS-FE/src/app/modules/assessments/services/intervention-export.service.spec.ts` and verify it fails
- [x] 1.4 Create `ERAS-FE/src/app/modules/assessments/utils/intervention-export-rows.ts` with date `MM/dd/yyyy`, badge labels, `getOptionLabel` for activity and area and "—" for empty values for (AC-9) and verify the spec from 1.3 passes
- [x] 1.5 Write the spec `[679-export-interventions-list/AC-10] comment is exported in full` for (AC-10) in `ERAS-FE/src/app/modules/assessments/services/intervention-export.service.spec.ts` and verify it fails
- [x] 1.6 Export the full `comments` in `intervention-export-rows.ts` for (AC-10) and verify the spec from 1.5 passes
- [x] 1.7 Write the spec `[679-export-interventions-list/AC-11] student cell lists all names` for (AC-11) in `ERAS-FE/src/app/modules/assessments/services/intervention-export.service.spec.ts` and verify it fails
- [x] 1.8 Join every student name with ", " in `intervention-export-rows.ts` for (AC-11) and verify the spec from 1.7 passes
- [x] 1.9 Write the spec `[679-export-interventions-list/AC-12] PDF shows title, date and time, user and applied filters` for (AC-12) in `ERAS-FE/src/app/modules/assessments/services/intervention-export.service.spec.ts` and verify it fails
- [x] 1.10 Add the header to `buildPdf` (title "Interventions", local date-time, user full name from `UserDataService`, one line per applied filter) and `INTERVENTION_EXPORT_MESSAGES` in `ERAS-FE/src/app/core/constants/messages.ts` for (AC-12) and verify the spec from 1.9 passes
- [x] 1.11 Write the spec `[679-export-interventions-list/AC-13] filters without a selection are not listed` for (AC-13) in `ERAS-FE/src/app/modules/assessments/services/intervention-export.service.spec.ts` and verify it fails
- [x] 1.12 Skip filters with no selection in the filter lines of `intervention-export.service.ts` for (AC-13) and verify the spec from 1.11 passes
- [x] 1.13 Write the spec `[679-export-interventions-list/AC-14] PDF has several pages and repeats headers` for (AC-14) in `ERAS-FE/src/app/modules/assessments/services/intervention-export.service.spec.ts` and verify it fails
- [x] 1.14 Add `exportPdf` (file name `interventions_<date>_<time>`) rendering all rows through `TablePdfService` with headers on every page for (AC-14) and verify the spec from 1.13 passes
- [x] 1.15 Write the spec `[679-export-interventions-list/AC-15] accented characters reach the PDF unchanged` for (AC-15) in `ERAS-FE/src/app/modules/assessments/services/intervention-export.service.spec.ts` and verify it fails
- [x] 1.16 Keep accented and special characters unchanged in the rows util and the PDF text for (AC-15) and verify the spec from 1.15 passes
- [x] 1.17 Write the spec `[679-export-interventions-list/AC-1] Export menu offers CSV and PDF and the icon button is gone` for (AC-1) in `ERAS-FE/src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts` and verify it fails
- [x] 1.18 Replace the "Export CSV" icon button by the Export `mat-menu` (CSV, PDF) in `.page-header` of `ERAS-FE/src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.html` using `INTERVENTION_EXPORT_MESSAGES`, and update the existing icon-button specs for (AC-1) and verify the spec from 1.17 passes
- [x] 1.19 Write the spec `[679-export-interventions-list/AC-2] shows no Export control until an assessment is selected` for (AC-2) in `ERAS-FE/src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts` and verify it fails
- [x] 1.20 Keep the Export control only in the non-empty branch of the template, so it is not shown with no assessment selected for (AC-2) and verify the spec from 1.19 passes
- [x] 1.21 Write the spec `[679-export-interventions-list/AC-21] shows no Export control when no intervention matches` for (AC-21) in `ERAS-FE/src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts` and verify it fails
- [x] 1.22 Confirm the control stays out of the "No interventions match" branch for (AC-21) and verify the spec from 1.21 passes
- [x] 1.23 Write the spec `[679-export-interventions-list/AC-3] CSV option runs the existing CSV export with the matching rows` for (AC-3) in `ERAS-FE/src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts` and verify it fails
- [x] 1.24 Wire the CSV option to the existing `exportToCSV()` in `ERAS-FE/src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.ts` for (AC-3) and verify the spec from 1.23 passes
- [x] 1.25 Write the spec `[679-export-interventions-list/AC-4] PDF receives only the 12 rows matching the filters` for (AC-4) in `ERAS-FE/src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts` and verify it fails
- [x] 1.26 Add `exportInterventions(type)` that passes the filtered rows of `sortedInterventions()`, `appliedFilters()` and `assessment()` to `InterventionExportService.exportPdf` for (AC-4) and verify the spec from 1.25 passes
- [x] 1.27 Write the spec `[679-export-interventions-list/AC-5] PDF receives all 25 rows while the table shows page 1 of 3` for (AC-5) in `ERAS-FE/src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts` and verify it fails
- [x] 1.28 Confirm the PDF gets all rows of `sortedInterventions()`, not `pagedInterventions()` for (AC-5) and verify the spec from 1.27 passes
- [x] 1.29 Write the spec `[679-export-interventions-list/AC-6] PDF rows keep the Risk Level order of the table` for (AC-6) in `ERAS-FE/src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts` and verify it fails
- [x] 1.30 Confirm the PDF keeps the order of `sortedInterventions()` for (AC-6) and verify the spec from 1.29 passes
- [x] 1.31 Write the spec `[679-export-interventions-list/AC-7] PDF has only the 3 interventions of the professional's list` for (AC-7) in `ERAS-FE/src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts` and verify it fails
- [x] 1.32 Confirm the PDF only uses the rows the list loaded through the role-based fetch strategy for (AC-7) and verify the spec from 1.31 passes
- [x] 1.33 Write the spec `[679-export-interventions-list/AC-19] shows progress and blocks the control until the file is downloaded` for (AC-19) in `ERAS-FE/src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts` and verify it fails
- [x] 1.34 Call `ExportStateService.startExport`/`endExport` (indeterminate, background) around the PDF export and disable the menu button while `isExporting()` for (AC-19) and verify the spec from 1.33 passes
- [x] 1.35 Write the spec `[679-export-interventions-list/AC-20] a failed export shows an error and no file` for (AC-20) in `ERAS-FE/src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts` and verify it fails
- [x] 1.36 Catch a failed PDF build, show the error toast with `INTERVENTION_EXPORT_MESSAGES.ERROR_MESSAGE` and end the export in `finally` for (AC-20) and verify the spec from 1.35 passes

## 2. Verification

- [x] 2.1 FE gates pass in `ERAS-FE/`: `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (>= 15%), `npm run build` (AGENTS.md section 8.7)
- [x] 2.2 The AC traceability check (AGENTS.md section 8.6) shows exactly 1 test per AC on the FE side, and `openspec validate 679-export-interventions-list --strict` passes

## Traceability
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | Export control offers CSV and PDF | FE | src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts › [679-export-interventions-list/AC-1] Export menu offers CSV and PDF and the icon button is gone |
| AC-2 | Export control is not shown until an assessment is selected | FE | src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts › [679-export-interventions-list/AC-2] shows no Export control until an assessment is selected |
| AC-3 | CSV option downloads the existing CSV | FE | src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts › [679-export-interventions-list/AC-3] CSV option runs the existing CSV export with the matching rows |
| AC-4 | Only rows matching the filters are exported | FE | src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts › [679-export-interventions-list/AC-4] PDF receives only the 12 rows matching the filters |
| AC-5 | All matching rows are exported, not only the current page | FE | src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts › [679-export-interventions-list/AC-5] PDF receives all 25 rows while the table shows page 1 of 3 |
| AC-6 | Rows keep the sorting of the table | FE | src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts › [679-export-interventions-list/AC-6] PDF rows keep the Risk Level order of the table |
| AC-7 | Export is limited to the user's own list | FE | src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts › [679-export-interventions-list/AC-7] PDF has only the 3 interventions of the professional's list |
| AC-8 | Columns, labels and order match the table | FE | src/app/modules/assessments/services/intervention-export.service.spec.ts › [679-export-interventions-list/AC-8] PDF columns match the table without Actions |
| AC-9 | Cell values match what the table shows | FE | src/app/modules/assessments/services/intervention-export.service.spec.ts › [679-export-interventions-list/AC-9] cell values match what the table shows |
| AC-10 | Comment is exported in full | FE | src/app/modules/assessments/services/intervention-export.service.spec.ts › [679-export-interventions-list/AC-10] comment is exported in full |
| AC-11 | All student names are exported | FE | src/app/modules/assessments/services/intervention-export.service.spec.ts › [679-export-interventions-list/AC-11] student cell lists all names |
| AC-12 | PDF shows title, date and time, user and applied filters | FE | src/app/modules/assessments/services/intervention-export.service.spec.ts › [679-export-interventions-list/AC-12] PDF shows title, date and time, user and applied filters |
| AC-13 | Filters without a selection are not listed | FE | src/app/modules/assessments/services/intervention-export.service.spec.ts › [679-export-interventions-list/AC-13] filters without a selection are not listed |
| AC-14 | Column headers repeat on every page | FE | src/app/modules/assessments/services/intervention-export.service.spec.ts › [679-export-interventions-list/AC-14] PDF has several pages and repeats headers |
| AC-15 | Accented and special characters are displayed correctly | FE | src/app/modules/assessments/services/intervention-export.service.spec.ts › [679-export-interventions-list/AC-15] accented characters reach the PDF unchanged |
| AC-19 | Progress is shown while generating | FE | src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts › [679-export-interventions-list/AC-19] shows progress and blocks the control until the file is downloaded |
| AC-20 | A failed export shows an error | FE | src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts › [679-export-interventions-list/AC-20] a failed export shows an error and no file |
| AC-21 | Export control is not shown when no intervention matches | FE | src/app/modules/assessments/components/interventions/interventions-list/intervention-list.component.spec.ts › [679-export-interventions-list/AC-21] shows no Export control when no intervention matches |
