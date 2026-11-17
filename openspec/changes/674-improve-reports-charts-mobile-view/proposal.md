# Proposal

**Status:** Approved
**Plan:** Approved

## Why

On a phone the Reports section is hard to use: the charts are laid out in two columns and are too narrow to read, the details panels are 380px and 440px wide beside the charts, the tooltip can open partly outside the screen, and a report exported to PDF from a phone can come out with a different size and layout than the one exported on a computer. This is one of the section sub-tickets of the mobile epic ERAS#668. Issue: ERAS#674 ("Reports and charts")

## What Changes

- On a mobile screen (narrower than 768px) the report filters are stacked at full width above the content, the three report tabs are reachable, and the charts fit the width of the screen with no horizontal scroll of the page.
- On a mobile screen the Dynamic Charts are in a single column, one below the other, and the buttons of each chart card fit inside the card. At 768px and wider they stay in two columns.
- On a mobile screen the labels of the Dynamic Charts and the component names on the axes of the Summary Charts are smaller so the chart itself is easier to read.
- On a mobile screen the Student Answers list and the Polls Answered list fit the width of the screen, and the export controls of Student Answers go below its title instead of over it.
- On a mobile screen the details of a chart element (from the Dynamic Charts and from the Summary Charts, in both chart types) are a screen of their own, centered and as wide as the screen, with a visible close button, instead of a panel beside or over the chart, and the list of students inside them fits the screen.
- On a mobile screen the first tap on a chart element shows its tooltip, readable and inside the screen; a second tap on the same element opens its details and hides the tooltip, and a tap outside the chart also hides it.
- A report exported to PDF from a mobile screen has the same page size, orientation and content as the one exported from a desktop screen.
- Screens of 768px and wider keep today's reports.

**Out of scope:** the legacy reports (`reports-v1`), decided on 2026-11-13: they stay desktop only and are not changed on purpose, tablets (sub-ticket 9 of ERAS#668), any change to who can do what, any back end change, and new chart types or new report data.

## Capabilities

### New Capabilities
- `reports-mobile-view`: how the Reports section (the Dynamic Charts, Summary Charts and Polls Answered tabs, their filters, details, tooltip and PDF export) adapts to a mobile screen.

### Modified Capabilities

## Impact

- **Submodules:** FE
- **Roles / who can do what:** no change. Every role that can open Reports today sees the same reports on mobile.
- **API contract:** none
- **Data / migration:** no

## Assumptions

- A1: "Mobile" is a screen narrower than 768px, the same threshold as `mobile-layout`, `students-mobile-view` and `assessments-mobile-view`. The issue's 375px is the test width.
- A2: The issue allows the details panel "below the chart or full screen". It is full screen, as the details of an assessment in `assessments-mobile-view`, so one rule covers every detail of the app.
- A3: "Same size" for the PDF means the same page size and the same orientation that the export produces on a desktop screen; it does not depend on the width of the screen the export was started from.
- A4: The tooltip needs no new content on mobile: it shows the same information as on desktop, only it fits the screen.
- A5: The expand and collapse of a Dynamic Charts card, the chart type menu and the Export button of each card stay available on mobile.
- A7: "The Export that is over Student details and stretches to the side" is the export format selector and Export button of the Student Answers list in Summary Charts (AC-24). If it is another Export button, the AC changes.
- A6: The problems were found by reading the code, not by looking at the app at 375px; the manual validation confirms each one before the plan is approved.

## Clarifications

### Session 2026-11-16

- Q: In mobile, what does the first tap on a chart element do, since a tap opens its details today? → A: it shows the tooltip, and a second tap on the same element opens the details; the same for heatmaps and column charts in the Dynamic and Summary Charts (AC-14, AC-15: changed, marker removed; AC-10, AC-11, AC-12: changed, the details open with the second tap)
- Q: Are the Dynamic Charts labels also smaller on mobile, like the Summary Charts ones? → A: yes, same rule; the former A8 is settled (AC-3, AC-4: changed; AC-21: changed, desktop keeps the label size)
- Status after this session: Clarified
- Status set to Approved on 2026-11-16 at Lucia Becerra's explicit request in chat.
- Plan set to Approved on 2026-11-16 at Lucia Becerra's explicit request in chat.

## Validation log

### 2026-11-16 – Round 1

Setup: run `npm start` in `ERAS-FE` (branch `feature/FE-674/reports-charts-mobile-view`) against the local stack (`AGENTS.md` §3.4), open Reports with the dev tools in device mode (375 x 667, touch emulation on), then repeat the desktop rows at 1280px. Sign in as `ERAS Administrator`. Use an evaluation process with at least two cohorts, a component with many questions, and at least one student. The two-tap tooltip and the PDF are best checked on a real touch device.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1 | At 375px open Reports, Dynamic Charts tab | Evaluation Process, Cohort, Component, Variable and Apply are one below the other at full width; no horizontal scroll of the page | | |
| AC-2 | At 375px look at the three tabs and tap each | Dynamic Charts, Summary Charts and Polls Answered open; no horizontal scroll (the labels wrap onto two lines, option A of D10) | | Lucia Becerra saw the tabs on the phone and chose to leave them as they are |
| AC-3 | Apply filters in Dynamic Charts at 375px | Heatmap cards are one below the other, as wide as the screen, labels smaller | | Reported fine in chat |
| AC-4 | Switch a Dynamic card to Column chart at 375px | Chart, title and legend inside the screen, axis labels smaller | | |
| AC-5 | Look at the Export, chart type and expand buttons of a card at 375px | Buttons inside the card, not overlapping each other or the chart title | | |
| AC-6 | Open Summary Charts at 375px (heatmap) | Legend wraps, component names smaller, cells without numbers, heatmap scrolls sideways inside its own card, page does not scroll | | Reported fine in chat after the second iteration |
| AC-7 | Switch Summary Charts to Column chart at 375px | Chart and legend inside the screen, axis labels smaller, page does not scroll | | |
| AC-8 | Scroll to Student Answers at 375px | Each student is a card with name, email and average risk badge; no table; no horizontal scroll | | |
| AC-9 | Open Polls Answered at 375px | Each poll instance is a card with its columns and action | | |
| AC-10 | Dynamic Charts at 375px: tap a cell, tap it again; then press the close button | Details cover the whole screen, centered, with the close button at the top and no horizontal scroll; closing shows the charts again | | Reported fine in chat |
| AC-11 | Summary heatmap at 375px: tap a cell, tap it again, close | Details are a screen of their own, nothing of the chart beside or behind; closing shows the report | | Reported fine in chat |
| AC-12 | Summary column chart at 375px: tap a column, tap it again, close | Same as AC-11 for the column details | | |
| AC-13 | In any details screen at 375px look at the student list | Each student card fits the screen; no horizontal scroll | | |
| AC-14 | Dynamic heatmap at 375px: tap a cell at the right edge once | Tooltip fully inside the screen and readable; the details do not open | | |
| AC-15 | Summary column chart at 375px: tap a column once | Tooltip inside the screen, above the column; the details do not open | | |
| AC-16 | After a tooltip shows, tap on the page outside the chart | Tooltip disappears; report unchanged | | |
| AC-17 | At 375px export the Summary report to PDF and compare with the one exported at 1280px | Same page size and orientation; chart as wide as the page | | |
| AC-18 | At 375px export a Dynamic card to PDF and compare with the one exported at 1280px | Same page size and orientation; chart as wide as the page | | Reported equal to desktop in chat |
| AC-19 | In the Summary PDF exported at 375px look at the students | A table with every column; no cards, filters or close buttons; the side menu does not open during the export | | |
| AC-20 | At 375px export the Student Answers list to PDF | A table with every column, same page size and orientation as the desktop PDF | | |
| AC-21 | At 1280px open Dynamic Charts and open details | Filters in one row, two chart columns with the usual label sizes, the 380px details beside the charts | | |
| AC-22 | At 1280px open Summary Charts and open details | Filters in one row, the 440px details beside the report, Student Answers is a table with its title and export controls as before | | |
| AC-23 | At 1280px hover a heatmap cell and a column and click one | Tooltip next to the pointer, up to 402px wide, opens on the left near the right edge; the click opens the details at once | | |
| AC-24 | At 375px look at the title of Student Answers and its export controls | The title is on its own line with the format selector and Export below, full width, not overlapping the title; no horizontal scroll | | Reported fine in chat |
| AC-25 | At 375px tap a chart element twice | The tooltip disappears when the details open and does not cover them | | Reported fine in chat |

Side effects to look at while testing: Assessments tabs, the Students list export, the side menu and header at 375px and 1280px, and rotating the phone across 768px.

Approved by Lucia Becerra, 2026-11-16, in chat: goal achieved, no side effects, no open errors. The result column was left for her to fill in; she approved the round as a whole.

Verified 2026-11-16: no gaps, no drift, gates green (openspec validate, FE lint, FE test with coverage, FE build; 25 ACs with exactly 1 FE test each).
