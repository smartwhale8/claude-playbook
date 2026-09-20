# Subagents, teams, and workflows

Four ways to run more than one thing at once. They differ in who holds the plan,
and that is the whole basis for choosing.

|  | Subagents | Skills | Agent teams | Workflows |
|---|---|---|---|---|
| What it is | A worker Claude spawns | Instructions Claude follows | A lead supervising peer sessions | A script the runtime executes |
| Who decides what runs next | Claude, turn by turn | Claude, following the prompt | The lead, turn by turn | The script |
| Where results live | Claude's context | Claude's context | A shared task list | Script variables |
| Scale | A few per turn | Same | A handful of peers | Dozens to hundreds |
| Token cost | Lower | Lowest | Highest | High |

Reach for the simplest one that fits. Most work needs a subagent, not a team.

## Subagents

A subagent runs in its own context window with its own tools and returns a
summary. The files it read never enter your conversation. That is the point: your
context window is the binding constraint, and delegation is how you protect it.

Define one in `.claude/agents/<name>.md`:

```markdown
---
name: explorer
description: Maps how something works across many files and reports back.
tools: Read, Grep, Glob, Bash(git log *)
model: haiku
effort: medium
---

You map code and report what you found. You do not change anything.
```

The frontmatter fields worth knowing:

| Field | Does |
|---|---|
| `tools` | Allowlist. Omit to inherit everything. |
| `disallowedTools` | Denylist against the inherited set. |
| `model` | `haiku`, `sonnet`, `opus`, `fable`, a full ID, or `inherit`. |
| `effort` | `low`, `medium`, `high`, `xhigh`, `max`. Which levels exist depends on the model: Opus 4.6 and Sonnet 4.6 have no `xhigh`. |
| `permissionMode` | `default` (shown as Manual), `acceptEdits`, `auto`, `dontAsk`, `plan`, `manual`, `bypassPermissions`. |
| `maxTurns` | Stops the agent and marks the result partial. |
| `isolation: worktree` | Runs in a temporary git worktree, branched from the default branch. |
| `background` | Keeps it in the background even when Claude wants it in front. |
| `memory` | `user`, `project`, or `local`. Persists across sessions. |
| `skills` | Preloads named skills into the agent at startup. |
| `omitClaudeMd` | Starts without the CLAUDE.md files. |

A subagent receives its system prompt, the delegation message, the CLAUDE.md
files, and a git status snapshot. It does **not** receive your conversation
history. Everything it needs goes in the delegation prompt.

Built-in types exist before you define anything: `Explore` and `Plan` are
read-only, `general-purpose` has the full tool set.

Invoke one by describing the task, or address it directly with
`@agent-explorer` to guarantee it runs.

### What ships here

| Agent | Model | Tools | For |
|---|---|---|---|
| `explorer` | haiku | Read-only | Mapping unfamiliar code cheaply. Haiku is the right model when the job is reading and summarizing. |
| `code-reviewer` | sonnet, high effort | Read-only | Backs `/review` and `/review-pr`. It exists instead of the built-in `Explore` because Explore skips CLAUDE.md to stay fast, which would also skip the rules a review checks against. |
| `security-reviewer` | opus, high effort | Read-only | Auditing a diff. A fresh context reviews better than the one that wrote the code. |
| `test-writer` | sonnet, worktree | Full | Backfilling tests without colliding with your checkout. |

Note the model choice in each. Running everything on your session model is the
most common way to overspend on delegation.

`CLAUDE_CODE_SUBAGENT_MODEL` sets a default for agents that do not name a model,
so it changes none of the four above, each of which names one. It also leaves
the built-in `Explore` and `Plan` agents alone. To force every subagent onto one
model regardless of its definition, add `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1`.

## Worktree isolation

`isolation: worktree` gives an agent its own git checkout, branched from the
default branch rather than your HEAD. Its shell commands run there, and Claude
Code removes the worktree automatically if the agent changed nothing.

Use it when an agent writes many files, or when several agents write at once.
`test-writer` uses it because a batch of new test files is exactly the case that
collides with whatever you are editing.

## Agent teams

Experimental, disabled by default, and expensive. Teammates inherit the lead's
permission mode, except `dontAsk`, which they do not inherit. The widely quoted
figure of roughly seven times the tokens of a single session applies to
teammates running in plan mode, which happens when the lead is in plan mode as
they spawn.

```json
{ "env": { "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1" } }
```

Teammates differ from subagents in that they message each other directly and
share a task list, rather than reporting back to one coordinator. That is worth
paying for when the work benefits from disagreement: several reviewers with
different lenses, or competing hypotheses for a bug where each teammate tries to
disprove the others.

Start with three to five. A subagent definition can serve as a teammate role, so
the agents in this playbook work as teammates without change.

Read the cost note before enabling this. For sequential work, edits to the same
files, or anything with dependencies, a single session wins.

## Workflows

A workflow is a JavaScript file that orchestrates subagents. The script holds the
loop, the branching, and the intermediate results, so Claude's context receives
only the final answer. That is what makes hundreds of agents possible.

Ask for one:

```
use a workflow to audit every route handler under src/routes/ for missing
authentication checks, and adversarially verify each finding before reporting it
```

Claude writes the script and the runtime executes it in the background. Watch it
with `/workflows`, and press `s` on a run to save its script to
`.claude/workflows/` for reuse as `/<name>`.

The shape of a saved script:

```javascript
export const meta = {
  name: 'audit-routes',
  description: 'Audit every route handler for missing auth checks',
}

const found = await agent('List every .ts file under src/routes/.', {
  schema: { type: 'object', required: ['files'],
            properties: { files: { type: 'array', items: { type: 'string' } } } },
})

const audits = await pipeline(found.files, file =>
  agent(`Audit ${file} for missing authentication checks.`, { label: file }),
)

return audits.filter(Boolean)
```

`agent()` spawns one, `pipeline()` runs one per item, `parallel()` runs a set at
once. Limits: 16 concurrent agents by default, 4,096 items per call, 1,000 agents
per run.

`/deep-research` is bundled with Claude Code and shows the pattern working.

This repository ships one: `/audit [what to look for]`, in
`.claude/workflows/audit.js`. It fans out one reviewer per file and then has a
second, independent agent try to refute each finding before reporting it. Read
it as a worked example of the quality pattern, which is the real reason to use a
workflow rather than simply to run more agents at once.

Three rules the runtime enforces on a saved script. `export const meta` must be
the first statement and a plain object literal, or the command disappears from
autocomplete. There is no `import()`. And `Date.now()`, `Math.random()`, and
`new Date()` throw, so a resumed run repeats the same calls instead of
diverging. Pass a timestamp through `args` if you need one.

Run `/reload-skills` after editing a saved script, then invoke it again.

Set the size guideline in `/config`, or `workflowSizeGuideline` in settings, to
bound how large Claude makes them: `small` is under 5 agents, `medium` under 10,
`large` under 50.

## Running several sessions yourself

Before any of the automated options, there is the manual one, and it is often
enough.

- **Worktrees**: separate checkouts, separate sessions, no collisions.
- **`/batch <instruction>`**: splits a change across 5 to 30 worktree-isolated
  subagents, each opening its own pull request.
- **Writer and reviewer**: one session implements, a second reviews with fresh
  context. The reviewer is better precisely because it did not write the code.
- **Fan out with `claude -p`**: a shell loop over a list of files. See
  `scripts/review-diff.sh` for the call shape.
