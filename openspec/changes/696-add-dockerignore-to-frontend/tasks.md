## 1. Implementation

- [x] 1.1 Finalize `ERAS-FE/.dockerignore` (start from the existing draft; add `.husky`, `.claude`, editor folders, logs; end the file with a newline)
- [x] 1.2 Confirm `src`, `public`, `angular.json`, `package.json`, `package-lock.json` and `tsconfig*.json` are not excluded

## 2. Verification

- [x] 2.1 Run `docker build -f ERAS-FE/dockerfile ERAS-FE` and confirm it succeeds and the context is smaller than before
- [x] 2.2 `openspec validate 696-add-dockerignore-to-frontend --strict` passes

No ACs and no tests: a `.dockerignore` has no behavior to test (proposal A1), so there is no Traceability table.
