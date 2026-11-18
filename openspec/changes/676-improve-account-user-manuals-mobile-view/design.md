# Design

## Context

Account & Information (`ERAS-FE/src/app/modules/profile/components/account-information/`) is a page that shows `app-profile-card` and, for a professional, `app-professional-info` (for everyone else `app-profile-summary`). User Manuals (`ERAS-FE/src/app/modules/user-manuals/`) lists each manual as a flex row with a Download button. The page-level grid of Account & Information already collapses at 1100px; the pieces inside it do not. The measurement of 2026-11-17 (see the measurement log in `proposal.md`) found three real problems, all in styles: values and the email of the profile card go past the card, the courses table of the professional info is as wide as its longest unbreakable name, and a long manual title pushes the Download button out of its row.

The mobile switch of the app is `ViewportService.isMobile` (`ERAS-FE/src/app/core/services/layout/viewport.service.ts`, threshold 767.98px), used in components as a `mobile` class (for example `home-v2/home.component.html`) and replaced by a signal in specs (`{ provide: ViewportService, useValue: { isMobile: signal(false) } }`).

## Goals / Non-Goals

**Goals:**
- The profile card shows its values one per row and breaks a long value or email inside the card on a mobile screen (AC-1).
- The professional info is one column and its courses stay inside the card, breaking a long code or name (AC-2).
- A manual with a long title stays inside its row with the Download button visible (AC-6).
- At 768px and wider the two pages do not change (AC-5, AC-8).

**Non-Goals:**
- No change to the edit forms, the summary panel, the page grid or the 1100px rule.
- No change to the tap area of the Download button (already 48 by 48 with the Material touch target).
- No change to templates' content, the services, the models or the API.

## Decisions

### D1. A `mobile` class from `ViewportService`, not a `@media` query
**Choice:** each of the three components (`profile-card`, `professional-info`, `user-manuals`) injects `ViewportService` and sets a `mobile` class on its root element; the mobile rules are written under `.mobile` in its stylesheet. The desktop rules are not touched, so AC-5 and AC-8 hold by construction.
**Alternative:** `@media (max-width: 767px)` in the stylesheets → the Karma window is narrower than 768px, so a spec could not show the desktop layout, and the app already decides "mobile" in one place.

### D2. Wrap long values with `overflow-wrap: anywhere`, under `.mobile` only
**Choice:** `overflow-wrap: anywhere` and `min-width: 0` on the profile card email and values and on the professional info values; the info grids become one column. It only breaks a word that does not fit, so normal text looks the same.
**Alternative:** `text-overflow: ellipsis` → hides the value, and the spec asks for the whole value.

### D3. Keep the courses table a table, with a fixed layout on mobile
**Choice:** on mobile the courses table gets `table-layout: fixed` and `overflow-wrap: anywhere` on its cells, so it can never be wider than its card and a long code or name breaks over lines (A4 of the proposal).
**Alternative:** turn the table into cards, or give it a sideways scroll → more markup and tests, or the content is not visible at once; the clarification chose a table that fits.

### D4. Prove the behavior with layout tests, not style strings
**Choice:** the AC tests render the real components in a host 343px (mobile) or 1280px (desktop) wide, with a long value, and check the real layout: the value ends inside its card, wraps over more than one line, and nothing scrolls sideways; for desktop, that the values stay in two columns and are not broken. They fail without the fix.
**Alternative:** assert `overflow-wrap` in the computed style → passes with any rule that sets it and does not prove that nothing overflows.

## Changes by layer

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Profile card | `mobile` class from `ViewportService`; one-column grid and wrapping of the email and values on mobile | `src/app/modules/profile/components/account-information/profile-card/profile-card.component.{ts,html,scss}` | AC-1, AC-5 |
| Professional info | `mobile` class; one-column grid, wrapping of values and chips, fixed layout and wrapping of the courses table on mobile | `src/app/modules/profile/components/account-information/professional-info/professional-info.component.{ts,html,scss}` | AC-2, AC-5 |
| User manuals | `mobile` class; the info block can shrink (`min-width: 0`), the title wraps and the Download button does not shrink on mobile | `src/app/modules/user-manuals/user-manuals.component.{ts,html,scss}` | AC-6, AC-8 |
| Tests | Page-level layout tests with the real children and a `ViewportService` signal; a layout test for the manuals list | `src/app/modules/profile/components/account-information/account-information.component.spec.ts`, `src/app/modules/user-manuals/user-manuals.component.spec.ts` | AC-1, AC-2, AC-5, AC-6, AC-8 |

## API contract

No API change.

## Data and migration

No schema change.

## Test strategy

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | FE | `src/app/modules/profile/components/account-information/account-information.component.spec.ts` | `[676-improve-account-user-manuals-mobile-view/AC-1] keeps a 60-character email and long values inside the profile card on a mobile screen` |
| AC-2 | FE | same file | `[676-improve-account-user-manuals-mobile-view/AC-2] stacks the professional info and keeps a long course name inside its card on a mobile screen` |
| AC-5 | FE | same file | `[676-improve-account-user-manuals-mobile-view/AC-5] keeps two columns and does not break values on a desktop screen` |
| AC-6 | FE | `src/app/modules/user-manuals/user-manuals.component.spec.ts` | `[676-improve-account-user-manuals-mobile-view/AC-6] keeps a 100-character title and the Download button inside the row on a mobile screen` |
| AC-8 | FE | same file | `[676-improve-account-user-manuals-mobile-view/AC-8] keeps the row and does not break the title on a desktop screen` |

Extra edge-case tests carry no AC tag. AC-5 and AC-8 guard against a regression, so they pass before and after the change. The Karma window is narrower than 768px, so every spec of these components provides `ViewportService` as `{ isMobile: signal(...) }`. Coverage gate: FE >= 15% (AGENTS.md section 8.7).

## Risks / Trade-offs

- [Existing specs of `profile-card`, `professional-info` and `user-manuals` start getting the real `ViewportService`] → it reads the Karma window, which is mobile; the specs that check desktop behavior provide `isMobile: signal(false)`, and the three spec files must stay green.
- [The `mobile` class changes a root element that tests may query] → the class is added, nothing is renamed or removed.
- [Measured only on the local app with long values typed into the page, and the manuals list with a simulated API answer] → the manual validation (`/sdd-validate-impl`) repeats the check at 375px with the real component before closing.

## Follow-ups

- The local back end of Visual Studio answered 500 for `/api/v1/manuals/` on 2026-11-17 because it did not point to the repository `manuals/` folder; `manuals/README.md` explains `UserManuals__Path`. Not part of this change.
- The Summary panel (administrator and officer) was only seen at normal values at 375px, not with long ones.
