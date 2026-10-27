## Purpose
Defines how internal users find and browse students in the Students view, starting with searching the full list of students by name.

## ADDED Requirements

### Requirement: Search students by name, ignoring case and accents
The system SHALL return only the students whose name contains the search text when the Students list is requested with a search, comparing without regard to letter case or accents, and SHALL treat the search text as plain text.

#### Scenario: AC-1 Name containing the text is returned regardless of case
**Side:** BE
- **GIVEN** the students "Ana Torres", "Luis Anaya" and "Pedro Gil" exist
- **WHEN** an `ERAS Student Services Officer` requests the Students list with the search "ANA"
- **THEN** the API responds 200 OK with "Ana Torres" and "Luis Anaya" and without "Pedro Gil"
- **AND** the total count is 2

#### Scenario: AC-2 Accents are ignored in the text and in the stored names
**Side:** BE
- **GIVEN** the students "José Pérez" and "Maria Ñúñez" exist
- **WHEN** an `ERAS Administrator` requests the Students list with the search "jose"
- **THEN** the response contains "José Pérez" and not "Maria Ñúñez"
- **AND** requesting the search "María" returns "Maria Ñúñez"

#### Scenario: AC-3 Special characters are matched literally
**Side:** BE
- **GIVEN** the students "Ana Torres" and "Ana_100% Gil" exist
- **WHEN** an `ERAS Administrator` requests the Students list with the search "_100%"
- **THEN** the response contains only "Ana_100% Gil"
- **AND** the request does not fail

#### Scenario: AC-4 An empty or blank search returns the full list
**Side:** BE
- **GIVEN** 12 students exist
- **WHEN** an `ERAS Administrator` requests the Students list with the search "   " (only spaces)
- **THEN** the response has a total count of 12, exactly as when no search is sent

### Requirement: Search covers every student and keeps ordering and paging
The system SHALL apply the name search to all students, not only to the requested page, and SHALL return the matches ordered by name with a total count of all matches, honoring the requested page and page size.

#### Scenario: AC-5 Matches are searched across all pages and paged
**Side:** BE
- **GIVEN** 120 students exist and 25 of them have "garcia" in their name, none of them among the first 10 students by name
- **WHEN** an `ERAS Student Services Officer` requests the first page of 10 with the search "garcia"
- **THEN** the response has a total count of 25 and 10 items ordered by name
- **AND** requesting the third page returns the remaining 5 matches

### Requirement: Search input in the Students view
The Students view SHALL show a search input at the top of the list with a clear button, and SHALL update the list without reloading the page once the user pauses typing for about 300 ms.

#### Scenario: AC-6 Search input is shown at the top of the view
**Side:** FE
- **GIVEN** an `ERAS Student Services Officer` opens the Students view
- **WHEN** the view finishes loading
- **THEN** a search input with the placeholder "Search by name" is shown above the list
- **AND** the clear button is not shown while the input is empty

#### Scenario: AC-7 Typing searches once after a short pause
**Side:** FE
- **GIVEN** the Students view is shown with the full list
- **WHEN** the user types "jos" one letter at a time, with less than 300 ms between letters, and then stops
- **THEN** exactly one list request is sent, with the search "jos", about 300 ms after the last letter
- **AND** the list shows the returned students without a page reload

#### Scenario: AC-8 Clear button restores the full list
**Side:** FE
- **GIVEN** the user searched for "jos" and the list shows only the matching students
- **WHEN** the user clicks the clear button of the search input
- **THEN** the input is emptied and the clear button disappears
- **AND** the list is requested again without a search and shows the first page of all students

### Requirement: Empty state when no student matches
The Students view SHALL show the message "No students found." instead of the table rows when a search returns no students.

#### Scenario: AC-9 No match shows the empty message
**Side:** FE
- **GIVEN** the user types "zzzz" in the search input and no student matches
- **WHEN** the list response arrives with a total count of 0
- **THEN** the list shows "No students found."
- **AND** the search input keeps "zzzz" and its clear button

### Requirement: Search keeps the list context
The Students view SHALL keep the search text and the page size when the user changes page or opens and closes a student modal, and SHALL go back to the first page when the search text changes.

#### Scenario: AC-10 Changing page keeps the search
**Side:** FE
- **GIVEN** the user searched for "garcia" and the list has 25 matches over three pages of 10
- **WHEN** the user goes to the second page
- **THEN** the list is requested with the search "garcia", page 2 and page size 10
- **AND** the search input still shows "garcia"

#### Scenario: AC-11 A new search returns to the first page
**Side:** FE
- **GIVEN** the user is on the third page of the full list with a page size of 25
- **WHEN** the user types "ana" in the search input
- **THEN** the list is requested with the search "ana", the first page and the page size 25

#### Scenario: AC-12 Search survives opening and closing a student modal
**Side:** FE
- **GIVEN** the user searched for "jose" and the list shows the matching students
- **WHEN** the user opens the profile modal of a student and closes it
- **THEN** the search input still shows "jose" and the list still shows the same matching students
- **AND** when the modal saved a change, the list is reloaded keeping the search "jose"

### Requirement: Export with an active search
The Students view SHALL export to CSV or PDF only the students that match the active search, and all students when no search is active.

#### Scenario: AC-13 Export while a search is active
**Side:** FE
- **GIVEN** the user searched for "jose" and the list shows 3 matching students out of 120
- **WHEN** the user exports the list to CSV
- **THEN** the exported file contains exactly the 3 matching students
- **AND** the export does not include the other 117 students
