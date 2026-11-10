# Tasks

## 1. Frontend (FE): shared tables follow the viewport service

- [x] 1.1 Write the spec `[669-unify-mobile-detection-and-touch-targets/AC-1] switches the table with actions between cards and table with the screen size` for (AC-1) in `ERAS-FE/src/app/shared/components/table-with-actions/table-with-actions.component.spec.ts` (`ViewportService` mocked with a `signal`; replace the `innerWidth`/`isMobile` specs of `ngOnInit` and `onResize`) and verify it fails
- [x] 1.2 Write the spec `[669-unify-mobile-detection-and-touch-targets/AC-2] switches the table between cards and table with the screen size` for (AC-2) in `ERAS-FE/src/app/shared/components/table/table.component.spec.ts` (same approach, replace the `innerWidth` specs) and verify it fails
- [x] 1.3 Write the spec `[669-unify-mobile-detection-and-touch-targets/AC-3] switches the table with redirect between cards and table with the screen size` for (AC-3) in `ERAS-FE/src/app/shared/components/table-with-redirect/table-with-redirect.component.spec.ts` (same approach, replace the `innerWidth` specs) and verify it fails
- [x] 1.4 Implement `readonly isMobile = inject(ViewportService).isMobile`, remove the own field, the `ngOnInit` line and the resize listener, and read `isMobile()` in `table-with-actions.component.{ts,html}` for (AC-1), and verify the spec from 1.1 and the rest of the component spec pass
- [x] 1.5 Do the same in `ERAS-FE/src/app/shared/components/table/table.component.{ts,html}` for (AC-2) and verify the spec from 1.2 passes
- [x] 1.6 Do the same in `ERAS-FE/src/app/shared/components/table-with-redirect/table-with-redirect.component.{ts,html}` for (AC-3) and verify the spec from 1.3 passes
- [x] 1.7 Change the AC-8 spec of #659 in `ERAS-FE/src/app/modules/students/students-list/students-list-mobile.component.spec.ts` so it no longer sets `window.innerWidth` and relies on the mocked `ViewportService`, and verify it and the other specs of the file still pass

## 2. Frontend (FE): answers import preview and unused flags

- [x] 2.1 Write the spec `[669-unify-mobile-detection-and-touch-targets/AC-4] switches the students preview between cards and table with the screen size` for (AC-4) in `ERAS-FE/src/app/modules/imports/components/import-preview/import-answers-preview/import-answers-preview.component.spec.ts` (mocked `ViewportService`; replace the `checkScreenSize` specs) and verify it fails because the cards are not shown at the first render on a narrow screen
- [x] 2.2 Implement `isMobile` from `ViewportService` in `import-answers-preview.component.{ts,html}`, removing the resize listener, for (AC-4) and verify the spec from 2.1 passes
- [x] 2.3 Remove the unused `isMobile` field, the resize listeners and the `ngOnInit` calls that only fed them, and their specs, in `import-preview.component.ts`, `polls-answered.component.ts`, `evaluation-process-list.component.ts`, `list-imported-student.component.ts` and `student-detail.component.ts` (paths in design.md), and verify with `grep` that no `.html` reads `isMobile` there and that the specs of those five components pass

## 3. Frontend (FE): tap area of the table controls

- [x] 3.1 Write the spec `[669-unify-mobile-detection-and-touch-targets/AC-5] gives the card actions of the table with actions a 48 by 48 tap area` for (AC-5) in `ERAS-FE/src/app/shared/components/shared-tables-touch-targets.spec.ts` (new; 375px host, mocked service, measures `.mat-mdc-button-touch-target`, the overlap of the controls and the visible box against the desktop layout) and verify it fails or already passes against today's code (guard test, D3)
- [x] 3.2 Write the spec `[669-unify-mobile-detection-and-touch-targets/AC-6] gives the detail button of the table with redirect a 48 by 48 tap area` for (AC-6) in the same file and verify it fails or already passes (guard test, D3)
- [x] 3.3 Write the spec `[669-unify-mobile-detection-and-touch-targets/AC-7] keeps the size of the table controls and rows on a desktop screen` for (AC-7) in the same file (1280px host, both tables) and verify it already passes (guard test, D3)
- [x] 3.4 Prove every guard test of 3.1 to 3.3 that passed can fail: break the code or the measure temporarily, see the failure, restore the files exactly, and note it in the report
- [x] 3.5 Only if the spec from 3.1 or 3.2 failed: add the `mobile` class and the touch-target rule to `table-with-actions.component.{html,scss}` or `table-with-redirect.component.{html,scss}` for (AC-5) and (AC-6) and verify the specs from 3.1 to 3.3 pass; if they passed, tick this task with the note "not needed: guard tests passed" (not needed: guard tests passed)

## 4. Verification

- [x] 4.1 BE gates: no BE file changes in `ERAS-BE/` (verify with `git -C ERAS-BE status`, which shows only the local `appsettings.json`); nothing to run
- [x] 4.2 FE gates pass in `ERAS-FE/` (AGENTS.md section 8.7): `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (>= 15%), `npm run build`
- [x] 4.3 Verify that `grep -rn "innerWidth" ERAS-FE/src/app --include=*.ts`, outside `*.spec.ts` files, returns only `apex-tooltip.directive.ts` and `grid.component.ts`
- [x] 4.4 The AC traceability check (AGENTS.md section 8.6) shows exactly 1 FE test per AC (AC-1 to AC-7), and `openspec validate 669-unify-mobile-detection-and-touch-targets --strict` passes

## Traceability
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | Table with actions switches between cards and table | FE | src/app/shared/components/table-with-actions/table-with-actions.component.spec.ts › [669-unify-mobile-detection-and-touch-targets/AC-1] switches the table with actions between cards and table with the screen size |
| AC-2 | Table switches between cards and table | FE | src/app/shared/components/table/table.component.spec.ts › [669-unify-mobile-detection-and-touch-targets/AC-2] switches the table between cards and table with the screen size |
| AC-3 | Table with redirect switches between cards and table | FE | src/app/shared/components/table-with-redirect/table-with-redirect.component.spec.ts › [669-unify-mobile-detection-and-touch-targets/AC-3] switches the table with redirect between cards and table with the screen size |
| AC-4 | Students preview switches between cards and table | FE | src/app/modules/imports/components/import-preview/import-answers-preview/import-answers-preview.component.spec.ts › [669-unify-mobile-detection-and-touch-targets/AC-4] switches the students preview between cards and table with the screen size |
| AC-5 | Card actions of the table with actions are at least 48 by 48 | FE | src/app/shared/components/shared-tables-touch-targets.spec.ts › [669-unify-mobile-detection-and-touch-targets/AC-5] gives the card actions of the table with actions a 48 by 48 tap area |
| AC-6 | Detail button of the table with redirect is at least 48 by 48 | FE | src/app/shared/components/shared-tables-touch-targets.spec.ts › [669-unify-mobile-detection-and-touch-targets/AC-6] gives the detail button of the table with redirect a 48 by 48 tap area |
| AC-7 | Desktop controls keep their size | FE | src/app/shared/components/shared-tables-touch-targets.spec.ts › [669-unify-mobile-detection-and-touch-targets/AC-7] keeps the size of the table controls and rows on a desktop screen |
