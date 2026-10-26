---
name: sdd-clarify
description: Reviews an ERAS OpenSpec change whose spec is in Draft, finds ambiguities, gaps and contradictions, asks the user concrete questions (at most 5) and records the answers in the spec. Use after /sdd-spec and before a human approves the spec, or when a spec has [NEEDS CLARIFICATION] markers or open assumptions.
allowed-tools: Bash(openspec:*) Bash(bash .claude/skills/sdd-spec/scripts/check-spec.sh:*)
---

Reduce the risk in a **Draft spec** before anyone reviews or implements it, by asking the few questions
whose answers change behavior, and writing those answers back into the spec.

**Boundary.** Edit only `proposal.md` and `specs/**/spec.md` of the change. Do NOT write `design.md`,
`tasks.md` or code, do NOT touch `ERAS-BE/` or `ERAS-FE/`, do NOT commit, and never set
`Status: Approved` (only a human does). Never read or print secrets.

**Templates:**
- `.claude/skills/sdd-clarify/templates/question.md`: how to present each question
- `.claude/skills/sdd-clarify/templates/clarification-log.md`: how to record answers in `proposal.md`

**Worked example** (fictional, for shape only): `.claude/skills/sdd-clarify/examples/session.md`

**Checker** (shared with `/sdd-spec`): `bash .claude/skills/sdd-spec/scripts/check-spec.sh <change-id>` (from the repo root).

## Steps

1. **Find the change.** Use the id the user gave; otherwise `openspec list` (if several, ask which).
   Re-read `proposal.md` and every `specs/**/spec.md` from disk. Read `**Status:**` in the proposal:
   - `Draft` → continue. `Clarified` → ask whether to reopen it. `Approved` → stop; an approved spec is
     reopened only by the user's explicit decision.
   - No spec files yet → stop and point to `/sdd-spec`.

2. **Gather context before asking** (read-only). Existing specs for the same capability
   (`openspec show "<id>" --type spec`), the current behavior in `ERAS-BE/` / `ERAS-FE/`, `AGENTS.md`
   and `openspec/config.yaml`. **Never ask what the code, the specs or AGENTS.md already answer**;
   fix the spec from that evidence and mention it in the report instead.

3. **Scan for gaps** in this order (this is the taxonomy; skip categories that are clear):
   1. **Open markers**: every `[NEEDS CLARIFICATION: …]` and every `## Assumptions` item that is risky.
   2. **Authorization**: allowed and denied roles per endpoint/route; ownership and scope rules; Guest behavior.
   3. **Validation and errors**: invalid input, limits, duplicates, not-found, conflict, exact status codes and messages.
   4. **State and data**: lifecycle and status transitions, what is persisted or left untouched on failure, existing data/migration effects.
   5. **BE ↔ FE contract**: behavior both sides must agree on (fields, enums, messages); a change in only one side;
      a missing or wrong `**Side:**` line (an API behavior with a user-visible message usually needs a BE AC and an FE AC).
   6. **Scope**: what is in or out; adjacent behavior that is silently affected; BREAKING effects.
   7. **Non-functional**: security, privacy of student data, performance or volume limits only when they change behavior.
   8. **Consistency**: contradictions between ACs, with an existing main spec, or with the code; duplicate or overlapping ACs; terms used with two meanings.
   9. **Testability**: ACs that are vague ("fast", "friendly", "properly"), compound (more than one behavior), or cannot be proven by one automated test per affected side.
   10. **Format**: run the checker first; it reports AC numbering, 4-`#` headings, WHEN/THEN, `**Side:**`, marker count and status. Also requirements of 500 characters or fewer.

   Format problems (10) and spec text that the evidence already settles are **fixed directly**, not asked.

4. **Pick the questions: at most 5 in total.** Rank the remaining gaps by impact on behavior,
   authorization, data or scope × uncertainty, and keep the top ones. Drop anything cosmetic or
   deferrable to design (naming, class structure, library choice). Merge gaps that one answer settles.
   If more than 5 matter, ask the 5 highest and list the rest as *Deferred* in the report and log.
   If nothing needs asking, say so, apply the direct fixes, and go to step 7.

5. **Ask.** Use `AskUserQuestion` (max 4 per call, so a 5th goes in a second call), following
   `templates/question.md`: one concrete question each, 2–4 mutually exclusive options, your
   recommended answer first with the reason. Ask in the user's language. If the tool is unavailable,
   print the numbered question blocks and wait. Do not edit the spec while waiting.

6. **Apply the answers**, one decision at a time, with the smallest edit:
   - Change the affected scenario, or add a scenario with the **next free AC number**. Never renumber,
     never reuse a number; a dropped AC leaves a gap.
   - Remove the matching `[NEEDS CLARIFICATION]` marker and move settled assumptions out of `## Assumptions`.
   - If an answer contradicts another AC, fix that AC too, in the same edit.
   - If an answer changes who can do what, make sure an AC covers it and update `Impact` in the proposal.
   - Append the session to `## Clarifications` in `proposal.md` using `templates/clarification-log.md`.
   - Status: set `**Status:** Clarified` only when **no** `[NEEDS CLARIFICATION]` marker remains and no
     question was deferred; otherwise leave `Draft`. Never write `Approved`.

7. **Validate.** `openspec validate "<change-id>" --strict` and
   `bash .claude/skills/sdd-spec/scripts/check-spec.sh "<change-id>"`; fix and re-run until both report no errors.

8. **Report** (short):
   - Questions asked and answered (n/5), direct fixes applied, deferred items.
   - ACs added or changed (list the keys `<change-id>/AC-<n>`).
   - A coverage line per category: resolved / clear / deferred / outstanding.
   - Next step: another `/sdd-clarify` run if anything is deferred or outstanding; otherwise a human
     reviews the spec and sets `**Status:** Approved`, then `/sdd-plan <change-id>` writes `design.md` and
     `tasks.md` (`/opsx:propose` on the same change is the generic alternative). Do not start those yourself.
     Implementation still waits for the human approval of the complete change (AGENTS.md §3.2), recorded as `**Plan:** Approved`.

## Guardrails

- At most 5 questions per run; every question is concrete, answerable, and changes the spec.
- Questions are about behavior (what the system does), never about implementation (how).
- Record only what the user answered or what the evidence proves; do not invent answers or accept
  your own recommendation silently. If the user skips a question, keep its marker and report it as outstanding.
- Do not widen scope: new capabilities discovered here go to `**Out of scope:**` in the proposal.
