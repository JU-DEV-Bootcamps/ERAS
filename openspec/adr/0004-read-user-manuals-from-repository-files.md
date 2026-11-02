# ADR-0004: Read user manuals from files managed in the repository

**Status:** Accepted
**Date:** 2026-10-29
**Area:** backend, infra
**Change:** 640-add-user-manuals-page

## Context

ERAS must offer user manuals (a PDF and an .odt for now) for download to every signed-in user. Developers write and update them, and nobody else should. The generic attachment feature
(`ERAS-BE/src/Eras.Application/Services/AttachmentService.cs`, entity types on `AttachmentEntityTypeRegistry`) is built for user uploads, so using it would need an upload flow and a new registered entity type, and its files would not go through code review. Files in the frontend `public/` folder would be served by the web server without sign-in. The parent repository has the review process (pull requests, CODEOWNERS) and the deployment of the stack.

## Decision

We keep manuals as files in a `manuals/` folder at the root of the parent repository, with a `manifest.json` that declares each one (identifier, title, language, version, file name, format). The backend only reads them: it takes the folder from the setting `UserManuals:Path`, serves them through its own read-only endpoints and never through attachments or static frontend files. Changes go through a reviewed pull request, with the folder owned by the developers in CODEOWNERS. The pipeline of every such pull request validates the folder (file present, declared, right type by content, size limit). The same approach applies to other read-only, developer-maintained reference files.

## Alternatives

- Store manuals as attachments of a "Manuals" entity type → needs an upload flow and a registry change, and the files are not reviewed as code.
- Put the files in the frontend static assets → downloadable without signing in, and every update redeploys the frontend.
- Store the files in the database → a migration and large binary rows for a handful of static documents.

## Consequences

- Manuals are versioned, reviewed and validated like code, and no upload endpoint or attachment change exists.
- The deployment must make the folder available to the backend container (a read-only mount plus a copy to the host in production); until then the list is empty.
- The validation tests live in the backend suite and need a full checkout to run against the real folder, so the parent repository pipeline runs them.
- A malformed manifest breaks the list, so the manifest is checked in the pipeline before merge.
