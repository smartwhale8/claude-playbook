# Testing

Standards for writing and maintaining tests.

## Test Requirements

- New features must include tests for the happy path and critical error paths
- Bug fixes must include a regression test that reproduces the bug before the fix
- Refactoring must not break existing tests — if tests need updating, that's part of the refactoring
- Tests are code — they deserve the same quality standards: clear naming, no duplication, proper structure

## Test Types

- **Unit tests**: Test individual functions/methods in isolation. Mock external dependencies (database, APIs, file system). Fast — run in milliseconds.
- **Integration tests**: Test modules working together with real dependencies (test database, test server). Verify API contracts, database queries, auth flows.
- **End-to-end tests**: Test full user workflows through the UI. Use sparingly — they're slow and brittle. Focus on critical user journeys (signup, core feature, payment).

Prioritize: many unit tests > some integration tests > few E2E tests (testing pyramid).

## Test Structure

Follow Arrange-Act-Assert (AAA) pattern:
```
// Arrange: set up test data and dependencies
// Act: call the function/endpoint being tested
// Assert: verify the expected outcome
```

- One assertion per test (conceptually) — test one behavior, not many
- Test names describe the behavior: `test_returns_404_when_user_not_found` — not `test_get_user` or `test1`
- Group related tests in describe/class blocks by the function or feature they test

## What to Test

- **Business logic**: Validation rules, calculations, state transitions, access control
- **API endpoints**: Request validation (rejects bad input), response format (correct shape), auth (rejects unauthorized), error cases (returns proper error codes)
- **Database operations**: Queries return expected results, constraints prevent invalid data, migrations apply cleanly
- **Edge cases**: Empty inputs, boundary values, concurrent operations, missing optional fields

## What Not to Test

- Framework internals (don't test that the ORM saves to the database — test your query logic)
- Trivial getters/setters with no logic
- Third-party library behavior
- Implementation details that may change — test behavior, not structure

## Test Data

- Each test creates its own data — don't share mutable state between tests
- Use factories or builders for creating test data — don't copy-paste object literals
- Clean up after tests — use transactions or truncation to reset database state
- Never use production data in tests

## Test Reliability

- Tests must be deterministic — same input, same result, every time
- No sleep/delay in tests — use polling, waitFor, or mock timers
- Tests must be independent — runnable in any order, individually or as a suite
- Flaky tests are bugs — fix or delete them, don't add retry logic
