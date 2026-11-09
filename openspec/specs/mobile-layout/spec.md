# mobile-layout Specification

## Purpose
Defines how the application shell, meaning the side menu and the page header, adapts to a mobile screen so that page content gets the full width.

## Requirements

### Requirement: The side menu is hidden by default on a mobile screen
The system SHALL hide the side menu by default on a screen narrower than 768px and let the page content use the full width of the screen.

#### Scenario: AC-1 Side menu is hidden and content uses the full width on mobile
**Side:** FE
- **GIVEN** a signed-in user on a 375px wide screen
- **WHEN** they open any page of the application
- **THEN** the side menu is not visible
- **AND** the page content starts at the left edge of the screen with no space reserved for the menu

### Requirement: The side menu opens over the content on demand on a mobile screen
The system SHALL show a menu button in the page header on a screen narrower than 768px, open the side menu over the content when it is pressed, and close the menu when the user picks a page or taps outside it.

#### Scenario: AC-2 Menu button opens the side menu over the content
**Side:** FE
- **GIVEN** a signed-in user on a 375px wide screen with the side menu hidden
- **WHEN** they press the menu button in the page header
- **THEN** the side menu is shown over the page content
- **AND** the page content keeps its position and width

#### Scenario: AC-3 Picking a page closes the side menu
**Side:** FE
- **GIVEN** a signed-in user on a 375px wide screen with the side menu open
- **WHEN** they pick the entry "Students"
- **THEN** the "Students" page is shown
- **AND** the side menu is closed

#### Scenario: AC-4 Tapping outside closes the side menu
**Side:** FE
- **GIVEN** a signed-in user on a 375px wide screen with the side menu open
- **WHEN** they tap on the page content outside the menu
- **THEN** the side menu is closed
- **AND** the page they were on is unchanged

### Requirement: The page header is compact on a mobile screen
The system SHALL show, in the page header of a screen narrower than 768px, only the menu button, the title the header shows on larger screens and the user menu, which keeps showing the user's name and role.

#### Scenario: AC-5 Header shows only the essentials on mobile
**Side:** FE
- **GIVEN** the signed-in user "Ana Torres" with the role "ERAS Administrator" on a 375px wide screen, and a header that shows the user's name, role and a notifications icon on larger screens
- **WHEN** they open the "Students" page
- **THEN** the page header shows the menu button, its title and the user menu
- **AND** the header itself does not show the text "Ana Torres", the text "ERAS Administrator" or the notifications icon

### Requirement: Screens of 768px and wider keep the current shell
The system MUST keep the current behavior of the side menu and the page header on a screen 768px wide or wider.

#### Scenario: AC-6 Desktop keeps the side menu beside the content
**Side:** FE
- **GIVEN** a signed-in user on a 1280px wide screen
- **WHEN** they open the "Students" page
- **THEN** the side menu is visible beside the page content
- **AND** the page header shows no menu button and still shows every element it shows today, including the user's name and role
