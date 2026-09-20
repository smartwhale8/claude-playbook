# Git Workflow

<!-- Core rule. Loads in every session. Added 2026-02-15, trimmed 2026-09-20. -->
<!-- Why this rule exists: these are conventions Claude cannot infer from the code. -->
<!-- The guardrail hook blocks force pushes; this covers the conventions. -->

## Commits

- Imperative mood, under 72 characters on the first line: "Add user validation".
- One logical change per commit. A commit compiles and passes tests on its own.
- The body explains why. The diff already shows what.
- Never commit `.env`, credentials, build output, or editor configuration.

## Branches and pull requests

- `main` stays deployable. Work happens on `feature/short-description` or `fix/short-description`.
- Pull requests stay under roughly 400 changed lines. Split anything larger into a sequence that each make sense alone.
- The description states what changed, why, how to test it, and what the risks are.
