# Proposal

**Status:** Approved
**Plan:** Approved

## Why

When the User Manuals page cannot list or download a manual it always shows the same message, whatever the cause: the manifest is missing, the manifest is invalid, a declared file is missing from the folder, or the manual does not exist. Users, QA and developers cannot tell these failures apart. A developer who adds or changes a manual also has no documented local workflow, and today believes that seeing a change needs `docker compose up` again. Follow-up to #640. Issue: [JU-DEV-Bootcamps/ERAS#687](https://github.com/JU-DEV-Bootcamps/ERAS/issues/687)

## What Changes

- The API answers each manuals failure with its own stable error code (manifest missing, manifest invalid, declared file missing, manual not found), and the response never contains a file path or a stack trace.
- The server log names the manual and the problem for each failure.
- The User Manuals page shows a specific message for each error code, on the list and on the download, and keeps a generic message for any other failure.
- A `manuals/README.md` guides a developer, step by step, to add or change a manual locally without rebuilding (Docker stack or backend outside Docker) and explains each error code of the page. The manuals folder validation treats it as documentation, not as an undeclared file.

**Out of scope:** an admin-only endpoint that returns the folder validator's problems; any change to who can view or download manuals.

## Capabilities

### New Capabilities
- none

### Modified Capabilities
- `user-manuals`: adds the requirements on distinguishable errors (API and page) and on the manuals README; modifies "Manual files are validated on every pull request" so the README is not reported as an undeclared file.

## Impact

- **Submodules:** BE + FE (plus the parent repository for `manuals/README.md`)
- **Roles / who can do what:** no change
- **API contract:** the error responses of `GET api/v1/manuals` and `GET api/v1/manuals/{id}/download` gain an error code; the BE error shape, the FE model and the FE service move together (details go to design.md)
- **Data / migration:** no

## Assumptions
- A1: The three server-side causes (manifest missing, manifest invalid, declared file missing) keep the status 500 they have today; only "manual not found" stays 404. The issue asks for codes, not new statuses.
- A2: A manifest that is not valid JSON is the same cause as a manifest with an invalid entry (empty id, a file name with a path, an unknown format): "manifest invalid".
- A3: The same four codes apply to the list and to the download; "declared file missing" and "manual not found" only occur on a download.
- A4: When the manifest itself is the problem (missing or invalid as a whole) there is no single manual to name, so the log entry names the manifest file and the problem; when one entry or one file is the problem, it names that manual.
- A5: The error code values are `manuals_manifest_missing`, `manuals_manifest_invalid`, `manuals_file_missing` and `manuals_not_found`. The values are a proposal and become the contract between BE and FE once approved.
- A6: The user-visible messages are written for a signed-in user and point to support, not to files; the wording in the ACs is a proposal a reviewer may change.
- A7: The README is checked for the topics the ACs list (numbered steps, manifest fields, supported file types, the 10 MB limit, the read-only mount, when `docker compose up` is needed, `UserManuals__Path`, the validation command, the four error codes), not for exact wording.
- A8: The "Manual files are validated on every pull request" requirement is modified, so its four existing scenarios keep their numbers (AC-17, AC-18, AC-19, AC-21) in this change and their tests are re-tagged to this change (AGENTS.md section 5.2). The new numbers of this change skip them.

## Clarifications

### Session 2026-11-13

- Q: One invalid manifest entry (for example the format "docx"): what happens to the valid manuals? → A: everything fails; the list and every download answer "manifest invalid" (AC-22: added; AC-2, AC-7 unchanged)
- Q: After a failed download, what happens to the message when another manual downloads successfully? → A: the message is cleared (AC-23: added)
- Q: Does the server log also record a manual that is not found (404)? → A: yes, with the requested identifier and the problem (AC-24: added; the log requirement now names the requested identifier)
- Status after this session: Clarified

### Session 2026-11-13 (2)

- Context: some developers did not run `docker compose up` or set `UserManuals__Path`; the README must guide them step by step. Applied directly: the README is numbered steps (AC-13: changed).
- Q: Backend outside Docker without `UserManuals__Path`: what does the README tell? → A: set it as an environment variable and do not commit a personal path in the shared settings file; no code default (AC-13: changed)
- Q: Should the README explain each error code with cause and fix? → A: yes (AC-25: added)
- Status after this session: Clarified

## Validation log

### 2026-11-13 – Round 1

Validation required: the FE page and its service changed, and the BE error responses of the manuals controller changed. Task 3.7 (follow the README) is done in this round.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-13 | Follow `manuals/README.md` step by step on the backend outside Docker: set `UserManuals__Path` to `manuals/`, start the backend, open the User Manuals page | The two manuals are listed; each step of the README worked as written | ❌ | The manual "With the backend outside docker" the command export UserManuals__Path="/path/to/ERAS/manuals" does not work, the term 'export' is not recognized in terminal of Visual Studio. |
| AC-13 | With the Docker stack: edit the `title` of an entry in `manifest.json`, reload the page | The new title shows without `docker compose up` or a rebuild | ❌ | Same above. |
| AC-8 | Unset `UserManuals__Path` (or rename `manifest.json` temporarily), reload the page | "The list of user manuals is not available right now. Please contact support." and no list items | ✅ | |
| AC-1 | Same state as AC-8, call `GET api/v1/manuals` with a token | 500 with body `{ code: "manuals_manifest_missing", message }`; no path and no stack trace | ✅ | |
| AC-9 / AC-2 | Set a `format` of `docx` in `manifest.json`, reload | "The list of user manuals is set up incorrectly. Please contact support."; the response code is `manuals_manifest_invalid` | ❌ | The code is still: "manuals_manifest_missing" |
| AC-22 | Same invalid manifest, try to download the valid manual by its address | Fails with `manuals_manifest_invalid` as well | ❌ | Same as above. |
| AC-10 / AC-3 | Restore the manifest, rename `manual-de-usuario-eras-v2.pdf` temporarily, click download on the PDF | "The file of this manual is not available right now. Please contact support." and nothing is downloaded | ❌ | Same as above. |
| AC-23 | After that error, click download on the .odt manual | The error message disappears and the .odt downloads | ❌ | Same as above. | 
| AC-11 / AC-4 | Call `GET api/v1/manuals/does-not-exist/download` with a token | 404 with code `manuals_not_found`; the page (stale id) shows "This manual no longer exists. Reload the page to see the current manuals." | ❌ | Same as above. | 
| AC-6 / AC-7 / AC-24 | Look at the backend log after the failures above | One entry each, naming the manual (or `manifest.json`), the file and the problem; the 404 names the requested id | ❌ | Same as above. | 
| AC-12 | Stop the backend and open the page | The generic message "Could not load the user manuals. Please try again later." | ✅ | |
| Side effects | Sign in as Guest, Professional and Administrator with a valid folder; list and download both manuals | Works for every role as before; other pages and errors of other endpoints unchanged | ❌ | Same as above. |
| README table | Compare each row of "When the page shows an error" in the README with what you saw | Cause and fix match the real behavior | ❌ | Same as above. |

Round 1 findings (2026-11-13): the README did not let a Visual Studio developer point the backend to `manuals/` (`export` is not recognized in the Visual Studio terminal, and a variable set in a terminal does not reach F5). Without the path the backend answers `manuals_manifest_missing` for every edit, which explains the rows marked "same as above". The developers use the backend from Visual Studio and Docker only for Keycloak and the database. Decision: fix the README (tasks 3.8, 3.9: user-secrets as the main step, Visual Studio note); AC-13 keeps its wording. The developer then tried the README approach and the manuals show. Round 2 repeats the rows still open once 3.8 and 3.9 are done.

### 2026-11-13 – Round 2

Repeats the rows of Round 1 that stayed open. The backend runs from Visual Studio with the path set by the README (user-secrets: `dotnet user-secrets set "UserManuals:Path" "<absolute path of manuals/>" --project ERAS-BE/src/Eras.Api`), Keycloak and the database in Docker, and the FE with `npm start`. Restore `manuals/` as it was after each row. Task 3.7 closes with the first row.

| Ref | Scenario (steps) | Expected result | Result (✅/❌/n.a.) | Notes |
|---|---|---|---|---|
| AC-13 | Follow the section "With the backend outside Docker" of `manuals/README.md` exactly as written, starting with no value set, and open the User Manuals page | Every step works as written; the two manuals are listed | ✅ | |
| AC-13 | Edit the `title` of an entry in `manifest.json`, reload the page without restarting the backend | The new title shows | ✅ | |
| AC-9 / AC-2 | Set a `format` of `docx` in `manifest.json`, reload | "The list of user manuals is set up incorrectly. Please contact support."; the response code is `manuals_manifest_invalid` | ✅ | |
| AC-22 | Same invalid manifest, request the download of the valid manual by its address | Fails with `manuals_manifest_invalid` | ✅ | |
| AC-10 / AC-3 | Restore the manifest, rename `manual-de-usuario-eras-v2.pdf` temporarily, click download on the PDF | "The file of this manual is not available right now. Please contact support."; nothing is downloaded; the response code is `manuals_file_missing` | ✅ | |
| AC-23 | After that error, click download on the .odt manual | The error message disappears and the .odt downloads | ✅ | |
| AC-11 / AC-4 | Request `GET api/v1/manuals/does-not-exist/download` with a token | 404 with code `manuals_not_found` | ✅ | |
| AC-5 | In the responses above, read the body | Only `code` and `message`; no file path, no folder path, no stack trace | ✅ | |
| AC-6 / AC-7 / AC-24 | Read the backend log after the failures above | One entry each: the missing file names the manual and the file; the invalid format names the manual and "format 'docx' is not supported"; the 404 names `does-not-exist` | ✅ | |
| Side effects | Open the page as Guest, Professional and Administrator with a valid folder; list and download both manuals | Works for every role as before; other pages and the errors of other endpoints are unchanged | ✅ | |
| README table | Compare each row of "When the page shows an error" with what you saw | Cause and fix match the real behavior | ✅ | |

Approved by Judith Paco, 2026-11-16.

Verified 2026-11-16: no gaps, no drift, gates green

### 2026-11-17 – Review of ERAS#695

The reviewer found drift between AC-13, `design.md` (D6 and the Infra row) and the README: the README makes user-secrets the main step and the environment variable an alternative. AC-13 and the design now say the same (AC-13 changed in its AND lines; the scenario title and the test are the same), the README wording about the mount was fixed (task 3.10), and `design.md` D1 records why there is no ADR. Status and Plan are back to Draft until a human approves the updated AC-13 and design. The Round 1 row "Docker stack: edit a title, reload, no `docker compose up`" is still without a result and is not repeated in Round 2: it is for the developer to run it, or to mark it n.a.
