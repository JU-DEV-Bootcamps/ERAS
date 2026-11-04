# ADR-0006: Show the imported identifier as the student's SIS ID

**Status:** Accepted
**Date:** 2026-11-02
**Area:** data
**Change:** 641-align-student-modal-fields
**Reviewed by:** LuFeBeVi (2026-11-04)
**Signed by:** LuFeBeVi (2026-11-04)

## Context

A student's SIS ID lives in two places. The import stores it on the student: `StudentMapper` copies the imported
`SISId` into `Student.Uuid` (`ERAS-BE/src/Eras.Application/Mappers/StudentMapper.cs`), which is why the Students
list and the import and export flows already work with it. The student profile has its own optional column,
`StudentProfile.SisId`, that only the profile summary reads. A student registered by hand gets a random GUID in
`Student.Uuid` (`CreateManualStudentCommandHandler`), which is an internal identifier, not a SIS ID. Showing the
profile column alone leaves every imported student without a SIS ID; showing `Uuid` alone would show a GUID for
registered students. The profile response (`GET api/v1/students/{id}/profile`) must return one value for the field.

## Decision

The SIS ID of a student is the identifier the import stored on the student (`Student.Uuid`) when the student is
imported (`Student.IsImported`), and `StudentProfile.SisId` when the student was registered by hand. When neither
exists there is no SIS ID. The identifier ERAS generates for a registered student is never returned as a SIS ID.
The rule lives in one place, the mapper that builds the profile response, and no new identifier column is added.

## Alternatives

- Read only `StudentProfile.SisId` → imported students, the large majority, would show no SIS ID, and the value would be a second copy of data the import already holds.
- Read only `Student.Uuid` → students registered by hand would show a generated GUID as their SIS ID.
- Copy `Student.Uuid` into `StudentProfile.SisId` with a migration → two sources to keep in sync and a data migration the ticket does not ask for.

## Consequences

- One rule for every screen that shows a SIS ID; the profile response needs no new field, its `SisId` carries the resolved value.
- A client that sends the response back in an update must not write the imported value into the profile; the update keeps the stored profile SIS ID unless the request carries one (change 641, design D3).
- `StudentProfile.SisId` stays as the SIS ID of students registered by hand. Any later migration of this data must keep the two sources distinct or supersede this ADR.
