#!/usr/bin/env bash
#
# PreToolUse hook: deny shell commands that are destructive or that leak secrets.
#
# Contract (https://code.claude.com/docs/en/hooks):
#   - Hook input arrives as JSON on stdin; the command is `.tool_input.command`.
#   - Printing a `permissionDecision` of "deny" blocks the call and gives Claude
#     the reason. Exit code stays 0: the JSON carries the decision.
#   - A rule that must hold every time belongs here, never in CLAUDE.md. CLAUDE.md
#     is context Claude weighs; this hook is a gate Claude cannot talk its way past.
#
# Registered in .claude/settings.json under PreToolUse with matcher "Bash".
# Edit the PATTERNS list to match your project. Requires jq.

set -uo pipefail

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

deny() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

# Each entry is "<extended regex>@@<reason shown to Claude>". The separator is
# @@ rather than a pipe, because the regexes themselves contain pipes.
PATTERNS=(
  'rm[[:space:]]+(-[[:alnum:]]*[rR][[:alnum:]]*[[:space:]]+)+/($|[[:space:]])@@Recursive delete of the filesystem root is blocked by the project guardrail hook.'
  'git[[:space:]]+push([[:space:]]|$).*(--force([[:space:]]|$)|-f([[:space:]]|$))@@Force push is blocked. Use --force-with-lease, and never force push to a shared branch.'
  'git[[:space:]]+reset[[:space:]]+--hard[[:space:]]+origin/(main|master)@@Hard reset onto the remote default branch discards local work. Blocked by the project guardrail hook.'
  '(cat|less|more|head|tail|bat)[[:space:]]+[^|;&]*\.env([[:space:]]|"|$)@@Reading .env prints secrets into the transcript. Read .env.example instead.'
  'curl[[:space:]][^|;&]*\|[[:space:]]*(sudo[[:space:]]+)?(ba)?sh([[:space:]]|$)@@Piping a downloaded script straight into a shell is blocked. Download it, read it, then run it.'
  'DROP[[:space:]]+(TABLE|DATABASE|SCHEMA)@@A DROP statement reached the shell. Blocked by the project guardrail hook. Run destructive SQL yourself.'
)

for entry in "${PATTERNS[@]}"; do
  regex="${entry%%@@*}"
  reason="${entry#*@@}"
  if printf '%s' "$COMMAND" | grep -qiE "$regex"; then
    deny "$reason"
  fi
done

exit 0
