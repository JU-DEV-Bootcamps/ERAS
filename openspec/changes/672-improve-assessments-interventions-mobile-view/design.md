# Design

## Context

The Assessments section lives in `ERAS-FE/src/app/modules/assessments/components/` (below: `A/`). `AssessmentsContainerComponent` renders `app-tabbed-layout` (routed tabs, a plain `router-outlet`, no transform) with two pages:

- **Assessments tab:** `AssessmentsComponent` (`A/assessments.component.ts`) owns the create and edit dialogs with one `modalConfig` (`minWidth: '500px'`, `width: '40vw'`) and hosts `app-assessment-list` (`A/assessment-list/`).
- **Interventions tab:** `InterventionsComponent` (`A/interventions/interventions.component.ts`) renders `app-list-filters` (`shared/components/list-filters/`, used only here) and `app-intervention-list` (`A/interventions/interventions-list/`), and opens the create and edit dialogs (`width: '520px'`) and the delete confirmation (`width: '400px'`).

Both lists are their own `mat-table` inside `.table-wrapper { overflow-x: auto }` (8 and 12 columns); they do not use the shared `app-list`. Both use the same push layout: `.slide-panel-area` gets `width: 480px; min-width: 480px` with `.panel-is-open` and renders the detail inline (`app-assessment-detail-dialog`, which is not a `MatDialog`, and `app-intervention-detail`), each with an X close button in its header. The only `@media` is `max-width: 1500px`, which hides `.inline-actions` and shows a `more_vert` menu. Actions are gated with `[disabled]` only: `canManageAssessment()` (`PermissionsService`, Administrator and Officer) and the Finalized status.

`app-assessment-student-data` shows a "+N" badge whose popover opens on `mouseenter`, is positioned from `rect.left` and has `min-width: 280px`. The assessment detail opens the student details modal at `width: '1152px'`. Assessment and student deletions use `ModalDeleteConfirmationService` (`width: '418px'`).

Mobile infrastructure that already exists: `ViewportService.isMobile` (`core/services/layout/viewport.service.ts`, below 768px), the global `.mobile-fullscreen-dialog` class (`src/styles/utils/index.scss`), which already styles `.modal-content` (the class the four forms of this section use), and the private `studentDialogSize()` of `StudentsListComponent`, which is the only place that builds the full-screen dialog config. Motivation and scope: `proposal.md`.

## Goals / Non-Goals

**Goals:**
- Cards instead of tables below 768px in both lists, with icon actions and a pagination that fits (AC-1, AC-2, AC-6, AC-7), and stacked Interventions controls (AC-3).
- Full-screen details with a visible close button (AC-4, AC-5) and the "+N" students by tap (AC-8).
- Full-screen forms and student details, and confirmations that fit (AC-9 to AC-14).
- The same `[disabled]` rules on the cards as on the table (AC-15, AC-16).
- From 768px nothing changes: table, 480px panel, `more_vert` menu below 1500px, dialog sizes (AC-17 to AC-19).

**Non-Goals:**
- Moving the two lists onto the shared `app-list` / `app-table-with-actions`.
- Changing `StudentsListComponent` to use the new dialog helper.
- Replacing the legacy `@Input()` / `@Output()` / `*ngFor` in the files this change edits.
- The 1500px rule of the row actions.

## Decisions

### D1. The layout switches on `ViewportService.isMobile()`, not on `@media`
**Choice:** `AssessmentListComponent`, `InterventionListComponent`, `ListFiltersComponent` and `AssessmentStudentDataComponent` read `inject(ViewportService).isMobile`. The lists render `@if (isMobile()) { cards } @else { table }` and bind `[class.mobile]`; the filters bind `[class.mobile]`. Tests replace the service with `{ isMobile: signal(...) }`, as in changes 659, 669 and 671.
**Alternative:** `@media (max-width: 767.98px)` in each stylesheet → the Karma window width is not controlled per test, so no AC could be proven, and it would be a second source for the 768px rule.

### D2. Each list renders its own cards
**Choice:** below 768px each list renders one `mat-card` per row of the current page: label and value rows for the fields of A3, then a row of actions. Cells that have markup today (status and risk badges, `app-assessment-student-data`, comment preview) are moved to `ng-template`s used by both the table cell and the card, so the two views cannot drift. The paginator stays and, on mobile, hides the page-size selector and the first and last buttons so that it fits 375px.
**Alternative:** move both lists to `app-list` + `app-table-with-actions`, which already has cards → a refactor of two screens (push layout, panel, role-gated buttons, CSV export) outside this change; recorded under Follow-ups. A CSS-only restyle of the `mat-table` rows → 12 columns, and not provable in a test.

### D3. Card actions are three icon buttons with the rules of the inline buttons
**Choice:** each card ends with `mat-icon-button`s View, Edit and Delete with an `aria-label` and the same `[disabled]` expressions as the inline (desktop) buttons, including `lookupsLoading()`. The `more_vert` menu is not rendered on mobile. Material's default touch target keeps each one at 48 by 48.
**Alternative:** the `more_vert` menu on the card → rejected in the clarification (two taps per action).

### D4. The detail is the same panel, fixed over the whole screen
**Choice:** under `.mobile`, `.slide-panel-area` with `.panel-is-open` is `position: fixed; inset: 0; width: 100%; min-width: 0; margin: 0; border-radius: 0; z-index: 999`, and `.main-content-area` and `.page-header` are hidden while it is open. `z-index: 999` is above the header and the side menu and below the CDK overlay (1000), so the dialogs opened from the detail (student details, create intervention, confirmations) appear on top. The detail components keep their X button; on mobile it loses the negative margin and the 20px icon so that it is a standard icon button, and the detail header stays at the top while the content scrolls. Closing sets the selection to null as today, which shows the list again.
**Alternative:** open the detail in a `MatDialog` on mobile → the detail components are inline components with inputs and outputs; they would need a wrapper and a second code path for close, refresh and "Create Intervention".

### D5. One helper builds the dialog size
**Choice:** a new pure function `responsiveDialogSize(isMobile, desktop)` in `src/app/core/utils/dialogs/responsive-dialog-size.ts` (new) returns the desktop config untouched from 768px and, below it, `width: '100vw'`, `maxWidth: '100vw'`, `height: '100dvh'`, `maxHeight: '100dvh'`, no `minWidth`, and `panelClass` plus `mobile-fullscreen-dialog`: the values of `studentDialogSize()` from change 659. It is used by the five `MatDialog.open` calls for forms and student details: `AssessmentsComponent` (create, edit), `InterventionsComponent` (create, edit), `AssessmentListComponent.onCreateIntervention` and `AssessmentDetailDialogComponent.openStudentDetails`. `assessments-modal-styles.scss` gets a `:host-context(.mobile-fullscreen-dialog)` block: 16px header padding, the content scrolls and the actions stay at the bottom.
**Alternative:** copy the object in four components → four copies of a rule that already exists once. Reuse `studentDialogSize()` → it is private to `StudentsListComponent`; moving it changes that component and is a Follow-up.

### D6. Confirmations get a maximum width, not a mobile branch
**Choice:** the delete confirmation of an intervention (`InterventionsComponent.confirmDelete`) and `ModalDeleteConfirmationService.confirmDelete` add `maxWidth: 'calc(100vw - 32px)'`. Their widths (400px and 418px) stay, so nothing changes on a screen wider than 450px.
**Alternative:** rely on Material's default `maxWidth: 80vw` → it already keeps them inside 375px, but it is implicit; the explicit value makes AC-13 provable and independent of the default.

### D7. The "+N" students open by tap, inside the screen
**Choice:** `togglePin()` also opens the popover when it pins (today only `mouseenter` sets `show`). On mobile the popover is positioned with `left: 8px; right: 8px` instead of `rect.left`, and loses its `min-width`, so it is always inside the screen. Desktop keeps the current position and hover.
**Alternative:** clamp `left` with the measured popover width → needs a second measurement after render for the same result.

## Changes by layer

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Dialog helper | new `responsiveDialogSize` (D5) and its unit spec | `src/app/core/utils/dialogs/responsive-dialog-size.ts` (new), `responsive-dialog-size.spec.ts` (new) | AC-9 to AC-12, AC-14, AC-19 |
| Assessment list | `isMobile`; cards with fields and icon actions; compact paginator; full-screen panel; `page-header` wraps; `onCreateIntervention` uses the helper | `A/assessment-list/assessment-list.component.{ts,html,scss}` | AC-1, AC-4, AC-6, AC-10, AC-15, AC-17 |
| Assessment detail | standard close button and sticky header under mobile; `openStudentDetails` uses the helper | `A/assessment-detail/assessment-detail-dialog.component.{ts,scss}` | AC-4, AC-14 |
| Student names | tap opens the popover; mobile position (D7) | `A/assessment-list/assessment-student-data/assessment-student-data.component.{ts,scss}` | AC-8 |
| Assessment forms | `modalConfig` goes through the helper for create and edit; mobile block in the shared modal styles | `A/assessments.component.ts`, `src/app/modules/assessments/styles/assessments-modal-styles.scss` | AC-9, AC-11, AC-19 |
| Intervention list | `isMobile`; cards with fields and icon actions; compact paginator; full-screen panel; `page-header` wraps | `A/interventions/interventions-list/intervention-list.component.{ts,html,scss}` | AC-2, AC-5, AC-7, AC-16, AC-18 |
| Intervention detail | standard close button and sticky header under mobile | `A/interventions/interventions-detail/intervention-detail.component.scss` | AC-5 |
| Interventions page | create and edit dialogs use the helper; delete confirmation gets `maxWidth` | `A/interventions/interventions.component.ts` | AC-10, AC-12, AC-13, AC-19 |
| Intervention forms | the attachment manager and the form fit the full-screen dialog | `A/interventions/edit-intervention-modal/edit-intervention-modal.component.scss`, `src/app/shared/components/attachment-manager/*.scss` (only if a fixed width overflows 375px) | AC-10, AC-12 |
| Filters | `mobile` class: the form is a column, each filter is full width, the Apply button below | `src/app/shared/components/list-filters/list-filters.component.{ts,html,scss}` | AC-3 |
| Delete confirmation | `maxWidth` (D6) | `src/app/shared/components/modals/modal-delete-confirmation/modal-delete-confirmation.service.ts` | AC-13 |

No route, model, service, permission or message change. No new dependency.

Implementation notes (2026-11-11), where the files differ from the table above without changing a decision:
- The mobile styles of both lists and the close button of both details live once in `src/app/modules/assessments/styles/_mobile-list.scss` (new), included by the four stylesheets.
- The maximum width of D6 is the constant `CONFIRMATION_DIALOG_MAX_WIDTH`, next to `responsiveDialogSize`.
- The untagged 375px fit check of the four form modals uses `src/app/modules/assessments/testing/expect-fits-mobile-dialog.ts` (new, test only).
- No sticky header was needed in the details: their header is already a fixed flex row and only the content scrolls. No change was needed in `edit-intervention-modal.component.scss` or in the attachment manager: the form already fits 375px.
- Two existing specs changed: `interventions.component.spec.ts` now provides a desktop `ViewportService`, and `modal-delete-confirmation.service.spec.ts` expects the new `maxWidth`.

## API contract
No API change.

## Data and migration
No schema change.

## Test strategy

All tests are FE (Jasmine/Karma) with `[672-improve-assessments-interventions-mobile-view/AC-n]` first in the `it()` title. New `*-mobile.component.spec.ts` files sit next to their unit, as `students-list-mobile.component.spec.ts` does. `ViewportService` is replaced by `{ isMobile: signal(...) }`. Layout is asserted from the real DOM inside a 375px (or 1280px) wide host: `scrollWidth <= clientWidth`, bounding rectangles, and computed `position`. Dialog sizes are asserted on the config passed to a spied `MatDialog.open`. API services are spies with fixed data; `PermissionsService.can` is a spy.

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | FE | `A/assessment-list/assessment-list-mobile.component.spec.ts` (new) | `[672-improve-assessments-interventions-mobile-view/AC-1] shows each assessment as a card with every field and no horizontal scroll on mobile` |
| AC-2 | FE | `A/interventions/interventions-list/intervention-list-mobile.component.spec.ts` (new) | `[672-improve-assessments-interventions-mobile-view/AC-2] shows each intervention as a card with every field and no horizontal scroll on mobile` |
| AC-3 | FE | `A/interventions/interventions-mobile.component.spec.ts` (new), real `app-list-filters` and `app-intervention-list` | `[672-improve-assessments-interventions-mobile-view/AC-3] stacks the filters and keeps Export and Create Intervention visible on mobile` |
| AC-4 | FE | `assessment-list-mobile.component.spec.ts`, real `app-assessment-detail-dialog` | `[672-improve-assessments-interventions-mobile-view/AC-4] opens the assessment detail over the whole screen and closes back to the list on mobile` |
| AC-5 | FE | `intervention-list-mobile.component.spec.ts`, real `app-intervention-detail` | `[672-improve-assessments-interventions-mobile-view/AC-5] opens the intervention detail over the whole screen and closes back to the list on mobile` |
| AC-6 | FE | `assessment-list-mobile.component.spec.ts` | `[672-improve-assessments-interventions-mobile-view/AC-6] shows View, Edit and Delete as icon buttons on the assessment card` |
| AC-7 | FE | `intervention-list-mobile.component.spec.ts` | `[672-improve-assessments-interventions-mobile-view/AC-7] shows View, Edit and Delete as icon buttons on the intervention card` |
| AC-8 | FE | `A/assessment-list/assessment-student-data/assessment-student-data.component.spec.ts` | `[672-improve-assessments-interventions-mobile-view/AC-8] shows every student name inside the screen when the badge is tapped on mobile` |
| AC-9 | FE | `A/assessments-mobile.component.spec.ts` (new) | `[672-improve-assessments-interventions-mobile-view/AC-9] opens the create assessment form full screen and reloads the list when it is saved` |
| AC-10 | FE | `interventions-mobile.component.spec.ts` | `[672-improve-assessments-interventions-mobile-view/AC-10] opens the create intervention form full screen and reloads the list when it is saved` |
| AC-11 | FE | `assessments-mobile.component.spec.ts` | `[672-improve-assessments-interventions-mobile-view/AC-11] opens the edit assessment form full screen on mobile` |
| AC-12 | FE | `interventions-mobile.component.spec.ts` | `[672-improve-assessments-interventions-mobile-view/AC-12] opens the edit intervention form full screen on mobile` |
| AC-13 | FE | `interventions-mobile.component.spec.ts`, real `ModalDeleteConfirmationComponent` in a 343px host | `[672-improve-assessments-interventions-mobile-view/AC-13] keeps the delete confirmation and its two buttons inside the screen` |
| AC-14 | FE | `A/assessment-detail/assessment-detail-dialog.component.spec.ts` | `[672-improve-assessments-interventions-mobile-view/AC-14] opens the student details full screen from the assessment detail on mobile` |
| AC-15 | FE | `assessment-list-mobile.component.spec.ts`, `can` returns false | `[672-improve-assessments-interventions-mobile-view/AC-15] disables Create Assessment, Edit and Delete and keeps View for a user who cannot manage assessments` |
| AC-16 | FE | `intervention-list-mobile.component.spec.ts`; the same `it` also mounts `AssessmentListComponent` with a Finalized assessment | `[672-improve-assessments-interventions-mobile-view/AC-16] blocks the same actions for a Finalized assessment on mobile` |
| AC-17 | FE | `assessment-list-mobile.component.spec.ts` | `[672-improve-assessments-interventions-mobile-view/AC-17] keeps the assessments table, the more menu and the 480px side panel on a 1280px screen` |
| AC-18 | FE | `intervention-list-mobile.component.spec.ts` | `[672-improve-assessments-interventions-mobile-view/AC-18] keeps the interventions table, the more menu and the 480px side panel on a 1280px screen` |
| AC-19 | FE | `assessments-mobile.component.spec.ts`; the same `it` also mounts `InterventionsComponent` | `[672-improve-assessments-interventions-mobile-view/AC-19] keeps the desktop sizes of the assessment and intervention forms` |

Extra tests without an AC tag: the unit spec of `responsiveDialogSize`, and a 375px fit check (no horizontal overflow, Cancel and save buttons inside the host) in the existing specs of the four form modals, which backs the "no field cut off" part of AC-9 to AC-12 that a dialog config cannot show. AC-15 to AC-19 are guard tests: they are expected to pass once the cards exist, so each one is proven by breaking the rule it guards (removing a `[disabled]`, forcing the mobile branch) and seeing it fail. Existing specs that assert dialog configs (`interventions.component.spec.ts:391`, `width: '520px'`) keep passing because the desktop config is returned untouched. Coverage gate: FE >= 15% (AGENTS.md section 8.7); the FE gates are in `ERAS-FE/AGENTS.md` §3.3.

## Risks / Trade-offs

- [The table and the card duplicate the row] → shared `ng-template`s for the cells with markup, one list of card fields per component, and AC-17 and AC-18 guard the table.
- [`position: fixed` panel inside the shell] → no ancestor has a transform (`app-tabbed-layout` is a `router-outlet`); AC-4 and AC-5 assert that the panel rectangle equals the window. If a containing block appears later, those tests fail.
- [`app-list-filters` and `ModalDeleteConfirmationService` are shared] → the filters are used only by the Interventions tab and change only under `.mobile`; the confirmation only gains a `maxWidth` larger than its width on any screen wider than 450px.
- [The Karma window is not 375px] → layout is asserted inside a fixed-width host; the full-screen panel is asserted against `window.innerWidth` and `innerHeight`; real phones are checked in `/sdd-validate-impl`.
- [`mobile-fullscreen-dialog` was written for the student modals] → it already targets `.modal-content`; the four forms get the untagged 375px fit check.
- [A resize across 768px with the detail open] → the selection is kept, so the detail moves between the panel and the full screen without closing.

## Follow-ups
- "Create Intervention" in the assessment detail and in the empty state of the Interventions list has no role or Finalized check in the front end (recorded in `proposal.md`, Out of scope).
- The `/assessments` route declares its roles on child routes while the guard runs on the parent, so the guard does not enforce them (`ERAS-FE/AGENTS.md` §7.1 step 1); its own change, it touches auth.
- The Karma browser window is narrower than 768px, so the existing specs that do not replace `ViewportService` run the mobile branch of the components they mount. They pass, but each should state its screen size.
- Move `StudentsListComponent.studentDialogSize()` onto `responsiveDialogSize` so the rule has one home.
- Move the two lists to the shared `app-list` / `app-table-with-actions`, and replace the legacy `@Input()` / `@Output()` / `*ngFor` of this module.
- The close control of the four form modals is a bare `mat-icon` with `(click)`, not a button (no keyboard focus, small tap area); the forms keep their Cancel button.
- The "risk" column header of the interventions table has a `(click)` that does nothing; only the icon sorts.
- The Edit item of the `more_vert` menu of the assessments table does not check `lookupsLoading()`, while the inline button does.
