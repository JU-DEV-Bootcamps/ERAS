# Proposal

**Status:** Approved
**Plan:** Approved

## Why

In Create Intervention, a file that fails validation (unsupported format, too large, duplicated, too many files) or fails to upload is dropped, and the error text is technical ("exceeds 10MB"), so users do not realise the intervention will be saved without that file. After a developer agreement this replaces the original ticket text (block saving): the intervention can still be created, but the user is warned first and decides. Issue: ERAS-FE#605

## What Changes

- On Create, when at least one attachment was rejected or failed to upload, a small confirmation modal (same look as the "Unsaved changes" modal) says the intervention will be created without those files, asks the user to review the errors, and offers "Create anyway" or "Keep editing".
- Every attachment error text becomes friendly English and says what will happen to the file, for example `"report.pdf" exceeds the 10MB limit, so the intervention will be created without it.`
- The friendlier texts live in the shared attachment manager, so the Edit Intervention modal shows them too.
- A failed upload no longer disables the Create button, nor the Save button in Edit.
- When several files are rejected at once, the field lists one message per file.

**Out of scope:** the confirmation modal in Edit Intervention (it saves without asking; its messages already state that the file is not saved); changes to the BE, to allowed formats, size limit or maximum number of files; other attachment users outside interventions.

## Capabilities

### New Capabilities
- `intervention-attachments`: what the user sees and can do when attachments of an intervention are rejected or fail to upload while creating or editing it.

### Modified Capabilities

## Impact

- **Submodules:** FE
- **Roles / who can do what:** no change
- **API contract:** none
- **Data / migration:** no

## Assumptions

- A1: A failed upload is treated like a validation error: the file is not attached, the user is warned and may continue. The original ticket only named validation errors, but the same outcome applies.
- A2: The warning modal appears once per click on Create, not each time a file is rejected; rejected files are listed in the field's error messages, not in the modal.
- A3: "Create anyway" creates the intervention with only the files that uploaded correctly; "Keep editing" returns to the form with its data and files unchanged.
- A4: Messages are shown in English only. Create says "created without it" and Edit says "saved without it"; the quoted wording in the ACs is the proposal and may be polished at review. The same wording applies to the other messages in Edit (e.g. AC-8 to AC-11 say "saved" there).
- A5: When a rejected file is removed or replaced by a valid one, the error message disappears and the modal is no longer shown.

## Clarifications

### Session 2026-11-18

- Q: In Edit, should a failed upload keep blocking Save? → A: No, Save stays enabled and saves without the file, no modal (AC-14: added, AC-11: unchanged)
- Q: What does the field show when several files are rejected at once? → A: One message per file (AC-13: added)
- Q: Wording of the Create modal → A: title "Attachments with errors", buttons "Create anyway" / "Keep editing" (AC-1: changed)
- Status after this session: Clarified
