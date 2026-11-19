# Tasks

Each group below is one commit (in `ERAS-FE-React` or in the parent repository), so one group can be reverted
without touching the others. `ERAS-FE-React` has no remote yet: its commits stay local.

## 1. Baseline (FE-React)

- [x] 1.1 In `ERAS-FE-React`, run `npm run lint`, `npm run typecheck`, `npm run test:ci` and `npm run build`. Verify that all four are green, and record the results and the test count in the Decisions section of `proposal.md`
- [x] 1.2 Search `src/` for default exports, `axios` imports, `fetch` calls, `localStorage`, `sessionStorage`, `document.cookie` and imports from `app` or `features` inside `src/core/`. Verify that the only hits are the ones the proposal names (`src/core/http/http.ts`, `src/core/config/config.ts`, and the auth test and its comment)

## 2. Lint rules as sensors (FE-React)

- [x] 2.1 Add to `ERAS-FE-React/eslint.config.js` the four rules of the proposal, each with its scope and a message that cites its `AGENTS.md` section. Use only ESLint core rules and add no dependency, then verify that `package.json` and `package-lock.json` are unchanged
- [x] 2.2 Write one throwaway file for each rule: a default export in `src/`, an `axios` import and a `fetch` call in `src/features/`, a `localStorage.setItem` call in `src/app/`, and an import from `src/app/` inside `src/core/`. Verify that `npm run lint` reports each one with its message, then delete the files
- [x] 2.3 Run `npm run lint` on the real code and verify that it is green (`src/core/config/config.ts` keeps its `fetch`, `src/core/http/http.ts` keeps its `axios`, and the auth test keeps its `Storage.prototype` spy)

## 3. Skills (FE-React)

- [x] 3.1 Write `ERAS-FE-React/.claude/skills/eras-fe-react-feature/SKILL.md` with the steps of the proposal. Use the frontmatter style of `eras-fe-react-test` (name, and a description that says when to use it), plus a boundary, the steps and a report. Verify that every file and function it names exists (`routes.tsx`, `RoleGuard.tsx`, `http.ts`, `session.tsx`, `access.ts`), and that it stops on ADR-0014, ADR-0015 and ADR-0016
- [x] 3.2 Write `ERAS-FE-React/.claude/skills/eras-fe-react-i18n/SKILL.md` with the writing rules for `en.ts`, `es.ts` and `pt-BR.ts`, the key naming, and the command that runs `src/core/i18n/i18n.test.ts`. Verify that the command runs green
- [x] 3.3 Write `ERAS-FE-React/.claude/skills/eras-fe-react-review/SKILL.md` with the checklist of the proposal, findings with `file:line`, and no edits. Verify by running it on the diff of change `0004` (`git -C ERAS-FE-React log` first commit to `HEAD`) that it produces findings only and changes no file

## 4. Pointers (FE-React and parent)

- [x] 4.1 In `ERAS-FE-React/AGENTS.md` §7.1–7.3, name `eras-fe-react-feature` (§7.1), `eras-fe-react-i18n` (§7.1 step 7 and §7.2) and `eras-fe-react-review` (§7.2). Verify that `npm run lint` still passes (Prettier formats `AGENTS.md` only if it is configured to)
- [x] 4.2 In the parent's `.claude/skills/sdd-implement/SKILL.md`, next to the existing `<name>-test` sentence, add that a side's `<submodule>/.claude/skills/<name>-feature/SKILL.md`, when it exists, is followed for that side's implementation tasks (for example `eras-fe-react-feature`). Verify that `bash .claude/skills/sdd-plan/tests/check-skills.sh` stays green
- [x] 4.3 In a new Claude Code session at the parent root, ask for an FE-React implementation task of a scratch change. Verify that the agent reaches `eras-fe-react-feature` through the pointers (record whether the nested skills are also listed by name), then discard the scratch change

## 5. Verification

- [x] 5.1 Run `bash .claude/skills/sdd-verify/scripts/run-gates.sh 0006-add-eras-fe-react-agent-tooling --side FE-React` and verify that lint, typecheck, test:ci (≥ 15%) and build all PASS
- [x] 5.2 Run `bash .claude/skills/sdd-plan/tests/check-skills.sh` and `bash .claude/hooks/tests/run-tests.sh`, and verify that both are green
- [x] 5.3 Run `git status --short` in the parent and in `ERAS-FE-React`, and verify that only the files of the Impact section and this change folder changed. Nothing changed under `ERAS-BE/` or `ERAS-FE/` except the user's machine-local files, so the AGENTS.md section 8.7 BE and FE gates do not apply
- [x] 5.4 Run `openspec validate "0006-add-eras-fe-react-agent-tooling" --strict` and verify that it passes

## Follow-ups

Not part of this change:

- A lint rule against one feature importing another, with ADR-0015, which may add a boundaries plugin.
- Skills for the generated OpenAPI client (ADR-0014) and the UI library (ADR-0016), once those ADRs are Accepted.
- Running `check-skills.sh`, or a side version of it, over `ERAS-FE-React/.claude/skills/`.
- Findings of the `eras-fe-react-review` dry run on change `0004`:
  - type the props of `RoleGuard` and `SessionProvider` with an `interface`;
  - decide whether the start-up error text in `src/main.tsx` stays untranslated (it is shown before the texts load).
- Line endings in `ERAS-FE-React`: there is no `.gitattributes`, and Git for Windows defaults to `core.autocrlf=true`. A fresh clone or checkout on Windows can therefore write CRLF files, while Prettier expects LF by default and `npm run lint` checks Prettier. Add a `.gitattributes` with `* text=auto eol=lf` in its own change, then verify that `npm run lint` stays green after a fresh checkout. Found on 2026-11-19, when `git add` warned "LF will be replaced by CRLF".
