# home-mobile-view Specification

## Purpose
Defines how the Home page, the recent alerts adapt to a mobile screen so that every section can be read without horizontal scrolling.

## Requirements

### Requirement: Home summary cards are stacked on a mobile screen
The system SHALL show, on a screen narrower than 768px, the summary cards of Home in one column, each as wide as the content and none cut off.

#### Scenario: AC-1 Summary cards stack in one column on mobile
**Side:** FE
- **GIVEN** a signed-in user on a 375px wide screen
- **WHEN** they open Home
- **THEN** the cards "Number of Students", "Polls Answered" and "Evaluations" are one below the other
- **AND** none is cut off and the page has no horizontal scroll

### Requirement: Recent alerts are readable on a mobile screen
The system SHALL show, on a screen narrower than 768px, each recent alert as a card with student id, student name, risk level, category, date and status, on Home and on the Recent Alerts page, without horizontal scrolling.

#### Scenario: AC-2 Recent alerts are cards without horizontal scroll on mobile
**Side:** FE
- **GIVEN** a recent alert of the student "Ana Torres" with risk level "High" on a 375px wide screen
- **WHEN** the user opens the Recent Alerts page
- **THEN** the alert appears as a card with student id, "Ana Torres", "High", category, date and status
- **AND** the card and the page have no horizontal scroll

#### Scenario: AC-3 Recent alerts block fits the width on Home on mobile
**Side:** FE
- **GIVEN** at least one recent alert on a 375px wide screen
- **WHEN** the user opens Home
- **THEN** the "Recent Alerts" block with its "View All" link is as wide as the content, below the summary cards
- **AND** the page has no horizontal scroll

### Requirement: Connected services fit a mobile screen
The system SHALL show, on a screen narrower than 768px, each connected service card as wide as the content instead of a fixed width.

#### Scenario: AC-4 Service cards fit the width on mobile
**Side:** FE
- **GIVEN** at least one connected service on a 375px wide screen
- **WHEN** the user opens Home
- **THEN** each service card is no wider than the content
- **AND** the page has no horizontal scroll

### Requirement: Every role sees the same Home sections on mobile
The system SHALL show on a mobile screen to the roles "ERAS Professional", "ERAS Student Services Officer" and "ERAS Administrator" the same Home sections they see on desktop.

#### Scenario: AC-6 Professional sees the same sections on mobile
**Side:** FE
- **GIVEN** a user with the role "ERAS Professional"
- **WHEN** they open Home on a 375px wide screen and on a 1280px wide screen
- **THEN** both show the same sections: Overview, summary cards, Recent Alerts and Connected Services

#### Scenario: AC-7 Officer sees the same sections on mobile
**Side:** FE
- **GIVEN** a user with the role "ERAS Student Services Officer"
- **WHEN** they open Home on a 375px wide screen and on a 1280px wide screen
- **THEN** both show the same sections: Overview, summary cards, Recent Alerts and Connected Services

#### Scenario: AC-8 Administrator sees the same sections on mobile
**Side:** FE
- **GIVEN** a user with the role "ERAS Administrator"
- **WHEN** they open Home on a 375px wide screen and on a 1280px wide screen
- **THEN** both show the same sections: Overview, summary cards, Recent Alerts and Connected Services

### Requirement: Screens of 768px and wider keep the current Home
The system MUST keep the three-column Home layout, with the Recent Alerts block spanning two columns, on a screen 768px wide or wider.

#### Scenario: AC-9 Desktop keeps three columns
**Side:** FE
- **GIVEN** a signed-in user on a 1280px wide screen
- **WHEN** they open Home
- **THEN** the three summary cards are side by side in one row
- **AND** the Recent Alerts block spans two of the three columns
