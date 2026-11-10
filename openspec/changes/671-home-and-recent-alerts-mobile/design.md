# Design

## Context

Home v2 (`ERAS-FE/src/app/modules/home-v2/home.component.{html,scss}`) lays out `.section-alerts-support` as a `grid-template-columns: repeat(3, 1fr)` with `.recent-alerts` spanning columns 1 to 2, and has no `@media` rule. `summary-details.component.ts` already sets `gridColumns` to 1 with `BreakpointObserver.observe([Breakpoints.XSmall])` (under 600px), but its template and SCSS never use it: `.grid-list` is a fixed `repeat(3, 1fr)`. `app-stats-card-v2` has `padding: 32px` and a `max-width: 310px` information column. `service-card-readable.component.scss` fixes `.card` at `width: 330px`. The Recent Alerts block (`home-v2/recent-alerts`) and the page (`modules/lists/components/recent-alerts-list`) both render `app-list`, which renders `app-table-with-actions`; that table already switches to cards below 768px with `window.innerWidth` (`isMobile`), and `ListComponent` already injects `ViewportService` (`core/services/layout/viewport.service.ts`, `isMobile` signal below 768px, added by change 659). The Home template has no role checks; `ROUTE_METADATA.HOME` and `RECENT_ALERTS` decide who reaches the pages. Motivation and scope: `proposal.md`.

## Goals / Non-Goals

**Goals:**
- Stack the Home summary cards, fit the Recent Alerts block and the service cards to the screen below 768px (AC-1, AC-3, AC-4).
- Prove the alerts are cards without horizontal scroll on the page and in the block (AC-2, AC-3).
- Prove each role sees the same sections on mobile and desktop (AC-6 to AC-8) and that desktop keeps three columns (AC-9).

**Non-Goals:**
- Moving `app-table-with-actions` from `window.innerWidth` to `ViewportService`.
- The legacy Home and the risk students table.

## Decisions

### D1. Layout switches on `ViewportService.isMobile()` with a `mobile` class
**Choice:** `HomeV2Component`, `SummaryDetailsV2Component` and `ServiceCardReadableComponent` inject `ViewportService` and bind `[class.mobile]="viewport.isMobile()"` on their root element. The SCSS under `.mobile` sets one column and `width: 100%`. Tests replace the service with `{ isMobile: signal(...) }`, as in change 659.
**Alternative:** `@media (max-width: 767px)` in each stylesheet → cannot be proven by a test, because the Karma window size is not controlled per test; the existing `Breakpoints.XSmall` (600px) in summary-details has the wrong threshold (A1: 768px).

### D2. Remove the unused `gridColumns` XSmall observer from summary-details
**Choice:** `SummaryDetailsV2Component` drops its `BreakpointObserver` subscription and `gridColumns`, since D1 replaces it and it never reached the template. Its existing spec stops providing the mock.
**Alternative:** keep both → two thresholds (600px and 768px) for the same grid.

### D3. Recent Alerts cards are verified, not rebuilt
**Choice:** no new alert card. `app-table-with-actions` already renders cards when `window.innerWidth < 768` with every column and the templates (risk level, status). The work is to let the block and the page fit: the Home alerts block spans the full width on mobile (D1), and the badges (`white-space: nowrap`, `display: block`) and card rows wrap inside 375px. AC-2 and AC-3 tests mount the real `app-list` at 375px with `window.innerWidth` set to 375, as the table spec does.
**Alternative:** a new alert card component → duplicates the shared card for the same fields (A2).

## Changes by layer

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Home layout | `mobile` class on the root; under it `.section-alerts-support` is one column and `.recent-alerts` spans it; `.header-section` wraps | `src/app/modules/home-v2/home.component.{ts,html,scss}` | AC-3, AC-9 |
| Summary cards | `mobile` class; `.grid-list` is one column under it; drop `gridColumns` and the XSmall observer; smaller card padding on mobile | `src/app/modules/home-v2/summary-details/summary-details.component.{ts,html,scss}`, `src/app/shared/components/cards/stats-card-v2/stats-card-v2.component.scss` | AC-1, AC-9 |
| Service cards | `mobile` class; `.card` is `width: 100%` and keeps `max-width: 330px` on desktop | `src/app/shared/components/cards/service-card-readable/service-card-readable.component.{ts,html,scss}` | AC-4 |
| Recent alerts | wrap badges and rows so cards fit 375px, in the block and on the page | `src/app/modules/home-v2/recent-alerts/recent-alerts.component.scss`, `src/app/modules/lists/components/recent-alerts-list/recent-alerts-list.component.scss` | AC-2, AC-3 |
| Roles | no code change; a test proves the template has no role-dependent section | `src/app/modules/home-v2/home.component.spec.ts` (new) | AC-6, AC-7, AC-8 |

No route, model, service, message or API change.

## API contract
No API change.

## Data and migration
No schema change.

## Test strategy

All tests are FE (Jasmine/Karma), with `[671-home-and-recent-alerts-mobile/AC-n]` first in the `it()` title. `ViewportService` is replaced by `{ isMobile: signal(...) }`; `window.innerWidth` is set to 375 or 1280 where the shared table needs it. Layout is asserted from the real DOM in a 375px wide host: computed `grid-template-columns`, bounding rectangles and `scrollWidth <= clientWidth`. Child components that call the API are stubbed with services returning fixed data.

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | FE | `src/app/modules/home-v2/summary-details/summary-details.component.spec.ts` | `[671-home-and-recent-alerts-mobile/AC-1] stacks the three summary cards in one column without overflow on mobile` |
| AC-2 | FE | `src/app/modules/lists/components/recent-alerts-list/recent-alerts-list.component.spec.ts`, real `app-list` | `[671-home-and-recent-alerts-mobile/AC-2] shows each alert as a card without horizontal scroll on mobile` |
| AC-3 | FE | `src/app/modules/home-v2/home.component.spec.ts` (new), real `app-recent-alerts` and `app-list` | `[671-home-and-recent-alerts-mobile/AC-3] fits the Recent Alerts block below the summary cards on mobile` |
| AC-4 | FE | `src/app/shared/components/cards/service-card-readable/service-card-readable.component.spec.ts` | `[671-home-and-recent-alerts-mobile/AC-4] makes each service card no wider than the content on mobile` |
| AC-6 | FE | `src/app/modules/home-v2/home.component.spec.ts`, user data stub with the role "ERAS Professional" | `[671-home-and-recent-alerts-mobile/AC-6] shows a Professional the same sections on mobile and on desktop` |
| AC-7 | FE | same file, role "ERAS Student Services Officer" | `[671-home-and-recent-alerts-mobile/AC-7] shows an Officer the same sections on mobile and on desktop` |
| AC-8 | FE | same file, role "ERAS Administrator" | `[671-home-and-recent-alerts-mobile/AC-8] shows an Administrator the same sections on mobile and on desktop` |
| AC-9 | FE | same file | `[671-home-and-recent-alerts-mobile/AC-9] keeps three summary columns and a two-column alerts block on a 1280px screen` |

Extra edge-case tests carry no AC tag. Coverage gates: FE >= 15% (AGENTS.md section 8.7). The FE gates are in `ERAS-FE/AGENTS.md` §3.3.

## Risks / Trade-offs

- [`stats-card-v2` is shared] → only a padding change under a `.mobile` ancestor; desktop rules are untouched and AC-9 guards them.
- [`app-table-with-actions` still reads `window.innerWidth`] → the card switch and `ViewportService` use the same 768px, so they agree; tests set both.
- [Karma window size is not 375px] → layout is asserted inside a fixed 375px host element, not the window.

## Open Questions

None.

## Follow-ups
- Move `app-table-with-actions` fully onto `ViewportService` (one threshold source); its own change.
- The risk students table is only used by `modules/_unused/experimental/risk-students`; decide whether Home should show risk students (issue AC-3 of ERAS#671) in a new change.
- On mobile the shared table card prints the raw `Date` value (it ignores the column pipe that the desktop table applies), so alert dates read like `Sat Oct 31 2026 20:00:00 GMT-0400`; format card values with the column pipe in `table-with-actions`, which affects every list, in its own change.
