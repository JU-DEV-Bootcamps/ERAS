# Tasks

## 1. Skills

- [x] 1.1 Add `.claude/skills/sdd-spec/` with `SKILL.md`, `templates/proposal.md`, `templates/spec.md` and a worked example
- [x] 1.2 Add `.claude/skills/sdd-clarify/` with `SKILL.md`, `templates/question.md`, `templates/clarification-log.md` and a worked example
- [x] 1.3 Add `.claude/skills/sdd-spec/scripts/check-spec.sh` (unique AC numbers, WHEN/THEN, Side, marker cap, Status line) and test it against a valid spec and four broken ones

## 2. Docs

- [x] 2.1 Document both skills in `AGENTS.md` section 5.1
- [x] 2.2 Mention both skills in `CLAUDE.md` (Claude Code specifics)

## 3. Verification

- [x] 3.1 `openspec validate 623-add-sdd-spec-and-clarify-skills --strict` passes
- [x] 3.2 The spec template and the worked example pass `openspec validate --strict` and `check-spec.sh` in a scratch change

## Follow-ups

The skills are set up but not used yet (no ticket to run them on). When the first real issue arrives, run `/sdd-spec` and `/sdd-clarify` on it and adjust the skills from what is observed, in its own change.
