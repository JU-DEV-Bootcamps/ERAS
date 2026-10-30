# Proposal

**Status:** Approved
**Plan:** Approved

## Why

Users have no way inside ERAS to find the user manuals and must ask someone for them. A page that lists the current manuals and lets any signed-in user download them removes that dependency. The manuals are maintained as files in the repository, reviewed by developers, so no upload process is needed. Issue: ERAS#640

## What Changes

- Add a "User Manuals" item to the sidebar, visible to every signed-in user, Guest included.
- Add a "User Manuals" page that lists the manuals (title, language, version, format) and lets the user download each one under the file name declared for it.
- Add two read-only backend endpoints, open to any signed-in user: list the manuals and download one. They read the manuals declared in a manifest file next to the manuals in the repository, from a configurable location.
- Manage manuals as code: a manuals folder with a manifest that declares each manual (identifier, title, language, version, file name, format). Only developers change it, through a reviewed pull request (review rule on the folder).
- Validate the manuals folder in the pipeline of every pull request (file present, declared, right type by content, size limit).
- No write endpoints for manuals; the entity type "Manuals" stays unregistered for the generic attachments and the generic attachment service is not modified.
- **Replaces** the earlier design of this change, which stored manuals as attachments of a "Manuals" entity type uploaded by a separate ticket.

**Out of scope:** creating or editing manual content; an upload flow of any kind; previewing manuals in the browser; draft/published status and editor-only visibility; scanning PDF and ODT for active content (scripts, macros, actions), which becomes a separate task after the signature and size validation; HTTP caching with a content-hash validator (can follow later because files are static per version); changes to the generic attachments feature.

## Capabilities

### New Capabilities
- `user-manuals`: listing the repository-managed user manuals and downloading each one from a dedicated page reachable from the sidebar, and the controls that keep the manuals read-only and valid.

### Modified Capabilities

## Impact

- **Submodules:** BE + FE, plus the parent repository, which holds the manuals folder, its manifest, its review rule and the pipeline job that validates it.
- **Roles / who can do what:** every signed-in user, including Guest (no ERAS role), may see the sidebar item, list the manuals and download them; an unsigned request gets 401. Nobody can create, change or delete a manual through the API. Changing a manual needs developer review in a pull request. No existing permission changes.
- **API contract:** two read-only endpoints (list manuals, download a manual); BE DTO, FE model and FE service move together (details go to design.md). `design.md` is required (BE + FE, API contract, auth, infra/CI) and the earlier one must be rewritten.
- **Data / migration:** none. Manuals are files, not rows.
- **Earlier work to rework:** the implementation made for the attachment-based design (manuals read from attachment rows, a repository method by entity type, an entity-type constant) no longer matches this design. The plan decides what stays; the decision to read manuals from repository files is recorded in ADR-0004.

## Assumptions
- A1: Guest is the narrowest case: an endpoint that only requires a signed-in user also admits Administrator, Student Services Officer and Professional, so Guest scenarios stand for all four.
- A2: The list is alphabetical by title, decided by the API (kept from the first version of this change); the page shows it in the order received.
- A3: Language and version are shown as declared in the manifest; their allowed values are not restricted by this change.
- A4: The empty-state message is kept even though the list is normally not empty.
- A5: Pipeline validation of the manuals folder is delivered as automated tests in the backend test suite that read the folder through a configurable location; the parent repository pipeline runs them with the submodules checked out, and they are skipped when the folder is not there (backend-only pipeline). Hence `**Side:** BE` for AC-17 to AC-21.
- A6: The signature check is the content check required by AC-18 (a PDF starts with the PDF signature, an ODT is a zip whose mimetype entry is the ODT type); deeper active-content analysis is out of scope.
- A7: The two manuals available at the start are one PDF and one .odt; their real titles, languages and versions are decided when the files are added, not in this spec.

## Clarifications

### Session 2026-10-29

- Q: Who sees the sidebar item and the page? → A: any signed-in user, Guest included (AC-2 changed, AC-3 removed)
- Q: Static FE files or API download? → A: API, because static files are public by URL (AC-8 to AC-12 added)
- Q: Where do title and description come from? → A: superseded by the reopening below

### Session 2026-10-29 (after reopening)

- Q: Where does the manuals folder live? → A: the parent ERAS repository, with its review rule and pipeline (AC-20 changed)
- Q: Maximum size of a manual file? → A: 10 MB, as the current attachment limit (AC-19 changed)
- Q: How are AC-17 to AC-21 tested if the folder is in the parent repository? → A: xUnit tests in the backend suite reading the folder by a configurable location, run by the parent pipeline (A5 changed)
- Status after this session: Clarified

### Reopened 2026-10-29

- The spec was reopened by the user to absorb a draft that manages manuals as repository files with a manifest. Changed: AC-4 (title, language, version, format; no date or size), AC-6, AC-7 (file name declared for the manual), AC-9, AC-10, AC-12 (undeclared id instead of a non-manual attachment). Added: AC-13 to AC-21. Unchanged: AC-1, AC-2, AC-5, AC-8, AC-11. `**Plan:**` reset to Draft because the plan and the implemented attachment-based code no longer match.

## Validation log

### 2026-10-29 – Round 1 (obsolete: spec reopened, redo after the rework)

**Prerequisite:** the upload ticket is not done, so `"Manuals"` is not registered for upload. For the rows that need data (AC-4, 6, 7, 9, 10, 12), seed two attachment rows with entity type `Manuals` (one PDF, one .odt) and their files in the uploads folder of the local stack, plus one attachment of another entity type (for example an intervention file) for AC-12. Start the stack as in AGENTS.md §3.4.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1 | Sign in as `ERAS Professional`, select "User Manuals" in the sidebar | The User Manuals page opens at `/user-manuals` and the sidebar item is highlighted; the other items keep their order and highlight | | |
| AC-1 | Repeat as `ERAS Administrator` and `ERAS Student Services Officer`; go to Home and back with the browser Back button | Item visible and active only on its page; navigation to and from other sections works | | |
| AC-2 | Sign in as a user with no ERAS role (Guest) | "User Manuals" is shown in the sidebar and opens the page; Guest sees no other new items | | |
| AC-4 | With the 2 manuals seeded, open the page | Both manuals listed in alphabetical order, each with title (file name without extension), last updated date, format (PDF / ODT) and size | | |
| AC-5 | Remove the seeded manual rows (or use a clean database), open the page | Empty-state message "No user manuals are available yet." and no list items | | |
| AC-6 | Click download on the PDF manual | The PDF downloads with its original file name and opens without errors | | |
| AC-7 | Click download on the .odt manual | The .odt downloads with its original file name and opens without errors | | |
| AC-8 | Call `GET api/v1/user-manuals` without a token (for example in Swagger or curl) | 401 Unauthorized, no manual data | | |
| AC-9 | Call the same endpoint with a Guest token | 200 OK, manuals ordered by title, each with title, last updated date, format and size | | |
| AC-10 | Call `GET api/v1/user-manuals/{id}/download` with a Guest token for a seeded manual | 200 OK with the file under its original name | | |
| AC-11 | Call the download endpoint without a token | 401 Unauthorized, no file content | | |
| AC-12 | Call the download endpoint with the id of the non-manual attachment | 404 Not Found, no file content; the same file still downloads through the attachments endpoint for its own roles | | |
| Errors | Stop the backend and open the page; expire the session and download | The page shows the load error message without breaking the layout; an expired session is sent to sign-in | | |
| Side effects | Open Home, Students, Assessments (with their roles) and upload/download an intervention attachment | Existing sidebar items, route access and intervention attachments behave as before | | |
| Views | Open the page at phone and tablet width | List and download buttons stay usable | | |

### 2026-10-29 – Round 2

**How to run:** start the stack of AGENTS.md §3.4 (`docker compose up --build`), which mounts the repository `manuals/` folder read-only into the backend. To run the backend alone, set `UserManuals__Path` to the full path of the `manuals/` folder. The pull-request workflow, compose mounts and deploy copy step are checked by a human, see *Human-only verification* below.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-1 | Sign in as `ERAS Professional`, select "User Manuals" in the sidebar; repeat as `ERAS Administrator` and `ERAS Student Services Officer` | The page opens at `/user-manuals` and the sidebar item is highlighted; other items keep their order and highlight | ✅ | |
| AC-2 | Sign in as a user with no ERAS role (Guest) | "User Manuals" is shown in the sidebar and opens the page; Guest sees no other new item | ✅ | |
| AC-4 | Open the page | Both manuals are listed in alphabetical order, each with title "Manual de usuario ERAS v2", language `es`, version `1.0` and format (PDF / ODT); no size or date shown | ✅ | |
| AC-5 | Point `UserManuals__Path` to a folder whose manifest has `"manuals": []` and open the page | Empty-state message and no list items | ✅ | |
| AC-13 | Stop the backend (or break the manifest) and open the page | An error message is shown, not a blank page and not the empty state | ✅ | |
| AC-6 | Click download on the PDF manual | `manual-de-usuario-eras-v2.pdf` is downloaded and opens without errors | ✅ | |
| AC-7 | Click download on the .odt manual | `manual-de-usuario-eras-v2.odt` is downloaded and opens without errors | ✅ | |
| AC-8 | `GET api/v1/manuals` without a token | 401 Unauthorized, no manual data | ✅ | |
| AC-9 | `GET api/v1/manuals` with a Guest token | 200 OK, two items ordered by title, each with id, title, language, version, file name and format | ✅ | |
| AC-10 | `GET api/v1/manuals/manual-de-usuario-eras-v2-pdf/download` with a Guest token | 200 OK, `Content-Type: application/pdf`, `Content-Disposition: attachment` with the declared file name | ✅ | |
| AC-14 | `GET api/v1/manuals/manual-de-usuario-eras-v2-odt/download` with an `ERAS Professional` token | 200 OK, `Content-Type: application/vnd.oasis.opendocument.text`, attachment with the declared file name | ✅ | |
| AC-11 | Download without a token | 401 Unauthorized, no file content | ✅ | |
| AC-12 | Download with the id `does-not-exist` and with an id containing `..` | 404 Not Found, no file content | ✅ | |
| AC-15 | Send POST, PUT, PATCH and DELETE to `api/v1/manuals` and to a download address | 405 Method Not Allowed each time; nothing changes in `manuals/` | ✅ | |
| AC-16 | `POST api/v1/attachments?EntityType=Manuals&EntityId=1` with a small PDF as an `ERAS Administrator` | 400 Bad Request; nothing is stored | ✅ | |
| Errors | Expire the session and click download; remove a file from `manuals/` while the manifest still declares it and open the download | Expired session goes to sign-in; the missing file gives a server error, not file content | ✅ | |
| Side effects | Open Home, Students, Assessments with their roles; upload and download an intervention attachment | Existing sidebar items, route access and intervention attachments behave as before | ✅ | |
| Views | Open the page at phone and tablet width | List and download buttons stay usable | n.a. | This app will not use in phone and tablets|

- **Views row:** skipped (n.a.) by the developer: ERAS has no mobile or tablet version. The developer made an observation about it that is not an error and will be discussed later.
- **Infra and deploy:** the workflow, compose mounts and deploy copy step are implemented but are not tasks; the developer verifies them as listed below.

### Human-only verification

Not testable by the agent; the developer checks these (the first three before the ship PR merges, the rest after the deploy):

- [ ] "Validate user manuals" is green on the ship PR, and runs the UserManuals tests (not zero) once the `ERAS-BE` pointer is bumped; the pointer-bump commit triggers it. Check that `submodules: recursive` works with the default token.
- [ ] `docker compose config` shows `./manuals` mounted read-only at `/app/manuals` in the backend (`docker-compose.yml`, `docker-compose.local.yml`); `deploy/compose.prod.yml` mounts `/home/ubuntu/eras-manuals`.
- [ ] The `@JU-DEV-Bootcamps/eras` team has write access to the repository (CODEOWNERS).
- [ ] The host folder `/home/ubuntu/eras-manuals` is confirmed with the deploy owners.
- [ ] After the deploy: `stage_deploy_runner.yml` copied `manuals/` to `~/eras-manuals` on each host.
- [ ] After the deploy: `~/app/docker-compose.yml` on each host was edited by hand with `/home/ubuntu/eras-manuals:/app/manuals:ro` (the deploy workflow does not deliver the compose file), and the page lists both manuals.
- Approved by Judith Paco, 2026-10-29

- Verified 2026-10-29: no gaps, no drift, gates green (infra and deploy checks are human-only, see Human-only verification)
