# Spec Delta

## Purpose
Defines how the configuration cards of the Settings page adapt to the screen width, so that they stay readable and proportionate on a small screen.

## ADDED Requirements

### Requirement: A configuration card is never wider than 350px on a screen narrower than 670px
The system SHALL limit the width of a configuration card to 350px and align it to the left of its row on a screen narrower than 670px.

#### Scenario: AC-1 Card is capped and left-aligned on a 500px screen
**Side:** FE
- **GIVEN** a user with the role "ERAS Administrator" and at least one configuration on a 500px wide screen
- **WHEN** they open the Settings page
- **THEN** each configuration card is 350px wide
- **AND** the card starts at the left edge of the area where the configuration cards are shown, the same place it starts today, with the free space on its right

#### Scenario: AC-2 Card fills the available width on a 375px screen
**Side:** FE
- **GIVEN** a user with the role "ERAS Administrator" and at least one configuration on a 375px wide screen
- **WHEN** they open the Settings page
- **THEN** each configuration card is as wide as the space available to it, which is less than 350px
- **AND** the cards are stacked

### Requirement: Screens of 670px and wider keep the current card layout
The system MUST keep the current layout of the configuration cards on a screen 670px wide or wider.

#### Scenario: AC-3 Card keeps its grid column width on a 1280px screen
**Side:** FE
- **GIVEN** a user with the role "ERAS Administrator" and at least one configuration on a 1280px wide screen
- **WHEN** they open the Settings page
- **THEN** each configuration card keeps the width of its grid column, with no cap and no alignment change applied
