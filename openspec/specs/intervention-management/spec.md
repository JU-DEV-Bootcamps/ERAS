# intervention-management Specification

## Purpose
Defines how interventions are managed in the Interventions section, starting with who can change the professional assigned to an intervention.

## Requirements

### Requirement: Reassign the professional of an intervention
The system SHALL let every user with an ERAS role change the professional assigned to an intervention, and SHALL reject users without an ERAS role.

#### Scenario: AC-1 Administrator reassigns the professional
**Side:** BE + FE
- **GIVEN** a user with the role "ERAS Administrator" editing an intervention assigned to "Ana Pérez"
- **WHEN** they select "Luis Gómez" as the professional and confirm
- **THEN** the intervention is saved with "Luis Gómez" as its professional
- **AND** the intervention shows "Luis Gómez" immediately, without reloading the page

#### Scenario: AC-2 Student Services Officer reassigns the professional
**Side:** BE + FE
- **GIVEN** a user with the role "ERAS Student Services Officer" editing an intervention assigned to "Ana Pérez"
- **WHEN** they select "Luis Gómez" as the professional and confirm
- **THEN** the intervention is saved with "Luis Gómez" as its professional
- **AND** the intervention shows "Luis Gómez" immediately

#### Scenario: AC-3 Professional reassigns the professional
**Side:** BE + FE
- **GIVEN** a user with the role "ERAS Professional" editing an intervention assigned to "Ana Pérez"
- **WHEN** they select "Luis Gómez" as the professional and confirm
- **THEN** the intervention is saved with "Luis Gómez" as its professional
- **AND** the intervention shows "Luis Gómez" immediately

#### Scenario: AC-4 Guest cannot reassign the professional through the API
**Side:** BE
- **GIVEN** a user with no ERAS role (Guest)
- **WHEN** they send an update of an intervention with a different professional
- **THEN** the API responds 403 Forbidden
- **AND** the intervention keeps its current professional

#### Scenario: AC-5 Edit modal offers a selectable professional
**Side:** FE
- **GIVEN** a user with any ERAS role opens the edit modal of an intervention
- **WHEN** the modal is shown
- **THEN** the Professional field is enabled and lists the professionals that can be assigned
- **AND** the current professional is preselected

#### Scenario: AC-6 Professional is required
**Side:** FE
- **GIVEN** a user editing an intervention
- **WHEN** they clear the Professional field and try to save
- **THEN** the form is not submitted and the field shows it is required
- **AND** the intervention is not changed

#### Scenario: AC-7 Reassigning does not alter other fields
**Side:** BE
- **GIVEN** an intervention with activity "Workshop", status "In Progress", comments "First session" and attached documents
- **WHEN** a user with an ERAS role changes only the professional and saves
- **THEN** activity, status, comments, students, attendance and attached documents keep their previous values
- **AND** only the professional differs

#### Scenario: AC-8 Existing interventions are not affected
**Side:** BE
- **GIVEN** interventions that already exist with an assigned professional
- **WHEN** the system is used after this change without anyone editing them
- **THEN** each intervention still has the same professional it had before

#### Scenario: AC-10 New professional is added to the assessment
**Side:** BE
- **GIVEN** an intervention in an assessment whose professionals are "Ana Pérez", and a user with any ERAS role
- **WHEN** they reassign the intervention to "Luis Gómez" and confirm
- **THEN** the assessment's professionals are "Ana Pérez" and "Luis Gómez"
- **AND** the intervention's professional is "Luis Gómez"

#### Scenario: AC-11 A professional already in the assessment is not duplicated
**Side:** BE
- **GIVEN** an assessment whose professionals are "Ana Pérez" and "Luis Gómez", with an intervention assigned to "Ana Pérez"
- **WHEN** a user reassigns that intervention to "Luis Gómez"
- **THEN** the assessment's professionals are still "Ana Pérez" and "Luis Gómez", each listed once
- **AND** the intervention's professional is "Luis Gómez"

#### Scenario: AC-12 Other interventions and the assessment keep their data
**Side:** BE
- **GIVEN** an assessment with two interventions, both assigned to "Ana Pérez", and with students "S1" and "S2"
- **WHEN** a user reassigns only the first intervention to "Luis Gómez"
- **THEN** the second intervention is still assigned to "Ana Pérez"
- **AND** the assessment's students and its other data are unchanged

#### Scenario: AC-13 The added professional can see the assessment
**Side:** BE
- **GIVEN** an intervention reassigned to "Luis Gómez", who has the role "ERAS Professional"
- **WHEN** "Luis Gómez" asks for the assessments assigned to him
- **THEN** the assessment is included
- **AND** "Ana Pérez" still sees it too

#### Scenario: AC-14 Existing assessments keep their professional
**Side:** BE
- **GIVEN** assessments that already have one assigned professional before this change
- **WHEN** the system is used after this change without anyone editing them
- **THEN** each assessment has exactly that professional and is visible to them as before
- **AND** no professional is added or removed

#### Scenario: AC-15 The assessment list shows every professional
**Side:** FE
- **GIVEN** an assessment whose professionals are "Ana Pérez" and "Luis Gómez"
- **WHEN** a user with any ERAS role opens the assessment list
- **THEN** the row shows both "Ana Pérez" and "Luis Gómez"
- **AND** an assessment with a single professional shows just that name

#### Scenario: AC-16 Edit the full list of professionals of an assessment
**Side:** BE + FE
- **GIVEN** an assessment whose professionals are "Ana Pérez", and an Administrator or Student Services Officer editing it
- **WHEN** they add "Luis Gómez" in the assessment form and save
- **THEN** the assessment's professionals are "Ana Pérez" and "Luis Gómez"
- **AND** the assessment's students and other data keep their previous values

#### Scenario: AC-17 Remove a professional who has no interventions in the assessment
**Side:** BE
- **GIVEN** an assessment whose professionals are "Ana Pérez" and "Luis Gómez", and no intervention of that assessment is assigned to "Luis Gómez"
- **WHEN** an Administrator or Student Services Officer removes "Luis Gómez" from the list and saves
- **THEN** the assessment's professionals are only "Ana Pérez"
- **AND** the assessment's interventions are unchanged

#### Scenario: AC-18 Cannot remove a professional who has interventions in the assessment
**Side:** BE
- **GIVEN** an assessment whose professionals are "Ana Pérez" and "Luis Gómez", and an intervention of that assessment is assigned to "Luis Gómez"
- **WHEN** an Administrator or Student Services Officer removes "Luis Gómez" from the list and saves
- **THEN** the API responds 409 Conflict with a message saying "Luis Gómez" still has interventions in this assessment
- **AND** the assessment keeps both professionals

#### Scenario: AC-19 The form shows why a professional cannot be removed
**Side:** FE
- **GIVEN** an Administrator or Student Services Officer who removed a professional that has interventions in the assessment
- **WHEN** they save and the API responds 409 Conflict
- **THEN** the form shows the message returned and stays open
- **AND** the professional list in the form is not saved

### Requirement: Record the activity of an intervention
The system SHALL automatically record an event, with its description, the time and the name of the authenticated user, when an intervention is created, when a comment is added, when its status changes and when its risk level or end risk level changes.

#### Scenario: AC-1 Creating an intervention records "Intervention created"
**Side:** BE
- **GIVEN** an "ERAS Professional" named "Ana Pérez"
- **WHEN** they create an intervention
- **THEN** the intervention has one event "Intervention created" with the creation time and the user name "Ana Pérez"
- **AND** the intervention has no other event

#### Scenario: AC-3 Adding a comment records "Comment added"
**Side:** BE
- **GIVEN** an intervention with no comments and a user named "Ana Pérez"
- **WHEN** they save the comments "First session done"
- **THEN** the intervention has an event "Comment added" with the time and the user name "Ana Pérez"
- **AND** the event does not contain the comment text

#### Scenario: AC-19 Changing a comment records an event and clearing it does not
**Side:** BE
- **GIVEN** an intervention with the comments "First session done" and a user named "Ana Pérez"
- **WHEN** they change the comments to "Second session done", and later clear the comments
- **THEN** the change to "Second session done" adds one event "Comment added" with the user name "Ana Pérez"
- **AND** clearing the comments adds no event
#### Scenario: AC-4 Changing the status records the previous and the new value
**Side:** BE
- **GIVEN** an intervention with status "Remitted" and a user named "Luis Gómez"
- **WHEN** they change its status to "In Progress"
- **THEN** the intervention has an event "Status changed: Remitted → In Progress" with the time and the user name "Luis Gómez"
- **AND** a later change to "Finalized" adds a second event "Status changed: In Progress → Finalized"

#### Scenario: AC-21 Changing the risk level records the previous and the new value
**Side:** BE
- **GIVEN** an intervention with risk level "Medium" and a user named "Luis Gómez"
- **WHEN** they change its risk level to "High"
- **THEN** the intervention has an event "Risk level changed: Medium → High" with the time and the user name "Luis Gómez"
- **AND** saving later with the risk level still "High" adds no event

#### Scenario: AC-22 Changing the end risk level records the previous and the new value
**Side:** BE
- **GIVEN** a Finalized intervention with no end risk level and a user named "Luis Gómez"
- **WHEN** they save it with the end risk level "Low"
- **THEN** the intervention has an event "End risk level changed: None → Low" with the time and the user name "Luis Gómez"
- **AND** saving later with the end risk level still "Low" adds no event

#### Scenario: AC-23 Changing both risk levels in one save records two events
**Side:** BE
- **GIVEN** a Finalized intervention with risk level "Medium", no end risk level and a user named "Luis Gómez"
- **WHEN** they save it with the risk level "High" and the end risk level "Low"
- **THEN** the intervention has two events, "Risk level changed: Medium → High" and "End risk level changed: None → Low", each with the same time and the user name "Luis Gómez"
- **AND** no combined event is recorded

#### Scenario: AC-5 Saving without a tracked change records no event
**Side:** BE
- **GIVEN** an intervention with status "Remitted", comments "First session done" and one event "Intervention created"
- **WHEN** a user saves it changing only the activity name and keeping the same status and comments
- **THEN** the intervention still has only the event "Intervention created"
- **AND** the activity name has the new value

#### Scenario: AC-6 A rejected status change records no event
**Side:** BE
- **GIVEN** an intervention with status "Finalized"
- **WHEN** a user tries to change its status to "In Progress" and the API rejects the transition
- **THEN** the API responds with the existing rejection and the status stays "Finalized"
- **AND** no event is recorded

#### Scenario: AC-20 Changing the type of an intervention keeps its history
**Side:** BE
- **GIVEN** an individual intervention with the events "Intervention created" by "Ana Pérez" at 2026-11-02 09:00 and "Comment added" by "Luis Gómez" at 2026-11-04 15:30
- **WHEN** a user with an ERAS role changes its type to group and saves
- **THEN** the resulting intervention has the same two events, in the same order, with the same user names and times
- **AND** no event "Intervention created" is added

### Requirement: Read the activity history of an intervention
The system SHALL return the events of one intervention only, oldest first, each with its description, time and user name, to every user with an ERAS role, and MUST deny users without an ERAS role.

#### Scenario: AC-7 Events are listed oldest first
**Side:** BE
- **GIVEN** an intervention with the events "Intervention created" at 2026-11-02 09:00, "Comment added" at 2026-11-04 15:30 and "Status changed: Remitted → In Progress" at 2026-11-03 10:15, and an "ERAS Administrator"
- **WHEN** they request the activity history of the intervention
- **THEN** the API responds 200 OK with the events in the order 2026-11-02 09:00, 2026-11-03 10:15, 2026-11-04 15:30
- **AND** each event shows its description, time and user name

#### Scenario: AC-8 Student Services Officer can read the history
**Side:** BE
- **GIVEN** an intervention with one event "Intervention created"
- **WHEN** an "ERAS Student Services Officer" requests its activity history
- **THEN** the API responds 200 OK with that event
- **AND** the event is unchanged

#### Scenario: AC-9 Professional can read the history
**Side:** BE
- **GIVEN** an intervention with one event "Intervention created"
- **WHEN** an "ERAS Professional" requests its activity history
- **THEN** the API responds 200 OK with that event
- **AND** the event is unchanged

#### Scenario: AC-10 Guest cannot read the history
**Side:** BE
- **GIVEN** a user with no ERAS role (Guest)
- **WHEN** they request the activity history of an intervention
- **THEN** the API responds 403 Forbidden
- **AND** no event data is returned

#### Scenario: AC-11 Events of one intervention never appear for another
**Side:** BE
- **GIVEN** an intervention "A" with two events and an intervention "B" of the same assessment with one event
- **WHEN** a user with an ERAS role requests the activity history of "B"
- **THEN** the API responds 200 OK with only the one event of "B"
- **AND** the history of "A" still has its two events

#### Scenario: AC-12 An unknown intervention is not found
**Side:** BE
- **GIVEN** a user with an ERAS role and no intervention with id 999999
- **WHEN** they request the activity history of intervention 999999
- **THEN** the API responds 404 Not Found
- **AND** no event data is returned

#### Scenario: AC-13 An intervention without events returns an empty list
**Side:** BE
- **GIVEN** an intervention created before this release, with no recorded events
- **WHEN** a user with an ERAS role requests its activity history
- **THEN** the API responds 200 OK with an empty list
- **AND** the intervention is unchanged

### Requirement: Show the activity history in the intervention details
The system SHALL show a read-only "Activity history" section in the intervention details with each event's description, its date and time as YYYY-MM-DD HH:MM and the name of the user who acted, and MUST NOT offer to edit or delete entries.

#### Scenario: AC-14 The section lists the events with description, time and user
**Side:** FE
- **GIVEN** an intervention with the events "Intervention created" by "Ana Pérez" at 2026-11-02 09:00 and "Comment added" by "Luis Gómez" at 2026-11-04 15:30
- **WHEN** a user with an ERAS role opens the details of the intervention
- **THEN** an "Activity history" section lists "Intervention created", "2026-11-02 09:00" and "Ana Pérez" first, then "Comment added", "2026-11-04 15:30" and "Luis Gómez"
- **AND** the entries appear in the order received, oldest first

#### Scenario: AC-15 The section is read only
**Side:** FE
- **GIVEN** an intervention with events
- **WHEN** an "ERAS Administrator" opens its details
- **THEN** the "Activity history" section shows the entries as plain text
- **AND** there is no action to edit or delete an entry

#### Scenario: AC-16 An intervention with only its creation shows that single entry
**Side:** FE
- **GIVEN** an intervention whose only event is "Intervention created" by "Ana Pérez" at 2026-11-02 09:00
- **WHEN** a user with an ERAS role opens its details
- **THEN** the "Activity history" section shows only that entry
- **AND** no empty rows or error message are shown

#### Scenario: AC-17 An intervention with no events shows a message
**Side:** FE
- **GIVEN** an intervention created before this release, with no events
- **WHEN** a user with an ERAS role opens its details
- **THEN** the "Activity history" section shows "No activity recorded yet."
- **AND** the rest of the details is shown as usual

#### Scenario: AC-18 Event text is displayed as plain text
**Side:** FE
- **GIVEN** an event whose user name is `<b>Ana</b><script>alert(1)</script>`
- **WHEN** a user with an ERAS role opens the details of the intervention
- **THEN** the user name is shown literally as that text
- **AND** no markup is rendered and no script runs
