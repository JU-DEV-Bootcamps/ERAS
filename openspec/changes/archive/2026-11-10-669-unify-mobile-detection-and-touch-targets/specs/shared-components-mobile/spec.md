# Spec Delta

## Purpose
Defines how the shared table components and the students preview of the answers import adapt to a phone screen, and how big their action controls are to tap.

## ADDED Requirements

### Requirement: The shared tables follow the mobile rule of the app
The system SHALL show each shared table component as cards on a screen narrower than 768px and as a table from 768px, and SHALL switch between both when the screen is resized, without reloading the page.

#### Scenario: AC-1 Table with actions switches between cards and table
**Side:** FE
- **GIVEN** the table with actions showing two students with their columns and an action
- **WHEN** the screen is 375px wide, then it is resized to 1280px
- **THEN** at 375px each student is a card with every column and the action, and no table is shown
- **AND** at 1280px a table with the same students is shown and no card is shown

#### Scenario: AC-2 Table switches between cards and table
**Side:** FE
- **GIVEN** the table showing two rows with their columns
- **WHEN** the screen is 375px wide, then it is resized to 1280px
- **THEN** at 375px each row is a card and no table is shown
- **AND** at 1280px a table with the same rows is shown and no card is shown

#### Scenario: AC-3 Table with redirect switches between cards and table
**Side:** FE
- **GIVEN** the table with redirect showing two rows with their columns and the detail button
- **WHEN** the screen is 375px wide, then it is resized to 1280px
- **THEN** at 375px each row is a card with its detail button and no table is shown
- **AND** at 1280px a table with the same rows and a detail button per row is shown and no card is shown

### Requirement: The answers import preview follows the mobile rule of the app
The system SHALL show, in the students preview of the answers import, each student as a card on a screen narrower than 768px and as a table from 768px, and SHALL switch between both when the screen is resized.

#### Scenario: AC-4 Students preview switches between cards and table
**Side:** FE
- **GIVEN** the students preview of the answers import with two students
- **WHEN** the screen is 375px wide, then it is resized to 1280px
- **THEN** at 375px each student is a card with its columns and its save switch, and no table is shown
- **AND** at 1280px a table with the same students is shown and no card is shown

### Requirement: Action controls of the shared tables are big enough to tap on mobile
The system SHALL give each action control of the shared table components, shown on a screen narrower than 768px, a tap area of at least 48 by 48 pixels, and SHALL leave their size unchanged from 768px.

#### Scenario: AC-5 Card actions of the table with actions are at least 48 by 48
**Side:** FE
- **GIVEN** the table with actions showing a student with two icon actions, on a 375px wide screen
- **WHEN** the cards are shown
- **THEN** the tap area of each action is at least 48 pixels wide and 48 pixels high
- **AND** the tap areas of the actions do not overlap each other and the card keeps its height

#### Scenario: AC-6 Detail button of the table with redirect is at least 48 by 48
**Side:** FE
- **GIVEN** the table with redirect showing a row with its detail button, on a 375px wide screen
- **WHEN** the card is shown
- **THEN** the tap area of the detail button is at least 48 pixels wide and 48 pixels high
- **AND** the card keeps its height

#### Scenario: AC-7 Desktop controls keep their size
**Side:** FE
- **GIVEN** the table with actions and the table with redirect showing rows with their action controls, on a 1280px wide screen
- **WHEN** the tables are shown
- **THEN** no control is enlarged: each one keeps its standard Material size
- **AND** the rows keep their current height
