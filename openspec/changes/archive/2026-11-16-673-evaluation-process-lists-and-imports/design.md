# Design

## Context

On a screen narrower than 768px the Evaluation Process list (`ERAS-FE/src/app/modules/lists/components/evaluacion-process/evaluation-process-list.component.html`) renders through `app-list`, which renders `app-table-with-actions`. That component draws each item as a `mat-card` (`ERAS-FE/src/app/shared/components/table-with-actions/table-with-actions.component.html`, lines 10-76): one `.row-info` per column with a bold label and a `<span class="information">` with the value. The value is plain text with no wrapping rule, so a Poll Name with no spaces cannot break and pushes the text outside the card. The card is a block inside `.card-container`, so its width already follows the screen; only the text overflows. The desktop table (`#tableView`) uses `.cell-text` and is not involved.

The mobile switch comes from `ViewportService.isMobile` (`ERAS-FE/src/app/core/services/layout/viewport.service.ts`), which the existing spec of the table already replaces with a signal.

## Goals / Non-Goals

**Goals:**
- A long unbroken value stays inside the card on a mobile screen (AC-1).
- The table at 768px and wider does not change (AC-2).

**Non-Goals:**
- No change to the card layout, the labels, the badge or the action buttons.
- No change to the desktop table, to the form or to any other page.

## Decisions

### D1. Wrap long values in the shared card with CSS
**Choice:** add `overflow-wrap: anywhere` to `.row-info` in `table-with-actions.component.scss`. It only breaks a word that does not fit, so text with spaces looks the same, and it fixes the card where the bug lives. No TypeScript or template change.
**Alternative:** pass a `mapClass` card class from the evaluation process list → needs a global style, because the card is rendered in the child component, and leaves the other lists with the same bug.

### D2. Prove the behavior with a layout test, not a style string
**Choice:** the AC test renders the list in a host 343px wide, with a Poll Name of 100 characters, and checks that the Poll Name is broken over more than one line, that it ends inside the card, and that neither its row nor the host scrolls sideways, so it fails when the text overflows and passes when it wraps. `ViewportService` is replaced by a signal, as `table-with-actions.component.spec.ts` already does, so the test does not depend on the size of the Karma window.
**Alternative:** assert `overflow-wrap` in the computed style → passes with any rule that sets it and does not prove that nothing overflows.

## Changes by layer

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Component styles | `overflow-wrap: anywhere` on `.row-info` (card only) | `src/app/shared/components/table-with-actions/table-with-actions.component.scss` | AC-1 |
| Tests | Provide a `ViewportService` signal in the list spec; add one test per AC | `src/app/modules/lists/components/evaluacion-process/evaluation-process-list.component.spec.ts` | AC-1, AC-2 |

## API contract

No API change.

## Data and migration

No schema change.

## Test strategy

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | FE | `src/app/modules/lists/components/evaluacion-process/evaluation-process-list.component.spec.ts` | `[673-evaluation-process-lists-and-imports/AC-1] keeps a 100-character Poll Name inside its card on a mobile screen` |
| AC-2 | FE | `src/app/modules/lists/components/evaluacion-process/evaluation-process-list.component.spec.ts` | `[673-evaluation-process-lists-and-imports/AC-2] keeps the table and does not wrap the Poll Name on a desktop screen` |

Extra edge-case tests carry no AC tag. AC-2 guards against a regression, so it passes before and after the fix. Coverage gates: FE >= 15% (AGENTS.md section 8.7).

## Risks / Trade-offs

- [The style is in a shared component] → it only affects cards on a mobile screen and only text that did not fit; the existing card spec in `table-with-actions.component.spec.ts` must stay green, and the other lists with cards are checked by eye at 375px.
- [Providing a `ViewportService` mock in the list spec changes how the existing tests there run] → the default signal is `false` (desktop), and the full spec file must stay green.
- [`ERAS-FE` is on the branch of 672 with an unfinished merge] → check out `673-evaluation-process-lists-and-imports` in `ERAS-FE` once that merge is finished or aborted, or work in a separate worktree.

## Follow-ups

- In the mobile card the Period shows the raw timestamp (for example `2026-06-03T04:00:00Z`) because the card prints `item[column.key]` and skips the column pipe that the table applies. Out of scope here; worth its own ticket.
- Other long values in other cards of the shared component are covered by the same style but are not tested here.
