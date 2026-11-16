# Spec Delta

## Purpose
Defines how the Assessments section, meaning the Assessments and Interventions tabs, their details and their dialogs, adapts to a mobile screen so that every assessment and intervention can be read, opened, created and changed without horizontal scrolling.

## ADDED Requirements

### Requirement: Each assessment is a readable card on a mobile screen
The system SHALL show, on a screen narrower than 768px, each assessment of the Assessments list as a card with its date, submitter, service, professionals, students, status and comment, without horizontal scrolling.

#### Scenario: AC-1 Assessment card shows every field without horizontal scroll
**Side:** FE
- **GIVEN** an assessment of the student "Ana Torres" with the professional "Luis Gómez" and the status "Remitted", and a user with the role "ERAS Administrator" on a 375px wide screen
- **WHEN** they open the Assessments tab
- **THEN** the assessment appears as a card with its date, submitter, service, "Luis Gómez", "Ana Torres", "Remitted" and its comment, and no table is shown
- **AND** the card, the pagination and the page have no horizontal scroll

### Requirement: Each intervention is a readable card on a mobile screen
The system SHALL show, on a screen narrower than 768px, each intervention of the Interventions list as a card with its date, type, mode, activity, professional, student, area, risk level, end risk level, status and comment, without horizontal scrolling.

#### Scenario: AC-2 Intervention card shows every field without horizontal scroll
**Side:** FE
- **GIVEN** an intervention with the activity "Workshop", the professional "Luis Gómez", the risk level "High" and the status "In Progress", in the selected assessment, on a 375px wide screen
- **WHEN** a user with an ERAS role opens the Interventions tab
- **THEN** the intervention appears as a card with its date, type, mode, "Workshop", "Luis Gómez", student, area, "High", end risk level, "In Progress" and its comment, and no table is shown
- **AND** the card, the pagination and the page have no horizontal scroll

### Requirement: The Interventions controls fit a mobile screen
The system SHALL show, on a screen narrower than 768px, the filters of the Interventions tab one below the other, each as wide as the content, with the Export and Create Intervention buttons reachable without horizontal scrolling.

#### Scenario: AC-3 Filters and buttons stack on mobile
**Side:** FE
- **GIVEN** a user with the role "ERAS Administrator" on a 375px wide screen, on the Interventions tab with an assessment that is not Finalized selected
- **WHEN** the tab is shown
- **THEN** the Assessment, Type, Status and Risk filters are one below the other, none wider than the content
- **AND** the Export button and the "Create Intervention" button are visible and the page has no horizontal scroll

### Requirement: The details cover the whole screen on a mobile screen
The system SHALL show, on a screen narrower than 768px, the detail of an assessment and the detail of an intervention over the whole screen instead of a 480px side panel, with a close button that is visible without scrolling and returns the user to the list.

#### Scenario: AC-4 Assessment detail opens full screen with a visible close button
**Side:** FE
- **GIVEN** a user on a 375px wide screen on the Assessments tab with the assessment of "Ana Torres"
- **WHEN** they use the View action of that assessment
- **THEN** the detail covers the whole width and height of the screen, with its close button visible without scrolling and nothing cut off at the sides
- **AND** pressing the close button shows the list of assessments again

#### Scenario: AC-5 Intervention detail opens full screen with a visible close button
**Side:** FE
- **GIVEN** a user on a 375px wide screen on the Interventions tab with the intervention "Workshop"
- **WHEN** they use the View action of that intervention
- **THEN** the detail covers the whole width and height of the screen, with its close button visible without scrolling and nothing cut off at the sides
- **AND** pressing the close button shows the list of interventions again

### Requirement: Actions are reachable by tap on a mobile screen
The system SHALL show, on a screen narrower than 768px, the View, Edit and Delete actions of each assessment and intervention as icon buttons on its card, and SHALL show the full list of students of an assessment with a tap, all without a hover and without horizontal scrolling.

#### Scenario: AC-6 Assessment actions are reachable from the card
**Side:** FE
- **GIVEN** a user with the role "ERAS Administrator" on a 375px wide screen and an assessment with the status "Remitted"
- **WHEN** the card of the assessment is shown
- **THEN** the card shows the View, Edit and Delete actions as three icon buttons, each started with one tap
- **AND** none of them needs a hover, a menu or a horizontal scroll

#### Scenario: AC-7 Intervention actions are reachable from the card
**Side:** FE
- **GIVEN** a user with the role "ERAS Administrator" on a 375px wide screen and an intervention with the status "In Progress" in an assessment that is not Finalized
- **WHEN** the card of the intervention is shown
- **THEN** the card shows the View, Edit and Delete actions as three icon buttons, each started with one tap
- **AND** none of them needs a hover, a menu or a horizontal scroll

#### Scenario: AC-8 Extra student names open with a tap inside the screen
**Side:** FE
- **GIVEN** an assessment with the students "Ana Torres", "Luis Rojas" and "Eva Paz" whose card shows a "+2" badge, on a 375px wide screen
- **WHEN** the user taps the "+2" badge
- **THEN** the names of the three students are shown
- **AND** the list of names is completely inside the screen

### Requirement: The forms can be completed on a mobile screen
The system SHALL open, on a screen narrower than 768px, the forms to create and to edit an assessment and an intervention at the full width and height of the screen, with every field and the Cancel and save buttons reachable, and SHALL save them as on desktop.

#### Scenario: AC-9 Create an assessment on mobile
**Side:** FE
- **GIVEN** a user with the role "ERAS Student Services Officer" on a 375px wide screen on the Assessments tab
- **WHEN** they press "Create Assessment", fill in the required fields and press the create button
- **THEN** the form covers the whole screen with no field cut off, and its Cancel and create buttons are reachable
- **AND** the assessment is saved and appears in the list

#### Scenario: AC-10 Create an intervention on mobile
**Side:** FE
- **GIVEN** a user with the role "ERAS Professional" on a 375px wide screen on the Interventions tab, with an assessment that is not Finalized selected
- **WHEN** they press "Create Intervention", fill in the required fields and press the create button
- **THEN** the form covers the whole screen with no field cut off, and its Cancel and create buttons are reachable
- **AND** the intervention is saved and appears in the list

#### Scenario: AC-11 Edit an assessment on mobile
**Side:** FE
- **GIVEN** a user with the role "ERAS Administrator" on a 375px wide screen and an assessment with the status "Remitted"
- **WHEN** they use the Edit action of the assessment
- **THEN** the edit form covers the whole screen with no field cut off
- **AND** its Cancel and save buttons are reachable

#### Scenario: AC-12 Edit an intervention on mobile
**Side:** FE
- **GIVEN** a user with an ERAS role on a 375px wide screen and an intervention with the status "In Progress" in an assessment that is not Finalized
- **WHEN** they use the Edit action of the intervention
- **THEN** the edit form covers the whole screen with no field cut off, including the attached documents
- **AND** its Cancel and save buttons are reachable

### Requirement: The other dialogs of the section fit a mobile screen
The system SHALL show, on a screen narrower than 768px, the delete confirmations of the Assessments section inside the screen with both of their buttons visible, and SHALL open the student details from the detail of an assessment at the full width and height of the screen.

#### Scenario: AC-13 Delete confirmation fits the screen
**Side:** FE
- **GIVEN** a user with the role "ERAS Administrator" on a 375px wide screen and an intervention in an assessment that is not Finalized
- **WHEN** they use the Delete action of the intervention
- **THEN** the confirmation is no wider than the screen
- **AND** its cancel and confirm buttons are both visible without horizontal scrolling

#### Scenario: AC-14 Student details open full screen from an assessment
**Side:** FE
- **GIVEN** a user on a 375px wide screen with the detail of the assessment of "Ana Torres" open
- **WHEN** they open the details of "Ana Torres" from the list of students of the assessment
- **THEN** the student details cover the whole screen, with no margin around them
- **AND** they can be closed without scrolling the page

### Requirement: Blocked actions stay blocked on a mobile screen
The system MUST block on a screen narrower than 768px every action of the Assessments section that the user's role or a Finalized status blocks on a wider screen, and MUST NOT offer on mobile an action that is not offered on desktop.

#### Scenario: AC-15 Professional cannot manage assessments on mobile
**Side:** FE
- **GIVEN** a user with the role "ERAS Professional" and an assessment with the status "Remitted"
- **WHEN** they open the Assessments tab on a 375px wide screen
- **THEN** the "Create Assessment" button and the Edit and Delete actions of the assessment card are shown disabled and cannot be used, as on desktop
- **AND** the View action of the assessment is available, as on desktop

#### Scenario: AC-16 A Finalized assessment blocks the same actions on mobile
**Side:** FE
- **GIVEN** a user with the role "ERAS Administrator" on a 375px wide screen and an assessment with the status "Finalized" that has one intervention
- **WHEN** they open the Assessments tab, then select that assessment on the Interventions tab
- **THEN** the Edit action of the assessment cannot be used, and the Edit and Delete actions of its intervention cannot be used
- **AND** the "Create Intervention" button above the list is not shown, as on desktop

### Requirement: Screens of 768px and wider keep the current Assessments section
The system MUST keep, on a screen 768px wide or wider, the tables, the 480px side panel beside the list, the action controls of the rows and the sizes of the dialogs of the Assessments section as they are today.

#### Scenario: AC-17 Desktop keeps the assessments table and the side panel
**Side:** FE
- **GIVEN** a user with the role "ERAS Administrator" on a 1280px wide screen on the Assessments tab
- **WHEN** they use the View action of an assessment
- **THEN** the assessments are a table with the actions of each row in its "more" menu, and no card is shown
- **AND** the detail opens as a 480px panel beside the table, which stays visible

#### Scenario: AC-18 Desktop keeps the interventions table and the side panel
**Side:** FE
- **GIVEN** a user with the role "ERAS Administrator" on a 1280px wide screen on the Interventions tab with an assessment selected
- **WHEN** they use the View action of an intervention
- **THEN** the interventions are a table with the actions of each row in its "more" menu, the filters are in one row, and no card is shown
- **AND** the detail opens as a 480px panel beside the table, which stays visible

#### Scenario: AC-19 Desktop keeps the dialog sizes
**Side:** FE
- **GIVEN** a user with the role "ERAS Administrator" on a 1280px wide screen
- **WHEN** they open the form to create an assessment, and then the form to create an intervention
- **THEN** the assessment form opens centered at 40% of the screen width, 512px, and the intervention form at 520px
- **AND** the page behind each form stays visible around it
