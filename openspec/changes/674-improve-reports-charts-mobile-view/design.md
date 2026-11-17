# Design

## Context

Reports live in `ERAS-FE/src/app/modules/reports/` (below: `R/` is `components/`). `ReportsComponent` renders `app-tabbed-layout` (`shared/components/tabbed-layout-component/`) with three routed pages for the v2 reports: `R/dynamic-charts-v2`, `R/summary-charts-v2` and `R/polls-answered`. The three share `app-poll-filters` (`R/poll-filters`). The legacy `reports-v1` route and its components (`R/dynamic-charts`, `R/summary-charts`) are out of scope and stay untouched.

How each piece behaves today, from the code:

- **Dynamic Charts v2.** `.charts-grid` and `.charts-layout` are `grid-template-columns: 1fr 1fr` with no `@media`. `generateSeries()` computes each card width as `totalWidth / CARD_LAYOUT.columns - spacing` with `columns: 2`, and `GetChartOptions` (`core/utils/apex-chart/heat-map-config-v2.ts`) derives the cell width and the label area (30% compact, 50% expanded) from that width, with a `22px` title and default label fonts. The cards are `app-expandable-card` (`shared/components/expandable-card-v2/`), whose Export, chart type and expand buttons are `position: absolute` at the top of the card over the chart title. The details are `app-details-panel` in `aside.details-aside` (`width: 380px`, `grid-column: 3`, sticky) inside the grid. Charts hide the native Apex tooltip (`.card-body .apexcharts-tooltip { display: none }`) and use `ApexTooltipDirective` (`shared/components/apex-tooltip/`), which listens to `mousemove` / `mouseleave` only, flips to the left of the pointer when the right side is short, and never clamps to the screen (the tooltip is `min-width: 282px`, `max-width: 402px`).
- **Summary Charts v2.** `.summary-layout` is a flex row with `aside.details-aside` (`width: 440px`) beside `.summary-content`; the only `@media (max-width: 768px)` changes paddings. The heatmap comes from `GetChartOptions` of `heat-map-config.ts` (v1 config, no label font settings, `baseChartOptions` is spread over the options); the column chart is `app-summary-column-charts-v2` (`ColumnChartUtils`, with an Apex `responsive` breakpoint at 1000px). Both use Apex's own tooltip (`TooltipChartV2Component` html, `max-width: 402px`). Student Answers is `app-list` with the export dropdown (`.container-title-button` is a flex row; `.export-select` has `min-width: 220px`) and, on mobile, `app-table-with-actions` already renders cards. The column details are `app-column-risk-panel` in the same aside. The Export button of the report is `report-card__actions` (already `flex-wrap`).
- **Details panel content.** `app-details-panel` (`shared/components/panels/details-panel-v2/`) shows the student list with `app-list-details` and `app-mat-card-details`, whose `mat-card` is a flex row with `.row-info { width: 210px }`; with the badge and the actions it is wider than the panel at 375px, which is what pushes the panel to a side and makes the page scroll sideways.
- **PDF.** `PdfHelper` (`core/utils/reports/exportReport.util.ts`) clones the on-screen DOM. `measureAndPrepare` first lays the clone out at `width: 100%` of the screen, calls it landscape when width > height, then resizes it to `LETTER_PX` (816 portrait, 1056 landscape). So the orientation depends on the width of the screen, and the clone holds whatever the screen rendered (cards, mobile chart options). `STYLE_CONF.width: '1440px'` in `R/summary-charts/constants/export-conf.ts` is not used by any code. Exports: `exportToPdf` (summary report, list), `exportCardToPdf` (dynamic card, with `element.offsetWidth` as the initial width) and `exportToPdfChunked` (list with more than 100 rows).
- **Mobile infrastructure that already exists:** `ViewportService.isMobile` (`core/services/layout/viewport.service.ts`, below 768px), the pattern of changes 659, 672 and 673 (layout driven by `isMobile()` and a `mobile` class, specs replace the service with `{ isMobile: signal(...) }`, full-screen details fixed over the page at `z-index: 999`, see `assessments-mobile-view`), `ListComponent.compactPaginatorOnMobile` (an opt-in input) and the shared cards of `app-table-with-actions`. Motivation and scope: `proposal.md`.

## Goals / Non-Goals

**Goals:**
- Filters, tabs, Dynamic Charts and Summary Charts that fit 375px, with smaller chart labels (AC-1 to AC-7, AC-24).
- Lists as cards that fit, and the Student Answers export controls below the title (AC-8, AC-9, AC-24).
- Details as a centered full-screen page with a student list that fits (AC-10 to AC-13).
- A tooltip that fits the screen, opens details on the second tap and hides on a tap outside (AC-14 to AC-16).
- PDFs from a phone equal to the desktop ones (AC-17 to AC-20).
- Nothing changes from 768px (AC-21 to AC-23).

**Non-Goals:**
- Changing the legacy `reports-v1` components.
- Rebuilding the charts when the screen is resized across 768px after they are drawn: chart options are computed when the data loads or the layout is re-generated, as today.
- Replacing the legacy `@Input()` / `@Output()` / `*ngIf` of the files this change edits.

## Decisions

### D1. The layout switches on `ViewportService.isMobile()` and a `mobile` class, not on `@media`
**Choice:** each unit that changes reads `inject(ViewportService).isMobile` and binds `[class.mobile]` on its host or root; every new rule is written under `.mobile`. The existing `@media (max-width: 768px)` block of `summary-charts-v2.component.scss` is moved under `.mobile` too. Specs replace the service with `{ isMobile: signal(...) }`.
**Alternative:** `@media (max-width: 767.98px)` → Karma's window width cannot be set per test, and the PDF clone is laid out at another width than the screen, so a media query would give the phone's styles to the desktop-sized clone (D8).

### D2. Dynamic Charts go to one column and smaller labels through the options
**Choice:** `.charts-grid` and `.charts-layout` become `grid-template-columns: 1fr` under `.mobile`, `generateSeries()` uses `columns: 1` when `isMobile()`, and `GetChartOptions` of `heat-map-config-v2.ts` gets a last optional parameter `isMobile = false`: when true the title is `14px` and the label fonts (`yaxis.labels.style.fontSize`, data labels) are `10px`. `ColumnChartUtils.createXAxis(categories, isMobile)` sets `labels.style.fontSize: '10px'` the same way. `DynamicColumnChartV2Component` and `DynamicChartsV2Component` pass the flag.
**Alternative:** CSS `font-size` on the Apex SVG text → Apex positions the label area from its own font settings, so the layout would not follow the font.

### D3. The card buttons get their own strip on mobile
**Choice:** `ExpandableCardComponent` reads `isMobile` and binds `[class.mobile]` on its host; under `.mobile` `.card-body` gets a top padding of `2.75rem` so the three absolute buttons (Export, chart type, expand: 2rem each, already apart by their `right` offsets) sit above the chart and not over its title.
**Alternative:** turn the buttons into a flex row in the template → touches the card template and the export clone (`.pdf-export`, `.change-to-column` are selected by name in `exportCardToPdf`).

### D4. The details are the same aside, fixed over the whole screen
**Choice:** under `.mobile`, `.details-aside` of both report pages is `position: fixed; inset: 0; width: 100%; max-width: none; z-index: 999; overflow-y: auto; background: var(--color-white)` and, while a panel is open, the rest of the page is hidden with `display: none`: in Dynamic Charts the subtitle, `app-poll-filters` and `.charts-area-wrapper`; in Summary Charts `.filter-bar` and `.summary-content`. The state `detailOpen` (mobile and a panel open) is a `computed` on each page. `app-details-panel` and `app-column-risk-panel` read `isMobile` and bind `[class.mobile]`: the header stays at the top (`position: sticky`) with the close button and the body takes `min-width: 0; max-width: 100%`. `z-index: 999` is the value of `assessments-mobile-view` (above the header and the menu, below the CDK overlay). Closing keeps today's handlers (`closePanel`, `closeColumnPanel`), which already re-generate the charts after the panel leaves.
**Alternative:** show the details under the chart → the issue allows it, but the clarification of the spec chose a screen of its own, and a fixed screen matches the rest of the app.

### D5. The student list in the details fits by a scoped override
**Choice:** `app-mat-card-details` is also used by the Lists module, so its stylesheet is not changed. `details-panel.component.scss` gets, under `:host(.mobile)`, `::ng-deep .row-info { width: auto; min-width: 0; flex: 1 }` and `::ng-deep mat-card { flex-wrap: wrap }`; `column-risk-panel.component.scss` already shows `app-list` (cards on mobile), so it only needs `min-width: 0` on its body.
**Alternative:** edit `mat-card-details.component.scss` → changes the Lists screen outside this change.

### D6. Summary Charts labels are smaller through `baseChartOptions`
**Choice:** `SummaryChartsV2Component` passes, when `isMobile()`, `{ legend: { show: false }, yaxis: { labels: { style: { fontSize: '10px' } } } }` as the `baseChartOptions` of `GetChartOptions` (v1 config, which already spreads it), and the column chart gets the flag of D2. `.chart-area` padding and `.summary-charts-wrapper` padding keep the values of the old media query under `.mobile`. The chart options are built when the report loads (non-goal above).
**Alternative:** change `heat-map-config.ts` itself → it is also used by the legacy v1 charts, which stay unchanged.

### D7. The export controls of the Student Answers list stack through an opt-in input
**Choice:** `ListComponent` gets `readonly stackExportOnMobile = input(false)` (next to `compactPaginatorOnMobile`, same precedent) and a `[class.stack-export]` host binding that is true when the input is true and `viewport.isMobile()`; `list.component.scss` under `.stack-export`: `.container-title-button` is a column, `.export-container` is a column with `align-items: stretch; height: auto`, and `.export-select` has `min-width: 0; width: 100%`. Student Answers (`summary-charts-v2.component.html`) sets it; `students-list` does not, so it keeps today's layout.
**Alternative:** style every `app-list` export dropdown on mobile → also changes the Students list, which has its own mobile rules from `students-mobile-view`.

### D8. PDFs are produced from a desktop-rendered clone, whatever the screen
**Choice:** `ViewportService` keeps `isMobile` as a `computed` of the media query and a new writable signal `desktopForced` (`readonly renderAsDesktop = signal(false)`): `isMobile = computed(() => !this.renderAsDesktop() && this.matches())`. `PdfHelper` injects the service and wraps `exportToPdf`, `exportCardToPdf` and `exportToPdfChunked` in `withDesktopRendering(container, width, run)`, which only does something when the real screen is mobile: it sets `renderAsDesktop` to true, sets `container.style.width` to `DESKTOP_EXPORT_WIDTH` (new constant in `export-conf.ts`: `report: 1000`, `card: 490`, the content width of a 1280px screen with the menu open, to be confirmed in the validation), dispatches a `resize` event, waits for the debounced charts to redraw (about 800ms, one `waitForReflow` loop), runs the export, and restores the width and the signal in a `finally`. `measureAndPrepare` takes the same width as its initial width on mobile instead of `100%`, so the orientation is decided from the same size on every screen. Column charts read `renderAsDesktop` to pass `responsive: []` to Apex (otherwise Apex, which reads the window width, would draw the horizontal bars of its 1000px breakpoint). Components that read `isMobile()` (`app-table-with-actions`, the lists, the chart options) re-render as on desktop, so the clone holds a table and desktop chart sizes. The page is covered by the export overlay while this happens. On desktop the wrapper does nothing, so desktop exports do not change (AC-21 to AC-23 are not affected).
**Alternative:** render a second, off-screen copy of the report at desktop width → duplicates the data loading and the components; or post-process the clone (convert cards to a table) → a second layout to maintain. The chosen way reuses the real components and the existing clone.

### D9. One directive handles the tooltip on every chart
**Choice:** `ApexTooltipDirective` (and `apex-tooltip.component.scss`) get: (a) the position is clamped to `[8, window.innerWidth - tooltipWidth - 8]`, and `.apex-cdk-tooltip` becomes `min-width: min(282px, calc(100vw - 16px))` and `max-width: min(402px, calc(100vw - 16px))`, which are today's values on any screen wider than 418px; (b) on mobile the tooltip is placed above the tapped point (below if there is no room above), so it does not cover the element; the desktop placement is unchanged; (c) on mobile a capture-phase `click` listener on the host lets the click through only when the tapped element is the one the tooltip is shown for, and otherwise stops it, so the first tap shows the tooltip and the second tap on the same element reaches Apex's `dataPointSelection` (details open); (d) a `pointerdown` listener on `document` hides the tooltip and forgets the armed element when the tap is outside the host. The directive reads `ViewportService.isMobile`. A new input `appApexTooltipEnabled` (default `true`) lets Summary Charts turn it on only on mobile: `SummaryChartsV2Component` and `SummaryColumnChartsV2Component` wrap their charts in an element with `[appApexTooltip]` and `[appApexTooltipEnabled]="isMobile()"`, and under `.mobile` hide `.apexcharts-tooltip` (as the expandable card does), so desktop keeps Apex's own tooltip there. The heatmap tooltip becomes a method of the page (`heatmapTooltip(seriesIndex, dataPointIndex)`) used by both Apex and the directive, and the column chart exposes the same html builder it passes to Apex.
**Alternative:** CSS-only limits on Apex's own tooltip → Apex positions it inside the chart and no CSS can clamp it to the screen; a second tooltip implementation for mobile → two places to keep equal.

### D10. The tabs scroll inside their own bar
**Decision (2026-11-16, Lucia Becerra): no change.** The tabs already fit at 375px because each one shrinks and wraps its label onto two lines, so (AC-2) holds with the current code and the shared tab bar, which Assessments also uses, stays untouched. The text below is the option that was not taken.
**Choice (not taken):** `TabbedLayoutComponent` reads `isMobile` and binds `[class.mobile]` on its wrapper; under `.mobile` `.tabs-nav` gets `padding: 0 8px; overflow-x: auto; white-space: nowrap` with the scrollbar hidden and `.tab-item` `flex: none; padding: 12px`, so each tab can be tapped and only the bar scrolls, never the page. The Assessments section uses the same component and gets the same bar.
**Alternative:** wrap the tabs on two lines → three uppercase labels do not fit 343px and a second row looks like a different control.

## Changes by layer

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Viewport service | `renderAsDesktop` signal and `isMobile` as `computed` (D8) | `src/app/core/services/layout/viewport.service.ts` | AC-17 to AC-20 |
| PDF helper | `withDesktopRendering`, reference width on mobile (D8) | `src/app/core/utils/reports/exportReport.util.ts`, `R/summary-charts/constants/export-conf.ts` | AC-17 to AC-20 |
| Filters | `mobile` class: column, full width, full-width Apply (D1) | `R/poll-filters/poll-filters.component.{ts,html,scss}` | AC-1 |
| Tabs | scrolling tab bar (D10) | `shared/components/tabbed-layout-component/tabbed-layout.component.{ts,html,scss}` | AC-2 |
| Dynamic Charts | one column, `columns: 1`, flag to the options, details aside (D2, D4) | `R/dynamic-charts-v2/dynamic-charts-v2.component.{ts,html,scss}` | AC-3, AC-10, AC-21 |
| Dynamic chart options | `isMobile` parameter (D2) | `src/app/core/utils/apex-chart/heat-map-config-v2.ts` | AC-3 |
| Column chart options | label font and `responsive` by flags (D2, D8) | `R/utils/column-chart.config.ts`, `R/dynamic-charts-v2/dynamic-column-chart-v2/*.ts`, `R/summary-charts-v2/summary-column-charts-v2/*.ts` | AC-4, AC-7 |
| Expandable card | `mobile` class, strip for the buttons (D3) | `shared/components/expandable-card-v2/expandable-card.component.{ts,scss}` | AC-5 |
| Summary Charts | `.mobile` instead of `@media`, label options, details aside, tooltip wrapper, `stackExportOnMobile` (D4, D6, D7, D9) | `R/summary-charts-v2/summary-charts-v2.component.{ts,html,scss}` | AC-6, AC-8, AC-11, AC-12, AC-22, AC-24 |
| Details panels | `mobile` class, scoped list override (D4, D5) | `shared/components/panels/details-panel-v2/details-panel.component.{ts,scss}`, `R/summary-charts-v2/column-risk-panel/column-risk-panel.component.{ts,scss}` | AC-10 to AC-13 |
| Shared list | `stackExportOnMobile` input (D7) | `shared/components/list/list.component.{ts,scss}` | AC-20, AC-24 |
| Polls Answered | no code change expected; guard test (AC-9) | `R/polls-answered/polls-answered.component.spec.ts` | AC-9 |
| Tooltip | clamp, mobile placement, tap gate, outside tap, enabled input (D9) | `shared/components/apex-tooltip/apex-tooltip.directive.ts`, `apex-tooltip.component.scss` | AC-14 to AC-16, AC-23 |

No route, model, service, permission or message change. No new dependency.

Implementation notes (2026-11-16), where the code differs from the decisions above without changing them:
- D3: the strip above the card body is `3rem`, not `2.75rem` (the buttons end at about 42px).
- D4: the details headers needed no sticky position, because the panel body already scrolls under a fixed header.
- D6: the mobile label font and the disabled data labels of the Summary heatmap are bound in the template (`heatmapYaxis`, `heatmapDataLabels`) and not built into the options when the data loads, so they follow the viewport, including the desktop rendering of a PDF. On mobile the heatmap sits in a card that scrolls sideways (`.heatmap-scroll`, minimum width 640px) so its cells can be tapped.
- D8: `ViewportService` also exposes `isMobileScreen` (the real screen, not affected by `renderAsDesktop`). The app shell (`LayoutComponent` and both headers) reads it, so the side menu and the header do not switch to their desktop layout while a PDF is rendered.
- D8: while a PDF is rendered as desktop the Dynamic Charts generate their charts at the desktop card width (`DESKTOP_EXPORT_WIDTH.card`) and not from the width of the phone grid, and `PdfHelper` dispatches a last `resize` after turning the desktop rendering off so the page draws itself again at its real size.
- D9: ApexCharts opens the details on `mousedown` and `touchstart`, not on `click`. The tap gate therefore decides at `pointerdown` and stops `touchstart`, `mousedown`, `mouseup` and `click` of a first tap; a second tap on the same element hides the tooltip and suppresses it until the next tap, so it does not cover the details (AC-25).

## API contract
No API change.

## Data and migration
No schema change.

## Test strategy

All tests are FE (Jasmine/Karma) with `[674-improve-reports-charts-mobile-view/AC-n]` first in the `it()` title. `ViewportService` is replaced by `{ isMobile: signal(...), renderAsDesktop: signal(false) }`. Layout is asserted from the real DOM inside a 375px (or 1280px) wide host (`scrollWidth <= clientWidth`, bounding rectangles, computed `position`); API services are spies with fixed data. New `*-mobile.component.spec.ts` files sit next to their unit, as in `assessments-mobile-view`. `R/` is `src/app/modules/reports/components/`, `S/` is `src/app/shared/components/`.

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
| AC-10 | FE | `dynamic-charts-v2-mobile.component.spec.ts`, real `app-details-panel` | `[674-improve-reports-charts-mobile-view/AC-10] opens the dynamic details centered over the whole screen on the second tap and closes back to the charts` |
| AC-11 | FE | `summary-charts-v2-mobile.component.spec.ts` | `[674-improve-reports-charts-mobile-view/AC-11] opens the heatmap details as a screen of their own and closes back to the report` |
| AC-12 | FE | `summary-charts-v2-mobile.component.spec.ts`, real `app-column-risk-panel` | `[674-improve-reports-charts-mobile-view/AC-12] opens the column details as a screen of their own and closes back to the report` |
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

Extra tests without an AC tag: `viewport.service.spec.ts` (`renderAsDesktop` turns `isMobile` off and back on); the position clamp and the placement above or below of the directive; the options helpers (`heat-map-config-v2.spec.ts`, `column-chart.config.spec.ts`: smaller fonts only when the flag is set); and the `withDesktopRendering` restore after an error. Specs that mount a changed unit without caring about the screen (`dynamic-charts-v2`, `summary-charts-v2`, `list`, `details-panel`, `expandable-card`, `apex-tooltip`) provide a desktop `ViewportService`, because the Karma window is narrower than 768px and the real service would be mobile. AC-9, AC-21 to AC-23 are guard tests: they are proven by breaking the rule they guard and seeing them fail. Coverage gate: FE >= 15% (`ERAS-FE/AGENTS.md` §3.3).

## Risks / Trade-offs

- [The PDF from a phone depends on the charts redrawing at desktop width] → the redraw is Apex's own resize handling plus a fixed wait; the validation exports a Dynamic card and a Summary report from a phone-sized window and compares them with the desktop ones. `DESKTOP_EXPORT_WIDTH` is a constant to tune.
- [`ViewportService` is shared by the whole app] → `isMobile` keeps its name and type (`Signal<boolean>`); only the export code writes `renderAsDesktop`, and its `finally` restores it.
- [The tab bar and `app-list` are shared] → the tabs change only under `.mobile` and also improve the Assessments tabs; the list change is behind an opt-in input used only by Student Answers.
- [The tooltip directive now clamps on every screen] → the clamp only moves a tooltip that would leave the screen, and `max-width: min(402px, 100vw - 16px)` is 402px on any screen wider than 418px; AC-23 guards the desktop behavior.
- [Stopping the first tap's click in capture phase] → on desktop the gate is off, so the click reaches Apex as today; on mobile the second tap must be on the same element or the tooltip moves to the new one.
- [Fixed full-screen details inside the shell] → no ancestor has a transform; the AC-10 to AC-12 specs assert the aside rectangle equals the window.
- [Chart options are not rebuilt when the screen crosses 768px after the data loaded] → documented non-goal; rotating a phone to landscape below 768px keeps the same options.

## Follow-ups
- The legacy `reports-v1` components keep `.list-container { width: 1200px }` and the 768px chart on small screens (decided out of scope on 2026-11-13).
- `STYLE_CONF.width: '1440px'` in `export-conf.ts` is not used by any code; remove it in its own change.
- `polls-answered.component.scss` has a `.form-container` media block for an element its template no longer has.
- `ExpandableCardComponent` hides the native Apex tooltip with `::ng-deep` and `!important`; a shared rule would be simpler once the Summary Charts use the directive on mobile only.
- The heatmaps have no Apex `responsive` options; the tablet range (768px to 1199px) is sub-ticket 9 of ERAS#668.
