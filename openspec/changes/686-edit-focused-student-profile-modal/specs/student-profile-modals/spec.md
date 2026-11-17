# Spec Delta

## ADDED Requirements

### Requirement: The profile summary is the only read-only student profile modal
The system SHALL show the profile summary as the read-only view of a student's profile, with the sections Personal information, Current academic information and Interventions in that order, and no editable field.

#### Scenario: AC-1 Profile summary shows the three sections in order
**Side:** FE
- **GIVEN** a user with an ERAS role and the student "Ana Torres" with profile data
- **WHEN** they open the profile summary of "Ana Torres"
- **THEN** the summary shows the sections "Personal information", "Current academic information" and "Interventions", in that order
- **AND** it shows no other section

#### Scenario: AC-2 Profile summary has no editable fields
**Side:** FE
- **GIVEN** a user who can manage students and the student "Ana Torres"
- **WHEN** they open the profile summary of "Ana Torres"
- **THEN** the summary shows no input, select or date field and no "Edit" or "Save" button
- **AND** it offers only a way to close it

### Requirement: Edit Student Profile opens an editable modal directly
The system SHALL offer in the Students list the action "Edit Student Profile", which opens a modal titled "Edit Student Profile" that is editable immediately for users who can manage students, without a viewing mode or an "Edit" button. For users who cannot manage students the profile fields stay disabled.

#### Scenario: AC-3 Action opens the editable modal
**Side:** FE
- **GIVEN** an ERAS Administrator and the student "Ana Torres" with a registered profile and mobile number "+506 8888 0000"
- **WHEN** they choose "Edit Student Profile" on the row of "Ana Torres"
- **THEN** a modal titled "Edit Student Profile" opens with its fields enabled and the mobile number "+506 8888 0000" filled in
- **AND** the modal has no "Edit" button and offers "Cancel" and "Save"

#### Scenario: AC-4 Student without a profile opens editable and prefilled
**Side:** FE
- **GIVEN** an ERAS Student Services Officer and an imported student "Luis Anaya" with email "luis.anaya@jala.university" and no registered profile
- **WHEN** they choose "Edit Student Profile" on the row of "Luis Anaya"
- **THEN** the "Edit Student Profile" modal opens editable with the name and email already filled in
- **AND** the remaining fields are empty

#### Scenario: AC-5 Professional still sees the action
**Side:** FE
- **GIVEN** a user with the role "ERAS Professional"
- **WHEN** they open the Students list
- **THEN** every row shows the "Edit Student Profile" action and the "Profile summary" action
- **AND** no row shows the actions to delete a student

#### Scenario: AC-17 Professional gets the modal with the profile fields disabled
**Side:** FE
- **GIVEN** a user with the role "ERAS Professional" and the student "Ana Torres" with the support entry "Tutoring"
- **WHEN** they choose "Edit Student Profile" on the row of "Ana Torres"
- **THEN** the modal opens with every profile field disabled and no "Save" button, offering only "Close"
- **AND** the interventions list below the form keeps its add control, so they can still manage interventions

#### Scenario: AC-6 Edit modal keeps the interventions list
**Side:** FE
- **GIVEN** an ERAS Administrator and the student "Ana Torres" with the support entry "Tutoring"
- **WHEN** they open "Edit Student Profile" for "Ana Torres"
- **THEN** the interventions list of "Ana Torres" is shown below the form with "Tutoring"
- **AND** the list offers its add control, as the interventions management does today

### Requirement: Saving and discarding in the edit modal
The system SHALL save the changes of the edit modal only when the user saves, show the updated values afterwards in the profile summary, and discard unsaved changes when the modal is cancelled or closed.

#### Scenario: AC-7 Saving updates the student and the summary shows it
**Side:** FE
- **GIVEN** an ERAS Administrator editing "Ana Torres" whose mobile number is "+506 8888 0000"
- **WHEN** they change it to "+506 7777 1111" and press "Save"
- **THEN** the update is sent with the mobile number "+506 7777 1111", the modal closes, the Students list reloads and a success message is shown
- **AND** the profile summary of "Ana Torres" opened afterwards shows the mobile number returned by the server, "+506 7777 1111"

#### Scenario: AC-8 Closing with unsaved changes discards them after confirmation
**Side:** FE
- **GIVEN** an ERAS Administrator who changed the mobile number of "Ana Torres" without saving
- **WHEN** they close the modal or press "Cancel" and confirm the discard
- **THEN** the modal closes and no save request is sent
- **AND** the stored mobile number of "Ana Torres" is unchanged

#### Scenario: AC-9 Cancelling without changes closes the modal
**Side:** FE
- **GIVEN** an ERAS Administrator who opened "Edit Student Profile" and changed nothing
- **WHEN** they press "Cancel"
- **THEN** the modal closes without asking for confirmation
- **AND** no save request is sent

### Requirement: The new student modal only creates students
The system SHALL provide the "New Student" modal solely to create a student, with a cohort selector, without any viewing or editing mode.

#### Scenario: AC-10 New student modal creates a student
**Side:** FE
- **GIVEN** an ERAS Administrator who opens "New Student" from the Students list
- **WHEN** they fill the required fields, select the cohort "Cohort 12" and press "Save"
- **THEN** the student is created, the modal closes and a success message is shown
- **AND** before saving, the modal showed the title "New Student" and the cohort selector, and no "Edit" button

### Requirement: The profile summary marks academic indicators with an icon
The system SHALL mark each field of Current academic information in the profile summary with an icon and a colour, so the indicators are easy to scan.

#### Scenario: AC-11 Academic fields carry an icon
**Side:** FE
- **GIVEN** a student with academic data, a third-attempt course and current courses
- **WHEN** a user with an ERAS role opens the profile summary
- **THEN** "Current CGPA", "SAP status", "Third attempt", "Passed courses", "Failed courses" and "Current courses" each show their own icon
- **AND** the fields keep the agreed order

### Requirement: The profile summary does not display fields outside the agreed list
The system SHALL NOT display in the profile summary any attribute that is not in the agreed list, and SHALL NOT delete or alter its stored data because it is hidden. The edit and creation forms keep their fields.

#### Scenario: AC-12 Profile summary no longer shows other fields
**Side:** FE
- **GIVEN** a student whose profile holds a date of birth, gender, nationality, secondary email, city, street, postal code, level of study, faculty, study modality and previous institution
- **WHEN** a user with an ERAS role opens the profile summary of that student
- **THEN** none of those fields or their values is shown
- **AND** the former free-text lists of identified risks and support received are not shown either

#### Scenario: AC-13 Edit and creation forms keep their fields
**Side:** FE
- **GIVEN** a user who can edit students
- **WHEN** they open "Edit Student Profile" for an existing student, and then "New Student"
- **THEN** both forms still show their current fields, including date of birth, gender, ID/passport number, city, street and level of study
- **AND** only the profile summary is limited to the three agreed sections

#### Scenario: AC-14 Saving a student does not alter the hidden data
**Side:** BE + FE
- **GIVEN** an existing student whose stored profile has a date of birth "2001-05-04", the free-text risk "Low attendance" and the city "San José"
- **WHEN** a user who can edit students changes the mobile number in "Edit Student Profile" and saves
- **THEN** the mobile number is updated
- **AND** the date of birth, the free-text risk, the city and every other stored value that is not shown keep their previous values

### Requirement: The profile summary and the edit modal load the selected student
The system SHALL load, in the profile summary and in the edit modal, the profile of the student that was selected, through the relationship the student already has with its profile, without creating a new profile.

#### Scenario: AC-15 Profile summary loads the selected student
**Side:** FE
- **GIVEN** the Students list with the students "Ana Torres" (id 42) and "Luis Anaya" (id 43)
- **WHEN** a user opens the profile summary of "Luis Anaya"
- **THEN** the summary requests the profile of student 43 only
- **AND** it shows the data of "Luis Anaya"

#### Scenario: AC-16 Edit modal loads the selected student
**Side:** FE
- **GIVEN** the Students list with the students "Ana Torres" (id 42) and "Luis Anaya" (id 43)
- **WHEN** a user who can manage students opens "Edit Student Profile" for "Luis Anaya"
- **THEN** the profile of student 43 only is requested
- **AND** the modal shows the data of "Luis Anaya" in its fields

## REMOVED Requirements

### Requirement: Both modals show the same three sections in the same order
**Reason**: The student record no longer has a viewing mode; the profile summary is the only read-only modal. Its three-section behavior is now covered by "The profile summary is the only read-only student profile modal" (AC-1).
**Migration**: The record-in-view-mode scenarios and the "same labels in both modals" scenario are dropped. The summary scenario is re-tagged to this change's AC-1.

### Requirement: Academic indicators are marked with an icon
**Reason**: Replaced by "The profile summary marks academic indicators with an icon"; the record has no viewing presentation anymore.
**Migration**: The summary scenario is re-tagged to this change's AC-11.

### Requirement: Fields outside the agreed list are not displayed
**Reason**: Replaced by "The profile summary does not display fields outside the agreed list"; the record has no viewing presentation anymore.
**Migration**: The summary, forms and preservation scenarios are re-tagged to this change's AC-12, AC-13 and AC-14; the record-in-view-mode scenario is dropped.

### Requirement: Each modal loads the selected student through the existing profile relationship
**Reason**: Replaced by "The profile summary and the edit modal load the selected student", since the record is now the edit modal.
**Migration**: The scenarios are re-tagged to this change's AC-15 and AC-16.
