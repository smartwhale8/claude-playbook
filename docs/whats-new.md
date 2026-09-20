# What's new in Claude Code, and what the playbook does about it

Tested against **Claude Code v2.1.263**. Latest release at the time of writing:
v2.1.278 (19 September 2026).

This page maps Claude Code releases to changes in this repository. If you last
read the playbook before September 2026, this is what changed underneath it.

## Since February 2026

### Things the old playbook got wrong

| Area | What the playbook said | What is actually true |
|---|---|---|
| Hook registration | `{"matcher": "...", "command": "..."}` | Each matcher group holds a `hooks` array of `{"type": "command", "command": ...}` handlers. The old form never fired. |
| Hook input | `$TOOL_INPUT_FILE_PATH` as an argument | JSON on stdin. The path is `.tool_input.file_path`. No such variable exists. |
| Hook events | Four | More than twenty, and five handler types, not just `command`. |
| Skills | "Only run when you explicitly invoke them" | Model-invocable by default. `disable-model-invocation: true` makes them user-only. |
| Memory precedence | A ranked stack with rules above CLAUDE.md | Files are concatenated, not overridden. Rules without `paths` load at the same priority as `.claude/CLAUDE.md`. |
| Skill frontmatter | 3 fields | Around 20, including `allowed-tools`, `context: fork`, `paths`, `model`, `effort`, and `hooks`. |
| Agent frontmatter | 3 fields | Around 17, including `model`, `isolation: worktree`, `permissionMode`, `memory`, and `background`. |

### Features the playbook now covers

| Feature | Version | Where |
|---|---|---|
| `AGENTS.md` read directly | v2.1.277 | `AGENTS.md` |
| `claude plugin eval` | v2.1.269 | `evals/` |
| `/skill-doctor` | v2.1.252 | [context and cost](context-and-cost.md) |
| Dynamic workflows, `ultracode` | v2.1.203 | [subagents and parallelism](subagents-and-parallelism.md) |
| `--permission-prompts none` | v2.1.259 | [automation](automation.md) |
| `background: false` on forked skills | v2.1.218 | `review` and `review-pr` skills |
| `${CLAUDE_PROJECT_DIR}` in skills | v2.1.196 | Not depended on here. The playbook uses the placeholder in hook commands, where no such floor applies |
| Agent teams | documented as of v2.1.178 | [subagents and parallelism](subagents-and-parallelism.md) |
| Routines | research preview | [automation](automation.md) |
| `/goal` | | [plan and verify](plan-and-verify.md) |
| Fast mode in cloud sessions | v2.1.271 | Mentioned under model selection |

### Model lineup

Fable 5.1, Opus 5, Sonnet 5, and Haiku 4.5. Aliases `fable`, `opus`, `sonnet`,
`haiku`, plus `best`, `opusplan`, and the `[1m]` suffix for a one-million-token
window. Effort is a separate axis: `low`, `medium`, `high`, `xhigh`, `max`.

Anything in this repository naming an older model is a bug. Report it.

## Playbook version history

See [CHANGELOG.md](../CHANGELOG.md).

## Keeping this current

The repository runs a monthly routine that reads the Claude Code changelog and
opens an issue listing anything new that the playbook does not yet document. The
prompt is in [automation](automation.md) if you want the same for your own.

Checking by hand:

```bash
claude --version
claude plugin validate . --strict
/context        # what your setup costs
/doctor         # proposed cuts to CLAUDE.md
/skill-doctor   # skills that never fire
```

The changelog is at https://code.claude.com/docs/en/changelog.
