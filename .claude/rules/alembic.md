# Alembic Migration Best Practices

Standards for managing database schema changes with Alembic.

## Migration Creation

- One migration per logical change — don't bundle "add users table" + "rename posts column" in a single migration
- Auto-generate migrations with `alembic revision --autogenerate -m "description"`, then review and edit the output — never trust autogenerate blindly
- Migration message should describe what changed: `"add email_verified column to users"` — not `"update"` or `"migration_003"`
- Always implement both `upgrade()` and `downgrade()` — every migration must be reversible

## Idempotent Operations

- Use `IF NOT EXISTS` / `IF EXISTS` guards for safety:
  ```python
  op.execute("CREATE INDEX IF NOT EXISTS ix_users_email ON users (email)")
  op.execute("DROP INDEX IF EXISTS ix_users_email")
  ```
- For column additions, check existence before adding:
  ```python
  conn = op.get_bind()
  inspector = inspect(conn)
  columns = [c["name"] for c in inspector.get_columns("users")]
  if "new_column" not in columns:
      op.add_column("users", sa.Column("new_column", sa.String(100)))
  ```
- This prevents failures when running migrations against databases in unknown states

## Migration Safety

- Never modify a migration that has been applied to shared environments (staging, production) — create a new migration instead
- Never delete migration files — the migration chain must remain intact
- Test both directions: run `upgrade 
`, then `downgrade -1`, then `upgrade head` to verify reversibility
- Data migrations: if a schema change requires data transformation, do it in the same migration — don't leave the database inconsistent between migrations

## Dangerous Operations

These require extra care:

- **Dropping columns/tables**: Back up data first. Use `IF EXISTS`. Consider two-phase: deprecate, migrate data, then drop
- **Renaming columns**: Use `op.alter_column()` with `new_column_name`, or create new column, migrate data, drop old
- **Changing column types**: May lose data. Add new column, migrate with type conversion, drop old
- **Adding NOT NULL**: Add column as nullable first, backfill data, then alter to NOT NULL
- **Adding unique constraints**: Verify no duplicates exist before adding, or the migration fails

## Organization

- Migration files live in `alembic/versions/` — never move them elsewhere
- Keep `env.py` clean: it imports all models for autogenerate discovery and configures the database connection
- Model discovery: all models must be imported in the models `__init__.py` so Alembic sees them via `Base.metadata`
- Database URL should come from environment variables via config, not hardcoded in `alembic.ini`

## Workflow

```bash
# 1. Make model changes in code
# 2. Generate migration
alembic revision --autogenerate -m "add email_verified to users"
# 3. Review the generated migration — edit if needed
# 4. Test upgrade
alembic upgrade head
# 5. Test downgrade
alembic downgrade -1
# 6. Upgrade again to confirm
alembic upgrade head
# 7. Commit both model changes and migration together
```

## Common Pitfalls

- **Missing model imports**: Autogenerate produces empty migrations if models aren't imported in `env.py` — verify your model registry
- **Enum changes**: Alembic doesn't auto-detect enum value additions — add them manually with `ALTER TYPE ... ADD VALUE`
- **Index names**: Always name indexes explicitly — auto-generated names vary across databases and can conflict
- **Foreign key ordering**: Create referenced tables before referencing tables; in downgrade, drop in reverse order
- **Concurrent migrations**: Never run migrations concurrently — use a migration lock or deploy process that ensures single execution
