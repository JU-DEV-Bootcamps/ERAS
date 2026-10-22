# Spec Delta

<!-- ILLUSTRATIVE EXAMPLE of a filled-in delta spec. The change is fictional. Do not copy its content. -->

## Purpose
Defines how officers create configurations and the rules a new configuration must satisfy before it is saved.

## ADDED Requirements

### Requirement: Active configuration names are unique per officer
The system SHALL reject the creation of a configuration whose name matches, ignoring case and surrounding spaces, an active configuration of the same officer.

#### Scenario: AC-1 Duplicate active name is rejected
**Side:** BE
- **GIVEN** an officer already owns an active configuration named "Main"
- **WHEN** they create another configuration named " main "
- **THEN** the API responds 409 Conflict with the message "A configuration with this name already exists"
- **AND** no new configuration is persisted

#### Scenario: AC-2 Name of an inactive configuration can be reused
**Side:** BE
- **GIVEN** an officer owns only an inactive configuration named "Main"
- **WHEN** they create a configuration named "Main"
- **THEN** the API responds 201 Created
- **AND** the new configuration is active

#### Scenario: AC-3 Conflict message is shown on the form
**Side:** FE
- **GIVEN** an officer has the create-configuration form open and the API will answer 409 Conflict
- **WHEN** they submit the form
- **THEN** the form shows "A configuration with this name already exists" next to the name field
- **AND** the form stays open with the typed values

### Requirement: Only administrators and officers create configurations
The system MUST allow only `ERAS Administrator` and `ERAS Student Services Officer` to create configurations.

#### Scenario: AC-4 Professional cannot create a configuration
**Side:** BE
- **GIVEN** a user with the role "ERAS Professional"
- **WHEN** they create a configuration named "Main"
- **THEN** the API responds 403 Forbidden
- **AND** no configuration is persisted

#### Scenario: AC-5 Guest cannot reach the create form
**Side:** FE
- **GIVEN** a user with no ERAS role
- **WHEN** they open the create-configuration route
- **THEN** they are redirected to the access-denied page

### Requirement: A configuration needs a name
The system SHALL reject the creation of a configuration whose name is empty or only spaces.

#### Scenario: AC-6 Blank name is rejected
**Side:** BE + FE
- **GIVEN** an officer creating a configuration
- **WHEN** they submit the name "   "
- **THEN** the API responds 400 Bad Request with a message that names the field "name"
- **AND** the form shows the same message and no configuration is persisted
