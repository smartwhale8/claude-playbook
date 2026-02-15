---
name: review
description: Review all uncommitted changes against project standards before committing
disable-model-invocation: true
---

Review all uncommitted changes in this project. $ARGUMENTS

## Process

1. **Gather changes**: Run `git diff --staged` for staged changes, or `git diff` if nothing is staged. Also check `git status` for new untracked files.

2. **Check each changed file against the project rules** (`.claude/rules/*.md`):

   ### Code Quality
   - Is there dead code, unused imports, or commented-out code?
   - Are there bandaid fixes or workarounds instead of root-cause solutions?
   - Is anything over-engineered for what it needs to do?

   ### Architecture
   - Does this follow existing patterns in the codebase?
   - Is there duplicate logic that should use an existing shared component or utility?
   - Are dependencies pointing in the right direction (inward, not outward)?

   ### Consistency
   - Does the code match the style and structure of similar files in the project?
   - For frontend: are spacing, colors, and component usage consistent with the rest of the UI?
   - For backend: are error handling, response format, and validation patterns consistent?

   ### Reuse
   - Could any new component, function, or pattern already exist in the codebase? Search before approving.
   - If something similar exists, flag it — it should be reused or extracted into a shared utility.

   ### Security
   - Any hardcoded secrets, credentials, or API keys?
   - Is user input validated at the boundary?
   - Are there SQL injection, XSS, or other OWASP risks?

   ### Performance
   - Any N+1 query patterns (database calls inside loops)?
   - Any unbounded queries missing LIMIT/pagination?
   - Frontend: unnecessary re-renders, missing debounce on inputs?

3. **Verdict**: Provide one of:
   - **Ready to commit** — no issues found
   - **Minor issues** — list them, but committing is acceptable after acknowledging
   - **Needs changes** — list specific issues that must be fixed before committing

For each issue, provide: the file, the line(s), what's wrong, and what the fix should be.
