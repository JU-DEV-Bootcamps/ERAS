# Spec Delta

## Purpose
Defines how Account & Information adapts to a mobile screen: the profile card and the professional info fit the screen, and the page is unchanged from 768px.

## ADDED Requirements

### Requirement: The profile card fits a mobile screen
The system SHALL show, on a screen narrower than 768px, the profile card with its values one per row and every value inside the card, breaking a long value over several lines, so that the page has no horizontal scroll.

#### Scenario: AC-1 The profile card is stacked and readable
**Side:** FE
- **GIVEN** a signed-in user whose email is 60 characters long without spaces, on a 375px wide screen
- **WHEN** they open Account & Information
- **THEN** the profile card shows its values one per row, and the whole email is shown inside the card, broken over several lines
- **AND** the card is not wider than the screen and the page has no horizontal scroll

### Requirement: The professional info fits a mobile screen
The system SHALL show, on a screen narrower than 768px, the professional info of a professional in one column, with the whole code and name of each course inside its card, breaking a long one over several lines, and no horizontal scroll of the page.

#### Scenario: AC-2 The professional info is stacked and its courses fit
**Side:** FE
- **GIVEN** an "ERAS Professional" with two courses, one of them with a course name of 80 characters without spaces, on a 375px wide screen
- **WHEN** they open Account & Information
- **THEN** the information sections are shown one below the other in one column and each course shows its code and its whole name inside the card
- **AND** the page has no horizontal scroll

### Requirement: Screens of 768px and wider keep the current Account & Information
The system MUST keep the current layout of Account & Information on a screen 768px wide or wider.

#### Scenario: AC-5 Desktop keeps the current layout
**Side:** FE
- **GIVEN** a signed-in user on a 1280px wide screen
- **WHEN** they open Account & Information
- **THEN** the profile card shows its values in two columns and the professional info shows its sections in two columns, as today
- **AND** no value is broken over several lines because of a mobile rule
