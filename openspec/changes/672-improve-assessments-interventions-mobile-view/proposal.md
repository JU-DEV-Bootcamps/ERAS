# Proposal

**Status:** Approved
**Plan:** Approved

## Why

On a phone the Assessments section cannot be used: the assessment and intervention lists are wide tables that scroll sideways, the detail of a row opens in a panel that is always 480px wide, the assessment form is at least 500px wide, and the intervention filters do not fit. A user on a 375px screen cannot read the lists, see a detail or complete a form. This is one of the section sub-tickets of the mobile epic ERAS#668. Issue: ERAS#672 ("Assessments and interventions")

## What Changes

- On a mobile screen (narrower than 768px) each assessment and each intervention is a card with all its fields and its actions, instead of a wide table row, with no horizontal scroll.
- On a mobile screen the Interventions filters, the Export button and the Create Intervention button are stacked and fit the width of the screen.
- On a mobile screen the detail of an assessment and the detail of an intervention cover the whole screen, with a visible close button that returns to the list.
- On a mobile screen the View, Edit and Delete actions are icon buttons on each card, and the extra student names of an assessment open with a tap, without a hover.
- On a mobile screen the forms to create and edit an assessment and an intervention, and the student details opened from an assessment, open full screen; the delete confirmation fits inside the screen.
- An action that a role or a Finalized status blocks on desktop is blocked in the same way on mobile.
- Screens of 768px and wider keep today's tables, side panel, action controls and dialog sizes.

**Out of scope:** tablets (sub-ticket 9 of ERAS#668), the content of the student details modal (covered by `students-mobile-view`), any change to who can do what, any back end change, and two findings in the current code that are recorded here and not fixed: the role check of the `/assessments` route is not enforced by its guard (only the side menu hides the entry), and "Create Intervention" in the assessment detail and in the empty state of the Interventions list has no role or status check in the front end.

## Capabilities

### New Capabilities
- `assessments-mobile-view`: how the Assessments section (the Assessments and Interventions tabs, their details and their dialogs) adapts to a mobile screen.

### Modified Capabilities

## Impact

- **Submodules:** FE
- **Roles / who can do what:** no change. The actions each role can use today stay the same on mobile.
- **API contract:** none
- **Data / migration:** no

## Assumptions

- A1: "Mobile" is a screen narrower than 768px, the same threshold as `mobile-layout`, `students-mobile-view` and `home-mobile-view`. The issue's 375px is the test width.
- A3: The cards show the same fields as the table columns. Assessment: date, submitter, service, professionals, students, status and comment. Intervention: date, type, mode, activity, professional, student, area, risk level, end risk level, status and comment.
- A5: The issue's AC-2 names the assessment detail. The intervention detail uses the same 480px panel in the same section, so it gets the same full-screen behavior.
- A7: The lists keep their pagination; on mobile it only has to fit the width of the screen.

## Clarifications

### Session 2026-11-11

- Q: The issue says an action without permission "is hidden as on desktop", but on desktop "Create Assessment", Edit and Delete are shown disabled for an `ERAS Professional`. What does mobile do? → A: disabled, as on desktop (AC-15: changed, marker removed).
- Q: How are the View, Edit and Delete actions shown on a mobile card? → A: as three icon buttons on the card, one tap each, like the Students cards; no "more" menu on mobile (AC-6, AC-7 and their requirement: changed).
- Q: Sub-ticket 2 (ERAS#670) left no shared dialog size rule. Which rule do the dialogs of this section follow on mobile? → A: the forms to create and edit an assessment and an intervention and the student details open full screen, as in `students-mobile-view`; a delete confirmation only has to fit inside the screen (AC-9 to AC-14: confirmed, text unchanged; former A2 and A6 settled).
- Q: The issue's AC-6 says "inline actions behave as before" at 1280px, but the inline icons are only shown from 1500px. What does "as before" mean? → A: at 1280px the table keeps the "more" menu of each row, and the 1500px rule is not moved (AC-17, AC-18: confirmed, text unchanged; former A4 settled).
- Q: Do the two findings (no role or Finalized check on "Create Intervention" in the assessment detail and in the empty state, and the route guard of `/assessments` not enforcing roles) enter this change? → A: no, out of scope; they stay recorded under Out of scope for a ticket of their own.
- Status after this session: Clarified
- Status set to Approved on 2026-11-11 at Lucia Becerra's explicit request in chat.
- Plan set to Approved on 2026-11-11 at Lucia Becerra's explicit request in chat.

## Validation log

### 2026-11-11 – Round 1

Setup: run the local stack (`AGENTS.md` §3.4) or `npm start` in `ERAS-FE` (branch `feature/FE-672/assessments-interventions-mobile-view`), open the app with the dev tools in device mode (375 x 667, touch emulation on), then repeat the desktop rows at 1280px. Sign in as `ERAS Administrator` unless the row names another role. Use an assessment with three or more students and at least one intervention, and one Finalized assessment.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1 | At 375px open `Assessments` | Each assessment is a card with date, submitter, service, professional, student, status and comment; no table; no horizontal scroll in the page or in the pagination | ✅ | Approved as a whole in chat |
| AC-2 | At 375px open the `Interventions` tab, pick an assessment and the filters, press Apply | Each intervention is a card with date, type, mode, activity, professional, student, area, risk level, end risk level, status and comment; no horizontal scroll | ✅ | Approved as a whole in chat |
| AC-3 | Same screen, look at the filters and the buttons | The four filters are one below the other at full width, Apply is below them with room before the next row, and Export and "Create Intervention" are visible | ✅ | The room between Apply and the buttons was reported as too small and fixed in this round (16px on mobile only); Lucia Becerra confirmed in chat that it looks right |
| AC-4 | At 375px press View on an assessment card, scroll the detail, press the close button | The detail covers the whole screen, the close button is visible at the top, and closing shows the cards again | ❌ | Reported by Lucia Becerra in chat on 2026-11-11: at 375px the list of students of the detail is too wide and the detail scrolls sideways. Sent back to implementation (tasks 1.41, 1.42) |
| AC-5 | At 375px press View on an intervention card, then close | Same as AC-4, with the attachments and the activity history readable | ✅ | Approved as a whole in chat |
| AC-6 | At 375px tap View, Edit and Delete on an assessment card | Each action starts with one tap; there is no "more" menu on the card | ✅ | Approved as a whole in chat |
| AC-7 | At 375px tap View, Edit and Delete on an intervention card | Each action starts with one tap; there is no "more" menu on the card | ✅ | Approved as a whole in chat |
| AC-8 | At 375px tap the "+N" badge of an assessment with several students (on the card, and on an intervention card) | The other student names appear, completely inside the screen; tapping outside closes them | ✅ | Approved as a whole in chat |
| AC-9 | At 375px, as `ERAS Student Services Officer`, press "Create Assessment", fill the form and create | The form covers the whole screen, every field can be reached and filled, Cancel and Create are visible, and the new assessment appears in the list | ✅ | Approved as a whole in chat |
| AC-10 | At 375px, as `ERAS Professional`, press "Create Intervention" (from the Interventions tab and from the assessment detail), fill the form, attach a file and create | The form covers the whole screen, nothing is cut off, and the new intervention appears in the list | ✅ | Approved as a whole in chat |
| AC-11 | At 375px press Edit on a Remitted assessment, change the comment and save | The edit form covers the whole screen and the change is saved | ✅ | Approved as a whole in chat |
| AC-12 | At 375px press Edit on an In Progress intervention with attached documents, change the status and save | The edit form covers the whole screen, the attached documents are not cut off, and the change is saved | ✅ | Approved as a whole in chat |
| AC-13 | At 375px press Delete on an intervention, on an assessment, and remove a student from an assessment detail; cancel each one | Each confirmation is inside the screen with both buttons visible | ✅ | Approved as a whole in chat |
| AC-14 | At 375px open an assessment detail and open the details of one of its students | The student details cover the whole screen and can be closed | ✅ | Approved as a whole in chat |
| AC-15 | At 375px, as `ERAS Professional`, open `Assessments` | "Create Assessment", Edit and Delete are shown disabled; View works | ✅ | Approved as a whole in chat |
| AC-16 | At 375px open a Finalized assessment in both tabs | Edit of the assessment is disabled; Edit and Delete of its interventions are disabled and the "Create Intervention" button above the list is not shown | ✅ | Approved as a whole in chat |
| AC-17 | At 1280px open `Assessments` and press View from the "more" menu of a row | A table with the "more" menu per row, the full pagination, and the detail as a 480px panel beside the table | ✅ | Approved as a whole in chat |
| AC-18 | At 1280px open `Interventions`, apply the filters and press View | The filters in one row with Apply beside them, a table with the "more" menu, and the detail as a 480px panel beside the table | ✅ | Approved as a whole in chat |
| AC-19 | At 1280px open the create assessment form and the create intervention form | They open centered at their current size (about 512px and 520px), with the page visible around them | ✅ | Approved as a whole in chat |
| – | At 1600px open both tabs | The inline Edit, View and Delete icons are shown in each row, as before | ✅ | Side effect check (the 1500px rule is not changed) |
| – | Resize the window across 768px with a detail open | The detail stays open and moves between the side panel and the full screen | ✅ | Side effect check |
| – | Other screens that use the delete confirmation (for example deleting a student in `Students`) at 1280px | The confirmation looks as before | ✅ | Side effect check: the shared confirmation only gained a maximum width |
| – | Empty and error states at 375px: `Assessments` with no assessment, `Interventions` with no assessment selected, with filters that match nothing, and with the backend stopped | The messages show as before, inside the screen | ✅ | Regression check |
| – | Open the browser console during all of the above | No new errors or warnings | ✅ | Approved as a whole in chat |

### 2026-11-11 – Round 2

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-4 | At 375px press View on an assessment with students whose names and emails are long, and look at the list of students of the detail | The student cards fit the detail, with their two actions visible, and the detail has no horizontal scroll | ✅ | Retest of the Round 1 finding after tasks 1.41 and 1.42; covered by Lucia Becerra's approval below |

Approved by Lucia Becerra, 2026-11-11 (reported in chat: approved, after the two findings of Round 1 were fixed: the room below the Apply button and the width of the list of students). The rows marked ✅ were approved as a whole from that report; the chat did not list them one by one. The ❌ of AC-4 in Round 1 is the finding that Round 2 retests.

Verified 2026-11-11: no gaps, no drift, gates green (AC-1 to AC-19)

Post-review change 2026-11-12 (a self review of both branches before the pull requests, ERAS#672): the tests no longer use Material's internal classes or the style values of the implementation. They check the paginator by its accessible labels, the rows by the template's own attribute, the full-screen detail against an element fixed to the screen, and the student names with the badge at the right edge of the screen. The 375px fit check of the forms looks at the header, the fields and the buttons. New checks without an AC tag: the cards and the pagination at 320px in both lists. The existing specs of the units made responsive now state a desktop screen. In the code, the full-screen detail does not scroll the page behind it (`overscroll-behavior`). `design.md` was brought in line with the final code (six dialog calls, which cells are shared, no sticky header). The Result cells of Round 1 were filled from the approval in chat. Every guard and hardened test was proven to fail by breaking the code it protects. No AC text changed.

Verified 2026-11-12: no gaps, no drift, gates green (AC-1 to AC-19)
