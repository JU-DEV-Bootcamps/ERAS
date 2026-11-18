# Proposal

**Status:** Approved
**Plan:** Approved

## Why

On a phone, Account & Information and User Manuals are not guaranteed to fit: the profile and professional info keep two-column grids, the courses table of a professional is a plain table, the cards have 32px of padding, and User Manuals has no mobile rule at all. This is one of the section sub-tickets of the mobile epic ERAS#668. Issue: ERAS#676 ("Account & Information and User Manuals")

## What Changes

- On a mobile screen (narrower than 768px) Account & Information shows the profile card and the information sections stacked in one column, with every value readable and inside its card, even a long email or a long course name, and no horizontal scroll of the page.
- On a mobile screen User Manuals shows each manual inside the width of the screen, even with a long title.
- Screens of 768px and wider keep today's Account & Information and User Manuals.

**Out of scope:** the edit forms of the profile and of the professional info, which already fit at 375px (see the measurement of 2026-11-17), the Home page and the other sections of epic ERAS#668, tablets, any change to who can see or edit a profile or download a manual, any back end change, any change to the manuals themselves or to how they are managed, and a manual viewer inside the page (User Manuals lists manuals and downloads them; it has no viewer).

## Capabilities

### New Capabilities
- `account-information-mobile-view`: how Account & Information (the profile card, the professional info and the summary,) adapts to a mobile screen.
- `user-manuals-mobile-view`: how the list of manuals of User Manuals adapts to a mobile screen.

### Modified Capabilities

## Impact

- **Submodules:** FE
- **Roles / who can do what:** no change. Every role that can open these pages today sees the same content on mobile.
- **API contract:** none
- **Data / migration:** no

## Assumptions

- A1: "Mobile" is a screen narrower than 768px, the same threshold as `mobile-layout`, `students-mobile-view` and `home-mobile-view`. The issue's 375px is the test width, and 1280px is the desktop width.
- A2: The issue says "the manuals list and the viewer". User Manuals has no viewer: each manual is a row with a Download button that downloads the file. So "viewer" means that row and button.
- A3: The problems were first found by reading the code and then measured at 375px on 2026-11-17 (see the measurement log); the ACs with no real problem were removed.
- A4: The professional's courses table keeps its two columns (Course Code and Course Name) and stays a table; on mobile each course is readable inside its card without making the page scroll sideways (settled in the clarification of 2026-11-17).
- A5: The summary panel that an officer or an administrator sees instead of the professional info already has a 700px rule; it is checked at 375px with the rest, and an AC is added with `/opsx:update` only if it shows a problem (settled in the clarification of 2026-11-17).

## Clarifications

### Session 2026-11-17

- Q: Measure at 375px before approving the spec, or approve first and measure in the manual validation? -> A: measure before approving; the app is run at 375px and 1280px, the ACs with no real problem are removed, and if none fails the ticket closes with the screenshots only (no AC changed; A3 stays)
- Q: On mobile, does the courses table of a professional stay a table or become cards? -> A: it stays a table that fits its card (AC-2 unchanged; A4 settled)
- Q: Does the summary panel of an officer or an administrator get its own AC? -> A: no, it is only checked at 375px and gets an AC only if it fails (A5 settled)
- Status after this session: Clarified
- Status set to Approved on 2026-11-17 at Lucia Becerra's explicit request in chat.
- AC-7 (Download button tap area) removed on 2026-11-17 at Lucia Becerra's request in chat, after the plan step found the tap area is already 48 by 48.
- Plan set to Approved on 2026-11-17 at Lucia Becerra's explicit request in chat.

## Measurement log

### 2026-11-17, 375px, local app (professional and administrator sessions)

- AC-1 confirmed: with a 60 character email without spaces and 40 character values, the email and the Employee ID and Phone values go past the card (email to 464px on a 375px screen).
- AC-2 confirmed: with a course name of 80 characters without spaces the courses table is 1141px wide on a 375px screen and nothing breaks.
- Edit forms: the profile edit form (administrator) and the professional info edit form (professional) fit at 375px, no overflow, Cancel and Save inside the screen with 40px height. The issue's AC-2 about the edit form is met today, so AC-3 and AC-4 were removed (their numbers are not reused).
- AC-6 confirmed: with a 100 character title without spaces the title pushes the Download button out of the row (to 1524px on a 375px screen).
- AC-7 removed: the Download button is 40 by 40 pixels to the eye, but its Material tap area is 48 by 48 already (measured on 2026-11-17 in the plan step), so there is no problem to fix; its number is not reused.
- The user manuals list was measured with a simulated API answer, because the local back end returned 500 for the manuals folder.

## Validation log

### 2026-11-18 – Round 1

How to run: local stack (AGENTS.md §3.4) with the back end pointing to the repository `manuals/` folder (`UserManuals__Path`, see `manuals/README.md`); the app at http://localhost:4200 with the browser at 375px wide, then at 1280px. For the long values: edit Employee ID, Phone and About in the profile form (an email of 60 characters without spaces needs a test user), and for the manual title use a local, uncommitted edit of `manuals/manifest.json` (100 characters without spaces).

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1 | At 375px, as any role, open Account & Information with a long Employee ID, Phone and a long email | Values one per row, every value broken inside the profile card, no horizontal scroll | | |
| AC-2 | At 375px, as an `ERAS Professional`, open Account & Information with a course whose name is 80 characters without spaces | Info sections in one column, the course code and name inside the card, no horizontal scroll | | |
| AC-5 | At 1280px, as an `ERAS Professional`, open Account & Information | Profile card and professional info in two columns, no value broken, same as before | | |
| AC-6 | At 375px, open User Manuals with a 100 character title without spaces | The title breaks over several lines and the Download button is inside the row; Download still works | | |
| AC-8 | At 1280px, open User Manuals | Row with icon, title, details and Download button, same as before | | |
| Side effects | `ERAS Administrator` and `ERAS Student Services Officer` open Account & Information at 375px (summary panel); edit and save the profile and the professional info at 375px | Pages still work, nothing overflows, saving still works | | |
| Errors | User Manuals with the back end returning an error or no manuals | The error or empty message shows inside the screen at 375px | | |

Approved by Lucia Becerra, 2026-11-18 (the rows of the table were validated by the developer in the app; she approved in chat without marking each row).

Verified 2026-11-18: no gaps, no drift, gates green
