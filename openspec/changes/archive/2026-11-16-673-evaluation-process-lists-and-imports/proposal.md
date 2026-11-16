# Proposal

**Status:** Approved
**Plan:** Approved

## Why

On a 375px phone screen the Evaluation Process list already shows each process as a readable card, but a long Poll Name without spaces, such as 100 characters, overflows the card. Part of the mobile epic 668. Issue: [ERAS#673](https://github.com/JU-DEV-Bootcamps/ERAS/issues/673)

## What Changes

- The card of an evaluation process keeps its whole Poll Name inside the card on a mobile screen, breaking it over several lines.

**Out of scope:** every other page and dialog (evaluation process form, students of a poll, Import Polls, import preview, import progress, students import), because they already look right on a 375px screen; a new look for the cards; and any change to the table shown from 768px.

## Capabilities

### New Capabilities
- `evaluation-process-mobile-view`: how the cards of the Evaluation Process list handle long values on a phone screen, and that the table on a desktop screen stays the same.

### Modified Capabilities

## Impact

- **Submodules:** FE
- **Roles / who can do what:** no change
- **API contract:** none
- **Data / migration:** no

## Assumptions

- A1: Only the Poll Name is known to overflow; other values of the card are not part of this change unless they are found to overflow during implementation.

## Clarifications

### Session 2026-11-12

- Q: Students List has no filters today; what happens with "the filters stack" (ticket AC-5)? → A: it became a readable list of cards (later removed, see 2026-11-13)
- Q: Does the Import Polls dialog get its own AC? → A: yes (later removed, see 2026-11-13)
- Q: Is the error dialog of the students import in this ticket? → A: yes (later removed, see 2026-11-13)

### Session 2026-11-13

- Decision by the developer after manual testing: every page already looks right at 375px except the Poll Name of the evaluation process card. The scope is reduced to that card; the spec is rewritten with 2 ACs (AC-1: long Poll Name inside the card, AC-2: desktop table unchanged), and the old AC-1 to AC-9 are replaced. None had a test yet.

- Status after this session: Clarified

## Validation log

### 2026-11-13 – Round 1

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1 | At 375px, open Evaluation Process with a process whose Poll Name is 100 characters without spaces | The whole Poll Name is inside its card, broken over several lines; the card is not wider than the screen; no horizontal scroll | ✅ | Reported by Lucia Becerra, checked in the browser |
| AC-1 | At 375px, check a process with a short Poll Name and the other cards | Cards look as before (labels, status badge, edit / import / view actions) | ✅ | Reported by Lucia Becerra, checked in the browser |
| AC-2 | At 1280px, open Evaluation Process | A table with the same columns as before, no cards, and the Poll Name on one line | ✅ | Reported by Lucia Becerra, checked in the browser |

Approved by Lucia Becerra, 2026-11-13
Verified 2026-11-13: no gaps, no drift, gates green
