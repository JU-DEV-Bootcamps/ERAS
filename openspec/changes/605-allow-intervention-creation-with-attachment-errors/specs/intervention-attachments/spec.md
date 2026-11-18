## Purpose
Defines how the Create and Edit Intervention forms treat attachments that are rejected or fail to upload, so users always know which files will not be saved and can decide whether to continue.

## ADDED Requirements

### Requirement: Warn before creating an intervention with rejected attachments
When the user clicks Create while an attachment error is shown (a rejected file or a failed upload), the system SHALL show a confirmation modal and SHALL create the intervention without those files only if the user confirms.

#### Scenario: AC-1 Confirmation modal appears when an attachment was rejected
**Side:** FE
- **GIVEN** a user with any ERAS role filling in a valid Create Intervention form who added "notes.exe", which was rejected as unsupported
- **WHEN** they click Create
- **THEN** a modal titled "Attachments with errors" opens with the text "Some attachments have errors and will not be saved. Review them, or create the intervention without them." and the buttons "Create anyway" and "Keep editing"
- **AND** the intervention is not created yet

#### Scenario: AC-2 Confirming creates the intervention without the rejected files
**Side:** FE
- **GIVEN** the confirmation modal is open, and the form has "plan.pdf" uploaded correctly and "notes.exe" rejected
- **WHEN** the user chooses "Create anyway"
- **THEN** the intervention is created with "plan.pdf" as its only attachment
- **AND** the success message is shown and the Create form closes

#### Scenario: AC-3 Keep editing returns to the form unchanged
**Side:** FE
- **GIVEN** the confirmation modal is open with a rejected file listed in the form
- **WHEN** the user chooses "Keep editing"
- **THEN** the modal closes and the Create form stays open with all values and the error message as they were
- **AND** no intervention is created

#### Scenario: AC-4 No modal when every attachment is valid
**Side:** FE
- **GIVEN** a valid Create Intervention form whose attachments all uploaded correctly
- **WHEN** the user clicks Create
- **THEN** the intervention is created without showing the confirmation modal
- **AND** all attachments are included

#### Scenario: AC-5 A failed upload does not block Create and also triggers the modal
**Side:** FE
- **GIVEN** a valid Create Intervention form where the upload of "plan.pdf" failed
- **WHEN** the user looks at the Create button and clicks it
- **THEN** the Create button is enabled and the confirmation modal opens
- **AND** choosing "Create anyway" creates the intervention without "plan.pdf"

#### Scenario: AC-6 No modal after the rejected file is removed
**Side:** FE
- **GIVEN** a Create Intervention form where "notes.exe" was rejected and its error is shown
- **WHEN** the user adds a valid file "plan.pdf" and clicks Create
- **THEN** the intervention is created with "plan.pdf" without showing the modal
- **AND** the error message for "notes.exe" is no longer shown

### Requirement: Show friendly attachment error messages
The system SHALL show every attachment error as a friendly English sentence that names the file and states that the intervention will be created (when creating) or saved (when editing) without it.

#### Scenario: AC-7 File over the size limit
**Side:** FE
- **GIVEN** a user adding attachments to an intervention
- **WHEN** they select "report.pdf" larger than 10MB
- **THEN** the field shows `"report.pdf" is larger than the 10MB limit, so the intervention will be created without it.`
- **AND** the file is not added to the list

#### Scenario: AC-8 Unsupported format
**Side:** FE
- **GIVEN** a user adding attachments to an intervention
- **WHEN** they select "notes.exe"
- **THEN** the field shows `"notes.exe" is not a supported file type (allowed: .pdf, .jpg, .png, .txt), so the intervention will be created without it.`
- **AND** the file is not added to the list

#### Scenario: AC-9 Duplicated file
**Side:** FE
- **GIVEN** an intervention form that already lists "plan.pdf"
- **WHEN** the user selects another file named "plan.pdf"
- **THEN** the field shows `"plan.pdf" has already been added, so it will only be attached once.`
- **AND** the list still has one "plan.pdf"

#### Scenario: AC-10 Too many files
**Side:** FE
- **GIVEN** an intervention form that already lists 5 attachments, the maximum
- **WHEN** the user selects one more file
- **THEN** the field shows "You can attach up to 5 documents, so the extra files will not be added."
- **AND** the list is unchanged

#### Scenario: AC-11 Upload failure
**Side:** FE
- **GIVEN** a user whose upload of "plan.pdf" fails
- **WHEN** the file shows its error state
- **THEN** the field shows `"plan.pdf" could not be uploaded, so the intervention will be created without it. Click the file to try again.`
- **AND** the file can still be retried or removed

#### Scenario: AC-12 Edit shows the same friendly messages
**Side:** FE
- **GIVEN** a user with any ERAS role editing an existing intervention
- **WHEN** they select "report.pdf" larger than 10MB
- **THEN** the field shows `"report.pdf" is larger than the 10MB limit, so the intervention will be saved without it.`
- **AND** no confirmation modal is shown when they save the edit

#### Scenario: AC-13 One message per rejected file
**Side:** FE
- **GIVEN** a user adding attachments to an intervention
- **WHEN** they select at once "report.pdf" larger than 10MB and "notes.exe"
- **THEN** the field shows one message for "report.pdf" (size limit) and one for "notes.exe" (unsupported type), each in its friendly wording
- **AND** neither file is added to the list

#### Scenario: AC-14 A failed upload does not block saving an edit
**Side:** FE
- **GIVEN** a user with any ERAS role editing an intervention with a valid form, where the upload of "plan.pdf" failed
- **WHEN** they look at the Save button and click it
- **THEN** the Save button is enabled and the intervention is saved without "plan.pdf", without a confirmation modal
- **AND** the field showed `"plan.pdf" could not be uploaded, so the intervention will be saved without it. Click the file to try again.`
