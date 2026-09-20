# Claude Playbook

A working `.claude/` directory for [Claude Code](https://code.claude.com), and
the reasoning behind every file in it.

Rules that load only when they apply, skills for review and verification,
subagents that keep exploration out of your context, and hooks that enforce what
instructions can only request.

[![Version](https://img.shields.io/badge/version-2.0.0-blue)](CHANGELOG.md)
[![Tested with Claude Code](https://img.shields.io/badge/Claude%20Code-v2.1.263-orange)](docs/whats-new.md)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)

> Independent community project. "Claude" and "Claude Code" are products of
> [Anthropic](https://www.anthropic.com). Not affiliated with, endorsed by, or
> sponsored by Anthropic.

---

## Contents

- [Why this exists](#why-this-exists)
- [Install](#install)
- [What you get](#what-you-get)
- [How the pieces fit together](#how-the-pieces-fit-together)
- [The components, one at a time](#the-components-one-at-a-time)
  - [1. CLAUDE.md](#1-claudemd-what-every-session-needs-to-know)
  - [2. Rules](#2-rules-standards-that-load-when-they-apply)
  - [3. Skills](#3-skills-workflows-you-run)
  - [4. Subagents](#4-subagents-work-that-happens-elsewhere)
  - [5. Hooks](#5-hooks-rules-that-cannot-be-ignored)
  - [6. Workflows](#6-workflows-orchestration-at-scale)
  - [7. Settings and permissions](#7-settings-and-permissions)
  - [8. MCP servers](#8-mcp-servers)
  - [9. CI and automation](#9-ci-and-automation)
  - [10. Evals](#10-evals-proof-that-any-of-this-helps)
- [Make it yours](#make-it-yours)
- [Check your setup](#check-your-setup)
- [Guides](#guides)
- [Compatibility](#compatibility)
- [Contributing](#contributing)

---

## Why this exists

Claude Code writes good code and still drifts, because nothing in your
repository tells it what "good" means here. Left alone it will patch symptoms
rather than causes, build a component that already exists three directories
over, leave dead code behind, and report that tests pass without running them.

None of that is a model failure. It is missing context, in the specific places
Claude Code gives you to put context.

This repository fills those places, and explains each choice, so you can keep
what fits your project and delete the rest.

**New in 2.0** (September 2026): the hook registration format, the memory
precedence model, and half the frontmatter documented here changed since the
first release. Rules are now path-scoped, which cut the always-loaded context
by 82%. See [what's new](docs/whats-new.md) and the
[changelog](CHANGELOG.md).

---

## Install

Three ways. Pick by how much you want to own.

### As a plugin, recommended for trying it out

```
/plugin marketplace add smartwhale8/claude-playbook
/plugin install claude-playbook@claude-playbook
```

You get the skills, the subagents, and the hooks, namespaced as
`/claude-playbook:review`. They update when you update the plugin, and nothing
lands in your repository.

Rules are not a plugin component, so copy those separately if you want them:

```bash
mkdir -p .claude/rules
curl -sL https://github.com/smartwhale8/claude-playbook/archive/main.tar.gz \
  | tar xz --strip=2 -C .claude/rules claude-playbook-main/.claude/rules
```

### As a template, recommended for a new project

Click **Use this template** on GitHub, or:

```bash
gh repo create my-project --template smartwhale8/claude-playbook --public --clone
```

You own every file and edit it freely. Nothing updates automatically.

### Copied into an existing project

```bash
git clone https://github.com/smartwhale8/claude-playbook /tmp/playbook
cp -r /tmp/playbook/.claude .
cp /tmp/playbook/.mcp.json.example .          # optional, inert until renamed
```

Then read [Make it yours](#make-it-yours). Copying it unchanged gets you maybe
half the value.

> **Before you run any of this**, read [SECURITY.md](SECURITY.md). Hooks are
> executable code that runs automatically. That is true of every playbook,
> including this one, and reviewing four short shell scripts is the price of
> using one.

---

## What you get

```
.claude/
├── CLAUDE.md                   Project instructions template, with the rules for writing one
├── settings.json               Hook registrations and permission rules
│
├── rules/                      Standards Claude applies while writing code
│   ├── code-quality.md              ─┐
│   ├── architecture.md               │
│   ├── engineering-principles.md     ├─ always loaded  (~1,700 tokens total)
│   ├── testing.md                    │
│   ├── security.md                   │
│   ├── git-workflow.md              ─┘
│   ├── api-design.md                ─┐
│   ├── error-handling.md             │
│   ├── database.md                   │
│   ├── alembic.md                    ├─ loaded only when Claude opens a matching file
│   ├── frontend.md                   │
│   ├── frontend-consistency.md       │
│   ├── performance.md                │
│   └── llm-prompts.md               ─┘
│
├── skills/                     Workflows you invoke
│   ├── review/                      /review          before committing
│   ├── review-pr/                   /review-pr 456   on a pull request
│   ├── fix-issue/                   /fix-issue 123   issue to merged PR
│   ├── verify/                      /verify          prove it works
│   └── plan-feature/                /plan-feature    interview, then write SPEC.md
│
├── agents/                     Specialists with their own context window
│   ├── explorer.md                  Haiku, read-only. Maps unfamiliar code cheaply.
│   ├── code-reviewer.md             Sonnet, read-only. Backs /review and /review-pr.
│   ├── security-reviewer.md         Opus, read-only. Audits a diff.
│   └── test-writer.md               Sonnet, worktree-isolated. Backfills tests.
│
├── hooks/                      Automatic, deterministic, not negotiable
│   ├── lint-on-edit.sh              After every edit. Returns failures to Claude.
│   ├── guard-destructive.sh         Before every command. Blocks six patterns.
│   ├── session-context.sh           At session start. Branch and recent commits.
│   └── require-green-tests.sh       Blocks the turn while tests fail. Off by default.
│
└── workflows/                  Orchestration too large for one context window
    └── audit.js                     /audit  one reviewer per file, each finding refuted

.claude-plugin/    plugin.json and marketplace.json, for installing it as a plugin
hooks/hooks.json   the same hooks, as the plugin registers them
evals/             three cases that measure whether any of this changes behaviour
docs/              seven guides
scripts/           a working headless example
.github/workflows/ @claude mentions, automatic PR review, and the playbook's own CI
AGENTS.md          cross-tool interoperability
.mcp.json.example  MCP template, inert until you rename it
SECURITY.md        read before trusting any .claude directory
```

---

## How the pieces fit together

Claude Code gives you several places to put a behaviour, and they differ in one
way that matters more than any other: **when the behaviour costs you context,
and whether it can be ignored.**

```
                      Does it need Claude's judgement?
                                  │
              ┌───────────────────┴───────────────────┐
              NO                                      YES
              │                                       │
          ┌───┴────┐                    ┌─────────────┴─────────────┐
       A HOOK                      Does it apply to           Is it a procedure
   Runs every time.                 certain files?             you run on request?
   Cannot be skipped.                    │                           │
   Costs no context.            ┌────────┴────────┐          ┌───────┴───────┐
                               YES               NO         YES             NO
                                │                 │          │               │
                        A PATH-SCOPED RULE   Does it need   A SKILL    Does it read
                        Loads only when      to read a      Body loads  a lot to say
                        Claude opens a       lot?           on demand.  a little?
                        matching file.          │                          │
                                          ┌─────┴─────┐              ┌─────┴─────┐
                                         YES         NO             YES         NO
                                          │           │              │           │
                                     A SUBAGENT   CLAUDE.md     A SUBAGENT   A CORE RULE
                                     Own context.  Always        Own context. Always
                                     Returns a     loaded.       Returns a    loaded.
                                     summary.      Keep it       summary.
                                                   under 200
                                                   lines.
```

The short version:

| If it must happen every time | Use a **hook**. Prose is a request; a hook is a gate. |
|---|---|
| If it only matters for some files | Use a **path-scoped rule**. |
| If it is a procedure you run | Use a **skill**. |
| If it needs to read a lot | Use a **subagent**. |
| If it applies to everything, always | Use **CLAUDE.md**, and keep it short. |

[Choosing a component](docs/choosing-a-component.md) works through the
trade-offs and the worked examples.

---

## The components, one at a time

### 1. CLAUDE.md: what every session needs to know

**What it is.** A file Claude reads at the start of every conversation. Your
build commands, your conventions, the decisions the code does not state for
itself.

**What ships.** `.claude/CLAUDE.md`, a template with the guidance written into
HTML comments. Those comments are stripped before the file enters context, so
they cost nothing.

**How to use it.**

```
/init       generates a first draft from your codebase
/doctor     proposes cuts for anything derivable from the code
/context    confirms it actually loaded
```

**The one rule.** Keep it under 200 lines. Longer files get ignored, because
the instruction you care about gets lost among forty you do not. For each line
ask: would removing this cause a mistake? If not, cut it.

Include the commands Claude cannot guess, conventions that differ from the
language default, architectural decisions, and gotchas. Exclude anything Claude
learns by reading the code.

---

### 2. Rules: standards that load when they apply

**What it is.** Markdown files in `.claude/rules/`. Without frontmatter they
load in every session. With `paths:` frontmatter they load only when Claude
opens a matching file.

**What ships.** Fourteen rules, split six always-loaded and eight path-scoped.

*Always loaded, about 1,700 tokens total:*

| File | Enforces |
|---|---|
| `code-quality.md` | Fix causes not symptoms, delete dead code, do what was asked and stop |
| `architecture.md` | Dependency direction, one definition per thing, module boundaries |
| `engineering-principles.md` | When to extract and when not to, validate at boundaries only |
| `testing.md` | Regression test first, never weaken a test to make it pass |
| `security.md` | Secrets, auth, input handling, what leaves the system |
| `git-workflow.md` | Commit and branch conventions |

*Loaded only when a matching file is opened:*

| File | Loads for |
|---|---|
| `api-design.md` | `**/api/**`, `**/routes/**`, `**/controllers/**` |
| `error-handling.md` | Source files |
| `database.md` | `**/models/**`, `**/repositories/**`, `**/migrations/**`, `*.sql` |
| `alembic.md` | `**/alembic/**`, `**/migrations/versions/*.py` |
| `frontend.md` | `*.tsx`, `*.jsx`, `*.vue`, `*.svelte`, `**/components/**` |
| `frontend-consistency.md` | UI and style files |
| `performance.md` | Source files |
| `llm-prompts.md` | `**/prompts/**`, `*.j2` |

**Why the split.** Before 2.0, all fourteen loaded in every session: roughly
9,400 tokens, including Alembic migration guidance in projects with no Python
and no database. Research from ETH Zurich (arXiv 2602.11988) measured more than
a 20% cost increase from always-on context files with no improvement in task
success. Scoping them removed nothing and cut the always-loaded footprint by
82%.

**How to add your own.**

```markdown
---
paths:
  - "src/payments/**/*.ts"
---

# Payments

<!-- Why this rule exists: PCI review, 2026-03. Revisit when we move to Stripe Connect. -->

- Amounts are integer minor units. Never a float.
- Every charge is idempotent on the request key.
```

Two habits keep a rule directory healthy. Scope it with `paths:` unless it truly
applies everywhere. Date the comment explaining why it exists, so a future
reader can decide whether to delete it. Note that the documented stripping of
block-level HTML comments covers CLAUDE.md files; the docs do not say the same
for rule files, so treat a rule's comments as part of its budget. The figures
here count them, which makes them an upper bound. A study from NAIST found 59% to 67% of
context files grow across commits and are never pruned.

**Delete what does not apply.** No database? Delete `database.md` and
`alembic.md`. No frontend? Delete the two frontend rules. No LLM calls? Delete
`llm-prompts.md`.

---

### 3. Skills: workflows you run

**What it is.** A directory with a `SKILL.md`. The body loads only when the
skill runs, so a long procedure costs nothing in the sessions that do not use
it. Skills are model-invocable by default; `disable-model-invocation: true`
makes them yours to trigger.

**What ships.**

| Skill | Invoke | Does |
|---|---|---|
| `review` | `/review` | Reviews uncommitted changes against your rules and returns a verdict. Runs as a forked subagent, so the review does not consume your context. |
| `review-pr` | `/review-pr 456` | Reviews a pull request for correctness, fit, security, tests, and CI status. Also forked. |
| `fix-issue` | `/fix-issue 123` | Issue to pull request: reproduce, branch, failing test first, fix the cause, verify, open the PR. |
| `verify` | `/verify` | Runs the type check, lint, tests, and build, adds a behavioural check, and reports the command output rather than a claim. |
| `plan-feature` | `/plan-feature <idea>` | Interviews you about the decisions you have not made, then writes `SPEC.md`. |

**Start with `/verify`.** It is the one that changes outcomes most. Claude stops
when work looks done, and "looks done" is the only signal it has unless you give
it a check it can run.

**How to add your own.**

```markdown
---
name: deploy-staging
description: Deploy the current branch to staging and watch the rollout.
disable-model-invocation: true
argument-hint: "[branch]"
allowed-tools: Bash(kubectl *), Bash(git *), Read
---

Deploy $ARGUMENTS to staging.

Current branch: !`git branch --show-current`

1. Confirm CI is green for this commit.
...
```

The pieces: `$ARGUMENTS` for input, `` !`command` `` to run a shell command and
inject its output before Claude sees the file, `allowed-tools` to pre-approve
tools so the skill does not stall on prompts, `disable-model-invocation` for
anything with side effects, and `context: fork` to run it in a subagent.

Keep the body under 500 lines and put reference material in sibling files.

Run `/skill-doctor` to see which skills fire and what each costs.

---

### 4. Subagents: work that happens elsewhere

**What it is.** A definition in `.claude/agents/`. The agent runs in its own
context window with its own tools and model, and returns a summary. The forty
files it read never enter your conversation.

This is the main defence against context exhaustion, which is the constraint
behind almost everything else here.

**What ships.**

| Agent | Model | Tools | For |
|---|---|---|---|
| `explorer` | Haiku, medium | Read-only | "How does auth work?" Reads widely, returns cited paragraphs. Haiku because reading and summarizing does not need a frontier model. |
| `code-reviewer` | Sonnet, high | Read-only | Backs `/review` and `/review-pr`. Exists rather than using the built-in `Explore` because Explore skips CLAUDE.md, which would strip the rules a review checks against. |
| `security-reviewer` | Opus, high | Read-only | Auditing a diff. Must trace the path from untrusted input to the vulnerable line before reporting a finding. |
| `test-writer` | Sonnet, worktree | Full | Backfilling tests in an isolated checkout. Forbidden from editing the code under test, so a bug it finds stays found. |

**How to use them.**

```
Use the explorer agent to map how session refresh works.
@agent-security-reviewer audit the changes in src/auth/
```

Naming the agent with `@` guarantees it runs.

**How to add your own.**

```markdown
---
name: migration-reviewer
description: Checks database migrations for unsafe operations on live data.
tools: Read, Grep, Glob
model: sonnet
effort: high
---

You review migrations for operations that lock a table or lose data...
```

Useful fields beyond those: `isolation: worktree` for an isolated checkout,
`maxTurns` to cap a run, `memory: project` to persist learning across sessions,
`permissionMode`, and `disallowedTools`.

A subagent does not see your conversation history. Everything it needs goes in
the delegation prompt.

---

### 5. Hooks: rules that cannot be ignored

**What it is.** A script that runs on an event. CLAUDE.md is context that Claude
weighs; a hook is a gate that runs whether or not Claude agrees. Anything that
must hold every time belongs here.

**What ships.**

| Script | Event | On by default | Does |
|---|---|---|---|
| `lint-on-edit.sh` | `PostToolUse` on `Edit\|Write` | Yes | Runs the right linter for the file type. On failure, hands the errors back so Claude fixes them in the same turn. |
| `guard-destructive.sh` | `PreToolUse` on `Bash` | Yes | Denies recursive root delete, force push, hard reset onto the remote default branch, reading `.env`, piping a download into a shell, and raw `DROP` statements. |
| `session-context.sh` | `SessionStart` | Yes | Adds the branch, uncommitted file count, and last five commits. Saves three tool calls per session. |
| `require-green-tests.sh` | `Stop` | No | Blocks the turn from ending while tests fail. The strongest verification gate here. Header comment has the settings block. |

All four need `jq`, and exit silently without it rather than failing your tool
call.

**How registration works.** In `.claude/settings.json`, never in the script:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"${CLAUDE_PROJECT_DIR}\"/.claude/hooks/lint-on-edit.sh",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```

Three details that break most hand-written hooks:

1. Each matcher group holds a `hooks` **array**. A `command` key directly on the
   matcher entry does not run. This repository shipped that error until 2.0.
2. Input arrives as **JSON on stdin**, not as arguments. Read
   `.tool_input.file_path` with `jq`. There is no `$TOOL_INPUT_FILE_PATH`.
3. Quote the placeholder: `"${CLAUDE_PROJECT_DIR}"`.

Handlers can also be `http`, `mcp_tool`, `prompt` (a small model decides), or
`agent` (a subagent decides). More than twenty events exist.
[Hooks and guardrails](docs/hooks-and-guardrails.md) has the full reference.

Verify with `/hooks`, and debug with `claude --debug-file ./debug.txt`.

---

### 6. Workflows: orchestration at scale

**What it is.** A JavaScript file in `.claude/workflows/` that orchestrates
subagents. The script holds the loop, the branching, and the intermediate
results, so your context receives only the final answer. That is what makes
hundreds of agents possible where a conversation would run out of room after a
few dozen.

**What ships.** `audit.js`, invoked as `/audit [what to look for]`.

```
/audit missing authentication checks
/audit unbounded database queries
```

It lists the files in scope, runs one reviewer per file, and then has a second,
independent agent try to **refute** each finding before reporting it.

That second pass is the reason to use a workflow here rather than a subagent. A
reviewer asked to find problems will find some whether or not they are real,
because that is what it was asked to do. An agent that sees only the claim and
the file, and is told to disprove it, removes most of the noise. Codifying that
in a script is what makes it happen the same way every run.

**How to get your own.** Do not write one by hand. Describe the task and let
Claude write the script:

```
use a workflow to migrate every component under src/components/ from JavaScript
to TypeScript, working on each file in its own isolated copy
```

Watch it with `/workflows`. When a run does what you wanted, press `s` on it to
save its script, and it becomes `/<name>` in future sessions.

**Three rules the runtime enforces**, worth knowing before you edit a saved
script. `export const meta` must be the first statement and a plain object
literal. There is no `import()`. And `Date.now()`, `Math.random()`, and
`new Date()` all throw, so that a resumed run repeats the same calls rather than
diverging.

Limits: 16 concurrent agents by default, 4,096 items per `pipeline()` or
`parallel()` call, and 1,000 agents per run. Set the size guideline in `/config`
to bound how large Claude makes them.

`/deep-research` is bundled with Claude Code and shows the same pattern.

---

### 7. Settings and permissions

`.claude/settings.json` holds hook registrations and permission rules. It is
committed and shared. Personal overrides go in `settings.local.json`, which
Claude Code keeps out of git.

```json
{
  "permissions": {
    "allow": ["Bash(npm run lint)", "Bash(git diff *)"],
    "deny": ["Read(./.env)", "Read(./.env.*)", "Edit(./.env)"]
  }
}
```

A `deny` rule applies immediately, including in an untrusted folder. An `allow`
rule waits until you trust the workspace.

One trap: the space in `Bash(git diff *)` matters. Without it,
`Bash(git diff*)` also matches `git diff-index`.

Add your project's safe commands to `allow` and you will stop clicking through
approval prompts. Run `/fewer-permission-prompts` and Claude will propose the
list from your own history.

---

### 8. MCP servers

`.mcp.json.example` ships inert. Rename it to `.mcp.json` to use it.

Project scope means the file is committed and shared with everyone who clones
the repository. Personal servers belong in user scope:
`claude mcp add --scope user`.

Curate ruthlessly. Every server adds tool names to your context even with
schemas deferred. Prefer a CLI where one exists: `gh`, `aws`, `gcloud`, and
`sentry-cli` add nothing at all. Run `/context` to see the cost and `/mcp` to
disable what you are not using.

---

### 9. CI and automation

| Workflow | Trigger | Does |
|---|---|---|
| `claude.yml` | `@claude` in a comment | Claude responds in the thread |
| `claude-review.yml` | Pull request opened or updated | Runs this repository's own `/review-pr` skill |
| `playbook-checks.yml` | Push and pull request | Validates manifests, shellchecks the hooks, parses the JSON, fails if the always-loaded rule budget exceeds 2,000 words, and runs the evals |

Set up the first two with `/install-github-app`, which installs the app, stores
the credential, and opens the pull request for you.

`scripts/review-diff.sh` is a working headless example showing `--bare`,
`--output-format json`, and `--permission-mode dontAsk`.
[Automation](docs/automation.md) covers headless runs, Actions, and scheduled
cloud routines.

---

### 10. Evals: proof that any of this helps

Three cases under `evals/` measure whether the playbook changes what Claude
does, rather than whether its files parse.

```bash
claude plugin validate . --strict    # do the manifests and components parse?
claude plugin eval .                 # does any of it change behaviour?
```

Each case runs with the plugin and again without it. The number that matters is
`Δ`, the difference. A case scoring 1.0 in both arms means the playbook did
nothing there.

One of the three is a negative case: an ordinary git question that fails if any
skill hijacks it. A description written too broadly is a real cost, and this
catches it.

`claude plugin eval` requires Claude Code v2.1.269 or later.

---

## Make it yours

Copying this unchanged gets you about half the value. Five steps, in order.

**1. Fill in the commands.** Edit `.claude/CLAUDE.md` with your real build,
test, lint, and type-check commands. The `/verify` skill runs exactly these, so
getting them right is what makes verification work.

**2. Delete what does not apply.** No database? Remove `database.md` and
`alembic.md`. No frontend? Remove both frontend rules. No LLM calls? Remove
`llm-prompts.md`. Deleting a rule is free; carrying one you ignore is not.

**3. Make the rules specific.** Generic rules are the weakest part of any
template. Replace them with your actual paths and names.

Generic:

> Use custom exception classes instead of framework defaults.

Specific:

> Use `NotFoundError`, `BadRequestError`, and `ForbiddenError` from
> `app/core/exceptions.py`. Handlers are registered in `main.py` and return
> `{"success": false, "error": {"code": "...", "message": "..."}}`.

**4. Point the guardrails at your project.** Edit `PATTERNS` in
`guard-destructive.sh` for the commands that would hurt in your repository. Add
your sensitive paths to `permissions.deny`. Set `PLAYBOOK_TEST_COMMAND` if you
enable the test gate.

**5. Check the fit of the path globs.** The `paths:` frontmatter assumes common
layouts. If your API lives somewhere other than `src/api/`, update the globs, or
the rule silently never loads.

---

## Check your setup

```
/context        What is actually loaded, and what it costs
/hooks          Which hooks are registered
/doctor         Proposed cuts to CLAUDE.md
/skill-doctor   Which skills fire, and what each one costs
```

For the playbook's own files:

```bash
claude plugin validate . --strict
shellcheck .claude/hooks/*.sh
```

To confirm a path-scoped rule loads when you expect, register an
`InstructionsLoaded` hook and watch what loads and why.

---

## Guides

| Guide | Covers |
|---|---|
| [Choosing a component](docs/choosing-a-component.md) | The decision, the trade-offs, the mistake everyone makes |
| [Plan and verify](docs/plan-and-verify.md) | Plan mode, `/goal`, Stop hooks, adversarial review, demanding evidence |
| [Hooks and guardrails](docs/hooks-and-guardrails.md) | The full hook reference: events, handler types, JSON decisions |
| [Subagents and parallelism](docs/subagents-and-parallelism.md) | Subagents, worktrees, agent teams, dynamic workflows |
| [Context and cost](docs/context-and-cost.md) | Where context goes, session habits, structural savings, models |
| [Automation](docs/automation.md) | Headless runs, GitHub Actions, scheduled routines |
| [What's new](docs/whats-new.md) | Claude Code changes since February 2026, and what changed here |
| [Security](SECURITY.md) | Reviewing a `.claude/` directory before trusting it |

---

## Compatibility

Tested against **Claude Code v2.1.263** on macOS.

| Feature used | Needs |
|---|---|
| `${CLAUDE_PROJECT_DIR}` inside a skill body | v2.1.196 |
| `background: false` on forked skills | v2.1.218 |
| `/skill-doctor` | v2.1.252 |
| `--permission-prompts none` | v2.1.259 |
| `claude plugin eval` | v2.1.269 |
| `AGENTS.md` read directly | v2.1.277 |

The rules, skills, agents, and hooks work on any recent version. Only the
tooling above has a floor.

Hook scripts need `jq`. They exit silently without it. They are tested on macOS
and have not been exercised on Windows.

---

## Contributing

Pull requests welcome, particularly rules that have prevented a real problem in
a real project.

What makes a rule worth adding:

- **Generic.** No project-specific paths or class names in the shipped version.
- **Concrete.** "Never query inside a loop" is enforceable. "Write performant
  code" is not.
- **Non-obvious.** If Claude already does it without being told, the line only
  dilutes the rules around it. Ask whether the rule changes behaviour, and say
  in the pull request how you know.
- **Scoped.** Add `paths:` frontmatter unless it genuinely applies everywhere.
  CI fails if the always-loaded set passes 2,000 words.
- **Dated.** A comment saying why the rule exists and when it was added, so
  someone can decide later whether to delete it.

Better still, add an eval case showing the rule changes what Claude does. A
positive `Δ` is the strongest argument a pull request here can make.

---

## License

[MIT](LICENSE). Use it, change it, ship it.
