# Proposal

**Status:** Approved
**Plan:** Approved

## Why

Professionals have nowhere to record the risks they detect in a student or the support the student has received, so other staff cannot see the student's current situation in the profile. Issue: ERAS#643 ("[Feature] Allow Professionals to add new data in Interventions (Risks Identified and Support Received) for Student Profile")

## What Changes

- A student has a list of intervention entries of two kinds: **risk identified** (type: Academic, Financial, Attendance or Personal) and **support received** (type: Tutoring, Advising, Financial aid or Referral).
- Each entry has a type chosen from the fixed list of its kind (a type of the other kind is not valid), a free-text description, a date, and the user who created it with the time it was created. A student can have any number of entries of each kind.
- An `ERAS Professional` can add, edit and delete the entries they created. An `ERAS Administrator` can also add entries and edit or delete entries of any user. Deleting asks for confirmation and is a soft delete: the entry leaves every list and stays stored with who deleted it and when. Type, description and date are required and validated before saving, in the form and again in the API, with clear messages.
- Entries are listed newest first. Every user with an ERAS role can view them; users who are neither a professional nor an administrator cannot change them.
- The student record (the modal opened from the Students list where the student's data is viewed and edited) has an Interventions section where the entries are managed. The read-only student profile summary shows risks and support as two separate lists, each with an empty-state message and no actions, reading the same entries; it stops showing the former free-text lists of the profile.
- An `ERAS Professional` can open the Students section, which lists only the students of the assessments they are assigned to, and read those students' profiles to reach that section. Other students are denied to them, and everything else about students stays read only: no create, import, export, edit of personal data or delete, in the interface and in the API.
- Saving an entry never changes any other data of the student.

**Out of scope:** removing, migrating or importing the former free-text lists of identified risks and support that the profile already stores (they stay untouched and are no longer shown; what to do with them is a decision with stakeholders); the assessment interventions managed in the Assessments section (capability `intervention-management`), which are unrelated to these entries; importing risk or support data from another source (none is known to exist; to be confirmed with stakeholders); editing the choice lists from the UI; reports, charts or exports that use these entries; notifications; attachments on entries.

## Capabilities

### New Capabilities
- `student-interventions`: how risk-identified and support-received entries of a student are recorded, listed, changed, removed and shown in the student profile, and who can do each.

### Modified Capabilities

## Impact

- **Submodules:** BE + FE
- **Roles / who can do what:** `ERAS Professional` gains read access to the Students list and to the profile of the students of their assigned assessments (only those) and can create, edit and delete their own entries on them. `ERAS Administrator` can create entries and edit or delete any entry. `ERAS Student Services Officer` can view entries only. `ERAS Guest` is denied everything.
- **API contract:** new endpoints to list, create, update and delete the entries of a student, and Professional read access to the students list and the student profile, limited to the students of their assigned assessments (the other student endpoints stay denied to them) (details go to design.md, so the BE DTO, the FE model and the FE service move together).
- **Data / migration:** yes, a new table linked to the existing student by a foreign key, and no change to the student table.

## Assumptions

- A1: The "student's record" is the existing student modal opened from the Students list (Student Profile / Edit Student), not a new page; the Interventions section there manages the entries. The existing read-only profile summary is the "profile modal" of the ticket and only displays them. Both read the same entries, so there is one source of data and no copy.
- A2: The description is plain text of at most 1000 characters. It is stored as written and always displayed as text, never as markup.
- A3: The date is any valid date, with no restriction on future dates; the ticket only requires that it is present.
- A4: Entries are ordered by date, newest first, and entries with the same date show the most recently created first. The list is not paged.
- A5: The creator is the authenticated user taken from the token, never from the request, and is shown by name. Editing an entry keeps its creator and creation time.
- A6: `ERAS Student Services Officer` can only view entries, following the ticket text ("only users with the professional role").
- A7: A professional is "assigned" to a student when they are listed as a professional of an assessment that includes the student, the same rule that already limits the assessments they see. Reassigning an intervention to them (change 635) adds them to that assessment, so they gain access to its students.
- A8: The scenarios that show an `ERAS Professional` acting on a student assume that student belongs to an assessment assigned to that professional, unless the scenario says otherwise. `ERAS Administrator` and `ERAS Student Services Officer` are not limited by assignment.

## Clarifications

### Session 2026-10-29

- Q: May an `ERAS Administrator` add, edit and delete entries, including those of other users? → A: Yes, all of it (AC-21: changed; AC-27, AC-28, AC-29: added)
- Q: May a Professional open every student or only the ones of their assigned assessments? → A: Every student (AC-22: changed)
- Q: What does a Professional see and do in the Students section and the profile modal? → A: Everything read only, with no create, import, export, edit or delete of students (AC-23: changed; AC-30: added)
- Q: Are the proposed risk and support type lists accepted? → A: Yes, as proposed, without "Other" (AC-7: unchanged; lists moved from Assumptions to What Changes)
- Q: Is deleting an entry permanent or a soft delete? → A: Soft delete, stored with who deleted it and when (AC-12, AC-28: changed)
- Revision (user decision, after the session): a Professional only sees the students of their assigned assessments, as access to assessments already works, instead of every student (AC-22: changed; AC-31, AC-32, AC-33: added; AC-16: given clarified; A7, A8 added).
- Direct fixes: AC-4 now covers a blank description; AC-9 is limited to adding an entry (it combined three operations); the edit and delete requirements say "someone else" so they stay consistent with the Administrator requirement.
- Status after this session: Clarified

### Session 2026-10-29 (revision found while implementing)

- Finding: after updating the branches from `develop`, the profile already has a read-only profile summary that shows two free-text lists (identified risks, support received) stored on the student profile; the spec assumed no such source existed.
- Q: Where are entries added, edited and deleted? → A: In the student record; the profile summary only displays them (AC-24, AC-25, AC-26: changed to the summary; AC-1, AC-9, AC-20, AC-22, AC-29, AC-30: wording only)
- Q: What happens to the former free-text lists? → A: They stay untouched and are no longer shown; no import (AC-34: added; AC-9: also keeps the profile's own lists unchanged)
- Status after this session: Clarified (spec and plan sent back for approval)

## Validation log

### 2026-10-30 – Round 1

Setup: the local stack (`AGENTS.md` §3.4) running on the 643 branches of `ERAS-BE` and `ERAS-FE`, with a real PostgreSQL. Test users: an Administrator, a Student Services Officer, a Professional "Ana Pérez" assigned to one assessment that includes the student "Ana Torres" (and not "Luis Anaya"), a second Professional "Luis Gómez", and a user with no ERAS role (Guest). Students "Ana Torres" and "Luis Anaya" exist; "Ana Torres" has a student profile.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| 4.4 | Start the API on a database without the new migration and let it apply `AddStudentInterventionEntries`; then `dotnet ef database update <previous migration>` and apply it again | The table `student_intervention_entries` is created, dropped on rollback and created again without errors | | |
| 4.4 | As "Ana Pérez" open Students (or call `GET api/v1/students`) | Only "Ana Torres" is listed, with the right total; "Luis Anaya" is not | | |
| AC-1 | As "Ana Pérez" open the record of "Ana Torres" (person icon), press "Add risk", pick Type "Academic", Date 2026-10-20, Description "Failed two midterms", Save | Dialog closes, a toast confirms, and the Risks list shows the entry at once without reloading | | |
| AC-2 | In the same record press "Add support", Type "Tutoring", Date 2026-10-21, Description "Weekly math tutoring", Save | The entry shows in the Support list and not in Risks | | |
| AC-3 | Look at the two entries and `GET api/v1/students/{id}/interventions` | Each shows "Created by Ana Pérez" and the creation time of the server; the API returns the creator's sub and name | | |
| AC-4 / AC-5 | Press "Add risk" and Save with nothing filled in; then try with only a blank (spaces) description | The form is not sent and shows "Type is required.", "Description is required." and "Date is required."; no request in the network tab | | |
| AC-6 | Type or paste 1001 characters in Description and Save | The form shows the maximum-length message and nothing is saved (API called directly answers 400 "too long") | | |
| AC-7 | `POST` a risk with Type "Tutoring" using the API | 400 with a message naming the Type field; nothing saved | | |
| AC-8 | `POST api/v1/students/999999/interventions` as "Ana Pérez" | 404 | | |
| AC-9 | After adding entries, open the record and the profile summary of "Ana Torres" | Name, email, cohort and personal data are unchanged | | |
| AC-10 | As "Ana Pérez" press Edit on her own entry, change the description to "Failed three midterms", Save | The list shows the new description at once; creator and date of creation are unchanged | | |
| AC-11 | As "Luis Gómez" (assigned to the same assessment) call `PUT` on an entry created by "Ana Pérez" | 403 and the entry is unchanged | | |
| AC-12 | As "Ana Pérez" press Delete on her entry and confirm | The entry disappears at once; in the database the row has `is_deleted = true` with `modified_by` = her sub and `updated_at` set | | |
| AC-13 | Press Delete on an entry and cancel the confirmation | The entry stays and no DELETE request is sent | | |
| AC-14 | As "Luis Gómez" call `DELETE` on an entry created by "Ana Pérez" | 403 and the entry remains | | |
| AC-15 | Create entries dated 2026-10-01, 2026-10-20 and 2026-10-10 and open the record | Within each list the order is newest date first (and, for equal dates, the last created first) | | |
| AC-16 | As the Administrator, open "Luis Anaya" after adding entries to "Ana Torres" | "Luis Anaya" shows empty lists; the entries of "Ana Torres" are not mixed in | | |
| AC-17 | As the Officer open the record and the profile summary of "Ana Torres" | The entries are listed unchanged | | |
| AC-18 | As the Guest call `GET api/v1/students/{id}/interventions` | 403 and no data | | |
| AC-19 | As the Officer call `POST`, `PUT` and `DELETE` on the entries API | Each answers 403 and nothing changes | | |
| AC-20 | As the Officer open the record of "Ana Torres" | The entries are listed with no "Add", "Edit" or "Delete" action | | |
| AC-21 | As the Administrator add a risk "Financial" to "Ana Torres" | Saved; the entry shows the Administrator as creator | | |
| AC-27 | As the Administrator edit an entry created by "Ana Pérez" | Saved; the creator is still "Ana Pérez" | | |
| AC-28 | As the Administrator delete an entry created by "Ana Pérez" | It disappears; the row is soft deleted with the Administrator as `modified_by` | | |
| AC-29 | As the Administrator open the record of a student with an entry by "Ana Pérez" | "Add risk", "Add support" and Edit/Delete on the entry are visible; Delete asks for confirmation | | |
| AC-22 | As "Ana Pérez" sign in and open the Students section from the side menu | The menu item exists, the list opens, and the profile of "Ana Torres" opens with the Interventions section | | |
| AC-23 | As "Ana Pérez" call `POST api/v1/students`, `POST api/v1/students/manual`, `DELETE api/v1/students/{id}`, `PUT api/v1/students/{id}/profile` | Each answers 403; the students are unchanged | | |
| AC-30 | As "Ana Pérez" look at the Students list and the record | No Import, Export, New Student, delete or details row actions and no selection checkboxes; the record opens read only (no Edit button, even for a student without profile); the search still works | | |
| AC-31 | As "Ana Pérez" call `GET api/v1/students/{id of Luis Anaya}/profile` | 403 and no data | | |
| AC-32 | As "Ana Pérez" call `GET api/v1/students/{id of Luis Anaya}/interventions` | 403 and no entries | | |
| AC-33 | As "Ana Pérez" call `POST api/v1/students/{id of Luis Anaya}/interventions` | 403 and nothing saved | | |
| AC-24 | As any role with an ERAS role open "Profile summary" (badge icon) of "Ana Torres" | Risks and Support are two separate lists with type, description and date, and no action | | |
| AC-25 | Open the profile summary of a student without entries | "No risks identified yet." and "No support received yet." | | |
| AC-26 | Add an entry whose description is `<b>Late</b><script>alert(1)</script>` and open the record and the summary | The text appears literally; nothing is rendered as markup and no script runs | | |
| AC-34 | For a student whose profile has the free-text risk "Low attendance" (set via `PUT api/v1/students/{id}/profile`) and no entries, open the summary | The Risks list says "No risks identified yet." and "Low attendance" is not shown | | |
| Side effects | Admin/Officer: use Import, Export (CSV/PDF), New Student, search and the details action; open Assessments and its interventions as a Professional | Everything works as before this change | | |
| Errors | Stop the API and press Save in the add dialog; open the summary with the entries endpoint failing | Error toast and the dialog stays open; the summary still shows the profile with the "could not be loaded" line | | |
| Views | Open the record and the add dialog at phone and tablet widths | Layout stays usable: lists stack in one column and the dialog fits | | |

Approved by Lucia Becerra (developer), 2026-10-30: goal achieved, no side effects, no open errors. The rows above were not marked one by one; the approval covers the whole round, including the real-PostgreSQL checks of task 4.4.

Verified 2026-10-30: no gaps, no drift, gates green (8 of 8: `openspec validate`, BE build, format, test and coverage, FE lint, test and build). The wording of `design.md` and tasks 2.5 was aligned with the code (a single `GetPagedAsyncWithJoins` overload that takes the allowed student ids), by the developer's decision.
