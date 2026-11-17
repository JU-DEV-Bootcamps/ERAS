# Design

## Context

Reports live in `ERAS-FE/src/app/modules/reports/` (below: `R/` is `components/`). `ReportsComponent` renders `app-tabbed-layout` (`shared/components/tabbed-layout-component/`) with three routed pages for the v2 reports: `R/dynamic-charts-v2`, `R/summary-charts-v2` and `R/polls-answered`. The three share `app-poll-filters` (`R/poll-filters`), which the legacy `reports-v1` pages also use. The legacy `reports-v1` route and its components (`R/dynamic-charts`, `R/summary-charts`) are out of scope and are not edited.

How each piece behaved before this change, from the code:

- **Dynamic Charts v2.** `.charts-grid` and `.charts-layout` are `grid-template-columns: 1fr 1fr` with no `@media`. `generateSeries()` computes each card width as `totalWidth / CARD_LAYOUT.columns - spacing` with `columns: 2`, and `GetChartOptions` (`core/utils/apex-chart/heat-map-config-v2.ts`) derives the cell width and the label area (30% compact, 50% expanded) from that width, with a `22px` title and default label fonts. The cards are `app-expandable-card` (`shared/components/expandable-card-v2/`), whose Export, chart type and expand buttons are `position: absolute` at the top of the card over the chart title. The details are `app-details-panel` in `aside.details-aside` (`width: 380px`, `grid-column: 3`, sticky) inside the grid. The cards hide the native Apex tooltip (`.card-body .apexcharts-tooltip { display: none }`) and the charts use `ApexTooltipDirective` (`shared/components/apex-tooltip/`), which listened to `mousemove` / `mouseleave` only, flipped to the left of the pointer when the right side is short, and never clamped to the screen (the tooltip is `min-width: 282px`, `max-width: 402px`).
- **Summary Charts v2.** `.summary-layout` is a flex row with `aside.details-aside` (`width: 440px`) beside `.summary-content`; the only `@media (max-width: 768px)` changes paddings. The heatmap comes from `GetChartOptions` of `heat-map-config.ts` (v1 config, no label font settings, `baseChartOptions` is spread over the options; the legacy v1 charts use it too); the column chart is `app-summary-column-charts-v2` (`ColumnChartUtils`, with an Apex `responsive` breakpoint at 1000px). Both use Apex's own tooltip (`TooltipChartV2Component` html, `max-width: 402px`). Student Answers is `app-list` with the export dropdown (`.container-title-button` is a flex row; `.export-select` has `min-width: 220px`) and, on mobile, `app-table-with-actions` already renders cards. The column details are `app-column-risk-panel` in the same aside. The Export button of the report is `report-card__actions` (already `flex-wrap`).
- **Details panel content.** `app-details-panel` (`shared/components/panels/details-panel-v2/`) shows the student list with `app-list-details` and `app-mat-card-details`, whose `mat-card` is a flex row with `.row-info { width: 210px }`; with the badge and the actions it is wider than the panel at 375px, which pushed the panel to a side and made the page scroll sideways.
- **PDF.** `PdfHelper` (`core/utils/reports/exportReport.util.ts`) clones the on-screen DOM. `measureAndPrepare` first lays the clone out at `width: 100%` of the screen, calls it landscape when width > height, then resizes it to `LETTER_PX` (816 portrait, 1056 landscape). So the orientation depends on the width of the screen, and the clone holds whatever the screen rendered (cards, mobile chart options). `STYLE_CONF.width: '1440px'` in `R/summary-charts/constants/export-conf.ts` is not used by any code. Callers: the Summary report, the Dynamic card (`exportCardToPdf`), `ListComponent` (Student Answers and the Students list, with `exportToPdfChunked` above 100 rows), the student detail modals and the legacy `reports-v1` pages.
- **Mobile infrastructure that already exists:** `ViewportService.isMobile` (`core/services/layout/viewport.service.ts`, below 768px), the pattern of changes 659, 672 and 673 (layout driven by `isMobile()` and a `mobile` class, specs replace the service, full-screen details fixed over the page at `z-index: 999`, see `assessments-mobile-view`), `ListComponent.compactPaginatorOnMobile` (an opt-in input) and the shared cards of `app-table-with-actions`. Motivation and scope: `proposal.md`.

## Goals / Non-Goals

**Goals:**
- Filters, tabs, Dynamic Charts and Summary Charts that fit 375px, with smaller chart labels and room below the filters (AC-1 to AC-7, AC-24, AC-26).
- Lists as cards that fit, and the Student Answers export controls below the title (AC-8, AC-9, AC-24).
- Details as a centered full-screen page with a student list that fits and lines up (AC-10 to AC-13, AC-28).
- A tooltip that fits the screen, opens details on the second tap, hides when they open and hides on a tap outside (AC-14 to AC-16, AC-25).
- PDFs from a phone equal to the desktop ones, without the app shell changing while they are made (AC-17 to AC-20, AC-27).
- Nothing changes from 768px (AC-21 to AC-23).

**Non-Goals:**
- Changing the legacy `reports-v1` components. They share `app-poll-filters` with the v2 pages, so their filters also stack on mobile; their charts, lists and PDF export do not change.
- Rebuilding the Dynamic heatmaps when the screen crosses 768px after they were generated (their options and card width are computed when the data loads or the layout is regenerated, as today). The Summary heatmap, both column charts, the lists and the details do follow the viewport live.
- Replacing the legacy `@Input()` / `@Output()` / `*ngIf` of the files this change edits.
- The 48px tap area and the focus handling of the full-screen details (recorded under Follow-ups).

## Decisions

### D1. The layout switches on `ViewportService.isMobile()` and a `mobile` class, not on `@media`
**Choice:** each unit that changes reads `inject(ViewportService).isMobile` and binds `[class.mobile]` on its host or root (`host: { '[class.mobile]': 'isMobile()' }`); every new rule is written under `.mobile`. The existing `@media (max-width: 768px)` block of `summary-charts-v2.component.scss` moved under `.mobile` too (so the paddings now stop applying at exactly 768px, as the rest of the app does). Specs replace the service with `{ isMobile: signal(...), renderAsDesktop: signal(false) }`.
**Alternative:** `@media (max-width: 767.98px)` → Karma's window width cannot be set per test, and the PDF clone is laid out at another width than the screen, so a media query would give the phone's styles to the desktop-sized clone (D8).

### D2. Dynamic Charts go to one column and smaller labels through the options
**Choice:** `.charts-grid` and `.charts-layout` become `grid-template-columns: minmax(0, 1fr)` under `.mobile`, `generateSeries()` uses `columns: 1` when `isMobile()`, and `GetChartOptions` of `heat-map-config-v2.ts` gets a last optional parameter `isMobile = false`: when true the title is `14px` and the label fonts (`yaxis.labels.style.fontSize`, data labels) are `MOBILE_CHART_LABEL_FONT_SIZE` (`10px`, in `chart.constants.ts`, shared by every mobile label). `ColumnChartUtils.createXAxis(categories, isMobile)` does the same for the column charts. Under `.mobile`, `app-poll-filters` is a block with `margin-bottom: 16px` so the Apply button does not touch the first card (AC-26).
**Alternative:** CSS `font-size` on the Apex SVG text → Apex positions the label area from its own font settings, so the layout would not follow the font.

### D3. The card buttons get their own strip on mobile
**Choice:** `ExpandableCardComponent` binds `[class.mobile]` on its host; under `.mobile` `.card-body` gets a top padding of `3rem` so the three absolute buttons (Export, chart type, expand: 2rem each, already apart by their `right` offsets) sit above the chart and not over its title.
**Alternative:** turn the buttons into a flex row in the template → touches the card template and the export clone (`.pdf-export`, `.change-to-column` are selected by name in `exportCardToPdf`).

### D4. The details are the same aside, fixed over the whole screen
**Choice:** under `.mobile`, `.details-aside` of both report pages is `position: fixed; inset: 0; width: 100%; z-index: 999; overflow-y: auto; background: var(--color-white)` and, while a panel is open, the rest of the page is hidden with `display: none` through the class `behind-detail`: in Dynamic Charts the subtitle, `app-poll-filters` and `.charts-area-wrapper`; in Summary Charts `.filter-bar` and `.summary-content`. The state is `detailOpen`, a `computed` (mobile and a panel open) on each page. In Summary Charts the mobile aside rules sit at the end of the stylesheet and under `.summary-layout` so they out-specify the desktop ones. `app-details-panel` and `app-column-risk-panel` bind `[class.mobile]` and their body takes `min-width: 0`; the panel header is already a fixed flex row above a body that scrolls. `z-index: 999` is the value of `assessments-mobile-view` (above the header and the menu, below the CDK overlay). Closing keeps today's handlers (`closePanel`, `closeColumnPanel`), which already re-generate the charts after the panel leaves.
**Alternative:** show the details under the chart → the issue allows it, but the clarification of the spec chose a screen of its own, and a fixed screen matches the rest of the app.

### D5. The student list in the details fits by a scoped override
**Choice:** `app-mat-card-details` is also used by the Lists module, so its stylesheet is not changed. `details-panel.component.scss` gets, under `:host(.mobile)`, `::ng-deep .row-info { width: auto; min-width: 0; flex: 1 }` and `::ng-deep mat-card { flex-wrap: wrap }`; the column panel already shows `app-list` (cards on mobile), so it only needs `min-width: 0` on its body.
**Alternative:** edit `mat-card-details.component.scss` → changes the Lists screen outside this change.

### D6. The Summary heatmap adapts through template bindings and sits in a scrolling card
**Choice:** the mobile label font and the disabled cell numbers are bound in the template, not built into the options when the data loads: `SummaryChartsV2Component` has the getters `heatmapYaxis` and `heatmapDataLabels`, which return the constants `MOBILE_HEATMAP_YAXIS` and `MOBILE_HEATMAP_DATA_LABELS` when `isMobile()` (the same object on every read, so ng-apexcharts does not rebuild the chart on each change detection) and `chartOptions.yaxis` / `chartOptions.dataLabels` otherwise. They therefore follow the viewport, including the desktop rendering of a PDF. On mobile the heatmap sits in `.heatmap-scroll` (`overflow-x: auto`) with `.heatmap-inner { min-width: 640px }`, so each cell is wide enough to tap and only that card scrolls sideways, never the page. The column chart takes the flag of D2.
**Alternative:** change `heat-map-config.ts` itself, or pass the mobile options through `baseChartOptions` when the data loads → the first also changes the legacy v1 charts, the second would not follow the viewport and would leave the PDF with the phone options.

### D7. The export controls of the Student Answers list stack through an opt-in input
**Choice:** `ListComponent` gets `readonly stackExportOnMobile = input(false)` (next to `compactPaginatorOnMobile`, same precedent) and a `stack-export` host class that is true when the input is true and `viewport.isMobile()`; `list.component.scss` under `.stack-export`: `.container-title-button` is a column, `.export-container` is a column with `align-items: stretch; height: auto`, and `.export-select` has `min-width: 0; width: 100%`. Student Answers (`summary-charts-v2.component.html`) sets it; the Students list does not, so it keeps today's layout.
**Alternative:** style every `app-list` export dropdown on mobile → also changes the Students list, which has its own mobile rules from `students-mobile-view`.

### D8. A PDF started from a phone is produced from a desktop-rendered clone, only for the report exports
**Choice:** `ViewportService` keeps `isMobile` as a `computed` (`matchesMobile() && !renderAsDesktop()`), exposes the real screen as `isMobileScreen`, and has a writable `renderAsDesktop` signal that only the export code sets. An export asks for this with the new optional `desktopWidth` of `ExportArgs`; only the report exports pass it: the Summary report and the Student Answers list (`ListComponent.exportAsDesktopOnMobile`, `DESKTOP_EXPORT_WIDTH.report`, 1000px) and the Dynamic card (`DESKTOP_EXPORT_WIDTH.card`, 490px). The Students list, the student detail modals and the legacy `reports-v1` exports do not pass it and behave as before. `PdfHelper.withDesktopRendering(container, width, run)` does nothing without a width or on a desktop screen; on a phone it sets `renderAsDesktop`, sets the container width, dispatches a `resize` event, waits `EXPORT_REDRAW_WAIT_MS` (800ms, a named constant, longer than the 450ms resize debounce of the Dynamic Charts plus the Apex redraw) in `waitForRedraw`, runs the export and, in a `finally`, restores the width, turns `renderAsDesktop` off and dispatches a last `resize` so the page draws itself again. `measureAndPrepare` measures the clone at that width instead of `100%` of the phone, so the orientation is decided as on a desktop content area. While the mode is on: the components that read `isMobile()` (`app-table-with-actions`, the lists, the chart options and labels) render as on desktop; the column charts pass `responsive: []` to Apex (which reads the window width and would otherwise draw its 1000px horizontal bars); and the Dynamic Charts generate their charts at the desktop card width (`DESKTOP_EXPORT_WIDTH.card`) and not from the phone grid. The app shell (`LayoutComponent`, `HeaderComponent`, `HeaderV2Component`) reads `isMobileScreen`, so the side menu and the header keep their mobile layout meanwhile (AC-27). The page is covered by the export overlay while this happens.
**Alternative:** render a second, off-screen copy of the report at desktop width → duplicates the data loading and the components; post-process the clone (convert cards to a table) → a second layout to maintain; wrap every `PdfHelper` call → would also change the Students list, the student modals and the legacy v1 exports, which this change does not cover.

### D9. One directive handles the tooltip on every chart
**Choice:** `ApexTooltipDirective` (and `apex-tooltip.component.scss`) get:
- **Position.** The horizontal position is clamped to `[8, clientWidth - tooltipWidth - 8]` on every screen, and `.apex-cdk-tooltip` becomes `min-width: min(282px, calc(100vw - 16px))` and `max-width: min(402px, calc(100vw - 16px))`, which are today's values on any screen wider than 418px. The tooltip is attached before it is measured, so its first display uses its real size. On mobile it is placed above the tapped point (below if there is no room above) and clamped vertically to the screen; the desktop placement is unchanged.
- **Two-tap gate (mobile only).** ApexCharts opens the details on `mousedown` and `touchstart`, not on `click`. The directive therefore decides at `pointerdown`, in the capture phase of the host: a tap on the element the tooltip is currently shown for (`armedKey`, set when the tooltip is displayed) is a second tap, which hides the tooltip, suppresses it until the next tap and lets the events through, so the details open; any other tap stops `touchstart`, `mousedown`, `mouseup` and `click` of that tap, so only the tooltip shows. A cancelled gesture (a pan of the scrolling heatmap card) never displays a tooltip, so it never arms the gate.
- **Hiding.** A tap on a part of the chart without data, a `mouseleave` and a `pointerdown` outside the host (a `document` listener) hide the tooltip and forget the armed element. `ngOnDestroy` removes every listener and disposes the overlay.
- **Input.** `appApexTooltipEnabled` (a signal `input`, default `true`) lets Summary Charts turn the directive on only on mobile: `SummaryChartsV2Component` and `SummaryColumnChartsV2Component` wrap their charts in an element with `[appApexTooltip]` and `[appApexTooltipEnabled]="isMobile()"`, and under `.mobile` hide `.apexcharts-tooltip` (as the expandable card does), so desktop keeps Apex's own tooltip there. The heatmap tooltip is the arrow property `heatmapTooltip(seriesIndex, dataPointIndex)` of the page (it returns an empty string when the data point no longer exists), used by both Apex and the directive; the column chart exposes `tooltipFn(componentIndex, riskIndex)`, which builds the same html it passes to Apex.

**Alternative:** CSS-only limits on Apex's own tooltip → Apex positions it inside the chart and no CSS can clamp it to the screen; a second tooltip implementation for mobile → two places to keep equal.

### D10. The tabs stay as they are
**Decision (2026-11-16, Lucia Becerra): no change.** The tabs already fit at 375px because each one shrinks and wraps its label onto two lines, so (AC-2) holds with the current code, and the shared tab bar, which Assessments also uses, stays untouched. The spec of (AC-2) is a guard: it fails when the tabs cannot shrink.
**Alternative (not taken):** one line with a scrolling bar under `.mobile` → a visible change to a shared component for a case that already works.

## Changes by layer

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Viewport service | `renderAsDesktop`, `isMobile` as `computed`, `isMobileScreen` (D8) | `src/app/core/services/layout/viewport.service.ts` | AC-17 to AC-20, AC-27 |
| App shell | reads `isMobileScreen` (D8) | `src/app/core/components/layout/layout.component.ts`, `header/header/header.component.ts`, `header/header-v2/header-v2.component.ts` | AC-27 |
| PDF helper | opt-in `desktopWidth`, `withDesktopRendering`, `waitForRedraw` (D8) | `src/app/core/utils/reports/exportReport.util.ts`, `R/summary-charts/types/export.ts`, `R/summary-charts/constants/export-conf.ts` | AC-17 to AC-20 |
| Filters | `mobile` class: column, full width, full-width Apply (D1) | `R/poll-filters/poll-filters.component.{ts,scss}` | AC-1 |
| Dynamic Charts | one column, `columns: 1`, desktop card width while exporting, space below the filters, details aside, `detailOpen` (D2, D4, D8) | `R/dynamic-charts-v2/dynamic-charts-v2.component.{ts,html,scss}` | AC-3, AC-10, AC-21, AC-26 |
| Chart options | `isMobile` parameter, shared label size (D2) | `src/app/core/utils/apex-chart/heat-map-config-v2.ts`, `chart.constants.ts`, `R/utils/column-chart.config.ts` | AC-3, AC-4, AC-7 |
| Column charts | flag to the options, `responsive` off while exporting (D2, D8), tooltip builder (D9) | `R/dynamic-charts-v2/dynamic-column-chart-v2/*.ts`, `R/summary-charts-v2/summary-column-charts-v2/*.{ts,html}` | AC-4, AC-7, AC-15 |
| Expandable card | `mobile` class, strip for the buttons, export asks for the card width (D3, D8) | `shared/components/expandable-card-v2/expandable-card.component.{ts,scss}` | AC-5, AC-18 |
| Summary Charts | `.mobile` instead of `@media`, heatmap getters and scrolling card, details aside, `detailOpen`, tooltip wrapper, `stackExportOnMobile`, report export width (D4, D6, D7, D8, D9) | `R/summary-charts-v2/summary-charts-v2.component.{ts,html,scss}` | AC-6, AC-8, AC-11, AC-12, AC-17, AC-22, AC-24 |
| Details panels | `mobile` class, scoped list override (D4, D5) | `shared/components/panels/details-panel-v2/details-panel.component.{ts,scss}`, `R/summary-charts-v2/column-risk-panel/column-risk-panel.component.{ts,scss}` | AC-10 to AC-13, AC-28 |
| Shared list | `stackExportOnMobile` and `exportAsDesktopOnMobile` inputs (D7, D8) | `shared/components/list/list.component.{ts,scss}` | AC-20, AC-24 |
| Polls Answered | no code change; guard test | `R/polls-answered/polls-answered.component.spec.ts` | AC-9 |
| Tooltip | clamp, placement, two-tap gate, hiding, enabled input (D9) | `shared/components/apex-tooltip/apex-tooltip.directive.ts`, `apex-tooltip.component.scss` | AC-14 to AC-16, AC-23, AC-25 |
| Tabs | none (D10) | | AC-2 |

No route, model, service, permission or message change. No new dependency.

## API contract
No API change.

## Data and migration
No schema change.

## Test strategy

All tests are FE (Jasmine/Karma) with `[674-improve-reports-charts-mobile-view/AC-n]` first in the `it()` title. `ViewportService` is replaced by `{ isMobile: signal(...), renderAsDesktop: signal(false) }` (the shell specs also give `isMobileScreen`). Layout is asserted from the real DOM inside a 375px (or 1280px) wide host (`scrollWidth <= clientWidth`, bounding rectangles, computed `position`); API services are spies with fixed data. The Apex chart is a mock `apx-chart` in the page specs (Dynamic and Summary) and the real one in the two column chart specs; the details panels are stubs in the page specs (their own layout is proven in `details-panel.component.spec.ts`) and the two taps are proven in the directive spec with synthetic SVG elements. New `*-mobile.component.spec.ts` files sit next to their unit, as in `assessments-mobile-view`. `R/` is `src/app/modules/reports/components/`, `S/` is `src/app/shared/components/`.

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | FE | `R/poll-filters/poll-filters.component.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-1] stacks the four filters and the Apply button at full width on mobile` |
| AC-2 | FE | `S/tabbed-layout-component/tabbed-layout.component.spec.ts` (new) | `[674-improve-reports-charts-mobile-view/AC-2] keeps the three report tabs tappable and the page without horizontal scroll on mobile` |
| AC-3 | FE | `R/dynamic-charts-v2/dynamic-charts-v2-mobile.component.spec.ts` (new) | `[674-improve-reports-charts-mobile-view/AC-3] shows the heatmap charts in one column with smaller labels on mobile` |
| AC-4 | FE | `R/dynamic-charts-v2/dynamic-column-chart-v2/dynamic-column-chart-v2.component.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-4] fits the column chart and uses smaller axis labels on mobile` |
| AC-5 | FE | `S/expandable-card-v2/expandable-card.component.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-5] keeps the card buttons inside the card and off the chart title on mobile` |
| AC-6 | FE | `R/summary-charts-v2/summary-charts-v2-mobile.component.spec.ts` (new) | `[674-improve-reports-charts-mobile-view/AC-6] fits the summary heatmap and its legend with smaller component names on mobile` |
| AC-7 | FE | `R/summary-charts-v2/summary-column-charts-v2/summary-column-charts-v2.component.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-7] fits the summary column chart and uses smaller axis labels on mobile` |
| AC-8 | FE | `summary-charts-v2-mobile.component.spec.ts`, real `app-list` | `[674-improve-reports-charts-mobile-view/AC-8] shows each student answer as a card with the average risk badge on mobile` |
| AC-9 | FE | `R/polls-answered/polls-answered.component.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-9] shows each poll instance as a card on mobile` |
| AC-10 | FE | `dynamic-charts-v2-mobile.component.spec.ts`, stub details panel | `[674-improve-reports-charts-mobile-view/AC-10] opens the dynamic details centered over the whole screen and closes back to the charts` |
| AC-11 | FE | `summary-charts-v2-mobile.component.spec.ts`, stub details panel | `[674-improve-reports-charts-mobile-view/AC-11] opens the heatmap details as a screen of their own and closes back to the report` |
| AC-12 | FE | `summary-charts-v2-mobile.component.spec.ts`, stub column panel | `[674-improve-reports-charts-mobile-view/AC-12] opens the column details as a screen of their own and closes back to the report` |
| AC-13 | FE | `S/panels/details-panel-v2/details-panel.component.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-13] keeps the student list of the details inside the screen on mobile` |
| AC-14 | FE | `S/apex-tooltip/apex-tooltip.directive.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-14] shows the heatmap tooltip inside the screen on the first tap without opening the details` |
| AC-15 | FE | `apex-tooltip.directive.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-15] shows the column tooltip inside the screen, off the tapped column, without opening the details` |
| AC-16 | FE | `apex-tooltip.directive.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-16] hides the tooltip when the user taps outside the chart` |
| AC-17 | FE | `src/app/core/utils/reports/exportReport.util.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-17] gives the report PDF from a mobile screen the page size and orientation of the desktop one` |
| AC-18 | FE | `exportReport.util.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-18] gives the chart card PDF from a mobile screen the page size and orientation of the desktop one` |
| AC-19 | FE | `exportReport.util.spec.ts`, real `app-table-with-actions` in the container | `[674-improve-reports-charts-mobile-view/AC-19] keeps the students as a table without cards, filters or close buttons in the report PDF from mobile` |
| AC-20 | FE | `S/list/list.component.spec.ts`, real `PdfHelper` with a spied `PdfService` | `[674-improve-reports-charts-mobile-view/AC-20] exports the student list to PDF as a table with the desktop page size from mobile` |
| AC-21 | FE | `dynamic-charts-v2-mobile.component.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-21] keeps two chart columns, the 380px details beside the charts and the label sizes on 1280px` |
| AC-22 | FE | `summary-charts-v2-mobile.component.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-22] keeps the filters in a row, the 440px details beside the report and the student table on 1280px` |
| AC-23 | FE | `apex-tooltip.directive.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-23] keeps the hover tooltip next to the pointer, up to 402px wide, with the click opening the cell on desktop` |
| AC-24 | FE | `S/list/list.component.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-24] places the export selector and button below the list title without overlap on mobile` |
| AC-25 | FE | `apex-tooltip.directive.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-25] hides the tooltip when the second tap opens the details` |
| AC-26 | FE | `dynamic-charts-v2-mobile.component.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-26] leaves space between the filters and the charts on mobile` |
| AC-27 | FE | `src/app/core/components/layout/layout.component.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-27] keeps the mobile shell while a PDF is rendered as desktop` |
| AC-28 | FE | `S/panels/details-panel-v2/details-panel.component.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-28] aligns the risk badge and the action of every student card on mobile whatever the text length` |

Extra tests without an AC tag: `viewport.service.spec.ts` (`renderAsDesktop` and `isMobileScreen`); the position clamp (horizontal and vertical), the placement above or below the point, the cancelled gesture, the tap on a part without data and the disabled directive in `apex-tooltip.directive.spec.ts`; the options helpers (`heat-map-config-v2.spec.ts`, `column-chart.config.spec.ts`); the restore after an error, the final redraw and the exports that do not ask for desktop rendering in `exportReport.util.spec.ts` and `list.component.spec.ts`; the stable heatmap option objects, the heatmap tooltip guard and the mobile-only directive on the heatmap in `summary-charts-v2-mobile.component.spec.ts`; `tooltipFn` in `summary-column-charts-v2.component.spec.ts`; and the stacked filters without variables (the Summary Charts and Polls Answered case) in `poll-filters.component.spec.ts`. Specs that mount a changed unit without caring about the screen provide a desktop `ViewportService` or run with the real one, because the Karma window is narrower than 768px. AC-2, AC-8, AC-9 and AC-21 to AC-23 are guard tests: they pass on the code before the change (AC-8 only once the export controls no longer overflow); AC-2 and AC-9 were also proven by breaking the code they guard, and AC-21 to AC-23 assert real measurements of the desktop layout. The waits for Apex in the column chart specs poll for the rendered legend instead of a fixed timeout. Coverage gate: FE >= 15% (`ERAS-FE/AGENTS.md` §3.3).

## Risks / Trade-offs

- [The PDF from a phone depends on the charts redrawing at desktop width] → the redraw is Apex's own resize handling plus a fixed wait (`EXPORT_REDRAW_WAIT_MS`, 800ms, with no readiness signal); a very slow phone could still export before the redraw ends. `DESKTOP_EXPORT_WIDTH` (1000 and 490) is a constant to tune; the Dynamic card PDF was checked on a phone-sized screen and the other report exports are covered by the specs only.
- [`ViewportService` is shared by the whole app] → `isMobile` keeps its name and type; only the opt-in report exports write `renderAsDesktop` and its `finally` restores it; the shell reads `isMobileScreen` so it never reacts to it.
- [`app-list`, `app-poll-filters`, the tooltip directive and `PdfHelper` are shared] → the list changes are behind opt-in inputs used only by Student Answers; the PDF change is opt-in per call; the filters stack on mobile everywhere they are used, including the legacy v1 pages and Polls Answered (the Summary and Polls case has an extra spec); the tooltip directive keeps the desktop behavior (AC-23 guards it).
- [The tooltip directive clamps on every screen] → the clamp only moves a tooltip that would leave the screen, and `max-width: min(402px, calc(100vw - 16px))` is 402px on any screen wider than 418px. `100vw` includes the scrollbar while the clamp uses `clientWidth`.
- [The two-tap gate stops events in the capture phase] → on desktop the gate is off, so the events reach Apex as today; on mobile a tap on another element moves the tooltip, and the details open only when the same element is tapped twice.
- [Fixed full-screen details inside the shell] → no ancestor has a transform; the AC-10 to AC-12 specs assert the aside rectangle equals the window.
- [Chart options of the Dynamic heatmaps are not rebuilt when the screen crosses 768px after the data loaded] → documented non-goal; rotating a phone to landscape below 768px keeps the same options.

## Follow-ups
- The legacy `reports-v1` components keep `.list-container { width: 1200px }` and the 768px chart on small screens (decided out of scope on 2026-11-13).
- The Export, chart type and expand buttons of the Dynamic cards (2rem, 32px) and the Export button of the Summary card are below the 48px tap area of the pull request checklist; (AC-5) only asks that they do not overlap.
- The full-screen details have no `role="dialog"` or `aria-modal`, do not move the focus to the panel and back, do not close with Esc, and the header and the side menu stay tabbable behind the fixed layer.
- The mobile styles add `::ng-deep` rules (`details-panel.component.scss`, `summary-charts-v2.component.scss` with `!important` to hide Apex's tooltip) next to the one of `ExpandableCardComponent`; a shared rule would be simpler once the Summary Charts use the directive on mobile only.
- `STYLE_CONF.width: '1440px'` in `export-conf.ts` is not used by any code; remove it in its own change.
- `polls-answered.component.scss` has a `.form-container` media block for an element its template no longer has.
- The heatmaps have no Apex `responsive` options; the tablet range (768px to 1199px) is sub-ticket 9 of ERAS#668.
- `ApexTooltipDirective` registers a `document` listener per instance and uses `window.innerWidth` and `clientWidth` in different places; one shared listener and one screen measure would be cleaner.
- `ViewportService.renderAsDesktop` is a public writable signal; a read-only signal and a setter would keep the "only exports write it" rule by construction.
- The mock `ViewportService` of the specs that do not use `PdfHelper` (poll filters) does not carry `renderAsDesktop`.
