# Security

<!-- Core rule. Loads in every session. Added 2026-02-15, trimmed 2026-09-20. -->
<!-- Why this rule exists: these are the failures that reach production and cost the -->
<!-- most. The guardrail hook blocks the shell-level cases; this covers the code. -->
<!-- Deeper review belongs to the security-reviewer agent, not to every session. -->

## Secrets

- No credential, key, token, or password in source. Read them from the environment or a secrets manager.
- `.env` is gitignored. Commit `.env.example` with placeholder values.
- A secret that appears in a commit, a log, or an error message is compromised and must be rotated, not just removed.

## Authentication and authorization

- Every mutating endpoint requires authentication. Every data access checks authorization before the read or write, never after.
- Authentication and authorization are separate checks. Being logged in is not permission.
- Authorization lives in shared middleware or dependencies, so it cannot be forgotten on one endpoint.
- Passwords are hashed with bcrypt or argon2. Tokens expire.

## Input handling

- Queries are parameterized. User input is never interpolated into SQL, shell commands, or file paths.
- User-generated content is escaped before rendering. Framework auto-escaping stays on.
- Writable fields are named explicitly. A request body is never passed straight into a model update.
- `allow_origins=["*"]` with credentials enabled is a vulnerability, not a configuration choice.

## What leaves the system

- Error responses carry a code and a message. Never a stack trace, a query, or a file path.
- Sensitive data is encrypted at rest, not only in transit.
