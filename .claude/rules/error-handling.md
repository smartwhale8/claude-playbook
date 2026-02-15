# Error Handling

Rules for consistent, debuggable, user-friendly error handling across the stack.

## Structured Error Responses

- Define a standard error response shape and use it everywhere:
  ```json
  { "success": false, "error": { "code": "VALIDATION_ERROR", "message": "Email is required" } }
  ```
- `code`: machine-readable UPPER_SNAKE_CASE identifier (for programmatic handling)
- `message`: human-readable description (for display or logging)
- Never return plain strings, raw stack traces, or framework-default error pages

## Custom Exception Classes

- Create a small set of custom exception/error classes for your domain (5-10 is usually enough)
- Each maps to an HTTP status code and a machine-readable error code
- Route handlers should raise these custom exceptions — not framework-default HTTP exceptions
- Register centralized exception handlers that convert custom exceptions to the standard error response format
- This ensures every error, regardless of where it's thrown, produces a consistent response

## No Silent Swallowing

- Never use empty `catch` / `except` blocks that discard errors
- Every caught exception must be either: re-raised, converted to a user-facing error, or explicitly logged with context
- `catch (e) { /* ignore */ }` is never acceptable — if you think you need it, you're masking a bug
- Log the original error before converting to a user-friendly message — debugging needs the real cause

## Error Boundaries

- Backend: wrap external calls (database, third-party APIs, file system) in try/catch with specific error handling
- Frontend: wrap async operations in try/catch, display errors to the user, and maintain usable UI state
- Both: unhandled exceptions should be caught by a top-level handler (middleware, error boundary) that logs and returns a generic 500/error screen — but aim for zero unhandled exceptions

## Fail Fast, Fail Loudly

- Validate inputs at system boundaries (API handlers, form submissions) before processing
- Fail on the first error, don't accumulate partial results from invalid input
- In development: surface errors visibly (console, toast, error page) — never hide them
- In production: log errors with full context (request ID, user ID, input data), return safe user-facing messages

## Error Context

- When logging errors, include: what operation was attempted, what input was provided, what state the system was in
- Wrap low-level errors with domain context: instead of "connection refused", return "Failed to save user profile: database unavailable"
- Use error codes that help identify the source: `USER_NOT_FOUND`, `PAYMENT_DECLINED`, `RATE_LIMITED` — not generic `ERROR` or `FAILED`
