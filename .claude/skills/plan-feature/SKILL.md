---
name: plan-feature
description: Turn a rough feature idea into a written specification by interviewing the user first. Use when the user describes something substantial they want built and the approach is not yet settled.
disable-model-invocation: true
argument-hint: "[what you want to build]"
allowed-tools: Read, Grep, Glob, AskUserQuestion, Write
---

# Plan a feature

The idea: $ARGUMENTS

Claude solving the wrong problem well is the most expensive failure in an agentic session. This skill spends a few minutes preventing it.

## 1. Read before asking

Find how the codebase already does the nearest equivalent thing. Identify the files a change like this would touch and the patterns it should follow. Bring that to the interview, so the questions are about the decisions rather than the facts.

## 2. Interview

Use `AskUserQuestion` to work through what is genuinely undecided. Skip anything you can answer by reading the code.

Cover:

- **Behaviour.** What happens in the normal case, and at each edge the user cares about.
- **Scope.** What is explicitly not part of this.
- **Data.** What is stored, what is derived, what migrates.
- **Interface.** The endpoints, the screens, or the commands involved.
- **Failure.** What happens when the dependency is down, the input is bad, or the operation is repeated.
- **Verification.** What has to be true for this to be finished.

Keep going until the hard parts are decided. Stop asking about things that have one obvious answer.

## 3. Write the specification

Write `SPEC.md` in the repository root:

```markdown
# <Feature>

## Goal
One paragraph. What this enables and for whom.

## Out of scope
The explicit list.

## Files and interfaces
Each file to add or change, and what changes in it.

## Behaviour
Numbered cases, each with its expected result.

## Data
Schema changes, migrations, derived values.

## Failure modes
Each one and the intended handling.

## Acceptance criteria
A numbered list, each item verifiable by a command or an observation.

## Verification
The end-to-end check that proves the feature works.
```

## 4. Hand over

Tell the user to start a fresh session to implement it, pointing that session at `SPEC.md`. A clean context that reads a good specification outperforms a long context that wrote one.
