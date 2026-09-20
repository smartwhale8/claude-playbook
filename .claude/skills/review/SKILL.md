---
name: review
description: Review uncommitted changes against the project rules before committing. Use when the user asks for a review of their working tree, asks whether changes are ready to commit, or says they are about to commit.
disable-model-invocation: true
argument-hint: "[optional focus, e.g. security]"
allowed-tools: Bash(git diff *), Bash(git status *), Bash(git log *), Read, Grep, Glob
context: fork
agent: code-reviewer
background: false
---

# Review uncommitted changes

Focus for this review, if the user gave one: $ARGUMENTS

## The changes

Staged:

!`git diff --staged --stat || true`

Unstaged:

!`git diff --stat || true`

Untracked:

!`git status --porcelain | grep '^??' || true`

## What to do

1. Read the full diff. Use `git diff --staged` if anything is staged, otherwise `git diff`. Read untracked files directly.
2. For each changed file, open the surrounding code. A change that is correct alone can still break the pattern of the module it lives in.
3. Check the change against `.claude/rules/`. Path-scoped rules apply to the files they match.
4. Search before reporting duplication. If a new helper or component looks like something that already exists, find the existing one and name it with its path.

## What counts as a finding

Report only what affects correctness, security, or the stated rules:

- Dead code, commented-out blocks, or debug output left behind
- A fix that treats a symptom instead of the cause
- Logic that duplicates something already in the codebase, with the path to the original
- A hardcoded secret, an unparameterized query, unescaped user content, a missing authorization check
- A query inside a loop, or a list read with no limit
- A new behaviour with no test, or a bug fix with no regression test

Style preferences are not findings. Neither is a possible future problem.

## Output

One verdict, then the findings.

- **Ready to commit.** Nothing blocking. Say what you checked.
- **Minor issues.** List them. Committing is reasonable once the author has seen them.
- **Needs changes.** List what must be fixed first.

Each finding gives the file and line, what is wrong, and the specific change that fixes it.
