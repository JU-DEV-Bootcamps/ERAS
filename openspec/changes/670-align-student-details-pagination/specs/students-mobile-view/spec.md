# Spec Delta

## ADDED Requirements

### Requirement: The pagination of the student details fits a mobile screen
The system SHALL show the range of the pagination of the Student Details modal, for example "21 – 30 of 46", on one line on a screen narrower than 768px, and on the same row as the page buttons from 375px wide, and MUST leave every other pagination as it is.

#### Scenario: AC-1 Range of the student details pagination on one line
**Side:** FE
- **GIVEN** the Student Details modal of a student with 46 answers, on its third page, on a 375px wide screen
- **WHEN** the modal is shown
- **THEN** the range "21 – 30 of 46" is on one line
- **AND** the range and the page buttons are on the same row and none of them is cut or outside the modal

#### Scenario: AC-2 Student details pagination unchanged on a desktop
**Side:** FE
- **GIVEN** the same Student Details modal, on its third page, on a 1280px wide screen
- **WHEN** the modal is shown
- **THEN** the range "21 – 30 of 46" is on one line next to the page buttons, as it is today
- **AND** the page-size selector and all four page buttons are shown

#### Scenario: AC-3 Other paginations unchanged
**Side:** FE
- **GIVEN** a pagination of 46 items shown outside the answers of the Student Details modal, on a 375px wide screen
- **WHEN** the Student Details modal is shown
- **THEN** that pagination keeps the style of its range label, its container and its buttons as it has today

#### Scenario: AC-4 Student details pagination on the narrowest phones
**Side:** FE
- **GIVEN** the Student Details modal of a student with 46 answers, on its third page, on a 320px wide screen
- **WHEN** the modal is shown
- **THEN** the range "21 – 30 of 46" is on one line
- **AND** the range and the page buttons are shown inside the card of the answers, with the buttons below the range

