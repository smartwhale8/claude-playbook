# Code Quality

<!-- Core rule. Loads in every session. Added 2026-02-15, trimmed 2026-09-20. -->
<!-- Why this rule exists: Claude will accept a workaround if nothing tells it not to. -->

## Fix the cause, not the symptom

- Before writing a fix, state what the root cause is. If you cannot name it, keep investigating.
- Reject fixes that suppress a warning, swallow an exception, add a flag to skip a broken path, or wrap the problem.
- When the proper fix is larger, say why it is the right one and do it. Never present a workaround as an option.

## Delete dead code

- Remove unused functions, classes, imports, variables, and commented-out blocks as you find them.
- When removing a feature, delete every trace: the implementation, re-exports, stubs, and the comments about it.
- Version control is the safety net. Nothing is kept "just in case".

## Do what was asked and stop

- Change what was requested and what is clearly necessary for it to work. Nothing else.
- No error handling for states that cannot occur, no validation on internal-only paths, no helper for a single call site.
- Three similar lines beat a premature abstraction. Abstract on the third real case, not the first.
