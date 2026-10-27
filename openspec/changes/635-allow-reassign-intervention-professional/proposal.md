# Proposal

**Status:** Approved
**Plan:** Approved

## Why

In the intervention edit modal the Professional field is locked to the current professional, so nobody can reassign an intervention. Every role that works in the Interventions section needs to be able to do it. Issue: ERAS-BE#635 / ERAS-FE#635

## What Changes

- The Professional field in the intervention edit modal becomes editable and lists the professionals that can be assigned.
- ERAS Administrator, ERAS Student Services Officer and ERAS Professional can all change the professional of an intervention they can open.
- A user with no ERAS role (Guest) cannot change the professional, in the UI or through the API.
- The new professional is saved and shown on the intervention right after confirming, and the new professional is added to the assessment's professionals; no other field of the intervention changes.
- An assessment keeps a list of professionals instead of a single one. Reassigning one intervention adds the new professional to that list and leaves the assessment, its students and its other interventions unchanged.
- In the assessment form, Administrator and Student Services Officer edit the full list of professionals. A professional can be removed only if none of the assessment's interventions is assigned to them; otherwise the save is rejected.
- Existing interventions and assessments keep their current professional.

**Out of scope:** recording the reassignment in a history or audit log (handled in another ticket); changing who can see, create or delete interventions; changing the permissions of any other section.

## Capabilities

### New Capabilities
- `intervention-management`: reassigning the professional of an intervention (no main spec exists yet for interventions).

### Modified Capabilities

## Impact

- **Submodules:** BE + FE
- **Roles / who can do what:** ERAS Administrator, ERAS Student Services Officer and ERAS Professional may reassign the professional of an intervention; Guest may not. The API already accepts every ERAS role on the update call, so the rule is made explicit and tested rather than widened.
- **API contract:** the assessment's single professional becomes a list; BE DTO, FE model and FE service change together (details go to design.md).
- **Data / migration:** yes; the assessment stores several professionals and existing single values are carried over.

## Assumptions
- A1: "Access to the Interventions section" means any of the three ERAS roles; Guest has none.
- A2: The professionals offered in the selector are the users that have the ERAS Professional role. The issue does not say otherwise.
- A3: Reassigning is part of editing an intervention, so a Professional can reassign every intervention that role can already edit; no extra ownership rule is added.
- A5: The professional is added to the assessment as part of the same save, for every ERAS role, even though editing an assessment directly is limited to Administrator and Officer.
- A6: When an intervention is reassigned, the previous professional stays in the assessment's list; they leave it only through the assessment form, and only under the rule in AC-17 and AC-18.
- A8: Only the frontend forms require at least one professional; the backend accepts an empty list so assessments that had no professional before the list existed can still be edited.
- A7: Visibility rules that today check the single assigned professional apply to any professional in the list.
- A4: The edit modal keeps its existing rule that the professional is required.

## Clarifications

### Session 2026-10-26 (superseded in part)
- Q: Should the reassignment be recorded in an audit log? -> A: No. It is handled in another ticket, so it is out of scope here (former AC-9 removed; the number is not reused).
- Q: Should reassigning also change the assessment's assigned professional? -> Revised by the reviewer: no replacement. An assessment can have several interventions, so the new professional is added to a list of professionals on the assessment (AC-10 to AC-16).
- Q: In the assessment form, replace the list, edit it, or only add? -> A: Edit the full list. Removing a professional is allowed only if that professional has no interventions in the assessment; otherwise the save is rejected (AC-16 to AC-19).

## Validation log

### 2026-10-27 – Round 1

Migration check (task 1.3): confirmed by the developer on a local PostgreSQL (Up, backfill and Down).

Run the local stack (AGENTS.md section 5.5) with seeded assessments, interventions and one user per role (ERAS Administrator, ERAS Student Services Officer, ERAS Professional) plus a user with no ERAS role.

| Ref | Scenario (steps) | Expected result | Result | Notes |
|---|---|---|---|---|
| AC-1 | As ERAS Administrator open Assessments > Interventions, edit an intervention assigned to Ana, choose Luis in Professional, save | Toast "Intervention updated successfully"; the list shows Luis without reloading | ✅ | |
| AC-2 | Same as AC-1 as ERAS Student Services Officer | Same result | ✅ | |
| AC-3 | Same as AC-1 as ERAS Professional | Same result | ✅ | |
| AC-4 | Call `PUT /api/v1/assessments/{id}/interventions/{id}` with a token that has no ERAS role | 403 Forbidden; the intervention keeps its professional | ✅ | |
| AC-5 | Open the edit modal of any intervention | Professional is enabled, lists the users with the Professional role, the current professional is preselected | ✅ | |
| AC-6 | In the edit modal clear the Professional field and try to save | Required error; no request is sent | ✅ | |
| AC-7 | Reassign an intervention and compare every other field (activity, status, comments, students, attendance, attachments) before and after | Only the professional differs | ✅ | |
| AC-8 | Open assessments and interventions that existed before the change without editing them | Every professional is the same as before | ✅ | |
| AC-10 | Reassign an intervention to a professional not yet in the assessment, then open the assessment from Assessments > Edit | The new professional is in the list next to the previous ones | ✅ | |
| AC-11 | Reassign another intervention of the same assessment to a professional already in the list | The list shows that professional once | ✅ | |
| AC-12 | In an assessment with two interventions, reassign only the first | The second keeps its professional; students and other assessment data are unchanged | ✅ | |
| AC-13 | Log in as the added professional and open Assessments | The assessment appears for them, and the previous professional still sees it | ✅ | |
| AC-14 | Open the assessments that had one professional before the migration | Each shows exactly that professional and is visible to them as before | ✅ | |
| AC-15 | Open the assessment list for an assessment with two professionals and for one with a single professional | Two names are shown together; a single assessment shows just its name | ✅ | |
| AC-16 | As Administrator or Officer edit an assessment, add a professional in the multi-select, save | The assessment has the full list; students and other data are unchanged | ✅ | |
| AC-17 | Edit an assessment and remove a professional who has no intervention in it, save | Saved; only the remaining professionals are listed | ✅ | |
| AC-18 | Edit an assessment and remove a professional who has an intervention in it, save | 409 Conflict naming the professional; the assessment keeps both | ✅ | |
| AC-19 | Repeat AC-18 in the UI | A toast shows the message, the modal stays open and nothing is saved | ✅ | |

Round 1 finding: AC-18 failed. Through Swagger a body with `assignedProfessionals: ["notnot"]` replaced the list and the removed professionals were not blocked with 409. Fix tasks 1.24 and 1.25 added (match the removed professional by sub, email and display name; do not skip when the user is not found).

Also check side effects and errors:

- A Professional who opens Assessments and Interventions sees only what they should (assessments in which they are in the list).
- The create-assessment form: the professionals multi-select is required and saves the list.
- The create-intervention modal still shows the first professional of the assessment, disabled.
- Reassigning together with a change of intervention type (replace-type) also adds the professional to the assessment.
- Backend failing (stop the API) or an expired session while saving shows an error toast and keeps the modal open.
- Narrow viewport: the edit modals and the assessment list remain usable.

Approved by the developer (judithmarg-dev), 2026-10-27: "the goal was achieved". The AC-18 row above keeps the original failure note; the fix (tasks 1.24 and 1.25) was made after it.

Verified 2026-10-27: no gaps, no drift, gates green (BE build, tests and coverage; FE lint, tests, coverage and build; strict validation; ADR-0002 Accepted). Caveat: `dotnet format --verify-no-changes` reports 1,444 findings that already existed on the branch before this change; none were added by it.
