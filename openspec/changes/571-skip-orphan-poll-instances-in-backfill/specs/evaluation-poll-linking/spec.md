# Spec Delta

## Purpose

Every poll that has poll instances is linked to its evaluation, so evaluation details can join each
poll instance to its own poll. This covers the one-time backfill that repairs older imports which
only linked the first poll of an evaluation.

## ADDED Requirements

### Requirement: The backfill skips poll instances whose evaluation no longer exists
The backfill of evaluation-to-poll links SHALL ignore poll instances that reference an evaluation
that does not exist, so that it completes on a database with such orphan references and creates no
link for them.

#### Scenario: AC-1 Orphan poll instances are skipped instead of failing the migration
**Side:** BE
- **GIVEN** evaluation 1 exists, polls 10 (uuid "a") and 11 (uuid "b") exist
- **AND** poll instances reference poll "a" for evaluation 1, poll "b" for evaluation 46 and poll "a" for evaluation 45, where evaluations 45 and 46 do not exist
- **WHEN** the backfill runs against tables with foreign keys enabled
- **THEN** it completes without error
- **AND** the only link created is evaluation 1 to poll 10

### Requirement: The backfill links every poll that has instances to its existing evaluation
The backfill SHALL create one evaluation-to-poll link for each distinct pair of existing evaluation
and poll that appears in the poll instances, and SHALL ignore poll instances with no evaluation.

#### Scenario: AC-2 Each poll with instances is linked once to its evaluation
**Side:** BE
- **GIVEN** evaluation 1 exists, polls 10 (uuid "a") and 11 (uuid "b") exist
- **AND** evaluation 1 has two poll instances of poll "a" and one of poll "b"
- **WHEN** the backfill runs
- **THEN** the links are exactly evaluation 1 to poll 10 and evaluation 1 to poll 11

#### Scenario: AC-3 Poll instances without an evaluation are ignored
**Side:** BE
- **GIVEN** evaluation 1 and poll 10 (uuid "a") exist
- **AND** the only poll instance of poll "a" has no evaluation
- **WHEN** the backfill runs
- **THEN** no link is created

### Requirement: The backfill keeps existing links and is idempotent
The backfill SHALL keep every link that already exists and SHALL be safe to run more than once
without creating duplicate links.

#### Scenario: AC-4 Existing links are kept and a second run adds nothing
**Side:** BE
- **GIVEN** evaluation 1 exists, polls 10 (uuid "a") and 11 (uuid "b") exist with one instance each for evaluation 1
- **AND** the link evaluation 1 to poll 10 already exists
- **WHEN** the backfill runs twice
- **THEN** the links are exactly evaluation 1 to poll 10 and evaluation 1 to poll 11
- **AND** no duplicate link is created
