# Design

## Context

FE only. The spec is `specs/students-mobile-view/spec.md` (AC-1 to AC-3); the reason is in `proposal.md`.

- The Student Details modal has two versions behind the `studentDetails` feature flag: `src/app/shared/components/modals/modal-student-detail/v2/student-detail-v2/` (the one shown with the flag) and `.../modal-student-detail/student-detail/` (the older one). Both show the student's answers with the shared list `app-list` (`src/app/shared/components/list/`), which draws a `mat-paginator` inside its own template.
- On a phone the paginator container wraps: the page-size selector takes the first row, and the range label ("21 – 30 of 46") and the four page buttons are left to share the second row. The label has the Material margins (24px and 32px) and shrinks, so "46" falls on a second line.
- `student-detail-v2.component.ts` already reads `ViewportService.isMobile` and puts a `mobile` class on its header (#659). The older version has no `isMobile`.
- The shared list is used by many screens and has its own opt-in for a compact paginator (`compactPaginatorOnMobile`, #659). The proposal says nothing else may change.

## Goals / Non-Goals

**Goals:**
- The range label of the paginator of the Student Details modal is on one line, on the same row as the page buttons, on a phone (AC-1).
- Desktop and every other pagination keep today's look (AC-2, AC-3) and, on the narrowest phones, the buttons below the range inside the card (AC-4).

**Non-Goals:**
- Changing the shared list or its paginator for everyone (D1).
- Hiding or moving the page-size selector or the page buttons.
- Any other modal, and the charts and tables inside this modal.

## Decisions

### D1. A style local to the Student Details modal, not a change of the shared list
**Choice:** the version of the modal that wraps (v2) puts a `mobile` class, driven by `ViewportService.isMobile()`, on the container of its list (`.card-answers`) and its `.scss` styles the paginator range label under that class with `::ng-deep` (the paginator belongs to the list's template): `white-space: nowrap` and no side margin for the label, and no side padding for the paginator (the 8px of room the range and the four buttons are short of at 375px), so the label and the four buttons fit one row of the modal. On a narrower phone (320px) the buttons wrap below the range, inside the card, instead of going out of it (`flex-wrap` on the range actions). The rule is nested under the container class, so no other list is reached.
**Alternative:** an input of `app-list` (or its `compactPaginatorOnMobile`) → it changes a component used by many screens, hides controls the user did not ask to lose, and widens the blast radius.
**Alternative:** a global `mat-paginator` style → it would change every pagination of the app.

### D2. Mobile is decided with `ViewportService`, as in #659 and #669
**Choice:** the class comes from `isMobile()` (narrower than 768px), never from `@media` or `window.innerWidth` (`ERAS-FE/AGENTS.md` section 7.2), so a spec can drive it with a mocked service.
**Alternative:** `@media (max-width: 767.98px)` in the `.scss` → a spec cannot resize the Karma window.

## Changes by layer

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Student details v2 | `mobile` class on `.card-answers` and the range label rule under it (D1) | `src/app/shared/components/modals/modal-student-detail/v2/student-detail-v2/student-detail-v2.component.{html,scss}` | AC-1, AC-2 |
| Student details (older) | no change: its list has less padding than the card of v2, so its range label does not wrap at 375px (checked by a guard test with no AC tag, task 1.5; it has less padding than v2) | `src/app/shared/components/modals/modal-student-detail/student-detail/student-detail.component.spec.ts` | (none) |
| Shared list | no change |  | AC-3 (tested from the spec of v2) |

## API contract

No API change.

## Data and migration

No schema change.

## Test strategy

AC-1, AC-2 and AC-4 render the real `StudentDetailV2Component` with its services mocked as the existing spec does, 46 answers (10 per page) and `ViewportService` mocked with `{ isMobile: signal(true) }` for AC-1 and `signal(false)` for AC-2; the component is placed in a host as wide as the modal's list (375px on a phone, 320px on the narrowest phones, as wide as the modal; 1100px on a desktop) because the paginator wraps by the width of its container, which holds in the default Karma window and in a 375px one. The test goes to the third page by pressing the next button twice, so the label is "21 – 30 of 46", the widest case. It measures the range label (height of one line, on the same row as the page buttons, inside the host). AC-3 creates a real `mat-paginator` with 46 items outside the answers card, next to the modal, and checks that its range label, container and buttons keep the style of Material. The same measurement for the older version is an extra test with no AC tag. The 375px run follows the way of #670 (`npm test -- --watch=true --include=<specs>` and `http://localhost:9876/debug.html` in the Browser pane with the Mobile preset). Coverage gate: FE >= 15% (AGENTS.md section 8.7).

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | FE | `src/app/shared/components/modals/modal-student-detail/v2/student-detail-v2/student-detail-v2.component.spec.ts` | `[670-align-student-details-pagination/AC-1] shows the range of the answers pagination on one line next to the page buttons on a phone` |
| AC-2 | FE | same file | `[670-align-student-details-pagination/AC-2] keeps the answers pagination of a desktop with its range next to the four page buttons` |
| AC-3 | FE | same file | `[670-align-student-details-pagination/AC-3] keeps the style of a pagination outside the answers of the student details` |
| AC-4 | FE | same file | `[670-align-student-details-pagination/AC-4] keeps the range on one line and the page buttons inside the card on the narrowest phones` |

AC-2 and AC-3 may already pass before the change (they guard what must not change); then they are guard tests and are proven by breaking the code temporarily, as in #669.

## Risks / Trade-offs

- [`::ng-deep` is deprecated] → it is the way the shared list is styled from outside today (`list.component.scss`), and the rule is nested under one container class so it reaches nothing else.
- [The label and four buttons need about 253px, and a phone narrower than about 370px has less] → the range actions wrap, so at 320px the buttons go below the range, inside the card; AC-4 measures it (task 1.7), and an extra spec with no AC tag measures 360px, the most common Android width, which has the same layout: the row needs about 253px and a 360px card has less, so the buttons go below the range. From 375px the row fits.
- [Two versions of the modal] → only v2 wraps its label at 375px (task 1.5); the older one is left as it is and keeps a guard test.

## Open Questions

None.

## Follow-ups

- Other lists show the same wrapped label on a narrow screen; each is fixed when it is reported, not here.
