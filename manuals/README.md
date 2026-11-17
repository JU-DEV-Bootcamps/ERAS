# User manuals

This folder holds the user manuals that the **User Manuals** page of ERAS lists and downloads. The files are managed in the repository and reviewed like code; the backend only reads them (see `openspec/adr/0004-read-user-manuals-from-repository-files.md`). Nothing here is uploaded through the application.

This `README.md` is documentation, not a manual: the folder validation ignores it.

## Add or change a manual

1. Copy the file into this folder. The type is checked by the file content, not by its extension, and a file larger than 10 MB is rejected.
2. Add or edit its entry in `manifest.json`. A file that no entry declares fails the validation, and so does an entry whose file is missing.
3. Fill in the six fields of the entry:

   | Field | What it is |
   |---|---|
   | `id` | Stable identifier, unique in the manifest. It is used in the download address. |
   | `title` | Name shown on the page. The list is ordered by title. |
   | `language` | Language of the manual, for example `es` or `en`. |
   | `version` | Version of the manual, for example `1.0`. |
   | `fileName` | Plain file name in this folder, with no directory part. |
   | `format` | `pdf` or `odt`. These are the only supported file types. |

4. Validate the folder from the repository root. The same tests run in the pipeline of every pull request that touches this folder:

   ```bash
   dotnet test ERAS-BE/Eras.sln --filter "FullyQualifiedName~UserManuals"
   ```

5. Open a pull request. Any change to this folder needs the review of the owners in `.github/CODEOWNERS`.

One bad entry in `manifest.json` makes the list and every download fail, so run the validation before you push.

## See your change locally

### With the Docker stack

Optional if you only use Docker for Keycloak and the database. The compose files mount this folder in the backend container as read-only (`./manuals:/app/manuals:ro`), so your edits appear without a rebuild: save the file and reload the page.

1. Once, only if your containers were created before the manuals mount existed (it came with the User Manuals page), run `docker compose up --build` from the repository root (or `docker compose -f docker-compose.local.yml up --build`). Until you do, the backend has no `manuals/` folder and the page reports a missing manifest.
2. From then on, `docker compose up` is only needed again after the mount itself changes (a change in a compose file) or when you want new backend code. Adding or editing a manual needs neither it nor a rebuild.

### With the backend outside Docker (Visual Studio or `dotnet run`)

This is the usual way to work: the backend runs from Visual Studio and Docker is only used for Keycloak and the database. The backend reads the folder from the setting `UserManuals:Path`, which is `/app/manuals` by default (the path inside the container). On your machine that folder does not exist, so the page reports a missing manifest until you point the setting to this folder.

A variable set in a terminal, including the terminal inside Visual Studio, does not reach the debugger: Visual Studio starts the backend with its own launch profile. So use user-secrets, which Visual Studio and `dotnet run` both read in Development and which is not versioned:

1. From the repository root, set the path once to the absolute path of this folder:

   ```powershell
   dotnet user-secrets set "UserManuals:Path" "C:\path\to\ERAS\manuals" --project ERAS-BE/src/Eras.Api
   ```

2. Start (or restart) the backend from Visual Studio, or with `dotnet run --project ERAS-BE/src/Eras.Api`, and open the **User Manuals** page or `GET /api/v1/manuals`.
3. Edits to the folder show without restarting the backend. To use another folder, run the command again with the new path and restart the backend.
4. To check or remove the value, run `dotnet user-secrets list --project ERAS-BE/src/Eras.Api` or `dotnet user-secrets remove "UserManuals:Path" --project ERAS-BE/src/Eras.Api`.

Alternative for a run from a shell only: set the environment variable `UserManuals__Path` in that same shell before `dotnet run` (`$env:UserManuals__Path = "C:\path\to\ERAS\manuals"` in PowerShell, `export UserManuals__Path=/path/to/ERAS/manuals` in bash). It does not work for Visual Studio.

Do not commit a personal path. `ERAS-BE/src/Eras.Api/Properties/launchSettings.json` is versioned: if you put the variable there instead, keep that change out of your commits.

## When the page shows an error

The page shows a different message for each cause. The backend log names the manual and the problem (the response never contains a path), so look there for the detail.

| Code | Page says | Probable cause and what to do |
|---|---|---|
| `manuals_manifest_missing` | The list of user manuals is not available right now. | The backend cannot find `manifest.json`: you did not run `docker compose up` after the mount was added, or `UserManuals__Path` is not set or points to the wrong folder. Follow the steps in "See your change locally". |
| `manuals_manifest_invalid` | The list of user manuals is set up incorrectly. | `manifest.json` is not valid JSON, or an entry has an empty id, a `fileName` with a path, or a `format` other than `pdf` or `odt`. Run the validation and fix the entry the log names. |
| `manuals_file_missing` | The file of this manual is not available right now. | The manifest declares a file that is not in this folder. Check the `fileName` and the file name, including upper and lower case, and copy the file in. |
| `manuals_not_found` | This manual no longer exists. | The page asked for an `id` that the manifest does not declare, usually a stale page after a change. Reload the page. |

Any other error message means the failure had no known code, for example a network problem: try again later.
