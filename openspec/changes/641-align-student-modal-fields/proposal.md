# Proposal

**Status:** Approved
**Plan:** Approved

## Why

The two student modals of the Students section (the student record and the read-only profile summary) show more data than agreed, in different orders and with different labels, so reviewing a student's profile means reading unrelated or duplicated information. Both must show the same agreed attributes, in the same order. Issue: ERAS#641 ("[Feature] Align Fields to Profile and Reuse Existing Student Data")

## What Changes

- Both modals show the same attributes, in the same order, in three sections:
  1. **Personal information**: first names, institutional email, SIS ID, ID/Passport number, mobile number, country, cohort.
  2. **Current academic information**: current CGPA, SAP status, current course as third attempt (only when it applies), passed courses count, failed courses count, current courses with group and section (last). Each field of this section carries an icon.
  3. **Interventions**: risks identified and support received, as two separate lists with an empty-state message.
- "STU ID" is replaced by "SIS ID", read from the SIS ID the student already has (the one stored by the import; for a student registered by hand, the SIS ID of its profile); no new identifier is introduced.
- "First names" shows the student's full name as one value.
- Any field the modals show today that is not in the list above is no longer displayed in the profile summary or in the student record's viewing presentation ("Student Profile"). The removal is display-only: no stored data is deleted or altered, including when a student is saved from the record. The Edit Student and New Student forms keep their fields.
- Both modals render these sections from one shared definition, so order and labels cannot drift apart.
- Cohort and country stay in Personal information. Each modal keeps loading the selected student through the existing student-to-profile relationship; no new profile table, entity or model is created.

**Out of scope:** hiding fields in the Edit Student and New Student forms of the record (they keep every field they have today); deleting or migrating the data of the removed fields; changes to the Students list, its filters, its CSV export or any other screen that uses student data; changes to how interventions are recorded (change 643); the other student detail modals of the Students list; editing the student-to-profile relationship, its keys or its cascade rules.

## Capabilities

### New Capabilities
- `student-profile-modals`: which attributes the student record and the profile summary show, in which sections and order, and where the SIS ID comes from.

### Modified Capabilities

## Impact

- **Submodules:** BE + FE. The student profile response must carry the imported student's SIS ID, so the BE DTO and its mapping, the FE model and the FE service move together.
- **Roles / who can do what:** no change. Who can open, edit or create a student stays as it is.
- **API contract:** the existing student profile response returns the SIS ID of imported students; no new endpoint and no new field if the existing SIS ID field can carry it (details go to design.md).
- **Data / migration:** no. Nothing is created, dropped or rewritten; the student-to-profile relationship and the Student model are untouched.
- **Depends on:** change 643 (student interventions), which is not merged into `develop` yet. This change is built on top of it: the Interventions section reuses the intervention lists and the student record's Interventions management that 643 adds.

## Assumptions

- A1: "Institutional email" is the student's primary email, the one the Student record already holds. The secondary email is not shown.
- A2: Missing values keep today's behavior in the profile summary: a dash ("-") is shown instead of an empty space.
- A3: The third-attempt field is shown as a label only when the student's current course is a third attempt; when it is not or is unknown, nothing is shown and no space is left for it.
- A4: Both modals use the same section titles and field labels, in English: "Personal information", "Current academic information", "Interventions", "First names", "Institutional email", "SIS ID", "ID/Passport number", "Mobile number", "Country", "Cohort", "Current CGPA", "SAP status", "Third attempt", "Current courses", "Passed courses", "Failed courses".
- A5: Courses keep today's presentation, as the last field of Current academic information: one row per course with name, group and section, and the existing message when the student has no current courses.
- A6: In the student record, Interventions keeps the add, edit and delete behavior of change 643. This change only fixes its position as the third section; the profile summary keeps showing the lists read-only.
- A7: The two modals still open from the same actions as today (the student profile summary and the student record of the Students list); this change does not add or move any entry point.
- A8: Every scenario that opens the student record in "view" mode covers its read-only presentation; the Edit Student and New Student modes keep their forms (AC-14).
- A10: The ID/Passport number goes right after the SIS ID in Personal information; the stakeholders confirmed it is shown but gave no position, so this is the default to challenge.
- A9: A student with no SIS ID at all (not imported and with no SIS ID in its profile) shows "-" as its SIS ID.

## Clarifications

### Session 2026-11-02

- Q: Where does the SIS ID shown come from? → A: The SIS ID the import stored on the student; for a student registered by hand, the SIS ID of its profile (AC-6: changed; AC-19: added)
- Q: What does "first names" show? → A: The full name as one value (AC-3: changed)
- Q: How does "only the listed attributes" apply to the record's create and edit forms? → A: Only to the viewing presentation; Edit Student and New Student keep their fields (AC-14: changed)
- Status after this session: Clarified

## Validation log

### 2026-11-02 – Round 1

Setup: run the local stack (AGENTS.md §3.4) and open Students. Use three students: an **imported** one (with a SIS ID from the import, with courses if possible), one **registered by hand** with a SIS ID in its profile, and one **registered by hand without** SIS ID. Open each with the "Profile summary" action and with "View profile" (the student record).

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1, AC-2 | Open the profile summary, then the student record (view mode), of the same student | Both show exactly three sections in this order: Personal information, Current academic information, Interventions | | |
| AC-3, AC-4 | Look at Personal information; open a student with no mobile number or country | Order: First names, Institutional email, SIS ID, Mobile number, Country, Cohort; First names is the full name; missing values show "-" | | |
| AC-5 | Look for "STU ID" in both modals | It appears nowhere; "SIS ID" is shown with the value | | |
| AC-6, AC-19 | Imported student; manual student with a profile SIS ID; manual student without one | Imported shows the SIS ID the import stored; manual shows the profile SIS ID; the third shows "-" (never a GUID) | | |
| AC-7, AC-10 | Look at Current academic information | Order: Current CGPA, SAP status, [Third attempt], Current courses (name, group, section), Passed courses, Failed courses | | |
| AC-8, AC-9 | Student whose current course is a third attempt vs one that is not or unknown | "Third attempt: Yes" appears only for the first one, between SAP status and the courses, with no gap otherwise | | |
| AC-11 | Interventions in the summary (read only) and in the record (manageable); a student with no entries | Risks identified and Support received are two separate lists; the summary has no add/edit/delete; empty lists show their message | | |
| AC-12, AC-13 | Look for date of birth, gender, ID/passport, secondary email, address, level of study, faculty, modality, previous institution and the old free-text risks/support | None of them appear in the summary or in the record in view mode | | |
| AC-14 | As Administrator or Student Services Officer press Edit, then New Student | Both forms still show all their fields; Cancel returns to the view with no unsaved prompt when nothing changed; locked name/email of imported students still locked | | |
| AC-15 | Edit a student that has CGPA/SAP/courses (profile data), change only the mobile number, save, reopen the summary | Mobile number changes; CGPA, SAP status, courses, SIS ID and the other values are unchanged | | |
| AC-16, AC-17 | Open the summary and the record of two different students in a row | Each modal shows the data of the student selected, never of the previous one | | |
| AC-18 | Compare the two modals for the same student | Same titles, labels, values and order | | |
| Side effects | Students list, search, filters, CSV export, other student detail modals; Professional role (read only, no Edit button) | All work as before; a Professional sees the three sections and the Interventions entries, and cannot edit personal data | | |
| Errors / states | Stop the API or use an expired session when opening each modal; slow connection; narrow window (≤800px) | A clear error message in the modal; spinner while loading; sections stack in one column on a narrow window | | |

Approved by Lucia Becerra, 2026-11-02.
Verified 2026-11-02: no gaps, no drift, gates green

### Session 2026-11-03

- Reopened by the user after the review of the frontend PR: the plan of the profile summary lost the icons of the former design, and the user asked for "Current courses" to go after "Passed courses" and "Failed courses", with an icon. The ticket's order for the section is therefore changed by the user (to be confirmed with the stakeholders together with the ID/Passport question).
- Changed: AC-7 (order), AC-8 (position of the third-attempt field), AC-10 (courses are the last field). Added: AC-20 (icons on the academic fields).
- Status after this session: Draft (to be approved again, then the plan)

### Session 2026-11-03 (stakeholders)

- Q: Must the ID/Passport number be shown in the view of the student and in the profile summary? → A: Yes, the stakeholders confirmed it must be shown (AC-3, AC-4: changed; AC-12, AC-13: it is no longer one of the hidden fields)
- Status after this session: Draft (to be approved again, then the plan)

### 2026-11-03 – Round 2 (after the reopening: passport number, courses last, icons)

Setup: run the local stack on the three `641-...` branches (ERAS-BE, ERAS-FE). Use "Aaron Ford" after running the sample script `aaron-ford-sample.sql` (all fields filled), plus a student with no data. Open each with "Profile summary" and with "View profile".

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-3, AC-4 | Personal information of Aaron Ford, and of a student with no passport, mobile or country | Order: First names, Institutional email, SIS ID, **ID/Passport number**, Mobile number, Country, Cohort; missing values show "-" | | |
| AC-7, AC-8, AC-9 | Current academic information of Aaron Ford (third attempt on), then of a student where it is off | Order: Current CGPA, SAP status, [Third attempt], Passed courses, Failed courses, **Current courses last**; Third attempt only when it applies | | |
| AC-10 | The courses of Aaron Ford | Each course with name, group and section, as the last field of the section | | |
| AC-20 | Look at each academic field | Each one has its own icon and colour (CGPA, SAP status, Third attempt, Passed, Failed, Current courses); the layout stays tidy on a narrow window | | |
| AC-12, AC-13 | Look for date of birth, gender, secondary email, address, level of study, faculty, modality, previous institution and the free-text risks and support | None of them appears in either modal (the ID/Passport number does) | | |
| AC-18 | Compare the profile summary and the student record (view) of the same student | Same sections, labels, values, icons and order | | |
| AC-14 | Press Edit and New Student | Forms keep all their fields; the ID/Passport number is still required | | |
| Regression | Interventions (add, edit, delete a risk and a support entry), Students list, search, CSV export, Professional role | Everything works as before; no console errors | | |

Approved by Lucia Becerra (Round 2), 2026-11-03.
Verified 2026-11-03: no gaps, no drift, gates green
