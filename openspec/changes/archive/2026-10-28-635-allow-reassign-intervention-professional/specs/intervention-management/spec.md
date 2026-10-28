## Purpose
Defines how interventions are managed in the Interventions section, starting with who can change the professional assigned to an intervention.

## ADDED Requirements

### Requirement: Reassign the professional of an intervention
The system SHALL let every user with an ERAS role change the professional assigned to an intervention, and SHALL reject users without an ERAS role.

#### Scenario: AC-1 Administrator reassigns the professional
**Side:** BE + FE
- **GIVEN** a user with the role "ERAS Administrator" editing an intervention assigned to "Ana Pérez"
- **WHEN** they select "Luis Gómez" as the professional and confirm
- **THEN** the intervention is saved with "Luis Gómez" as its professional
- **AND** the intervention shows "Luis Gómez" immediately, without reloading the page

#### Scenario: AC-2 Student Services Officer reassigns the professional
**Side:** BE + FE
- **GIVEN** a user with the role "ERAS Student Services Officer" editing an intervention assigned to "Ana Pérez"
- **WHEN** they select "Luis Gómez" as the professional and confirm
- **THEN** the intervention is saved with "Luis Gómez" as its professional
- **AND** the intervention shows "Luis Gómez" immediately

#### Scenario: AC-3 Professional reassigns the professional
**Side:** BE + FE
- **GIVEN** a user with the role "ERAS Professional" editing an intervention assigned to "Ana Pérez"
- **WHEN** they select "Luis Gómez" as the professional and confirm
- **THEN** the intervention is saved with "Luis Gómez" as its professional
- **AND** the intervention shows "Luis Gómez" immediately

#### Scenario: AC-4 Guest cannot reassign the professional through the API
**Side:** BE
- **GIVEN** a user with no ERAS role (Guest)
- **WHEN** they send an update of an intervention with a different professional
- **THEN** the API responds 403 Forbidden
- **AND** the intervention keeps its current professional

#### Scenario: AC-5 Edit modal offers a selectable professional
**Side:** FE
- **GIVEN** a user with any ERAS role opens the edit modal of an intervention
- **WHEN** the modal is shown
- **THEN** the Professional field is enabled and lists the professionals that can be assigned
- **AND** the current professional is preselected

#### Scenario: AC-6 Professional is required
**Side:** FE
- **GIVEN** a user editing an intervention
- **WHEN** they clear the Professional field and try to save
- **THEN** the form is not submitted and the field shows it is required
- **AND** the intervention is not changed

#### Scenario: AC-7 Reassigning does not alter other fields
**Side:** BE
- **GIVEN** an intervention with activity "Workshop", status "In Progress", comments "First session" and attached documents
- **WHEN** a user with an ERAS role changes only the professional and saves
- **THEN** activity, status, comments, students, attendance and attached documents keep their previous values
- **AND** only the professional differs

#### Scenario: AC-8 Existing interventions are not affected
**Side:** BE
- **GIVEN** interventions that already exist with an assigned professional
- **WHEN** the system is used after this change without anyone editing them
- **THEN** each intervention still has the same professional it had before

#### Scenario: AC-10 New professional is added to the assessment
**Side:** BE
- **GIVEN** an intervention in an assessment whose professionals are "Ana Pérez", and a user with any ERAS role
- **WHEN** they reassign the intervention to "Luis Gómez" and confirm
- **THEN** the assessment's professionals are "Ana Pérez" and "Luis Gómez"
- **AND** the intervention's professional is "Luis Gómez"

#### Scenario: AC-11 A professional already in the assessment is not duplicated
**Side:** BE
- **GIVEN** an assessment whose professionals are "Ana Pérez" and "Luis Gómez", with an intervention assigned to "Ana Pérez"
- **WHEN** a user reassigns that intervention to "Luis Gómez"
- **THEN** the assessment's professionals are still "Ana Pérez" and "Luis Gómez", each listed once
- **AND** the intervention's professional is "Luis Gómez"

#### Scenario: AC-12 Other interventions and the assessment keep their data
**Side:** BE
- **GIVEN** an assessment with two interventions, both assigned to "Ana Pérez", and with students "S1" and "S2"
- **WHEN** a user reassigns only the first intervention to "Luis Gómez"
- **THEN** the second intervention is still assigned to "Ana Pérez"
- **AND** the assessment's students and its other data are unchanged

#### Scenario: AC-13 The added professional can see the assessment
**Side:** BE
- **GIVEN** an intervention reassigned to "Luis Gómez", who has the role "ERAS Professional"
- **WHEN** "Luis Gómez" asks for the assessments assigned to him
- **THEN** the assessment is included
- **AND** "Ana Pérez" still sees it too

#### Scenario: AC-14 Existing assessments keep their professional
**Side:** BE
- **GIVEN** assessments that already have one assigned professional before this change
- **WHEN** the system is used after this change without anyone editing them
- **THEN** each assessment has exactly that professional and is visible to them as before
- **AND** no professional is added or removed

#### Scenario: AC-15 The assessment list shows every professional
**Side:** FE
- **GIVEN** an assessment whose professionals are "Ana Pérez" and "Luis Gómez"
- **WHEN** a user with any ERAS role opens the assessment list
- **THEN** the row shows both "Ana Pérez" and "Luis Gómez"
- **AND** an assessment with a single professional shows just that name

#### Scenario: AC-16 Edit the full list of professionals of an assessment
**Side:** BE + FE
- **GIVEN** an assessment whose professionals are "Ana Pérez", and an Administrator or Student Services Officer editing it
- **WHEN** they add "Luis Gómez" in the assessment form and save
- **THEN** the assessment's professionals are "Ana Pérez" and "Luis Gómez"
- **AND** the assessment's students and other data keep their previous values

#### Scenario: AC-17 Remove a professional who has no interventions in the assessment
**Side:** BE
- **GIVEN** an assessment whose professionals are "Ana Pérez" and "Luis Gómez", and no intervention of that assessment is assigned to "Luis Gómez"
- **WHEN** an Administrator or Student Services Officer removes "Luis Gómez" from the list and saves
- **THEN** the assessment's professionals are only "Ana Pérez"
- **AND** the assessment's interventions are unchanged

#### Scenario: AC-18 Cannot remove a professional who has interventions in the assessment
**Side:** BE
- **GIVEN** an assessment whose professionals are "Ana Pérez" and "Luis Gómez", and an intervention of that assessment is assigned to "Luis Gómez"
- **WHEN** an Administrator or Student Services Officer removes "Luis Gómez" from the list and saves
- **THEN** the API responds 409 Conflict with a message saying "Luis Gómez" still has interventions in this assessment
- **AND** the assessment keeps both professionals

#### Scenario: AC-19 The form shows why a professional cannot be removed
**Side:** FE
- **GIVEN** an Administrator or Student Services Officer who removed a professional that has interventions in the assessment
- **WHEN** they save and the API responds 409 Conflict
- **THEN** the form shows the message returned and stays open
- **AND** the professional list in the form is not saved
