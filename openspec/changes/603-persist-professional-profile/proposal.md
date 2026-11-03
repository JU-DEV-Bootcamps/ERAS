# Proposal

**Status:** Approved
**Plan:** Approved

## Why

The professional info section of the account information page shows mock data, and its Position field is duplicated in the general profile edit form, so two places can update the same value. Professionals need their professional profile stored by the backend, with a single owner for Position. Ticket: 603 (branch `603-feature-account-information-profile-professional`). No GitHub issue matching this number was found in ERAS-BE or ERAS-FE.

## What Changes

- Store the professional profile fields (position, faculty, office hours, subjects taught, courses) in the backend, with a new migration, and let the ERAS Professional role read and update their own profile.
- The professional info section loads and saves through the API instead of mock data. It shows the active interventions count read-only, reusing the existing count of the user's unfinalized interventions.
- Position is updated only from the professional info section for professionals. The profile edit form no longer shows Position to professionals, and the general profile update ignores position submitted by professionals.
- For the professional role, the professional info section takes the place of the profile summary panel on the account information page.

**Out of scope:** a new definition or new storage for active interventions; editing another professional's profile; managing professional profiles as an officer or administrator; any change to the page for officers and guests beyond keeping the current summary panel.

## Capabilities

### New Capabilities
- `professional-profile`: storage, read and update of the professional profile, and ownership of the position value.
- `account-information`: which panels the account information page shows per role, and which fields the profile edit form shows.

### Modified Capabilities
- None.

## Impact

- **Submodules:** BE + FE
- **Roles / who can do what:** ERAS Professional gains read and update of their own professional profile. ERAS Administrator, ERAS Student Services Officer and Guest are denied. For the professional role, the profile update no longer changes Position. Other roles keep their current profile edit behavior.
- **API contract:** new endpoints to read and update the caller's own professional profile; the general profile update stops applying position for professionals. BE DTO, FE model and FE service change together (details in design.md).
- **Data / migration:** yes. New storage for the professional profile fields. Position stays on the existing user record.

`design.md` will be required later: the change spans BE and FE, adds a migration, touches authorization and changes an API contract (AGENTS.md §8.2).

## Assumptions

- A1: Position keeps living on the existing user record, so the profile summary and card keep reading it. The professional endpoint writes it, which makes the professional info section its single editor for professionals.
- A2: "Position hidden in edit mode" applies to the professional role only. Other roles have no other section that edits Position, so they keep it in the profile edit form.
- A3: ~~ERAS Administrator passes the role checks of the existing policy.~~ Superseded in session 3: the professional profile is for ERAS Professionals only, and the administrator is denied (AC-20). This departs from AGENTS.md §4.3 and needs an ADR before plan approval (design D3).
- A4: The professional profile stores no active evaluations value. The "Active Interventions" figure is the existing read-only count of interventions the user created that are not finalized. Superseded Q2 (see Clarifications, session 2).
- A5: Faculty is required free text of up to 200 characters; office hours are free text of up to 200 characters that may be empty (session 4). Subjects are a list of text values that may be empty; courses are a list of code and name pairs that may be empty, but each course must have a non-empty code and name (session 5). Not structured (session 1, Q1).
- A6: A professional who never saved a profile sees empty text values and empty lists, not an error.

## Clarifications

### Session 1

- **Q1 — Structure of faculty and office hours** (affects AC-1, AC-3, AC-2): answered *Free text*. Faculty and office hours stay required text up to 200 characters. Structured office hours and a faculty catalog are not in this change.
- **Q2 — Type of active evaluations** (affects AC-1, AC-2, AC-3, AC-17): answered *Whole number*. Must be an integer of 0 or more; never saved means 0. Added AC-17.
- **Direct fix:** AC-1 and AC-3 described subjects and courses as comma-separated text. Changed to a list of subjects and code/name course pairs, matching the frontend model.

### Session 2

- **Decision (user, no question needed):** "Active evaluations" is replaced by "Active interventions", reused from the existing count, with no new implementation and no side effects. Superseded Q2 from session 1. Evidence: the backend already counts the interventions the user created that are not finalized, and the general profile already returns it read-only.
- **Changes:** removed active evaluations from AC-1, AC-2 and AC-3. Removed AC-17 (its number is left unused). Added AC-18 (backend: a professional profile update leaves the count unchanged) and AC-19 (frontend: the count is shown read-only).
- **Deferred:** none.

### Session 3 (spec reopened by the user's decision)

- **Decision (user):** the professional profile is for ERAS Professionals only. The administrator is denied, which overrides the earlier assumption A3. The spec was reopened (`Status: Draft`) and needs a new approval.
- **Changes:** the "Only ERAS Professionals" requirement now denies every role except ERAS Professional, including ERAS Administrator. Added AC-20 (administrator denied, backend). AC-5 and AC-6 are unchanged.
- **Follow-up before plan approval:** an ADR for the professional-only rule, because it departs from AGENTS.md §4.3 and adds a role policy. Not written yet; the user will decide.

### Session 4

- **Q1 — Required fields** (affects AC-4, AC-21): answered *Faculty only*. Position and office hours may be empty. Added AC-21.
- **Q2 — Length limits** (affects AC-22): answered *Position 100, others 200*. Course code is 20 characters. Added the length-limit requirement and AC-22.
- **Direct fix:** none.
- **Deferred:** none.
- **Plan impact:** the design's D7 still lists position and office hours as required and shows the same limits. It must be updated when the plan is redone.

### Session 5 (spec reopened by the user's decision)

- **Decision (user):** a course must have a non-empty code and name; an empty value is rejected with 400 naming the field. Taken from the earlier plan question on course rules, which the user answered "both required".
- **Changes:** added the requirement "Every course has a code and a name" with AC-23 (BE, a course with an empty name is rejected). No other AC changed. A5 now states the course rule.
- **Status:** back to `Draft`, so a human reviews and sets `Approved` again.
- **Deferred:** none.
