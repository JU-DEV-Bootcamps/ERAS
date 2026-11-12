## Purpose
Lets Administrators, Student Services Officers and Professionals take the Assessments list out of the app as a CSV or PDF file that contains every record of their own list.

## ADDED Requirements

### Requirement: Offer CSV and PDF export on the Assessments list
The system SHALL offer CSV and PDF export of the Assessments list to Administrators, Student Services Officers and Professionals whenever their list has at least one assessment.

#### Scenario: AC-1 Export control offers CSV and PDF
**Side:** FE
- **GIVEN** an "ERAS Student Services Officer" whose Assessments list has 3 assessments
- **WHEN** they open the Assessments list
- **THEN** an Export control is shown
- **AND** it offers the options "CSV" and "PDF"

#### Scenario: AC-2 No export control for an empty list
**Side:** FE
- **GIVEN** an "ERAS Professional" with no assessments in their list
- **WHEN** they open the Assessments list
- **THEN** the empty state is shown
- **AND** no Export control is shown

### Requirement: Export every assessment of the user's own list
The system MUST export every assessment of the user's own list, in the same order as the table and regardless of the page shown, and MUST NOT include assessments outside that list.

#### Scenario: AC-3 CSV contains all rows, not only the current page
**Side:** FE
- **GIVEN** an "ERAS Student Services Officer" whose list has 25 assessments and the table shows page 1 of 3 with 10 rows per page
- **WHEN** they export CSV
- **THEN** the downloaded file has 1 header row and 25 data rows

#### Scenario: AC-4 PDF contains all rows, not only the current page
**Side:** FE
- **GIVEN** an "ERAS Administrator" whose list has 100 assessments and the table shows page 2 of 10
- **WHEN** they export PDF
- **THEN** the table in the downloaded PDF has 100 data rows

#### Scenario: AC-5 Export is limited to the user's own list
**Side:** FE
- **GIVEN** an "ERAS Professional" whose list shows the 3 assessments assigned to them
- **WHEN** they export PDF
- **THEN** the table in the PDF has exactly those 3 rows
- **AND** no assessment outside their list is included

#### Scenario: AC-17 Rows keep the order of the table
**Side:** FE
- **GIVEN** a list of 25 assessments shown in the order A1, A2, ..., A25 across 3 pages
- **WHEN** the user exports CSV
- **THEN** the data rows of the file are in the order A1, A2, ..., A25

### Requirement: Export the same columns as the table, with full content
The system SHALL export the same columns, labels and order as the on-screen table, without the Actions column, with the table's displayed values, except that Comment and Student are exported in full.

#### Scenario: AC-6 Columns, labels and order match the table
**Side:** FE
- **GIVEN** an "ERAS Student Services Officer" with at least one assessment in their list
- **WHEN** they export in either format
- **THEN** the CSV header and the PDF table header both show, in this order, "Date", "Submitter", "Service", "Professional", "Student", "Status", "Comment"
- **AND** neither has an "Actions" column

#### Scenario: AC-7 Cell values match what the table shows
**Side:** FE
- **GIVEN** an assessment created on 2026-03-05, submitted by a user shown as "Laura Gómez", for service "psychology", assigned to a professional shown as "Carlos Díaz", with status "InProgress"
- **WHEN** it is exported
- **THEN** its row shows Date "03/05/2026", Submitter "Laura Gómez", Service "Psychology", Professional "Carlos Díaz" and Status "In Progress"
- **AND** a submitter or professional that cannot be resolved to a name is shown by its identifier, as in the table

#### Scenario: AC-8 Comment is exported in full
**Side:** FE
- **GIVEN** an assessment whose comment has 200 characters, which the table shows cut to 60 characters followed by "..."
- **WHEN** it is exported
- **THEN** the Comment cell contains all 200 characters
- **AND** it does not end with "..."

#### Scenario: AC-9 All student names are exported
**Side:** FE
- **GIVEN** an assessment with 4 students "Ana Pérez", "Luis Mora", "Eva Ríos" and "Tomás Vega"
- **WHEN** it is exported
- **THEN** the Student cell lists all four names separated by commas
- **AND** it shows no student count and no student ids

### Requirement: Produce CSV files that open correctly in spreadsheets
The system MUST produce CSV files that are UTF-8 with a header row, keep accented characters intact, escape commas, quotes and line breaks, and neutralize values that a spreadsheet would run as formulas.

#### Scenario: AC-10 Accented characters survive in a spreadsheet
**Side:** FE
- **GIVEN** an assessment for the student "María Peña" with the comment "Revisión académica"
- **WHEN** the user exports CSV
- **THEN** the downloaded file starts with a UTF-8 byte-order mark, so spreadsheet applications read it as UTF-8
- **AND** "María Peña" and "Revisión académica" appear in the file with their accents unchanged

#### Scenario: AC-11 Commas, quotes and line breaks are escaped
**Side:** FE
- **GIVEN** an assessment whose comment is `Said "ok", then left` followed by a line break and `Next step`
- **WHEN** it is exported to CSV
- **THEN** the comment is written as a single field with its quotes doubled
- **AND** the file still has one data row for that assessment

#### Scenario: AC-12 Formula-like values are neutralized
**Side:** FE
- **GIVEN** assessments whose text cells (for example Comment or a student name) start with "=", "+", "-" and "@" respectively, for example the comment `=SUM(A1:A9)`
- **WHEN** they are exported to CSV
- **THEN** each of those cells is prefixed with a single quote
- **AND** the rest of the text is unchanged
- **AND** cells that do not start with those characters are unchanged

### Requirement: Produce a PDF with a header and a paginated table
The system SHALL produce a PDF that shows the title, the export date and time, the name of the exporting user and the applied filters, followed by a table whose column headers repeat on every page.

#### Scenario: AC-13 PDF shows title, date and time, user and filters
**Side:** FE
- **GIVEN** the user "Laura Gómez" with the Assessments list open
- **WHEN** she exports PDF
- **THEN** the first page shows the title "Assessments", the export date and time, the exporting user "Laura Gómez" and "Filters: None"

#### Scenario: AC-14 Column headers repeat on every page
**Side:** FE
- **GIVEN** a list of 100 assessments, which does not fit on one page
- **WHEN** the user exports PDF
- **THEN** the PDF has more than one page
- **AND** the column headers are shown at the top of the table on every page

### Requirement: Show progress and report failures
The system SHALL show an in-progress indication while a file is being generated, and SHALL show an error message, without downloading a file, when generation fails.

#### Scenario: AC-15 Progress is shown while generating
**Side:** FE
- **GIVEN** a user with the Assessments list open
- **WHEN** they start an export
- **THEN** an in-progress indication is shown until the file has been downloaded
- **AND** the Export control cannot be used again until the file has been downloaded
- **AND** the indication is then removed

#### Scenario: AC-16 A failed export shows an error
**Side:** FE
- **GIVEN** a user with the Assessments list open and a file generation that fails
- **WHEN** they start an export
- **THEN** an error message is shown
- **AND** no file is downloaded
- **AND** the in-progress indication is removed
