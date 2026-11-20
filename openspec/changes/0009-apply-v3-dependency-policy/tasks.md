# Tasks

All the work in `ERAS-FE-React` is one commit, on the branch `ci/0009/dependency-policy` from `develop`. `ERAS-FE-React` has no remote yet, so that commit stays local.

## 1. Baseline (FE-React)

- [x] 1.1 Run `npm audit --audit-level=high` in `ERAS-FE-React` and record the result in the Decisions section of `proposal.md`. If it reports a high or critical advisory, stop and ask the user, because fixing it is a dependency update outside this change
- [x] 1.2 Run `npm ci --ignore-scripts`, then `npm run lint`, `npm run typecheck`, `npm run test:ci` and `npm run build`. Verify that all four pass, record the results, then run `npm ci` again so that the local install has its scripts back

## 2. Pull request workflow (FE-React)

- [x] 2.1 In `.github/workflows/pr_workflow.yaml`, add a `concurrency` group keyed on the pull request number, with `cancel-in-progress: true`
- [x] 2.2 Change the install step to `npm ci --ignore-scripts`, and add the step `npm audit --audit-level=high` right after it
- [x] 2.3 Pin `actions/checkout` and `actions/setup-node` to the full commit SHA of the `v4` tag they use today, read with `gh api` from the actions' repositories, with `# v4.x.y` as a comment. Record the SHAs in the Decisions section

## 3. Dependabot (FE-React)

- [x] 3.1 Create `.github/dependabot.yml` with the `npm` and `github-actions` ecosystems as the proposal describes:
  - weekly, with `target-branch: develop` and `cooldown` `default-days: 7`;
  - minor and patch updates grouped, majors separate;
  - `open-pull-requests-limit: 5` for npm;
  - commit prefix `chore` with scope, and the label `dependencies`.

  Check every key against GitHub's Dependabot options reference, and record in the Decisions section whether `cooldown` also delays security updates

## 4. Rules (FE-React)

- [x] 4.1 In `AGENTS.md` §7.2, extend the dependency rule with:
  - the 7-day minimum age, with the exception for a reviewed security fix;
  - no merge of an update without review;
  - a pointer to ADR-0017.
- [x] 4.2 In `AGENTS.md` §3.3, add `npm audit --audit-level=high` to the commands

## 5. Verification

- [x] 5.1 Run `bash .claude/skills/sdd-verify/scripts/run-gates.sh 0009-apply-v3-dependency-policy --side FE-React` and verify that every gate passes
- [x] 5.2 Run `npx prettier --check .github AGENTS.md` in `ERAS-FE-React` and verify that it passes
- [x] 5.3 Run `git status --short` in the parent and in every submodule. Verify that only `pr_workflow.yaml`, `dependabot.yml`, `AGENTS.md` and this change folder changed, apart from the user's machine-local files; `package.json` and `package-lock.json` must be unchanged
- [x] 5.4 Run `openspec validate "0009-apply-v3-dependency-policy" --strict` and verify that it passes
