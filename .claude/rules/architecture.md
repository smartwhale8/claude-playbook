# Architecture

Principles for maintaining a clean, scalable codebase as the project grows.

## Separation of Concerns

- Each module/file has one clear responsibility — if you can't describe what a file does in one sentence, it's doing too much
- Business logic belongs in service/domain layers, not in API route handlers or UI components
- Data access (queries, ORM calls) stays in repository/data layers, not scattered across business logic
- API/route handlers should only: validate input, call business logic, format output
- UI components should only: render state, dispatch actions, handle user interaction

## Dependency Direction

- Dependencies point inward: routes → services → repositories → models
- Inner layers never import from outer layers (models don't import from routes, services don't import from API handlers)
- Shared utilities live in a common/core layer that any layer can import
- If two modules at the same layer need to communicate, extract the shared concern into a lower layer — don't create circular imports

## Single Source of Truth

- Every concept (model, type, constant, configuration) is defined in exactly one place
- Other modules import from the canonical location — never redefine or duplicate
- If you find the same struct/class/type defined in two files, delete one and import from the other
- Configuration comes from one source (environment/config file), accessed through one mechanism

## Module Organization

- Group by feature/domain, not by technical layer — `users/` contains routes, services, models for users, not `routes/` containing all routes for everything
- Shared code that crosses feature boundaries lives in a `core/` or `common/` directory
- Keep feature modules self-contained: a feature should be deletable without cascading failures across unrelated features
- Index/barrel files re-export the public API of a module — internal helpers stay internal

## Interface Boundaries

- Define clear contracts between modules: function signatures, request/response types, error types
- Internal implementation details should not leak through interfaces — callers shouldn't need to know how something works, only what it accepts and returns
- When a module's interface changes, update all callers in the same change — don't leave stale references

## Scaling Decisions

- Choose patterns that work at 10x current scale, not 100x — optimize for known requirements, not hypothetical ones
- Premature optimization is waste; premature abstraction is worse — build concrete implementations first, abstract when you see the pattern repeated
- When in doubt, start simple and refactor later — a working simple solution is always better than an incomplete complex one
