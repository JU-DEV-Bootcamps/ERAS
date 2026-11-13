# ADR-0010: Use jspdf-autotable to build vector PDF tables in the frontend

**Status:** Accepted
**Date:** 2026-11-11
**Area:** frontend
**Change:** 678-export-assessments-list
**Reviewed by:** judithmarg-dev (2026-11-11)
**Signed by:** judithmarg-dev (2026-11-11)

## Context

The only PDF export in the frontend (`ERAS-FE/src/app/core/services/exports/pdf.service.ts`) photographs the rendered page with `html2canvas-pro` and pastes the images into `jsPDF`. It is slow, produces image-only PDFs (no selectable text, blurry, heavy) and cannot contain rows the paginator hides. Change `678-export-assessments-list` exports the full Assessments list (worst case 100 rows) with a header and column headers repeated on every page. The data is already in memory in the browser, with names resolved in the frontend, and `jspdf` ^4 is already installed. A table with automatic page breaks needs layout code that `jspdf` alone does not provide.

## Decision

We build PDF tables in the frontend from plain columns and rows with `jspdf-autotable` on top of the existing `jspdf`, as real text with automatic page breaks and repeated headers. The library is loaded with a dynamic `import()` so it stays out of the main bundle, and its version must be compatible with the installed `jspdf` 4.x. New table exports use this approach, not DOM snapshots.

## Alternatives

- Keep `html2canvas` snapshots → slow, image-only output, cannot include hidden rows.
- Backend PDF with QuestPDF → new backend code and license review, and the backend would have to repeat the name resolution done in the frontend; not needed for 100 rows.
- Backend PDF with headless Chromium → heavy infrastructure for the same result.
- Browser print stylesheet → no control over pagination and no download without the print dialog.

## Consequences

- One new runtime dependency, to be kept compatible with `jspdf` when it is upgraded.
- PDFs have selectable text, small size and headers repeated on every page; generation of 100 rows is fast and needs no new request.
- The legacy `PdfService` stays for the screens that use it; migrating them is separate work.
- If volume grows or exports are needed without the user on screen, a backend engine can replace this one, because the export service receives plain columns and rows.
