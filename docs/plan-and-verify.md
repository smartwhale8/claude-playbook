# Plan, then build, then verify

Two failures account for most wasted time in agentic coding. Claude solves the
wrong problem, or Claude reports success it did not check. Planning prevents the
first. Verification prevents the second.

## Plan first

Claude stops exploring once it has a plausible approach. If that approach is
wrong, everything after it is wasted, and you find out at review time.

Plan mode separates the two phases. Claude reads and answers, but cannot edit or
run commands, until you approve a plan.

```
Shift+Tab until the status bar shows "⏸ plan mode on"
claude --permission-mode plan          # or start the session in it
```

The sequence:

1. **Explore.** "Read `src/auth/` and explain how sessions and login work today."
2. **Plan.** "I want to add Google OAuth. What changes, in what order, and what
   is the session flow?" Press `Ctrl+G` to open the plan in your editor and
   change it directly.
3. **Implement.** Approve the plan, then let Claude work against it.
4. **Verify.** Below.

Plan mode has a cost, so skip it when you could describe the diff in one
sentence. Use it when the approach is uncertain, the change spans several files,
or you do not know the code being changed.

For anything larger, run `/plan-feature`. It interviews you with
`AskUserQuestion`, asks about the decisions you have not made rather than the
facts it can read, and writes `SPEC.md`. Then start a fresh session pointed at
that file. A clean context reading a good specification beats a long context
that wrote one.

## Give Claude a way to check its own work

Claude stops when the work looks done. Without a check it can run, "looks done"
is the only signal available, and you become the verification loop: every
mistake waits for you to notice it.

Give Claude something that returns pass or fail and the loop closes on its own.

Four levels, in increasing order of how hard they gate the stop:

### 1. In the prompt

Cheapest, works today, on any task.

> Write a `validateEmail` function. Test cases: `user@example.com` is true,
> `invalid` is false, `user@.com` is false. Run the tests after implementing.

Compare with "implement a function that validates email addresses". The second
version has no end condition.

For a UI change, paste a screenshot and ask Claude to screenshot the result and
list the differences.

### 2. The verify skill

Run `/verify` after Claude says it is done. It runs the type check, the linter,
the tests, and the build, adds one behavioural check that exercises the actual
change, and reports the command output rather than a claim.

Its rules are what make it useful: paste what the command returned, report a
skipped check as skipped rather than as a pass, and never claim success while
anything is red.

### 3. A goal

`/goal` sets a completion condition. A separate evaluator model checks it after
every turn, and Claude keeps working until it holds.

```
/goal all tests in test/auth pass and the lint step is clean
```

The evaluator reads the conversation and does not run commands, so write a
condition Claude's own output can demonstrate. "`npm test` exits 0" works
because the result appears in the transcript.

A goal does not change your permission mode. Run it in auto mode for unattended
work. Bound it with a clause such as "or stop after 20 turns".

### 4. A Stop hook

The strongest gate. A script that blocks the turn from ending until it passes.
`.claude/hooks/require-green-tests.sh` is a working one: it runs your suite and,
on failure, returns `decision: "block"` with the output, sending Claude back to
work. Claude Code overrides it after 8 consecutive blocks, so a permanently red
suite cannot trap a session.

It ships unregistered, because running the full suite after every turn is the
wrong trade for most projects. The header comment has the settings block.

## Have a second model check the first

The model that wrote the code is a poor judge of it. A reviewer in a fresh
context sees the diff and your criteria, not the reasoning that produced the
change.

```
Use a subagent to review the rate limiter diff against SPEC.md. Check that every
requirement is implemented, that the listed edge cases have tests, and that
nothing outside the task's scope changed. Report gaps, not style preferences.
```

Or use the components here: the `security-reviewer` agent for vulnerabilities,
`/review` before a commit, `/review-pr` on a pull request.

One caution. A reviewer asked to find gaps will find some, because that is what
it was asked to do. Chasing every finding produces defensive code, extra
abstraction, and tests for cases that cannot happen. Tell the reviewer to report
only what affects correctness or the stated requirements, and treat the rest as
optional.

## Demand evidence

The habit that matters more than any of the above: ask for the output, not the
claim.

"The tests pass" is an assertion. The test runner's output is evidence. Reading
the evidence is faster than re-running the check yourself, and it is the only
thing that works for a session you were not watching.
