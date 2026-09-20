# Changelog

All notable changes to this playbook. Versions follow
[semantic versioning](https://semver.org). "Breaking" means a change that alters
what an existing user's `.claude/` directory does.

## [2.0.0] - 2026-09-20

Tested against Claude Code v2.1.263.

The first release since February 2026. Claude Code changed substantially in
between, and parts of the playbook had stopped working.

### Fixed

- **The lint hook never fired.** It was registered with a `command` key directly
  on the matcher entry and read a `$TOOL_INPUT_FILE_PATH` variable that does not
  exist. Hooks nest a `hooks` array under each matcher and receive JSON on
  stdin. Rewritten, and now registered in a `settings.json` that the repository
  previously did not ship at all.
- **The lint hook discarded its own output.** It sent linter errors to
  `/dev/null` and always exited 0, so Claude never learned a lint run had
  failed. It now returns the failures as `additionalContext`.
- **The memory precedence diagram was wrong.** It showed a ranked stack with
  rules overriding CLAUDE.md. Instruction files are concatenated, and rules
  without `paths` load at the same priority as `.claude/CLAUDE.md`.
- **"Skills only run when you explicitly invoke them" was wrong.** Skills are
  model-invocable by default.
- Hook event table listed 4 of more than 20 events, and one of five handler
  types.
- Skill and agent frontmatter references listed 3 fields each, of roughly 20 and
  17 respectively.

### Changed

- **Rules are now path-scoped.** All 14 rule files loaded in every session,
  about 6,976 words or roughly 9,400 tokens, including Alembic guidance in
  projects with no Python. Eight are now scoped with `paths:` frontmatter and
  six remain always-loaded. The always-loaded set is 1,271 words, about 1,700
  tokens, an 82% reduction with no rule removed. (Breaking: rules that used to
  apply everywhere now apply to matching files.)
- **Core rules were cut.** `engineering-principles.md` went from 749 to about
  220 words. The removed material restated DRY, YAGNI, KISS, and SRP, which the
  model applies without being told. What remains is the judgement it gets wrong.
- Every rule file now carries a dated comment recording why it exists, so a
  future reader can decide whether to keep it.
- `.claude/CLAUDE.md` raises its length guidance from 80 to 200 lines, matching
  Anthropic's, and adds compaction instructions.
- The three existing skills gained `allowed-tools`, `argument-hint`, and dynamic
  context injection with `` !`command` ``. `review` and `review-pr` now run as
  forked subagents via `context: fork`, so a review does not consume the main
  context.
- `security-reviewer` gained `model: opus`, `effort: high`, and a requirement to
  trace the path from untrusted input before reporting a finding.

### Added

- `.claude/settings.json` with hook registrations and permission rules.
- **Hooks**: `guard-destructive.sh` (PreToolUse, denies six command patterns),
  `session-context.sh` (SessionStart, adds branch and recent commits),
  `require-green-tests.sh` (Stop, blocks the turn while tests fail, ships
  unregistered).
- **Skills**: `verify`, which runs the project's checks and reports evidence
  rather than a claim; `plan-feature`, which interviews the user and writes
  `SPEC.md`.
- **Agents**: `explorer` (Haiku, read-only, for mapping code cheaply),
  `code-reviewer` (read-only, backs the two review skills), and `test-writer`
  (worktree-isolated, forbidden from editing the code under test).
- **Workflow**: `.claude/workflows/audit.js`, invoked as `/audit [what to look
  for]`. Runs one reviewer per file, then has a second independent agent try to
  refute each finding before it is reported.
- **Plugin distribution**: `.claude-plugin/plugin.json`,
  `.claude-plugin/marketplace.json`, and `hooks/hooks.json`. The playbook now
  installs with `/plugin marketplace add smartwhale8/claude-playbook`.
- **Eval suite** under `evals/`, with three cases including a negative case that
  fails if a skill hijacks an ordinary question.
- **CI**: manifest validation, shellcheck, JSON parse checks, and a gate that
  fails the build if the always-loaded rule set grows past 2,000 words. Plus two
  `claude-code-action@v1` workflows.
- **Docs**: choosing a component, plan and verify, hooks and guardrails,
  subagents and parallelism, context and cost, automation, and what's new.
- `SECURITY.md`, on reviewing a `.claude/` directory before trusting it.
- `AGENTS.md` and the cross-tool interoperability options.
- `.mcp.json.example`, inert until renamed.
- `scripts/review-diff.sh`, a working headless example.

### Reviewed

Before release, an independent agent checked every technical claim in this
repository against the live documentation. It found fourteen defects, all fixed
here, the most serious being a Stop hook that nested `decision` and `reason`
inside `hookSpecificOutput` where they belong at the top level, which would have
made the verification gate run the test suite and then silently do nothing. The
`$schema` URLs pointed at a marketing redirect rather than a schema, the plugin
registered two of the three hooks the standalone settings file registers, and
the CI eval invocation was missing `--trust-plugin` and `--allow-tools Bash`.

### Known limitations

- The eval suite has not been executed. `claude plugin eval` requires v2.1.269
  and the development machine runs v2.1.263. The case files conform to the
  documented schema and validate, but their scores are unmeasured. CI runs them
  once an `ANTHROPIC_API_KEY` secret exists.
- The hook scripts are tested on macOS with GNU-compatible `jq` and BSD `grep`.
  They have not been exercised on Windows.

## [1.0.0] - 2026-02-15

Initial release: a `.claude/` directory with a CLAUDE.md template, 14 rule
files, 3 skills, 1 subagent, and 1 hook script.
