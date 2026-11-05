## 1. Review the sdd-verify gates

- [x] 1.1 Run `verify-gate.sh` and `run-gates.sh` on a completed change (for example `571-skip-orphan-poll-instances-in-backfill`) and record each gate's real result
- [x] 1.2 Compare every command and threshold in `run-gates.sh` with `AGENTS.md` §8.7, `ERAS-BE/AGENTS.md` §3.2 and `ERAS-FE/AGENTS.md` §3.3
- [x] 1.3 Fix each defect found (false pass or fail, wrong exit code, Windows quirk) and re-run to confirm (none found)
- [x] 1.4 Update `.claude/skills/sdd-verify/SKILL.md` if behavior or usage changed

## 2. Hooks

- [x] 2.1 Decide whether a Claude Code hook should run or remind about the gates, weighing run time and team-wide effect; record the decision and reasons in the proposal Assumptions
- [x] 2.2 If a hook is justified, add it to `.claude/settings.json` and verify it triggers; otherwise skip this task and say why (no hook added, see A4)

## 3. Figma MCP research

- [x] 3.1 Research the Figma MCP capabilities (read design context, screenshots, Code Connect, write to Figma) and list how each could serve an SDD step
- [x] 3.2 Cover access, licensing, confidentiality and fit with ERAS (Angular Material 3) and give a recommendation without adopting anything
- [x] 3.3 Write `openspec/figma-mcp-research.md` and link it from `AGENTS.md` §2.2

## 4. Figma PoC: ask for a design

- [x] 4.1 Choose one small FE screen (for example a list with a filter bar and an empty state) and create a scratch Figma file; mock data only
- [x] 4.2 Ask Claude to draft the screen in the scratch file with the Figma MCP, reusing a library if one exists; one attempt plus follow-up tweaks
- [x] 4.3 Review the draft with a designer or the FE lead and record what worked, manual fixes and attempts
- [x] 4.4 Use the approved draft as input for `/sdd-spec` and note which visible states became ACs (candidate ACs listed in the research doc; no separate spec, there is no issue for the screen)
- [x] 4.5 Write `openspec/figma-mcp-guide.md` (prompt template, setup, rules: mock data only, scratch file first, designer reviews, a frame is not the spec) and link it from `AGENTS.md` §2.2
- [x] 4.6 Add the PoC result (effort, defects, go or no-go) to `openspec/figma-mcp-research.md`

## 5. Gates

- [x] 5.1 `openspec validate 660-add-tools-to-improve-sdd --strict` passes
- [x] 5.2 Run `bash .claude/skills/sdd-plan/tests/check-skills.sh` and report the real result
