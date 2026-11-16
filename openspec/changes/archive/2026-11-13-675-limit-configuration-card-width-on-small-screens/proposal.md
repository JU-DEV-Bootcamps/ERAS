# Proposal

**Status:** Approved
**Plan:** Approved

## Why

On the Settings page, between 376px and 669px wide, each configuration card stretches across the whole screen, which looks oversized for the little content a card holds. The rest of the responsive view of Settings already works and must not change. Issue: ERAS#675

## What Changes

- On a screen narrower than 670px, a configuration card is never wider than 350px and is aligned to the left of its row, starting where the cards start today (no padding of the page or of the card area changes).
- On a screen 375px wide or narrower the card is already narrower than 350px because of the page paddings, so it keeps filling the space available to it and nothing changes there.
- On a screen 670px wide or wider, the configuration cards keep the layout they have today.

**Out of scope:** the dialogs to create, edit and delete a configuration, the route redirect for roles without access, the "Available Service Providers" cards and any other responsive behavior of Settings (all work as expected today).

## Capabilities

### New Capabilities
- `settings-mobile-view`: how the configuration cards of the Settings page adapt to the screen width.

### Modified Capabilities

## Impact

- **Submodules:** FE
- **Roles / who can do what:** no change
- **API contract:** none
- **Data / migration:** no

## Assumptions

- A1: The cap is 350px, the width the card has on desktop today (named in issue #675), so a card looks the same on a 500px screen as on a desktop.
- A2: "Narrower than 670px" is an exclusive bound: a 670px screen keeps today's layout.
- A3: The configuration cards sit in a single column in the whole range below 670px, as they do today, so only the card width and alignment change and not the number of columns.

## Clarifications

### Session 2026-11-12

- Q: How to treat screens of 375px or less, where the card is already under 350px? → A: One cap rule for every screen narrower than 670px; at 375px the card just fills the available space (AC-1, AC-2: changed)
- Q: Where does a capped card sit in its row between 376px and 669px? → A: Aligned to the left, in line with the "Configurations" title (AC-1: changed)

- Status after this session: Clarified

### Session 2026-11-12 (reopened from Approved by the user while planning)

- Q: AC-1 asks the card to align with the "Configurations" title, but today the cards start 16px to its right because of the card area padding. Which one? → A: Correct AC-1: the card starts where the cards start today and no padding changes (AC-1: changed)

- Status after this session: Clarified

## Validation log

### 2026-11-12 – Round 1

Scope: FE change (`configuration-card.component.scss`), so validation is required. Manual checklist for the developer. Run the app with the local stack of `AGENTS.md` §3.4 (or the `run` skill), sign in as each role below, open the Settings page (`/cosmic-latte`) with at least two configurations, and use the browser's responsive mode to set each width.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1 | Sign in as "ERAS Administrator" at 500px. Open Settings. Measure each configuration card with the browser inspector. | Each card is 350px wide and starts at the same left edge as the card area, with free space on its right. | ✅ | |
| AC-1 | Same as above, at 669px and at 670px. | At 669px the card is still capped at 350px. At 670px the layout matches `develop`. | ✅ | |
| AC-2 | Sign in as "ERAS Administrator" at 375px. Open Settings. | Each card fills the space available to it, which is under 350px. The cards are stacked one above the other, with no horizontal scroll. | ✅ | |
| AC-3 | Sign in as "ERAS Administrator" at 1280px. Open Settings. | The cards look exactly as in `develop` at this width: grid columns, no cap, no shift. | ✅ | |
| Side effects | Sign in as "ERAS Administrator" at 500px. Use the edit and delete buttons on a card, the "Test Connection" button, and the "+" button. | The dialogs open and their buttons are reachable. Test Connection updates the status and the "last test" time. Edit and delete behave as before. | ✅ | |
| Side effects | Compare the "Available Service Providers" cards and the page header at 500px and at 1280px with `develop`. | No change in those elements. | ✅ | |
| Roles | Sign in as "ERAS Student Services Officer" at 500px and open Settings. | The cards follow the same width rule as for the Administrator (AC-1). | ✅ | |
| Roles | Sign in as "ERAS Professional" or as a Guest at 500px and try to open `/cosmic-latte`. | The redirect works as in `develop` (unchanged by this change). | ✅ | |
| Errors | Make the health check fail (stop the backend or the Cosmic Latte service), then reload Settings at 500px. | The card shows the failed status as before, and its width does not change. | ✅ | |
| Errors | Sign in with no configurations at 500px. | The empty state is as in `develop`, with no layout error. | ✅ | |
| Different views | With Settings open, resize the window across 669px / 670px. | The card width updates without a reload. | ✅ | |

Approved by judithmarg-dev, 2026-11-12 (all 11 rows ✅; goal achieved, no side effects).

Verified 2026-11-12: no gaps, no drift, gates green
