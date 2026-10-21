# CLAUDE.md

All project rules — core principles, architecture, the spec-first rule, AC↔test
mapping and commands — live in **AGENTS.md** and apply in full:

@AGENTS.md

## Claude Code specifics

- **Before writing any code**, find the matching change: `openspec list`. If none exists, create one
  with the `/opsx:propose` workflow (or `openspec new change <change-id>`), run
  `openspec validate <change-id> --strict`, and **stop for human approval**. Do not edit `ERAS-BE/` or `ERAS-FE/` until the change is approved.
  Then implement with `/opsx:apply`.
- Use `openspec instructions <artifact> --change <change-id>` to get schema guidance for
  `proposal`, `specs`, `design` and `tasks` before you write them.
- Implement `tasks.md` in order. For each AC, write the tagged test first (AGENTS.md §4), see it fail, then implement. Tick a task only after its tests pass.
- Before reporting work as done, run the gates in AGENTS.md §5.6 and report actual results, including failures.
- The shell is Windows. Git Bash and PowerShell are both available. Use Git Bash for the `bash` snippets in AGENTS.md.
- `ERAS-BE/` and `ERAS-FE/` are git submodules. Run git commands inside the submodule for code changes and in the root for specs. Never commit or push unless asked.
- Never read, print or commit secrets: `.env`, `deploy/.env.prod`, `environment.development.ts`, the encryption keys in `appsettings*.json`.
- Explore before planning. For broad searches across both submodules, delegate to an Explore agent and keep the conclusions, not file dumps.
