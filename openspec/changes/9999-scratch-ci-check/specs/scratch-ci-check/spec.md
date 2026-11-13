# Spec Delta

## Purpose

Temporary capability that exists only to prove that the SDD checks workflow reports a spec that breaks a project rule.

## ADDED Requirements

### Requirement: The scratch check reports a scenario without a side

The system SHALL report a scenario that has no Side line when the SDD checks workflow runs.

#### Scenario: AC-1 Scenario without a Side line
- **GIVEN** a scratch change whose scenario has no Side line
- **WHEN** the workflow runs check-spec.sh
- **THEN** it reports that the scenario has no Side line
