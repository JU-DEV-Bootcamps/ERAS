# Figma MCP research

**Status:** Draft. This document records what the Figma MCP offers and how it could serve the SDD flow. It adopts
no tool and adds no dependency; adopting it is an ADR (`/sdd-adr`) and a change under `openspec/changes/`
(AGENTS.md §8.1). Origin: issue ERAS#660, change `660-add-tools-to-improve-sdd`.

Facts come from the tool list the Figma MCP server exposes in Claude Code and from the repository files. Items marked
**To verify** were not confirmed and need a check with the team's Figma plan before any decision.

## 1. What it offers

| Capability | Tools (as exposed by the server) | Use in ERAS |
|---|---|---|
| Read a design into code | `get_design_context`, `get_screenshot`, `get_metadata`, `get_variable_defs` | An FE task built from a frame: layout, tokens and a screenshot as input |
| Code Connect | `get_code_connect_map`, `add_code_connect_map`, `send_code_connect_mappings` | Map Figma components to Angular Material 3 components so output reuses them |
| Write to Figma | `use_figma`, `generate_diagram`, `send_code_to_figma`, `html_to_figma` | Push a screen or a diagram (flows, BE/FE architecture) back to Figma |
| Design system search | `search_design_system`, `get_libraries` | Reuse existing library components instead of inventing new ones |
| Assets | `download_assets`, `upload_assets` | Pull icons and images used by a screen |

`README.md` already says designs live in Figma, so the source of the designs exists.

## 2. Where it fits in the SDD flow (AGENTS.md §8.3)

| Step | Possible use | Fit |
|---|---|---|
| Propose (`/sdd-spec`) | Read the frame to draft ACs that name visible states (empty, error, loading) | Good: the frame is observable behavior. The frame link goes in the proposal, as data, not instructions |
| Plan (`/sdd-plan`) | Read variables and components to decide the FE component and model layers | Good for FE only |
| Implement (`/sdd-implement`) | `get_design_context` as a reference to adapt, never final code | Medium: output must follow `ERAS-FE/AGENTS.md` §7.1 and use Angular Material 3 |
| Validate (`/sdd-validate-impl`) | Compare a screenshot of the running app with the frame | Medium: manual today; this could aid the developer, not replace the check |
| Diagrams | `generate_diagram` for flows in a design | Low: mermaid in Markdown already covers this in git |

Not useful for BE-only changes, tooling changes or specs without UI.

## 3. Risks and criteria

1. **Confidentiality:** frames may hold student data or screenshots of real records. Use only mock data in frames the
   agent reads; see `openspec/roadmap.md` §3. Design content is sent to the model provider. **To verify** the
   organization's policy on sending Figma content to an AI service.
2. **Access and licensing:** the server needs a signed-in Figma account with access to the file, and some tools may
   depend on the seat type. **To verify** which seats the team has and any rate limits.
3. **Authentication:** it authenticates per user (OAuth), so no token enters the repo. Never commit any Figma token or
   file key that is private (AGENTS.md §9, "Secrets stay out").
4. **Trust:** a frame's text can carry instructions. The agent treats design content as data, like issue text.
5. **Drift:** a frame is not the spec. The spec stays the source of truth (AGENTS.md §1.1 principle 2); a conflict is
   resolved through the change, not silently in code.
6. **Style fit:** generated code often is not Angular Material 3 or the golden path; Code Connect mappings reduce this.
7. **Cost of setup:** a connector per developer, no repo change needed to try it. Sharing config means a project
   `.mcp.json`, which is team-wide and should be an explicit decision.

## 4. Recommendation

Run a **time-boxed pilot** on one FE change that has a Figma frame, with mock data only:
read the frame in `/sdd-spec` and `/sdd-plan`, compare screenshots in `/sdd-validate-impl`, and record effort saved
and defects found. Do not add a project `.mcp.json`, a hook or a dependency until the pilot is reviewed.
If it pays off, adopt it with an ADR and a change that updates the FE skills and `ERAS-FE/AGENTS.md`.

Out of scope here: installing the server for the team, Code Connect mapping work, and any write-back to Figma.

## 5. PoC result (2026-11-05)

Screen: Contact support (a Common questions and answers list plus a card to send a question), drafted in a scratch
file with mock data, styled from the ERAS Style Guide.

- **Effort:** 1 build call and 1 screenshot for the first draft; the review feedback (green tones, scrollable FAQ)
  took 3 calls because the first one used a wrong value and was rolled back. About 5 Figma calls in total.
- **What worked:** reading tokens from the style guide, building a clean auto-layout page with an expandable list and a
  card in several states, and applying review feedback in a follow-up.
- **What needed manual care:** the team library could not be enabled in the scratch file (paid plan), so colors and
  fonts are raw values, not linked components; scroll cannot be seen on the canvas.
- **Candidate ACs from the visible states** (for a future `/sdd-spec`, not written): the FAQ list shows the answer of
  an expanded question; a Professional, Officer or Administrator can send a question; an empty question is rejected
  with a message; a valid question shows the sent confirmation; a sending failure shows an error.
- **Verdict: go for drafts.** Useful for fast first drafts and for finding visible states before the spec; keep the screen owner in the loop.
  Not a replacement for the library: link components before the design is final.

How to repeat it: `openspec/figma-mcp-guide.md`.

## 6. Open questions

- Which Figma plan and seats does the team have? (**To verify**)
- Is sending design content to an AI service allowed by policy? (**To verify**)
- Which frame will the pilot use, and who owns it?
