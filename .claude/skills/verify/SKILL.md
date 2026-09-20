---
name: verify
description: Prove that a change actually works by running the project's checks and reporting the evidence. Use after implementing anything, when the user asks whether a change works, or before declaring a task done.
argument-hint: "[optional: what to verify]"
allowed-tools: Bash, Read, Grep, Glob
---

# Verify the change

What to verify, if the user said: $ARGUMENTS

Claude stops when the work looks done. "Looks done" is not evidence. This skill produces evidence.

## Run the checks

Run each command the project defines, in this order, and stop at the first failure to fix it before continuing. The commands come from `.claude/CLAUDE.md`. If they are not recorded there, find them in `package.json`, `Makefile`, `pyproject.toml`, or the CI workflow, and then add them to `CLAUDE.md` so the next session does not repeat this search.

1. **Type check.** The compiler catches what the tests miss.
2. **Lint.** Never suppress a rule to get a pass.
3. **Tests.** The full suite, not only the file you touched. A change that passes its own test and breaks two others is not done.
4. **Build.** The build succeeding is a separate fact from the tests passing.

## Behavioural check

Running the suite proves the tests pass. It does not prove the change does what was asked. Add one check that exercises the actual behaviour:

- An API change: call the endpoint and show the request and the response.
- A UI change: run the app, take a screenshot, and compare it with what was asked for.
- A command-line change: run the command and show its output.
- A data change: query the result and show the rows.

## Report

State the outcome first: verified, or not verified.

Then the evidence, as a short table of each command and its result, followed by the output of anything that failed.

Rules for this report:

- Paste what the commands returned. Never summarize a pass you did not see.
- A skipped check is reported as skipped, with the reason. Never as a pass.
- If the suite was already failing before this change, say so and name the failures that are pre-existing.
- Do not claim success while any check is red.
