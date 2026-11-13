# Improvement proposals for the ERAS SDD flow

**Date:** 2026-11-12
**Basis:** a review of the SDD flow of ERAS (what comes from OpenSpec and what is the team's own, and how each `/sdd-*` skill finds its context).
**Status:** proposals **F1, F2, F3, T4 and T8** were applied in change `0000-improve-sdd-entry-and-rules`; the rest are still pending (see the "Deferred improvements" section of that change's `proposal.md`). References to lines of `CLAUDE.md` describe the state before that change. Each proposal states **what**, **why** and **where**; none was verified against the application code.

---

## 1. Priorities

| Priority | Proposal | Effort |
|---|---|---|
| **P1** | F1 `#<n>` rule in `CLAUDE.md` · F2 Unify `/opsx:*` and `/sdd-*` · T4 `/sdd-implement` reads the submodules' `AGENTS.md` · F5 CI job | Low (text and one workflow) |
| **P2** | S1 `resolve-change.sh` · N1 `/sdd-start` · N2 `/sdd-status` · T1 BE/FE test skills · S2 `check-impl.sh --run` | Medium |
| **P3** | L1–L4 Loops · T6 Reviewer subagents · T7 Approval hook | Medium-high |

---

## 2. Flow improvements

| # | Proposal | Why | How / where |
|---|---|---|---|
| F1 | **Explicit rule for `#<n>`**: look for `openspec/changes/<n>-*`, then `gh issue view <n>` in BE, FE and the parent repo, then the branch of each submodule; if there are several matches, ask | Today the agent infers it and it can vary (no written rule) | `CLAUDE.md`, section "Claude Code specifics" |
| F2 | **Remove the weak path**: `CLAUDE.md` lines 15–17 told the agent to use `/opsx:propose` and `/opsx:apply`, which skip the gates (`Status`/`Plan: Approved`, AC tags). Switch to `/sdd-*` and keep `/opsx:*` only for `skip_specs` and exploration | Two paths, one without gates: it was risk no. 3 of the flow review | `CLAUDE.md`; `AGENTS.md` §8.5 |
| F3 | **Define how "current branch" maps to a change** (branch `<prefix>/<n>/<title>` ↔ `<n>-<verb>-<object>`) | `validate-impl` and `verify` use it but nobody defines it | `openspec/sdd-conventions.md` + script S1 |
| F4 | **Light path for changes without behavior** (CI, docs, refactor). Today `/sdd-spec` stops and sends the user to `/opsx:propose` | It is exactly the case that has neither its own skill nor gates | New skill `/sdd-chore` (see N3) |
| F5 | **CI**: a job that runs `openspec validate --all --strict`, `check-skills.sh` and the `check-*` scripts of the active changes | Everything depends on someone running them by hand (risk no. 2). Rules with a script only help if the script runs | `.github/workflows/` of the parent repo |
| F6 | **Normalize changes with an inconsistent state** (571, 578, 642, 660) | 571 has 9/9 tasks with spec and plan in Draft; 660 is complete but has no `Status` and is not archived | Human review + `/sdd-status` (N2) |

---

## 3. New skills based on the current flow

| # | Skill | What it does | Why |
|---|---|---|---|
| N1 | `/sdd-start <#n \| id>` | Resolves `#675` → change, issue, branch and state; proposes the next step (`/sdd-spec`, `/sdd-plan`…) | It is the entry point that is missing today; it makes "it already knows what to do" deterministic |
| N2 | `/sdd-status` | Table of all changes: `Status`, `Plan`, tasks `x/y`, `Verified`, pending ADRs | Today each `proposal.md` has to be opened; it would catch cases like 571 and 660 |
| N3 | `/sdd-chore` | `proposal.md` + `tasks.md` with `skip_specs: true`, §8.7 verification and archive with `--skip-specs` | Covers the gap of proposal F4 |
| N4 | `/sdd-pr` | Drafts (without committing) the ship PR description: Traceability table, linked submodule PRs, files the commit carries (the ones `/sdd-verify` already lists by hand) | AGENTS.md §8.3 step 5 requires specific content; today it is assembled by hand |
| N5 | `/sdd-review-feedback` | Reads the PR comments and classifies them: code change → test-first task; requirement change → back to `/sdd-spec` | `/sdd-validate-impl` already routes manual-validation feedback this way, but nothing does it for PR review |

---

## 4. Skills, agents and `AGENTS.md` by technology

Today the submodules have no `.claude/` (no skills or agents). The golden paths (§6.1 and §7.1) are only prose in `ERAS-BE/AGENTS.md` and `ERAS-FE/AGENTS.md`, and `/sdd-implement` cites a skill `eras-fe-test` that **does not exist**.

| # | Proposal | Why | Where |
|---|---|---|---|
| T1 | **Test skills**: `eras-fe-test` (Jasmine, TestBed, `HttpTestingController`, tag `it('[id/AC-n]')`) and `eras-be-test` (xUnit, the layer where the behavior is decided, `Trait("AC")`) | The templates `ac-test-be.md` and `ac-test-fe.md` already exist in `sdd-implement`; wrapping them per technology avoids repeating rules and fixes the broken reference | `ERAS-FE/.claude/skills/`, `ERAS-BE/.claude/skills/` |
| T2 | **Scaffolding skills** for the golden path: `eras-be-usecase` (Domain → contract → handler → DTO → controller with `[Authorize(Policy…)]`) and `eras-fe-feature` (lazy route, model, `BaseApiService`, OnPush component) | They are fixed lists of steps; a skill applies them in order and can check them | Submodules, `.claude/skills/` |
| T3 | **Migrations skill** `eras-migration`: only `dotnet ef migrations add`, never edit an applied migration or the snapshot | It is a rule of §9 "Limits" that today is only guarded by text | `ERAS-BE/.claude/skills/` |
| T4 | **`/sdd-implement` step 2 reads `ERAS-BE/AGENTS.md` and/or `ERAS-FE/AGENTS.md`** according to the sides in `tasks.md` (or `@ERAS-BE/AGENTS.md` in the root `CLAUDE.md`) | From the root those rules are not guaranteed to load; the skill cites §6.1/§7.1, which are only pointers | `sdd-implement/SKILL.md` |
| T5 | **Extend `check-skills.sh`** to also check the submodules' skills and that every cited skill exists | Today it detects broken paths inside `sdd-*`, but the reference to `eras-fe-test` is marked conditional and does not fail | `sdd-plan/tests/check-skills.sh` |
| T6 | **Read-only reviewer subagents** in `.claude/agents/`: `eras-be-reviewer`, `eras-fe-reviewer` (golden path, legacy patterns, `CancellationToken`, policies, OnPush…) and `ac-test-auditor` (do the assertions prove the AC?) | `/sdd-verify` asks to read every test and review drift in the main context. An isolated agent saves context and gives an independent reading | Used in `sdd-verify` steps 3 and 6 |
| T7 | **Hook that blocks editing `ERAS-BE/` or `ERAS-FE/` without a change with `Plan: Approved`** (reusing a `check-approved.sh` script) | `CLAUDE.md` requires it in prose; a hook enforces it | `.claude/settings.json` (the `update-config` skill configures hooks) |
| T8 | **`AGENTS.md`**: add a "which skill to use when" table per side (BE/FE) and the `#<n>` rule | Gathers in one place what is scattered today | `AGENTS.md` §8.5 |

---

## 5. Scripts

| # | Improvement | Why |
|---|---|---|
| S1 | **Shared `resolve-change.sh [#n \| id]`**: returns the change, its state (`Status`, `Plan`, tasks, `Verified`) or the list of candidates | Each skill repeats in prose "given id → branch → `openspec list` → ask". A script does it the same way every time; `/sdd-start` and `/sdd-status` reuse it |
| S2 | **`check-impl.sh --run`**: run the tagged tests (`dotnet test --filter "AC=…"`, `npm test --include=…`) and verify that they pass | Today it only **counts tags**; it does not know whether the test passes |
| S3 | **Detect a test with two AC keys** in `check-impl.sh` | The "one test, one AC" rule is only checked in one direction (how many tests per AC) |
| S4 | **`check-spec.sh`**: accept "Forbidden" as well as `403`, and warn if the spec names classes, DTOs or file paths | The rule "the spec does not say how" (`sdd-spec` step 6) has no check at all |
| S5 | **`run-gates.sh`**: run BE and FE in parallel and add `--only <gate>` | Today they run in series (several minutes on Windows); a specific failure can be retried without repeating everything |
| S6 | **`check-all.sh`** that walks all active changes with `check-spec/plan/impl` | Feeds the CI job (F5) and `/sdd-status` |
| S7 | **Split `run-tests.sh`** (5 min) into sections in CI (`plan`, `impl`, `adr`…) in parallel | It already accepts a section as an argument; it only needs to be used |

---

## 6. Loops

Today the loops exist but are **manual**: `validate-impl → implement → validate-impl` and `clarify → spec` need the user to invoke the skill again. Proposal, always with a **stop condition** so they do not cycle forever:

| # | Loop | Stop condition | Why |
|---|---|---|---|
| L1 | **Gates fix-loop**: if `run-gates.sh` reports `FAIL`, read its log, fix and run again | At most 3 iterations; stop if the same thing fails twice or if the fix requires touching the spec or plan | The typical failure (format, lint, one test) is fixed without human intervention |
| L2 | **Test-first loop per task** (already in `/sdd-implement`): reinforce that it must not move to the next task if the test did not fail first | A test that is red for the right reason | It is the rule that is easiest to skip without anything noticing (hence S2) |
| L3 | **PR review** (`/sdd-review-feedback`, N5) with `/loop` to check again for new comments | No pending comments, or approval | The change must be archived **after** approval (`/sdd-archive`) |
| L4 | **Parallelize sides**: independent BE and FE groups in subagents | Only if the API contract is already fixed in `design.md`; if it changes, go back to serial | It reduces time; the risk is that BE and FE diverge |

Limits that hold in any loop: **never edit the spec or plan on their own**, never tick a task with a red test, never commit.

---

## 7. What would not change

- **Human approvals** (`Approved`, `Accepted`) and "no skill commits": they are the part that protects the most.
- **One script per verifiable rule** and the scripts' own self-tests: it is what distinguishes the flow from a long prompt.
- **The spec / plan / tasks separation** and that only `/sdd-implement` writes code.
