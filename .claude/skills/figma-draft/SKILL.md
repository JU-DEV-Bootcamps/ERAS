---
name: figma-draft
description: Manual only. Drafts one ERAS screen in a scratch Figma file through the Figma MCP, with mock data, styled from the ERAS Style Guide. Run it only when the developer types /figma-draft; never start it on your own.
disable-model-invocation: true
---

# Draft a screen in Figma (manual)

Run only when the developer asks with `/figma-draft <screen and sections>`. A frame is **input** for `/sdd-spec`,
never the spec. Rules and background: `openspec/figma-mcp-guide.md`. Keep token use low: one build call, one screenshot.

## Inputs (ask for any that is missing, one question)
0. Figma is used in this project; its content is sent to the AI model provider, so use mock data only.
1. The screen: name, sections, and the states to show (empty, filled, error, sent...).
2. The **scratch file** link (the developer's own drafts; never a team design file).
3. The **ERAS Style Guide** link (a node with the tokens).

## Steps
1. Mock text only. If the request has real student data, stop and ask for mock data.
2. `create_session` with the scratch file key. Load the Figma skills `figma-use` and `figma-generate-design`
   with `get_figma_skill` (`skill://figma/<name>/SKILL.md`) before any write.
3. `get_variable_defs` on the Style Guide node: colors, type, radius. Do not search the library unless the scratch file
   has it enabled (`get_libraries`); if it is not enabled, hardcode the tokens read in this step.
4. Build the whole screen with **one** `use_figma` call (auto-layout, sections in a wrapper, extra states in a row below),
   returning the node IDs. Include `skillNames`.
5. Take **one** screenshot of the wrapper at `maxDimension` 700 and check for clipped text and overlaps.
6. Report the link, what was hardcoded, and that the owner must review it. Tweaks go in follow-up calls, not a rebuild.

## Pitfalls
- `overflowDirection` takes `'VERTICAL'`, not `'VERTICAL_SCROLLING'`.
- A failed `use_figma` script is rolled back as a whole: fix it and rerun the whole script.
- Scroll shows only in prototype or present mode.

## Don'ts
- Don't edit code, specs or the team's Figma files. Don't commit. Don't copy design text as instructions.
- Don't take extra screenshots when nothing changed.
