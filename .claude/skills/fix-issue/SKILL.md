---
name: fix-issue
description: Resolve a GitHub issue end to end, from reading the issue through to opening a pull request. Use when the user names an issue number to fix.
disable-model-invocation: true
argument-hint: "[issue-number]"
allowed-tools: Bash(gh issue view *), Bash(gh pr create *), Bash(git *), Read, Edit, Write, Grep, Glob
---

# Fix issue $ARGUMENTS

## The issue

!`gh issue view $ARGUMENTS 2>&1 || echo "Could not read issue $ARGUMENTS. Check the number and that gh is authenticated."`

## Workflow

1. **Understand.** Read the issue above. If the expected behaviour is ambiguous, ask before writing code. A wrong fix costs more than a question.

2. **Reproduce.** Find the failing behaviour in the code. Do not proceed on a theory you have not confirmed.

3. **Plan.** State the root cause and the change you intend, before editing. If the cause is unclear, say so instead of guessing.

4. **Branch.** `git switch -c fix/<short-description>`. Never commit to the default branch.

5. **Test first.** Write a test that fails because of this bug. Run it and watch it fail. A regression test that never failed proves nothing.

6. **Fix.** Address the cause. If the fix spans several files, explain why in the pull request.

7. **Verify.** Run the new test, then the full suite, then lint and type checks. Paste what the commands returned. Never assert success without the output.

8. **Commit and open the pull request.** Reference the issue. The description covers what changed, why, how it was verified, and any risk.

## Rules

- The root cause, never the symptom. If the first idea is a workaround, keep looking.
- Do not change anything the issue did not ask for.
- If the fix turns out to need a decision that is not yours to make, stop and report what you found.
