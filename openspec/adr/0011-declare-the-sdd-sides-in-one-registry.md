# ADR-0011: Declare the SDD sides in one registry

**Status:** Accepted
**Date:** 2026-11-17
**Area:** process
**Change:** 0003-support-multiple-frontend-clients
**Reviewed by:** richardecos-dev (2026-11-18) 
**Signed by:** richardecos-dev (2026-11-18)

## Context

A side is a submodule whose tests prove an AC: today `BE` (`ERAS-BE`) and `FE` (`ERAS-FE`, Angular). A second, permanent web client, `ERAS-FE-React` (React, a different team), is coming and will share the specs and the AC keys with `FE`.

The two sides are written by hand in about 18 files: `openspec/config.yaml`, `openspec/sdd-conventions.md`, `AGENTS.md` §5.2, §8.6 and §8.7, `CLAUDE.md`, the `/sdd-*` skills and templates, and the scripts `check-spec.sh`, `check-plan.sh`, `check-impl.sh`, `run-gates.sh`, `check-archive.sh` and `check-skills.sh`. The scripts read the `**Side:**` line by substring (`side ~ /FE/`, `grep -qw FE`), so a side named `FE-React` would also count as `FE`, and `check-spec.sh` only accepts `BE`, `FE` or `BE + FE`.

Clients can come and go: if a client is dropped, every one of those files would have to be edited again. The scripts run in Git Bash on Windows and with GNU awk on the CI runner, where no YAML parser can be relied on. ADR-0007 already gives each submodule its own `AGENTS.md` for its rules.

## Decision

Every side is declared once, in `openspec/sides.conf`: one `[section]` per side with its name, submodule folder, test root, test file patterns, the form of the AC key in a test (`trait` or `title`), the pattern of a focused or skipped test, its parity group, the generated folders to delete before the gates, its gate commands in order and its coverage minimum. Scripts, skills and rules read the sides from it (through `.claude/skills/sdd-shared/sides.sh`) and never name a client by hand. A `**Side:**` value is split on ` + `, and each part must match a registered name whole. Adding or removing a client is one `[section]` in the registry plus that client's own `AGENTS.md` (ADR-0007, applied to every registered client).

## Alternatives

- Hard-code `FE-React` next to `FE` in every file → about 18 files to edit now, and again for every client added or removed; the two teams would conflict on the same lines.
- A naming convention matched by pattern (`FE*`) → `FE-React` still matches `FE`, which is the bug to remove.
- A YAML or JSON registry → no reliable YAML parser in Git Bash or gawk, and `jq` is not guaranteed on every contributor's machine.
- The sides inside `openspec/config.yaml` → the OpenSpec CLI owns that file's schema, and its `context` text is not machine-readable.

## Consequences

- `FE` and `FE-React` are counted, gated and archived separately, and an AC can be declared for any combination of them.
- A new client needs no edit to scripts or skills; a dropped client leaves no dead rule behind.
- Gate commands of a client are `npm run` script names, so the real commands and thresholds live in the client's own repository.
- Rules that name a side's own framework (for example the Angular names in `AGENTS.md` §4.3) still need their own home; moving them to the client's `AGENTS.md` is follow-up work.
- `check-parity.sh` can list the ACs one client of a parity group covers and the other does not.
- The registry becomes a file every check depends on: a malformed line breaks all of them, so `run-tests.sh` covers it.
