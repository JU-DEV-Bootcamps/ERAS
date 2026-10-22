# Proposal

<!-- ILLUSTRATIVE EXAMPLE of a filled-in proposal. The change is fictional (it reuses the 608 example of AGENTS.md section 3.1). Do not copy its content. -->

**Status:** Draft

## Why

Officers can create two active configurations with the same name, so reports and imports cannot tell them apart. Issue: ERAS-BE#608 / ERAS-FE#608

## What Changes

- Creating a configuration whose name is already used by an active configuration of the same officer is rejected with a clear message.
- The configurations form shows that message instead of a generic error.

**Out of scope:** renaming existing configurations; deduplicating configurations that already exist.

## Capabilities

### New Capabilities
- `configuration-management`: creation of configurations and the rules they must satisfy.

### Modified Capabilities

## Impact

- **Submodules:** BE + FE
- **Roles / who can do what:** no change; `ERAS Administrator` and `ERAS Student Services Officer` may create configurations, `ERAS Professional` and Guest may not.
- **API contract:** the create endpoint gains a 409 response (details go to design.md)
- **Data / migration:** no

## Assumptions

- A1: Names are compared case-insensitively and without leading or trailing spaces, because "main" and "Main " would look identical to an officer.

## Clarifications
