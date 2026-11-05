# Proposal

**Status:** Approved
**Plan:** Approved

## Why

On a phone the Students page is hard to use: the side menu stays open and takes most of the screen, so the content is squeezed and its text wraps word by word. The student modals can be opened, but only some of their records can be read and used comfortably. Issue: ERAS#659 ("[Enhancement] Students > Students Profile: Mobile view for students section improvement")

## What Changes

- On a mobile screen (narrower than 768px) the side menu is hidden by default and opens over the content from a menu button in the page header; on larger screens it behaves as it does today.
- On a mobile screen the page header is compact: menu button, page title and user menu.
- On a mobile screen the Students list stacks its search and action buttons, and its pagination is reduced to what fits.
- On a mobile screen the student profile summary, the student details, the student record and the new student form fill the screen.
- On a mobile screen the current courses of a student profile are listed as stacked entries instead of a wide table.

**Out of scope:** screens 768px wide or wider (tablets, and phones held in landscape), the import dialogs, the intervention entry dialogs, the charts and tables inside the student details modal (only its header is adapted, AC-16), the pagination of lists other than Students, and redesigning other pages (they only gain the hidden side menu and the compact header).

## Capabilities

### New Capabilities
- `mobile-layout`: how the application shell (side menu and page header) adapts to a mobile screen.
- `students-mobile-view`: how the Students list and the student modals adapt to a mobile screen.

### Modified Capabilities

## Impact

- **Submodules:** FE
- **Roles / who can do what:** no change.
- **API contract:** none
- **Data / migration:** no

## Assumptions

- A2: Both side menu designs (the legacy one and the new one selected by the feature flag) behave the same on mobile.
- A3: On mobile the header hides the user's name and role text and the notifications icon, because they do not fit next to the title; the user menu keeps showing the name and role.
- A5: The side menu closes by itself when the user picks an entry that opens a page. Entries that only expand a submenu keep it open.

## Clarifications

### Session 2026-11-04

- Q: Below which width is the side menu hidden and the header compacted? → A: below 768px, the same threshold as the list cards; phones in landscape and tablets keep today's layout (AC-1 to AC-6: confirmed, text unchanged; former A1 settled).
- Q: Does the reduced pagination apply to every list or only to Students? → A: only the Students list; every other list keeps its full pagination (AC-9: changed; former A4 removed).
- Q: Is the student details modal ("See more details") included? → A: yes, it opens full screen on mobile; its inner content is not redesigned (AC-13: added; AC-10 and the requirement text now name it).
- Fixed from evidence: the requirement named the student record and the new student form but only the profile summary had an AC (AC-14, AC-15: added); AC-5 and AC-6 assumed a header with name, role and a notifications icon, while the legacy header shows only a title and the user menu, so they now refer to what each header shows today (AC-5, AC-6: changed).
- Status after this session: Clarified

### Session 2026-11-04 (update after manual validation)

- Q: The details header (name, email, UUID and the three buttons) is cut off at 375px; adapt it? → A: yes: the data stacked one under the other and the three buttons in one row below (AC-16: added; the charts and tables inside the modal stay out of scope). `**Status:**` and `**Plan:**` need the reviewer again.

## Validation log

### 2026-11-04 – Round 1

Run the app with the local stack (AGENTS.md §3.4) or `npm start` in `ERAS-FE/`, sign in as `ERAS Administrator`, and open DevTools device mode at 375×812 (then 1280×800 for the desktop rows).

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1 | At 375px open any page (Home, Students, a report) | Side menu is not visible; content uses the full width, no left gap | | |
| AC-2 | At 375px press the menu button in the header | Menu slides in over the content; content does not move | | |
| AC-3 | With the menu open, pick "Students" | Students page loads and the menu closes | | |
| AC-4 | With the menu open, tap the dark area outside it | Menu closes; page unchanged | | |
| AC-5 | At 375px look at the header (new header with the `home` flag on, and legacy header with it off) | Menu button, page title and user menu only; no name, role or bell | | |
| AC-6 | At 1280px open Students | Menu beside the content (open), no menu button; header keeps name, role and bell | | |
| AC-7 | At 375px open Students | Search field sits above the action buttons, buttons stacked at full width | | |
| AC-8 | At 375px look at a student card | Every column and the action buttons are visible, nothing cut off | | |
| AC-9 | At 375px scroll to the paginator, then at 1280px | Compact on mobile (no page-size selector, no first/last); full pagination on desktop | | |
| AC-10 | At 375px open "See more details", the student record and the profile summary | Each opens full screen with no horizontal scroll; content fully reachable by scrolling and closable | | |
| AC-13 | At 375px open the student details modal ("See more details") | Full screen; inner content readable (layout is not redesigned) | | |
| AC-14 | At 375px open the student record | Full screen; form/fields usable | | |
| AC-15 | At 375px press the new student button | Form opens full screen; can be filled and saved/cancelled | | |
| AC-11 | At 1280px open the same four modals | Same size and look as before this change | | |
| AC-12 | At 375px open a student's profile summary with current courses | Each course is stacked (name, group, section), no horizontal scroll; at 1280px it stays a table | | |
| Side effects | At 375px and 1280px open Home, a report, Assessments and Lists | Pages render as before; menu hidden on mobile and beside content on desktop; other lists keep full pagination | | |
| Roles | Repeat the Students page as `ERAS Student Services Officer` and `ERAS Professional` | Same layout and menu behavior; permissions unchanged | | |
| Errors | At 375px open Students with the backend down, then with no students | Error/empty state fits the screen; menu button still works | | |
| Different views | Resize from 1280px to 375px and back with the menu open; rotate 375×812 to 812×375 | Menu mode follows the width (no stuck backdrop); landscape ≥768px keeps the desktop layout | | |

Approved by Lucia Becerra, 2026-11-04 (reported "Todo OK" in chat after the manual check at 375px; the per-row results were not filled in).

Verified 2026-11-04: no gaps, no drift, gates green

Post-validation tweak 2026-11-04 (requested by Lucia): on mobile Import and Export sit side by side at their natural width and New Student is on the row below, to use less space. AC-7 text is unchanged; its test and an extra untagged layout test pass with the 154 students-list specs.

Post-validation change 2026-11-04 (requested by Lucia): AC-16 added for the header of the new student details modal (data stacked, the three buttons in one row). Test-first; lint, the full FE suite and the build pass. Needs a manual look at 375px and the reviewer for Status and Plan again; run /sdd-verify again before archiving.

Status and Plan set to Approved on 2026-11-05 at Lucia Becerra's explicit request in chat.
Verified 2026-11-05: no gaps, no drift, gates green (AC-1 to AC-16)
