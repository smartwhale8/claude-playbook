# Testing

<!-- Core rule. Loads in every session. Added 2026-02-15, trimmed 2026-09-20. -->
<!-- Why this rule exists: a test Claude can run is what closes the verification loop. -->
<!-- These are the habits that keep that loop trustworthy. -->

## What must have a test

- A bug fix includes a regression test that fails before the fix and passes after it. Write it first.
- A new feature covers the happy path and the error paths that a user can actually reach.
- Refactoring changes no test expectations. If a test has to change, the behaviour changed, and that is a different task.

## Never weaken a test to make it pass

- Do not skip, delete, mark as expected-failure, loosen an assertion, or add a retry to get a green run.
- A failing test is information. Report it and fix the cause.
- Flaky tests are bugs. Fix the nondeterminism rather than retrying around it.

## Reliability

- Tests are independent and run in any order. Each creates its own data and cleans up after itself.
- No sleeps. Poll, await a condition, or use fake timers.
- Test names state the behaviour: `returns_404_when_user_not_found`, not `test_get_user`.
