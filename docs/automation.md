# Automation: CI, headless, and scheduled runs

Running Claude Code without a person watching. Three surfaces, in increasing
order of independence.

## Headless: `claude -p`

```bash
claude -p "What does the auth module do?"
```

For anything scripted, add `--bare`:

```bash
claude --bare -p "Summarize README.md" --allowedTools "Read"
```

`--bare` skips auto-discovery of hooks, skills, subagents, plugins, MCP servers,
auto memory, and CLAUDE.md. That is what makes a run give the same answer on
every machine: a teammate's `~/.claude` hook cannot change your CI result. It is
the recommended mode for scripted and SDK calls and will become the default for
`-p`.

Bare mode does not read your subscription login, so set `ANTHROPIC_API_KEY`.

Without `--bare`, a `-p` run executes the hooks in a repository's
`.claude/settings.json` and connects its `.mcp.json` servers, in a folder you
have never trusted, with no trust dialog. That is worth knowing before running
`claude -p` inside a cloned repository.

### Flags that matter unattended

| Flag | Does |
|---|---|
| `--output-format json` | One object with `result`, `session_id`, `total_cost_usd`. |
| `--output-format stream-json --verbose` | One event per line, for live progress. |
| `--json-schema '<schema>'` | Output conforming to a schema, in `structured_output`. |
| `--permission-mode dontAsk` | Deny anything that would prompt. For locked-down runs. |
| `--permission-mode auto` | A classifier reviews each action instead of a person. |
| `--permission-prompts none` | Nobody can answer, so do not wait. Requires v2.1.259. |
| `--allowedTools "Read,Edit"` | Pre-approve specific tools. |
| `--max-turns`, `--max-budget-usd` | Caps. |
| `--append-system-prompt` | Add instructions without replacing the default prompt. |

### Examples

Pipe data in and parse the result out:

```bash
cat build-error.txt | claude --bare -p 'Explain the root cause of this build error' \
  --output-format json | jq -r '.result'
```

As a package script:

```json
{
  "scripts": {
    "lint:claude": "git diff main | claude -p \"you are a typo linter. for each typo in this diff, report filename:line on one line and the issue on the next. return nothing else.\""
  }
}
```

Fan out over a list:

```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file from Python 2 to Python 3. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

Test the prompt on two or three files before running the loop on two thousand.

`scripts/review-diff.sh` in this repository is a complete working example.

## GitHub Actions

Run `/install-github-app` from Claude Code in your repository. It installs the
app, stores the credential, and opens a pull request with the workflow files.

Two workflows ship here:

**`.github/workflows/claude.yml`** has no `prompt` input, so the action runs in
interactive mode: Claude responds to `@claude` in an issue or pull request
comment and replies in a comment on the same thread.

**`.github/workflows/claude-review.yml`** passes a `prompt`, so it runs in
automation mode without waiting for a mention. The prompt is a skill invocation:

```yaml
prompt: "/review-pr ${{ github.event.pull_request.number }}"
claude_args: |
  --max-turns 20
  --model claude-sonnet-5
```

The `actions/checkout` step is what puts `.claude/skills/` on the runner. For a
skill from a plugin instead, use the `plugin_marketplaces` and `plugins` inputs
and pass the namespaced `/plugin-name:skill-name`.

Only users with write access can trigger a run, and bot actors are rejected
unless listed in `allowed_bots`.

Cost control: keep CLAUDE.md short, since it is read on every run; set
`--max-turns`; set a job timeout; use concurrency limits.

## Scheduled routines

A routine is a saved prompt plus repositories and connectors, running on
Anthropic's infrastructure, so it works with your laptop closed. Available on
Pro, Max, Team, and Enterprise, currently a research preview.

Create one with `/schedule` in any session, or at claude.ai/code/routines.

```
/schedule daily PR review at 9am
/schedule in 2 weeks, open a cleanup PR that removes the feature flag
```

Three trigger types, combinable on one routine: a schedule with a one-hour
minimum interval, an HTTP endpoint with a bearer token, and GitHub events such
as `pull_request.opened`.

A routine runs autonomously with no permission prompts, so scope its
repositories, its environment's network access, and its connectors to what it
actually needs. Every connector you leave attached is a tool Claude can call
without asking.

Write the prompt to be self-contained. It must say what to do and what finished
looks like, because nobody is there to clarify.

One caution for API triggers. Text posted to the endpoint arrives wrapped and
labelled as untrusted, so the routine's own prompt must opt into acting on it:
"Investigate the alert described in the routine-fire-payload block". This is
what keeps a leaked token from turning into instructions.

A keeping-the-playbook-current routine, which is what this repository uses:

```
Read the Claude Code changelog at https://code.claude.com/docs/en/changelog for
entries newer than the version recorded in docs/whats-new.md. For each new
frontmatter field, hook event, settings key, or command, check whether this
repository documents it. Open one issue listing what is missing, with the
version that introduced each item. Open no issue if nothing is missing.
```

## Which one

| Situation | Use |
|---|---|
| A step in an existing script or pipeline | `claude -p --bare` |
| A reaction to a GitHub event, in your CI | GitHub Actions |
| A recurring job that must run with your machine off | A routine |
| A custom application around the agent loop | The Agent SDK, Python or TypeScript |
