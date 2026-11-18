# Tasks

## 1. Frontend (FE)

- [ ] 1.1 Add `ATTACHMENT_MESSAGES` (friendly texts for size, type, duplicate, max files, upload failure, and the modal title and body) to `ERAS-FE/src/app/core/constants/messages.ts` and verify it compiles with `npm run build`
- [ ] 1.2 Write the specs `[605-allow-intervention-creation-with-attachment-errors/AC-7]`, `AC-8`, `AC-9`, `AC-10` for (AC-7) (AC-8) (AC-9) (AC-10) in `ERAS-FE/src/app/shared/components/attachment-manager/attachment-manager.component.spec.ts`, one `it()` each, and verify they fail
- [ ] 1.3 Implement the per-file `rejectionMessages` signal, the `errorMessages` computed, the `created` or `saved` verb from `entityId()` and the template loop in `attachment-manager.component.ts` and `.html` for (AC-7) (AC-8) (AC-9) (AC-10) and verify the specs from 1.2 pass
- [ ] 1.4 Write the specs `[605-allow-intervention-creation-with-attachment-errors/AC-11]`, `AC-12`, `AC-13` for (AC-11) (AC-12) (AC-13) in the same spec file and verify they fail
- [ ] 1.5 Implement the derived upload-failure messages, the "saved" wording when `entityId` is set and one message per rejected file, and remove the `uploadError` branch from `notifyFormControl()` in `attachment-manager.component.ts` for (AC-11) (AC-12) (AC-13) and verify the specs from 1.4 pass; update the old `uploadError` and old-text specs of that file (no AC tag)
- [ ] 1.6 Write the spec `[605-allow-intervention-creation-with-attachment-errors/AC-14]` for (AC-14) in `ERAS-FE/src/app/modules/assessments/components/interventions/edit-intervention-modal/edit-intervention-modal.component.spec.ts` and verify it fails
- [ ] 1.7 Remove the `uploadError` branch from `onStagedFilesChange()` in `edit-intervention-modal.component.ts` for (AC-14), update the existing spec that expects `{ uploadError: true }`, and verify the spec from 1.6 passes
- [ ] 1.8 Write the specs `[605-allow-intervention-creation-with-attachment-errors/AC-1]` to `AC-6` for (AC-1) (AC-2) (AC-3) (AC-4) (AC-5) (AC-6) in `ERAS-FE/src/app/modules/assessments/components/interventions/new-intervention-modal/new-intervention-modal.component.spec.ts`, one `it()` each, with `MatDialog` spied, and verify they fail
- [ ] 1.9 Implement the confirmation step with `MatDialog` and `ModalDeleteConfirmationComponent` in `submitIntervention()` and remove the `uploadError` branch from `onStagedFilesChange()` in `new-intervention-modal.component.ts` for (AC-1) (AC-2) (AC-3) (AC-4) (AC-5) (AC-6), update the existing spec that expects `{ uploadError: true }`, and verify the specs from 1.8 pass

## 2. Verification

- [ ] 2.1 FE gates pass in `ERAS-FE/`: `npm run lint`, `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` (>= 15%), `npm run build` (AGENTS.md §8.7)
- [ ] 2.2 The AC traceability check (AGENTS.md §8.6) shows exactly 1 FE test per AC, and `openspec validate 605-allow-intervention-creation-with-attachment-errors --strict` passes
- [ ] 2.3 Manual check in the app: create an intervention with a `.exe` and an oversized file, see the friendly messages and the modal, and verify "Create anyway" creates it and "Keep editing" returns to the form

## Traceability
| AC | Scenario | Side | Test |
|----|----------|------|------|
| AC-1 | Confirmation modal appears when an attachment was rejected | FE | src/app/modules/assessments/components/interventions/new-intervention-modal/new-intervention-modal.component.spec.ts › [605-allow-intervention-creation-with-attachment-errors/AC-1] opens the "Attachments with errors" modal when Create is clicked with an attachment error |
| AC-2 | Confirming creates the intervention without the rejected files | FE | src/app/modules/assessments/components/interventions/new-intervention-modal/new-intervention-modal.component.spec.ts › [605-allow-intervention-creation-with-attachment-errors/AC-2] creates the intervention without the rejected files after "Create anyway" |
| AC-3 | Keep editing returns to the form unchanged | FE | src/app/modules/assessments/components/interventions/new-intervention-modal/new-intervention-modal.component.spec.ts › [605-allow-intervention-creation-with-attachment-errors/AC-3] keeps the form open and creates nothing after "Keep editing" |
| AC-4 | No modal when every attachment is valid | FE | src/app/modules/assessments/components/interventions/new-intervention-modal/new-intervention-modal.component.spec.ts › [605-allow-intervention-creation-with-attachment-errors/AC-4] creates the intervention without a modal when every attachment is valid |
| AC-5 | A failed upload does not block Create and also triggers the modal | FE | src/app/modules/assessments/components/interventions/new-intervention-modal/new-intervention-modal.component.spec.ts › [605-allow-intervention-creation-with-attachment-errors/AC-5] keeps Create enabled and opens the modal when an upload failed |
| AC-6 | No modal after the rejected file is removed | FE | src/app/modules/assessments/components/interventions/new-intervention-modal/new-intervention-modal.component.spec.ts › [605-allow-intervention-creation-with-attachment-errors/AC-6] creates without the modal after a valid file replaces the rejected one |
| AC-7 | File over the size limit | FE | src/app/shared/components/attachment-manager/attachment-manager.component.spec.ts › [605-allow-intervention-creation-with-attachment-errors/AC-7] shows the friendly size-limit message |
| AC-8 | Unsupported format | FE | src/app/shared/components/attachment-manager/attachment-manager.component.spec.ts › [605-allow-intervention-creation-with-attachment-errors/AC-8] shows the friendly unsupported-type message |
| AC-9 | Duplicated file | FE | src/app/shared/components/attachment-manager/attachment-manager.component.spec.ts › [605-allow-intervention-creation-with-attachment-errors/AC-9] shows the friendly duplicated-file message |
| AC-10 | Too many files | FE | src/app/shared/components/attachment-manager/attachment-manager.component.spec.ts › [605-allow-intervention-creation-with-attachment-errors/AC-10] shows the friendly maximum-files message |
| AC-11 | Upload failure | FE | src/app/shared/components/attachment-manager/attachment-manager.component.spec.ts › [605-allow-intervention-creation-with-attachment-errors/AC-11] shows the friendly upload-failure message |
| AC-12 | Edit shows the same friendly messages | FE | src/app/shared/components/attachment-manager/attachment-manager.component.spec.ts › [605-allow-intervention-creation-with-attachment-errors/AC-12] says "saved" instead of "created" when editing an existing intervention |
| AC-13 | One message per rejected file | FE | src/app/shared/components/attachment-manager/attachment-manager.component.spec.ts › [605-allow-intervention-creation-with-attachment-errors/AC-13] shows one message per rejected file |
| AC-14 | A failed upload does not block saving an edit | FE | src/app/modules/assessments/components/interventions/edit-intervention-modal/edit-intervention-modal.component.spec.ts › [605-allow-intervention-creation-with-attachment-errors/AC-14] keeps Save enabled and saves without a modal when an upload failed |
