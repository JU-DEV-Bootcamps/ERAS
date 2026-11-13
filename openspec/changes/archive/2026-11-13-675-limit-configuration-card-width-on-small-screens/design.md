# Design

## Context

The Settings page is `CosmicLatteComponent` (`ERAS-FE/src/app/modules/settings/cosmic-latte.component.*`). It renders each configuration with `app-configuration-card` inside `.card-grid-wrapper` (16px padding) > `.card-grid-container`, a grid with `grid-template-columns: repeat(auto-fill, minmax(300px, 1fr))` and a 16px gap. The shell adds `padding: 0 12px` below 768px and `0 20px` above (`ERAS-FE/src/app/core/components/layout/layout.component.scss`). See proposal.md - Why.

Measured from that CSS, the grid is `screen width - 56px` wide below 768px, and a second column only fits from about 672px. So below 670px there is one column and `1fr` stretches the card across it: at 375px the card is 319px wide, at 500px it is 444px. The `mat-card { width: 350px }` rule in `cosmic-latte.component.scss` never reaches the configuration card (view encapsulation: the card's `mat-card` belongs to the child component), so nothing caps its width. `configuration-card.component.scss` has no `:host` rule and no `@media`.

## Goals / Non-Goals

**Goals:**
- Cap the card at 350px and start it at the left of the card area below 670px (AC-1), without making it narrower than the space it has at 375px (AC-2), and leave it as it is from 670px up (AC-3).

**Non-Goals:**
- Changing the grid, the paddings of the wrapper or of the shell, the number of columns, or the `mat-card` rule in `cosmic-latte.component.scss` (it only serves the service provider cards).
- A shared breakpoint token or mixin for 670px: one rule uses it.

## Decisions

### D1. Put the cap in the card's own stylesheet, on `:host`
**Choice:** a `@media` block in `configuration-card.component.scss` styles `:host` (the `app-configuration-card` element, which is the grid item). The rule travels with the card and the page stylesheet stays untouched.
**Alternative:** a `.card-grid-container > app-configuration-card` rule in `cosmic-latte.component.scss` → works too (the host element is in that template), but spreads one card's sizing over two files and leaves the dead `mat-card` rule looking like the owner.

### D2. `width: 100%; max-width: 350px; justify-self: start`
**Choice:** inside the media block, `:host { width: 100%; max-width: 350px; justify-self: start; }`. `width: 100%` keeps the card as wide as its column when the column is under 350px (AC-2); `max-width` caps it (AC-1); `justify-self: start` stops the grid from stretching it and leaves the free space on its right.
**Alternative:** `width: 350px` → overflows a column narrower than 350px, which breaks AC-2 on a 375px screen.

### D3. Breakpoint `@media screen and (max-width: 669.98px)`
**Choice:** "narrower than 670px" is written as `669.98px`, the same convention as `MOBILE_MEDIA_QUERY = '(max-width: 767.98px)'` in `core/services/layout/viewport.service.ts`, so fractional widths are not left in a gap. Nothing outside the block changes, so AC-3 holds by construction.
**Alternative:** `max-width: 669px` → leaves 669.5px unstyled.

### D4. Test the media query in an iframe of the screen width
**Choice:** a `@media` rule answers to the window, not to the host width, so the `host.style.width` trick used in `home.component.spec.ts` cannot prove it. Each spec renders `CosmicLatteComponent` as usual, then moves its element into an `<iframe>` of the width under test, positioned off-screen (not `display: none`, which would skip layout) (375, 500, 1280) together with copies of the document's `<style>` and `<link rel="stylesheet">` nodes, wrapped in a div with the shell's padding, and measures `getBoundingClientRect()` there. The helper lives in `cosmic-latte.component.spec.ts` (one consumer).
**Alternative:** read the rule from `document.styleSheets` and evaluate its media text → proves the text of the CSS, not what the user sees. **Alternative:** a launcher flag for the window size → fixed for the whole run, one width only.

## Changes by layer

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Component | `@media screen and (max-width: 669.98px) { :host { width: 100%; max-width: 350px; justify-self: start; } }`; no TS or template change, no new colors | `src/app/modules/settings/configuration-card/configuration-card.component.scss` | AC-1, AC-2, AC-3 |
| Tests | Iframe helper and three tagged specs in a new `describe` of the page spec | `src/app/modules/settings/cosmic-latte.component.spec.ts` | AC-1, AC-2, AC-3 |

## API contract

No API change.

## Data and migration

No schema change.

## Test strategy

Each spec renders the page with two configurations (so stacking can be measured), one service provider (the card reads `serviceProviders[0].serviceProviderLogo`) and a `healthCheck` stub that returns `{ status: true, dateTime }`; the role is irrelevant to the CSS, so the user stub is the same one the existing `describe` uses. "Card area" is `.card-grid-container`.

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | FE | `src/app/modules/settings/cosmic-latte.component.spec.ts` | `[675-limit-configuration-card-width-on-small-screens/AC-1] caps the card at 350px and starts it at the left of the card area on a 500px screen` |
| AC-2 | FE | same file | `[675-limit-configuration-card-width-on-small-screens/AC-2] fills the available width, under 350px, and stacks the cards on a 375px screen` |
| AC-3 | FE | same file | `[675-limit-configuration-card-width-on-small-screens/AC-3] keeps the grid column width with no cap on a 1280px screen` |

What each one asserts: AC-1, the first card is 350px wide and its left edge equals the card area's left edge. AC-2, the first card is as wide as the card area, under 350px, and the second card's top is at or below the first one's bottom. AC-3, the first card is as wide as the first track of the computed `grid-template-columns` and wider than 350px, and its left edge equals the card area's left edge.

AC-2 and AC-3 describe behavior that holds today, so they pass before the stylesheet changes: they are guards. Each is shown to fail once by a temporary edit (a fixed `width: 350px` for AC-2, the rule moved outside the media block for AC-3) and the edit is reverted.

Extra edge-case tests carry no AC tag. Coverage gates: FE >= 15% (AGENTS.md section 8.7).

## Risks / Trade-offs

- [The iframe copies stylesheets that load asynchronously, so a measure could run before they apply] → the helper waits for the `load` event of every copied `<link>` before measuring.
- [The iframe approach is heavier than a unit test] → three specs, one helper, one consumer; the alternatives in D4 do not prove the behavior.
- [The shell padding in the helper (12px / 20px) can drift from `layout.component.scss`] → the assertions compare the card with the card area, never with a pixel count that depends on that padding, except the 350px cap.
- [A card under 350px of space still overflows when the screen is under about 356px, because the grid keeps `minmax(300px, 1fr)`] → unchanged and out of scope; the rule never makes it worse.
- Blast radius: only `app-configuration-card`, used in one template.

## Follow-ups
- `mat-card { width: 350px }` in `cosmic-latte.component.scss` only reaches the service provider cards, and the card-related rules duplicated there (`.services-card`, `.title-status`, `.ligth`, `.check`, `.close`, `mat-card-actions`) look dead for the configuration card. A cleanup gets its own change.
- `cosmic-latte.component.html` still uses `*ngFor` and the card uses `@Input()`, `@Output()` and constructor injection (legacy patterns, AGENTS.md section 7.2). Left alone as out of scope.
