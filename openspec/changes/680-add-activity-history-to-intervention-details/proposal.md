# Proposal

**Status:** Approved
**Plan:** Approved

## Why

Users cannot see how an intervention changed over time, who changed it or when. An activity history on the intervention details gives that traceability. Issue: ERAS#680

## What Changes

- Record an event automatically when an intervention is created, when a comment is added, when its status changes and when its risk level or end risk level changes.
- Show a read-only "Activity history" section in the intervention details, oldest event first, with the description, the date and time (YYYY-MM-DD HH:MM) and the name of the user who acted.
- Interventions created before this release have no recorded events and show an empty-state message.

**Out of scope:** editing or deleting entries; filtering, searching or exporting the history; notifications; backfilling history of existing interventions; priority events (an intervention has no priority today; it moves to a separate change); the bulk replace of all interventions of an assessment (not used by the frontend today; its effect on the history goes to a follow-up); event types other than the four recorded here.

## Capabilities

### New Capabilities
### Modified Capabilities
- `intervention-management`: adds the activity history of an intervention (new requirements; no existing requirement changes).

## Impact

- **Submodules:** BE + FE
- **Roles / who can do what:** every user with an ERAS role (Administrator, Student Services Officer, Professional) can read the history; Guest cannot. Nobody can edit or delete entries.
- **API contract:** a new way to read the history of one intervention; BE DTO, FE model and FE service move together (details go to design.md).
- **Data / migration:** yes, the events must be stored (details go to design.md).

## Assumptions
- A1: Today there is no intervention history, so events are new stored data captured from the moment this ships.
- A2: Interventions that exist before this release have no events, not even "Intervention created"; they show the message "No activity recorded yet." (backfill is out of scope in the issue).
- A4: The user name is the display name of the authenticated user at the time of the event; it does not change if the user is renamed later.
- A5: Status values are shown with their labels "Remitted", "In Progress" and "Finalized", and one status change is one entry showing the previous and the new value.
- A6: The timestamp is shown in the user's local time zone in the format YYYY-MM-DD HH:MM.
- A7: Saving an intervention without changing the tracked data records no event, and a request that fails (validation error or forbidden status transition) records none.
- A8: The issue's criterion that the section loads "without a visible delay" is a performance goal, not an automated AC; the plan (design.md) decides how the history loads with the details.
- A10: An intervention has two editable risk levels: the risk level (`riskLevelName`) and the end risk level (`endRiskLevelName`); the API accepts both on every save. The frontend only lets the user save an end risk level when the status is Finalized, but that is a frontend rule: the history records any change that reaches the API. Each change is one entry showing the previous and the new value, with the labels "Low", "Medium" and "High"; an empty previous or new value is shown as "None".
- A11: Changing the type of an intervention (AC-20) records the risk level events too when that save changes either value compared with the old intervention; the existing events are kept as AC-20 states.
- A12: The two risk levels have different descriptions so the entry says which one changed: "Risk level changed: [previous] → [new]" and "End risk level changed: [previous] → [new]".
- A9: Reading the history follows the existing rule of the intervention endpoints: any user with an ERAS role.

## Clarifications

### Session 2026-11-05

- Q: What does "Priority set to [value]" mean, since interventions have no priority? → A: Priority is left out of this release and moves to a separate change (AC-2: removed)
- Q: When is "Comment added" recorded, given one free-text comments field? → A: when the text goes from empty to non-empty or changes to a different non-empty text; clearing records nothing (AC-3: kept, AC-19: added)
- Status after this session: Clarified

### Session 2026-11-06

- Q: What happens to the history when the type of an intervention is changed (it is recreated with a new id)? → A: the history is kept on the recreated intervention (AC-20: added). The spec was reopened by the user from Approved for this; it needs approval again.
- Status after this session: Clarified

### Session 2026-11-09

- Q: Which acceptance criteria are new? → A: "Status changed: [previous] → [new]" already is AC-4, so only the risk level events are new (AC-21 and AC-22: added; both risk levels are editable, see A10). Supported event types of the release: Intervention created, Comment added, Status changed, Risk level changes. The spec was reopened by the user from Approved; the spec and the plan need approval again.
- Status after this session: Draft

### Session 2026-11-09 (risk levels)

- Q: What text does the end risk level event use? → A: "End risk level changed: [previous] → [new]", and "Risk level changed: [previous] → [new]" for the risk level (A12 settled; AC-22)
- Q: What if one save changes both risk levels? → A: two separate entries, one per field, with the same user and time (AC-23: added)
- Status after this session: Clarified (the spec and the plan still need human approval)

## Validation log

### 2026-11-06 – Round 1

Scope: new controller action `GET api/v1/assessments/{id}/interventions/{interventionId}/history` (BE) and the
"Activity history" section in the intervention details panel (FE). Also affected: creating, editing the status or comments,
and changing the type of an intervention, because they now write events.

How to run: start the local stack per `AGENTS.md` §3.4 (or the `run` skill) with the new migration applied, and sign in with one
user per ERAS role. Use an intervention created during this round for the event rows, since interventions from before this release have no events.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1 | Create a new intervention as ERAS Professional "Ana Pérez". Open its details. | Section shows "Intervention created", the time as YYYY-MM-DD HH:MM and "Ana Pérez". | ❌ | The new section "Activity history" is not displayed because the data.assessmentId do not exist, it is undefined. |
| AC-3 | Edit the intervention and add comments "First session done". Save. Reopen details. | One new "Comment added" entry with the time and the user name. The comment text is not shown in the entry. | ❌ |  The new section "Activity history" is not displayed because the data.assessmentId do not exist, so the updates are not visible. |
| AC-19 | Change the comments to "Second session done", then clear them and save. | Changing adds one "Comment added". Clearing adds nothing. | ❌ | Same above. |
| AC-4 | Change the status Remitted → In Progress, then → Finalized. | Entries "Status changed: Remitted → In Progress" and "Status changed: In Progress → Finalized", in that order. | ❌ | Same above. |
| AC-5 | Save the intervention changing only the activity name, keeping status and comments. | No new entry; the activity name is updated. | ✅ | |
| AC-6 | Try an invalid status transition (for example from Finalized back to In Progress). | The app shows the existing rejection and the status does not change. No new entry appears. | ✅ | |
| AC-20 | Change the intervention type (individual ↔ group) on an intervention that has entries. | The intervention keeps its entries, in the same order, users and times. No new "Intervention created". | ❌ |  The new section "Activity history" is not displayed because the data.assessmentId do not exist, so the updates are not visible.|
| AC-7 | With several events, open the details. | Entries are listed oldest first. | ❌ | Same above. |
| AC-8 | Sign in as ERAS Student Services Officer, open the details of an intervention. Also call the history endpoint. | Section and endpoint (200) show the events. | ✅ | If I verify in swagger only it works correctly but if I try to do with front the assessmentId is undefined. |
| AC-9 | Sign in as ERAS Professional, open the details and call the endpoint. | Section and endpoint (200) show the events. | ✅ | If I verify in swagger only it works correctly but if I try to do with front the assessmentId is undefined. |
| AC-10 | Call the history endpoint without an ERAS role (Guest, or no token). | 403 Forbidden, no event data. | ✅ | |
| AC-11 | Create two interventions in the same assessment; add events only to the first. Open the details of the second. | The second shows only its own entries. | ✅ | |
| AC-12 | Call the history endpoint for an intervention id that is not in the assessment (for example 999999). | 404 Not Found. | ❌ | It responds 500 error internal |
| AC-13 | Open the details of an intervention created before this release. | Section shows "No activity recorded yet." and the rest of the panel loads. | ❌ | Any message shows that message only it display the another sections as before. |
| AC-14 | Open the details of an intervention with two or more events. | Each entry shows description, YYYY-MM-DD HH:MM time and user name, oldest first. | ❌ | Due to assessmentId in data is undefined, nothing is showed. |
| AC-15 | Open the details as ERAS Administrator. | Entries are plain text. There is no edit or delete action. | ❌ | Same above. |
| AC-16 | Open the details of an intervention with only "Intervention created". | One entry only, no empty rows. | ❌ | Same above. |
| AC-17 | Open the details of an intervention without events. | "No activity recorded yet." is shown. | ❌ | Same above. |
| AC-18 | Save a user name with markup (for example by renaming the test user to `<b>Ana</b>`), then open the details. | The name is shown literally, with no bold text and no script running. | n.a. | Keycloak does not allow to use special characters in name. |

**Side effects (not AC-specific):**
- Existing intervention list, details, edit and attachments still work for every role.
- Upload and remove an attachment on an intervention with events; the events are unchanged.
- Changing the type of an intervention keeps its attachments and the other fields (the existing rule for reassigning the professional still holds).
- Errors: stop the backend and open the details. The panel must still open and show no history section content and no error text.
- Views: check the details panel at a narrow (phone) width and in Spanish or English if the app offers both.

**Finding (reported by the developer, 2026-11-06):** the "Activity history" section does not appear, so every FE row above could not be validated; the BE was checked by the developer and works. Cause: the FE `InterventionModel` declares `assessmentId`, but the BE `InterventionDto` does not return it, so `data.assessmentId` is `undefined` at runtime and the details panel never renders the section. The unit specs passed because they gave the inputs straight to the history component; no test covered the history inside the details panel.

Round 1 status: blocked by the finding above. The rows are not validated; Round 2 repeats them after the fix.

### 2026-11-06 – Round 2

After the fix of the Round 1 finding (the details panel now receives the assessment id from the list; tasks 2.5 and 2.6), the developer repeated the checklist of Round 1 in the running app and reported that everything works: goal achieved, no side effects, no open errors. Row results were not itemised in this log; the developer's report covers every row of Round 1.

Approved by Judith Paco, 2026-11-06


### 2026-11-06 – Round 3

Scope: visual only (FE). Each entry of the "Activity history" now has a bullet of colour `--primary-700` (tasks 2.7 and 2.8).

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-14 | Open the details of an intervention with several events. | Each entry shows a bullet of colour `#117473` aligned with its description; description, time and user are as before. | ⬜ | |
| AC-16 | Open the details of an intervention with only "Intervention created". | One entry with its bullet. | ⬜ | |
| AC-17 | Open the details of an intervention without events. | Only "No activity recorded yet."; no bullet. | ⬜ | |

The `Verified` line above predates this change; `/sdd-verify` refreshes it after this round.

The developer checked the bullets in the running app and reported that they look as expected and work well.

Approved by Judith Paco, 2026-11-06


### 2026-11-09 – Round 4

Scope: risk level events (AC-21, AC-22, AC-23) added in this round, plus the type-change rule (AC-20) when it also changes a risk level. The BE handlers, the mapper and the FE event type union changed; the controller action is unchanged since Round 2. The "Activity history" section is the same component as before, so AC-14 to AC-18 are re-checked only as side effects.

How to run: start the local stack per `AGENTS.md` §3.4 (or the `run` skill) with the new migration `AddRiskLevelToInterventionActivities` applied. Sign in as ERAS Professional (or Student Services Officer) for the edit steps; use an intervention created during this round.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-21 | Open an intervention with risk level Medium. Edit it, set the risk level to High, save. Reopen details. Save again without changing the risk level. | One new entry "Risk level changed: Medium → High" with the time (YYYY-MM-DD HH:MM) and the user name. The second save adds nothing. | ✅ | |
| AC-22 | Open a Finalized intervention with no end risk level. Edit it, set the end risk level to Low, save. Reopen details. | One new entry "End risk level changed: None → Low" with the time and the user name. | ✅ | The end risk level can only be set in the UI when the status is Finalized. |
| AC-23 | On a Finalized intervention, change the risk level to High and the end risk level to Low in the same save. Reopen details. | Two new entries, "Risk level changed: … → High" then "End risk level changed: None → Low", with the same time and user name. No combined entry. | ✅ | |
| AC-20 | Change the type of an intervention (individual ↔ group) and change its risk level in the same save. Reopen details. | Existing entries are kept in the same order, users and times. The risk level entry is added. No new "Intervention created". | ✅ | Covers A11. |
| AC-5 | Save an intervention changing only the activity name, keeping risk levels, status and comments. | No new entry. | ✅ | Regression for the new risk level comparison. |
| AC-6 | Try an invalid status transition (for example from Finalized back to In Progress). | Rejected as before. No new entry, not even a risk level entry. | ✅ | |
| AC-14 | Open the details of an intervention with the new risk level entries among others. | Each entry shows its description, the time as YYYY-MM-DD HH:MM and the user name, oldest first, with its bullet. | ✅ | Side effect check for the new description text. |
| AC-16 | Open the details of an intervention with a risk level entry only. | Only that entry, no empty rows. | ✅ | |

**Side effects (not AC-specific):**
- Existing list, details, edit, attachments and status changes still work for every role after the migration.
- Save an intervention whose risk levels were never set (empty values): the labels show "None" and nothing breaks.
- Administrator sees the new entries as plain text with no edit or delete action (AC-15).
- Guest still gets 403 on the history endpoint (AC-10).
- Errors: stop the backend and open the details. The panel must still open and show no history content and no error text.
- Views: check the details panel at a narrow (phone) width.

The developer ran the Round 4 checklist in the running app and reported: goal achieved, no side effects, no open errors. Row results were not itemised in this log; the developer's report covers every row above.

Approved by Judith Paco, 2026-11-09

Verified 2026-11-09: no gaps, no drift, gates green (after Round 4)
