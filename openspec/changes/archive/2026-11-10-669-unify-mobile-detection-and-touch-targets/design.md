# Design

## Context

The spec covers `shared-components-mobile` (AC-1 to AC-7), FE only. #659 added `ViewportService` (`ERAS-FE/src/app/core/services/layout/viewport.service.ts`, signal `isMobile`, query `(max-width: 767.98px)`) and used it in the shell and the Students section. The branch `669-shared-foundations-unify-mobile-detection-and-touch-targets` of `ERAS-FE` is built on top of the 659 branch because #659 cannot be merged during the code freeze.

Today three shared components keep their own `isMobile = false` field, set in `ngOnInit` and in a `@HostListener('window:resize')` from `window.innerWidth < 768`: `src/app/shared/components/table/table.component.ts`, `.../table-with-actions/table-with-actions.component.ts` and `.../table-with-redirect/table-with-redirect.component.ts`. Their templates read it with `*ngIf="isMobile; else tableView"` (`table-with-actions` also checks `columns.length > 0`). `src/app/modules/imports/components/import-preview/import-answers-preview/import-answers-preview.component.ts` has the same field, but it is set **only** in a `window:resize` listener, never at init: a user who opens the page on a phone sees the table until the window is resized (AC-4 fails today for that reason).

Five more components declare a flag that no template reads: `import-preview.component.ts`, `polls-answered.component.ts`, `evaluation-process-list.component.ts` (threshold 600px), `list-imported-student.component.ts` and the old `student-detail.component.ts`. The first three also keep a resize listener that only feeds that flag. `apex-tooltip.directive.ts` (positions the tooltip from the window width) and `grid.component.ts` (sizes itself with a `ResizeObserver` on its own element) are not mobile detection and stay as they are.

For the tap area: `app/shared/components/buttons/action-button` renders a `mat-button`, `table-with-redirect` a `mat-icon-button`, and the theme (`src/styles/utils/index.scss`) uses density 0. Angular Material gives these buttons an invisible `.mat-mdc-button-touch-target` 48px high (48px wide for the square icon button, as wide as the button for a text button) at that density. AC-5 and AC-6 may therefore already hold; the tests decide.

## Goals / Non-Goals

**Goals:**
- The three shared tables and the answers import preview read the mobile rule from `ViewportService` only, at init and after a resize (AC-1, AC-2, AC-3, AC-4).
- The tap area of their action controls is at least 48 by 48 pixels on mobile, and nothing changes on desktop (AC-5, AC-6, AC-7).

**Non-Goals:**
- No new viewport service, no new breakpoint and no `@media` for the layout switch.
- No rewrite of the legacy `*ngIf` / `@HostListener` code the change does not need to touch (only the lines that read the width are replaced).

## Decisions

### D1. The shared components read `ViewportService.isMobile` and call it in the template
**Choice:** each component declares `readonly isMobile = inject(ViewportService).isMobile;` and its template uses `isMobile()`; the field, the `ngOnInit` line and the `@HostListener('window:resize')` are removed. It follows the pattern of #659 (D1 and D4 of `659-improve-students-mobile-view`) and lets a test drive the layout with `{ provide: ViewportService, useValue: { isMobile: signal(...) } }`.
**Alternative:** keep each component's listener and only change the number → keeps four copies of the rule and the missing initial value of the answers preview.

### D2. The unused flags are deleted, with their listeners and their tests
**Choice:** remove the `isMobile` field of `import-preview`, `polls-answered`, `evaluation-process-list`, `list-imported-student` and the old `student-detail`, together with the `@HostListener('window:resize')` methods and `ngOnInit` calls that only fed them, and the specs that assert the flag. No template reads them (checked with `grep` on every `.html` of the app), so no behavior changes and no AC is needed.
**Alternative:** switch them to `ViewportService` → keeps dead state alive.

### D3. Tap area: guard tests first, a mobile-only rule only if one fails
**Choice:** AC-5, AC-6 and AC-7 are written first against today's code. The tap area is the `.mat-mdc-button-touch-target` element of each control, measured with `getBoundingClientRect()`; "the controls look the same" is the visible box of the same control measured in the mobile and in the desktop layout (equal height), and "rows keep their height" is the `tr.mat-mdc-row` height on desktop. If AC-5 or AC-6 fails, a rule driven by `isMobile()` (a `mobile` class on the card, D4 of #659) sets the touch target of its controls in the component's `.scss`, enlarging only that invisible element.
**Alternative:** enlarge the buttons themselves on mobile → changes the look and the height of the cards, which the clarification rejected.

## Changes by layer

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Shared tables | Use `ViewportService.isMobile`; remove the own field, `ngOnInit` line and resize listener (D1) | `src/app/shared/components/table-with-actions/table-with-actions.component.{ts,html}`, `.../table/table.component.{ts,html}`, `.../table-with-redirect/table-with-redirect.component.{ts,html}` | AC-1, AC-2, AC-3 |
| Answers import preview | Use `ViewportService.isMobile` (D1) | `src/app/modules/imports/components/import-preview/import-answers-preview/import-answers-preview.component.{ts,html}` | AC-4 |
| Unused flags | Delete the field, the listener and their specs (D2) | `src/app/modules/imports/components/import-preview/import-preview.component.ts`, `src/app/modules/reports/components/polls-answered/polls-answered.component.ts`, `src/app/modules/lists/components/evaluacion-process/evaluation-process-list.component.ts`, `src/app/modules/imports/components/import-students/list-imported-student/list-imported-student.component.ts`, `src/app/shared/components/modals/modal-student-detail/student-detail/student-detail.component.ts` and their `.spec.ts` | none |
| Tap area | Only if the guard tests fail: `mobile` class and touch-target rule (D3) | `src/app/shared/components/table-with-actions/table-with-actions.component.{html,scss}`, `.../table-with-redirect/table-with-redirect.component.{html,scss}` | AC-5, AC-6 |
| Existing spec of #659 | The AC-8 spec stops setting `window.innerWidth` and uses the mocked service | `src/app/modules/students/students-list/students-list-mobile.component.spec.ts` | AC-8 of #659 |

No new route, model, API service, role or permission is involved.

## Test strategy

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | FE | `src/app/shared/components/table-with-actions/table-with-actions.component.spec.ts` (existing; `ViewportService` mocked, the old `isMobile` and `innerWidth` tests are replaced) | `[669-unify-mobile-detection-and-touch-targets/AC-1] switches the table with actions between cards and table with the screen size` |
| AC-2 | FE | `src/app/shared/components/table/table.component.spec.ts` (existing, same change) | `[669-unify-mobile-detection-and-touch-targets/AC-2] switches the table between cards and table with the screen size` |
| AC-3 | FE | `src/app/shared/components/table-with-redirect/table-with-redirect.component.spec.ts` (existing, same change) | `[669-unify-mobile-detection-and-touch-targets/AC-3] switches the table with redirect between cards and table with the screen size` |
| AC-4 | FE | `src/app/modules/imports/components/import-preview/import-answers-preview/import-answers-preview.component.spec.ts` (existing; the `checkScreenSize` tests are replaced) | `[669-unify-mobile-detection-and-touch-targets/AC-4] switches the students preview between cards and table with the screen size` |
| AC-5 | FE | `src/app/shared/components/shared-tables-touch-targets.spec.ts` (new; table with actions on a 375px host, mocked service) | `[669-unify-mobile-detection-and-touch-targets/AC-5] gives the card actions of the table with actions a 48 by 48 tap area` |
| AC-6 | FE | same new file (table with redirect on a 375px host) | `[669-unify-mobile-detection-and-touch-targets/AC-6] gives the detail button of the table with redirect a 48 by 48 tap area` |
| AC-7 | FE | same new file (both tables on a 1280px host) | `[669-unify-mobile-detection-and-touch-targets/AC-7] keeps the size of the table controls and rows on a desktop screen` |

AC-1 to AC-4 switch the mocked `isMobile` signal from `true` to `false` inside one test; the real reaction to a resize and the 768px boundary are proven by the untagged specs of `ViewportService` (#659). AC-4 fails today for the reason in the Context. AC-5, AC-6 and AC-7 may already pass against today's code (D3); then they are guard tests and are proven by breaking the code temporarily. Extra edge-case tests carry no AC tag. Coverage gate: FE >= 15% (AGENTS.md section 8.7).

## Risks / Trade-offs

- [`ViewportService` comes from the 659 branch, which is not merged] → the 669 branch is built on top of it; when #659 merges the PR of this change only carries its own commits. Never push a root pointer to an unpushed FE commit.
- [Tests that render the shared tables used `window.innerWidth` to get the card layout] → `students-list-mobile.component.spec.ts` (AC-8 of #659) is the one that does; its change is a task, and the full suite is run at the end.
- [The `isMobile` field becomes a signal, so `isMobile` is no longer a boolean] → only the own templates and specs read it (checked with `grep`); the build and the specs catch any other use.
- [The Karma window is not 375px wide] → layout tests drive the mock; the tap-area tests set a 375px host and measure rectangles, as the Students tests of #659 do.

## Open Questions

- None.

## Follow-ups

- Document in `ERAS-FE/AGENTS.md` §7.2 that mobile is decided only with `ViewportService` (planned with sub-ticket 2 of ERAS#668, the responsive dialogs).
- The `table`, `table-with-redirect`, `table-with-actions` and `import-answers-preview` templates still use `*ngIf` and `*ngFor`; moving them to `@if` / `@for` is a refactor of its own.
