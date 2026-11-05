# Proposal

## Why

Issue: ERAS#660 (`JU-DEV-Bootcamps/ERAS`, parent ERAS#619). Two gaps in the Spec-Driven Development (SDD) tooling:

1. `/sdd-verify` runs the test and lint gates through `run-gates.sh` and its pre-flight through `verify-gate.sh`. Nobody has reviewed that they run the right commands, report real results and fail loudly when a tool is missing. The repo also has no Claude Code hook that backs these gates up (`.claude/settings.json` does not exist).
2. The team has not evaluated the Figma MCP (already connected in some Claude Code sessions) as a tool for the SDD flow. Today the repo has no Figma reference beyond a mention in `README.md`.

## What Changes

- **Review the `sdd-verify` gates.** Run `run-gates.sh` and `verify-gate.sh` against a real change, compare the commands with `AGENTS.md` §8.7, `ERAS-BE/AGENTS.md` §3.2 and `ERAS-FE/AGENTS.md` §3.3, and fix every mismatch or false pass/false fail found (wrong command, flag, threshold, exit code, Windows quirk).
- **Review hooks for `sdd-verify`.** Decide whether a Claude Code hook (for example a `Stop` or pre-commit style check) should run or remind about the gates, and, if the review shows value, add it as project hook configuration. If not, record why not.
- **Figma MCP research.** Write a short research document: what the Figma MCP offers, how it could serve the SDD flow (spec ACs from designs, FE implementation from design context), what access, licensing and confidentiality concerns apply, and a recommendation. It records options and criteria like `openspec/roadmap.md`; it adopts no tool and adds no dependency.

- **Figma PoC ("ask for a design").** Run a small proof of concept: draft one small FE screen in a scratch Figma file through the Figma MCP, with mock data only, have the developer who owns the screen review it, and use it as input for `/sdd-spec`. Write a one-page team guide (`openspec/figma-mcp-guide.md`) with the prompt template, per-developer setup and rules, and add the PoC result to the research document. One screen, one draft attempt, to keep token use low.

**Out of scope:** a project `.mcp.json`, hooks for Figma, Code Connect mapping, any BE or FE code change, changing the gates' thresholds (BE 25%, FE 15%), changing application code in `ERAS-BE/` or `ERAS-FE/`, installing or configuring the Figma MCP for the team, changing any CI pipeline, and the other `/sdd-*` skills unless the review finds a defect that blocks `sdd-verify`.

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Parent repo only:** `.claude/skills/sdd-verify/` (scripts and `SKILL.md`), possibly a new `.claude/settings.json` for hooks, and a research document (location in A2).
- **Submodules:** none. No BE or FE code changes.
- **Roles / who can do what:** no change.
- **API contract / data / migration:** none.
- **Risk:** a hook that runs slow gates automatically could slow every session; the review must weigh that before adding one. Hook configuration is shared by the whole team once committed.

No application behavior changes, so this change sets `skip_specs: true` (AGENTS.md §8.1, tooling and docs).

## Assumptions

- **A1.** "Hooks" means Claude Code hooks (`settings.json`) plus the shell scripts `sdd-verify` calls. If the ticket meant only the scripts, the hook decision in task 2.1 resolves to "none".
- **A2.** The Figma research is `openspec/figma-mcp-research.md`, linked from `AGENTS.md` §2.2, next to `openspec/roadmap.md`.
- **A5.** The PoC screen and the Figma file are chosen by the ticket owner before task 4.1 starts; the PoC needs the owner's Figma account signed in.
- **A3.** "Integrate" in the ticket means evaluate and recommend; any adoption is a follow-up change.

- **A4 (hook decision, 2026-11-05).** No Claude Code hook is added. The full gate run takes about 5 minutes and
  `/sdd-verify` already runs it on demand through `run-gates.sh`; a hook that ran it automatically would slow
  every session for the whole team. Review result: on 2026-11-05, `run-gates.sh --be --fe` passed 8 of 8 gates
  (BE coverage 89.2%) and `verify-gate.sh` ran with no errors, so no script defect was found and `SKILL.md` is unchanged.
  A hook can be proposed later if the team wants an automatic reminder.

## Validation log

- Skipped: no BE controller or FE change (skills, hooks and docs only).
- Verified 2026-11-05: no gaps, no drift, gates green (tooling and docs only; no ACs; full BE and FE gates also passed on 2026-11-05)
