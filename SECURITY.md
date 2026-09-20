# Security

## Read this before running any playbook, including this one

A `.claude/` directory is executable code. Hooks run shell commands, MCP servers
start processes, and both can act before you have approved anything.

Two CVEs concerned exactly this path. CVE-2025-59536 let a project execute code
before the user accepted the trust dialog, fixed in Claude Code 1.0.111.
CVE-2026-21852 let a repository's settings file point `ANTHROPIC_BASE_URL` at an
attacker's endpoint and exfiltrate API keys before trust was confirmed, fixed in
2.0.65.

Claude Code has since added workspace trust: `permissions.allow`,
`additionalDirectories`, `extraKnownMarketplaces`, and most `env` values wait
until you trust the folder. `deny` and `ask` rules apply immediately.

The gap that remains is `claude -p` without `--bare`. A non-interactive run shows
no trust dialog and no per-server approval, and it still executes a repository's
hooks and connects its MCP servers. Pass `--bare` for scripted runs in any
repository you did not write.

## Review this repository before you use it

Four things to read, in this order. They are short by design.

1. **`.claude/hooks/*.sh`** (four scripts, about 200 lines total). These run
   automatically. `guard-destructive.sh` and `lint-on-edit.sh` run on every Bash
   command and every edit respectively.
2. **`.claude/settings.json`**. Which hooks are registered, and what the
   permission rules allow and deny.
3. **`hooks/hooks.json`**. The same hooks, as the plugin registers them.
4. **`.mcp.json.example`**. It ships inert, with an `.example` suffix, so no MCP
   server starts until you rename it and read what it points at.

What these hooks do: run your project's linter on edited files, block six
destructive shell patterns, and add your git branch and recent commits at
session start. They make no network requests, send nothing anywhere, and read no
file outside your project.

They require `jq` and exit silently without it.

## When you adopt it

- Read the hook scripts. Do not take the paragraph above on trust; that is the
  entire point of this page.
- Edit `PATTERNS` in `guard-destructive.sh` for your project. The shipped list is
  a starting point and is not exhaustive.
- The permission `deny` rules cover `.env` and `secrets/`. Add the paths that
  matter in your repository.
- Treat a change to `.claude/` in a pull request with the same scrutiny as a
  change to a build script, because that is what it is.

## Reporting a vulnerability in this repository

Open a GitHub security advisory at
https://github.com/smartwhale8/claude-playbook/security/advisories/new rather
than a public issue.

For a vulnerability in Claude Code itself, report it to Anthropic:
https://www.anthropic.com/responsible-disclosure-policy
