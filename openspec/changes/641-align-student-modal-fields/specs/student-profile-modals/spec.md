## Purpose
Defines which attributes the student record and the student profile summary show, in which sections and order, so both modals present the same agreed profile of a student.

## ADDED Requirements

### Requirement: Both modals show the same three sections in the same order
The system SHALL show, in the student profile summary and in the student record when it is open for viewing, exactly three sections in this order: Personal information, Current academic information and Interventions, with the same titles and labels in both.

#### Scenario: AC-1 Profile summary shows the three sections in order
**Side:** FE
- **GIVEN** a user with an ERAS role and the student "Ana Torres" with profile data
- **WHEN** they open the profile summary of "Ana Torres"
- **THEN** the summary shows the sections "Personal information", "Current academic information" and "Interventions", in that order
- **AND** it shows no other section

#### Scenario: AC-2 Student record in view mode shows the three sections in order
**Side:** FE
- **GIVEN** a user with an ERAS role and the student "Ana Torres" with profile data
- **WHEN** they open the student record of "Ana Torres" for viewing
- **THEN** the record shows the sections "Personal information", "Current academic information" and "Interventions", in that order
- **AND** it shows no other section

#### Scenario: AC-18 Both modals show the same labels for the same student
**Side:** FE
- **GIVEN** the student "Ana Torres" with profile data
- **WHEN** the profile summary and the student record (in view mode) are each opened for "Ana Torres"
- **THEN** both show the same section titles, the same field labels and the same values, in the same order
- **AND** both are built from the same shared definition of sections and fields

### Requirement: Personal information shows the agreed fields in the agreed order
The system SHALL show in Personal information, in this order: first names, institutional email, SIS ID, ID/Passport number, mobile number, country and cohort, and nothing else.

#### Scenario: AC-3 Personal information fields and their order
**Side:** FE
- **GIVEN** the student with first name "Ana", last name "Torres", institutional email "ana.torres@jala.university", SIS ID "S-1001", ID/Passport number "AB-123456", mobile number "+506 8888 0000", country "Costa Rica" and cohort "Cohort 12"
- **WHEN** a user with an ERAS role opens the profile summary of "Ana Torres"
- **THEN** Personal information shows "First names", "Institutional email", "SIS ID", "ID/Passport number", "Mobile number", "Country" and "Cohort", in that order, with those values
- **AND** "First names" shows the full name as one value, "Ana Torres" (first, middle and last name, when each exists)

#### Scenario: AC-4 Missing personal values show a dash
**Side:** FE
- **GIVEN** a student with no ID/Passport number, no mobile number and no country
- **WHEN** a user with an ERAS role opens the profile summary of that student
- **THEN** "ID/Passport number", "Mobile number" and "Country" each show "-"
- **AND** the fields are still listed in their position

#### Scenario: AC-5 STU ID is replaced by SIS ID
**Side:** FE
- **GIVEN** the student "Ana Torres" whose SIS ID is "S-1001"
- **WHEN** a user with an ERAS role opens the profile summary of "Ana Torres"
- **THEN** the label "SIS ID" shows "S-1001"
- **AND** the text "STU ID" does not appear anywhere in the modal

#### Scenario: AC-6 SIS ID of an imported student is the one the import stored
**Side:** BE
- **GIVEN** a student created by an import whose SIS ID is "S-2002" and who has no registered profile
- **WHEN** a user with an ERAS role requests that student's profile
- **THEN** the API responds 200 OK and the response carries the SIS ID "S-2002"
- **AND** the same holds when the student has a registered profile whose own SIS ID is "S-9999" (the imported value is the one returned)

#### Scenario: AC-19 SIS ID of a manually registered student is the one of its profile
**Side:** BE
- **GIVEN** a student created with the "New Student" flow whose profile has the SIS ID "S-3003", and another created the same way with no SIS ID in its profile
- **WHEN** a user with an ERAS role requests the profile of each
- **THEN** the first response carries the SIS ID "S-3003" and the second carries no SIS ID
- **AND** the identifier that ERAS generated for the student is never returned as its SIS ID

### Requirement: Current academic information shows the agreed fields in the agreed order
The system SHALL show in Current academic information, in this order: current CGPA, SAP status, current course as a third attempt (only when it applies), passed courses count, failed courses count and current courses with their groups and sections, and nothing else.

#### Scenario: AC-7 Current academic information fields and their order
**Side:** FE
- **GIVEN** the student "Ana Torres" with CGPA 3.4, SAP status "Satisfactory", 7 passed courses and 1 failed course
- **WHEN** a user with an ERAS role opens the profile summary of "Ana Torres"
- **THEN** Current academic information shows "Current CGPA" 3.4, "SAP status" "Satisfactory", "Passed courses" 7, "Failed courses" 1 and the current courses, in that order
- **AND** no other field is shown in that section

#### Scenario: AC-8 Third-attempt field appears when it applies
**Side:** FE
- **GIVEN** a student whose current course is a third attempt
- **WHEN** a user with an ERAS role opens the profile summary of that student
- **THEN** the field "Third attempt" is shown between "SAP status" and "Passed courses"
- **AND** it is shown with a value that says the course is a third attempt

#### Scenario: AC-9 Third-attempt field is hidden when it does not apply
**Side:** FE
- **GIVEN** a student whose current course is not a third attempt, and another whose third-attempt status is unknown
- **WHEN** a user with an ERAS role opens the profile summary of each
- **THEN** the field "Third attempt" is not shown for either
- **AND** the remaining fields of the section keep their order with no gap

#### Scenario: AC-10 Current courses show their group and section
**Side:** FE
- **GIVEN** a student with the current courses "Algorithms" (group "A", section "2") and "Databases" (group "B", section "1")
- **WHEN** a user with an ERAS role opens the profile summary of that student
- **THEN** each course is listed with its name, group and section
- **AND** the courses are listed after "Failed courses", as the last field of the section

### Requirement: Academic indicators are marked with an icon
The system SHALL mark each field of Current academic information, in both modals, with an icon and a colour, so the indicators are easy to scan.

#### Scenario: AC-20 Academic fields carry an icon
**Side:** FE
- **GIVEN** a student with academic data, a third-attempt course and current courses
- **WHEN** a user with an ERAS role opens the profile summary or the student record in view mode
- **THEN** "Current CGPA", "SAP status", "Third attempt", "Passed courses", "Failed courses" and "Current courses" each show their own icon
- **AND** the fields keep the agreed order

### Requirement: Interventions shows risks identified and support received
The system SHALL show in Interventions the risks identified and the support received as two separate lists, each with an empty-state message when it has no entries, using the entries managed by change 643.

#### Scenario: AC-11 Interventions shows two separate lists
**Side:** FE
- **GIVEN** the student "Ana Torres" with one risk entry "Academic" and one support entry "Tutoring", and the student "Luis Anaya" with no entries
- **WHEN** a user with an ERAS role opens the profile summary of each
- **THEN** for "Ana Torres" the section Interventions lists "Academic" under risks identified and "Tutoring" under support received
- **AND** for "Luis Anaya" each list shows its empty-state message

### Requirement: Fields outside the agreed list are not displayed
The system SHALL NOT display, in either modal in its viewing presentation, any attribute that is not in the agreed list, and SHALL NOT delete or alter its stored data because it is hidden.

#### Scenario: AC-12 Profile summary no longer shows other fields
**Side:** FE
- **GIVEN** a student whose profile holds a date of birth, gender, nationality, secondary email, city, street, postal code, level of study, faculty, study modality and previous institution
- **WHEN** a user with an ERAS role opens the profile summary of that student
- **THEN** none of those fields or their values is shown
- **AND** the former free-text lists of identified risks and support received are not shown either

#### Scenario: AC-13 Student record in view mode no longer shows other fields
**Side:** FE
- **GIVEN** the same student, and a user with an ERAS role
- **WHEN** they open the student record for viewing
- **THEN** none of those fields or their values is shown
- **AND** only the fields of the three agreed sections are listed

#### Scenario: AC-14 Edit and creation forms keep their fields
**Side:** FE
- **GIVEN** a user who can edit students
- **WHEN** they open the student record to edit an existing student, and then to create a new student
- **THEN** both forms still show their current fields, including date of birth, gender, ID/passport number, city, street and level of study
- **AND** only the viewing presentation of the record ("Student Profile") is limited to the three agreed sections

#### Scenario: AC-15 Saving a student does not alter the hidden data
**Side:** BE + FE
- **GIVEN** an existing student whose stored profile has a date of birth "2001-05-04", the free-text risk "Low attendance" and the city "San José"
- **WHEN** a user who can edit students changes the mobile number from the record and saves
- **THEN** the mobile number is updated
- **AND** the date of birth, the free-text risk, the city and every other stored value that is not shown keep their previous values

### Requirement: Each modal loads the selected student through the existing profile relationship
The system SHALL load, in each modal, the profile of the student that was selected, through the relationship the student already has with its profile, without creating a new profile.

#### Scenario: AC-16 Profile summary loads the selected student
**Side:** FE
- **GIVEN** the Students list with the students "Ana Torres" (id 42) and "Luis Anaya" (id 43)
- **WHEN** a user opens the profile summary of "Luis Anaya"
- **THEN** the summary requests the profile of student 43 only
- **AND** it shows the data of "Luis Anaya"

#### Scenario: AC-17 Student record loads the selected student
**Side:** FE
- **GIVEN** the Students list with the students "Ana Torres" (id 42) and "Luis Anaya" (id 43)
- **WHEN** a user opens the student record of "Luis Anaya"
- **THEN** the record requests the profile of student 43 only
- **AND** it shows the data of "Luis Anaya"
