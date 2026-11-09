# Proposal

**Status:** Approved
**Plan:** Approved

## Why

Users cannot see how an assessment changed over time, who changed it or when. An activity history on the assessment details gives that traceability. Issue: ERAS#681

## What Changes

- Record an event automatically when an assessment is created, when a comment is added and when its status changes.
- Show a read-only "Activity history" section in the assessment details, oldest event first, with the description, the date and time (YYYY-MM-DD HH:MM) and the name of the user who acted.
- Assessments created before this release have no recorded events and show an empty-state message.

**Out of scope:** editing or deleting entries; filtering, searching or exporting the history; notifications; backfilling history of existing assessments; event types other than the three recorded here (the issue says "four" but lists three); the activity history of the interventions of the assessment (already covered by change 680).

## Capabilities

### New Capabilities
- `assessment-management`: the activity history of an assessment (record, read and show it).

### Modified Capabilities

## Impact

- **Submodules:** BE + FE
- **Roles / who can do what:** every user with an ERAS role (Administrator, Student Services Officer, Professional) can read the history, as they can already read the assessment; Guest cannot. Nobody can edit or delete entries. Who can create or edit an assessment does not change.
- **API contract:** a new way to read the history of one assessment; BE DTO, FE model and FE service move together (details go to design.md).
- **Data / migration:** yes, the events must be stored (details go to design.md).

## Assumptions
- A1: Today there is no assessment history, so events are new stored data captured from the moment this ships.
- A2: Assessments that exist before this release have no events, not even "Assessment created"; they show "No activity recorded yet." (backfill is out of scope in the issue).
- A3: The user name is the display name of the authenticated user at the time of the event; it does not change if the user is renamed later.
- A4: Status values are shown with their labels "Remitted", "In Progress" and "Finalized"; one status change is one entry showing the previous and the new value.
- A5: The timestamp is shown in the user's local time zone as YYYY-MM-DD HH:MM.
- A6: "Comment added" follows the same rule as the intervention history (change 680): it is recorded when the comments go from empty to text or change to a different text; clearing them records nothing, and the comment text is not stored in the event. Comments given when the assessment is created record no "Comment added" (see Clarifications).
- A7: Saving an assessment without changing its status or comments records no event, and a request that fails (validation error or forbidden status transition) records none.
- A8: Reading the history follows the existing rule of reading one assessment: any user with an ERAS role, with no restriction to assigned professionals.
- A9: The issue's criterion that the section loads "without a visible delay" is a performance goal, not an automated AC; the plan (design.md) decides how the history loads with the details.

## Clarifications

### Session 2026-11-06

- Q: Does creating an assessment that already has comments also record "Comment added"? → A: No, only "Assessment created"; "Comment added" is recorded on later saves (AC-1: made concrete)
- Q: What happens to the events when the assessment is deleted? → A: they are removed with it (AC-19: added; former A10 removed)
- Status after this session: Clarified

## Validation log

### 2026-11-09 – Round 1

Reason: the change adds a BE controller action (`GET api/v1/assessments/{id}/history`) and FE changes (new `assessment-activity-history` component, embedded in `assessment-detail-dialog`).

Run the app with the local stack (`AGENTS.md` §3.4) or the `run` skill, and log in with one account per role (Administrator, Student Services Officer, Professional) plus a Guest account.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1 | Create an assessment with comments; open its details | Activity history shows "Assessment created" with the creation time and your name; no "Comment added" entry | ✅ | |
| AC-2 | On an assessment with no comments, add a comment and save; open details | One "Comment added" entry with time and your name; the comment text is not shown in the history | ✅ | |
| AC-3 | Change the comment text, then clear it and save | One "Comment added" entry for the change; clearing adds nothing | ✅ | |
| AC-4 | Change status Remitted → In Progress, then In Progress → Finalized | Two entries "Status changed: Remitted → In Progress" and "Status changed: In Progress → Finalized", in that order | ✅ | |
| AC-5 | Change only the objective and save | No new entry | ✅ | |
| AC-6 | Try a forbidden status transition (e.g. from Finalized) | Error shown as before; status unchanged; no new entry | ✅ | |
| AC-7 | Open an assessment with several events | Entries listed oldest first | ✅ | |
| AC-8 | Log in as Student Services Officer; open an assessment's details | History is visible and read only | ✅ | |
| AC-9 | Log in as Professional; open an assessment's details | History is visible and read only | ✅ | |
| AC-10 | Log in as Guest (no ERAS role) | Guest cannot reach the history; no event data shown | ✅ | |
| AC-11 | Open two different assessments with events | Each details view shows only its own events | ✅ | |
| AC-12 | Request the history of a non-existent id (e.g. via Swagger, id 999999) | 404 Not Found, no event data | ❌ | The message return a 500 internal error, it is not found correctly but does not show the 404 code. |
| AC-13 | Open an assessment created before this release | Empty state "No activity recorded yet." | ✅ | |
| AC-14 | Open an assessment with events created by two users | Section lists description, time as YYYY-MM-DD HH:MM and user name, oldest first | ✅ | |
| AC-15 | Open details as Administrator; look for any edit or delete control on entries | Entries are plain text; no edit or delete action | ✅ | |
| AC-16 | Open an assessment whose only event is "Assessment created" | One entry only; no empty rows or error | ✅ | |
| AC-17 | Open an assessment with no events | Message "No activity recorded yet."; rest of the details shown as usual | ✅ | |
| AC-18 | Open details of an assessment whose user name contains `<b>Ana</b>` (set up in a test account) | Text shown literally; no markup rendered, no alert | ✅ | |
| AC-19 | Delete a Remitted assessment that has events (Administrator) | Assessment gone; its events are gone too; other assessments' history unchanged | ✅ | Confirm in the DB if the UI cannot show it | 

Outcome Round 1: 18 of 19 rows ✅; AC-12 ❌ (500 instead of 404). Tasks 1.19 (reopened), 1.20 and 1.21 added in `tasks.md`; back to `sdd-implement`. No FE change needed. A new round follows after the fix.

Side effects to check in Round 1:
- Assessment list, create, edit and delete work as before for every role.
- Intervention activity history (change 680) still shows and works in the intervention panel.
- The details dialog opens for an assessment with no id (no history section, no console error).
- Details still usable when the history request fails (e.g. backend stopped).
- Different views: narrow (phone) width, and any language the app offers.

### 2026-11-09 – Round 2

Reason: re-check after the fix of AC-12 (task 1.21: the history query throws `NotFoundException` instead of `KeyNotFoundException`, so the unknown-assessment case answers 404). Rows AC-1 to AC-6, AC-8 to AC-10 and AC-14 to AC-19 were ✅ in Round 1 and their code path did not change; they are not repeated here. Restart the API first so it runs the fixed code, then run the stack as in Round 1.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-12 | Request the history of a non-existent id (e.g. via Swagger, `GET api/v1/assessments/999999/history`) | 404 Not Found with a friendly message; no event data; no 500 | ✅ | Round 1 failure was 500 |
| AC-7 | Open an assessment with several events | Entries still listed oldest first | ✅ | Handler touched by the fix |
| AC-11 | Open two different assessments with events | Each details view still shows only its own events | ✅ | Handler touched by the fix |
| AC-13 | Open an assessment created before this release | Still shows "No activity recorded yet." with status 200 | ✅ | Handler touched by the fix |

Side effects to check in Round 2:
- An existing assessment (not deleted) still opens its details without any error; the history section loads.
- The intervention activity history (change 680) still shows in the intervention panel.
- Create, edit and delete of an assessment still work as before for the Administrator.

Approved by judithmarg-dev, 2026-11-09 (goal achieved, no side effects, no open errors; the developer wrote the date as 2023-11-09, taken as a typo for today).

Verified 2026-11-09: no gaps, no drift, gates green (design.md aligned with the AC-12 fix: `NotFoundException`, the Api-level AC-12 test and the follow-up on change 680's intervention history).
