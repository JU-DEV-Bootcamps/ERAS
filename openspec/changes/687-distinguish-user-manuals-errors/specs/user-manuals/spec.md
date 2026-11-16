## ADDED Requirements

### Requirement: Each manuals failure has its own error code
The system SHALL answer a failed list or download of manuals with a stable error code that tells apart a missing manifest, an invalid manifest, a declared file missing from the folder and a manual that is not declared, and MUST NOT put a file path or a stack trace in the response.

#### Scenario: AC-1 A missing manifest is reported on the list
**Side:** BE
- **GIVEN** the manuals folder has no manifest
- **WHEN** a signed-in user requests the list of manuals
- **THEN** the API responds 500 with the error code "manuals_manifest_missing"
- **AND** no manual information is returned

#### Scenario: AC-2 An invalid manifest is reported on the list
**Side:** BE
- **GIVEN** the manifest declares a manual "student-guide" with the unknown format "docx"
- **WHEN** a signed-in user requests the list of manuals
- **THEN** the API responds 500 with the error code "manuals_manifest_invalid"
- **AND** no manual information is returned

#### Scenario: AC-3 A declared file missing from the folder is reported on the download
**Side:** BE
- **GIVEN** the manifest declares the manual "manual-de-usuario-eras-v2-pdf" with the file "manual-de-usuario-eras-v2.pdf" and that file is not in the manuals folder
- **WHEN** a signed-in user requests the download of "manual-de-usuario-eras-v2-pdf"
- **THEN** the API responds 500 with the error code "manuals_file_missing"
- **AND** no file content is returned

#### Scenario: AC-4 An undeclared manual is reported with its own code
**Side:** BE
- **GIVEN** no manual is declared with the identifier "does-not-exist"
- **WHEN** a signed-in user requests the download of "does-not-exist"
- **THEN** the API responds 404 Not Found with the error code "manuals_not_found"
- **AND** no file content is returned

#### Scenario: AC-5 The response does not expose internal details
**Side:** BE
- **GIVEN** the manifest declares the manual "manual-de-usuario-eras-v2-pdf" with a file that is not in the manuals folder
- **WHEN** a signed-in user requests the download of "manual-de-usuario-eras-v2-pdf"
- **THEN** the response body contains no file path and no folder path
- **AND** the response body contains no stack trace

#### Scenario: AC-22 One invalid manifest entry fails the download of every manual
**Side:** BE
- **GIVEN** the manifest declares a valid manual "manual-de-usuario-eras-v2-pdf" and a manual "student-guide" with the unknown format "docx"
- **WHEN** a signed-in user requests the download of "manual-de-usuario-eras-v2-pdf"
- **THEN** the API responds 500 with the error code "manuals_manifest_invalid"
- **AND** no file content is returned

### Requirement: Each manuals failure is logged on the server
The system SHALL write to the server log, for every failure of a list or download of manuals, an entry that names the manual and the problem: the requested identifier for a manual that is not declared, or the manifest when the manifest as a whole is the cause.

#### Scenario: AC-6 A missing file is logged with the manual and the file
**Side:** BE
- **GIVEN** the manifest declares the manual "manual-de-usuario-eras-v2-pdf" with the file "manual-de-usuario-eras-v2.pdf" and that file is not in the manuals folder
- **WHEN** a signed-in user requests the download of "manual-de-usuario-eras-v2-pdf"
- **THEN** the server log has an entry that names "manual-de-usuario-eras-v2-pdf" and "manual-de-usuario-eras-v2.pdf"
- **AND** the entry says that the file is missing

#### Scenario: AC-7 An invalid manifest entry is logged with the manual and the problem
**Side:** BE
- **GIVEN** the manifest declares a manual "student-guide" with the unknown format "docx"
- **WHEN** a signed-in user requests the list of manuals
- **THEN** the server log has an entry that names "student-guide"
- **AND** the entry says that the format "docx" is not supported

#### Scenario: AC-24 A manual that is not declared is logged with its identifier
**Side:** BE
- **GIVEN** no manual is declared with the identifier "does-not-exist"
- **WHEN** a signed-in user requests the download of "does-not-exist"
- **THEN** the server log has an entry that names "does-not-exist"
- **AND** the entry says that no manual is declared with that identifier

### Requirement: The page shows a specific message for each failure
The User Manuals page SHALL show a different message for each error code of a failed list or download, and the generic message when the failure carries no known code.

#### Scenario: AC-8 A missing manifest shows its message on the list
**Side:** FE
- **GIVEN** the request for the list of manuals fails with the error code "manuals_manifest_missing"
- **WHEN** a user opens the User Manuals page
- **THEN** the page shows "The list of user manuals is not available right now. Please contact support."

#### Scenario: AC-9 An invalid manifest shows its message on the list
**Side:** FE
- **GIVEN** the request for the list of manuals fails with the error code "manuals_manifest_invalid"
- **WHEN** a user opens the User Manuals page
- **THEN** the page shows "The list of user manuals is set up incorrectly. Please contact support."

#### Scenario: AC-10 A missing file shows its message on the download
**Side:** FE
- **GIVEN** the User Manuals page lists a manual and its download fails with the error code "manuals_file_missing"
- **WHEN** the user clicks its download button
- **THEN** the page shows "The file of this manual is not available right now. Please contact support."
- **AND** no file is downloaded

#### Scenario: AC-11 A manual that no longer exists shows its message on the download
**Side:** FE
- **GIVEN** the User Manuals page lists a manual and its download fails with the error code "manuals_not_found"
- **WHEN** the user clicks its download button
- **THEN** the page shows "This manual no longer exists. Reload the page to see the current manuals."
- **AND** no file is downloaded

#### Scenario: AC-12 A failure without a known code shows the generic message
**Side:** FE
- **GIVEN** the request for the list of manuals fails with no error code
- **WHEN** a user opens the User Manuals page
- **THEN** the page shows "Could not load the user manuals. Please try again later."

#### Scenario: AC-23 A later successful download clears the error message
**Side:** FE
- **GIVEN** the page shows the message of a failed download of one manual
- **WHEN** the user downloads another manual and the download succeeds
- **THEN** the error message is no longer shown
- **AND** the other manual's file is downloaded

### Requirement: The manuals folder explains how to change manuals locally
The system SHALL provide in the manuals folder a README that guides a developer, step by step, to add or change a manual locally without rebuilding, whether the backend runs in the Docker stack or outside it, and that tells which error code of the page each missed step causes.

#### Scenario: AC-13 The README guides the local workflow step by step
**Side:** BE
- **GIVEN** the manuals folder at the root of the main ERAS repository
- **WHEN** its README is read
- **THEN** it gives numbered steps to add or change a manual, and it explains the manifest fields, the supported file types ("pdf" and "odt") and the 10 MB limit
- **AND** it states that the folder is mounted read-only in the backend so edits appear without a rebuild, and that "docker compose up" is only needed after the mount itself changes, and says to run it once after pulling the change that adds the mount
- **AND** it gives numbered steps to run the backend outside Docker by setting "UserManuals__Path" in the environment to the manuals folder, and warns not to commit a personal path in a shared settings file
- **AND** it explains how to validate the folder with the user manuals tests

#### Scenario: AC-25 The README explains each error code of the page
**Side:** BE
- **GIVEN** the manuals folder at the root of the main ERAS repository
- **WHEN** its README is read
- **THEN** it lists the error codes "manuals_manifest_missing", "manuals_manifest_invalid", "manuals_file_missing" and "manuals_not_found"
- **AND** for each code it gives the probable cause and what to do, including, for "manuals_manifest_missing", that the folder is not mounted (no "docker compose up" after the mount was added) or that "UserManuals__Path" is not set

## MODIFIED Requirements

### Requirement: Manual files are validated on every pull request
The system SHALL validate in the pipeline of every pull request that each declared manual has its file, that every file in the manuals folder, other than its manifest and its README, is declared, that each file is of the declared type by its content and not only by its extension, and that no file exceeds the maximum size, and MUST fail the pipeline otherwise.

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

#### Scenario: AC-14 The README is not reported as an undeclared file
**Side:** BE
- **GIVEN** a manuals folder whose manifest declares every file except "README.md", and a file "README.md" in it
- **WHEN** the manuals validation runs
- **THEN** the validation passes
- **AND** no problem names "README.md"
