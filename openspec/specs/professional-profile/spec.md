# professional-profile Specification

## Purpose
Defines how the backend stores, returns and updates the professional profile of ERAS Professionals, and which role owns the position value shown on their account.

## Requirements

### Requirement: Professionals read their own professional profile
The system SHALL return the professional profile of the authenticated ERAS Professional, with position, faculty, office hours, subjects taught and courses, and MUST NOT return another user's profile.

#### Scenario: AC-1 Professional reads a saved profile
**Side:** BE
- **GIVEN** an ERAS Professional has saved faculty "Engineering", office hours "Mon 9:00-11:00", subjects "Algorithms" and "Databases", and course with code "CS101" named "Intro to Programming"
- **WHEN** they request their professional profile
- **THEN** the API responds 200 OK with those values
- **AND** nothing is changed

#### Scenario: AC-2 Professional who never saved gets empty values
**Side:** BE
- **GIVEN** an ERAS Professional who has never saved a professional profile
- **WHEN** they request their professional profile
- **THEN** the API responds 200 OK with empty text values and empty lists of subjects and courses

### Requirement: Professionals update their own professional profile
The system MUST accept an update of the professional profile only from the authenticated ERAS Professional, and MUST store all submitted values together, replacing the previously saved ones.

#### Scenario: AC-3 Professional saves a valid profile
**Side:** BE
- **GIVEN** an ERAS Professional with a saved professional profile
- **WHEN** they submit a complete profile with faculty "Science", office hours "Tue 14:00-16:00", subject "Statistics" and course with code "MATH200" named "Statistics II"
- **THEN** the API responds 200 OK with the saved profile
- **AND** a later request for their professional profile returns the new values

#### Scenario: AC-4 Missing required field is rejected
**Side:** BE
- **GIVEN** an ERAS Professional with a saved professional profile
- **WHEN** they submit an update where faculty is empty
- **THEN** the API responds 400 Bad Request with a message that names the field "faculty"
- **AND** the previously saved values remain unchanged

#### Scenario: AC-21 Position and office hours may be left empty
**Side:** BE
- **GIVEN** an ERAS Professional with a saved professional profile
- **WHEN** they submit a profile with faculty "Science" and empty position and office hours
- **THEN** the API responds 200 OK
- **AND** the saved position and office hours are empty

#### Scenario: AC-18 Professional profile update leaves active interventions unchanged
**Side:** BE
- **GIVEN** an ERAS Professional who has 2 active interventions they created
- **WHEN** they submit a valid professional profile update
- **THEN** the API responds 200 OK
- **AND** a request for their general profile still reports 2 active interventions

### Requirement: Professional profile text values have length limits
The system MUST reject a professional profile whose position is longer than 100 characters, whose faculty, office hours, subject or course name is longer than 200 characters, or whose course code is longer than 20 characters.

#### Scenario: AC-22 Text value longer than its limit is rejected
**Side:** BE
- **GIVEN** an ERAS Professional with a saved professional profile
- **WHEN** they submit an update where office hours has 201 characters
- **THEN** the API responds 400 Bad Request with a message that names the field "officeHours"
- **AND** the previously saved values remain unchanged

### Requirement: Every course has a code and a name
The system MUST reject a professional profile in which any course has an empty code or an empty name.

#### Scenario: AC-23 Course with an empty code or name is rejected
**Side:** BE
- **GIVEN** an ERAS Professional with a saved professional profile
- **WHEN** they submit an update with a course whose name is empty
- **THEN** the API responds 400 Bad Request with a message that names the field "courses"
- **AND** the previously saved values remain unchanged

### Requirement: Only ERAS Professionals use the professional profile
The system MUST allow reading and updating the professional profile only to the authenticated ERAS Professional, and MUST deny it to every other role, including ERAS Administrator.

#### Scenario: AC-5 Officer cannot read or update the professional profile
**Side:** BE
- **GIVEN** a user with the role "ERAS Student Services Officer"
- **WHEN** they request or submit a professional profile
- **THEN** the API responds 403 Forbidden
- **AND** no professional profile is changed

#### Scenario: AC-6 Guest cannot read the professional profile
**Side:** BE
- **GIVEN** an authenticated user with no ERAS role
- **WHEN** they request a professional profile
- **THEN** the API responds 403 Forbidden

#### Scenario: AC-20 Administrator cannot read or update the professional profile
**Side:** BE
- **GIVEN** a user with the role "ERAS Administrator"
- **WHEN** they request or submit a professional profile
- **THEN** the API responds 403 Forbidden
- **AND** no professional profile is changed

### Requirement: Position is owned by the professional profile for professionals
The system MUST store the position submitted with a professional profile as the position of that user, and MUST NOT change the position of an ERAS Professional through the general profile update.

#### Scenario: AC-7 Position saved from the professional profile is shown in the profile
**Side:** BE
- **GIVEN** an ERAS Professional
- **WHEN** they save a professional profile with position "Dean"
- **THEN** a request for their general profile returns position "Dean"

#### Scenario: AC-8 General profile update ignores position for a professional
**Side:** BE
- **GIVEN** an ERAS Professional whose position is "Dean"
- **WHEN** they submit a general profile update with position "Associate Dean" and their other editable fields
- **THEN** the API responds 200 OK
- **AND** their position remains "Dean"
- **AND** their other editable fields are updated

#### Scenario: AC-9 General profile update still sets position for other roles
**Side:** BE
- **GIVEN** an ERAS Student Services Officer whose position is "Officer"
- **WHEN** they submit a general profile update with position "Coordinator"
- **THEN** the API responds 200 OK
- **AND** their position is "Coordinator"
