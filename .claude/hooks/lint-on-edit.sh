#!/usr/bin/env bash
#
# PostToolUse hook: lint the file Claude just edited and report failures back.
#
# Contract (https://code.claude.com/docs/en/hooks):
#   - Hook input arrives as JSON on stdin, not as arguments.
#   - The edited path is `.tool_input.file_path`.
#   - Exit 0 and print JSON on stdout to hand Claude the linter output. Printing
#     the failures as `additionalContext` is what makes Claude fix them; a hook
#     that silently swallows linter output teaches Claude nothing.
#
# Registered in .claude/settings.json under PostToolUse with matcher "Edit|Write".
# Requires jq (https://jqlang.org). Without jq the hook exits 0 and does nothing.

set -uo pipefail

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

INPUT=$(cat)
FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

OUTPUT=""
STATUS=0

case "${FILE_PATH##*.}" in
  py)
    if command -v ruff >/dev/null 2>&1; then
      OUTPUT=$(ruff check --fix "$FILE_PATH" 2>&1)
      STATUS=$?
    fi
    ;;
  ts|tsx|js|jsx|mjs|cjs)
    if [ -f package.json ] && command -v npx >/dev/null 2>&1; then
      OUTPUT=$(npx --no-install eslint --fix "$FILE_PATH" 2>&1)
      STATUS=$?
    fi
    ;;
  go)
    if command -v gofmt >/dev/null 2>&1; then
      OUTPUT=$(gofmt -l -w "$FILE_PATH" 2>&1)
      STATUS=$?
    fi
    ;;
  rs)
    if command -v rustfmt >/dev/null 2>&1; then
      OUTPUT=$(rustfmt --edition 2021 "$FILE_PATH" 2>&1)
      STATUS=$?
    fi
    ;;
  sh|bash)
    if command -v shellcheck >/dev/null 2>&1; then
      OUTPUT=$(shellcheck "$FILE_PATH" 2>&1)
      STATUS=$?
    fi
    ;;
  *)
    exit 0
    ;;
esac

# The linter passed, or it auto-fixed everything it could. Say nothing.
if [ "$STATUS" -eq 0 ] || [ -z "$OUTPUT" ]; then
  exit 0
fi

# Hand the remaining failures to Claude so it fixes them in this turn.
jq -n --arg ctx "Lint failed for $FILE_PATH. Fix these before continuing:
$OUTPUT" '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: $ctx
  }
}'
exit 0
