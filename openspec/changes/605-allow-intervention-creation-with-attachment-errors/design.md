# Design

## Context

Spec: `specs/intervention-attachments/spec.md` (AC-1..AC-14). FE only; the BE already claims whatever the draft session holds, so files that were rejected or failed never reach it.

Today, in `ERAS-FE/src/app/`:
- `shared/components/attachment-manager/attachment-manager.component.ts` validates selected files with `FileValidationService`, keeps one `errorMessage` signal built by `FormUtils.getTextError` (first error key only) and inline strings for the max-files cases, and marks failed uploads with `status: 'error'` without any message.
- `notifyFormControl()` of the manager and `onStagedFilesChange()` of the New and Edit modals set `{ uploadError: true }` on the `uploadInput` control, which makes the form invalid. `stagedFilesChange` is declared but never emitted, so only the manager's `notifyFormControl()` (called from `toggleRemoveExisting`) ever applies it.
- `new-intervention-modal.component.ts` `submitIntervention()` creates the intervention straight away. `core/services/unsaved-changes-guard.service.ts` already opens `ModalDeleteConfirmationComponent` (`shared/components/modals/modal-delete-confirmation/`) with `title`, `subtitle`, `confirmText`, `cancelText`.

## Goals / Non-Goals

**Goals:**
- A confirmation modal on Create when an attachment error is shown (AC-1..AC-6).
- Friendly, per-file messages in the shared attachment manager for Create and Edit (AC-7..AC-13).
- A failed upload never disables Create or Save (AC-5, AC-14).

**Non-Goals:**
- Emitting `stagedFilesChange` or making "uploading" block submit (see Follow-ups).
- Removing the now unused file keys of `FormUtils.getTextError`.

## Decisions

### D1. Message texts live in one builder in `core/constants/messages.ts`
**Choice:** a new `ATTACHMENT_MESSAGES` object with functions (`sizeExceeded`, `unsupportedType`, `duplicated`, `maxFiles`, `uploadFailed`, plus the modal title and body) that take the file name and a verb (`'created'` or `'saved'`). The manager picks the verb from `entityId()` (`null` means Create). AGENTS.md §7.1 asks for user-facing text in `messages.ts`.
**Alternative:** edit the keys in `FormUtils.getTextError` → they are generic form messages shared by all forms and have no notion of create or edit.

### D2. The manager keeps a list of rejection messages and derives the upload-failure messages
**Choice:** `errorMessage` becomes `rejectionMessages = signal<string[]>([])`, reset on every new selection (as today). Upload failures are a `computed` over `stagedFiles()` with `status === 'error'`, so they disappear when the file is retried successfully or removed. `errorMessages = computed(...)` joins both; `hasErrors` is true when it is not empty. The template renders one `<p>` per message. Each selected file is validated on its own, so one message per file is produced (AC-13).
**Alternative:** store upload failures in the same signal → they would not clear when the file is removed or retried.

### D3. Create asks through `MatDialog`, reading `hasErrors()` from the manager
**Choice:** in `NewInterventionModalComponent.submitIntervention()`, if `attachmentManagerNew.hasErrors()` is true, open `ModalDeleteConfirmationComponent` (title "Attachments with errors", the AC-1 text, `Create anyway` / `Keep editing`) and continue only when it closes with `true`. Otherwise submit as today. The component injects `MatDialog` itself; the guard service is not changed.
**Alternative:** add a method to `UnsavedChangesGuardService` → it is about leaving a dialog, not about submitting.

### D4. Failed uploads no longer make the form invalid
**Choice:** remove the `uploadError` branch from the manager's `notifyFormControl()` and from `onStagedFilesChange()` in both modals; keep `uploading`. The existing specs that assert `{ uploadError: true }` are updated to assert no error.
**Alternative:** keep it and bypass validity on submit → leaves the Create/Save button disabled, contradicting AC-5 and AC-14.

## Changes by layer

### Frontend (`ERAS-FE/`)

| Piece | Change | Files | ACs |
|---|---|---|---|
| Messages | Add `ATTACHMENT_MESSAGES` (friendly texts, modal title and body) | `src/app/core/constants/messages.ts` | AC-1, AC-7..AC-11, AC-13, AC-14 |
| Component | Per-file `rejectionMessages`, derived `uploadFailureMessages`, `errorMessages`, public `hasErrors`; verb from `entityId()`; drop `uploadError` | `src/app/shared/components/attachment-manager/attachment-manager.component.ts` | AC-5, AC-7..AC-14 |
| Template | Render one message per entry | `src/app/shared/components/attachment-manager/attachment-manager.component.html` | AC-7..AC-13 |
| Component | Confirmation step in `submitIntervention()`; drop `uploadError` in `onStagedFilesChange()` | `src/app/modules/assessments/components/interventions/new-intervention-modal/new-intervention-modal.component.ts` | AC-1..AC-6 |
| Component | Drop `uploadError` in `onStagedFilesChange()` | `src/app/modules/assessments/components/interventions/edit-intervention-modal/edit-intervention-modal.component.ts` | AC-14 |

## API contract

No API change.

## Data and migration

No schema change.

## Test strategy

| AC | Side | Layer / project | Planned test (file › name) |
|---|---|---|---|
| AC-1 | FE | `src/app/modules/assessments/components/interventions/new-intervention-modal/` | `new-intervention-modal.component.spec.ts` › `[605-allow-intervention-creation-with-attachment-errors/AC-1] opens the "Attachments with errors" modal when Create is clicked with an attachment error` |
| AC-2 | FE | same file | `[605-allow-intervention-creation-with-attachment-errors/AC-2] creates the intervention without the rejected files after "Create anyway"` |
| AC-3 | FE | same file | `[605-allow-intervention-creation-with-attachment-errors/AC-3] keeps the form open and creates nothing after "Keep editing"` |
| AC-4 | FE | same file | `[605-allow-intervention-creation-with-attachment-errors/AC-4] creates the intervention without a modal when every attachment is valid` |
| AC-5 | FE | same file | `[605-allow-intervention-creation-with-attachment-errors/AC-5] keeps Create enabled and opens the modal when an upload failed` |
| AC-6 | FE | same file | `[605-allow-intervention-creation-with-attachment-errors/AC-6] creates without the modal after a valid file replaces the rejected one` |
| AC-7 | FE | `src/app/shared/components/attachment-manager/` | `attachment-manager.component.spec.ts` › `[605-allow-intervention-creation-with-attachment-errors/AC-7] shows the friendly size-limit message` |
| AC-8 | FE | same file | `[605-allow-intervention-creation-with-attachment-errors/AC-8] shows the friendly unsupported-type message` |
| AC-9 | FE | same file | `[605-allow-intervention-creation-with-attachment-errors/AC-9] shows the friendly duplicated-file message` |
| AC-10 | FE | same file | `[605-allow-intervention-creation-with-attachment-errors/AC-10] shows the friendly maximum-files message` |
| AC-11 | FE | same file | `[605-allow-intervention-creation-with-attachment-errors/AC-11] shows the friendly upload-failure message` |
| AC-12 | FE | same file | `[605-allow-intervention-creation-with-attachment-errors/AC-12] says "saved" instead of "created" when editing an existing intervention` |
| AC-13 | FE | same file | `[605-allow-intervention-creation-with-attachment-errors/AC-13] shows one message per rejected file` |
| AC-14 | FE | `src/app/modules/assessments/components/interventions/edit-intervention-modal/` | `edit-intervention-modal.component.spec.ts` › `[605-allow-intervention-creation-with-attachment-errors/AC-14] keeps Save enabled and saves without a modal when an upload failed` |

AC-12's second line (no modal when saving an edit) holds because the Edit modal has no confirmation code path; AC-14 proves a save with an error goes straight through. Extra edge-case tests carry no AC tag. FE coverage gate >= 15% (AGENTS.md §8.7).

## Risks / Trade-offs

- [Blast radius: the manager is shared by New and Edit] → both modal specs and the manager spec run in the verification group; wording differs only by the `created`/`saved` verb.
- [Existing specs assert `uploadError` and the old texts] → they are updated in the same tasks as the behavior; none carries an AC tag.
- [The too-many-files-in-one-selection case has no AC] → its text is rewritten in the same friendly style and covered by the existing test, updated.
- [`stagedFilesChange` is never emitted, so a file that is still uploading may not block Create today] → unchanged by this change; see Follow-ups.

## Follow-ups
- `AttachmentManagerComponent.stagedFilesChange` is never emitted, so `onStagedFilesChange()` in both modals is dead code and "uploading" does not block submit; decide whether to wire it or delete it.
- The file keys (`maxFiles`, `maxSize`, `fileFormat`, `duplicated`) of `FormUtils.getTextError` and `FileValidationService.getMaxFilesMessage` will have no attachment caller after this change; remove them in a refactor change.
