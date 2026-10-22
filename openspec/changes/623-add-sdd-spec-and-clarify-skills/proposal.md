# Proposal

## Why

Writing a spec from an idea and refining it before review is done by hand today, and nothing enforces the AC format, the Side of each AC or the question discipline before `/opsx:propose` generates everything at once. Issue: ERAS#623

## What Changes

- Add the project skill `/sdd-spec`: creates or updates a Draft change (`proposal.md` and the delta `spec.md`) with templates, a worked example and a checker script.
- Add the project skill `/sdd-clarify`: reviews a Draft spec, asks at most 5 questions and records the answers, with templates and a worked example.
- Document both skills in `AGENTS.md` section 5.1 and mention them in `CLAUDE.md`.

**Out of scope:** changes to `openspec/config.yaml`, to the `/opsx:*` workflows, and any change in `ERAS-BE/` or `ERAS-FE/`.

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Submodules:** none (parent repo only: `.claude/skills/`, `AGENTS.md`, `CLAUDE.md`)
- **Roles / who can do what:** no change
- **API contract:** none
- **Data / migration:** none

No spec-level behavior changes, so this change sets `skip_specs: true` (AGENTS.md section 3, tooling and docs).
