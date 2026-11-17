# Proposal

**Status:** Approved
**Plan:** Approved

## Why

On a phone the Reports section is hard to use: the charts are laid out in two columns and are too narrow to read, the details panels are 380px and 440px wide beside the charts, the tooltip can open partly outside the screen, and a report exported to PDF from a phone can come out with a different size and layout than the one exported on a computer. This is one of the section sub-tickets of the mobile epic ERAS#668. Issue: ERAS#674 ("Reports and charts")

## What Changes

- On a mobile screen (narrower than 768px) the report filters are stacked at full width above the content, the three report tabs are reachable, and the charts fit the width of the screen with no horizontal scroll of the page.
- On a mobile screen the Dynamic Charts are in a single column, one below the other, and the buttons of each chart card fit inside the card. At 768px and wider they stay in two columns.
- On a mobile screen the Apply button of the Dynamic Charts filters keeps room above the first chart card.
- On a mobile screen the labels of the Dynamic Charts and the component names on the axes of the Summary Charts are smaller so the chart itself is easier to read. The Summary heatmap shows no numbers in its cells and scrolls sideways inside its own card so its cells can be tapped.
- On a mobile screen the Student Answers list and the Polls Answered list fit the width of the screen, and the export controls of Student Answers go below its title instead of over it.
- On a mobile screen the details of a chart element (from the Dynamic Charts and from the Summary Charts, in both chart types) are a screen of their own, centered and as wide as the screen, with a visible close button, instead of a panel beside or over the chart, and the list of students inside them fits the screen.
- On a mobile screen the first tap on a chart element shows its tooltip, readable and inside the screen; a second tap on the same element opens its details and hides the tooltip, and a tap outside the chart also hides it.
- A report exported to PDF from a mobile screen (the Summary report, a Dynamic Charts card and the Student Answers list) has the same page size, orientation and content as the one exported from a desktop screen. While it is made, the side menu and the header keep their mobile layout.
- Screens of 768px and wider keep today's reports.

**Out of scope:** the legacy reports (`reports-v1`), decided on 2026-11-13: they stay desktop only and are not changed on purpose, tablets (sub-ticket 9 of ERAS#668), any change to who can do what, any back end change, and new chart types or new report data.

## Capabilities

### New Capabilities
- `reports-mobile-view`: how the Reports section (the Dynamic Charts, Summary Charts and Polls Answered tabs, their filters, details, tooltip and PDF export) adapts to a mobile screen.

### Modified Capabilities

## Impact

- **Submodules:** FE
- **Roles / who can do what:** no change. Every role that can open Reports today sees the same reports on mobile.
- **Shared pieces:** `app-poll-filters` stacks its filters on mobile everywhere it is used, so the legacy `reports-v1` pages and Polls Answered also get it; the legacy charts, lists and PDF exports do not change. The PDF change is opt-in per export, so the Students list, the student detail modals and `reports-v1` export as before. The tooltip directive, the shared list and the expandable card keep their desktop behavior.
- **API contract:** none
- **Data / migration:** no

## Assumptions

- A1: "Mobile" is a screen narrower than 768px, the same threshold as `mobile-layout`, `students-mobile-view` and `assessments-mobile-view`. The issue's 375px is the test width.
- A2: The issue allows the details panel "below the chart or full screen". It is full screen, as the details of an assessment in `assessments-mobile-view`, so one rule covers every detail of the app.
- A3: "Same size" for the PDF means the same page size and the same orientation that the export produces on a desktop screen. The report is measured as a desktop content area of 1000px (490px for a Dynamic Charts card, the width of a card on a 1280px screen), so it does not depend on the width of the phone it was started from.
- A4: The tooltip needs no new content on mobile: it shows the same information as on desktop, only it fits the screen.
- A5: The expand and collapse of a Dynamic Charts card, the chart type menu and the Export button of each card stay available on mobile.
- A6: The problems were first found by reading the code, not by looking at the app at 375px; the manual validation on a phone-sized screen (Round 1 and 2 of the validation log) confirmed or corrected each one.
- A7: "The Export that is over Student details and stretches to the side" is the export format selector and Export button of the Student Answers list in Summary Charts (AC-24). If it is another Export button, the AC changes.


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
| AC-1 | At 375px open Reports, Dynamic Charts tab | Evaluation Process, Cohort, Component, Variable and Apply are one below the other at full width; no horizontal scroll of the page | ✅ | Approved as a whole in chat |
| AC-2 | At 375px look at the three tabs and tap each | Dynamic Charts, Summary Charts and Polls Answered open; no horizontal scroll (the labels wrap onto two lines, option A of D10) | ✅ | Lucia Becerra saw the tabs on the phone and chose to leave them as they are |
| AC-3 | Apply filters in Dynamic Charts at 375px | Heatmap cards are one below the other, as wide as the screen, labels smaller | ✅ | Reported fine in chat |
| AC-4 | Switch a Dynamic card to Column chart at 375px | Chart, title and legend inside the screen, axis labels smaller | ✅ | Approved as a whole in chat |
| AC-5 | Look at the Export, chart type and expand buttons of a card at 375px | Buttons inside the card, not overlapping each other or the chart title | ✅ | Approved as a whole in chat |
| AC-6 | Open Summary Charts at 375px (heatmap) | Legend wraps, component names smaller, cells without numbers, heatmap scrolls sideways inside its own card, page does not scroll | ✅ | Reported fine in chat after the second iteration |
| AC-7 | Switch Summary Charts to Column chart at 375px | Chart and legend inside the screen, axis labels smaller, page does not scroll | ✅ | Approved as a whole in chat |
| AC-8 | Scroll to Student Answers at 375px | Each student is a card with name, email and average risk badge; no table; no horizontal scroll | ✅ | Approved as a whole in chat |
| AC-9 | Open Polls Answered at 375px | Each poll instance is a card with its columns and action | ✅ | Approved as a whole in chat |
| AC-10 | Dynamic Charts at 375px: tap a cell, tap it again; then press the close button | Details cover the whole screen, centered, with the close button at the top and no horizontal scroll; closing shows the charts again | ✅ | Reported fine in chat |
| AC-11 | Summary heatmap at 375px: tap a cell, tap it again, close | Details are a screen of their own, nothing of the chart beside or behind; closing shows the report | ✅ | Reported fine in chat |
| AC-12 | Summary column chart at 375px: tap a column, tap it again, close | Same as AC-11 for the column details | ✅ | Approved as a whole in chat |
| AC-13 | In any details screen at 375px look at the student list | Each student card fits the screen; no horizontal scroll | ✅ | Approved as a whole in chat |
| AC-14 | Dynamic heatmap at 375px: tap a cell at the right edge once | Tooltip fully inside the screen and readable; the details do not open | ✅ | Approved as a whole in chat |
| AC-15 | Summary column chart at 375px: tap a column once | Tooltip inside the screen, above the column; the details do not open | ✅ | Approved as a whole in chat |
| AC-16 | After a tooltip shows, tap on the page outside the chart | Tooltip disappears; report unchanged | ✅ | Approved as a whole in chat |
| AC-17 | At 375px export the Summary report to PDF and compare with the one exported at 1280px | Same page size and orientation; chart as wide as the page | ✅ | Approved as a whole in chat |
| AC-18 | At 375px export a Dynamic card to PDF and compare with the one exported at 1280px | Same page size and orientation; chart as wide as the page | ✅ | Reported equal to desktop in chat |
| AC-19 | In the Summary PDF exported at 375px look at the students | A table with every column; no cards, filters or close buttons; the side menu does not open during the export | ✅ | Approved as a whole in chat |
| AC-20 | At 375px export the Student Answers list to PDF | A table with every column, same page size and orientation as the desktop PDF | ✅ | Approved as a whole in chat |
| AC-21 | At 1280px open Dynamic Charts and open details | Filters in one row, two chart columns with the usual label sizes, the 380px details beside the charts | ✅ | Approved as a whole in chat |
| AC-22 | At 1280px open Summary Charts and open details | Filters in one row, the 440px details beside the report, Student Answers is a table with its title and export controls as before | ✅ | Approved as a whole in chat |
| AC-23 | At 1280px hover a heatmap cell and a column and click one | Tooltip next to the pointer, up to 402px wide, opens on the left near the right edge; the click opens the details at once | ✅ | Approved as a whole in chat |
| AC-24 | At 375px look at the title of Student Answers and its export controls | The title is on its own line with the format selector and Export below, full width, not overlapping the title; no horizontal scroll | ✅ | Reported fine in chat |
| AC-25 | At 375px tap a chart element twice | The tooltip disappears when the details open and does not cover them | ✅ | Reported fine in chat |

Side effects to look at while testing: Assessments tabs, the Students list export, the side menu and header at 375px and 1280px, and rotating the phone across 768px.


Approved by Lucia Becerra, 2026-11-16, in chat (Round 1): goal achieved, no side effects, no open errors. She approved the round as a whole, so the rows without a note read "Approved as a whole in chat".

Round 1 was followed on 2026-11-16 and 2026-11-17 by fixes she asked for in chat (the tooltip over the details, the numbers in the heatmap and its size, the PDF from a phone, the side menu opening while exporting, the space below the filters; AC-25, AC-26 and AC-27 were added) and by the changes of an independent review before the pull requests. Round 2 re-checks what those changes touched.

### 2026-11-17 – Round 2

Setup: as in Round 1.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-14 | At 375px tap a cell of the Dynamic heatmap once; start a drag on another cell and cancel it | The first tap shows the tooltip and does not open the details; a cancelled drag shows nothing and does not count as a tap | | |
| AC-16 | After a tooltip shows, tap an axis label or the legend, then tap outside the chart | The tooltip disappears each time; the next tap on a cell shows the tooltip again | | |
| AC-25 | Tap a Summary heatmap cell twice, then the same in a column chart | The second tap opens the details with no tooltip over them | | |
| AC-6 | Open the Summary heatmap at 375px and tap two cells in a row | The heatmap does not flicker or redraw between the taps; it scrolls sideways inside its card | | |
| AC-15 | Tap a column near the bottom edge of the screen | The tooltip stays fully inside the screen, above or below the column | | |
| AC-17 | At 375px export the Summary report to PDF | Same page size and orientation as the desktop PDF, chart as wide as the page, students as a table | | |
| AC-18 | At 375px export a Dynamic card to PDF | Same as the desktop PDF; the page looks as before once the export ends | | Reported equal to desktop in chat before the review |
| AC-20 | At 375px export the Student Answers list to PDF | A table with every column, same page size and orientation as the desktop PDF | | |
| AC-19 | At 375px export the Students list (Students page) to PDF | It exports as before this change (the desktop rendering is not used there) | | Side effect to look at |
| AC-27 | Watch the side menu and the header while any of those PDFs is made | Neither changes; the menu stays hidden | | Reported fixed in chat |
| AC-26 | At 375px apply filters in Dynamic Charts | The Apply button does not touch the first chart card | | Reported fixed in chat |
| AC-28 | At 375px open any details with students of short and long names and answers | The risk badge and the open icon line up in the same columns in every card; the text wraps in its own column | | Reported in chat, fixed |
| AC-10 to AC-12 | Open each of the three details at 375px | The close button is visible at the top of the screen | | |
| AC-1 | At 375px open Summary Charts and Polls Answered | Their filters are stacked at full width; the legacy `/reports-v1` pages also show stacked filters | | Side effect to look at |

Side effects to look at while testing: Assessments tabs, the Students list export, and rotating the phone across 768px.
