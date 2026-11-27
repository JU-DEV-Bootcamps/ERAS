# ADR-0016: Use MUI with one theme as the UI library of the React client

**Status:** Accepted
**Date:** 2026-11-20
**Area:** frontend
**Change:** none
**Reviewed by:** richardecos-dev (2026-11-20)
**Signed by:** richardecos-dev (2026-11-20)

## Context

ADR-0012 leaves the UI library of v3 (`ERAS-FE-React`) as a separate decision, required before the first v3 module; until then `ERAS-FE-React/AGENTS.md` §7.1 step 8 allows only plain semantic HTML. v2 and v3 live on permanently side by side (ADR-0012), and v2 is built with Angular Material 3 and its tokens in `ERAS-FE/src/styles/utils/` (`_theme-colors.scss`, `_theme-fonts.scss`, `_theme-sizes.scss`, `_theme-breakpoints.scss`), with breakpoints at 768px (tablet) and 1024px (desktop). The modules being ported (first Home) use cards, tables, chips, links and dialogs. The jsx-a11y rules are errors in v3. This decision applies to every v3 module and changes nothing in `ERAS-FE` or `ERAS-BE`.

## Decision

v3 uses MUI (Material UI) as its only component library, styled through one MUI theme that is the single source of colors, typography, spacing, shape and breakpoints.

- **One theme**, defined once in `src/app/theme.ts` and mounted with `ThemeProvider` and `CssBaseline` in `AppProviders`. Its values copy v2's tokens from `ERAS-FE/src/styles/utils/` (read only), so both clients look alike; its breakpoints match v2's: below 768px is mobile, 768px to 1023px is tablet, 1024px and above is desktop.
- **No color, font or size is written by hand** in a component: components read them from the theme (`'primary.main'`, `theme.spacing(2)`, `theme.breakpoints.up('md')`).
- **Adjustments** use the `sx` prop or `styled()` with theme values; **responsive layout** uses the theme breakpoints in `sx` or `useMediaQuery`.
- **Icons** come from `@mui/icons-material`.
- **No other styling system or component library** (Tailwind, CSS modules, Sass, another kit).
- MUI and its peer dependencies are installed with exact versions by the first change that needs them (ADR-0012).

## Alternatives

- MUI with Tailwind for layout and responsive tweaks → `sx` and the theme breakpoints already cover them; Tailwind would add a second styling system, a second palette that bypasses the theme, CSS order and reset conflicts with `CssBaseline`, different default breakpoints and one more build dependency.
- Tailwind with headless components (Radix, shadcn) → v3 would not look like v2's Angular Material, and every component would be built and maintained in the repository.
- Mantine, Chakra or another kit → no Material look, so v2 and v3 would diverge visually.
- Plain semantic HTML and hand-written CSS → tables, dialogs and form controls rebuilt by hand, with their accessibility.
- MUI's default theme → v3 would look different from v2.

## Consequences

- v2 and v3 share the same look; a change of v2's tokens must be copied by hand to `src/app/theme.ts`, because the two repositories share no code.
- One way to style anything, so reviews check one rule: values come from the theme.
- MUI brings Emotion (CSS-in-JS) and adds weight to the bundle; the v3 team owns its updates and audit.
- MUI components carry their own ARIA, but jsx-a11y still applies: labels, headings and real buttons and links stay the author's job.
- Storybook (deferred by change `0004` until this decision) can now be planned in its own change.
- The first module with a screen (planned: the Home port) installs MUI, writes `src/app/theme.ts` and mounts it in `AppProviders`.
- `ERAS-FE-React/AGENTS.md` §7.1 step 8 and §7.2, and the "Stop and ask" list of `eras-fe-react-feature`, must point to this ADR once it is Accepted.
