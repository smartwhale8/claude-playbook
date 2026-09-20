---
paths:
  - "**/*.{ts,tsx,js,jsx,py,go,rb,java,kt,rs}"
---

# Error Handling

<!-- Path-scoped to source files, so it stays out of sessions spent in docs, -->
<!-- configuration, or data files. Added 2026-02-15, scoped 2026-09-20. -->

## Never swallow an error

- An empty `catch` or bare `except: pass` is never acceptable. It hides a bug rather than handling one.
- Every caught error is re-raised, converted into a user-facing error, or logged with context. Choose one deliberately.
- Log the original error before converting it. The converted message is for the user; the original is for debugging.

## Custom error types

- Define a small set of domain error classes, roughly five to ten. Each maps to one status code and one machine-readable code.
- Handlers raise those types. A central handler converts them into the response envelope.
- Raising a framework-default HTTP exception scatters the response format across the codebase.

## Context

- A logged error records what was attempted, with what input, and in what state.
- Wrap low-level failures in domain language: "Failed to save user profile: database unavailable", not "connection refused".
- Error codes name the cause: `USER_NOT_FOUND`, `PAYMENT_DECLINED`. Never `ERROR` or `FAILED`.

## Boundaries

- Wrap calls to a database, a third-party API, or the filesystem, and handle their specific failures.
- A top-level handler catches what escapes, logs it, and returns a safe response. Aim for nothing reaching it.
