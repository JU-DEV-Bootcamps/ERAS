## Purpose
Lets Administrators, Student Services Officers and Professionals take the Interventions list out of the app as a file, from one Export control that offers CSV and PDF, containing the interventions that match the filters of their own list.

## ADDED Requirements

### Requirement: Offer CSV and PDF from one Export control on the Interventions list
The system SHALL offer the export of the Interventions list to Administrators, Student Services Officers and Professionals through a single Export control with the options "CSV" and "PDF", the same control used on the Assessments list, and SHALL show it only while the list has interventions to export, as the current "Export CSV" button is.

#### Scenario: AC-1 Export control offers CSV and PDF
**Side:** FE
- **GIVEN** an "ERAS Student Services Officer" on the Interventions list with an assessment selected that has 3 interventions
- **WHEN** they open the Export control
- **THEN** it offers the options "CSV" and "PDF"
- **AND** the separate "Export CSV" icon button is no longer shown

#### Scenario: AC-2 Export control is not shown until an assessment is selected
**Side:** FE
- **GIVEN** an "ERAS Administrator" on the Interventions list with no assessment selected, so the list shows "Select an assessment"
- **WHEN** they look at the page
- **THEN** the Export control is not shown
- **AND** only the "Select an assessment" message is displayed

#### Scenario: AC-21 Export control is not shown when no intervention matches
**Side:** FE
- **GIVEN** a user with an assessment selected and filters that no intervention matches, so the list shows "No interventions match the current filters"
- **WHEN** they look at the page
- **THEN** the Export control is not shown
- **AND** only the empty-state message is displayed

#### Scenario: AC-3 CSV option downloads the existing CSV
**Side:** FE
- **GIVEN** an "ERAS Professional" with an assessment selected and 5 interventions matching the active filters
- **WHEN** they choose "CSV" in the Export control
- **THEN** a CSV file is downloaded with 1 header row and those 5 interventions
- **AND** its columns and values are the ones the "Export CSV" icon button produced before

### Requirement: Export to PDF the interventions that match the active filters
The system MUST export to PDF every intervention that matches the filters active when the export is requested, in the order of the table and regardless of the page shown, and MUST NOT include interventions that the filters hide or that are outside the user's own list.

#### Scenario: AC-4 Only rows matching the filters are exported
**Side:** FE
- **GIVEN** an assessment with 30 interventions, of which 12 match the active filters Type "Group" and Risk Level "High"
- **WHEN** the user exports PDF
- **THEN** the table in the PDF has exactly those 12 rows
- **AND** none of the other 18 interventions is included

#### Scenario: AC-5 All matching rows are exported, not only the current page
**Side:** FE
- **GIVEN** 25 interventions matching the active filters and the table showing page 1 of 3 with 10 rows per page
- **WHEN** the user exports PDF
- **THEN** the table in the PDF has 25 data rows

#### Scenario: AC-6 Rows keep the sorting of the table
**Side:** FE
- **GIVEN** a list sorted by Risk Level descending, shown in the order I1, I2, ..., I25 across 3 pages
- **WHEN** the user exports PDF
- **THEN** the data rows of the PDF are in the order I1, I2, ..., I25

#### Scenario: AC-7 Export is limited to the user's own list
**Side:** FE
- **GIVEN** an "ERAS Professional" whose list shows, for the selected assessment, the 3 interventions they are allowed to see
- **WHEN** they export PDF
- **THEN** the table in the PDF has exactly those 3 rows
- **AND** no intervention outside their list is included

### Requirement: Export to PDF the same columns as the table, with full content
The system SHALL export to PDF the same columns, labels and order as the on-screen table, without the Actions column, with the table's displayed values, except that Comment and Student are exported in full.

#### Scenario: AC-8 Columns, labels and order match the table
**Side:** FE
- **GIVEN** a user with at least one intervention in the list
- **WHEN** they export PDF
- **THEN** the PDF table header shows, in this order, "Date", "Type", "Mode", "Activity", "Professional", "Student", "Area", "Risk Level", "End Risk Level", "Status", "Comment"
- **AND** it has no "Actions" column

#### Scenario: AC-9 Cell values match what the table shows
**Side:** FE
- **GIVEN** an intervention dated 2026-03-05 that the table shows with Type "Individual", Professional "Carlos Díaz", Risk Level "High", Status "In Progress" and no end risk level
- **WHEN** it is exported to PDF
- **THEN** its row shows Date "03/05/2026", Type "Individual", Professional "Carlos Díaz", Risk Level "High" and Status "In Progress"
- **AND** the End Risk Level cell shows "—", as in the table

#### Scenario: AC-10 Comment is exported in full
**Side:** FE
- **GIVEN** an intervention whose comment has 200 characters, which the table shows cut to 60 characters followed by "..."
- **WHEN** it is exported to PDF
- **THEN** the Comment cell contains all 200 characters
- **AND** it does not end with "..."

#### Scenario: AC-11 All student names are exported
**Side:** FE
- **GIVEN** a group intervention with 4 students "Ana Pérez", "Luis Mora", "Eva Ríos" and "Tomás Vega", of which the table shows only 2 names
- **WHEN** it is exported to PDF
- **THEN** the Student cell lists all four names separated by commas

### Requirement: Produce a PDF with a header and a paginated table
The system SHALL produce a PDF that shows the title, the export date and time, the name of the exporting user and the applied filters, followed by a table whose column headers repeat on every page, with accented and special characters displayed correctly.

#### Scenario: AC-12 PDF shows title, date and time, user and applied filters
**Side:** FE
- **GIVEN** the user "Laura Gómez" with the assessment "03/05/2026 – Psychology (In Progress)" selected and the filters Type "Group" and Risk Level "High", "Medium"
- **WHEN** she exports PDF
- **THEN** the first page shows the title "Interventions", the export date and time and the exporting user "Laura Gómez"
- **AND** it shows the applied filters by name and value: Assessment "03/05/2026 – Psychology (In Progress)", Type "Group" and Risk Level "High, Medium"

#### Scenario: AC-13 Filters without a selection are not listed
**Side:** FE
- **GIVEN** a user with the assessment "03/05/2026 – Psychology (In Progress)" selected and no Type, Status or Risk Level selected
- **WHEN** they export PDF
- **THEN** the applied filters show only Assessment "03/05/2026 – Psychology (In Progress)"
- **AND** Type, Status and Risk Level are not mentioned

#### Scenario: AC-14 Column headers repeat on every page
**Side:** FE
- **GIVEN** 100 interventions matching the active filters, which do not fit on one page
- **WHEN** the user exports PDF
- **THEN** the PDF has more than one page
- **AND** the column headers are shown at the top of the table on every page

#### Scenario: AC-15 Accented and special characters are displayed correctly
**Side:** FE
- **GIVEN** an intervention for the student "María Peña" with the activity "Sesión de orientación" and the comment "Revisión académica: año 1"
- **WHEN** it is exported to PDF
- **THEN** "María Peña", "Sesión de orientación" and "Revisión académica: año 1" appear in the PDF with "á", "ñ", "é" and "ó" unchanged

### Requirement: Show progress and report failures
The system SHALL show an in-progress indication while the PDF is being generated, and SHALL show an error message, without downloading a file, when generation fails.

#### Scenario: AC-19 Progress is shown while generating
**Side:** FE
- **GIVEN** a user with interventions in the list
- **WHEN** they start a PDF export
- **THEN** an in-progress indication is shown until the file has been downloaded
- **AND** the Export control cannot be used again until the file has been downloaded
- **AND** the indication is then removed

#### Scenario: AC-20 A failed export shows an error
**Side:** FE
- **GIVEN** a user with interventions in the list and a PDF generation that fails
- **WHEN** they start a PDF export
- **THEN** the error message "The file could not be generated. Please try again." is shown
- **AND** no file is downloaded
- **AND** the in-progress indication is removed
