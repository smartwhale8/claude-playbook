# Database

Standards for schema design, data access, and migrations.

## Schema Design

- Every table has a primary key — prefer UUIDs for distributed systems, auto-increment integers for simpler apps
- Every table has `created_at` timestamp — most should also have `updated_at`
- Use soft deletes (`deleted_at` timestamp) for user-facing data that may need recovery; hard deletes for transient data
- Foreign keys must specify `ON DELETE` behavior (`CASCADE`, `SET NULL`, `RESTRICT`) — never leave it as the implicit default
- Add `UNIQUE` constraints for natural keys (email, username, relationship pairs like follower+followed)
- Add `CHECK` constraints for business rules enforceable at the DB level (e.g., no self-referencing relationships, positive amounts)
- Add indexes on columns used in `WHERE`, `JOIN`, `ORDER BY` — especially foreign keys and timestamps

## One Model, One Location

- Each database table is defined by exactly one model/schema class in one file
- Other modules that need the model import it from the canonical location — never redefine
- If you find the same table defined in two files, delete the duplicate immediately

## Migrations

- Every schema change goes through a migration — never modify the database manually
- Each migration does one thing — don't bundle unrelated schema changes
- Migrations must be reversible — implement both up and down operations
- Use idempotent operations where possible (`IF NOT EXISTS`, `IF EXISTS`)
- Test both upgrade and downgrade paths before committing
- Never modify a migration that has already been applied to shared environments — create a new migration instead

## Query Patterns

- **No N+1 queries**: Never execute database queries inside a loop over results. Batch-fetch related data with `WHERE id IN (...)` or use eager loading (join/subquery loading)
- **Parameterized queries only**: Never string-interpolate user input into queries — use the ORM's query builder or parameterized statements
- **Select only what you need**: Don't `SELECT *` when you need 3 columns — specify fields to reduce data transfer
- **Paginate everything**: Every list query must have a LIMIT — never return unbounded result sets
- **Use transactions**: Group related writes in a single transaction — don't leave data in an inconsistent state if one write fails

## Connection Management

- Use connection pooling in production — don't open a new connection per request
- Set reasonable pool sizes, timeouts, and max overflow limits
- Implement connection retry logic for transient failures (especially with cloud databases)
- Always close/return connections after use — use context managers or dependency injection to prevent leaks

## Data Integrity

- Enforce constraints at the database level, not just in application code — the database is the last line of defense
- Use transactions for operations that modify multiple tables
- Avoid storing derived data that can be computed — if you must (for performance), document it and keep it synchronized
- Never trust application-level uniqueness checks alone — race conditions exist; use database constraints
