# Spec Delta

## Purpose
Lets any signed-in ERAS user find the available user manuals on a dedicated page and download the current version of each, while the manuals themselves are maintained by developers as reviewed files in the repository.

## ADDED Requirements

### Requirement: Sidebar entry to the User Manuals page
The system SHALL show a "User Manuals" item in the sidebar to every signed-in user, including users with no ERAS role (Guest), and SHALL highlight it while the User Manuals page is active.

#### Scenario: AC-1 Sidebar item opens the page
**Side:** FE
- **GIVEN** a signed-in user with the role "ERAS Professional"
- **WHEN** they select "User Manuals" in the sidebar
- **THEN** the User Manuals page opens
- **AND** the "User Manuals" item is highlighted as active

#### Scenario: AC-2 Guest sees the sidebar item
**Side:** FE
- **GIVEN** a signed-in user with no ERAS role (Guest)
- **WHEN** the sidebar is displayed
- **THEN** the "User Manuals" item is shown and opens the User Manuals page

### Requirement: List of available manuals
The system SHALL return to any signed-in user only the manuals that the repository declares as available, each with its title, language, version and file format, in alphabetical order by title, and the User Manuals page MUST show them.

#### Scenario: AC-4 Manuals are listed with their details
**Side:** FE
- **GIVEN** the list of manuals returns a PDF manual and an .odt manual
- **WHEN** a user opens the User Manuals page
- **THEN** both manuals are shown in the order received
- **AND** each item shows its title, language, version and file format ("PDF" or "ODT")

#### Scenario: AC-5 Empty state when there are no manuals
**Side:** FE
- **GIVEN** the list of manuals is empty
- **WHEN** a user opens the User Manuals page
- **THEN** the page shows an empty-state message and no list items

#### Scenario: AC-13 A failed list shows an error message
**Side:** FE
- **GIVEN** the request for the list of manuals fails
- **WHEN** a user opens the User Manuals page
- **THEN** the page shows an error message
- **AND** the page is not left blank

#### Scenario: AC-9 The API lists only the declared manuals in alphabetical order
**Side:** BE
- **GIVEN** the repository declares a PDF titled "Student Guide" and an .odt titled "Admin Guide"
- **WHEN** a signed-in user with no ERAS role (Guest) requests the list of manuals
- **THEN** the API responds 200 OK with "Admin Guide" first and "Student Guide" second
- **AND** each item carries its identifier, title, language, version and file format
- **AND** no file that is not declared is listed

#### Scenario: AC-8 Listing requires a signed-in user
**Side:** BE
- **GIVEN** a request with no valid sign-in token
- **WHEN** it asks for the list of manuals
- **THEN** the API responds 401 Unauthorized
- **AND** no manual information is returned

### Requirement: Download of a manual
The system SHALL let any signed-in user download a declared manual with one click, delivering the file as an attachment with the content type of its format and the file name declared for it, and MUST answer 404 for an identifier that is not declared.

#### Scenario: AC-6 Download the PDF manual
**Side:** FE
- **GIVEN** the User Manuals page lists the PDF manual
- **WHEN** the user clicks its download button
- **THEN** the PDF file is downloaded with the file name declared for the manual

#### Scenario: AC-7 Download the .odt manual
**Side:** FE
- **GIVEN** the User Manuals page lists the .odt manual
- **WHEN** the user clicks its download button
- **THEN** the .odt file is downloaded with the file name declared for the manual

#### Scenario: AC-10 The API delivers the PDF manual to any signed-in user
**Side:** BE
- **GIVEN** a declared PDF manual whose declared file name is "student-guide.pdf"
- **WHEN** a signed-in user with no ERAS role (Guest) requests its download
- **THEN** the API responds 200 OK with the file content and the content type "application/pdf"
- **AND** the response is an attachment named "student-guide.pdf"

#### Scenario: AC-14 The API delivers the .odt manual with its content type
**Side:** BE
- **GIVEN** a declared .odt manual whose declared file name is "admin-guide.odt"
- **WHEN** a signed-in user with the role "ERAS Professional" requests its download
- **THEN** the API responds 200 OK with the file content and the content type "application/vnd.oasis.opendocument.text"
- **AND** the response is an attachment named "admin-guide.odt"

#### Scenario: AC-11 Download requires a signed-in user
**Side:** BE
- **GIVEN** a request with no valid sign-in token
- **WHEN** it asks to download a manual
- **THEN** the API responds 401 Unauthorized
- **AND** no file content is returned

#### Scenario: AC-12 An undeclared manual identifier is not found
**Side:** BE
- **GIVEN** no manual is declared with the identifier "does-not-exist"
- **WHEN** a signed-in user requests the download of "does-not-exist"
- **THEN** the API responds 404 Not Found
- **AND** no file content is returned

### Requirement: Manuals are read-only and managed in the repository
The system SHALL expose manuals read-only: it MUST NOT accept creating, replacing, changing or deleting a manual through the API, MUST keep rejecting any upload of attachments typed as manuals, and MUST require developer review for any change to the manuals folder.

#### Scenario: AC-15 No write operation exists for manuals
**Side:** BE
- **GIVEN** the list and download addresses of the manuals
- **WHEN** a signed-in user sends a POST, PUT, PATCH or DELETE request to them
- **THEN** the API responds 405 Method Not Allowed
- **AND** no manual is created, changed or removed

#### Scenario: AC-16 An attachment upload typed as manuals is rejected
**Side:** BE
- **GIVEN** the generic attachment upload
- **WHEN** a file is uploaded with the entity type "Manuals"
- **THEN** the upload is rejected with 400 Bad Request
- **AND** nothing is stored

#### Scenario: AC-20 Changes to the manuals folder require developer review
**Side:** BE
- **GIVEN** the manuals folder at the root of the main ERAS repository and its review rules
- **WHEN** the manuals folder is checked for a required reviewer
- **THEN** a developers group is required as owner of every file in it
- **AND** a change to a file in it cannot be merged without that group's approval

### Requirement: Manual files are validated on every pull request
The system SHALL validate in the pipeline of every pull request that each declared manual has its file, that every file in the manuals folder is declared, that each file is of the declared type by its content and not only by its extension, and that no file exceeds the maximum size, and MUST fail the pipeline otherwise.

#### Scenario: AC-17 A declared manual without its file fails the validation
**Side:** BE
- **GIVEN** a manual declared with the file name "student-guide.pdf" and no such file in the manuals folder
- **WHEN** the manuals validation runs
- **THEN** the validation fails and names "student-guide.pdf"

#### Scenario: AC-21 A file that is not declared fails the validation
**Side:** BE
- **GIVEN** a file "extra.pdf" in the manuals folder that no manual declares
- **WHEN** the manuals validation runs
- **THEN** the validation fails and names "extra.pdf"

#### Scenario: AC-18 A file whose content does not match its declared type fails the validation
**Side:** BE
- **GIVEN** a manual declared as PDF whose file content is not a PDF
- **WHEN** the manuals validation runs
- **THEN** the validation fails and names the file
- **AND** a correct extension alone does not make it pass

#### Scenario: AC-19 A file over the maximum size fails the validation
**Side:** BE
- **GIVEN** a declared manual whose file is larger than the maximum size of 10 MB
- **WHEN** the manuals validation runs
- **THEN** the validation fails and names the file
