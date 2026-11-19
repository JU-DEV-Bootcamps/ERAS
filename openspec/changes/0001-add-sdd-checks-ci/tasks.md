# Tasks

Each group below is one commit, so one group can be reverted without touching the others.

## 1. Baseline (Infra)

- [x] 1.1 Install the OpenSpec CLI locally at the version recorded in the generated skills (`generatedBy` in `.claude/skills/openspec-*`), confirm the npm package name from the OpenSpec project page, and verify `openspec --version` prints that version
- [x] 1.2 Run `openspec validate --all --strict` and record the result, and verify whether the baseline is green or lists errors before the workflow exists
- [x] 1.3 Run `check-plan.sh`, `check-adr.sh` and, for non-`skip_specs` changes, `check-spec.sh` for each active change and record the errors, and verify the list matches the Risk section of the proposal

## 2. Workflow (Infra)

- [x] 2.1 Create `.github/workflows/sdd-checks.yml` with the `pull_request` trigger and the path filter of the proposal, `submodules: recursive` checkout, `gawk` and the pinned CLI install, and verify the file is valid YAML (for example `node -e "require('fs').readFileSync('.github/workflows/sdd-checks.yml','utf8')"` plus a review against `manuals-validation.yml`)
- [x] 2.2 Add the steps `openspec validate --all --strict` and `check-skills.sh`, and verify each step names the exact command from tasks 1.2 and the `check-skills.sh` path
- [x] 2.3 Add a step that lists the changes touched by the PR (`git diff --name-only` against the base branch, `openspec/changes/<id>/` excluding `archive/`) and runs `check-plan.sh` and `check-adr.sh` for each, and `check-spec.sh` only when the change has no `skip_specs: true`, and verify with a local dry run of the same shell commands on change `0000-improve-sdd-entry-and-rules`
- [x] 2.4 Set `continue-on-error: true` on the job and add a comment in the file saying a human flips it after the check is green on real pull requests, and verify the job cannot block a merge

## 3. Verification

- [x] 3.1 Open a draft pull request that only touches this change and verify the workflow runs on it, that the checkout includes `ERAS-BE/AGENTS.md`, and that `check-skills.sh` reports 0 errors on the runner
- [x] 3.2 On the same draft pull request, add a temporary scratch change `9999-scratch-ci-check` whose scenario has no `**Side:**` line (a rule `openspec validate` does not enforce, so the job reaches `check-spec.sh`; a heading with 3 `#` would fail `openspec validate` first and `check-spec.sh` would never run) and verify the workflow reports the error on the runner (proving the scripts behave the same with the runner's awk), then remove the scratch change in the next commit
- [x] 3.3 Run `git status --short` and verify only `.github/workflows/sdd-checks.yml` and this change folder are new, and that no existing workflow, `ERAS-BE/` or `ERAS-FE/` file changed (AGENTS.md section 8.7 gates do not apply: no BE or FE code)
- [x] 3.4 Run `openspec validate "0001-add-sdd-checks-ci" --strict` and verify it passes
