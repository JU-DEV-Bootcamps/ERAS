# students-mobile-view Specification

## Purpose
Defines how the Students list and the student modals adapt to a mobile screen so that every student record can be found, read and used without horizontal scrolling.

## Requirements

### Requirement: The Students list controls fit a mobile screen
The system SHALL show, on a screen narrower than 768px, the search field of the Students list on its own full-width row, with the Import, Export and New Student buttons below it, all reachable without horizontal scrolling.

#### Scenario: AC-7 Search and action buttons stack on mobile
**Side:** FE
- **GIVEN** a user with the role "ERAS Administrator" on a 375px wide screen, on the "Students" page with at least one student
- **WHEN** the page is shown
- **THEN** the search field is on its own row and as wide as the content
- **AND** the buttons "Import", "Export" and "New Student" are all visible below it and the page has no horizontal scroll

### Requirement: Each student is a readable card on a mobile screen
The system SHALL show, on a screen narrower than 768px, each student of the list as a card with its name, email, timely submissions, average score, last access and action icons, without horizontal scrolling.

#### Scenario: AC-8 Student card shows every column and the actions
**Side:** FE
- **GIVEN** the student "Ana Torres" in the Students list on a 375px wide screen
- **WHEN** the list is shown
- **THEN** "Ana Torres" appears as a card with "Name", "Email", "Timely Submissions", "Avg. Score" and "Last Access" and the action icons for that student
- **AND** the card and the page have no horizontal scroll

### Requirement: The Students list pagination fits a mobile screen
The system SHALL show, in the Students list on a screen narrower than 768px, a pagination with the range label and the previous and next buttons only, and the full pagination on wider screens and in every other list.

#### Scenario: AC-9 Pagination is reduced on mobile
**Side:** FE
- **GIVEN** the Students list with more than one page of students on a 375px wide screen
- **WHEN** the list is shown
- **THEN** the pagination shows the range label and the previous and next buttons
- **AND** it does not show the page-size selector or the first-page and last-page buttons

### Requirement: The student modals fill a mobile screen
The system SHALL open the student profile summary, the student details, the student record and the new student form at the full width and height of the screen when it is narrower than 768px, and MUST keep their current size on wider screens.

#### Scenario: AC-10 Student modals open full screen on mobile
**Side:** FE
- **GIVEN** a user on a 375px wide screen on the "Students" page
- **WHEN** they open the profile summary of a student
- **THEN** the modal covers the whole screen, with no margin around it
- **AND** the modal's Close button is visible without scrolling the page

#### Scenario: AC-13 Student details modal opens full screen on mobile
**Side:** FE
- **GIVEN** a user on a 375px wide screen on the "Students" page
- **WHEN** they open the details of a student with the "See more details" action
- **THEN** the modal covers the whole screen, with no margin around it
- **AND** the modal can be closed without scrolling the page

#### Scenario: AC-14 Student record opens full screen on mobile
**Side:** FE
- **GIVEN** a user on a 375px wide screen on the "Students" page
- **WHEN** they open the profile of a student with the "View profile" action
- **THEN** the modal covers the whole screen, with no margin around it
- **AND** its Close button is visible without scrolling the page

#### Scenario: AC-15 New student form opens full screen on mobile
**Side:** FE
- **GIVEN** a user with the role "ERAS Administrator" on a 375px wide screen on the "Students" page
- **WHEN** they press "New Student"
- **THEN** the form covers the whole screen, with no margin around it
- **AND** its Cancel button is visible without scrolling the page

#### Scenario: AC-11 Student modals keep their size on larger screens
**Side:** FE
- **GIVEN** a user on a 1280px wide screen on the "Students" page
- **WHEN** they open the profile summary of a student
- **THEN** the modal opens at its current width of 1100px, centered over the page
- **AND** the page behind it stays visible around the modal

### Requirement: Current courses are stacked on a mobile screen
The system SHALL list, on a screen narrower than 768px, each current course in the student profile with its name, group and section stacked, instead of a wide table.

#### Scenario: AC-12 Current courses are readable without horizontal scroll
**Side:** FE
- **GIVEN** the student "Ana Torres" with the current courses "Algorithms" (group "A", section "2") and "Databases" (group "B", section "1"), on a 375px wide screen
- **WHEN** a user opens the profile summary of "Ana Torres"
- **THEN** each course is shown with its name, group and section one under the other
- **AND** the modal has no horizontal scroll

### Requirement: The student details header fits a mobile screen
The system SHALL show, in the new student details modal on a screen narrower than 768px, the student's name, email and UUID one under the other and the Export, Print and Create Assessment buttons together in one row below them, none of them cut off.

#### Scenario: AC-16 Student details header is readable on mobile
**Side:** FE
- **GIVEN** the student "Ana Torres" with an email and a UUID, on a 375px wide screen
- **WHEN** a user opens her details with the "See more details" action
- **THEN** her name, email and UUID are shown one under the other, each one fully inside the modal
- **AND** the Export, Print and Create Assessment buttons are in the same row below them, inside the modal and without horizontal scroll
