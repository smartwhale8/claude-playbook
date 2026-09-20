---
name: review-pr
description: Review a pull request for correctness, architecture, security, and test coverage. Use when the user names a PR number to review.
disable-model-invocation: true
argument-hint: "[pr-number]"
allowed-tools: Bash(gh pr view *), Bash(gh pr diff *), Bash(gh pr checks *), Read, Grep, Glob
context: fork
agent: code-reviewer
background: false
---

# Review pull request $ARGUMENTS

## The pull request

!`gh pr view $ARGUMENTS 2>&1 || echo "Could not read PR $ARGUMENTS."`

## The diff

!`gh pr diff $ARGUMENTS 2>&1 | head -1500 || true`

## What to check

1. **Intent.** What is this pull request for? Does the diff do that, and only that?

2. **Correctness.** Trace the changed paths. Unhandled edge cases, off-by-one errors, null and undefined paths, race conditions, error paths that cannot be reached.

3. **Fit.** Does the change follow the patterns already in this codebase? Read the neighbouring files rather than assuming. Name any duplication with the path to the original. Are new dependencies justified?

4. **Security.** Input validation at the boundary, parameterized queries, escaped output, authorization checks on new endpoints, no secrets in the diff.

5. **Tests.** Is each new behaviour covered? Does a bug fix carry a regression test? Are the edge cases tested, or only the happy path?

6. **CI.** Check `gh pr checks $ARGUMENTS`. Do not approve over a red build.

## Output

Open with the verdict: approve, approve with comments, or request changes.

Then the findings, ordered by severity. Each one names the file and line, states the problem, and gives the change that resolves it.

Say plainly what you did not check, for example a subsystem you could not reach or a test you could not run. A review that hides its gaps is worse than a short one.
