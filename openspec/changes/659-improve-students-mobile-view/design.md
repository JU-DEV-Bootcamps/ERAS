# Design

## Context

The shell in `ERAS-FE/src/app/core/components/layout/layout.component.{ts,html,scss}` renders a `mat-sidenav` with `mode="side"`, `[opened]="true"` and `disableClose`. Its width comes from `sidenavWidth()`: 250px or 70px (legacy sidebar, collapsed at or below 1200px) or a fixed 260px (new sidebar, flag `newSidebar`). `mat-sidenav-content` always gets `margin-left: sidenavWidth()`, so on a 375px phone the content is left with 115px to 305px.

The header is `HeaderContainerComponent` (`header/header-v2/header-container.component.ts`), which shows `HeaderV2Component` (title, user name and role, a notifications icon, `UserMenuComponent`) when the `home` flag is on, and `HeaderComponent` (title "ERAS" and `UserMenuComponent`) otherwise. `UserMenuComponent` already shows name and role inside its menu.

The Students list (`modules/students/students-list/students-list.component.*`) renders `app-list` (`shared/components/list`), which renders `app-table-with-actions`. That table already switches to cards below 768px, but decides it with `window.innerWidth` and a `resize` listener (`isMobile`). `app-list` always shows `mat-paginator` with `showFirstLastButtons` and the page-size selector. The student dialogs are opened by `students-list.component.ts` with fixed widths: the details modal (`width: '1152px'`, `maxHeight: '921.59px'`), the profile summary and the new student form / student record (`width: '1100px'`, `maxHeight: '95vh'`), all with `maxWidth: '95vw'`. The current courses of the profile are a `<table class="courses">` in `student-profile-view.component.html`.

No component reacts to the viewport through a shared, mockable source; `layout.component.ts` uses `BreakpointObserver` directly and others read `window.innerWidth`. Motivation and scope: `proposal.md`.

## Goals / Non-Goals

**Goals:**
- Hide the side menu on a screen narrower than 768px and open it from the header (AC-1 to AC-4), compact the header (AC-5) and keep the layout of wider screens (AC-6).
- Adapt the Students list controls, cards, pagination, the four student modals and the current courses to mobile (AC-7 to AC-15).

**Non-Goals:**
- Moving `app-table-with-actions` and the import previews from `window.innerWidth` to the new service; they keep working at the same 768px threshold.
- Changing any back end, API, model, route, permission or message text other than one accessible label.

## Decisions

### D1. One `ViewportService` that exposes `isMobile` as a signal
**Choice:** a new `providedIn: 'root'` service `src/app/core/services/layout/viewport.service.ts` with `readonly isMobile: Signal<boolean>`, built from `BreakpointObserver.observe('(max-width: 767.98px)')` with `observer.isMatched(...)` as the initial value, and one exported constant for the query. Layout, headers, the Students list, the shared list and the profile view inject it. Tests replace it with `{ isMobile: signal(true) }`.
**Alternative:** `@media` queries only → cannot switch the sidenav mode, the dialog configuration or the template, and cannot be driven from a test. Reading `window.innerWidth` per component (the current pattern) → not reactive without a `HostListener` in every component, and hard to test.

### D2. The sidenav switches between `side` and `over`, and closes on navigation
**Choice:** `LayoutComponent` keeps a `menuOpen` signal. On mobile the sidenav is `mode="over"`, `[opened]="menuOpen()"`, `disableClose` is off, its width is the expanded width of the active sidebar (250px legacy, 260px new) and `mat-sidenav-content` has `margin-left: 0`. The sidenav closes when the container backdrop is tapped (`(backdropClick)`) and on every `NavigationEnd`, which also covers the submenu links that never call `onMenuClick`. Entries that only expand a submenu keep it open because they do not navigate. On wider screens the bindings are exactly today's. The legacy in-sidenav expand/collapse button is not rendered on mobile, since the header button replaces it.
**Alternative:** close inside `SidebarComponent.onMenuClick` → misses submenu links, which navigate through `routerLink` only, and needs the layout and both sidebars to share state.

### D3. The menu button lives in both headers and is forwarded by the container
**Choice:** `HeaderV2Component` and `HeaderComponent` inject `ViewportService`, render a menu button (accessible label from `core/constants/messages.ts`) only when `isMobile()`, and expose an `output()` `menuToggle`. `HeaderContainerComponent` re-emits it and `layout.component.html` binds it to `menuOpen`. `HeaderV2Component` hides the name/role block and the notifications icon on mobile. The user menu stays.
**Alternative:** a shared "menu state" service → hidden coupling between header and layout for one boolean.

### D4. Mobile styling that must be tested is driven by `isMobile()`, not by `@media`
**Choice:** where an AC depends on how things lay out (AC-7, AC-9, AC-10, AC-12), the component binds `[class.mobile]="isMobile()"` or renders a different template, so a Jasmine spec can switch the signal and assert computed styles or the DOM in a 375px wide container. Existing `@media` rules (for example `student-profile-view.component.scss` at 800px, `_forms.scss` at 900px) are left alone.
**Alternative:** `@media (max-width: 767px)` in each stylesheet → cannot be proven by a test, because the Karma window size is not controlled per test.

### D5. The reduced pagination is an opt-in of the shared list
**Choice:** `ListComponent` gets `@Input() compactPaginatorOnMobile = false`. When it is true and `isMobile()`, the paginator renders with `hidePageSize` and without first/last buttons. `students-list.component.html` sets it to true. Every other list keeps its paginator (clarified scope).
**Alternative:** change the shared paginator for all ~20 consumers → rejected in `/sdd-clarify`.

### D6. One dialog size helper for the four student dialogs
**Choice:** `students-list.component.ts` gets a private method that takes the desktop options of each dialog (unchanged values) and, when `isMobile()`, returns `{ width: '100vw', maxWidth: '100vw', height: '100dvh', maxHeight: '100dvh', panelClass: [<its panelClass>, 'mobile-fullscreen-dialog'] }`. The class is defined once in `src/styles/utils/index.scss` (square corners, flex column surface, content area that scrolls and a footer that stays visible). The component-level `max-height: 75vh` of `.profile-modal` is released inside that class. Desktop options are not touched (AC-11).
**Alternative:** `@media` only on the panel → the fixed `width: '1100px'` and `maxHeight` are inline styles of the overlay and win over a stylesheet.

### D7. Current courses switch template, not CSS
**Choice:** `student-profile-view.component.html` renders the `<table class="courses">` when not mobile and a `<ul class="courses-stacked">` of entries (name, then group and section) when mobile.
**Alternative:** CSS that turns the table into blocks → harder to keep accessible (header cells detach from their data) and not testable (D4).

### D8. The details header switches layout with `isMobile()`
**Choice:** `student-detail-v2.component` injects `ViewportService` and puts a `mobile` class on its header; under it the header drops its fixed 96px height, the info card stacks name, email and UUID in a column (the value may wrap) and the actions sit in one row below, so the Export, Print and Create Assessment buttons stay together (D4).
**Alternative:** a `@media` rule → untestable with the mocked service (D4). The old details modal (flag off) has a stacked header already and is not touched.

## Changes by layer

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Service | New `ViewportService` with `isMobile` (D1) | `src/app/core/services/layout/viewport.service.ts` (new) | AC-1 to AC-15 |
| Shell | `menuOpen`, `over`/`side` mode, width and margin by viewport, close on backdrop and `NavigationEnd`, hide the expand button on mobile (D2) | `src/app/core/components/layout/layout.component.{ts,html,scss}` | AC-1, AC-2, AC-3, AC-4, AC-6 |
| Header | Menu button, `menuToggle` output, compact v2 header, container forwarding (D3) | `src/app/core/components/layout/header/header-v2/header-v2.component.{ts,html,scss}`, `.../header-v2/header-container.component.ts`, `.../header/header.component.{ts,html,scss}` | AC-2, AC-5, AC-6 |
| Messages | Accessible label of the menu button | `src/app/core/constants/messages.ts` | AC-2 |
| Students list | `mobile` class on the controls bar; stacked search and buttons (D4); `compactPaginatorOnMobile` set (D5); dialog size helper (D6) | `src/app/modules/students/students-list/students-list.component.{ts,html,scss}` | AC-7, AC-9, AC-10, AC-11, AC-13, AC-14, AC-15 |
| Shared list | `compactPaginatorOnMobile` input (D5) | `src/app/shared/components/list/list.component.{ts,html}` | AC-9 |
| Cards | Card view already exists; only adjust `table-with-actions.component.scss` if the card or the page overflows at 375px | `src/app/shared/components/table-with-actions/table-with-actions.component.scss` | AC-8 |
| Dialog styles | `.mobile-fullscreen-dialog` and the inner overrides (D6) | `src/styles/utils/index.scss`, `src/app/modules/students/students-list/student-profile-summary-modal/student-profile-summary-modal.component.scss`, `src/styles/utils/_forms.scss` | AC-10, AC-13, AC-14, AC-15 |
| Details header | `mobile` class and stacked header (D8) | `src/app/shared/components/modals/modal-student-detail/v2/student-detail-v2/student-detail-v2.component.{ts,html,scss}` | AC-16 |
| Profile | Stacked courses template and styles (D7) | `src/app/modules/students/students-list/student-profile-view/student-profile-view.component.{ts,html,scss}` | AC-12 |

No new route, model, service for the API, role or permission is involved: no `ROUTE_METADATA`, `canActivateAuthRole` or `PermissionsService` change.

## API contract
No API change.

## Data and migration
No schema change.

## Test strategy

All tests are FE (Jasmine/Karma) and use `[659-improve-students-mobile-view/AC-n]` first in the `it()` title. `ViewportService` is replaced by `{ isMobile: signal(...) }` so a test flips the viewport. Visual outcomes are asserted from the real DOM: computed styles, bounding rectangles and `scrollWidth <= clientWidth` inside a 375px wide host element.

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | FE | `src/app/core/components/layout/layout.component.spec.ts` (new); sidebar and toast stubbed, real header with stubbed user and flag services | `[659-improve-students-mobile-view/AC-1] hides the side menu and removes the content margin on a mobile screen` |
| AC-2 | FE | same file | `[659-improve-students-mobile-view/AC-2] opens the side menu over the content when the header menu button is pressed` |
| AC-3 | FE | same file, with `provideRouter` | `[659-improve-students-mobile-view/AC-3] closes the side menu after navigating to Students` |
| AC-4 | FE | same file | `[659-improve-students-mobile-view/AC-4] closes the side menu when the backdrop is tapped` |
| AC-5 | FE | `src/app/core/components/layout/header/header-v2/header-v2.component.spec.ts` (new) | `[659-improve-students-mobile-view/AC-5] shows only the menu button, the title and the user menu on mobile` |
| AC-6 | FE | `src/app/core/components/layout/layout.component.spec.ts` | `[659-improve-students-mobile-view/AC-6] keeps the side menu beside the content and the full header on a 1280px screen` |
| AC-7 | FE | `src/app/modules/students/students-list/students-list-mobile.component.spec.ts` (new, real `MatDialog`, real `app-list`) | `[659-improve-students-mobile-view/AC-7] stacks the search field above the action buttons on mobile` |
| AC-8 | FE | same file; sets `window.innerWidth` to 375 as the table spec already does | `[659-improve-students-mobile-view/AC-8] shows each student as a card with every column and the actions` |
| AC-9 | FE | same file | `[659-improve-students-mobile-view/AC-9] reduces the pagination of the Students list on mobile` |
| AC-10 | FE | same file; real `MatDialog` with the profile summary modal and a stubbed profile service | `[659-improve-students-mobile-view/AC-10] opens the profile summary full screen on mobile` |
| AC-11 | FE | same file; `MatDialog.open` spied with `callThrough` on a desktop viewport | `[659-improve-students-mobile-view/AC-11] keeps the 1100px profile summary on a desktop screen` |
| AC-12 | FE | `src/app/modules/students/students-list/student-profile-view/student-profile-view.component.spec.ts` (existing) | `[659-improve-students-mobile-view/AC-12] stacks each current course with its group and section on mobile` |
| AC-13 | FE | `students-list-mobile.component.spec.ts`; asserts the options passed to `MatDialog.open` for the details modal | `[659-improve-students-mobile-view/AC-13] opens the student details full screen on mobile` |
| AC-14 | FE | same file; options passed to `MatDialog.open` for the student record | `[659-improve-students-mobile-view/AC-14] opens the student record full screen on mobile` |
| AC-15 | FE | same file; options passed to `MatDialog.open` for the new student form | `[659-improve-students-mobile-view/AC-15] opens the new student form full screen on mobile` |
| AC-16 | FE | `student-detail-v2.component.spec.ts` (existing; 375px host, `ViewportService` mocked); asserts name, email and UUID stack, and the three buttons share one row inside the host | `[659-improve-students-mobile-view/AC-16] stacks the student data and keeps the three buttons in one row on mobile` |

AC-13, AC-14 and AC-15 prove the dialog options, which are shared with AC-10 through D6; whether their content fits the screen is checked by hand in `/sdd-validate-impl`. Extra edge-case tests (the service's initial value and change, the legacy header's menu button, the sidenav keeping a submenu open) carry no AC tag. Coverage gate: FE >= 15% (AGENTS.md section 8.7).

## Risks / Trade-offs

- [The shell is shared by every page] → the new behavior is gated on `isMobile()`; AC-6 and the existing sidebar specs guard the desktop path, and the change is checked by hand on `/students`, a report and the home page.
- [`mat-sidenav` changing `mode` at runtime (rotating the phone, resizing the window)] → bind `mode`, `opened` and `disableClose` together from one signal and cover the switch with an untagged test.
- [Two mechanisms for the same 768px threshold (`ViewportService` and `window.innerWidth` in the table)] → same value, no visible difference; unifying them is a follow-up.
- [Full-screen dialogs use `100dvh`; very old browsers ignore it] → fallback to `100vh` declared in the panel class.
- [The details modal and the student record keep their inner layout] → full screen only, except the details header (AC-16); other content that overflows is reported in `/sdd-validate-impl`, not fixed here (scope clarified).

## Open Questions

- None.

## Follow-ups

- Move `app-table-with-actions`, `import-preview` and `import-answers-preview` from `window.innerWidth` to `ViewportService`.
- With the new sidebar (260px fixed) screens between 768px and 1200px stay cramped; a tablet layout needs its own change.
- Adapt the charts and tables inside the student details modal to mobile (its header is done, AC-16).
- Adapt the intervention form dialog (586px, `maxWidth: 95vw`) and the import dialogs to mobile.
- Apply the compact pagination to the other lists if wanted.
