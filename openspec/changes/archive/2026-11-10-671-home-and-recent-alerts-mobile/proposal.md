# Proposal

**Status:** Approved
**Plan:** Approved

## Why

On a phone the Home page and the Recent Alerts page overflow: the summary cards and the alerts block sit in three fixed columns, the alerts are a wide table, and the service cards are a fixed 330px wide. Issue: ERAS#671 ("Home and Recent Alerts")

## What Changes

- On a mobile screen (narrower than 768px) the Home summary cards are stacked in one column, and the Recent Alerts block and the connected service cards fill the width of the screen.
- On a mobile screen each recent alert, on Home and on the full Recent Alerts page, is shown as a card with all its fields instead of a wide table row.
- Every role sees on mobile the same Home sections as on desktop.
- Screens of 768px and wider keep today's three-column Home.

**Out of scope:** the application shell (side menu and header, already covered by `mobile-layout`), the risk students table (no screen renders it today: only the `_unused` experimental page uses it, so the issue's AC-3 is not delivered), the legacy Home layout, the other pages, and any back end change.

## Capabilities

### New Capabilities
- `home-mobile-view`: how the Home page and the recent alerts adapt to a mobile screen.

### Modified Capabilities

## Impact

- **Submodules:** FE
- **Roles / who can do what:** no change.
- **API contract:** none
- **Data / migration:** no

## Assumptions

- A1: "Mobile" is a screen narrower than 768px, the same threshold as `mobile-layout` and `students-mobile-view`.
- A2: The alert card on mobile shows the same fields as the table: student id, student name, risk level, category, date and status.
- A3: On mobile the "Recent Alerts" block keeps its "View All" link.
- A4: The section order on mobile is the desktop order: Overview, summary cards, Recent Alerts, Connected Services.

## Clarifications

### Session 2026-11-10

- Q: The issue asks for risk students as cards on mobile, but no active screen renders the risk students table. What should the spec do? → A: out of scope; AC-5 removed (number left as a gap) and the risk students table is listed under Out of scope.
- Fixed from evidence: AC-2 already holds for the card switch below 768px in the shared table, so its test proves the Recent Alerts page and Home block keep it; the Why no longer names the risk students table.
- Status after this session: Clarified

## Validation log

### 2026-11-10 – Round 1

Run the app with the local stack (AGENTS.md §3.4) or `npm start` in `ERAS-FE/`, with the Home v2 flag on (`homev2`). Open DevTools device mode at 375×812, then 1280×800 for the desktop rows. Reload after changing the size.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1 | At 375px as `ERAS Administrator`, open Home | "Number of Students", "Polls Answered" and "Evaluations" are one below the other, none cut off, no horizontal scroll | ✅ | |
| AC-2 | At 375px, open Recent Alerts (`/recent-alerts`) with at least one alert | Each alert is a card with student id, name, risk level, category, date and status; no table, no horizontal scroll | ✅ | Known: the date prints as a raw date string (follow-up in design.md) |
| AC-3 | At 375px, open Home | "Recent Alerts" block with "View All" is as wide as the content, below the summary cards; "View All" opens `/recent-alerts` | ✅ | |
| AC-4 | At 375px, open Home with at least one connected service | Each service card is no wider than the screen, no horizontal scroll | | ✅|
| AC-6 | Open Home as `ERAS Professional` at 375px and 1280px | Same sections on both: Overview, summary cards, Recent Alerts, Connected Services | ✅ | |
| AC-7 | Same as AC-6 as `ERAS Student Services Officer` | Same sections on both sizes | ✅ | |
| AC-8 | Same as AC-6 as `ERAS Administrator` | Same sections on both sizes | ✅ | |
| AC-9 | At 1280px, open Home | Three summary cards in one row; the Recent Alerts block spans two of three columns | ✅ | |
| Side effects | At 1280px open Recent Alerts and Home; at 375px open Students | No visible change on desktop; Students (change 659) still looks as before | ✅ | |
| Errors / states | At 375px, Home with no recent alerts and with no services; slow or failing API | Empty and loading states fit the screen, no overflow | ✅ | |
| Different views | Rotate to 768px+ (tablet) and use the `?v1` override | 768px shows the desktop layout; `?v1` shows the legacy Home unchanged | ✅ | |

Approved by Judith Paco, 2026-11-10
Verified 2026-11-10: no gaps, no drift, gates green
