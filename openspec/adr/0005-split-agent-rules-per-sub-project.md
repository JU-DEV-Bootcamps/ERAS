# ADR-0005: Split agent rules per sub-project, one rule one home

**Status:** Accepted
**Date:** 2026-10-30
**Area:** process
**Change:** 652-improve-sdd
**Reviewed by:** dev team
**Signed by:** Judith Paco

## Context

`AGENTS.md` in the parent repository is the single rule file for every contributor and agent, and the root `CLAUDE.md` imports it, so all of it (about 34,000 characters) loads in every session. Backend and frontend rules (`§3.2`, `§4.1`, `§6` and `§3.3`, `§4.2`, `§7`) have different stacks, commands and golden paths, and a session that works on one side loads the other side's rules too. `ERAS-BE/` and `ERAS-FE/` are separate git repositories (submodules) with no agent definition of their own.

About 20 files under `.claude/skills/` cite `AGENTS.md` sections by number, and `.claude/skills/sdd-plan/tests/check-skills.sh` fails when a cited section is not a heading of the root `AGENTS.md`. Moving sections out would break those citations.

## Decision

Each sub-project has its own `AGENTS.md`, imported by a `CLAUDE.md` that contains only `@AGENTS.md`. The backend and frontend rules live there and nowhere else: a rule has exactly one home. The root `AGENTS.md` keeps every heading and number; the body of a moved section becomes a pointer to the submodule file. The submodule files reuse the original section numbers, so "`AGENTS.md` §6.1" resolves to one place. Submodule files name the parent file in plain text and never link to it by relative path, because a submodule can be cloned or built alone. The `/sdd-*` skills and the OpenSpec changes stay in the parent repository.

## Alternatives

- Keep one root `AGENTS.md` → loads both sides' rules in every session and gives the submodule teams no place of their own.
- Remove the moved sections from the root and rewrite every citation → a large diff across about 20 skill files and open changes, and `check-skills.sh` would need new logic.
- Copy the rules into the submodules and keep them in the root too → two homes drift apart.
- Relative links from the submodules to `../AGENTS.md` → dead links when a submodule is used on its own.

## Consequences

- A session in one submodule loads that side's rules plus the shared ones; a session touching both sides loads both and saves nothing.
- A new rule is added to exactly one file, and a review of the split checks that no rule appears twice.
- The root keeps small pointer sections for the moved topics, so the skills' citations keep working.
- The submodule `AGENTS.md` files ship in the submodule PRs and reach the parent through the pointer bump (`AGENTS.md` §5.1).
