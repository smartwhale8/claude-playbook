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
# Edit the PATTERNS list to match your project.
#
# On parsing the input: a security control that cannot read its input must not
# wave the input through. This script reads the command with jq, falls back to
# python3, and if neither exists falls back to matching the patterns against the
# raw stdin payload. The raw pass is less precise, so it can refuse a command
# that merely mentions a dangerous string, but it fails closed on the patterns
# that matter and stays out of the way of everything else. It also tells you to
# install jq, once per blocked call, through `systemMessage`.

set -uo pipefail

INPUT=$(cat)

if [ -z "$INPUT" ]; then
  exit 0
fi

COMMAND=""
DEGRADED=0

# Try each parser in turn. A parser that is installed but broken, or that
# returns nothing, falls through to the next one instead of ending the check.
# Giving up here would mean allowing the command, which is the one outcome a
# guardrail must never reach by accident.
if command -v jq >/dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null) || COMMAND=""
fi

if [ -z "$COMMAND" ] && command -v python3 >/dev/null 2>&1; then
  COMMAND=$(printf '%s' "$INPUT" | python3 -c \
    'import json,sys
try:
    sys.stdout.write(json.load(sys.stdin).get("tool_input", {}).get("command", ""))
except Exception:
    pass' 2>/dev/null) || COMMAND=""
fi

if [ -z "$COMMAND" ]; then
  # No parser produced a command. Match the patterns against the whole payload
  # rather than waving the call through. Replace the JSON punctuation with
  # spaces first, using bash's own substitution so this needs no extra tool:
  # several patterns anchor on a space or end of line, and a command sitting
  # inside a JSON string is followed by a quote instead.
  COMMAND="${INPUT//\"/ }"
  COMMAND="${COMMAND//\\/ }"
  COMMAND="${COMMAND//\{/ }"
  COMMAND="${COMMAND//\}/ }"
  DEGRADED=1
fi

# grep is what does the matching. Without it this script cannot check anything,
# and saying so is better than passing silently.
if ! command -v grep >/dev/null 2>&1; then
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"The project guardrail hook cannot run because grep is not on PATH, so destructive commands cannot be checked. Fix PATH or remove the hook from .claude/settings.json."}}\n'
  exit 0
fi

deny() {
  reason="$1"
  if [ "$DEGRADED" -eq 1 ]; then
    reason="$reason (Matched against the raw hook payload because neither jq nor python3 is installed, so this check is imprecise. Install jq.)"
  fi
  # printf rather than jq, so a deny still works with no parser present. The
  # reasons below are fixed strings with no quotes, backslashes or newlines.
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason"
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
