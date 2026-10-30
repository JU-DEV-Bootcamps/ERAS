# Proposal

**Status:** Approved
**Plan:** Approved

## Why

The current Spec-Driven Development (SDD) workflow found five gaps. Issue: ERAS#652 (`JU-DEV-Bootcamps/ERAS`).

1. `AGENTS.md` is the single rule file for the whole repo, but `ERAS-BE/` and `ERAS-FE/` have different stacks, commands and golden paths. An agent working inside one submodule has no definition scoped to it.
2. The workflow table (AGENTS.md §8.3) does not show at a glance who is in charge of each step, the human or the AI agent.
3. ADRs are written by `/sdd-adr` and set to `Accepted` by "a human", but there is no review step (like a PR review by leads or managers) and no sign-off by the developers and QAs who must follow them.
4. Newcomers and reviewers must open every file in `openspec/adr/` to learn the decisions in force. There is no single summary to check against.
5. There is no place that records which tools the team may adopt if the infrastructure moves (for example from GitHub to Azure DevOps for CI/CD), or how confidential data (secrets, intellectual property) is kept and secured.

**Measured (2026-10-30, characters of the root `AGENTS.md`, about 3.5 characters per token):** the file is 34,431 characters (475 lines, roughly 9,800 tokens) and loads in full on every session through `@AGENTS.md`. The backend-only sections (§3.2, §4.1, §6) are 7,296 characters and the frontend-only sections (§3.3, §4.2, §7) are 4,390. After the split, a backend session loads about 87% of today's size (saves about 1,250 tokens) and a frontend session about 79% (saves about 2,100 tokens); a session that touches both sides saves nothing. The saving is small because §8 (workflow, 12,000 characters, 35% of the file) and §9 are shared and still load every time. Splitting by side is therefore mainly about relevance and ownership, not tokens; a bigger token saving comes from slimming §8.4 and §8.5, which this change also does (see What Changes).

## What Changes

- **Agent definition per sub-project.** Add `ERAS-BE/AGENTS.md` and `ERAS-FE/AGENTS.md` (each with a `CLAUDE.md` that imports it), holding only the rules, commands and golden path of that side. The root `AGENTS.md` keeps the shared rules (principles, workflow, limits) and points to them. No rule is duplicated: a rule lives in exactly one file.
- **Slim §8.** Keep every §8 heading and the §8.3 table in the root `AGENTS.md`, but shrink the bodies of §8.4 (SDD skill conventions) and §8.5 (slash commands and skills) to what every session needs: one line per skill (the `/name` stays, because `check-skills.sh` requires it) and a pointer to the skill's `SKILL.md` for the detail. Detail that only a skill needs moves into that skill, which already loads on demand. No rule is lost: it moves to one place.
- **Responsibility by color.** In AGENTS.md §8, mark each workflow step (§8.3) and each skill (§8.5) with a role marker, human or AI, plus a legend. Markdown has no text color, so the marker is a colored emoji (for example 🟦 human, 🟩 AI, 🟨 shared) next to the existing "Who" column.
- **ADR review and sign-off.** Add to `openspec/adr/README.md` and to the ADR template: a review step (like a PR review) and a sign-off checklist before `Accepted`. Anyone with write access to the repository may review and sign; one sign-off is enough. The ADR file records who reviewed and who signed. Only a human sets `Accepted` still holds.
- **ADR summary.** Add `openspec/adr/SUMMARY.md`: one short paragraph per Accepted ADR (the rule to follow, not the history), grouped by Area, for new contributors and reviewers. `/sdd-adr` and `check-adr.sh` keep it in sync with the index, like the README index today.
- **Roadmap section.** Add a roadmap document (location in A3) with two parts: (a) a classification of tools by concern (CI/CD, hosting, identity, secrets, observability) with the criteria to evaluate a replacement, using the GitHub → Azure DevOps move as the worked example; (b) how confidential data is kept and secured (secrets, intellectual property), building on the existing "Secrets stay out" limits. It records options and criteria; it adopts no tool and changes no pipeline.

**Out of scope:** removing or renumbering any `AGENTS.md` heading (every `§` reference keeps resolving), moving the `/sdd-*` skills out of the parent repo, migrating CI/CD, changing any pipeline, rotating or moving real secrets, and rewriting any Accepted ADR. Moving `ADR-0001` from `Proposed` to `Accepted` is a human decision and is not part of this change.

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Submodules:** `ERAS-BE` and `ERAS-FE` (one new `AGENTS.md` and `CLAUDE.md` each, own PR, then parent pointer bump). Both submodules currently have unrelated uncommitted local edits that must not enter these PRs.
- **Parent repo:** `AGENTS.md`, `CLAUDE.md`, `openspec/adr/` (README, template, `SUMMARY.md`), `.claude/skills/sdd-adr/` (template, `check-adr.sh`), a roadmap document.
- **Roles / who can do what:** no change to application roles. The change defines who reviews and signs ADRs (a process rule, not an application rule).
- **API contract / data / migration:** none.
- **Risk:** splitting rules across three `AGENTS.md` files can leave rules duplicated or contradictory. Task 1.3 checks that no rule exists twice and that every `AGENTS.md` section reference (§n) still resolves.

No application behavior changes, so this change sets `skip_specs: true` (AGENTS.md §8.1, docs and tooling).

## Assumptions

- **A1.** "Sub-project" means the two submodules `ERAS-BE/` and `ERAS-FE/`. `Keycloak/`, `deploy/` and `nginx/` stay under the root file.
- **A2.** "Agent definition" means an `AGENTS.md` per sub-project imported by a `CLAUDE.md`, the same pattern as the root. Claude Code sub-agent files (`.claude/agents/*.md`) are not part of this change.
- **A3.** The roadmap lives in `openspec/roadmap.md`, linked from AGENTS.md §2.2. It could instead be an AGENTS.md section; the document keeps the root file short.
- **A4.** "Colors" are emoji markers, because plain Markdown renders no color. A diagram with real colors is a possible follow-up.
- **A5.** The review and sign-off are recorded in the ADR file (fields `Reviewed by` and `Signed by`) and in a PR checklist, so the history stays in git.

## Clarifications

- **Q1.** Who reviews ADRs and how many sign-offs? **Answer (2026-10-30):** anyone with write access to the repository (developer, lead, manager or QA) can review, sign off and accept; one sign-off is enough before `Accepted`. The ticket's "leads/managers review, devs/QAs sign" is therefore a checklist for the reviewer to follow, not a restriction on who may sign.
- **Q2.** Where do the submodule `AGENTS.md` files land? **Answer (2026-10-30):** created in this change, in `ERAS-BE` and `ERAS-FE` (own PRs, then the parent pointer bump).
