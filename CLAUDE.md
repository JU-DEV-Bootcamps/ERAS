# CLAUDE.md

All project rules — core principles, architecture, the spec-first rule, AC↔test
mapping and commands — live in **AGENTS.md** and apply in full:

@AGENTS.md

Backend and frontend rules live in `ERAS-BE/AGENTS.md` and `ERAS-FE/AGENTS.md` (each imported by its own
`CLAUDE.md`). They load when you work in that submodule; the root `AGENTS.md` keeps a pointer under each
moved heading (ADR-0007).

## Claude Code specifics

- **A bare `#<n>`** (for example "review #675"): 1) look for the change `openspec/changes/<n>-*`; 2) if there is none, `gh issue view <n>` in `ERAS-BE`, `ERAS-FE` and the parent repo, and say in which one it was found; 3) read the current branch of each submodule with `git -C <submodule> branch --show-current`; 4) if there is more than one match, ask which one. Never guess an issue number or a repository.
- **Before writing any code**, find the matching change: `openspec list`. For a feature or behavior change, use the spec-first path in the next bullet. Only a change with no observable behavior (CI, docs, refactor, tooling) is created with the `/opsx:propose` workflow (or `openspec new change <change-id>`) and `skip_specs: true`: run
  `openspec validate <change-id> --strict`, and **stop for human approval**. Do not edit `ERAS-BE/` or `ERAS-FE/` until the change is approved.
  Then implement a `skip_specs` change with `/opsx:apply`. `/opsx:explore` is only for thinking; it writes nothing.
- For a new feature or behavior change, use the spec-first path: `/sdd-spec` writes the Draft spec, `/sdd-clarify` closes its gaps, a human sets `Status: Approved`, `/sdd-plan` writes `design.md` (the plan) and `tasks.md`, a human sets `Plan: Approved`, then `/sdd-implement` codes the tasks test first, `/sdd-validate-impl` is the manual gate (BE controller or FE changes) and `/sdd-verify` audits and recommends archiving; once the ship PR is approved, `/sdd-archive` archives the change as that PR's last commit, before it merges. Conventions: AGENTS.md §8.4. Do not use `/opsx:propose`, `/opsx:apply` or `/opsx:archive` for a feature: they skip the ERAS gates (`Status` and `Plan: Approved`, AC tags, test-first evidence, the §8.7 gates). Only `/sdd-implement` writes code; no skill commits.
- Architectural decisions (a dependency or pattern, an auth/role model, a data approach, a cross-cutting BE↔FE contract, a departure from a golden path) get an ADR in `openspec/adr/` via `/sdd-adr`, one decision per file, linked from the `design.md` D-block as `**ADR:** ADR-NNNN`. Read the Accepted ADRs in `openspec/adr/README.md` before planning, and never rewrite an Accepted ADR: supersede it.
- Use `openspec instructions <artifact> --change <change-id>` to get schema guidance for
  `proposal`, `specs`, `design` and `tasks` before you write them.
- Implement `tasks.md` in order. For each AC, write the tagged test first (AGENTS.md §5.2, §6.3, §7.3), see it fail, then implement. Tick a task only after its tests pass.
- Before reporting work as done, run the gates in AGENTS.md §8.7 and report actual results, including failures.
- The shell is Windows. Git Bash and PowerShell are both available. Use Git Bash for the `bash` snippets in AGENTS.md.
- `ERAS-BE/` and `ERAS-FE/` are git submodules. Run git commands inside the submodule for code changes and in the root for specs. Never commit or push unless asked.
- Never read, print or commit secrets: `.env`, `deploy/.env.prod`, `environment.development.ts`, the encryption keys in `appsettings*.json`.
- Explore before planning. For broad searches across both submodules, delegate to an Explore agent and keep the conclusions, not file dumps.
