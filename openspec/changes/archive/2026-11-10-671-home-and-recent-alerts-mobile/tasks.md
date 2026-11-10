# Tasks

## 1. Frontend (FE)

- [x] 1.1 Write the spec `[671-home-and-recent-alerts-mobile/AC-1] stacks the three summary cards in one column without overflow on mobile` for (AC-1) in `ERAS-FE/src/app/modules/home-v2/summary-details/summary-details.component.spec.ts` with a mocked `ViewportService`, and verify it fails
- [x] 1.2 Implement the `mobile` class and one-column grid, drop `gridColumns` and the XSmall observer, in `summary-details.component.{ts,html,scss}` and `stats-card-v2.component.scss` for (AC-1) and verify the spec from 1.1 and the existing specs of both components pass
- [x] 1.3 Write the spec `[671-home-and-recent-alerts-mobile/AC-4] makes each service card no wider than the content on mobile` for (AC-4) in `ERAS-FE/src/app/shared/components/cards/service-card-readable/service-card-readable.component.spec.ts` and verify it fails
- [x] 1.4 Implement the `mobile` class and `width: 100%` card in `service-card-readable.component.{ts,html,scss}` for (AC-4) and verify the spec from 1.3 passes
- [x] 1.5 Write the spec `[671-home-and-recent-alerts-mobile/AC-2] shows each alert as a card without horizontal scroll on mobile` for (AC-2) in `ERAS-FE/src/app/modules/lists/components/recent-alerts-list/recent-alerts-list.component.spec.ts` with the real `app-list` at 375px, and verify it fails
- [x] 1.6 Wrap the badges and card rows in `recent-alerts-list.component.scss` for (AC-2) and verify the spec from 1.5 passes (no SCSS change needed: the card already fits 375px, so 1.5 is a guard test that fails at 1280px)
- [x] 1.7 Write the spec `[671-home-and-recent-alerts-mobile/AC-3] fits the Recent Alerts block below the summary cards on mobile` for (AC-3) in the new `ERAS-FE/src/app/modules/home-v2/home.component.spec.ts` and verify it fails
- [x] 1.8 Implement the `mobile` class, one-column `.section-alerts-support` and wrapping header in `home.component.{ts,html,scss}`, and the card fit in `recent-alerts.component.scss`, for (AC-3) and verify the spec from 1.7 passes
- [x] 1.9 Write the spec `[671-home-and-recent-alerts-mobile/AC-6] shows a Professional the same sections on mobile and on desktop` for (AC-6) in `home.component.spec.ts`, comparing the section headings on mobile and on desktop, and verify it passes (no code change expected; if it fails, fix the template and note it)
- [x] 1.10 Write the spec `[671-home-and-recent-alerts-mobile/AC-7] shows an Officer the same sections on mobile and on desktop` for (AC-7) in `home.component.spec.ts` and verify it passes (same note as 1.9)
- [x] 1.11 Write the spec `[671-home-and-recent-alerts-mobile/AC-8] shows an Administrator the same sections on mobile and on desktop` for (AC-8) in `home.component.spec.ts` and verify it passes (same note as 1.9)
- [x] 1.12 Write the spec `[671-home-and-recent-alerts-mobile/AC-9] keeps three summary columns and a two-column alerts block on a 1280px screen` for (AC-9) in `home.component.spec.ts` and verify it passes with the implementation of 1.2 and 1.8

## 2. Verification

- [x] 2.1 The AGENTS.md section 8.7 FE gates pass in `ERAS-FE/`: `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (>= 15%), `npm run build`
- [x] 2.2 The AC traceability check (AGENTS.md section 8.6) shows exactly 1 test per AC per affected side, and `openspec validate 671-home-and-recent-alerts-mobile --strict` passes

## Traceability
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | Summary cards stack in one column on mobile | FE | src/app/modules/home-v2/summary-details/summary-details.component.spec.ts › [671-home-and-recent-alerts-mobile/AC-1] stacks the three summary cards in one column without overflow on mobile |
| AC-2 | Recent alerts are cards without horizontal scroll on mobile | FE | src/app/modules/lists/components/recent-alerts-list/recent-alerts-list.component.spec.ts › [671-home-and-recent-alerts-mobile/AC-2] shows each alert as a card without horizontal scroll on mobile |
| AC-3 | Recent alerts block fits the width on Home on mobile | FE | src/app/modules/home-v2/home.component.spec.ts › [671-home-and-recent-alerts-mobile/AC-3] fits the Recent Alerts block below the summary cards on mobile |
| AC-4 | Service cards fit the width on mobile | FE | src/app/shared/components/cards/service-card-readable/service-card-readable.component.spec.ts › [671-home-and-recent-alerts-mobile/AC-4] makes each service card no wider than the content on mobile |
| AC-6 | Professional sees the same sections on mobile | FE | src/app/modules/home-v2/home.component.spec.ts › [671-home-and-recent-alerts-mobile/AC-6] shows a Professional the same sections on mobile and on desktop |
| AC-7 | Officer sees the same sections on mobile | FE | src/app/modules/home-v2/home.component.spec.ts › [671-home-and-recent-alerts-mobile/AC-7] shows an Officer the same sections on mobile and on desktop |
| AC-8 | Administrator sees the same sections on mobile | FE | src/app/modules/home-v2/home.component.spec.ts › [671-home-and-recent-alerts-mobile/AC-8] shows an Administrator the same sections on mobile and on desktop |
| AC-9 | Desktop keeps three columns | FE | src/app/modules/home-v2/home.component.spec.ts › [671-home-and-recent-alerts-mobile/AC-9] keeps three summary columns and a two-column alerts block on a 1280px screen |
