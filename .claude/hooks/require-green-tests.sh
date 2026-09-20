#!/usr/bin/env bash
#
# Stop hook: refuse to end the turn while the test suite is red.
#
# This is the strongest verification gate in the playbook. A prompt asking Claude
# to run the tests is advice; this hook is a gate. Claude cannot finish the turn
# until the command exits 0.
#
# Contract (https://code.claude.com/docs/en/hooks#stop-decision-control):
#   - A Stop hook returns `decision: "block"` with a `reason` to send Claude back
#     to work. Both fields are TOP LEVEL, not inside `hookSpecificOutput`. Only
#     `additionalContext` nests there, and that is the softer form: guidance
#     rather than an error.
#   - Claude Code overrides the hook and ends the turn after 8 consecutive
#     blocks, so a permanently failing suite cannot trap a session. The
#     `stop_hook_active` input field is true while that is happening.
#   - Stop hooks take no matcher; they fire on every turn end.
#
# NOT registered by default, because running the full suite after every turn is
# the wrong trade for most projects. Turn it on in .claude/settings.json when you
# want an unattended run to be trustworthy:
#
#   "Stop": [
#     {
#       "hooks": [
#         {
#           "type": "command",
#           "command": "\"${CLAUDE_PROJECT_DIR}\"/.claude/hooks/require-green-tests.sh",
#           "timeout": 600
#         }
#       ]
#     }
#   ]
#
# Set TEST_COMMAND to your suite. Requires jq.

set -uo pipefail

TEST_COMMAND="${PLAYBOOK_TEST_COMMAND:-npm test}"

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

INPUT=$(cat)

# Claude Code caps consecutive blocks at 8, and sets stop_hook_active while it is
# already continuing because of a stop hook. Bow out early rather than spending a
# full test run on a turn that is already in that loop.
if [ "$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false')" = "true" ]; then
  exit 0
fi

# Only gate turns that actually touched the codebase. A question about the code
# should not trigger a test run.
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
    exit 0
  fi
fi

OUTPUT=$(eval "$TEST_COMMAND" 2>&1)
STATUS=$?

if [ "$STATUS" -eq 0 ]; then
  exit 0
fi

TAIL=$(printf '%s' "$OUTPUT" | tail -40)

jq -n --arg reason "The test suite is failing, so the work is not done. Command: ${TEST_COMMAND}

${TAIL}

Fix the failures and run the suite again. Do not disable, skip, or weaken a test to make it pass." '{
  decision: "block",
  reason: $reason
}'
exit 0
