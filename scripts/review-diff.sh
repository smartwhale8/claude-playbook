#!/usr/bin/env bash
#
# Headless review of the current branch against main, as JSON.
#
# Shows the shape of a `claude -p` call you can put in CI, a pre-push hook, or a
# package.json script. Three flags carry the weight:
#
#   --bare              Skip auto-discovery of hooks, plugins, MCP servers, auto
#                       memory, and CLAUDE.md. This is what makes the run give
#                       the same answer on every machine, and it is the
#                       recommended mode for scripted calls. It also means the
#                       run does NOT use your subscription login, so set
#                       ANTHROPIC_API_KEY.
#   --output-format json  Returns a JSON object with `result`, `session_id`, and
#                       `total_cost_usd`, so a script can branch on the outcome
#                       and track spend per invocation.
#   --permission-mode dontAsk  Deny anything that would prompt, since nobody is
#                       there to answer. Reads in the working directory and the
#                       read-only command set still run.
#
# Usage:  ./scripts/review-diff.sh [base-branch]

set -euo pipefail

BASE="${1:-main}"

if [ -z "${ANTHROPIC_API_KEY:-}" ]; then
  echo "Set ANTHROPIC_API_KEY. Bare mode does not read your subscription login." >&2
  exit 1
fi

DIFF=$(git diff "$BASE"...HEAD)

if [ -z "$DIFF" ]; then
  echo "No changes against $BASE." >&2
  exit 0
fi

# Piping the diff in means Claude needs no Bash permission to read it.
printf '%s' "$DIFF" | claude --bare -p \
  "Review this diff for correctness and security defects only. For each one give
   the file, the line, the problem, and the fix. Report nothing about style. If
   you find no defects, say so in one line." \
  --append-system-prompt "You are a senior engineer reviewing a colleague's diff." \
  --output-format json \
  --max-turns 5 \
  --permission-mode dontAsk \
  | tee /dev/stderr \
  | jq -r '.result'
