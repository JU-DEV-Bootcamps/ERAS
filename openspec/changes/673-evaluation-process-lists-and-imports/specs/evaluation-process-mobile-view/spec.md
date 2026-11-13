# Spec Delta

## Purpose
Defines how the cards of the Evaluation Process list handle long values on a phone screen, and that the table shown on a desktop screen stays unchanged.

## ADDED Requirements

### Requirement: A long Poll Name stays inside the evaluation process card on a mobile screen
The system SHALL show, on a screen narrower than 768px, the whole Poll Name of an evaluation process inside its card, breaking it over several lines when it has no spaces, so that the card is never wider than the screen.

#### Scenario: AC-1 A long Poll Name stays inside the card
**Side:** FE
- **GIVEN** an evaluation process whose Poll Name is 100 characters long without spaces, on a 375px wide screen
- **WHEN** the user opens Evaluation Process
- **THEN** the whole Poll Name is shown inside its card, broken over several lines
- **AND** the card is not wider than the screen and the page has no horizontal scroll

### Requirement: Screens of 768px and wider keep the current table of evaluation processes
The system MUST keep showing the evaluation processes as a table with its current columns on a screen 768px wide or wider.

#### Scenario: AC-2 Desktop keeps the table
**Side:** FE
- **GIVEN** evaluation processes, one of them with a Poll Name of 100 characters without spaces, on a 1280px wide screen
- **WHEN** the user opens Evaluation Process
- **THEN** the evaluation processes are shown in a table with the same columns as today and no card is shown
- **AND** the Poll Name is not broken over several lines
