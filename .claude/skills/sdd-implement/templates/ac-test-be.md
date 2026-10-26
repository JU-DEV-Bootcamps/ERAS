<!--
TEMPLATE for one backend AC test (xUnit, AGENTS.md section 4.2). Copy the skeleton, rename, fill.
Rules:
- ONE test per AC for the BE side, tagged with exactly ONE AC key. Helper/edge tests carry NO AC tag.
- Put it where the AC's behavior is decided: business rule -> test/Eras.Application.Tests/Features/<Feature>/ (handler) or
  test/Eras.Domain.Tests/ (validator/transition); status code or authorization -> test/Eras.Api.Tests/;
  repository/external client/job -> test/Eras.Infrastructure.Tests/.
- Method name: <Unit>_<Condition>_<Expected>, async tests end in Async. Arrange/Act/Assert mirror GIVEN/WHEN/THEN.
- Stack: xUnit, Moq, FluentAssertions, EF InMemory/MockQueryable. Match the neighbouring test files for setup.
- Run it alone: dotnet test Eras.sln --filter "AC=<change-id>/AC-<n>"
Delete this comment in the real file.
-->

```csharp
public class <Handler>Tests
{
    [Fact]
    [Trait("Change", "<change-id>")]
    [Trait("AC", "<change-id>/AC-<n>")]
    public async Task HandleAsync_<Condition>_<Expected>Async()
    {
        // Arrange (GIVEN) <state, actor, role from the scenario>

        // Act (WHEN) <the single action>

        // Assert (THEN / AND) <observable result: status code via BussinessException, persisted or not>
    }
}
```

Failure first: run the test before implementing and confirm it fails **because the behavior is missing**
(assertion or missing member), not because of a typo or a wrong setup. Then implement until it passes.
