# Tasks

## 1. Frontend (FE)

- [x] 1.1 Write the spec `[673-evaluation-process-lists-and-imports/AC-1] keeps a 100-character Poll Name inside its card on a mobile screen` for (AC-1) in `ERAS-FE/src/app/modules/lists/components/evaluacion-process/evaluation-process-list.component.spec.ts`, providing a `ViewportService` signal (default desktop) and rendering the list in a 343px host; verify it fails because the text overflows the card
- [x] 1.2 Add `overflow-wrap: anywhere` to `.row-info` in `ERAS-FE/src/app/shared/components/table-with-actions/table-with-actions.component.scss` for (AC-1) and verify the spec from 1.1 passes
- [x] 1.3 Write the spec `[673-evaluation-process-lists-and-imports/AC-2] keeps the table and does not wrap the Poll Name on a desktop screen` for (AC-2) in the same spec file, and verify it passes with the change from 1.2 in place (the change only touches `.row-info`, which the desktop table does not use) and that `table-with-actions.component.spec.ts` stays green

## 2. Verification

- [x] 2.1 FE gates of AGENTS.md section 8.7 pass in `ERAS-FE/`: `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (>= 15%), `npm run build`
- [x] 2.2 Verify in the browser at 375px and 1280px that a 100-character Poll Name stays inside its card and that the table at 1280px looks as before, with no horizontal scroll of the page
- [x] 2.3 The AC traceability check (AGENTS.md section 8.6) shows exactly 1 test per AC per affected side, and `openspec validate 673-evaluation-process-lists-and-imports --strict` passes

## Traceability
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | A long Poll Name stays inside the card | FE | src/app/modules/lists/components/evaluacion-process/evaluation-process-list.component.spec.ts › [673-evaluation-process-lists-and-imports/AC-1] keeps a 100-character Poll Name inside its card on a mobile screen |
| AC-2 | Desktop keeps the table | FE | src/app/modules/lists/components/evaluacion-process/evaluation-process-list.component.spec.ts › [673-evaluation-process-lists-and-imports/AC-2] keeps the table and does not wrap the Poll Name on a desktop screen |
