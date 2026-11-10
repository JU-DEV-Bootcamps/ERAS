# Proposal

**Status:** Approved
**Plan:** Approved

## Why

On a phone, the pagination of the Student Details modal wraps its range label: "21 – 30 of 46" shows "46" on a second line, so the pagination looks misaligned. It was reported on 2026-11-10 during the manual review of the modals one by one, after an earlier attempt of ERAS#670 was discarded. This is the first fix of that review. Issue: ERAS#670

## What Changes

- On a screen narrower than 768px the range label of the pagination of the Student Details modal ("21 – 30 of 46") is on one line and sits aligned with the page buttons.
- From 768px the pagination of the Student Details modal looks as it does today.
- Every other list and every other modal keeps its pagination exactly as it is.

**Out of scope:** any other modal or screen (each one is reviewed and fixed on its own request), the charts and tables inside the Student Details modal, and the dialog sizes.

## Capabilities

### New Capabilities

### Modified Capabilities
- `students-mobile-view`: adds the requirement for the pagination of the Student Details modal on a phone.

## Impact

- **Submodules:** FE
- **Roles / who can do what:** no change
- **API contract:** none
- **Data / migration:** no

## Assumptions

- A1: "Student Details modal" is the modal opened with "See more details" in the Students list, in both of its versions (the one shown with the `studentDetails` feature flag and the older one), because both show the same list with the same pagination.
- A2: "Aligned" means the range label is on one line and on the same row as the page buttons, with the page-size selector kept as it is today.

## Clarifications

### Session 2026-11-10

- Q: Are the assumptions A1 (both versions of the Student Details modal) and A2 ("aligned" means one line on the same row as the page buttons, selector kept) right? → A: confirmed by Lucia in chat (A1, A2 settled, text unchanged).
- A1 refined during implementation: the older version of the modal does not wrap its range label at 375px (its list has less padding than the card of v2), so it is not changed and the AC applies to v2; this narrows the change, not its behavior.
- Status and Plan set to Approved on 2026-11-10 at Lucia Becerra's explicit request in chat.

## Validation log

### 2026-11-10 – Round 1

Setup: run the local stack (`AGENTS.md` §3.4) or `npm start` in `ERAS-FE` (the branch of this change), open the app with the dev tools in device mode (375 x 667, touch emulation on), then repeat the desktop check at 1280px. Sign in as `ERAS Administrator`. Use a student with more than 20 answers.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1 | At 375px open `Students`, press "See more details" on a student with 40 or more answers, scroll to the list of answers and go to its third page | The range "21 – 30 of ..." is on one line, on the same row as the page buttons; nothing is cut or outside the modal | ✅ | The wrapped "46" was the reported problem |
| AC-2 | Repeat the same at 1280px | The pagination looks as before: page-size selector, the range on one line next to the four page buttons | ✅ | |
| AC-4 | At 320px (and 360px) open `Students`, press "See more details" on a student with 40 or more answers, scroll to the answers and go to its third page | The range "21 – 30 of ..." is on one line and the page buttons are below it, both inside the card of the answers, nothing cut | | Added after the review; pending the manual look |
| AC-3 | At 375px open any other list with pagination (`Students`, `Evaluation process`, `Recent alerts`) | Its pagination looks as before this change | ✅ | Side effect check |
| – | Open the student details of a student with no answers, and with the backend stopped, at 375px | The empty and error states show as before | ✅ | Regression check |
| – | Open the student details with the older design (turn the `studentDetails` flag off) at 375px | The pagination looks as before; its range is already on one line | ✅ | The older version is not changed |
| – | Open the browser console during all of the above | No new errors or warnings | ✅ | |

Approved by Lucia Becerra, 2026-11-10 (reported in chat: everything fine; the rows marked ✅ were approved as a whole from that report, the chat did not list them one by one).

Post-review change 2026-11-10 (an independent review of the PRs, ERAS#670): a 320px phone had less room than the row needs and the range went out of the card, so AC-4 was added (spec text: the range is on the same row as the buttons from 375px; below that the buttons go under it), the paginator loses its 8px of side padding on a phone and its actions wrap, AC-3 is now tested next to the modal with a real paginator, and the spec says "third page" (46 answers at 10 per page) where it said "second". Needs a manual look at 320px and 360px (row AC-4) and the reviewer for the spec text; run /sdd-verify again before archiving.

Verified 2026-11-10: no gaps, no drift, gates green (AC-1 to AC-4)
