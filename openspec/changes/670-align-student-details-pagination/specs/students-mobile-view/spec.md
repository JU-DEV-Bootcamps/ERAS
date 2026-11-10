# Spec Delta

## ADDED Requirements

### Requirement: The pagination of the student details fits a mobile screen
The system SHALL show the range of the pagination of the Student Details modal, for example "21 – 30 of 46", on one line and on the same row as the page buttons on a screen narrower than 768px, and MUST leave every other pagination as it is.

#### Scenario: AC-1 Range of the student details pagination on one line
**Side:** FE
- **GIVEN** the Student Details modal of a student with 46 answers, on its second page, on a 375px wide screen
- **WHEN** the modal is shown
- **THEN** the range "21 – 30 of 46" is on one line
- **AND** the range and the page buttons are on the same row and none of them is cut or outside the modal

#### Scenario: AC-2 Student details pagination unchanged on a desktop
**Side:** FE
- **GIVEN** the same Student Details modal on a 1280px wide screen
- **WHEN** the modal is shown
- **THEN** the range "21 – 30 of 46" is on one line next to the page buttons, as it is today
- **AND** the page-size selector and all four page buttons are shown

#### Scenario: AC-3 Other paginations unchanged
**Side:** FE
- **GIVEN** a list outside the Student Details modal with 46 items, on a 375px wide screen
- **WHEN** the list is shown
- **THEN** its pagination keeps the range label with the style it has today
