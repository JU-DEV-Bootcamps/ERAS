# Tasks

## 1. Frontend (FE)

- [x] 1.1 Write the spec `[676-improve-account-user-manuals-mobile-view/AC-1] keeps a 60-character email and long values inside the profile card on a mobile screen` for (AC-1) in `ERAS-FE/src/app/modules/profile/components/account-information/account-information.component.spec.ts`, rendering the real children in a 343px host with `ViewportService` as `{ isMobile: signal(true) }`, and verify it fails
- [x] 1.2 Implement the `mobile` class and the one-column grid and wrapping in `profile-card.component.{ts,html,scss}` for (AC-1) and verify the spec from 1.1 passes
- [x] 1.3 Write the spec `[676-improve-account-user-manuals-mobile-view/AC-2] stacks the professional info and keeps a long course name inside its card on a mobile screen` for (AC-2) in the same spec file, with a professional and a course name of 80 characters without spaces, and verify it fails
- [x] 1.4 Implement the `mobile` class, the one-column grid, the wrapping and the fixed layout of the courses table in `professional-info.component.{ts,html,scss}` for (AC-2) and verify the spec from 1.3 passes
- [x] 1.5 Write the spec `[676-improve-account-user-manuals-mobile-view/AC-5] keeps two columns and does not break values on a desktop screen` for (AC-5) in the same spec file, in a 1280px host with `{ isMobile: signal(false) }`, and verify it passes before and after 1.2 and 1.4
- [x] 1.6 Write the spec `[676-improve-account-user-manuals-mobile-view/AC-6] keeps a 100-character title and the Download button inside the row on a mobile screen` for (AC-6) in `ERAS-FE/src/app/modules/user-manuals/user-manuals.component.spec.ts`, in a 343px host with `{ isMobile: signal(true) }`, and verify it fails
- [x] 1.7 Implement the `mobile` class, `min-width: 0` on the info block, the wrapping title and the non-shrinking Download button in `user-manuals.component.{ts,html,scss}` for (AC-6) and verify the spec from 1.6 passes
- [x] 1.8 Write the spec `[676-improve-account-user-manuals-mobile-view/AC-8] keeps the row and does not break the title on a desktop screen` for (AC-8) in the same spec file, in a 1280px host with `{ isMobile: signal(false) }`, and verify it passes before and after 1.7
- [x] 1.9 Provide `ViewportService` in the existing specs of `profile-card`, `professional-info` and `user-manuals` where they assert desktop behavior, and verify the three spec files stay green

## 2. Verification

- [x] 2.1 FE gates of AGENTS.md section 8.7 pass in `ERAS-FE/`: `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (>= 15%), `npm run build`, and `npx prettier --check` on the changed files
- [x] 2.2 The AC traceability check (AGENTS.md section 8.6) shows exactly 1 test per AC per affected side, and `openspec validate 676-improve-account-user-manuals-mobile-view --strict` passes

## Traceability
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | The profile card is stacked and readable | FE | src/app/modules/profile/components/account-information/account-information.component.spec.ts › [676-improve-account-user-manuals-mobile-view/AC-1] keeps a 60-character email and long values inside the profile card on a mobile screen |
| AC-2 | The professional info is stacked and its courses fit | FE | src/app/modules/profile/components/account-information/account-information.component.spec.ts › [676-improve-account-user-manuals-mobile-view/AC-2] stacks the professional info and keeps a long course name inside its card on a mobile screen |
| AC-5 | Desktop keeps the current layout | FE | src/app/modules/profile/components/account-information/account-information.component.spec.ts › [676-improve-account-user-manuals-mobile-view/AC-5] keeps two columns and does not break values on a desktop screen |
| AC-6 | A manual with a long title fits the screen | FE | src/app/modules/user-manuals/user-manuals.component.spec.ts › [676-improve-account-user-manuals-mobile-view/AC-6] keeps a 100-character title and the Download button inside the row on a mobile screen |
| AC-8 | Desktop keeps the current list | FE | src/app/modules/user-manuals/user-manuals.component.spec.ts › [676-improve-account-user-manuals-mobile-view/AC-8] keeps the row and does not break the title on a desktop screen |
