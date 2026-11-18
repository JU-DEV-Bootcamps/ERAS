# Spec Delta

## Purpose
Defines how the list of manuals of User Manuals adapts to a mobile screen, and that the page is unchanged from 768px.

## ADDED Requirements

### Requirement: Each manual fits a mobile screen
The system SHALL show, on a screen narrower than 768px, each manual with its whole title inside the width of the screen, breaking a long title over several lines, and its Download button inside the row.

#### Scenario: AC-6 A manual with a long title fits the screen
**Side:** FE
- **GIVEN** a manual whose title is 100 characters long without spaces, on a 375px wide screen
- **WHEN** the user opens User Manuals
- **THEN** the whole title is shown inside its row, broken over several lines, and the Download button is inside the row
- **AND** the row is not wider than the screen and the page has no horizontal scroll

### Requirement: Screens of 768px and wider keep the current User Manuals
The system MUST keep the current layout of User Manuals on a screen 768px wide or wider.

#### Scenario: AC-8 Desktop keeps the current list
**Side:** FE
- **GIVEN** a manual with a title of 100 characters without spaces, on a 1280px wide screen
- **WHEN** the user opens User Manuals
- **THEN** the manual is shown as a row with its icon, its title, its details and a standard Material Download button, as today
- **AND** the title is not broken over several lines because of a mobile rule
