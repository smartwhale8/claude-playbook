# Security

Non-negotiable security practices. Every code change must be evaluated for security implications.

## Secrets Management

- Never hardcode secrets, API keys, tokens, passwords, or credentials in source code
- Store secrets in environment variables or a secrets manager — never in config files checked into version control
- `.env` files must be in `.gitignore` — provide `.env.example` with placeholder values instead
- Default values for secrets in configuration should be clearly marked as dev-only and must fail loudly in production
- Rotate secrets immediately if they're ever exposed in a commit, log, or error message

## Authentication

- Every mutating endpoint (POST/PATCH/PUT/DELETE) must require authentication
- Use established standards: JWT, OAuth 2.0, session tokens — never homebrew auth
- Tokens must have expiration times — no indefinite sessions
- Store passwords using strong hashing (bcrypt, argon2) with per-user salts — never plain text or reversible encryption
- Implement account lockout or rate limiting on authentication endpoints to prevent brute force

## Authorization

- Authentication (who are you?) and authorization (what can you do?) are separate concerns — implement both
- Check permissions before any data access or mutation — not after
- Use the principle of least privilege: default to no access, explicitly grant permissions
- Authorization checks should be centralized in reusable middleware/dependencies — not inlined differently in every endpoint

## Input Validation (OWASP Top 10)

- **SQL Injection**: Use parameterized queries or ORM query builders exclusively — never string-interpolate user input into queries
- **XSS**: Sanitize user-generated content before rendering in HTML — use framework auto-escaping, don't render raw HTML from user input
- **CSRF**: Use anti-CSRF tokens for cookie-based auth, or use token-based auth (Bearer tokens) which is inherently CSRF-resistant
- **Path Traversal**: Validate file paths, reject `../` sequences, use allowlists for permitted directories
- **Mass Assignment**: Explicitly define which fields are writable — never pass raw request bodies directly to model update methods

## Data Protection

- Encrypt sensitive data at rest (PII, health data, financial data) — not just in transit
- Use HTTPS everywhere — never serve authenticated endpoints over plain HTTP
- Log access to sensitive data for audit trails
- Implement data retention policies — don't store data longer than needed
- Sanitize error responses — never leak internal details (stack traces, SQL queries, file paths) to API consumers

## CORS

- Never use `allow_origins=["*"]` with `allow_credentials=True` in production — this is a security vulnerability
- Whitelist specific origins in production
- Wildcard CORS is acceptable only in local development environments

## Dependency Security

- Keep dependencies updated — outdated packages are the most common attack vector
- Audit dependencies for known vulnerabilities before adding them
- Prefer well-maintained, widely-used packages over obscure alternatives
- Pin dependency versions for reproducible builds
