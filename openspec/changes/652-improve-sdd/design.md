# Design

## Context

See proposal.md (Why, What Changes, Clarifications). This change has no spec and no ACs (`skip_specs: true`): it edits documents and the SDD check scripts. It touches the parent repo and the two submodules.

What exists today, from the files:
- Root `AGENTS.md` (34,431 characters). Backend-only parts: §3.2, §4.1, §6 (6.1–6.3). Frontend-only parts: §3.3, §4.2, §7 (7.1–7.3). Shared: §1, §2, §3.1, §3.4, §4.3, §5, §8, §9.
- `ERAS-BE/` and `ERAS-FE/` have a `README.md` and no `AGENTS.md` or `CLAUDE.md`. Neither repo ignores those names. `ERAS-FE/.claude/` exists untracked (skill `eras-fe-test`) and is left alone.
- `.claude/skills/sdd-plan/tests/check-skills.sh` fails when a skill, its templates or its examples cite an `AGENTS.md` section (`§n` or `section n`) that is not a `##`/`###` heading of the **root** `AGENTS.md`, and when a skill's `/name` is missing from the root file. About 20 skill files cite sections.
- `.claude/skills/sdd-adr/scripts/check-adr.sh` treats every `openspec/adr/*.md` except `README.md` as an ADR, so a new `SUMMARY.md` there fails it ("file name must be NNNN-<kebab-title>.md"). It checks the README index row by row against the ADR files.
- ADRs 0002 and 0003 are `Accepted` and carry no review or sign-off fields; the first ADR is still `Proposed`.
- The self-test `.claude/skills/sdd-plan/tests/run-tests.sh` has a `check-adr` section (about line 197) that builds fixture ADRs.

## Goals / Non-Goals

**Goals:**
- Every `AGENTS.md` heading and number that exists today still exists, so no `§` citation breaks.
- Each rule has exactly one home.
- The check scripts and the self-test cover the new ADR rules (review, sign-off, summary) and stay green.

**Non-Goals:**
- No change to the application behavior, pipelines or real secrets.
- Do not write or backfill review and sign-off values for the existing ADRs: only a human signs.
- No ADR is written by this plan (see Open Questions).

## Decisions

### D1. Keep every root heading; replace the body of moved sections with a pointer
**Choice:** Backend sections (§3.2, §4.1, §6.1–6.3) and frontend sections (§3.3, §4.2, §7.1–7.3) keep their heading in the root `AGENTS.md`; the body becomes one or two lines: "Backend rules live in `ERAS-BE/AGENTS.md` §<same number>; read it before working in `ERAS-BE/`." The submodule files reuse the **same section numbers** (`ERAS-BE/AGENTS.md` has §3.2, §4.1, §6.x; `ERAS-FE/AGENTS.md` has §3.3, §4.2, §7.x), so "AGENTS.md §6.1" has one home and `check-skills.sh` keeps passing unchanged for these.
**Alternative:** Remove the sections and rewrite the citations in about 20 skill files → large diff, breaks the open changes' text, and `check-skills.sh` would need new logic.
**ADR:** ADR-0005

### D2. Submodule files name the parent file in plain text, never by relative link
**Choice:** `ERAS-BE/AGENTS.md` and `ERAS-FE/AGENTS.md` start with "Shared rules (principles, workflow, limits) are in the root `AGENTS.md` of the ERAS parent repository" and use no `../` links. Each submodule `CLAUDE.md` contains `@AGENTS.md` only (the import resolves relative to the file that holds it).
**Alternative:** Relative links to `../AGENTS.md` → dead links when a submodule is cloned or built alone.

### D3. Slim §8.4 and §8.5 into one shared file; the headings and the §8.3 table stay
**Choice:** Move the bodies of §8.4 (SDD skill conventions table) and §8.5 (skill tables) to a new `openspec/sdd-conventions.md`, the single source the `/sdd-*` skills read on demand. In the root file, §8.4 keeps its heading plus the status-line rule and the sentence "only a human sets Approved/Accepted"; §8.5 keeps its heading and one line per command or skill: `/name`, step, role marker, and a pointer to its `SKILL.md`. The `/name` of every skill stays in the root file because `check-skills.sh` requires it.
**Alternative:** Move each detail into the single skill that uses it (the proposal's wording) → §8.4 is shared by all eight skills, so it would be copied eight times. Only skill-specific detail goes into a `SKILL.md`; shared conventions go to the shared file. (proposal.md says "that skill"; the shared file is the only addition to it.)

### D4. Role markers are emoji in the existing "Who" column, with one legend
**Choice:** Legend under §8.3: 🟦 human, 🟩 AI agent, 🟨 shared (the agent drafts, a human approves). Applied to every §8.3 step and every row of the §8.5 tables, and repeated in `openspec/sdd-conventions.md`. The marker must agree with the rule "only a human sets Approved/Accepted".
**Alternative:** A Mermaid diagram with real colors → renders inconsistently in terminals and the desktop app. Possible follow-up.

### D5. ADR review and sign-off are recorded in the ADR file and checked by `check-adr.sh`
**Choice:** New fields in the ADR template, after `**Change:**`: `**Reviewed by:**` and `**Signed by:**`, each `<GitHub handle> (YYYY-MM-DD)`, left empty while `Proposed`. `openspec/adr/README.md` gains a "Review and sign-off" section: the ADR travels in a PR, anyone with write access reviews it with the checklist below and one person signs, then a human sets `Accepted`. Checklist: one decision per file; Context states facts, not the answer; Alternatives are real; Consequences name the new rule; consistent with the Accepted ADRs; Area correct; no secret, host or personal data; index and `SUMMARY.md` rows updated. `check-adr.sh`: **error** if an ADR is `Accepted`, dated on or after this change's date (2026-10-30) and has no `Signed by` value; **warning** for older Accepted ADRs without one, so ADR-0002 and ADR-0003 stay green until a human signs them.
**Alternative:** Error for every Accepted ADR → red on day one for ADR-0002/0003, and a skill must not invent signatures.
**ADR:** ADR-0006

### D6. `SUMMARY.md` is a checked mirror of the Accepted ADRs, maintained by the skill
**Choice:** `openspec/adr/SUMMARY.md`: grouped by Area (same grouping as the README index), one `### ADR-NNNN <title>` entry per **Accepted** ADR with a "Rule:" sentence of at most 2 lines and a link to the file. `check-adr.sh` skips `SUMMARY.md` as a file, and errors when an Accepted ADR has no entry or an entry points to a non-Accepted or missing ADR. `/sdd-adr` updates it with the README index. `/sdd-plan` reads it instead of every ADR of the same Area when it checks for overlap.
**Alternative:** Hand-maintained list with no check → drifts, exactly like an unchecked index.

### D7. The roadmap is a standalone document that records options and criteria only
**Choice:** `openspec/roadmap.md`, linked from AGENTS.md §2.2, with: (1) status line "no tool adopted by this document"; (2) a table of concerns (CI/CD, source hosting, hosting and runtime, identity, secrets, observability) with today's tool taken from the repo files (`.github/workflows/`, `docker-compose*.yml`, `nginx/`, `Keycloak/`, `deploy/`), the options to evaluate and the criteria; (3) a migration checklist with GitHub → Azure DevOps as the worked example (pipelines, branch policies, submodules, commit hooks, secret store, permissions); (4) a confidential-data section: secrets, personal data of students, intellectual property (source, specs, ADRs), with the rules that already exist in AGENTS.md §9 plus where each class may live and who may access it. No secret value, host name, key or URL of a private resource appears in it.
**Alternative:** A section inside `AGENTS.md` → grows the always-loaded file this change is shrinking.

## Changes by layer

### Parent repo (`ERAS/`)

| Piece | Change | Files |
|---|---|---|
| Rules | Replace the bodies of §3.2, §3.3, §4.1, §4.2, §6, §7 with pointers (D1); slim §8.4/§8.5 (D3); add legend and markers (D4); link the roadmap in §2.2 | `AGENTS.md` (edit) |
| Claude entry | Note that sub-project files exist and load on demand | `CLAUDE.md` (edit) |
| SDD conventions | Receives the moved §8.4/§8.5 bodies | `openspec/sdd-conventions.md` (new) |
| ADRs | Review and sign-off section; summary | `openspec/adr/README.md` (edit), `openspec/adr/SUMMARY.md` (new) |
| Skills | `/sdd-adr` writes the new fields and updates the summary; `/sdd-plan` reads the summary; skills that cite §8.4 point to the shared file | `.claude/skills/sdd-adr/SKILL.md`, `.claude/skills/sdd-adr/templates/adr.md`, `.claude/skills/sdd-plan/SKILL.md` (edit) |
| Checks | `check-adr.sh`: skip `SUMMARY.md`, summary check, sign-off check (D5, D6). Self-test cases for each | `.claude/skills/sdd-adr/scripts/check-adr.sh`, `.claude/skills/sdd-plan/tests/run-tests.sh` (edit) |
| Roadmap | New document (D7) | `openspec/roadmap.md` (new) |

### Backend (`ERAS-BE/`)

| Piece | Change | Files |
|---|---|---|
| Agent definition | Rules, commands, Onion layers, golden path, tests moved from root §3.2, §4.1, §6.1–6.3, same numbers (D1, D2) | `ERAS-BE/AGENTS.md` (new), `ERAS-BE/CLAUDE.md` (new, `@AGENTS.md`) |

### Frontend (`ERAS-FE/`)

| Piece | Change | Files |
|---|---|---|
| Agent definition | Rules, commands, layers, golden path, tests moved from root §3.3, §4.2, §7.1–7.3, same numbers | `ERAS-FE/AGENTS.md` (new), `ERAS-FE/CLAUDE.md` (new, `@AGENTS.md`) |

## API contract
No API change.

## Data and migration
No schema change.

## Test strategy

No ACs, so no tagged tests. Behavior of the scripts is covered by untagged cases added to `.claude/skills/sdd-plan/tests/run-tests.sh` (section `adr`) and written before the script edits: `SUMMARY.md` present is not parsed as an ADR; an Accepted ADR missing from the summary fails; an entry for a non-Accepted ADR fails; an Accepted ADR dated 2026-10-30 or later without `Signed by` fails; an older one warns. The documents are checked by `check-skills.sh` (every `§` citation resolves), `check-adr.sh`, and `openspec validate --strict`. Token claim: record the new `AGENTS.md` size against 34,431 characters.

## Risks / Trade-offs

- [A moved section is copied instead of moved, leaving a rule in two files] → task 1.4 diffs the root against the submodule files and checks that no paragraph appears twice.
- [An agent starts in the root and never reads the submodule file] → each root stub says to read the file before working in that folder; the skills that cite §6.1 and §7.1 keep resolving to the stub.
- [Submodule PRs and the parent pointer land out of order] → ship the submodule PRs first, bump the pointer only after they merge (AGENTS.md §5.1); the parent stubs are valid once the files exist on the merged commit.
- [Both submodules have unrelated uncommitted edits] → stage only the new files in each PR.
- [`check-adr.sh` change breaks `check-archive.sh`, which calls it] → the self-test sections `adr` and `archive` both run before ship.
- [§8.4/§8.5 slimming drops a rule only the old text carried] → task 2.2 lists each removed row and where it went before the root text is cut.

## Open Questions

- None. ADR-0005 and ADR-0006 are `Accepted`; a human still has to add their `Reviewed by` and `Signed by` values.

## Follow-ups

- A Mermaid diagram with real colors for the §8.3 workflow (D4 alternative).
- A human signs the existing ADRs (and decides whether the first ADR is Accepted): this plan does not do it.
- Moving the remaining shared detail out of `AGENTS.md` (§1.1, §9) if more token saving is wanted.
