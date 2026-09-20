---
paths:
  - "**/alembic/**/*.py"
  - "**/alembic.ini"
  - "**/migrations/versions/*.py"
---

# Alembic Migrations

<!-- Path-scoped to Alembic files. Before 2026-09-20 this loaded in every session, -->
<!-- including projects with no Python and no database. Delete this file if you do -->
<!-- not use SQLAlchemy. Added 2026-02-15, scoped 2026-09-20. -->

## Generating

- `alembic revision --autogenerate -m "add email_verified to users"`, then read and edit the output. Autogenerate is a draft.
- The message says what changed. Never "update" or "migration_003".
- Implement both `upgrade()` and `downgrade()`.

## Guarding against unknown database states

```python
op.execute("CREATE INDEX IF NOT EXISTS ix_users_email ON users (email)")
```

```python
conn = op.get_bind()
columns = [c["name"] for c in inspect(conn).get_columns("users")]
if "new_column" not in columns:
    op.add_column("users", sa.Column("new_column", sa.String(100)))
```

## Operations that need a plan

| Operation | Safe approach |
|---|---|
| Adding `NOT NULL` | Add the column nullable, backfill it, then alter it to `NOT NULL`. |
| Changing a column type | Add a new column, migrate the values with the conversion, drop the old one. |
| Renaming a column | `op.alter_column(..., new_column_name=...)`, or add, copy, drop across two releases. |
| Dropping a column or table | Back up first. Deprecate, migrate readers off it, then drop in a later release. |
| Adding a unique constraint | Check for duplicates first, otherwise the migration fails on live data. |

## Pitfalls

- Autogenerate produces an empty migration when models are not imported in `env.py`.
- Alembic does not detect new enum values. Add them with `ALTER TYPE ... ADD VALUE`.
- Name indexes explicitly. Generated names differ across databases.
- Create referenced tables before referencing ones, and drop them in the reverse order.
- Never run two migration processes concurrently.

## Workflow

```bash
alembic revision --autogenerate -m "add email_verified to users"
# read and edit the generated file
alembic upgrade head
alembic downgrade -1
alembic upgrade head
# commit the model change and the migration together
```
