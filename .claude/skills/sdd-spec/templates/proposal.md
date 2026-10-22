# Proposal

<!--
TEMPLATE for openspec/changes/<change-id>/proposal.md, created by /sdd-spec.
Keep it to one page. Why and what, never how. Delete every HTML comment from the output file.
design.md and tasks.md are NOT written here.
-->

**Status:** Draft
<!-- Draft = written, may contain open questions.   (set by /sdd-spec)
     Clarified = no open questions remain.            (set by /sdd-clarify)
     Approved = a human reviewer accepted the spec.   (set by the human ONLY, never by an agent)
     Spec approval is an early gate; code still waits for approval of the full change (design + tasks). -->

## Why

<!-- 1-2 sentences: the problem, who has it, why now. Link the issue: ERAS-BE#<n> and/or ERAS-FE#<n>. -->
<Problem and motivation.> Issue: ERAS-BE#<n> / ERAS-FE#<n>

## What Changes

<!-- Bullets, specific. Mark breaking changes with **BREAKING**. -->
- <change 1>
- <change 2>

**Out of scope:** <what this change deliberately does not do>

## Capabilities

### New Capabilities
<!-- Durable behavior, kebab-case, not a task name. Run `openspec list --specs` first; reuse existing paths. -->
- `<capability-path>`: <what it covers>

### Modified Capabilities
<!-- Exact existing path under openspec/specs/. Leave empty if none. -->
- `<existing-capability-path>`: <which requirement changes>

## Impact

- **Submodules:** <BE | FE | BE + FE>
- **Roles / who can do what:** <state explicitly, e.g. "Student Services Officer may now ...", or "no change">
- **API contract:** <new or changed endpoints in one line, or "none"> (details go to design.md)
- **Data / migration:** <yes/no, one line>

## Assumptions
<!-- Minor ambiguities resolved by a reasonable default. One line each, numbered, so a reviewer can challenge them.
     Remove the section if there are none. -->
- A1: <assumption and why it is reasonable>

## Clarifications
<!-- Appended by /sdd-clarify. Leave this heading empty until then. -->
