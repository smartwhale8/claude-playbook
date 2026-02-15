# Git Workflow

Standards for version control, commits, and collaboration.

## Commit Messages

- Write in imperative mood: "Add user validation" — not "Added" or "Adds"
- First line: concise summary under 72 characters — what changed and why
- Body (if needed): explain the reasoning, not the mechanics — the diff shows what changed, the message explains why
- Reference issue/ticket numbers when applicable: `Fix login redirect loop (#123)`
- One logical change per commit — don't bundle unrelated changes

## Commit Granularity

- Each commit should be a single, coherent unit of work that compiles and passes tests
- Don't commit half-finished features — use branches for work in progress
- Don't combine "fix bug" + "add feature" + "refactor" in one commit — separate them
- Small, focused commits are easier to review, revert, and bisect

## Branch Strategy

- `main` is always deployable — never commit directly to main
- Feature branches: `feature/short-description` or `feat/short-description`
- Bug fix branches: `fix/short-description`
- Branches should be short-lived — merge within days, not weeks
- Delete branches after merging — don't accumulate stale branches

## Pull Requests

- PRs should be reviewable in one sitting — aim for under 400 lines changed
- If a change is larger, break it into sequential PRs that each make sense independently
- PR title: concise summary of the change
- PR description: what changed, why, how to test, any risks or trade-offs
- Link related issues/tickets in the description
- Don't merge your own PRs without review (on team projects)

## What Not to Commit

- `.env` files, credentials, secrets, API keys
- Build artifacts, compiled output, `node_modules/`, `__pycache__/`
- IDE/editor config that's personal preference (`.vscode/settings.json`, `.idea/`)
- Large binary files — use Git LFS or external storage
- Generated files that can be reproduced from source (lock files are the exception — commit those)

## Pre-Commit Hygiene

- Run linting and formatting before every commit
- Run relevant tests before pushing
- Ensure the project builds/compiles without errors
- Review your own diff before committing — catch accidental debug code, console.logs, TODOs
