# Architecture

<!-- Core rule. Loads in every session. Added 2026-02-15, trimmed 2026-09-20. -->
<!-- Why this rule exists: Claude builds each piece correctly in isolation and still -->
<!-- drifts from the structure of the codebase around it. This states the structure. -->

## Layers and direction

- Dependencies point inward: routes call services, services call repositories, repositories own the models.
- An inner layer never imports from an outer one. A model does not import from a route.
- Route handlers validate input, call business logic, and format output. Nothing else lives there.
- Data access stays in the repository layer. Queries do not appear in business logic or in UI code.

## One definition of each thing

- Every model, type, constant, and configuration value is defined once and imported from that one place.
- Finding the same type declared in two files means one of them is deleted, not kept in sync.
- Configuration is read from one source through one mechanism.

## Module boundaries

- Group by feature, not by technical layer. A feature directory holds its own routes, services, and models.
- A feature should be deletable without breaking unrelated features.
- Code shared across features lives in a `core/` or `common/` layer that any feature may import.
- When a module's interface changes, update every caller in the same change.
