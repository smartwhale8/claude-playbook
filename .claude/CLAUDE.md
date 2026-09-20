# Project Instructions

<!--
  STARTER TEMPLATE. Replace every line below with facts about your project.

  Keep this file under 200 lines. Claude reads it at the start of every session,
  so everything here costs tokens in every conversation, including ones where it
  is irrelevant. Anthropic's guidance: a file that is too long gets ignored.

  The test for each line: would removing it cause Claude to make a mistake?
  If not, cut it.

  Include: commands Claude cannot guess, conventions that differ from the
  language default, architectural decisions not visible in the code, and gotchas.

  Exclude: anything Claude can learn by reading the code, standard conventions,
  file-by-file descriptions, and API documentation. Link to docs instead.

  Run /init to generate a first draft from your codebase, then cut it down.
  Run /doctor and Claude will propose cuts for content it can derive from code.
  Run /context to confirm this file actually loaded.

  These HTML comments are stripped before the file enters Claude's context,
  so they cost nothing.
-->

## Commands

<!-- The /verify skill runs these. Get them right and verification works. -->

- Build: `npm run build`
- Test: `npm test`
- Single test: `npm test -- --grep "test name"`
- Lint: `npm run lint -- --fix`
- Type check: `npm run typecheck`

## Code style

<!-- Only what differs from the language default. -->

- ES modules, never CommonJS
- Named exports, not default exports
- TypeScript strict mode is on

## Architecture

<!-- Decisions that the code does not state for itself. -->

- API routes in `src/api/`, business logic in `src/services/`, data access in `src/repositories/`
- Shared types in `src/types/`
- The repository layer owns all database access. Services never query directly.

## Workflow

- Feature branches only. Never commit to `main`.
- Run lint and tests before committing.

## Gotchas

<!-- The things that waste a session when nobody wrote them down. -->

- The test database resets between runs. Do not rely on seed data.
- Frontend environment variables need the `VITE_` prefix or they are not exposed.

## Compact instructions

When compacting, preserve the full list of modified files and the test commands that were run.
