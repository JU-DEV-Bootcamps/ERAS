# Spec Delta

## Purpose
Defines which panels the account information page shows for each role, how the professional info section loads and saves its data, and which fields the profile edit form offers.

## ADDED Requirements

### Requirement: The professional info section replaces the summary panel for professionals
The page MUST show the professional info section in place of the profile summary panel for the ERAS Professional role, and MUST show the profile summary panel and no professional info section for every other role.

#### Scenario: AC-10 Professional sees professional info instead of the summary
**Side:** FE
- **GIVEN** a signed-in user with the role "ERAS Professional"
- **WHEN** they open the account information page
- **THEN** the professional info section is shown in the place of the profile summary panel
- **AND** the profile summary panel is not shown

#### Scenario: AC-11 Officer sees the summary and no professional info
**Side:** FE
- **GIVEN** a signed-in user with the role "ERAS Student Services Officer"
- **WHEN** they open the account information page
- **THEN** the profile summary panel is shown
- **AND** the professional info section is not shown

### Requirement: The professional info section shows and saves the professional profile from the backend
The professional info section MUST display the values returned by the backend and MUST save the values the professional submits through the backend.

#### Scenario: AC-12 Professional info shows the saved values
**Side:** FE
- **GIVEN** the backend returns a professional profile with faculty "Engineering" and office hours "Mon 9:00-11:00"
- **WHEN** the professional opens the account information page
- **THEN** the professional info section shows "Engineering" as faculty and "Mon 9:00-11:00" as office hours

#### Scenario: AC-19 Active interventions are shown read-only
**Side:** FE
- **GIVEN** a professional whose account reports 7 active interventions
- **WHEN** they open the account information page
- **THEN** the professional info section shows "Active Interventions" with the value 7
- **AND** no input is offered to change that value

#### Scenario: AC-13 Saved professional info is shown after saving
**Side:** FE
- **GIVEN** a professional is editing the professional info section
- **WHEN** they change faculty to "Science" and save with all required fields filled
- **THEN** the section returns to view mode showing "Science" as faculty

#### Scenario: AC-14 Failed save keeps the form open with the typed values
**Side:** FE
- **GIVEN** a professional is editing the professional info section and the backend answers with an error
- **WHEN** they save
- **THEN** an error message is shown
- **AND** the form stays open with the typed values

### Requirement: Position is edited only in the professional info section for professionals
The profile edit form MUST NOT show the Position field to an ERAS Professional, and MUST NOT send a position change when the professional saves it. For every other role the profile edit form MUST keep the Position field.

#### Scenario: AC-15 Professional's profile edit form has no Position field
**Side:** FE
- **GIVEN** a signed-in user with the role "ERAS Professional"
- **WHEN** they open the profile edit form
- **THEN** no Position field is shown
- **AND** saving the form does not send a position value

#### Scenario: AC-16 Officer's profile edit form keeps the Position field
**Side:** FE
- **GIVEN** a signed-in user with the role "ERAS Student Services Officer"
- **WHEN** they open the profile edit form
- **THEN** a Position field is shown with their current position
