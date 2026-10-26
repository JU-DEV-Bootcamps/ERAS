<!-- ILLUSTRATIVE EXAMPLE of one /sdd-clarify run on a fictional change. Do not copy its content. -->

# Example: /sdd-clarify 608-reject-duplicate-configuration-name

**Input state:** `Status: Draft`, two markers in the spec, one risky assumption.

## What the skill fixes without asking
- AC-4 and AC-5 used a 3-`#` heading → changed to `####`. (Format.)
- AC-2 said "friendly message" → replaced with the exact text already used by the sibling configuration endpoints, found in the code. (Answered by evidence.)

## Questions asked (2 of 5)

### Q1 — Duplicates (affects AC-1, AC-2 · gap: scope)

**Context:** AC-1 says "an active configuration of the same officer", but a second officer can create the same name.

**Question:** Should the name be unique per officer or across all officers?

| Option | Answer | Consequence |
|---|---|---|
| A (Recommended) | Per officer | AC-1 stays as written; matches how configurations are listed today |
| B | Across all officers | AC-1 changes; a new AC covers "name already used by another officer" without leaking who owns it |

**Why A:** the list endpoint already scopes configurations to their owner.

### Q2 — Inactive (affects AC-2 · gap: state)

**Context:** nothing says whether an inactive configuration blocks its name.

**Question:** Can an inactive configuration's name be reused?

| Option | Answer | Consequence |
|---|---|---|
| A (Recommended) | Yes | AC-2 is added: reuse of an inactive name is allowed |
| B | No | The requirement drops "active"; AC-2 is not added |

**Why A:** an inactive configuration is hidden from officers, so blocking its name would be surprising.

## Answers applied
- Q1 → A: no spec change; marker removed from AC-1.
- Q2 → A: AC-2 added as `608-reject-duplicate-configuration-name/AC-2`; no existing number touched.

## Log appended to proposal.md

```markdown
### Session 2026-10-22

- Q: Unique per officer or across all officers? → A: Per officer (AC-1: unchanged, marker removed)
- Q: Can an inactive configuration's name be reused? → A: Yes (AC-2: added)
- Status after this session: Clarified
```

## Report
Questions 2/5 · direct fixes 2 · ACs added: `608-reject-duplicate-configuration-name/AC-2` · deferred 0 · `openspec validate --strict` passes · `check-spec.sh` 0 errors.
Next: a human reviews the spec and sets `Status: Approved`, then `/sdd-plan` on this change writes `design.md` and `tasks.md`.
