# Tasks

Each group below is one commit, so one group can be reverted without touching the others. Nothing in this
change blocks a pull request or an agent: every check only warns (observe mode).

## 1. Baseline (Infra)

- [x] 1.1 Read the current Claude Code documentation for `permissions.deny` and for `PreToolUse` and `Stop` hooks (input JSON, exit codes, the output field that shows a warning to the user and to the agent without blocking, `timeout`), and verify the field names this change uses by recording them with the doc version in the Decisions section of `proposal.md`
- [x] 1.2 Write a throwaway hook in `.claude/settings.local.json` (personal, not committed) that only appends its stdin to a scratch file, trigger it with one edit on Windows, and verify how Claude Code runs the command (Git Bash or another shell), the shape of `tool_input.file_path` (absolute, backslashes, drive letter) and that a missing `bash` does not break the edit; record the result, then delete the throwaway hook
- [x] 1.3 Run, for every active change and every submodule branch checked out today, the lookup Hook 1 will do (branch digits → `openspec/changes/<n>-*` → approval line), and `check-impl.sh <id> --final` for the active changes with `Plan: Approved`, and verify the results (which would warn and why) are recorded in the Risk section of `proposal.md`, with no false warning left unexplained
- [x] 1.4 Run `bash .claude/skills/sdd-plan/tests/run-tests.sh` and `bash .claude/skills/sdd-plan/tests/check-skills.sh` and verify both are green before any file of this change is added (the baseline the last group compares against)

## 2. Deny rules (Infra)

- [x] 2.1 Create `.claude/settings.json` with `permissions.deny` for `Read` and `Edit` of `/.env`, `/deploy/.env.prod` and `**/environment.development.ts`, and verify with a Claude Code session that reading `.env` is refused while reading `.env.sample` and `ERAS-BE/**/appsettings.json` still works
- [x] 2.2 Add `.claude/settings.local.json` to the root `.gitignore`, and verify `git check-ignore -v .claude/settings.local.json` names that line and `git check-ignore .claude/settings.json` prints nothing

## 3. Hooks in observe mode (Infra)

- [x] 3.1 Write `.claude/hooks/tests/run-tests.sh` with the cases of the proposal (parent-repo path, submodule path with an approved change, with no matching change, with an unapproved change, `skip_specs` change with `Status: Approved`, Windows path with backslashes, broken JSON, `ERAS_HOOKS=off`, Stop with a pre-cutoff change, Stop with no uncommitted submodule change), and verify it fails because the hooks do not exist yet
- [x] 3.2 Write `.claude/hooks/require-approved-change.sh` (Hook 1): read the side folders from `openspec/sides.conf` through `.claude/skills/sdd-shared/sides.sh`, apply the "Change lookup" rule of `openspec/sdd-conventions.md`, warn with the field recorded in task 1.1, always exit 0, fail open on any error of its own, and verify the Hook 1 cases of task 3.1 pass
- [x] 3.3 Write `.claude/hooks/report-traceability.sh` (Hook 2): only for a side with uncommitted changes whose branch maps to a change with `Plan: Approved` created on or after `HARNESS_SINCE`, run `check-impl.sh <id>` without `--final` and show a one-line summary only when it reports warnings or errors, never exit 2, fail open, and verify the Hook 2 cases of task 3.1 pass
- [x] 3.4 Register both hooks in `.claude/settings.json` with a `timeout` each (Hook 1 at most 10 s, Hook 2 at most 60 s), and verify in a real Claude Code session on Windows: one edit in a submodule on a branch without a change shows the warning and the edit is applied, and one turn ending with an uncommitted test change runs Hook 2 without delaying the turn by more than its timeout
- [x] 3.5 Set `ERAS_HOOKS=off`, repeat the edit of task 3.4, and verify no warning appears

## 4. CI step in observe mode (Infra)

- [x] 4.1 Add a step to `.github/workflows/sdd-checks.yml`, after the existing ones, that runs only when the PR changes the pointer of at least one submodule of `openspec/sides.conf`, and runs `check-impl.sh <id> --final` for each active change the PR touches that has `Plan: Approved`, is not `skip_specs` and has `created:` on or after `HARNESS_SINCE` (an `env` value in the workflow), printing a one-line notice for every change it skips and why; verify the job still has `continue-on-error: true` and that no other step changed
- [x] 4.2 Run the same shell commands of task 4.1 locally against the changes of task 1.3, and verify every pre-cutoff change is skipped with a notice and a spec-only PR (no pointer change) skips the step

## 5. Docs (Docs)

- [x] 5.1 Add one paragraph to `CLAUDE.md` ("Claude Code specifics") on the deny rules, the two hooks, that they only warn, and `ERAS_HOOKS=off`, and add the hook self-test to the "Checks" row of `openspec/sdd-conventions.md`, and verify `check-skills.sh` stays green

## 6. Verification

- [x] 6.1 Run `bash .claude/hooks/tests/run-tests.sh`, `bash .claude/skills/sdd-plan/tests/run-tests.sh` and `bash .claude/skills/sdd-plan/tests/check-skills.sh`, and verify all are green and match the baseline of task 1.4
- [ ] 6.2 Open a draft pull request that only touches this change and verify `sdd-checks.yml` runs, the new step is skipped (no pointer change) with its notice, and the job result is the same as before this change
- [x] 6.3 Run `git status --short` and verify only the files listed in the Impact section of `proposal.md` and this change folder changed, and that nothing under `ERAS-BE/`, `ERAS-FE/` or `ERAS-FE-React/` changed (the AGENTS.md section 8.7 BE and FE gates do not apply: no submodule code)
- [x] 6.4 Run `openspec validate "0005-add-agent-harness-observe-mode" --strict` and verify it passes

## Follow-ups

Not part of this change; each one is its own change, proposed only after this one has run in observe mode on
real work:

- Phase 2, blocking: a `block` value for `ERAS_HOOKS` (Hook 1 exits 2), removing `continue-on-error` from `sdd-checks.yml` and marking it required. A human decides, after N pull requests in green.
- `ERAS-BE` CI: `dotnet format --verify-no-changes` and `-warnaserror` in `pr_workflow.yaml`, only after `578-fix-dotnet-format-baseline` is merged and the current warning count is measured.
- Architecture tests: the Onion dependency rule in `ERAS-BE`, and import-boundary lint rules in `ERAS-FE` and `ERAS-FE-React` ("components never call `HttpClient`").
- Let `check-impl.sh` read an archived change, so the CI step can also run on the ship PR's archive commit.
- Deny shell reads of the secret files (Bash permission rules or the Claude Code sandbox).
- Extend Hook 1 to the infrastructure files of AGENTS.md section 8.1 (`.github/`, `deploy/`, `nginx/`, `docker-compose*.yml`).
- A scheduled routine that reports spec ↔ code drift and stale active changes.
