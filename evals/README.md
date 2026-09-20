# Eval suite

These cases measure whether the playbook changes what Claude does, rather than
whether its files parse. `claude plugin validate` checks the schemas; this
checks the behaviour.

## Run them

```bash
claude plugin eval . --allow-tools Bash
claude plugin eval . --case verify-before-done --allow-tools Bash
claude plugin eval . --runs 1 --ablation none --allow-tools Bash   # fastest, while iterating
claude plugin eval . --threshold 0.8 --trust-plugin --allow-tools Bash --json   # what CI runs
```

Two flags are not optional here:

- **`--allow-tools Bash`.** A case's `allowed_tools` grants read-only tools
  only. `Bash`, `Write`, `Edit`, `WebFetch`, and `WebSearch` are removed from
  the session unless granted on the command line, and neither the case nor a
  skill's own `allowed-tools` can widen that. Two of these cases need to run
  commands, so without this flag they fail for the wrong reason.
- **`--trust-plugin` in CI.** The first run against a directory asks
  `Trust this plugin directory?`. Under `--json`, or when stdout is not a
  terminal, it cannot ask and exits 1 instead.

Requires Claude Code v2.1.269 or later. Earlier versions answer
`plugin eval is currently in early access`.

Results land in `evals/results/<timestamp>/`, as `aggregate-result.json` and a
self-contained `report.html`.

## Reading the result

Every case runs twice over: once with the plugin loaded, once without. The
number that matters is `Δ`, the difference between the two.

A case scoring 1.0 in both arms means the playbook did nothing. Claude would
have got there anyway, and the case is not evidence for the playbook. A case
with a positive `Δ` is the playbook earning its context.

## The cases

| Case | What it asks | What it proves |
|---|---|---|
| `review-uncommitted-changes` | Review a diff with four planted defects: a hardcoded key, SQL injection, an N+1 query, and dead code. | The review skill finds real defects and returns a verdict, rather than commenting on style. |
| `verify-before-done` | Confirm that a change works, in an empty workspace where nothing can be verified. | The verify skill reports honestly that it could not verify, instead of asserting success. This is the failure the skill exists to prevent. |
| `no-false-trigger` | An ordinary git question. | No skill hijacks the conversation. A description written too broadly fails here, which is why the case has `min: 0, max: 0` on its `tool_used` grader. |

## Adding a case

```
evals/<case-name>/
├── prompt.md              # frontmatter: max_turns, allowed_tools, tags. Body: the prompt.
└── graders/
    ├── <name>.md          # one grader per file; the filename is the grader name
    └── ...
```

Write the prompt the way a user would type it, not by naming the skill, unless
the skill is user-invoked only (`disable-model-invocation: true`), in which case
the invocation belongs in the prompt.

Give each case one grader on the result and one on how Claude got there. The
cheap grader types (`regex`, `tool_used`, `tool_order`, `file_exists`) read the
transcript and cost nothing. The `llm` and `baseline` types call a judge model.

`claude plugin eval init` will interview you and write a suite for you.
