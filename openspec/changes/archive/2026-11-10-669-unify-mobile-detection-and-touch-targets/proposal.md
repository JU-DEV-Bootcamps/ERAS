# Proposal

**Status:** Approved
**Plan:** Approved

## Why

The shared table components and one import preview decide "mobile" with their own `window.innerWidth` reads and resize listeners, which duplicates the 768px rule that #659 introduced as one shared service and makes them hard to test. Their action buttons can also be too small to tap on a phone. This is the first sub-ticket of the mobile epic ERAS#668. Issue: ERAS#669

## What Changes

- The three shared table components (table, table with actions, table with redirect) and the students preview of the answers import take the mobile rule from the shared viewport service instead of reading the window width themselves, so they all switch at 768px and follow a resize.
- Mobile flags that no template reads (import preview, polls answered, evaluation process list, imported students list, old student details) are removed.
- On a screen narrower than 768px the action controls of the shared tables have a tap area of at least 48 by 48 pixels; only the tap area grows, the controls and the cards look the same. From 768px nothing changes.

**Out of scope:** new mobile layouts for any section (sub-tickets 3 to 8 of ERAS#668), dialog sizes (sub-ticket 2), the tooltip positioning of the charts and the dashboard grid, which size themselves from their own container, and tablets (sub-ticket 9).

## Capabilities

### New Capabilities
- `shared-components-mobile`: how the shared table components and the import answers preview react to the screen size, and the tap size of their action controls.

### Modified Capabilities

## Impact

- **Submodules:** FE
- **Roles / who can do what:** no change
- **API contract:** none
- **Data / migration:** no

## Assumptions

- A1: The shared viewport service comes from ERAS#659, which cannot be merged during the code freeze. The 669 branch of ERAS-FE is built on top of the 659 branch, so the service is available; when #659 is merged, this change only carries its own commits. The behavior below does not depend on the service.
- A2: The threshold is the one of #659: narrower than 768px is mobile, 768px and wider is desktop.
- A3: The flags in the import preview, polls answered, evaluation process list (which uses 600px), imported students list and old student details are never read by a template, so removing them changes no behavior and has no AC.

## Clarifications

### Session 2026-11-06

- Q: Which controls get the 48 by 48 pixel tap area on mobile? → A: only the shared table components: the card actions of the table with actions and the detail button of the table with redirect; the other screens belong to sub-tickets 3 to 8 of ERAS#668 (AC-5, AC-6: confirmed, text unchanged; former A5 settled).
- Q: How is the control enlarged on mobile? → A: only its tap area grows; the icon and the button look the same and the cards keep their height (AC-5, AC-6: changed; former A4 settled).
- Status after this session: Clarified

## Validation log

### 2026-11-06 – Round 1

Setup: run the local stack (`AGENTS.md` §3.4) or `npm start` in `ERAS-FE`, open the app in the browser with the dev tools in device mode (375px wide, touch emulation on), then repeat the screen checks at 1280px. Sign in as `ERAS Administrator` (sees every screen below).

Where the shared components are used: `app-table-with-actions` is rendered by `app-list` (Students, Evaluation process, Recent alerts and the other list screens) and by `Import status`; the students preview of the answers import is `Evaluation process > Import preview`. `app-table` and `app-table-with-redirect` are not rendered by any screen of the app (only an `_unused` experimental component imports them), so AC-2, AC-3 and AC-6 cannot be seen in the browser; their tagged tests are the proof.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1 | Open `Students` at 375px. Then widen the window to 1280px without reloading, and narrow it again | At 375px each student is a card with its columns and actions and there is no table. At 1280px a table with the same students. The switch happens while resizing, at 768px | ✅ | Approved as a whole in chat |
| AC-1 | Repeat on `Recent alerts` and `Evaluation process` (screens that use the same list component) | Same behavior: cards below 768px, table from 768px | ✅ | Side effect check |
| AC-1 | Open an import and go to `Import status` (`/evaluation-process/import-status/<id>`) at 375px and at 1280px | Cards at 375px, table at 1280px; the selection checkboxes and the row actions still work | ✅ | Side effect check |
| AC-2 | Not visible in the app (component not rendered by any screen) | Proven by its tagged test | n.a. | |
| AC-3 | Not visible in the app (component not rendered by any screen) | Proven by its tagged test | n.a. | |
| AC-4 | Go to `Evaluation process > Import preview`, load a preview with students, at 375px. Reload the page directly at 375px (do not resize) | At the first render each student is a card with its columns and its save switch and there is no table (before this change a direct load at 375px showed the table). At 1280px a table with the same students | ✅ | Real bug fixed: the flag was only set on resize |
| AC-5 | At 375px, on `Students` (or `Import status`), look at the action buttons of a card and tap each one with the touch emulation. Inspect one button in the dev tools: its touch target element (`.mat-mdc-button-touch-target`) | Each action is easy to tap, with a tap area of at least 48 by 48 px, they do not overlap, and the card looks as before (same height, same visible buttons) | ✅ | Tests proved the tap area already was 48px, so no CSS was added |
| AC-6 | Not visible in the app (component not rendered by any screen) | Proven by its tagged test | n.a. | |
| AC-7 | At 1280px, on `Students` and `Import status`, compare the row height and the action controls with `develop` | Nothing is enlarged: same row height and same 40 px controls | ✅ | Approved as a whole in chat |
| – | Errors and states: open `Students` with a search that returns nothing, and with the backend stopped | The empty and error messages show as before at 375px and at 1280px | ✅ | Regression check |
| – | Roles: sign in as `ERAS Student Services Officer` and `ERAS Professional` and open `Students` at 375px | The cards and actions each role is allowed to see appear as before; no new action is shown | ✅ | Side effect check |
| – | Screens whose unused mobile flag was removed: open `Polls answered` (Reports), `Evaluation process`, `Import students` list and the student details modal at 375px | They load and look as before (no error in the console) | ✅ | Dead code removed, no AC |
| – | Open the browser console during all of the above | No errors or warnings caused by the viewport service | ✅ | Approved as a whole in chat |

Approved by Lucia, 2026-11-06 (reported in chat: everything fine, no problems; AC-2, AC-3 and AC-6 are proven by their tests only). The rows marked ✅ were approved as a whole from that report; the chat did not list them one by one.

Verified 2026-11-06: no gaps, no drift, gates green

Post-review change 2026-11-10 (reviewer comments on ERAS-FE#1122 and ERAS#683): the guard tests of AC-5, AC-6 and AC-7 no longer use fixed sizes or Material internals. They compare the mobile layout with the desktop one, a standard Material icon button and the layout with the touch targets hidden; the only number left is the 48px of the AC. The Round 1 results above were filled from the approval in chat. The new tests were proven to fail by hiding the touch targets, enlarging the buttons on mobile only and enlarging them everywhere.

Verified 2026-11-10: no gaps, no drift, gates green (AC-1 to AC-7)
