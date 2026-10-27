<!--
TEMPLATE for the report /sdd-implement gives the user when it pauses or finishes. Short, honest, real numbers.
Only report what you observed. Say plainly what failed, what was skipped and what was not verified.
Delete this comment.
-->

## Implementation: <change-id>

**Progress:** <done>/<total> tasks · **Stopped because:** <all done | blocked on task X: reason | user asked to stop>

### Done this session
- [x] <n.m> <task> → test `<name>` failed first, then passed

### Test-first evidence
| AC | Side | Test | Failed first (why) | Passes now |
|---|---|---|---|---|
| AC-1 | BE | `<Class> › <Method>` | <assertion that was missing> | yes |
| AC-2 | BE | `<Class> › <Method>` | guard test: passed at once; fails when <condition> is removed (checked) | yes |

### Gates (AGENTS.md section 8.7)
| Gate | Command | Result |
|---|---|---|
| BE build | `dotnet build Eras.sln -warnaserror` | <pass / fail: output> |
| BE format | `dotnet format Eras.sln --verify-no-changes` | <…> |
| BE tests | `dotnet test Eras.sln` | <passed/failed/skipped counts per project> |
| BE coverage | `--collect:"XPlat Code Coverage"` | <% lines, gate 25%> |
| FE lint | `npm run lint` | <…> |
| FE tests | `npm test -- --watch=false --browsers=ChromeHeadless --code-coverage` | <counts, % lines, gate 15%> |
| FE build | `npm run build` | <…> |
| Traceability | `check-impl.sh <change-id> --final` | <errors/warnings> |
| OpenSpec | `openspec validate <change-id> --strict` | <…> |

### Not verified / skipped
- <what was not run or could not be run, and why>

### Out of scope noticed
- <finding> → added to `design.md` Follow-ups

### Ready to commit (not committed)
| Repo | Branch | Message | `git add` |
|---|---|---|---|
| `ERAS-BE/` | `<prefix>/<story>/<title>` | `feat: <…>` | `<files>` |
| `ERAS-FE/` | `<prefix>/<story>/<title>` | `feat: <…>` | `<files>` |
| parent | `<branch>` | `docs: tick tasks of <change-id>` | `openspec/changes/<change-id>/tasks.md` |

**Next:** `/sdd-validate-impl` (when a BE controller or the FE changed), then `/sdd-verify`.
