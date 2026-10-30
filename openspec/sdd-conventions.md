# SDD conventions and skills

Single source of the conventions shared by the `/sdd-*` skills, and the full list of slash commands and skills.
The root `AGENTS.md` §8.4 and §8.5 keep the headings and a short summary and point here (ADR-0005 explains why
detail is kept in one place). The workflow itself (steps, gates, agent obligations) stays in `AGENTS.md` §8.3.

**Who is in charge (markers).** 🟦 human · 🟩 AI agent · 🟨 shared: the agent drafts or runs, a human decides.
Only a human sets `Approved` on a spec or a plan and `Accepted` on an ADR, so no step is marked 🟩 when it ends
in one of those decisions.

## SDD skill conventions

The skills `/sdd-spec` → `/sdd-clarify` → `/sdd-plan` → `/sdd-implement` → `/sdd-validate-impl` → `/sdd-verify` → `/sdd-archive` (see "Slash commands and skills" below), plus `/sdd-adr` (called from `/sdd-plan` or on its own), share these conventions. This section is their single source. Only `/sdd-implement` writes code; no skill commits.

| Item | Convention |
|---|---|
| Files | `proposal.md` (why, what, status lines, logs), `specs/<capability>/spec.md` (ACs), `design.md` (**the plan**: layers, API contract, test strategy), `tasks.md` (checklist and Traceability) |
| Status lines | In `proposal.md`: `**Status:** Draft \| Clarified \| Approved` for the spec and `**Plan:** Draft \| Approved` for `design.md` + `tasks.md`. **Only a human sets `Approved`.** Code waits for `Plan: Approved` |
| AC | `#### Scenario: AC-<n> <title>` plus a line `**Side:** BE \| FE \| BE + FE`. Key: `<change-id>/AC-<n>` |
| Tasks | `- [ ] <group>.<n> <description>`. A test task starts with "Write" and cites `(AC-<n>)`, and comes before its implementation task. Replaced tasks are struck through, never renumbered |
| Logs | `## Clarifications` and `## Validation log` live in `proposal.md`. **Never in `spec.md`**: it is a delta that is merged into `openspec/specs/` on archive |
| Done | Every task ticked, Traceability filled with real tests (exactly 1 per AC per side), §8.7 gates green, `openspec validate --strict`; then the parent-repo commit carries the change folder and its ADR files (§8.3 step 5), the submodule PRs merge, the change is archived as the last commit of the ship PR (§8.3 step 6) and the ship PR merges. There is no separate `Implemented` status |
| ADR | One decision per file in `openspec/adr/NNNN-<kebab-title>.md`, numbered from `0001` with no gaps, never reused. Fields `**Status:**` (`Proposed`, `Accepted`, `Rejected`, `Deprecated`, `Superseded by ADR-NNNN`), `**Date:**`, `**Area:**` (`backend`, `frontend`, `auth`, `data`, `infra`, `process`), `**Change:**`, `**Reviewed by:**` and `**Signed by:**` (empty until a human fills them), optional `**Supersedes:**`; sections Context, Decision, Alternatives, Consequences. Index: `openspec/adr/README.md`, grouped by Area; summary of the Accepted ADRs: `openspec/adr/SUMMARY.md` |
| ADR use | An ADR is for a decision that outlives its change: a dependency or pattern, an auth/role/ownership model, a data or migration approach, a cross-cutting BE ↔ FE contract, a departure from a golden path (§6.1, §7.1). The `design.md` D-block links it as `**ADR:** ADR-NNNN`. **Only a human sets `Accepted`**, after a review like a PR and one sign-off by anyone with write access (checklist in `openspec/adr/README.md`, ADR-0006), usually with `Plan: Approved`. An Accepted ADR is never rewritten: a new ADR supersedes it, and the old one's Status becomes `Superseded by ADR-MMMM` once the new one is Accepted. `/sdd-verify` requires every linked ADR to be Accepted, and the ADR files ship in the change's commit (§8.3 step 5) |
| Checks | `.claude/skills/sdd-spec/scripts/check-spec.sh`, `sdd-plan/scripts/check-plan.sh`, `sdd-implement/scripts/check-impl.sh`, `sdd-verify/scripts/verify-gate.sh` (pre-flight gate), `sdd-verify/scripts/run-gates.sh` (runs the §8.7 gates and prints one line per gate), `sdd-adr/scripts/check-adr.sh`, `sdd-archive/scripts/check-archive.sh`, and `sdd-plan/tests/check-skills.sh` for the skills themselves. Self-test: `bash .claude/skills/sdd-plan/tests/run-tests.sh` (from a path without spaces) |
| Skill model | A skill may pin a model with `model:` in its `SKILL.md` frontmatter. Use an alias (`haiku`, `sonnet`, `opus`), not a full model ID. The pin applies to that skill's turn only and overrides the session model (`/model`) for it; the session model resumes on the next prompt. A value outside the organization's allowed models is ignored. Pinned today: `sdd-validate-impl` and `sdd-archive` (`haiku`, see change `653-adjust-skills-for-token-usage`); every other skill uses the session model |

## Slash commands and skills

**Claude Code slash commands** (installed in `.claude/` by `openspec init --tools claude --profile core`):

| Command | Who | Step (§8.3) | What it does |
|---|---|---|---|
| `/opsx:explore` | 🟨 | before 1 | Think through an idea or investigate code, without writing anything |
| `/opsx:propose "<idea>"` | 🟨 | 1. Propose | Creates the change with proposal, specs, design and tasks, then stops for approval |
| `/opsx:update` | 🟨 | 1–3 | Revises the artifacts of an existing change |
| `/opsx:apply` | 🟩 | 3. Implement | Works through `tasks.md` (only after approval) |
| `/opsx:sync` | 🟩 | 6 | Syncs the delta specs into `openspec/specs/` |
| `/opsx:archive` | 🟨 | 6. Archive | Archives a completed change |

**Project skills** (in `.claude/skills/`, optional spec-first path; conventions above. Only `/sdd-implement` writes code and none of them commits):

| Command | Who | Step (§8.3) | What it does |
|---|---|---|---|
| `/sdd-spec "<idea>"` | 🟨 | 1. Propose | Creates or updates the Draft spec (AC scenarios) of a change from an idea, with templates |
| `/sdd-clarify <change-id>` | 🟨 | 1. Propose | Finds gaps in a Draft spec, asks at most 5 questions and records the answers. Then a human reviews and sets `Status: Approved` |
| `/sdd-plan <change-id>` | 🟨 | 1. Propose | For an Approved spec, writes `design.md` (the plan: layers, API contract, test strategy) and `tasks.md` with the traceability table. Then a human sets `Plan: Approved` (step 2) |
| `/sdd-implement <change-id>` | 🟩 | 3. Implement | Works through `tasks.md` in order, test first, one tagged test per AC per side, then runs the §8.7 gates and reports. Needs `Plan: Approved`; never commits |
| `/sdd-validate-impl <change-id>` | 🟨 | 4. Verify | Manual validation gate, only when a BE controller or the FE changed: hands you a checklist per AC, logs the result in `proposal.md` and sends problems back to `/sdd-implement` |
| `/sdd-verify <change-id>` | 🟩 | 4. Verify | Audit: tasks ticked, one tagged test per AC per side, §8.7 gates, linked ADRs Accepted, no drift from the spec and `design.md`. Fills the Traceability table, lists the files the parent-repo commit must carry (change folder and ADRs) and recommends `/sdd-archive`; never archives |
| `/sdd-archive <change-id>` | 🟨 | 6. Archive | After `/sdd-verify` and the ship PR's approval: checks the gate (tasks ticked, `Verified` line, linked ADRs Accepted, submodule pointers merged), archives the change as the last commit of the ship PR, validates the living specs and lists the files to commit; never commits |
| `/sdd-adr ["<decision>"]` | 🟨 | 1. Propose (or any time) | Writes an ADR in `openspec/adr/` (status `Proposed`) or supersedes one, and updates the index. `/sdd-plan` offers it for architectural decisions; a human sets `Accepted` |
