# Proposal

**Status:** Approved

## Why

ERAS v3 (`ERAS-FE-React`) has its foundation (change `0004`) and one agent skill, `eras-fe-react-test`. The next changes add ERAS modules one by one, so the agent will repeat the same work many times: a route with roles, a feature folder, server-state hooks on `src/core/http/`, texts in three languages, and a review against `ERAS-FE-React/AGENTS.md` §7.1–7.2. Most §7.2 rules exist only as text today, so they hold only if the agent remembers them. This change adds three skills that guide that work and turns the mechanical §7.2 rules into lint errors that enforce it, before the first module is written. Issue: placeholder `0006` (no issue yet; rename the folder when it exists, before approval).

## What Changes

- **Skill `eras-fe-react-feature`** (`ERAS-FE-React/.claude/skills/eras-fe-react-feature/SKILL.md`): walks `/sdd-implement` through one FE-React implementation task along §7.1 with the real files. It covers:
  - the route entry and its `roles` in `src/app/routing/routes.tsx`;
  - the folder `src/features/<feature>/`, with named exports and typed `interface` props;
  - API calls only through `src/core/http/http.ts`;
  - TanStack Query hooks;
  - permissions with `useSession()` and `canAccess`;
  - texts through the i18n skill.

  It **stops and asks** wherever an ADR is still pending: the generated OpenAPI client (ADR-0014), state and layers (ADR-0015) and the UI library (ADR-0016). It also notes that React Hook Form and Zod are installed by the first change that needs a form (ADR-0012). It ends with the FE-React gates and writes code only inside the task's scope.
- **Skill `eras-fe-react-i18n`**: how to add a user-facing text.
  - The same key path goes in `src/core/i18n/en.ts`, `es.ts` (neutral Spanish) and `pt-BR.ts` (Brazilian Portuguese), with English first.
  - Keys are named by feature, `<feature>.<screen>.<item>`, and shown with `useTranslation()`.
  - Key parity is already checked by `src/core/i18n/i18n.test.ts`, which the skill tells the agent to run.
- **Skill `eras-fe-react-review`**: a review of a v3 diff, limited to what lint cannot check:
  - user-facing text outside the resources;
  - server data copied into component state;
  - raw role strings instead of `canAccess`;
  - route roles that do not match the spec's ACs;
  - semantic HTML and labels beyond jsx-a11y;
  - a library added without a change;
  - an AC test that only renders.

  It reports findings with `file:line` and edits nothing. It does not replace `/sdd-verify`.
- **Lint rules as sensors** in `ERAS-FE-React/eslint.config.js`. They use **only ESLint core rules**, so no dependency is added and ADR-0012 is untouched. Each message cites its `AGENTS.md` §7 rule:
  - *No default exports* (§7.1 step 4): `no-restricted-syntax` on `ExportDefaultDeclaration`, for `src/**`. The root config files (`vite.config.ts`, `eslint.config.js`, `commitlint.config.js`) need their default export and are outside `src/`.
  - *HTTP only through `src/core/http/`* (§7.1 step 2): `no-restricted-imports` of `axios` and `no-restricted-globals` for `fetch`, for `src/app/**`, `src/features/**` and `src/shared/**`. `src/core/` is not covered on purpose: `src/core/config/config.ts` must `fetch` `/config.json` before the HTTP client exists, and `src/core/http/http.ts` is the client.
  - *Tokens never in browser storage* (§7.2, ADR-0013): `no-restricted-globals` for `localStorage` and `sessionStorage`, and `no-restricted-properties` for `document.cookie`, for `src/**` except test files. The auth test spies on `Storage.prototype` to prove nothing is written.
  - *`core` uses nothing from `app` or `features`* (§4.2): `no-restricted-imports` patterns for `src/core/**`.
- **Pointers**:
  - `ERAS-FE-React/AGENTS.md` §7.1–7.3 names each skill where it applies.
  - The parent's `.claude/skills/sdd-implement/SKILL.md` already follows a side's `<name>-test` skill. It now also follows a side's `<name>-feature` skill for that side's implementation tasks, with `eras-fe-react-feature` as the example.

**Out of scope (Follow-ups in `tasks.md`):**
- A rule against one feature importing another: core rules cannot express "any other feature folder", so it waits for ADR-0015, which may add a boundaries plugin.
- Skills for the OpenAPI client (ADR-0014) and the UI library (ADR-0016).
- Running `check-skills.sh` over the side's skills.
- Any feature code.
- Any change to `ERAS-FE/` or `ERAS-BE/`.

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- **Sides / submodules:**
  - `ERAS-FE-React`: a local repository with no remote yet, not a submodule; commits stay local.
  - The parent repository: one line in `sdd-implement`.
  - `ERAS-BE` and `ERAS-FE` are not touched.
- **Files:**
  - `ERAS-FE-React/.claude/skills/eras-fe-react-feature/SKILL.md`, `…/eras-fe-react-i18n/SKILL.md` and `…/eras-fe-react-review/SKILL.md` (new).
  - `ERAS-FE-React/eslint.config.js` and `ERAS-FE-React/AGENTS.md` (pointers).
  - `.claude/skills/sdd-implement/SKILL.md` (one pointer).
- **Roles / who can do what:** no change for ERAS users. For contributors on v3, code that breaks one of the four rules no longer passes `npm run lint`, which is a blocking gate of the FE-React side (ADR-0012).
- **API contract:** none
- **Data / migration:** none
- **Risk (low):**
  - *Breaking current work:* measured on 2026-11-19, `npm run lint` is green, and `src/` has:
    - no default export;
    - no `axios` import or `fetch` call outside `src/core/`;
    - no `localStorage`, `sessionStorage` or `document.cookie` outside the auth test's spy;
    - no `core` import from `app` or `features`.

    The new rules therefore start green. Task 1 measures this again before any rule is added.
  - *A rule too wide:* each rule is proven on throwaway files (one per rule) and on the real code before it ships. A legitimate case that fails is a bug in the rule, fixed before it ships.
  - *Skills not found:* nested skills may not be listed when a session starts at the parent root. Like `eras-fe-react-test` today, the new skills are reached through `AGENTS.md` and `sdd-implement` pointers; task 4 checks that path.
- **Rollback:** each group in `tasks.md` is one commit (in `ERAS-FE-React` or in the parent), and each can be reverted on its own.

No behavior of ERAS changes, so this change sets `skip_specs: true` (AGENTS.md section 3, tooling and docs).

## Decisions

**Task 1.1, baseline (2026-11-19, `ERAS-FE-React` on `develop` at `c21ed4c`):** `npm run lint`, `npm run typecheck`, `npm run test:ci` and `npm run build` all exit 0. `test:ci` shows 7 test files and 37 tests passed, with line coverage at 93.9 % (77/82).

**Task 1.2, baseline search (2026-11-19):**
- *Default exports:* only in the root config files (`commitlint.config.js`, `eslint.config.js`, `vite.config.ts`), none in `src/`.
- *`axios`:* imported only in `src/core/http/http.ts`.
- *`fetch`:* called only in `src/core/config/config.ts` (`fetchFn: typeof fetch = fetch`).
- *Browser storage:* named only in the auth test (`vi.spyOn(Storage.prototype, 'setItem')`) and in a comment of `src/core/auth/auth.ts`.
- *`core` → `app` / `features` imports:* none.

**Group 2, lint sensors (2026-11-19):**
- *Config:* the four rules are in `eslint.config.js` as four blocks of ESLint 9.39 core rules. The core-layer rule uses a `regex` pattern (`^(\.\./)+(app|features)(/|$)`), because the code uses relative imports only (no path aliases). In flat config, two blocks that name the same rule for the same file replace each other, so the `src/{app,features,shared}` block repeats the storage values next to `fetch`.
- *Extra cases:* `window.localStorage`, `window.sessionStorage` and `window.fetch` are restricted too, so the rules cannot be bypassed through `window`. `package.json` and `package-lock.json` are unchanged.
- *Throwaway files (task 2.2):* they produced exactly 8 errors, each with its message:
  - a default export;
  - `axios`, `fetch` and `window.fetch` in `src/features/`;
  - `localStorage`, `window.sessionStorage` and `document.cookie` in `src/app/`;
  - `../../app/session` imported from `src/core/`.

  A further file showed that `localStorage` in `src/features/` is still an error. Two cases stayed allowed: `fetch` in `src/core/`, and `localStorage` in a test file. The files were deleted.
- *Real code (task 2.3):* `npm run lint` exits 0 on the real code.

**Group 3, skills (2026-11-19):**
- *`eras-fe-react-feature`:* every file it names exists (`routes.tsx`, `RoleGuard.tsx`, `http.ts`, `session.tsx`, `access.ts`, `main.tsx`), and it stops on ADR-0014, ADR-0015 and ADR-0016. It also states that `createHttpClient` exists but no instance reaches the screens yet (`main.tsx` creates none), so the first feature that calls the API stops on ADR-0014 / ADR-0015 instead of choosing the wiring.
- *`eras-fe-react-i18n`:* it follows the existing resources, so Spanish uses formal "usted" (the `es.ts` header and texts), not the tone the plan first assumed. Shell pages keep `<screen>.<item>` keys and features use `<feature>.<screen>.<item>`. Its command, `npm test -- run src/core/i18n`, passed (1 file, 7 tests).
- *`eras-fe-react-review`:* a dry run on the code of change `0004` (from `4ea794f` to `c21ed4c`, the whole repository) changed no file and gave 3 findings, kept as Follow-ups because they are outside this change:
  - `src/app/routing/RoleGuard.tsx:8` and `src/app/session.tsx:14`: props typed inline instead of with an `interface` (rule 6).
  - `src/main.tsx:34`: the start-up error text "ERAS could not start:" is not in the resources (rule 1). It is shown before the texts load.

**Group 4 and 5, pointers and verification (2026-11-19):**
- *Pointers:* `ERAS-FE-React/AGENTS.md` names the three skills, in §7.1 (after the steps, and in step 7) and §7.2. Under §7.2 it also lists the four rules that `npm run lint` now enforces. The parent's `sdd-implement` follows a side's `<name>-feature` skill next to its `<name>-test` skill. The three `SKILL.md` files were formatted with the repository's Prettier, as `eras-fe-react-test` and `AGENTS.md` already are.
- *Gates:* `run-gates.sh --side FE-React` gave `openspec validate`, lint, test, typecheck and build all PASS. `check-skills.sh` gave 0 errors, and the hook self-test passed 23/23. It was run again after the session restarted, which had cut off the first run.
- *Files changed:*
  - parent: `.claude/skills/sdd-implement/SKILL.md` and this change folder;
  - `ERAS-FE-React`: `AGENTS.md`, `eslint.config.js` and the three new skill folders;
  - `ERAS-BE` and `ERAS-FE`: only the user's machine-local files.

  `package.json` and `package-lock.json` are unchanged.

**Task 4.3, discovery check (2026-11-19):** in a new Claude Code session at the parent root, the user asked which skill the agent would follow for an FE-React implementation task, without writing code. No scratch change was created, so nothing had to be discarded. The agent chose `/sdd-implement` and reached `eras-fe-react-test`, `eras-fe-react-feature` and `eras-fe-react-i18n` through the pointer in `sdd-implement` (it cited `SKILL.md:63-67`) and through `ERAS-FE-React/AGENTS.md`. It also named the FE-React gates, `run-gates.sh`, `check-impl.sh`, `/sdd-validate-impl` and `eras-fe-react-review`. The answer does not show whether the nested skills are listed by name at session start; they are reached through the pointers, as the proposal expects.

## Validation log

- Skipped: no BE controller or FE change (agent skills, docs and lint configuration only; no screen or behavior of a web client changed).
- Verified 2026-11-19: no gaps, no drift, gates green
