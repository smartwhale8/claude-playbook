# Code Quality

These principles are non-negotiable. Evaluate every code change against them before implementation.

## No Dead Code

- Actively remove unused functions, classes, imports, variables, and commented-out code
- Never leave dead code "just in case" — version control is the safety net
- When removing a feature or refactoring, delete all traces: implementations, re-exports, stubs, `# removed` comments
- If a model, function, or variable has zero references, it gets deleted — not commented out, not left with a TODO

## Root-Cause Fixes Only

- Every fix must address the root cause, not the symptom
- Before implementing any fix, ask: **"Is this a workaround or a proper solution?"**
- Reject fixes that: suppress warnings, silence errors with try/except, add flags to skip broken paths, or wrap problems rather than solving them
- If the first solution that comes to mind is a patch — stop, investigate deeper, find the architectural fix

## No Shortcuts

- Follow solid architecture even when the proper fix requires more work
- If the right solution means removing duplicate code, refactoring imports, or restructuring modules — do that work
- Quick hacks compound into unmaintainable systems; always choose the clean path
- Don't add compatibility shims, feature flags for dead paths, or defensive code for impossible states

## Proactive Evaluation

- Before writing any fix, explicitly evaluate: "Is this a bandaid?"
- If yes, reject it and find the proper fix before writing code
- When proposing solutions, present only proper fixes — never offer a "quick workaround" as an option
- If a proper fix is significantly more complex, explain why it's worth the effort — don't default to the easy path

## No Over-Engineering

- Only make changes that are directly requested or clearly necessary
- Don't add features, refactor surrounding code, or make "improvements" beyond what was asked
- Don't add error handling for scenarios that can't happen, or validation for internal-only code paths
- Don't create helpers, utilities, or abstractions for one-time operations
- Three similar lines of code is better than a premature abstraction
- The right amount of complexity is the minimum needed for the current task
