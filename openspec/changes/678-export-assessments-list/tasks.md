# Tasks

## 1. Frontend (FE)

- [x] 1.1 Add the `jspdf-autotable` dependency (version compatible with `jspdf` 4.x) in `ERAS-FE/package.json` and verify `npm ci` and `npm run build` still succeed
- [x] 1.2 Write the spec `[678-export-assessments-list/AC-6] CSV and PDF headers match the table columns without Actions` for (AC-6) in `ERAS-FE/src/app/modules/assessments/services/assessment-export.service.spec.ts` and verify it fails
- [x] 1.3 Create `assessment-export.columns.ts`, `assessment-status-labels.ts` (badge reuses it), `assessment-export-rows.ts` and the PDF engine `core/services/exports/table-pdf.service.ts` for (AC-6) and verify the badge spec stays green
- [x] 1.4 Write the spec `[678-export-assessments-list/AC-7] cell values match what the table shows` for (AC-7) in `assessment-export.service.spec.ts` and verify it fails
- [x] 1.5 Implement date, service, status and name formatting in `assessment-export-rows.ts` for (AC-7) and verify the spec from 1.4 passes
- [x] 1.6 Write the spec `[678-export-assessments-list/AC-8] comment is exported in full` for (AC-8) in `assessment-export.service.spec.ts` and verify it fails
- [x] 1.7 Export the full comment, "—" when empty, in `assessment-export-rows.ts` for (AC-8) and verify the spec from 1.6 passes
- [x] 1.8 Write the spec `[678-export-assessments-list/AC-9] student cell lists all names` for (AC-9) in `assessment-export.service.spec.ts` and verify it fails
- [x] 1.9 Join all student names with ", " in `assessment-export-rows.ts` for (AC-9) and verify the spec from 1.8 passes
- [x] 1.10 Write the spec `[678-export-assessments-list/AC-10] CSV starts with a UTF-8 BOM and keeps accents` for (AC-10) in `assessment-export.service.spec.ts` and verify it fails
- [x] 1.11 Create `ERAS-FE/src/app/modules/assessments/services/assessment-export.service.ts` (`exportCsv`: Papa with `CSV_CONFIG`, BOM, `downloadTextFile`, name `assessments_<date>_<time>`) for (AC-10) and verify the spec from 1.10 passes
- [x] 1.12 Write the spec `[678-export-assessments-list/AC-11] commas, quotes and line breaks are escaped` for (AC-11) in `assessment-export.service.spec.ts` and verify it fails
- [x] 1.13 Confirm the Papa output escapes the field and keeps one data row for (AC-11) and verify the spec from 1.12 passes
- [x] 1.14 Write the spec `[678-export-assessments-list/AC-12] formula-like cells get a leading single quote` for (AC-12) in `assessment-export.service.spec.ts` and verify it fails
- [x] 1.15 Enable `escapeFormulae` in `exportCsv` for (AC-12) and verify the spec from 1.14 passes
- [x] 1.16 Write the spec `[678-export-assessments-list/AC-13] PDF shows title, date and time, user and filters` for (AC-13) in `assessment-export.service.spec.ts` and verify it fails
- [x] 1.17 Implement `TablePdfService.buildDocument` header block and `AssessmentExportService.exportPdf` (title "Assessments", local date-time, user full name from `UserDataService`, "Filters: None") for (AC-13) and verify the spec from 1.16 passes
- [x] 1.18 Write the spec `[678-export-assessments-list/AC-4] PDF table has all 100 rows` for (AC-4) in `assessment-export.service.spec.ts` and verify it fails
- [x] 1.19 Render every row with `autoTable` for (AC-4) and verify the spec from 1.18 passes
- [x] 1.20 Write the spec `[678-export-assessments-list/AC-14] PDF has several pages and repeats headers` for (AC-14) in `assessment-export.service.spec.ts` and verify it fails
- [x] 1.21 Set `showHead: 'everyPage'` and wrapped cells in `TablePdfService` for (AC-14) and verify the spec from 1.20 passes
- [x] 1.22 Write the spec `[678-export-assessments-list/AC-1] shows an Export control offering CSV and PDF` for (AC-1) in `ERAS-FE/src/app/modules/assessments/components/assessment-list/assessment-list.component.spec.ts` and verify it fails
- [x] 1.23 Add the Export menu (CSV, PDF) in `.page-header` of `assessment-list.component.html`, `displayedColumns` from the column definition, and `ASSESSMENT_EXPORT_MESSAGES` in `core/constants/messages.ts` for (AC-1) and verify the spec from 1.22 passes
- [x] 1.24 Write the spec `[678-export-assessments-list/AC-2] shows no Export control for an empty list` for (AC-2) in `assessment-list.component.spec.ts` and verify it fails
- [x] 1.25 Keep the control only in the non-empty branch for (AC-2) and verify the spec from 1.24 passes
- [x] 1.26 Write the spec `[678-export-assessments-list/AC-3] CSV has all 25 rows while the table shows page 1 of 3` for (AC-3) in `assessment-list.component.spec.ts` and verify it fails
- [x] 1.27 Wire the CSV option to export the full `assessments()` array in `assessment-list.component.ts` for (AC-3) and verify the spec from 1.26 passes
- [x] 1.28 Write the spec `[678-export-assessments-list/AC-17] rows keep the order of the table` for (AC-17) in `assessment-list.component.spec.ts` and verify it fails
- [x] 1.29 Pass the rows in `assessments()` order without sorting for (AC-17) and verify the spec from 1.28 passes
- [x] 1.30 Write the spec `[678-export-assessments-list/AC-5] exports only the 3 assessments of the professional's list` for (AC-5) in `assessment-list.component.spec.ts` and verify it fails
- [x] 1.31 Wire the PDF option to export the full `assessments()` array for (AC-5) and verify the spec from 1.30 passes
- [x] 1.32 Write the spec `[678-export-assessments-list/AC-15] shows progress and blocks the control until the file is downloaded` for (AC-15) in `assessment-list.component.spec.ts` and verify it fails
- [x] 1.33 Call `ExportStateService.startExport`/`endExport` around the export and disable the control while `isExporting()` for (AC-15) and verify the spec from 1.32 passes
- [x] 1.34 Write the spec `[678-export-assessments-list/AC-16] a failed export shows an error and no file` for (AC-16) in `assessment-list.component.spec.ts` and verify it fails
- [x] 1.35 Catch the failure, show the error toast and end the export in `finally` for (AC-16) and verify the spec from 1.34 passes

## 2. Verification

- [x] 2.1 FE gates pass in `ERAS-FE/`: `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (>= 15%), `npm run build` (AGENTS.md section 8.7)
- [x] 2.2 The AC traceability check (AGENTS.md section 8.6) shows exactly 1 test per AC on the FE side, and `openspec validate 678-export-assessments-list --strict` passes

## Traceability
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | Export control offers CSV and PDF | FE | src/app/modules/assessments/components/assessment-list/assessment-list.component.spec.ts › [678-export-assessments-list/AC-1] shows an Export control offering CSV and PDF |
| AC-2 | No export control for an empty list | FE | src/app/modules/assessments/components/assessment-list/assessment-list.component.spec.ts › [678-export-assessments-list/AC-2] shows no Export control for an empty list |
| AC-3 | CSV contains all rows, not only the current page | FE | src/app/modules/assessments/components/assessment-list/assessment-list.component.spec.ts › [678-export-assessments-list/AC-3] CSV has all 25 rows while the table shows page 1 of 3 |
| AC-4 | PDF contains all rows, not only the current page | FE | src/app/modules/assessments/services/assessment-export.service.spec.ts › [678-export-assessments-list/AC-4] PDF table has all 100 rows |
| AC-5 | Export is limited to the user's own list | FE | src/app/modules/assessments/components/assessment-list/assessment-list.component.spec.ts › [678-export-assessments-list/AC-5] exports only the 3 assessments of the professional's list |
| AC-6 | Columns, labels and order match the table | FE | src/app/modules/assessments/services/assessment-export.service.spec.ts › [678-export-assessments-list/AC-6] CSV and PDF headers match the table columns without Actions |
| AC-7 | Cell values match what the table shows | FE | src/app/modules/assessments/services/assessment-export.service.spec.ts › [678-export-assessments-list/AC-7] cell values match what the table shows |
| AC-8 | Comment is exported in full | FE | src/app/modules/assessments/services/assessment-export.service.spec.ts › [678-export-assessments-list/AC-8] comment is exported in full |
| AC-9 | All student names are exported | FE | src/app/modules/assessments/services/assessment-export.service.spec.ts › [678-export-assessments-list/AC-9] student cell lists all names |
| AC-10 | Accented characters survive in a spreadsheet | FE | src/app/modules/assessments/services/assessment-export.service.spec.ts › [678-export-assessments-list/AC-10] CSV starts with a UTF-8 BOM and keeps accents |
| AC-11 | Commas, quotes and line breaks are escaped | FE | src/app/modules/assessments/services/assessment-export.service.spec.ts › [678-export-assessments-list/AC-11] commas, quotes and line breaks are escaped |
| AC-12 | Formula-like values are neutralized | FE | src/app/modules/assessments/services/assessment-export.service.spec.ts › [678-export-assessments-list/AC-12] formula-like cells get a leading single quote |
| AC-13 | PDF shows title, date and time, user and filters | FE | src/app/modules/assessments/services/assessment-export.service.spec.ts › [678-export-assessments-list/AC-13] PDF shows title, date and time, user and filters |
| AC-14 | Column headers repeat on every page | FE | src/app/modules/assessments/services/assessment-export.service.spec.ts › [678-export-assessments-list/AC-14] PDF has several pages and repeats headers |
| AC-15 | Progress is shown while generating | FE | src/app/modules/assessments/components/assessment-list/assessment-list.component.spec.ts › [678-export-assessments-list/AC-15] shows progress and blocks the control until the file is downloaded |
| AC-16 | A failed export shows an error | FE | src/app/modules/assessments/components/assessment-list/assessment-list.component.spec.ts › [678-export-assessments-list/AC-16] a failed export shows an error and no file |
| AC-17 | Rows keep the order of the table | FE | src/app/modules/assessments/components/assessment-list/assessment-list.component.spec.ts › [678-export-assessments-list/AC-17] rows keep the order of the table |
