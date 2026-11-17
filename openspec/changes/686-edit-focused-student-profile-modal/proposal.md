# Proposal

**Status:** Approved
**Plan:** Approved

## Why

The Students list has two modals that look the same: the student record (opened from "View profile") and the profile summary. The record also mixes three jobs (create, view, edit), so users cannot tell which one to use. Issue: ERAS#686

## What Changes

- The profile summary stays the only read-only modal of a student's profile.
- The student record stops having a viewing mode. The Students list action "View profile" becomes "Edit Student Profile" and opens a modal that is editable straight away, with no extra click.
- Creating a student and editing a student become two separate modals; the creation modal no longer knows about viewing or editing.
- The "Edit Student Profile" action stays visible to every user of the list; a Professional (no student-management permission) gets the modal with the profile fields disabled and no Save, and keeps managing interventions there.
- The requirements of `student-profile-modals` that describe the record "in view mode" are removed or narrowed to the profile summary.

**Out of scope:** changes to the fields of the profile summary, the edit form or the creation form; changes to the backend; renaming the "Profile summary" action; an "Edit" shortcut inside the profile summary; a read-only context header in the edit modal.

## Capabilities

### New Capabilities
- None.

### Modified Capabilities
- `student-profile-modals`: removes the record's view mode, adds the edit-focused modal, its entry point, who can open it and how it saves and discards changes; narrows the "both modals" requirements to the profile summary.

## Impact

- **Submodules:** FE
- **Roles / who can do what:** no change in who can edit: a Professional keeps access to the record, now with the profile fields disabled (as the former view mode) and the interventions management intact (student-interventions AC-22 and AC-30). Administrator and Student Services Officer: no change.
- **API contract:** none
- **Data / migration:** no

## Assumptions

- A1: The name "Edit Student Profile" (action tooltip, modal title) was confirmed by the developer during planning; the issue still asks for product or design sign-off before release.
- A2: Every student, with or without a registered profile, opens the edit modal editable; students without a profile open prefilled with their existing name and email, as today.
- A3: The edit modal keeps the interventions management list below the form, so nothing the record offered is lost.
- A4: Imported students keep their locked fields (names and primary email) in the edit modal, as today.
- A5: Existing tests tagged with `student-profile-modals` ACs that survive here (summary sections, icons, hidden fields, loading) are re-tagged to this change's AC keys (AGENTS.md §5.2).

## Clarifications

### Session 2026-11-16

- Q: Should the profile summary offer an "Edit Student Profile" shortcut for managers? → A: No, the summary stays fully read-only and editing starts only from the list action (AC-2: unchanged; out of scope noted)
- Q: Should the edit modal show a read-only context header above the form? → A: No, only the form and the interventions (AC-3, AC-6: unchanged; out of scope noted)
- Direct fixes: AC-6 made concrete (add control), AC-7 split into request sent and summary value shown afterwards, AC-10 reworded so the "before saving" checks are explicit.
- Status after this session: Clarified

### Session 2026-11-16 (during implementation)

- Q: Hiding the action from a Professional would remove their way to manage interventions (student-interventions AC-22 and AC-30) → A: the Professional keeps the action and gets the modal with the profile fields disabled and no Save (AC-5: changed, AC-17: added). The spec and plan were edited after approval at the developer's request; the reviewer should re-confirm both.
- Status after this session: Approved (unchanged)

## Validation log

### 2026-11-16 – Round 1

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-3 | As Administrator, Students list, press "Edit Student Profile" (pencil icon) on a student with a profile | Modal "Edit Student Profile" opens with fields enabled and stored values filled; no "Edit" button; buttons Cancel and Save | ✅ | |
| AC-4 | Same, on an imported student without a profile | Opens editable with name and email filled (name and email locked), other fields empty | ✅ | |
| AC-5 | As Professional, open the Students list | Rows show "Edit Student Profile" and "Profile summary", no delete | ✅ | |
| AC-17 | As Professional, press "Edit Student Profile" | Fields all disabled, only "Close", interventions list below still has its add control | ✅ | |
| AC-6 | As Administrator, open the edit modal | Interventions list appears below the form; add, edit and delete work | ✅ | |
| AC-7 | Change the mobile number, press Save; then open "Profile summary" of that student | Modal closes, list reloads, success toast; summary shows the new number | ✅ | |
| AC-8 | Change a field, press Cancel (or the X) and confirm the discard; reopen | Modal closes after the confirmation; stored value unchanged | ✅ | |
| AC-9 | Open the edit modal, change nothing, press Cancel | Closes with no confirmation | ✅ | |
| AC-10 | Press "New Student", fill the required fields and a cohort, Save | Title "New Student", cohort selector, no "Edit" button; student is created and appears in the list | ✅ | |
| AC-1, AC-2 | Open "Profile summary" as Administrator | Three sections in order (Personal, Current academic, Interventions); no inputs, only "Close" | ✅ | |
| AC-11, AC-12 | Same summary | Academic fields have icons; no date of birth, gender, city, street, etc. | ✅ | |
| AC-13, AC-14 | In the edit and new modals check the fields; edit only the mobile number and save | Forms keep their fields (date of birth, gender, ID/passport, city, street, level of study); other stored values stay unchanged | ✅ | |
| AC-15, AC-16 | Open the summary and the edit modal for two different students | Each shows the data of the chosen student | ✅ | |
| Errors | Save with a duplicate email, or with the backend stopped | Error toast, modal stays open and Save works again | ✅ | |
| Views | Open the edit modal and the summary on a phone-width screen | Both are full screen and usable | ✅ | |
| Side effects | Delete action, "See more details", search and pagination on the list | Behave as before | ✅ | |

Approved by the developer (Judith), 2026-11-17. The developer also made SCSS adjustments after the round.

Verified 2026-11-17: no gaps, no drift, gates green (SCSS tweaks documented in design.md Styles and task 2.13; the plan was edited after approval, so the reviewer should re-confirm Plan).
