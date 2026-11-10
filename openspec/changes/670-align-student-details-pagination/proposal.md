# Proposal

**Status:** Approved
**Plan:** Approved

## Why

On a phone, the pagination of the Student Details modal wraps its range label: "21 – 30 of 46" shows "46" on a second line, so the pagination looks misaligned. Lucia reported it on 2026-11-10 while reviewing the modals one by one after the earlier attempt of ERAS#670 was reset. This is the first fix of that review. Issue: ERAS-FE#670 (ERAS#670)

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
- A1 refined during implementation: the older version of the modal does not wrap its range label at 375px (its list is not inside the padded card of v2), so it is not changed and the AC applies to v2; this narrows the change, not its behavior.
- Status and Plan set to Approved on 2026-11-10 at Lucia Becerra's explicit request in chat.

## Validation log

### 2026-11-10 – Round 1

Setup: run the local stack (`AGENTS.md` §3.4) or `npm start` in `ERAS-FE` (branch `670-responsive-dialogs-and-modals`), open the app with the dev tools in device mode (375 x 667, touch emulation on), then repeat the desktop check at 1280px. Sign in as `ERAS Administrator`. Use a student with more than 20 answers.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1 | At 375px open `Students`, press "See more details" on a student with 40 or more answers, scroll to the list of answers and go to its third page | The range "21 – 30 of ..." is on one line, on the same row as the page buttons; nothing is cut or outside the modal | ✅ | The wrapped "46" was the reported problem |
| AC-2 | Repeat the same at 1280px | The pagination looks as before: page-size selector, the range on one line next to the four page buttons | ✅ | |
| AC-3 | At 375px open any other list with pagination (`Students`, `Evaluation process`, `Recent alerts`) | Its pagination looks as before this change | ✅ | Side effect check |
| – | Open the student details of a student with no answers, and with the backend stopped, at 375px | The empty and error states show as before | ✅ | Regression check |
| – | Open the student details with the older design (turn the `studentDetails` flag off) at 375px | The pagination looks as before; its range is already on one line | ✅ | The older version is not changed |
| – | Open the browser console during all of the above | No new errors or warnings | ✅ | |

Approved by Lucia Becerra, 2026-11-10 (reported in chat: everything fine; the rows marked ✅ were approved as a whole from that report, the chat did not list them one by one).

Verified 2026-11-10: no gaps, no drift, gates green (AC-1 to AC-3)
