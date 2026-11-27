# Tasks

All the work is in the parent, on the branch `chore/0011/register-eras-fe-react-submodule` from `develop`. `ERAS-FE-React` gets no commit.

## 1. Preconditions

- [x] 1.1 Run `git ls-remote https://github.com/JU-DEV-Bootcamps/ERAS-FE-React.git develop` and verify it returns `111e66a…`, and `gh repo view JU-DEV-Bootcamps/ERAS-FE-React --json defaultBranchRef` returns `develop`
- [x] 1.2 Switch `ERAS-FE-React` to `develop` (`git -C ERAS-FE-React switch develop`) and verify `git -C ERAS-FE-React rev-parse --short HEAD` is `111e66a`. The user's uncommitted `vite.config.ts` may stay; it is never committed

## 2. Register the submodule (parent)

- [x] 2.1 Remove the `ERAS-FE-React/` line and its comment from `.git/info/exclude` (local file, never committed), and verify `git status --short` now lists `ERAS-FE-React/`
- [x] 2.2 Run `git submodule add https://github.com/JU-DEV-Bootcamps/ERAS-FE-React.git ERAS-FE-React`, and verify it reports "Adding existing repo", `.gitmodules` has three entries, and `git submodule status` shows `111e66a` for `ERAS-FE-React`

## 3. Docs (parent)

- [x] 3.1 In the root `AGENTS.md` §2.1, change the `ERAS-FE-React/` row to "**Git submodule.**", keeping the rest of the row
- [x] 3.2 In `README.md`, add an `ERAS-FE-React/` row to the repository map after `ERAS-FE/`, and mention the v3 client in the intro line about submodules

## 4. Verification

- [x] 4.1 Run `bash .claude/hooks/tests/run-tests.sh` and verify every test passes with the real submodule in place
- [x] 4.2 Run `git submodule status` and verify it lists `ERAS-BE`, `ERAS-FE` and `ERAS-FE-React`, with `ERAS-FE-React` at `111e66a` and no `-` (not initialized) or `+` (checked-out commit differs) prefix
- [x] 4.3 Run `git status --short` and verify only `.gitmodules`, `ERAS-FE-React`, `AGENTS.md`, `README.md` and this change folder are staged or changed, apart from the user's machine-local files (`ERAS-BE`, `ERAS-FE` pointers, `PROPUESTA_ERAS_V3_REACT_1.md`)
- [x] 4.4 Run `openspec validate "0011-register-eras-fe-react-submodule" --strict` and verify it passes
