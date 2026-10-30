# ADR-0005: Limit a professional's access to students of their assigned assessments

**Status:** Accepted
**Date:** 2026-10-29
**Area:** auth, backend
**Change:** 643-add-student-interventions

## Context

Students are an Administrator and Officer area today: `ERAS-BE/src/Eras.Api/Controllers/StudentsController.cs` carries a
class-level `[Authorize(Policy = ErasPolicies.AdminOrOfficer)]`, and the FE route `STUDENTS` lists the same two roles.
An `ERAS Professional` must now open the Students list and a student's profile, but only for the students they work with.
That relation already exists: `Assessment.AssignedProfessionals` holds the Keycloak subs of the professionals of an
assessment and `Assessment.StudentIds` its students (both array columns, ADR-0002), and `IAssessmentRepository.GetByAssignedProfessionalAsync`
already limits which assessments a professional sees.
Several `[Authorize]` attributes on one controller are combined with AND, so an action cannot loosen the class policy.
`Eras.Error` has no 403 exception (`BussinessException(message, statusCode)` is the nearest), and `ErrorFilter` turns an `ErasException`
into its status code. Authorization of an endpoint belongs to `ErasPolicies`, ownership and scope rules to the handler (AGENTS.md §6.2).

## Decision

A professional's access to students is limited to the students of the assessments whose `AssignedProfessionals` contains their
Keycloak sub; `ERAS Administrator` and `ERAS Student Services Officer` are not limited and `ERAS Guest` is denied.
The rule lives in one Application-layer resolver that every Professional-scoped student handler uses (the students list, the student
profile and the student-intervention handlers), never in a controller or in the repository. A violation is a `BussinessException`
with status 403.
`StudentsController` is guarded at class level with `AnyErasRole` and each action declares its own policy: `AdminOrOfficer` everywhere
except the students list and the student profile read. A test reads the attributes by reflection and fails when an action
declares no policy of its own, so a new action cannot become open to professionals by omission.

## Alternatives

- Separate professional-only read endpoints (for example `students/assigned`) → duplicates the list and profile logic and forces the FE service and components to pick an endpoint by role.
- Filter only in the FE → not a security boundary; the API would still return every student.
- A global EF query filter by the current user → hides rows from administrators, jobs and migrations, and ties persistence to the HTTP user.
- Keep the class policy as it is and open only new routes → the profile and list the Interventions section needs stay unreachable to professionals.

## Consequences

- One resolver to reuse for any later Professional-scoped student endpoint, and one rule to change if "assigned" ever means something else.
- The class-level policy is no longer the Students safety net: every new `StudentsController` action must state its policy, and the reflection test enforces it.
- The student ids come from array columns (ADR-0002), so the lookup flattens `StudentIds` of the professional's assessments; a student's soft delete still hides it because the ids are resolved through the filtered `Students` set.
- Reassigning an intervention to a professional (change 635) adds them to the assessment and so grants them its students.
- Existence is checked before scope: an unknown student answers 404 and an existing student outside the professional's assessments answers 403.
