# Project Instructions

<!--
  STARTER TEMPLATE — Customize for your project.
  Keep this file SHORT (<80 lines). Only include what Claude can't figure out by reading your code.
  Run /init to auto-generate a version based on your codebase, then refine.
-->

## Commands
<!-- Add your actual build/test/lint commands here -->
- Build: `npm run build`
- Test: `npm test`
- Lint: `npm run lint -- --fix`
- Single test: `npm test -- --grep "test name"`

## Code Style
<!-- Only list conventions that differ from language defaults -->
- Use ES modules (import/export), not CommonJS (require)
- Prefer named exports over default exports
- Use TypeScript strict mode

## Workflow
- Run lint and tests before committing
- Write descriptive commit messages in imperative mood
- Create feature branches, never commit directly to main

## Architecture
<!-- Key decisions Claude can't infer from code alone -->
- API routes live in `src/api/`, business logic in `src/services/`
- Database access through repository pattern in `src/repositories/`
- Shared types in `src/types/`

## Gotchas
<!-- Non-obvious behaviors, environment quirks, common mistakes -->
- The test database resets between runs — don't rely on seed data
- Environment variables must be prefixed with `VITE_` for frontend access
