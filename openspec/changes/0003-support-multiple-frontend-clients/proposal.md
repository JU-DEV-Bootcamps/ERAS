# Proposal

**Status:** Approved

## Why

ERAS gets a second, permanent web client: ERAS v3 in React, in a new submodule `ERAS-FE-React`, next to ERAS v2 (Angular, `ERAS-FE`), which stays in production and is kept by another team. The SDD rules and scripts assume one frontend: the sides `BE` and `FE` are written by hand in about 18 files, and the scripts read the `**Side:**` line by substring (`/FE/`, `grep -qw FE`), so a side named `FE-React` would also count as `FE`, and `check-spec.sh` would reject it. Adding a client today means editing every one of those files, and removing one means editing them again. Issue: placeholder `0003` (no issue yet; rename the folder when it exists, before approval).

## What Changes

- **Side registry (new): `openspec/sides.conf`.** One line per side with its name, submodule folder, test root, test file patterns, how a test carries the AC key (`trait` or `title`), the pattern of a focused or skipped test, its parity group and its gate commands. It starts with three entries:

  | Side | Submodule | Tests | AC key in | Group | Gates |
  |---|---|---|---|---|---|
  | `BE` | `ERAS-BE` | `test/**/*.cs` | `[Trait("AC", "<key>")]` | — | today's BE gates, unchanged |
  | `FE` | `ERAS-FE` | `src/app/**/*.spec.ts` | `it('[<key>] …')` | `web` | today's FE gates, unchanged |
  | `FE-React` | `ERAS-FE-React` | `src/**/*.test.ts`, `src/**/*.test.tsx` | `it('[<key>] …')` | `web` | `npm run lint`, `npm run test:ci`, `npm run typecheck`, `npm run build` |

  Adding or removing a client is one line in this file plus the client's own `AGENTS.md` (ADR-0007). No script, skill or rule names a client by hand. The FE-React gates are `npm run` script names, so the commands behind them (`vitest run --coverage`, `tsc --noEmit`, `vite build`) and the 15% coverage threshold live in `ERAS-FE-React`, not here.
- **Shared reader (new): `.claude/skills/sdd-shared/sides.sh`.** One sourced shell file that reads the registry and the `**Side:**` lines. It has no `SKILL.md`, so it is not a skill and `check-skills.sh` skips it.
- **Exact side matching.** A `**Side:**` value is split on ` + `, and each part is compared whole against the registered names: `FE` and `FE-React` are different sides. `check-spec.sh` accepts any combination of registered sides without repeats and rejects an unknown or repeated name.
- **The check scripts read the registry instead of hard-coded paths:** `check-spec.sh`, `check-plan.sh`, `check-impl.sh` (count, undeclared tags, focused or skipped tests per side), `run-gates.sh` (new `--side <name>`, repeatable; `--be` and `--fe` stay as aliases) and `check-archive.sh` (one pointer per side declared). A registered side whose submodule is not checked out gives the same result as a side with no tests (`check-impl.sh`) or an `UNRUNNABLE` gate (`run-gates.sh`); it never crashes the script.
- **Parity report (new): `.claude/skills/sdd-shared/check-parity.sh`.** For each parity group (today `web`: `FE` and `FE-React`), it lists the ACs of the living specs and active changes declared for one side of the group and not the other. Informative only: it always exits 0 and no workflow calls it.
- **Self-tests:** `run-tests.sh` gets cases that fail today and pass after the change: an AC declared only `FE-React` asks for no Angular test; an Angular test tagged with an AC declared only `FE-React` is an error; `FE + FE-React` needs exactly one test on each side; an unknown side is rejected; a missing submodule does not crash; `run-gates.sh --fe` runs only the FE gates. `check-skills.sh` also accepts paths under `ERAS-FE-React/` (the submodule names it allows come from the registry).
- **Rules, written once and pointing to the registry:**
  - `AGENTS.md` §2.1 and §2.2: rows for `ERAS-FE-React/` and `openspec/sides.conf`.
  - `AGENTS.md` §4.3: the cross-cutting contract stays API level (role values, `api/v1`, enums as strings, JWT, feature flags endpoint). The Angular names (`ERASRoles`, `keycloakHttpInterceptor`, `BaseApiService`, `FeatureFlagsService`) are labelled as the `FE` (v2) contract. The `FE-React` names go in `ERAS-FE-React/AGENTS.md` in a later change. The API does not change.
  - `AGENTS.md` §5.1: three submodules, the pointer of each, and the PR order when two teams change the same change (each submodule PR merges on its own; the parent ship PR bumps only the pointers of the sides the change declares).
  - `AGENTS.md` §5.2, §5.3, §8.6, §8.7 and §9: the sides, their test locations and their gates are the ones in `openspec/sides.conf`. The §8.6 snippet becomes a call to `check-impl.sh`, which already counts per side.
  - `openspec/config.yaml` (`context`, `rules.proposal`), `openspec/sdd-conventions.md` (AC row) and `CLAUDE.md` (submodule list and the `#<n>` lookup): from the registry.
  - The `/sdd-*` skills and their templates (`sdd-spec`, `sdd-clarify`, `sdd-plan`, `sdd-implement`, `sdd-validate-impl`, `sdd-verify`, `sdd-adr`, `sdd-archive`): "each side in `openspec/sides.conf`" instead of "BE and FE". Angular-only guidance stays, labelled `FE`. The golden path of each client is read from that client's `AGENTS.md`.
- **ADR (new, Proposed):** ADR-0011 "Declare the SDD sides in one registry" (`openspec/adr/0011-declare-the-sdd-sides-in-one-registry.md`), written with `/sdd-adr`. The number is tentative until the PR merges. It applies ADR-0007 to every registered client and does not supersede it.

**Out of scope:**
- Any edit under `ERAS-FE/`: code, tests and its `AGENTS.md`, including the line of its §7.3. Its tags and its 127 tagged tests (at the current pointer) are not renamed.
- Any edit under `ERAS-BE/`.
- Creating `ERAS-FE-React`, its `AGENTS.md`, its rules and its gates' scripts (the ERAS-FE-React foundation change).
- `.github/workflows/` (the v3 CI and infrastructure change).
- `README.md` onboarding (the ERAS-FE-React foundation change).
- Moving the Angular names of §4.3 into `ERAS-FE/AGENTS.md` (needs the v2 team; Follow-up).

## Pending agreement with the v2 team

These are drafted here and **not applied** to `AGENTS.md` or any other rule file. `openspec/`, the ADRs and the parent CI are shared with the v2 team, so a rule here binds them too.

- **ADR numbering with two teams.** Proposal: a new ADR takes the next free number on its branch, but the number is final only when its PR merges. If another ADR took that number first, the team that merges last renumbers its file, its index row, its `SUMMARY.md` entry and every `**ADR:** ADR-NNNN` link before merging. `check-adr.sh` already fails on a duplicate number or a gap, so the collision shows up in the PR.
- **Change ids.** No new rule: a change id keeps its issue-number prefix, as today (`<issue-number>-<verb>-<object>`). Both teams' issues live in different repositories, so the issue's repository should also appear in `proposal.md` (already required: "Link the GitHub issue").

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Submodules:** none (parent repo only). No file under `ERAS-BE/` or `ERAS-FE/` changes.
- **Files:** `openspec/sides.conf`, `.claude/skills/sdd-shared/sides.sh`, `.claude/skills/sdd-shared/check-parity.sh` (new); the five check scripts, `check-skills.sh`, `run-tests.sh`; `AGENTS.md`, `CLAUDE.md`, `openspec/config.yaml`, `openspec/sdd-conventions.md`; the `/sdd-*` `SKILL.md` files and their templates; one new ADR and the `openspec/adr/README.md` index.
- **Roles / who can do what:** no change.
- **API contract:** none.
- **Data / migration:** none.
- **Done when:** the check scripts give the same result for `BE` and `FE` before and after the change, on the same submodule pointers. Group 1 records the baseline: `check-spec.sh`, `check-plan.sh`, `check-impl.sh` and `check-adr.sh` on every active change, the per-AC BE and FE counts on every active change and living spec (127 tagged FE tests, 109 BE at the pointers `ERAS-FE 01552be5`, `ERAS-BE 8bddb0c9`), `check-skills.sh` and `openspec validate --all --strict`.
- **Risk:** medium. The scripts are on the path of every change, and a mistake in the reader would change the result for v2. Contained by the baseline comparison and by `run-tests.sh`, which runs before and after.
- **Rollback:** `git revert` of the change's commits. The registry and the reader are new files; no existing data or test is renamed.

No behavior changes, so this change sets `skip_specs: true` (AGENTS.md section 3, tooling).

## Decisions

- 2026-11-18, task 6.1: the baseline comparison (same submodule pointers, `ERAS-BE 8bddb0c9`, `ERAS-FE 01552be5`) gave identical results for `BE` and `FE` (109 BE and 127 FE tagged tests, same errors, warnings and exit codes on every active change), except the text of one warning of `check-plan.sh` on changes `0000` and `578`: `no task group is named by side (BE, FE or Infra)` is now `(BE, FE, FE-React or Infra)`, because the list comes from `openspec/sides.conf` (ADR-0011). Approved by the reviewer (stated in chat).

## Follow-ups

- Move the Angular names of `AGENTS.md` §4.3 into `ERAS-FE/AGENTS.md` once the v2 team agrees.
- Run `check-parity.sh` in CI as an informative step (the v3 CI and infrastructure change).

## Validation log

2026-11-18 – Skipped: no BE controller or FE change.

Verified 2026-11-18: no gaps, no drift, gates green (declared by the reviewer in chat on the evidence of the implementation run: 30/30 tasks, run-tests.sh 141/141, identical BE/FE baseline, openspec validate --all --strict green; the /sdd-verify drift audit was not run)
