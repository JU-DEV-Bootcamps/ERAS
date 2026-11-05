# Tasks

## 1. Frontend (FE): viewport service

- [x] 1.1 Write an untagged spec for `ViewportService` in `ERAS-FE/src/app/core/services/layout/viewport.service.spec.ts` (initial value from `BreakpointObserver`, and it flips when the observer emits) and verify it fails
- [x] 1.2 Implement `ViewportService` with `isMobile` and the 768px query constant in `ERAS-FE/src/app/core/services/layout/viewport.service.ts` and verify the spec from 1.1 passes

## 2. Frontend (FE): application shell (layout and headers)

- [x] 2.1 Write the spec `[659-improve-students-mobile-view/AC-1] hides the side menu and removes the content margin on a mobile screen` for (AC-1) in `ERAS-FE/src/app/core/components/layout/layout.component.spec.ts` (new; `SidebarComponent` and the toast stubbed, `ViewportService` mocked) and verify it fails
- [x] 2.2 Write the spec `[659-improve-students-mobile-view/AC-2] opens the side menu over the content when the header menu button is pressed` for (AC-2) in the same file and verify it fails
- [x] 2.3 Write the spec `[659-improve-students-mobile-view/AC-3] closes the side menu after navigating to Students` for (AC-3) in the same file, using `provideRouter`, and verify it fails
- [x] 2.4 Write the spec `[659-improve-students-mobile-view/AC-4] closes the side menu when the backdrop is tapped` for (AC-4) in the same file and verify it fails
- [x] 2.5 Write the spec `[659-improve-students-mobile-view/AC-6] keeps the side menu beside the content and the full header on a 1280px screen` for (AC-6) in the same file, with the real header and stubbed user and feature-flag services, and verify it fails or already passes against today's layout
- [x] 2.6 Write the spec `[659-improve-students-mobile-view/AC-5] shows only the menu button, the title and the user menu on mobile` for (AC-5) in `ERAS-FE/src/app/core/components/layout/header/header-v2/header-v2.component.spec.ts` (new) and verify it fails
- [x] 2.7 Add the menu button label to `ERAS-FE/src/app/core/constants/messages.ts` for (AC-2) and verify `npm run build` compiles it
- [x] 2.8 Implement the menu button, the `menuToggle` output and the compact mobile header in `header-v2.component.{ts,html,scss}` and `header.component.{ts,html,scss}`, and forward the output from `header-container.component.ts`, for (AC-5) and (AC-2), and verify the spec from 2.6 passes
- [x] 2.9 Implement `menuOpen`, the `over`/`side` mode, the width and margin by viewport, the close on backdrop and `NavigationEnd`, and hiding the expand button on mobile in `layout.component.{ts,html,scss}` for (AC-1), (AC-2), (AC-3), (AC-4) and (AC-6), and verify the specs from 2.1 to 2.5 pass
- [x] 2.10 Write an untagged spec in `layout.component.spec.ts` that switching the viewport from desktop to mobile and back keeps the sidenav state coherent, and for the legacy header's menu button, and verify they pass

## 3. Frontend (FE): Students list controls, cards and pagination

- [x] 3.1 Write the spec `[659-improve-students-mobile-view/AC-7] stacks the search field above the action buttons on mobile` for (AC-7) in `ERAS-FE/src/app/modules/students/students-list/students-list-mobile.component.spec.ts` (new; real `app-list`, real `MatDialog`, `ViewportService` mocked, 375px host) and verify it fails
- [x] 3.2 Write the spec `[659-improve-students-mobile-view/AC-8] shows each student as a card with every column and the actions` for (AC-8) in the same file (`window.innerWidth` set to 375 as `table-with-actions.component.spec.ts` does) and verify it fails or already passes
- [x] 3.3 Write the spec `[659-improve-students-mobile-view/AC-9] reduces the pagination of the Students list on mobile` for (AC-9) in the same file and verify it fails
- [x] 3.4 Implement the `mobile` class on the controls bar and its stacked styles in `students-list.component.{html,scss}` for (AC-7) and verify the spec from 3.1 passes
- [x] 3.5 Implement the `compactPaginatorOnMobile` input in `ERAS-FE/src/app/shared/components/list/list.component.{ts,html}` and set it in `students-list.component.html` for (AC-9), and verify the spec from 3.3 passes and the existing `list.component.spec.ts` still passes
- [x] 3.6 Adjust `ERAS-FE/src/app/shared/components/table-with-actions/table-with-actions.component.scss` only as far as the spec from 3.2 needs (card or page overflow at 375px) for (AC-8) and verify the spec from 3.2 passes

## 4. Frontend (FE): full-screen student modals

- [x] 4.1 Write the spec `[659-improve-students-mobile-view/AC-10] opens the profile summary full screen on mobile` for (AC-10) in `students-list-mobile.component.spec.ts` (real `MatDialog`, stubbed profile service; the overlay fills the window and the Close button is inside it) and verify it fails
- [x] 4.2 Write the spec `[659-improve-students-mobile-view/AC-11] keeps the 1100px profile summary on a desktop screen` for (AC-11) in the same file and verify it fails or already passes against today's options
- [x] 4.3 Write the specs `[659-improve-students-mobile-view/AC-13] opens the student details full screen on mobile`, `[659-improve-students-mobile-view/AC-14] opens the student record full screen on mobile` and `[659-improve-students-mobile-view/AC-15] opens the new student form full screen on mobile` for (AC-13), (AC-14) and (AC-15) in the same file, as three separate `it()` blocks asserting the options passed to `MatDialog.open`, and verify they fail
- [x] 4.4 Implement the dialog size helper in `students-list.component.ts` and use it in `openStudentDetails`, `openProfileSummaryModal`, the student record and the new student form for (AC-10), (AC-11), (AC-13), (AC-14) and (AC-15), and verify the specs from 4.1 to 4.3 pass
- [x] 4.5 Add `.mobile-fullscreen-dialog` (square corners, flex column, scrolling content, visible footer, `100vh` fallback) in `ERAS-FE/src/styles/utils/index.scss`, and release the `max-height: 75vh` of `.profile-modal` inside it, for (AC-10), (AC-13), (AC-14) and (AC-15), and verify the spec from 4.1 passes
- [x] 4.6 Write the spec `[659-improve-students-mobile-view/AC-16] stacks the student data and keeps the three buttons in one row on mobile` for (AC-16) in `ERAS-FE/src/app/shared/components/modals/modal-student-detail/v2/student-detail-v2/student-detail-v2.component.spec.ts` (existing; 375px host, `ViewportService` mocked) and verify it fails
- [x] 4.7 Implement the `mobile` class and the stacked header in `student-detail-v2.component.{ts,html,scss}` for (AC-16) and verify the spec from 4.6 passes and the existing specs of the component still pass

## 5. Frontend (FE): stacked current courses

- [x] 5.1 Write the spec `[659-improve-students-mobile-view/AC-12] stacks each current course with its group and section on mobile` for (AC-12) in `ERAS-FE/src/app/modules/students/students-list/student-profile-view/student-profile-view.component.spec.ts` (existing; 375px host, `ViewportService` mocked) and verify it fails
- [x] 5.2 Implement the stacked courses list and its styles in `student-profile-view.component.{ts,html,scss}` for (AC-12) and verify the spec from 5.1 passes and the desktop table spec still passes

## 6. Verification

- [x] 6.1 BE gates: no BE file changed in `ERAS-BE/` (`git -C ERAS-BE status` shows only the local `appsettings.json`); nothing to run
- [x] 6.2 FE gates pass in `ERAS-FE/` (AGENTS.md section 8.7): `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (>= 15%), `npm run build`
- [x] 6.3 The AC traceability check (AGENTS.md section 8.6) shows exactly 1 FE test per AC (AC-1 to AC-15), and `openspec validate 659-improve-students-mobile-view --strict` passes

## Traceability
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | Side menu is hidden and content uses the full width on mobile | FE | src/app/core/components/layout/layout.component.spec.ts › [659-improve-students-mobile-view/AC-1] hides the side menu and removes the content margin on a mobile screen |
| AC-2 | Menu button opens the side menu over the content | FE | src/app/core/components/layout/layout.component.spec.ts › [659-improve-students-mobile-view/AC-2] opens the side menu over the content when the header menu button is pressed |
| AC-3 | Picking a page closes the side menu | FE | src/app/core/components/layout/layout.component.spec.ts › [659-improve-students-mobile-view/AC-3] closes the side menu after navigating to Students |
| AC-4 | Tapping outside closes the side menu | FE | src/app/core/components/layout/layout.component.spec.ts › [659-improve-students-mobile-view/AC-4] closes the side menu when the backdrop is tapped |
| AC-5 | Header shows only the essentials on mobile | FE | src/app/core/components/layout/header/header-v2/header-v2.component.spec.ts › [659-improve-students-mobile-view/AC-5] shows only the menu button, the title and the user menu on mobile |
| AC-6 | Desktop keeps the side menu beside the content | FE | src/app/core/components/layout/layout.component.spec.ts › [659-improve-students-mobile-view/AC-6] keeps the side menu beside the content and the full header on a 1280px screen |
| AC-7 | Search and action buttons stack on mobile | FE | src/app/modules/students/students-list/students-list-mobile.component.spec.ts › [659-improve-students-mobile-view/AC-7] stacks the search field above the action buttons on mobile |
| AC-8 | Student card shows every column and the actions | FE | src/app/modules/students/students-list/students-list-mobile.component.spec.ts › [659-improve-students-mobile-view/AC-8] shows each student as a card with every column and the actions |
| AC-9 | Pagination is reduced on mobile | FE | src/app/modules/students/students-list/students-list-mobile.component.spec.ts › [659-improve-students-mobile-view/AC-9] reduces the pagination of the Students list on mobile |
| AC-10 | Student modals open full screen on mobile | FE | src/app/modules/students/students-list/students-list-mobile.component.spec.ts › [659-improve-students-mobile-view/AC-10] opens the profile summary full screen on mobile |
| AC-11 | Student modals keep their size on larger screens | FE | src/app/modules/students/students-list/students-list-mobile.component.spec.ts › [659-improve-students-mobile-view/AC-11] keeps the 1100px profile summary on a desktop screen |
| AC-12 | Current courses are readable without horizontal scroll | FE | src/app/modules/students/students-list/student-profile-view/student-profile-view.component.spec.ts › [659-improve-students-mobile-view/AC-12] stacks each current course with its group and section on mobile |
| AC-13 | Student details modal opens full screen on mobile | FE | src/app/modules/students/students-list/students-list-mobile.component.spec.ts › [659-improve-students-mobile-view/AC-13] opens the student details full screen on mobile |
| AC-14 | Student record opens full screen on mobile | FE | src/app/modules/students/students-list/students-list-mobile.component.spec.ts › [659-improve-students-mobile-view/AC-14] opens the student record full screen on mobile |
| AC-15 | New student form opens full screen on mobile | FE | src/app/modules/students/students-list/students-list-mobile.component.spec.ts › [659-improve-students-mobile-view/AC-15] opens the new student form full screen on mobile |
| AC-16 | Student details header is readable on mobile | FE | src/app/shared/components/modals/modal-student-detail/v2/student-detail-v2/student-detail-v2.component.spec.ts › [659-improve-students-mobile-view/AC-16] stacks the student data and keeps the three buttons in one row on mobile |
