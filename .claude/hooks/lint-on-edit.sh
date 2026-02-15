#!/bin/bash
# Hook: Run linter after file edits
# Register in .claude/settings.json under PostToolUse for the Edit/Write tools
#
# Example settings.json entry:
# {
#   "hooks": {
#     "PostToolUse": [
#       {
#         "matcher": "Edit|Write",
#         "command": ".claude/hooks/lint-on-edit.sh \"$TOOL_INPUT_FILE_PATH\""
#       }
#     ]
#   }
# }

FILE_PATH="$1"

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

EXTENSION="${FILE_PATH##*.}"

case "$EXTENSION" in
  py)
    ruff check "$FILE_PATH" --fix --quiet 2>/dev/null
    ;;
  ts|tsx|js|jsx)
    npx eslint "$FILE_PATH" --fix --quiet 2>/dev/null
    ;;
  *)
    # No linter configured for this file type
    ;;
esac
