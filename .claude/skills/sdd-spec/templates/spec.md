# Spec Delta

<!--
TEMPLATE for openspec/changes/<change-id>/specs/<capability-path>/spec.md
Fill it in, then DELETE every HTML comment (including this one) from the output file.
One file per capability. Behavior only: no class, method, table or library names.
-->

## Purpose
<!-- NEW capability only: 1-2 sentences, 50+ characters, on what the capability is for.
     DELETE this whole section when the capability already exists under openspec/specs/. -->
<What this capability is for, in plain words.>

## ADDED Requirements
<!-- Use MODIFIED instead (full existing block, copied from openspec/specs/) when behavior of an
     existing requirement changes. REMOVED needs **Reason** and **Migration**. -->

### Requirement: <one behavior, in plain words>
<!-- One behavior per requirement. SHALL / MUST only. 500 characters or fewer.
     Examples and edge cases go into scenarios, not here. -->
The system SHALL <observable behavior> <for which actor> <under which constraint>.

<!-- Scenario = Acceptance Criterion (AC).
     - Heading: exactly 4 '#', "AC-<n> <short title>". n starts at 1, unique in the CHANGE (not per file),
       never renumbered, never reused.
     - One scenario = one behavior = one automated test per affected side (BE / FE).
     - Line right under the heading: **Side:** BE | FE | BE + FE (the sides whose test proves the AC;
       it becomes the Side column of the traceability table in tasks.md).
     - WHEN and THEN are mandatory. Use concrete values ("Main", 409), exact role names, observable results.
     - Cover, for every new endpoint or route: the happy path, each allowed role, each DENIED role,
       and each validation failure. Any change to who can do what is its own AC. -->

#### Scenario: AC-1 <happy path title>
**Side:** BE + FE
- **GIVEN** <starting state, actor and role>
- **WHEN** <single action>
- **THEN** <observable result: status code, message, what the user sees>
- **AND** <side effect that must (not) happen, e.g. "no new record is persisted">

#### Scenario: AC-2 <denied role title>
**Side:** BE
- **GIVEN** a user with the role "ERAS Professional"
- **WHEN** they <perform the action>
- **THEN** the API responds 403 Forbidden
- **AND** nothing is changed

#### Scenario: AC-3 <validation failure title>
**Side:** BE
- **GIVEN** <valid actor>
- **WHEN** they submit <invalid input, concrete>
- **THEN** the API responds 400 Bad Request with a message that names the invalid field
- **AND** nothing is persisted

<!-- Only when a real ambiguity changes scope, behavior, authorization or data and cannot be
     answered from the code or specs (max 3 per change), keep the scenario and mark the gap inline:
       - **THEN** [NEEDS CLARIFICATION: <one concrete question>]
     /sdd-clarify resolves and removes these markers. Never guess silently. -->
