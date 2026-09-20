---
paths:
  - "**/models/**/*"
  - "**/repositories/**/*"
  - "**/migrations/**/*"
  - "**/db/**/*"
  - "**/*.sql"
  - "**/*{Model,Repository,Entity}.{ts,js,py,go,rb,java,kt}"
---

# Database

<!-- Path-scoped. Loads only when Claude opens a model, repository, migration, -->
<!-- or SQL file. Added 2026-02-15, scoped and trimmed 2026-09-20. -->

## Schema

- Every table has a primary key and a `created_at`. Most need `updated_at`.
- Every foreign key states its `ON DELETE` behaviour explicitly. The implicit default is never the intent.
- Natural keys get a `UNIQUE` constraint. Business rules that the database can check get a `CHECK` constraint.
- Index the columns used in `WHERE`, `JOIN`, and `ORDER BY`, starting with foreign keys and timestamps.
- Constraints live in the database, not only in application code. Application-level uniqueness checks lose races.

## Queries

- **No N+1.** Never query inside a loop over results. Batch with `WHERE id IN (...)` or eager-load the relation.
- Parameterized queries only.
- Select the columns you need. Do not eager-load relations you will not read.
- Every list query has a `LIMIT`.
- Writes that span tables run in one transaction.

## Migrations

- Every schema change is a migration. Nobody edits the database by hand.
- One logical change per migration, with a working reverse.
- Never edit a migration that has run in a shared environment. Write a new one.
- Test the upgrade and the downgrade before committing.
