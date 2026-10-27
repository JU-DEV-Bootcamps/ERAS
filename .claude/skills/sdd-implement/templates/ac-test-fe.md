<!--
TEMPLATE for one frontend AC test (Jasmine/Karma, AGENTS.md section 7.3). Copy the skeleton, rename, fill.
Rules:
- ONE it() per AC for the FE side. The AC key goes FIRST in the title, in square brackets, exactly: [<change-id>/AC-<n>].
- The spec file sits next to the unit as <unit>.spec.ts. Helper/edge it()s carry NO AC key.
- Never fit / xit / fdescribe / xdescribe in anything you leave behind.
- Use TestBed, provideHttpClient() + provideHttpClientTesting() / HttpTestingController, jasmine.createSpyObj.
  Never HttpClientModule in tests. Match the neighbouring spec files for setup.
- Run it alone: npm test -- --watch=false --browsers=ChromeHeadless --include="src/app/<path>/<unit>.spec.ts"
Delete this comment in the real file.
-->

```ts
describe('<Unit>', () => {
  it('[<change-id>/AC-<n>] <behavior the user sees, from the scenario>', () => {
    // GIVEN <state, role from the scenario>

    // WHEN <the single action>

    // THEN <what is rendered, called or navigated>
  });
});
```

Failure first: run the spec before implementing and confirm it fails **because the behavior is missing**,
not because of a wrong selector, provider or import. Then implement until it passes.
