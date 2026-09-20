# Hooks and guardrails

A rule in CLAUDE.md is a request. A hook is a gate. Anything that must hold every
time belongs in a hook, because a hook runs whether or not Claude agrees, whether
or not the context window is full, and whether or not the instruction got lost
among the other forty.

## How a hook is wired

Hooks are registered in `.claude/settings.json`, never in the script itself.

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

1. **The nesting.** Each matcher group holds a `hooks` array of handler objects.
   A `command` key placed directly on the matcher entry does not run. This
   playbook shipped that error until September 2026.
2. **Input arrives as JSON on stdin.** Not as arguments. The edited path is
   `.tool_input.file_path`; a Bash command is `.tool_input.command`. There is no
   `$TOOL_INPUT_FILE_PATH` variable.
3. **Quote the placeholder.** In shell form, write `"${CLAUDE_PROJECT_DIR}"` with
   the quotes, or a path containing a space breaks the command.

Check your work with `/hooks` to see what is registered, and
`claude --debug-file ./debug.txt` to see which hooks matched and how they exited.

## Speaking back to Claude

A hook that exits silently teaches Claude nothing. Return JSON on stdout instead.

**Block a tool call** from `PreToolUse`:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Force push is blocked. Use --force-with-lease."
  }
}
```

**Hand Claude information** from `PostToolUse` or `SessionStart`:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Lint failed for src/api.ts: 'user' is never used."
  }
}
```

**Refuse to end the turn** from `Stop`. Note that `decision` and `reason` are
top level here, not inside `hookSpecificOutput`. This is the one place the
nesting differs, and it is easy to get wrong:

```json
{
  "decision": "block",
  "reason": "The test suite is failing, so the work is not done."
}
```

The softer form for the same event does nest, and reads as guidance rather than
an error in the transcript:

```json
{
  "hookSpecificOutput": {
    "hookEventName": "Stop",
    "additionalContext": "Run the test suite before finishing."
  }
}
```

Both route through the same loop protection: the `stop_hook_active` input field
is true while Claude Code is already continuing because of a stop hook, and
Claude Code ends the turn anyway after 8 consecutive blocks.

Exit code 2 also blocks, on the events where blocking applies, and sends stderr
to Claude as the explanation. The JSON form is clearer and carries more.

## Handler types

`command` is not the only option. A handler can also be:

| Type | What it does |
|---|---|
| `command` | Runs a script. Deterministic, free, fast. |
| `http` | POSTs to an endpoint. For a shared service across a team. |
| `mcp_tool` | Calls an MCP tool. |
| `prompt` | Asks a small fast model to decide. For checks a regex cannot express. |
| `agent` | Spawns a subagent with read-only tools to decide. |

A `prompt` handler is the bridge between a hook and judgement:

```json
{
  "type": "prompt",
  "prompt": "Does this command touch production infrastructure? $ARGUMENTS Respond {\"ok\": true} to allow, or {\"ok\": false, \"reason\": \"...\"} to stop it.",
  "timeout": 30
}
```

`$ARGUMENTS` is replaced with the hook's input JSON. Note the response shape:
a prompt handler's model returns `ok`, not `decision`. `{"ok": false}` stops the
action, and what that means depends on the event.

## Events

There are far more than the four this playbook used to list. The ones worth
knowing:

| Event | Fires | Use for |
|---|---|---|
| `PreToolUse` | Before a tool call | Blocking destructive commands, rewriting input |
| `PostToolUse` | After a tool returns | Linting, formatting, feeding failures back |
| `PostToolUseFailure` | After a tool fails | Reacting to a specific failure |
| `UserPromptSubmit` | On your message | Injecting context, validating a prompt |
| `SessionStart` | At session start | Branch, ticket, and environment context |
| `SessionEnd` | At exit | Cleanup, logging |
| `Stop` | Before the turn ends | Gating on tests, lint, or a build |
| `SubagentStop` | Before a subagent ends | Checking a delegated result |
| `PreCompact` | Before compaction | Preserving something the summary would drop |
| `PermissionRequest` | On a permission prompt | Answering automatically in unattended runs |
| `InstructionsLoaded` | When instructions load | Debugging which rules actually loaded |
| `FileChanged` | On a watched file change | Reacting to `.env` or lockfile edits |

Matchers filter by tool name for the tool events, and by other values elsewhere.
`SessionStart` matches on `startup|resume|clear|compact|fork`. `PreCompact`
matches `manual|auto`. `Stop` takes no matcher and always fires.

## What ships here

| Script | Event | Registered | What it does |
|---|---|---|---|
| `lint-on-edit.sh` | `PostToolUse` on `Edit\|Write` | Yes | Runs the right linter for the file type and returns failures as context so Claude fixes them in the same turn. |
| `guard-destructive.sh` | `PreToolUse` on `Bash` | Yes | Denies six command patterns: recursive root delete, force push, hard reset onto the remote default branch, reading `.env`, piping a download into a shell, and a raw `DROP` statement. |
| `session-context.sh` | `SessionStart` | Yes | Adds the branch, the uncommitted file count, and the last five commits, saving three tool calls per session. |
| `require-green-tests.sh` | `Stop` | No | Blocks the turn while the test suite is red. Unregistered by default; the header has the settings block. |

Each is a starting point. Edit `PATTERNS` in the guard to match your project, and
set `PLAYBOOK_TEST_COMMAND` for the test gate.

The lint and session hooks use `jq` and do nothing without it. The guardrail
never goes quiet: it reads the command with `jq`, falls back to `python3`, and
failing both matches its patterns against the raw payload and says so in the
reason it returns. A security control that cannot read its input must not wave
the input through.

## Permissions do some of this without a script

Not everything needs a hook. Permission rules in `.claude/settings.json` are
cheaper for simple cases:

```json
{
  "permissions": {
    "allow": ["Bash(npm run lint)", "Bash(git diff *)"],
    "deny": ["Read(./.env)", "Read(./.env.*)", "Edit(./.env)"]
  }
}
```

A `deny` rule takes effect immediately, including in a folder you have not
trusted. An `allow` rule waits until you trust the workspace.

One trap: in `Bash(git diff *)`, the space before the `*` matters. Without it,
`Bash(git diff*)` also matches `git diff-index`.

## Before you trust someone else's .claude directory

Hooks and MCP servers in a cloned repository are executable code. Two CVEs, one
from 2025 and one from 2026, concerned exactly this. Read `SECURITY.md` in this repository before running
any playbook, including this one.
