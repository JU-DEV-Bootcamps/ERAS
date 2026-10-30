## Purpose
Defines how risks identified and support received are recorded for a student, who can change them, and how they are listed and shown in the student profile.

## ADDED Requirements

### Requirement: Record risk and support entries for a student
The system SHALL let an `ERAS Professional` add a risk-identified or support-received entry to a student, with a type from the fixed list of its kind, a description and a date, and SHALL record the authenticated professional and the creation time automatically.

#### Scenario: AC-1 Professional adds a risk-identified entry
**Side:** BE + FE
- **GIVEN** an `ERAS Professional` "Ana Pérez" with the student "Ana Torres" open
- **WHEN** they add a risk with type "Academic", description "Failed two midterms" and date 2026-10-20 and save
- **THEN** the entry is saved for "Ana Torres" and the Risks list shows it immediately, without reloading the page
- **AND** the API responds 201 Created

#### Scenario: AC-2 Professional adds a support-received entry
**Side:** BE
- **GIVEN** an `ERAS Professional` and the student "Ana Torres"
- **WHEN** they add a support entry with type "Tutoring", description "Weekly math tutoring" and date 2026-10-21
- **THEN** the API responds 201 Created with the entry as a support entry of "Ana Torres"
- **AND** the Support list of "Ana Torres" contains it and the Risks list does not

#### Scenario: AC-3 Creator and creation time are recorded automatically
**Side:** BE
- **GIVEN** an `ERAS Professional` "Ana Pérez" and a request that names "Luis Gómez" as creator and a different creation time
- **WHEN** the entry is saved
- **THEN** the entry shows "Ana Pérez" as its creator and the time the server received the request as its creation time
- **AND** the creator and time sent in the request are ignored

#### Scenario: AC-4 Required fields are validated by the API
**Side:** BE
- **GIVEN** an `ERAS Professional` and the student "Ana Torres"
- **WHEN** they save an entry with no type, or an empty or blank description, or no date
- **THEN** the API responds 400 Bad Request with a message that names each missing field
- **AND** no entry is persisted

#### Scenario: AC-5 The form shows the required-field errors
**Side:** FE
- **GIVEN** an `ERAS Professional` with the add-entry form open and nothing filled in
- **WHEN** they try to save
- **THEN** the form is not submitted and the Type, Description and Date fields each show that they are required
- **AND** no request is sent to the API

#### Scenario: AC-6 A description over the limit is rejected
**Side:** BE
- **GIVEN** an `ERAS Professional` and the student "Ana Torres"
- **WHEN** they save an entry whose description has 1001 characters
- **THEN** the API responds 400 Bad Request with a message saying the description is too long
- **AND** no entry is persisted

#### Scenario: AC-7 A type from the other kind is rejected
**Side:** BE
- **GIVEN** an `ERAS Professional` and the student "Ana Torres"
- **WHEN** they save a risk entry with the type "Tutoring", which belongs to the support list, or a type that is on no list
- **THEN** the API responds 400 Bad Request with a message that names the Type field
- **AND** no entry is persisted

#### Scenario: AC-8 An unknown student is not found
**Side:** BE
- **GIVEN** an `ERAS Professional` and no student with id 999999
- **WHEN** they add an entry to the student 999999
- **THEN** the API responds 404 Not Found
- **AND** no entry is persisted

#### Scenario: AC-9 Saving an entry does not change the student
**Side:** BE
- **GIVEN** the student "Ana Torres" with a name, email, cohort, personal profile data and the profile's own lists of identified risks and support
- **WHEN** an `ERAS Professional` adds an entry to "Ana Torres"
- **THEN** the name, email, cohort, personal profile data and the profile's own lists of "Ana Torres" keep their previous values
- **AND** the entries of other students are not changed

### Requirement: Edit own entries
The system SHALL let an `ERAS Professional` edit the type, description and date of an entry they created, SHALL keep its creator and creation time, and SHALL reject editing an entry created by someone else.

#### Scenario: AC-10 Professional edits their own entry
**Side:** BE + FE
- **GIVEN** an entry created by the `ERAS Professional` "Ana Pérez" with description "Failed two midterms"
- **WHEN** "Ana Pérez" changes the description to "Failed three midterms" and saves
- **THEN** the entry shows the new description in the list immediately and the API responds 200 OK
- **AND** the entry keeps "Ana Pérez" as creator and its original creation time

#### Scenario: AC-11 Professional cannot edit an entry of another professional
**Side:** BE
- **GIVEN** an entry created by the `ERAS Professional` "Luis Gómez"
- **WHEN** the `ERAS Professional` "Ana Pérez" sends an edit of that entry
- **THEN** the API responds 403 Forbidden
- **AND** the entry keeps its previous values

### Requirement: Delete own entries with confirmation
The system SHALL ask an `ERAS Professional` to confirm before deleting an entry they created, and SHALL remove it from the lists only after they confirm, keeping it stored with who deleted it and when. It MUST reject deleting an entry created by someone else.

#### Scenario: AC-12 Professional deletes their own entry after confirming
**Side:** BE + FE
- **GIVEN** an entry created by the `ERAS Professional` "Ana Pérez"
- **WHEN** "Ana Pérez" chooses Delete and confirms
- **THEN** the API responds 204 No Content and the entry disappears from the list immediately
- **AND** the entry is no longer returned for that student but stays stored with "Ana Pérez" as the user who deleted it and the time of deletion

#### Scenario: AC-13 Cancelling the confirmation keeps the entry
**Side:** FE
- **GIVEN** an `ERAS Professional` looking at the confirmation to delete one of their entries
- **WHEN** they cancel
- **THEN** the confirmation closes and the entry is still listed
- **AND** no delete request is sent to the API

#### Scenario: AC-14 Professional cannot delete an entry of another professional
**Side:** BE
- **GIVEN** an entry created by the `ERAS Professional` "Luis Gómez"
- **WHEN** the `ERAS Professional` "Ana Pérez" sends a delete of that entry
- **THEN** the API responds 403 Forbidden
- **AND** the entry is still returned for the student

### Requirement: List the entries of a student
The system SHALL return the entries of one student only, newest first, to every user with an ERAS role, and SHALL deny users without an ERAS role.

#### Scenario: AC-15 Entries are listed newest first
**Side:** BE
- **GIVEN** the student "Ana Torres" with a risk dated 2026-10-01, a support entry dated 2026-10-20 and a risk dated 2026-10-10
- **WHEN** an `ERAS Professional` requests the entries of "Ana Torres"
- **THEN** the API responds 200 OK with the entries in the order 2026-10-20, 2026-10-10, 2026-10-01
- **AND** each entry shows its kind, type, description, date, creator and creation time

#### Scenario: AC-16 Entries of one student never appear for another
**Side:** BE
- **GIVEN** the student "Ana Torres" with two entries and the student "Luis Anaya" with none, both in an assessment assigned to the `ERAS Professional` "Ana Pérez"
- **WHEN** "Ana Pérez" requests the entries of "Luis Anaya"
- **THEN** the API responds 200 OK with an empty list
- **AND** requesting the entries of "Ana Torres" still returns her two entries

#### Scenario: AC-17 Student Services Officer can view the entries
**Side:** BE
- **GIVEN** the student "Ana Torres" with one risk entry
- **WHEN** an `ERAS Student Services Officer` requests the entries of "Ana Torres"
- **THEN** the API responds 200 OK with that entry
- **AND** the entry is unchanged

#### Scenario: AC-18 Guest cannot view the entries
**Side:** BE
- **GIVEN** a user with no ERAS role (Guest)
- **WHEN** they request the entries of a student
- **THEN** the API responds 403 Forbidden
- **AND** no entry data is returned

### Requirement: Only professionals change entries
The system SHALL deny creating, editing and deleting entries to users who are neither an `ERAS Professional` nor an `ERAS Administrator`, and the interface SHALL show them the entries without add, edit or delete actions.

#### Scenario: AC-19 Student Services Officer cannot change entries
**Side:** BE
- **GIVEN** an `ERAS Student Services Officer` and the student "Ana Torres" with one entry
- **WHEN** they try to add an entry to "Ana Torres" and to edit and delete the existing one
- **THEN** each request is answered with 403 Forbidden
- **AND** the entries of "Ana Torres" are unchanged

#### Scenario: AC-20 Student Services Officer sees the entries without actions
**Side:** FE
- **GIVEN** an `ERAS Student Services Officer` opening the record of a student with entries
- **WHEN** the Interventions section is shown
- **THEN** the entries are listed
- **AND** there is no add, edit or delete action

### Requirement: Administrators manage entries
The system SHALL let an `ERAS Administrator` add entries and edit or delete entries created by any user, keeping the original creator, and the interface SHALL show them the add, edit and delete actions.

#### Scenario: AC-21 Administrator adds an entry
**Side:** BE
- **GIVEN** an `ERAS Administrator` and the student "Ana Torres"
- **WHEN** they add a risk with type "Financial", description "Tuition payment overdue" and date 2026-10-22
- **THEN** the API responds 201 Created and the entry shows that Administrator as its creator
- **AND** the entries of other students are unchanged

#### Scenario: AC-27 Administrator edits an entry of a professional
**Side:** BE
- **GIVEN** an entry created by the `ERAS Professional` "Ana Pérez"
- **WHEN** an `ERAS Administrator` changes its description and saves
- **THEN** the API responds 200 OK and the entry shows the new description
- **AND** the entry keeps "Ana Pérez" as creator and its original creation time

#### Scenario: AC-28 Administrator deletes an entry of a professional
**Side:** BE
- **GIVEN** an entry created by the `ERAS Professional` "Ana Pérez"
- **WHEN** an `ERAS Administrator` deletes it
- **THEN** the API responds 204 No Content and the entry is no longer returned for that student
- **AND** the entry stays stored with that Administrator as the user who deleted it

#### Scenario: AC-29 Administrator sees the add, edit and delete actions
**Side:** FE
- **GIVEN** an `ERAS Administrator` opening the record of a student with an entry created by "Ana Pérez"
- **WHEN** the Interventions section is shown
- **THEN** there is an add action and the entry has edit and delete actions
- **AND** deleting asks for confirmation as it does for a professional

### Requirement: Professionals reach the student record
The system SHALL let an `ERAS Professional` open the Students section, list the students of the assessments they are assigned to and read those students' profiles to use the Interventions section, and MUST deny them every other student and every other student action (create, import, delete, edit personal data).

#### Scenario: AC-22 Professional opens the record of an assigned student and the Interventions section
**Side:** BE + FE
- **GIVEN** an `ERAS Professional` "Ana Pérez" assigned to an assessment of the student "Ana Torres" and to no assessment of the student "Luis Anaya"
- **WHEN** they open the Students section and the profile of "Ana Torres"
- **THEN** the Students list shows "Ana Torres" and not "Luis Anaya", and the record opens with the Interventions section
- **AND** the API responds 200 OK to the list and to the profile requests

#### Scenario: AC-23 Professional still cannot change students
**Side:** BE
- **GIVEN** an `ERAS Professional`
- **WHEN** they send a request to create a student, to import students, to delete a student or to edit a student's personal profile
- **THEN** each request is answered with 403 Forbidden
- **AND** the students are unchanged

#### Scenario: AC-30 Professional sees the Students section read only
**Side:** FE
- **GIVEN** an `ERAS Professional` who opens the Students section and a student's record
- **WHEN** the list and the record are shown
- **THEN** there is no action to create, import, export, edit personal data or delete a student
- **AND** the record shows the student's data and the Interventions section with its add, edit and delete actions

#### Scenario: AC-31 Professional cannot open the profile of a student who is not assigned
**Side:** BE
- **GIVEN** an `ERAS Professional` "Ana Pérez" assigned to no assessment of the student "Luis Anaya"
- **WHEN** they request the profile of "Luis Anaya"
- **THEN** the API responds 403 Forbidden
- **AND** no data of "Luis Anaya" is returned

#### Scenario: AC-32 Professional cannot read the entries of a student who is not assigned
**Side:** BE
- **GIVEN** an `ERAS Professional` "Ana Pérez" assigned to no assessment of the student "Luis Anaya", who has one entry
- **WHEN** they request the entries of "Luis Anaya"
- **THEN** the API responds 403 Forbidden
- **AND** no entry is returned

#### Scenario: AC-33 Professional cannot add an entry to a student who is not assigned
**Side:** BE
- **GIVEN** an `ERAS Professional` "Ana Pérez" assigned to no assessment of the student "Luis Anaya"
- **WHEN** they add a risk entry to "Luis Anaya"
- **THEN** the API responds 403 Forbidden
- **AND** no entry is persisted

### Requirement: Show the entries in the student profile summary
The system SHALL show, in the read-only student profile summary, the risks identified and the support received as two separate lists read from the same entries that are managed in the student record, each with an empty-state message when it has none and without add, edit or delete actions, and SHALL display descriptions as plain text.

#### Scenario: AC-24 Risks and support are shown as separate lists
**Side:** FE
- **GIVEN** the student "Ana Torres" with one risk "Academic" and one support entry "Tutoring"
- **WHEN** a user with an ERAS role opens the profile summary of "Ana Torres"
- **THEN** the summary shows "Academic" in the Risks list and "Tutoring" in the Support list, each with its description and date
- **AND** the summary has no add, edit or delete action

#### Scenario: AC-25 Empty lists show a message
**Side:** FE
- **GIVEN** a student with no risk entries and no support entries
- **WHEN** a user with an ERAS role opens the profile summary
- **THEN** the Risks list shows "No risks identified yet." and the Support list shows "No support received yet."
- **AND** no empty rows are shown

#### Scenario: AC-26 Descriptions are displayed as plain text
**Side:** FE
- **GIVEN** an entry whose description is `<b>Late</b><script>alert(1)</script>`
- **WHEN** a user with an ERAS role opens the profile summary
- **THEN** the description is shown literally as that text
- **AND** no markup is rendered and no script runs

#### Scenario: AC-34 The former free-text lists of the profile are not shown
**Side:** FE
- **GIVEN** a student whose profile has the free-text risk "Low attendance" and no entries
- **WHEN** a user with an ERAS role opens the profile summary
- **THEN** the Risks list shows "No risks identified yet." and "Low attendance" is not shown
- **AND** the entries are the only source of the two lists
