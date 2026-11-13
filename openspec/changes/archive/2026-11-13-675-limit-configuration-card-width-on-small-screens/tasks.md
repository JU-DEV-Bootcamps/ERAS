# Tasks

## 1. Frontend (FE)

- [x] 1.1 Write the iframe helper and the spec `[675-limit-configuration-card-width-on-small-screens/AC-1] caps the card at 350px and starts it at the left of the card area on a 500px screen` for (AC-1) in a new `describe` of `ERAS-FE/src/app/modules/settings/cosmic-latte.component.spec.ts`, and verify it fails because the card is about 444px wide
- [x] 1.2 Write the spec `[675-limit-configuration-card-width-on-small-screens/AC-2] fills the available width, under 350px, and stacks the cards on a 375px screen` for (AC-2) in the same file, and verify it passes against today's styles and fails once with a temporary `width: 350px` on `:host` (a guard test), then revert that edit
- [x] 1.3 Write the spec `[675-limit-configuration-card-width-on-small-screens/AC-3] keeps the grid column width with no cap on a 1280px screen` for (AC-3) in the same file, and verify it passes against today's styles and fails once with the cap moved outside the media block (a guard test), then revert that edit
- [x] 1.4 Add `@media screen and (max-width: 669.98px) { :host { width: 100%; max-width: 350px; justify-self: start; } }` to `ERAS-FE/src/app/modules/settings/configuration-card/configuration-card.component.scss` for (AC-1), (AC-2) and (AC-3), and verify the three specs from 1.1 to 1.3 pass and `npm run lint` is clean

## 2. Verification

- [x] 2.1 FE gates pass in `ERAS-FE/`: `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (>= 15%), `npm run build` (AGENTS.md section 8.7)
- [x] 2.2 The AC traceability check (AGENTS.md section 8.6) shows exactly 1 FE test per AC and 0 BE tests, and `openspec validate 675-limit-configuration-card-width-on-small-screens --strict` passes
- [x] 2.3 Verify by hand at 375px, 500px, 669px, 670px and 1280px wide on the Settings page with at least two configurations that the card is never wider than 350px below 670px and starts at the left of the card area, and from 670px the layout is the same as in `develop`

## Traceability
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | Card is capped and left-aligned on a 500px screen | FE | src/app/modules/settings/cosmic-latte.component.spec.ts › [675-limit-configuration-card-width-on-small-screens/AC-1] caps the card at 350px and starts it at the left of the card area on a 500px screen |
| AC-2 | Card fills the available width on a 375px screen | FE | src/app/modules/settings/cosmic-latte.component.spec.ts › [675-limit-configuration-card-width-on-small-screens/AC-2] fills the available width, under 350px, and stacks the cards on a 375px screen |
| AC-3 | Card keeps its grid column width on a 1280px screen | FE | src/app/modules/settings/cosmic-latte.component.spec.ts › [675-limit-configuration-card-width-on-small-screens/AC-3] keeps the grid column width with no cap on a 1280px screen |
